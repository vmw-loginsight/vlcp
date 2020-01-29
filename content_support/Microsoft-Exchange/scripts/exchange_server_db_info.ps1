function ex_dbinfo()
{
# Verify the output directory exists.
  $logs_directory = ".\\logs";
  if (!(Test-Path $logs_directory)) {
    $tempPath = New-Item -ItemType directory -Path $logs_directory;
  }
 
	
#getting the exchange server details
	
#deleting the file if it exists already 
if ( Test-Path $logs_directory\exchangeServerInfo.csv ){
	Remove-Item $logs_directory\exchangeServerInfo.csv
}

	Get-Mailbox -ResultSize unlimited | 
	Select @{Name="ExchangeField";Expression={"Get-Mailbox_info"}},Name,ServerName,Database,IsMailboxEnabled,SamAccountName,Office,UserPrincipalName,OriginatingServer | 
	export-csv -noTypeInformation $logs_directory\exchangeServerInfo.csv

#getting the exchange database details

#deleting the file if it exists already 
if ( Test-Path $logs_directory\exchangeServerDBInfo.csv ){
	Remove-Item $logs_directory\exchangeServerDBInfo.csv
}

	Get-MailboxDatabase | 
	Select @{Name="Date";Expression={get-date -format "yyyy-MM-dd HH:mm:ss"}},@{Name="ExchangeField";Expression={"Get-Database_info"}} ,Server,Name,@{Name="Number Of Mailboxes";expression={(Get-Mailbox -Database $_.Identity | Measure-Object).Count}} | 
	export-csv -noTypeInformation $logs_directory\exchangeServerDBInfo.csv

}

#ex_dbinfo