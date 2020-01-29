
function main()
{
	ex_dbinfo
	exchange_email_stats	
	exchange_mailbox_stats
	exchange_environment_report
}

# Execute other scripts containing the functions first before calling main function
. .\exchange_server_db_info.ps1
. .\exchange_email_stats.ps1
. .\exchange_mailbox_stats.ps1
. .\exchange_environment_report.ps1

# Connect to Exchange server to execute exchange cmdlets
. $env:ExchangeInstallPath\bin\RemoteExchange.ps1
Connect-ExchangeServer -auto -AllowClobber

# Execute main function
. main;
