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
        foreach ($sku in $AddSkus) {
            $params.AddLicenses += @{
                SkuId = $sku
            }
        }
    } elseif ($action -eq 'Remove') {
        # Remove licenses from the parameter set
        foreach ($sku in $RemoveSkus) {
            $params.RemoveLicenses += @{
                SkuId = $sku
            }
        }
    } elseif ($action -eq 'Update') {
        # Update licenses in the parameter set
        foreach ($sku in $AddSkus) {
            $params.AddLicenses += @{
                SkuId = $sku
            }
        }
        foreach ($sku in $RemoveSkus) {
            $params.RemoveLicenses += @{
                SkuId = $sku
            }
        }
    }
    # Check if the user exists
    try {
        Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
    } catch {
        Write-Error "User $UserPrincipalName not found."
        return $false
    }
    # Backup the current licenses if requested
    if ($Backup) {
        $currentLicenses = Get-MgUserLicenseDetail -UserId $UserPrincipalName
        # Check if the backup array is initialized
        if (-not $script:backupArray) {
            $script:backupArray = @()
        }
        # Add the current licenses to the backup array
        $script:backupArray += [PSCustomObject]@{
            UserPrincipalName = $UserPrincipalName
            Licenses          = $currentLicenses
        }
        Write-Host "Backup created for $UserPrincipalName"
    }
    # Update the licenses
    try {
        Set-MgUserLicense @params
        Write-Host "Licenses updated for $UserPrincipalName"
        return $true
    } catch {
        Write-Error "Failed to update licenses for $($UserPrincipalName): $_"
        retrun $false
    }
}