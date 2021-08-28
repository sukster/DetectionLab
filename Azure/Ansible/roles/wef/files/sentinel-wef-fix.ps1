Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Stopping the Windows Event Collector Service..."
Stop-Service -Name Wecsvc

if ((Get-Service -Name Wecsvc).Status -ne "Running")
  {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting log file for all WEF subscriptions to Forwarded Events..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\EventCollector\Subscriptions\*" -Name "LogFile" -Value "ForwardedEvents"
	
  }

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Starting the Windows Event Collector Service..."
Start-Service -Name Wecsvc

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Stopping the Splunk Forwarder Service..."
Stop-Service -Name SplunkForwarder

if ((Get-Service -Name SplunkForwarder).Status -ne "Running")
  {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling the Splunk Forwarder Service..."
	Set-Service -Name SplunkForwarder -StartupType Disabled
  }

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Restarting the Microsoft Monitoring Agent Service..."
Restart-Service -Name HealthService