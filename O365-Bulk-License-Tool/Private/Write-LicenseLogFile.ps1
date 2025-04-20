function Write-LicenseLogFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogFilePath,
        [Parameter(Mandatory = $true)]
        [string]$Action,
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory = $false)]
        [string]$Status,
        [Parameter(Mandatory = $false)]
        [string]$ErrorMessage
    )

    # Check if the log file exists
    if (-Not (Test-Path -Path $LogFilePath)) {
        Write-Error "Log file not found: $LogFilePath"
        return
    }

    # Create a log entry
    $logEntry = @{
        Timestamp       = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Action          = $Action
        UserPrincipalName = $UserPrincipalName
        Status          = $Status
        ErrorMessage    = $ErrorMessage
    }

    # Convert the log entry to JSON and append it to the log file
    $logEntry | ConvertTo-Json | Out-File -Append -FilePath $LogFilePath -Encoding UTF8
}