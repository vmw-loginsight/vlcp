
function main()
{
	Write-Host "------------------------------- Executing 'ex_admin_auditlog' function ---------------------------------"
	Write-Host ""
	ex_admin_auditlog
	Write-Host "------------------------------- Executing 'ex_perfcounter' function ------------------------------------"
	Write-Host ""
	ex_perfcounter	
	Write-Host "------------------------------- Executing 'ex_serverconf' function -------------------------------------"
	Write-Host ""
	ex_serverconf
}

# Execute other scripts containing the functions first before calling main function
. .\exchange_admin_audit_log.ps1
. .\exchange_performanceCounter.ps1
. .\exchange_server_configuration.ps1

# Connect to Exchange server to execute exchange cmdlets
#. $env:ExchangeInstallPath\bin\RemoteExchange.ps1
#Connect-ExchangeServer -auto -AllowClobber

# Execute main function
. main;
