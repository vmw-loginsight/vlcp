
function main()
{
	ex_admin_auditlog
	ex_perfcounter	
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
