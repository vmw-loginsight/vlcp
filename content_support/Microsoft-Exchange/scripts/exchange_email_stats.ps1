
function exchange_email_stats()
{

    $today = get-date 
    $rundate = $($today.adddays(-0.25))
    $outfile = "exchange_email_stats_all_servers.csv" 
 
    $accepted_domains = Get-AcceptedDomain |% {$_.domainname.domain} 
    [regex]$dom_rgx = "`(?i)(?:" + (($accepted_domains |% {"@" + [regex]::escape($_)}) -join "|") + ")$" 
 
    $mbx_servers = Get-ExchangeServer |? {$_.serverrole -match "Mailbox"}|% {$_.fqdn} 
    [regex]$mbx_rgx = "`(?i)(?:" + (($mbx_servers |% {"@" + [regex]::escape($_)}) -join "|") + ")\>$" 
 
    $msgid_rgx = "^\<.+@.+\..+\>$" 
 
    $hts = get-exchangeserver |? {$_.serverrole -match "hubtransport" -or "ClientAccess"} |% {$_.name} 
 
    $exch_addrs = @{}  
    $msgrec = @{} 
    $bytesrec = @{}
    $total_msgsent = @{} 
    $total_bytessent = @{} 
    $server_name = @{}
 
    $obj_table = { 
    @" 
    Type = ExchangeEmailStats
    StartDate = $today
    EndDate = $rundate
    User = $($address.split("@")[0]) 
    Domain = $($address.split("@")[1]) 
    ServerName = $("{0:F2}" -f $server_name[$address])
    Sent Total = $(0 + $total_msgsent[$address]) 
    Received Total = $(0 + $msgrec[$address])
    Sent MB Total = $("{0:F2}" -f $($total_bytessent[$address]/1mb)) 
    Received MB Total = $("{0:F2}" -f $($bytesrec[$address]/1mb)) 
    Total(Send+Receive)MB = $("{0:F2}" -f $(($($total_bytessent[$address]/1mb) + $($bytesrec[$address]/1mb))))
"@ 
    } 
 
    $props = $obj_table.ToString().Split("`n")|% {if ($_ -match "(.+)="){$matches[1].trim()}} 
 
    $stat_recs = @() 

    foreach ($ht in $hts)
    { 
        get-messagetrackinglog -Server $ht -Start "$rundate" -End "$today" -resultsize unlimited   | 
        %{     
		    if ($_.eventid -eq "DELIVER" -and $_.source -eq "STOREDRIVER")
		    { 
			    if ($_.messageid -match $mbx_rgx -and $_.sender -match $dom_rgx) 
			    { 
				    $server_name[$_.sender]  = $ht
				    $total_msgsent[$_.sender] += $_.recipientcount
				    $total_bytessent[$_.sender] += $_.totalbytes 
			 
				    foreach ($rcpt in $_.recipients)
				    {            
					    $exch_addrs[$rcpt] ++     
					    $msgrec[$rcpt] ++ 
					    $bytesrec[$rcpt] += $_.totalbytes 
					    $server_name[$rcpt]  = $ht
				    } 
			    } 
                else 
			    { 
				    if ($_messageid -match $messageid_rgx)
				    { 
					    foreach ($rcpt in $_.recipients)
					    { 
						    $msgrec[$rcpt] ++  
						    $bytesrec[$rcpt] += $_.totalbytes
						    $server_name[$rcpt]  = $ht
					    } 
				    } 
                } 
		    } 
     
            if ($_.eventid -eq "RECEIVE" -and $_.source -eq "STOREDRIVER")
		    { 
			    $exch_addrs[$_.sender] ++ 
			    $server_name[$_.sender]  = $ht
				 
			    if ($_.recipients -notmatch $dom_rgx)
			    { 
				    $ext_count = ($_.recipients -notmatch $dom_rgx).count 
				    $total_msgsent[$_.sender] += $ext_count
				    $total_bytessent[$_.sender] += $_.totalbytes
			    }                                 
		    } 
        }      
    } 

    # Verify the output directory exists.
    $logs_directory = ".\\logs";
    if (!(Test-Path $logs_directory)) 
    {
	    $tempPath = New-Item -ItemType directory -Path $logs_directory;
    }

 
    foreach ($address in $exch_addrs.keys)
    { 
	    $stat_rec = (new-object psobject -property (ConvertFrom-StringData (&$obj_table))) 
	    $stat_recs += $stat_rec | select $props 
    } 

    #deleting the file if it exists already 
    if ( Test-Path $logs_directory\\$outfile ){
	    Remove-Item $logs_directory\\$outfile
    }

    # Export all users sent and receive
    $stat_recs | export-csv $logs_directory\\$outfile -notype  

}

#exchange_email_stats