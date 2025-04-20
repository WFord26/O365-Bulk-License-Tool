function Import-UserFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    # Check if the file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }
    # Confirm the file extension is .csv, .json, .xml, or .txt
    $extension = [System.IO.Path]::GetExtension($FilePath)
    if ($extension -notin @('.csv', '.json', '.xml', '.txt')) {
        Write-Error "Unsupported file type: $extension. Supported types are .csv, .json, .xml, .txt"
        return
    }
    # Import the file based on its extension
    switch ($extension) {
        '.csv' {
            $data = Import-Csv -Path $FilePath
        }
        '.json' {
            $data = Get-Content -Path $FilePath | ConvertFrom-Json
        }
        '.xml' {
            $data = [xml](Get-Content -Path $FilePath)
        }
        '.txt' {
            $data = Get-Content -Path $FilePath
        }
    }
    # Confirm the $data has a header labled "UPN", "EMAIL", or "UserPrincipalName"
    if ($data | Get-Member -Name 'UPN' -ErrorAction SilentlyContinue) {
        $header = 'UPN'
    } elseif ($data | Get-Member -Name 'EMAIL' -ErrorAction SilentlyContinue) {
        $header = 'EMAIL'
    } elseif ($data | Get-Member -Name 'UserPrincipalName' -ErrorAction SilentlyContinue) {
        $header = 'UserPrincipalName'
    } else {
        Write-Error "No valid header found in the file. Expected headers are UPN, EMAIL, or UserPrincipalName."
        return
    }
    # Normalize the header to "UserPrincipalName"
    if ($header -ne 'UserPrincipalName') {
        $data | ForEach-Object {
            $_ | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $_.$header -Force
            $_.PSObject.Properties.Remove($header)
        }
    }
    return $data
}