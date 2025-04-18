function Update-UserLicense {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory = $true, ValidateSet = 'Add', 'Remove', 'Update')]
        [switch]$action,
        [Parameter(Mandatory = $false)]
        [string[]]$AddSkus,
        [Parameter(Mandatory = $false)]
        [string[]]$RemoveSkus,
        [Parameter(Mandatory = $false)]
        [switch]$Backup

    )
    # Build Parameter Set
    $params = @{
        UserId = $UserPrincipalName
        AddLicenses       = @()
        RemoveLicenses    = @()
    }
    # Perform action based on the switch
    if ($action -eq 'Add') {
        $params.AddLicenses = $AddSkus
    } elseif ($action -eq 'Remove') {
        $params.RemoveLicenses = $RemoveSkus
    } elseif ($action -eq 'Update') {
        $params.AddLicenses = $AddSkus
        $params.RemoveLicenses = $RemoveSkus
    }
    # Check if the user exists
    try {
        Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
    } catch {
        Write-Error "User $UserPrincipalName not found."
        return
    }
    # Backup the current licenses if requested
    if ($Backup) {
        $currentLicenses = Get-MgUserLicenseDetail -UserId $UserPrincipalName
        # Save to tmp file
        $backupFile = "$env:TEMP\$UserPrincipalName-Licenses-Backup.json"
        $currentLicenses | ConvertTo-Json | Out-File -FilePath $backupFile -Force
        Write-Host "Backup of current licenses saved for $userPrincipalName"
    }
    # Update the licenses
    try {
        Set-MgUserLicense @params
        Write-Host "Licenses updated for $UserPrincipalName"
    } catch {
        Write-Error "Failed to update licenses for $($UserPrincipalName): $_"
    }
}