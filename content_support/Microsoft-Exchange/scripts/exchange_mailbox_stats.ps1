
function exchange_mailbox_stats()
{

$outfile = "exchange_mailbox_stats.csv"

# Verify the output directory exists.
$logs_directory = ".\\logs";
if (!(Test-Path $logs_directory)) {
    $tempPath = New-Item -ItemType directory -Path $logs_directory;
}

#deleting the file if it exists already 
if ( Test-Path $logs_directory\\$outfile ){
	Remove-Item $logs_directory\\$outfile
}
  
$mailboxs = Get-Mailbox -ResultSize unlimited
$(Foreach ($mailbox in $mailboxs){ 
$mailbox | Get-MailboxStatistics -ResultSize unlimited | 
Add-Member -MemberType ScriptProperty -Name SizeInMB -Value {[int]($this.TotalItemSize.Value.ToMB())} -PassThru |
Select @{Name="Type";Expression={"ExchangeMailboxStats"}},@{Name="Date";Expression={get-date}},DisplayName,SizeInMB,ServerName
}) | Sort -Property {[int]($_.SizeInMB)} -Descending | Export-Csv -NoTypeInformation $logs_directory\\$outfile


}


#exchange_mailbox_stats