function Set-LogFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$path,
        [Parameter(Mandatory = $false)]
        [switch]$overwrite
    )
    # Check if the log file already exists
    if ($path){
        $dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $fullpath = Join-Path -Path $path -ChildPath "$Name-$dateTime.log"
        if (Test-Path -Path $fullpath) {
            # Optionally, you can choose to overwrite or append
            if ($overwrite) {
                Remove-Item -Path $fullpath -Force
                New-Item -Path $fullpath -ItemType File -Force | Out-Null
                Write-Host "Log file overwritten at $fullpath"
            } else {
                Write-Host "Log file already exists at $fullpath"
                return
            }
        } else {
            # Create the log file
            New-Item -Path $fullpath -ItemType File -Force | Out-Null
            Write-Host "Log file created at $fullpath"
            
        }
    } else {
        $dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        # Check if working on windows or Linux
        if ($env:SYS_PLATFORM -eq "win32") {
            $path = "$env:USERPROFILE\Documents\0365_Bulk_License_Tool\logs"
        } else {
            $path = "$env:HOME/0365_Bulk_License_Tool/logs"
        }
        $fullpath = Join-Path -Path $path -ChildPath "$Name-$dateTime.log"
        if (Test-Path -Path $fullpath) {
            # Optionally, you can choose to overwrite or append
            if ($overwrite) {
                Remove-Item -Path $fullpath -Force
                New-Item -Path $fullpath -ItemType File -Force | Out-Null
                Write-Host "Log file overwritten at $fullpath"
            } else {
                Write-Host "Log file already exists at $fullpath"
                return
            }
        } else {
            # Create the log file
            New-Item -Path $fullpath -ItemType File -Force | Out-Null
            Write-Host "Log file created at $fullpath"
            
        }
    }
    # Get Tenant Name
    $org = Get-MgOrganization
    $tenantName = $org.DisplayName
    # Initialize the log file with a header
    $header = "Log file created on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') for tenant $tenantName"
    Add-Content -Path $fullpath -Value $header
    # Return the full path of the log file
    return $fullpath
}