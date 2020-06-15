
function main()
{
	Write-Host "------------------------------- Executing 'ex_dbinfo' function -----------------------------------------"
	Write-Host ""
	ex_dbinfo
	Write-Host "------------------------------- Executing 'exchange_email_stats' function ------------------------------"
	Write-Host ""
	exchange_email_stats
	Write-Host "------------------------------- Executing 'exchange_mailbox_stats' function ----------------------------"
	Write-Host ""	
	exchange_mailbox_stats
	Write-Host "------------------------------- Executing 'exchange_environment_report' function ----------------------"
	Write-Host ""
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
