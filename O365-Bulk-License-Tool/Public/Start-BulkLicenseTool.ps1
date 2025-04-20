function Start-BulkLicenseTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$UserFile,
        [Parameter(Mandatory = $true, ValidateSet = 'Add', 'Remove', 'Update')]
        [String]$Action,
        [Parameter(Mandatory = $false)]
        [String[]]$AddSkus,
        [Parameter(Mandatory = $false)]
        [String[]]$RemoveSkus,
        [Parameter(Mandatory = $false)]
        [string]$Backup,
        [Parameter(Mandatory = $false)]
        [string]$TenantId,
        [Parameter(Mandatory = $false)]
        [string]$ClientId,
        [Parameter(Mandatory = $false)]
        [string]$ClientSecret
    )

    #Connect to Microsoft Graph
    if ($ClientId -and $ClientSecret -and $TenantId) {
        Connect-MGG -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret -scope @('User.ReadWrite.All', 'Organization.Read.All')
    } else {
        Connect-MGG -Interactive -scope @('User.ReadWrite.All', 'Organization.Read.All')
    }
    # Confirm the user is connected to Microsoft Graph
    if (-not (Get-MgContext)) {
        Write-Error "Not connected to Microsoft Graph. Please connect first."
        return
    }

    # Get MG context
    $org = Get-MgContext

    $users = Import-UserFile -FilePath $UserFile
    if ($null -eq $users) {
        Write-Error "Failed to import user file."
        return
    }

    # Set the log file
    $log = Set-LogFile -Name "$($org.DisplayName)-$Action" -overwrite $true

    # Create a backup array if requested
    if ($Backup) {
        $script:backupArray = @()
    }

    # Get the tenant licenses
    $tenantLicenses = Group-TenantLicenses
    if ($null -eq $tenantLicenses) {
        Write-Error "Failed to get tenant licenses."
        return
    }

    # Check if the action is valid
    if ($Action -notin @('Add', 'Remove', 'Update')) {
        Write-Error "Invalid action: $Action. Valid actions are Add, Remove, Update."
        return
    }

    # Cycle through each user
    foreach ($user in $users) {
        if ($action -eq 'Add') {
            $gridAddLicenses = $tenantLicenses.SkuFriendlyName | Out-GridView -Title "Choose licenes to Add" -PassThru
            $gridAddLicenses = $gridAddLicenses | ForEach-Object { $_.SkuId }
            $gridRemoveLicenses = $null
        } elseif ($action -eq 'Remove') {
            $gridRemoveLicenses = $tenantLicenses.SkuFriendlyName | Out-GridView -Title "Choose licenes to Remove" -PassThru
            $gridRemoveLicenses = $gridRemoveLicenses | ForEach-Object { $_.SkuId }
            $gridAddLicenses = $null
        } elseif ($action -eq 'Update') {
            $gridAddLicenses = $tenantLicenses.SkuFriendlyName | Out-GridView -Title "Choose licenes to Add" -PassThru
            $gridAddLicenses = $gridAddLicenses | ForEach-Object { $_.SkuId }
            $gridRemoveLicenses = $tenantLicenses.SkuFriendlyName | Out-GridView -Title "Choose licenes to Remove" -PassThru
            $gridRemoveLicenses = $gridRemoveLicenses | ForEach-Object { $_.SkuId }
        }
        # Check if the user exists
        try {
            Get-MgUser -UserId $user.UserPrincipalName -ErrorAction Stop
        } catch {
            Write-Error "User $($user.UserPrincipalName) not found."
            continue
        }
        
        $params = @{
            UserId = $user.UserPrincipalName
            AddLicenses       = @()
            RemoveLicenses    = @()
        }
        # Perform action based on the switch
        if ($Action -eq 'Add') {
            foreach ($sku in $gridAddLicenses) {
                $params.AddLicenses += @{
                    SkuId = $sku
                }
            }
        } elseif ($Action -eq 'Remove') {
            # Remove licenses from the parameter set
            foreach ($sku in $gridRemoveLicenses) {
                $params.RemoveLicenses += @{
                    SkuId = $sku
                }
            }
        } elseif ($Action -eq 'Update') {
            # Update licenses in the parameter set
            foreach ($sku in $gridAddLicenses) {
                $params.AddLicenses += @{
                    SkuId = $sku
                }
            }
            foreach ($sku in $gridRemoveLicenses) {
                $params.RemoveLicenses += @{
                    SkuId = $sku
                }
            }
        }
        # Add the action to the params
        $params.Action = $Action
        # Add the backup to the params
        if ($Backup) {
            $params.Backup = $true
        }
        

        # Upadte the user licenses
        $result = Update-UserLicense @params

        if ($result) {
            Write-Host "Successfully updated licenses for user $($user.UserPrincipalName)"
            # Write to the log file
            Write-LicenseLogFile -LogFilePath $log -Action $Action -UserPrincipalName $user.UserPrincipalName -Status "Success"
            
        } else {
            Write-Error "Failed to update licenses for user $($user.UserPrincipalName)"
            # Write to the log file
            Write-LicenseLogFile -LogFilePath $log -Action $Action -UserPrincipalName $user.UserPrincipalName -Status "Failed" -ErrorMessage "Failed to update licenses"
        }
    }

    # Export the backup array if requested
    if ($Backup) {
        $backupFile = Join-Path -Path (Split-Path -Path $log -Parent) -ChildPath "Backup-$($org.DisplayName)-$Action.json"
        $script:backupArray | ConvertTo-Json | Out-File -FilePath $backupFile -Encoding UTF8
        Write-Host "Backup file created at $backupFile"
    }
    # Close the log file
    $logFile = Get-Content -Path $log
    $logFile | Out-File -FilePath $log -Encoding UTF8
    Write-Host "Log file closed at $log"
    # Return the log file path
    return $log
}