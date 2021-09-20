# Purpose: Downloads and unzips a copy of the Palantir WEF Github Repo customized for Azure Sentinel. This includes WEF subscriptions and custom WEF channels.

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and unzipping the Palantir Windows Event Forwarding Repo customized for Azure Sentinel..."

$wefRepoPath = 'C:\Users\vagrant\AppData\Local\Temp\WEF-Sentinel-Master.zip'

If (-not (Test-Path $wefRepoPath))
{
    # GitHub requires TLS 1.2 as of 2/1/2018
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # Disabling the progress bar speeds up IWR https://github.com/PowerShell/PowerShell/issues/2138
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://github.com/sukster/windows-event-forwarding/archive/master.zip" -OutFile $wefRepoPath
    Expand-Archive -path "$wefRepoPath" -destinationpath 'c:\Users\vagrant\AppData\Local\Temp\Sentinel-WEF' -Force
}
else
{
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $wefRepoPath already exists. Moving On."
}
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Palantir WEF for Azure Sentinel download complete!"
