# Purpose: Imports the custom Windows Event Channel and XML subscriptions for Azure Sentinel on the WEF host
# Note: This only needs to be installed on the WEF server

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing WEF Subscriptions for Azure Sentinel..."

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if WEF Subscriptions for Splunk have already been installed..."
if ((Test-Path "$env:windir\system32\CustomEventChannels.dll"))
{
	Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating custom event subscriptions for Azure Sentinel..."
	cd c:\Users\vagrant\AppData\Local\Temp\Sentinel-WEF\windows-event-forwarding-master\wef-subscriptions
	cmd /c "for /r %i in (*.xml) do wecutil cs %i"
	
	Start-Sleep -Seconds 5

	Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Enabling custom event subscriptions for Azure Sentinel..."
	cmd /c "for /r %i in (*.xml) do wecutil ss %~ni /e:true"
	
	Start-Sleep -Seconds 5

	Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Enabling WecUtil Quick Config..."
	wecutil qc /q:true
	
	Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Restarting the Windows Event Collector Service..."
	Restart-Service -Name Wecsvc
}
else
{
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) WEF Subscriptions for Splunk have not yet been installed..."
}

if ((Get-Service -Name wecsvc).Status -ne "Running")
{
    throw "Windows Event Collector failed to restart"
}