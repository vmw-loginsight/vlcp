function exchange_environment_report()
{
# Sub-Function to Get Database Information. 
function _GetDAG 
{ 
    param($DAG) 
    @{Name            = $DAG.Name.ToUpper() 
      MemberCount    = $DAG.Servers.Count 
      Members        = [array]($DAG.Servers | % { $_.Name }) 
      Databases        = @() 
      } 
} 
 
# Sub-Function to Get Database Information 
function _GetDB 
{ 
    param($Database,$ExchangeEnvironment,$Mailboxes,$ArchiveMailboxes) 
	  
    # Circular Logging, Last Full Backup 
    if ($Database.CircularLoggingEnabled) 
	{ 
		$CircularLoggingEnabled="Yes" 
	} else { 
		$CircularLoggingEnabled = "No"
	} 
    $LastFullBackup = $Database.LastFullBackup
	$LastIncrementalBackup = $Database.LastIncrementalBackup
	
	# Backup in progress
	$backupinprogress = $Database.backupinprogress
	
	#Determines the database type (Mailbox or Public Folder)
	if ($Database.IsMailboxDatabase -eq $True) 
	{
		$IsMailboxDatabase = "Mailbox"
	}
	if ($Database.IsPublicFolderDatabase -eq $True) 
	{
		$IsPublicFolderDatabase = "Public Folder"
	}
	
     
    # Mailbox Average Sizes 
    $MailboxStatistics = [array]($ExchangeEnvironment.Servers[$Database.Server.Name].MailboxStatistics | Where {$_.Database -eq $Database.Identity}) 
    if ($MailboxStatistics) 
    { 
        [long]$MailboxItemSizeB = 0 
        $MailboxStatistics | %{ $MailboxItemSizeB+=$_.TotalItemSizeB } 
        [long]$MailboxAverageSize = $MailboxItemSizeB / $MailboxStatistics.Count 
    } else { 
        $MailboxAverageSize = 0 
    } 
     
    # Free Disk Space Percentage 
    if ($ExchangeEnvironment.Servers[$Database.Server.Name].Disks) 
    { 
        foreach ($Disk in $ExchangeEnvironment.Servers[$Database.Server.Name].Disks) 
        { 
            if ($Database.EdbFilePath.PathName -like "$($Disk.Name)*") 
            { 
                $FreeDatabaseDiskSpace = $Disk.FreeSpace / $Disk.Capacity * 100 				
            } 
            if ($Database.ExchangeVersion.ExchangeBuild.Major -ge 14) 
            { 
                if ($Database.LogFolderPath.PathName -like "$($Disk.Name)*") 
                { 
                    $FreeLogDiskSpace = $Disk.FreeSpace / $Disk.Capacity * 100 
                } 
            } else { 
                $StorageGroupDN = $Database.DistinguishedName.Replace("CN=$($Database.Name),","") 
                $Adsi=[adsi]"LDAP://$($Database.OriginatingServer)/$($StorageGroupDN)" 
                if ($Adsi.msExchESEParamLogFilePath -like "$($Disk.Name)*") 
                { 
                    $FreeLogDiskSpace = $Disk.FreeSpace / $Disk.Capacity * 100 
                } 
            } 
        } 
    } else { 
        $FreeLogDiskSpace=$null 
        $FreeDatabaseDiskSpace=$null 
    } 
     

	# TODO: Need to validate as above comments realted Exchange 2010 is valid as code is functional for Exchange 2016 (v15)
    # Exchange 2010 Database Only 
    $CopyCount = [int]$Database.Servers.Count 
    if ($Database.MasterServerOrAvailabilityGroup.Name -ne $Database.Server.Name) 
    { 
        $Copies = [array]($Database.Servers | % { $_.Name }) 
    } else { 
        $Copies = @() 
    } 
    # Archive Info 
    $ArchiveMailboxCount = [int]([array]($ArchiveMailboxes | Where {$_.ArchiveDatabase -eq $Database.Name})).Count 
    $ArchiveStatistics = [array]($ArchiveMailboxes | Where {$_.ArchiveDatabase -eq $Database.Name} | Get-MailboxStatistics -Archive ) 
    if ($ArchiveStatistics) 
    { 
        [long]$ArchiveItemSizeB = 0 
        $ArchiveStatistics | %{ $ArchiveItemSizeB+=$_.TotalItemSize.Value.ToBytes() } 
        [long]$ArchiveAverageSize = $ArchiveItemSizeB / $ArchiveStatistics.Count 
    } else { 
        $ArchiveAverageSize = 0 
    } 
    # DB Size / Whitespace Info 
    [long]$Size = $Database.DatabaseSize.ToBytes() 
    [long]$Whitespace = $Database.AvailableNewMailboxSpace.ToBytes() 
    $StorageGroup = $null 

     
    @{Name                        = $Database.Name 
      StorageGroup                = $StorageGroup                            #  looks like have never value as explicit "$null" is assigned
      ActiveOwner                 = $Database.Server.Name.ToUpper() 
      MailboxCount                = [long]([array]($Mailboxes | Where {$_.Database -eq $Database.Identity})).Count 
      MailboxAverageSize          = $MailboxAverageSize 
      ArchiveMailboxCount         = $ArchiveMailboxCount                     # have value 0 while testing localy. Look like archiving not enabled localy
      ArchiveAverageSize          = $ArchiveAverageSize                      # have value 0 while testing localy. Look like archiving not enabled localy
      CircularLoggingEnabled      = $CircularLoggingEnabled 
	  LastFullBackup			  = $LastFullBackup                          # no value while testing localy. Look like backup not enabled localy
	  LastIncrementalBackup       = $LastIncrementalBackup	                 # no value while testing localy. Look like backup not enabled localy
      Size                        = $Size                                    
      Whitespace                  = $Whitespace                               
      Copies                      = $Copies                                  
      CopyCount                   = $CopyCount                               
      FreeLogDiskSpace            = $FreeLogDiskSpace 
      FreeDatabaseDiskSpace       = $FreeDatabaseDiskSpace 
	  IsMailboxDatabase			  = $IsMailboxDatabase
	  IsPublicFolderDatabase      = $IsPublicFolderDatabase                  # no value while testing localy
	  backupinprogress			  = $backupinprogress
	  
      } 
} 
 
 
# Sub-Function to get mailbox count per server. 
function _GetExSvrMailboxCount 
{ 
    param($Mailboxes,$ExchangeServer,$Databases) 
    $MailboxCount = 0 
    foreach ($Database in [array]($Databases | Where {$_.Server -eq $ExchangeServer.Name})) 
    { 
        $MailboxCount+=([array]($Mailboxes | Where {$_.Database -eq $Database.Identity})).Count 
    } 
    $MailboxCount 
     
} 
 
# Sub-Function to Get Exchange Server information 
function _GetExSvr 
{ 
    param($ExchangeServer,$Mailboxes,$Databases) 
     
    # Set Basic Variables 
    $MailboxCount = 0 
    $RollupLevel = 0 
    $RollupVersion = "" 
    $ExtNames = @() 
    $IntNames = @() 
    $CASArrayName = "" 
     
    # Get WMI Information 
    $tWMI = Get-WmiObject Win32_OperatingSystem -ComputerName $ExchangeServer.Name -ErrorAction SilentlyContinue 
    if ($tWMI) 
    { 
        $OSVersion = $tWMI.Caption.Replace("(R)","").Replace("Microsoft ","").Replace("Enterprise","Ent").Replace("Standard","Std").Replace(" Edition","") 
		#valuse is emtpy need to handle pisble need to add N/A
        $OSServicePack = $tWMI.CSDVersion 
        $RealName = $tWMI.CSName.ToUpper() 
    } else { 
        $OSVersion = "N/A" 
        $OSServicePack = "N/A" 
        $RealName = $ExchangeServer.Name.ToUpper() 
    } 
    $tWMI=Get-WmiObject -query "Select * from Win32_Volume" -ComputerName $ExchangeServer.Name -ErrorAction SilentlyContinue 
    if ($tWMI) 
    { 
        $Disks=$tWMI | Select Name,Capacity,FreeSpace | Sort-Object -Property Name 
    } else { 
        $Disks=$null 
    } 
     
    # Get Exchange Version 
	# TODO: better to remove condigion as <6 does not supported
    if ($ExchangeServer.AdminDisplayVersion.Major -eq 6) 
    { 
        $ExchangeMajorVersion = "$($ExchangeServer.AdminDisplayVersion.Major).$($ExchangeServer.AdminDisplayVersion.Minor)" 
        $ExchangeSPLevel = $ExchangeServer.AdminDisplayVersion.FilePatchLevelDescription.Replace("Service Pack ","") 
    } else { 
        $ExchangeMajorVersion = $ExchangeServer.AdminDisplayVersion.Major 
        $ExchangeSPLevel = $ExchangeServer.AdminDisplayVersion.Minor 
    } 
    # Exchange 2007+ 
    if ($ExchangeMajorVersion -ge 8) 
    { 
        # Get Roles 
        $MailboxStatistics=$null 
        [array]$Roles = $ExchangeServer.ServerRole.ToString().Replace(" ","").Split(","); 
        if ($Roles -contains "Mailbox") 
        { 
            $MailboxCount = _GetExSvrMailboxCount -Mailboxes $Mailboxes -ExchangeServer $ExchangeServer -Databases $Databases 
            if ($ExchangeServer.Name.ToUpper() -ne $RealName) 
            { 
                $Roles = [array]($Roles | Where {$_ -ne "Mailbox"}) 
                $Roles += "ClusteredMailbox" 
            } 
            # Get Mailbox Statistics the normal way, return in a consitent format 
            $MailboxStatistics = Get-MailboxStatistics -Server $ExchangeServer | Select DisplayName,@{Name="TotalItemSizeB";Expression={$_.TotalItemSize.Value.ToBytes()}},@{Name="TotalDeletedItemSizeB";Expression={$_.TotalDeletedItemSize.Value.ToBytes()}},Database 
        } 
        # Get HTTPS Names (Exchange 2010 only due to time taken to retrieve data)
		# TODO: Need to be review and remove
		# if ($Roles -contains "ClientAccess") # -and $E2010) 
        # { 
        #     Get-OWAVirtualDirectory -Server $ExchangeServer -ADPropertiesOnly | %{ $ExtNames+=$_.ExternalURL.Host; $IntNames+=$_.InternalURL.Host; } 
        #     Get-WebServicesVirtualDirectory -Server $ExchangeServer -ADPropertiesOnly | %{ $ExtNames+=$_.ExternalURL.Host; $IntNames+=$_.InternalURL.Host; } 
        #     Get-OABVirtualDirectory -Server $ExchangeServer -ADPropertiesOnly | %{ $ExtNames+=$_.ExternalURL.Host; $IntNames+=$_.InternalURL.Host; } 
        #     Get-ActiveSyncVirtualDirectory -Server $ExchangeServer -ADPropertiesOnly | %{ $ExtNames+=$_.ExternalURL.Host; $IntNames+=$_.InternalURL.Host; } 
        #     $IntNames+=(Get-ClientAccessServer -Identity $ExchangeServer.Name).AutoDiscoverInternalURI.Host 
        #     if ($ExchangeMajorVersion -ge 14) 
        #     { 
        #         Get-ECPVirtualDirectory -Server $ExchangeServer -ADPropertiesOnly | %{ $ExtNames+=$_.ExternalURL.Host; $IntNames+=$_.InternalURL.Host; } 
        #     } 
        #     $IntNames = $IntNames|Sort-Object -Unique 
        #     $ExtNames = $ExtNames|Sort-Object -Unique 
        #     $CASArray = Get-ClientAccessArray -Site $ExchangeServer.Site.Name 
        #     if ($CASArray) 
        #     { 
        #         $CASArrayName = $CASArray.Fqdn 
        #     } 
        # } 
 
        # Rollup Level / Versions 
		# -----------------------------------
		# TODO: Need to be review and remove
        if ($ExchangeMajorVersion -ge 14) 
        { 
            $RegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer\\UserData\\S-1-5-18\\Products\\AE1D439464EB1B8488741FFA028E291C\\Patches" 
        } else { 
            $RegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer\\UserData\\S-1-5-18\\Products\\461C2B4266EDEF444B864AD6D9E5B613\\Patches" 
        } 
        $RemoteRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ExchangeServer.Name); 
        if ($RemoteRegistry) 
        {
            try
            {
                $RUKeys = $RemoteRegistry.OpenSubKey($RegKey).GetSubKeyNames() | ForEach {"$RegKey\\$_"} 
            } catch {}
            if ($RUKeys) 
            { 
                [array]($RUKeys | %{$RemoteRegistry.OpenSubKey($_).getvalue("DisplayName")}) | %{ 
                    if ($_ -like "Update Rollup *") 
                    { 
                        $tRU = $_.Split(" ")[2] 
                        if ($tRU -like "*-*") { $tRUV=$tRU.Split("-")[1]; $tRU=$tRU.Split("-")[0] } else { $tRUV="" } 
                        if ($tRU -ge $RollupLevel) { $RollupLevel=$tRU; $RollupVersion=$tRUV } 
                    } 
                } 
            } 
        } 
		# Exchange 2013 CU or SP Level 
        if ($ExchangeMajorVersion -ge 15) 
        { 
            $RegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Microsoft Exchange v15" 
            $RemoteRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ExchangeServer.Name); 
            if ($RemoteRegistry) 
            { 
                $ExchangeSPLevel = $RemoteRegistry.OpenSubKey($RegKey).getvalue("DisplayName") 
                if ($ExchangeSPLevel -like "*Service Pack*" -or $ExchangeSPLevel -like "*Cumulative Update*") 
                { 
                    $ExchangeSPLevel = $ExchangeSPLevel.Replace("Microsoft Exchange Server 2013 ",""); 
                    $ExchangeSPLevel = $ExchangeSPLevel.Replace("Service Pack ","SP"); 
                    $ExchangeSPLevel = $ExchangeSPLevel.Replace("Cumulative Update ","CU");  
                } else { 
                    $ExchangeSPLevel = 0; 
                } 
            } 
			
        } 
         
    } 
  
    # Return Hashtable 
    @{Name                    = $ExchangeServer.Name.ToUpper() 
     RealName                = $RealName 
     ExchangeMajorVersion     = $ExchangeMajorVersion 
     ExchangeSPLevel        = $ExchangeSPLevel 
     Edition                = $ExchangeServer.Edition 
     Mailboxes                = $MailboxCount 
     OSVersion                = $OSVersion; 
     OSServicePack            = $OSServicePack 
     Roles                    = $Roles 
     RollupLevel            = $RollupLevel 
     RollupVersion            = $RollupVersion 
     Site                    = $ExchangeServer.Site.Name 
     MailboxStatistics        = $MailboxStatistics 
     Disks                    = $Disks 
     IntNames                = $IntNames 
     ExtNames                = $ExtNames 
     CASArrayName            = $CASArrayName 
    }     
} 
 

# Sub Function to populate data for Databases
function _GetDBTable 
{ 
    param($Databases)
	
    $Output= "`"Type`",`"Sub-Type`",`"Server`",`"Storage Group`",`"Database Name`",`"Database Type`",`"Mailboxes`",`"Av. Mailbox Size`",`"Archive MBs`",`"Av. Archive Size`",`"DB Size`",`"DB Whitespace`",`"Database Disk Free`",`"Log Disk Free`",`"Backup Type`",`"Backup Time`",`"Backup In Progress`",`"Last Full Backup`",`"Circular Logging`",`"Copies (n)`"`r`n"
	
	$lastbackup = @{}
	$dbtype = @{}	

    foreach ($Database in $Databases) 
    { 	
				
		
		if ( $Database.LastFullBackup -eq $null -and $Database.LastIncrementalBackup -eq $null)
		
		{
			#No backup timestamp was present. This means either the database has
			#never been backed up, or it was unreachable when this script ran
			$lastbackup.time = "Never/Unknown"
			$lastbackup.type = "Never/Unknown"
			$lastbackup.fulltime = "Not Available"
			$lastbackup.status = "Fail"
		}		
		elseif ( $Database.LastFullBackup -lt $Database.LastIncrementalBackup )
		{
			$lastbackup.time = $Database.LastIncrementalBackup
			$lastbackup.type = "Incremental"			
				
			#check last full backup
			if ($Database.LastFullBackup -eq $null)
			{
				$lastbackup.fulltime = "Not Available"
			}
			else
			{
				$lastbackup.fulltime = $Database.LastFullBackup
			}
		}
		elseif ( $Database.LastIncrementalBackup -lt $Database.LastFullBackup )
		{
			$lastbackup.time = $Database.LastFullBackup
			$lastbackup.type = "Full"
			$lastbackup.fulltime = $Database.LastFullBackup
			$lastbackup.status = "Pass"
			
		} 
				
		#DB type 		
		if ( $Database.IsMailboxDatabase -eq "Mailbox" )
		{
			$dbtype = $Database.IsMailboxDatabase
		
		}
		else
		{
			$dbtype = $Database.IsPublicFolderDatabase
		}
		
	
		#Determine Yes/No status for backup in progress
		if ($($Database.backupinprogress) -eq $true) {$inprogress = "Yes"}
		if ($($Database.backupinprogress) -eq $false) {$inprogress = "No"}
		
		
		$Output+="`"Exchange-Health-Report`","
		$Output+="`"MailboxDB-NonDAG`","              
        $Output+="`"$($Database.ActiveOwner)`","	
        $Output+="`"$($Database.StorageGroup)`","        
        $Output+="`"$($Database.Name)`","  
		$Output+="`"$($dbtype)`","  
		$Output+="`"$($Database.MailboxCount)`","	
		$Output+="`"$("{0:N2}" -f ($Database.MailboxAverageSize/1MB)) MB`","	
        $Output+="`"$($Database.ArchiveMailboxCount)`","	
        $Output+="`"$("{0:N2}" -f ($Database.ArchiveAverageSize/1MB)) MB`","	  
        $Output+="`"$("{0:N2}" -f ($Database.Size/1GB)) GB`","	
        $Output+="`"$("{0:N2}" -f ($Database.Whitespace/1GB)) GB`","	
        $Output+="`"$("{0:N1}" -f $Database.FreeDatabaseDiskSpace) %`","	  	
        $Output+="`"$("{0:N1}" -f $Database.FreeLogDiskSpace) %`","	
		$Output+="`"$($lastbackup.type)`"," 
		$Output+="`"$($lastbackup.time)`","
		$Output+="`"$($inprogress)`","
	    $Output+="`"$($lastbackup.fulltime)`","	
        $Output+="`"$($Database.CircularLoggingEnabled)`","	
        $Output+="`"$($Database.Copies|%{$_}) ($($Database.CopyCount))`""	       
        $Output+="`r`n"	
		
    } 
      
    $Output 
} 

############################################## MAIN ##############################################
 
 
# Check Exchange Management Shell Version 
Write-Host "----------------- Check Exchange Management Shell Version"
if (Get-ExchangeServer | Where {$_.AdminDisplayVersion.Major -ne 15}) 
{ 
    Write-Error "The script is functional only for the Exchange 2013/2016. Version differnt then 15.X is detected." 
} 

# Hashtable to update with environment data 
$ExchangeEnvironment = @{Sites                  = @{} 
                         Servers                = @{} 
                         DAGs                   = @() 
                         NonDAGDatabases        = @() 
                        } 

# Get Mailboxes
$Mailboxes = [array](Get-Mailbox -ResultSize Unlimited) 
$ArchiveMailboxes = [array](Get-Mailbox -Archive -ResultSize Unlimited) #better to move where use it
$RemoteMailboxes = [array](Get-RemoteMailbox  -ResultSize Unlimited) 
$ExchangeEnvironment.Add("RemoteMailboxes",$RemoteMailboxes.Count) 

# Get Database
Write-Host "----------------- Get Database"
$Databases = [array](Get-MailboxDatabase -IncludePreExchange2013 -Status) 
$DAGs = [array](Get-DatabaseAvailabilityGroup) 

# Get Total number of Mailboxes
Write-Host "----------------- Get Total number of Mailboxes"
$ExchangeEnvironment.Add("TotalMailboxes",$Mailboxes.Count + $ExchangeEnvironment.RemoteMailboxes); 


# Get Server, Exchange and Mailbox Information
Write-Host "----------------- Get Exchange and Mailbox Information."
$ExchangeServers = [array](Get-ExchangeServer)
# Collect Exchange Server Information 
for ($i=0; $i -lt $ExchangeServers.Count; $i++) 
{ 
    # Get Exchange Info 
    $ExSvr = _GetExSvr -ExchangeServer $ExchangeServers[$i] -Mailboxes $Mailboxes -Databases $Databases 
    # Add to site or pre-Exchange 2007 list 
    if ($ExSvr.Site) 
    { 
        # Exchange 2007 or higher 
        if (!$ExchangeEnvironment.Sites[$ExSvr.Site]) 
        { 
            $ExchangeEnvironment.Sites.Add($ExSvr.Site,@($ExSvr)) 
        } else { 
            $ExchangeEnvironment.Sites[$ExSvr.Site]+=$ExSvr 
        } 
    }  
    # Add to Servers List 
    $ExchangeEnvironment.Servers.Add($ExSvr.Name,$ExSvr) 
} 
echo "++++++++++++ DEBUG ++++++++++++ ExchangeEnvironment variable value"
echo $ExchangeEnvironment


# Populate Environment DAGs 
Write-Host "----------------- Populate Environment DAGs"
if ($DAGs) 
{ 
    foreach($DAG in $DAGs) 
    { 
		# Uncomment if would like to debug whole $DAGs vaiable
        #echo "++++++++++++ DEBUG ++++++++++++ $DAG variable value"
		#echo $DAG
		$ExchangeEnvironment.DAGs+=(_GetDAG -DAG $DAG) 
    } 
} 
echo "++++++++++++ DEBUG ++++++++++++ ExchangeEnvironment.DAGs variable value"
echo $ExchangeEnvironment.DAGs
echo "++++++++++++ DEBUG ++++++++++++ ExchangeEnvironment variable value"
echo $ExchangeEnvironment


# Get Database information 
Write-Host "----------------- Get Database information"
for ($i=0; $i -lt $Databases.Count; $i++) 
{ 
    $Database = _GetDB -Database $Databases[$i] -ExchangeEnvironment $ExchangeEnvironment -Mailboxes $Mailboxes -ArchiveMailboxes $ArchiveMailboxes
	# Uncomment if would like to debug whole $Database vaiable
    echo "++++++++++++ DEBUG ++++++++++++ $Database variable value"
	echo $Database
	
	$DAGDB = $false 
    for ($j=0; $j -lt $ExchangeEnvironment.DAGs.Count; $j++) 
    { 
        if ($ExchangeEnvironment.DAGs[$j].Members -contains $Database.ActiveOwner) 
        { 
            $DAGDB=$true
            $ExchangeEnvironment.DAGs[$j].Databases += $Database 
			Write-Host "----------------- Appended as DAGDatabases to $ExchangeEnvironment.DAGs"
        } 
    } 
    if (!$DAGDB) 
    { 
        $ExchangeEnvironment.NonDAGDatabases += $Database
		Write-Host "----------------- Appending as NonDAGDatabases to $ExchangeEnvironment.NonDAGDatabases"		
    }   
} 

# Verify the output directory existstancy.
Write-Host "----------------- Verify the output directory existstancy."
$logs_directory = ".\\logs";
if (!(Test-Path $logs_directory)) {
	Write-Host "----------------- Creating '.\logs' directory."
	$tempPath = New-Item -ItemType directory -Path $logs_directory;
}

# Deleting old generated file if it already exists.
Write-Host "----------------- Deleting old generated file if it already exists."
if ( Test-Path $logs_directory\exchange_environment_report.csv ){
	Remove-Item $logs_directory\exchange_environment_report.csv
}

# Calculating Databases tables.
Write-Host "----------------- Calculating Databases tables."
echo "++++++++++++ DEBUG ++++++++++++ NonDAGDatabases count for ExchangeEnvironment.NonDAGDatabases.Count"
echo $ExchangeEnvironment.NonDAGDatabases.Count 
echo "++++++++++++ DEBUG ++++++++++++ DAGs count for $ExchangeEnvironment.DAGs.Databases.Count"
echo $ExchangeEnvironment.DAGs.Databases.Count

# Create temporay list including all databases
$total_DBs = $ExchangeEnvironment.DAGs.Databases + $ExchangeEnvironment.NonDAGDatabases

$Output=_GetDBTable -Databases $total_DBs
echo "++++++++++++ DEBUG ++++++++++++ Final result that are going to output file."
echo $Output
$Output | ConvertFrom-Csv | Export-Csv -NoTypeInformation $logs_directory\exchange_environment_report.csv


} # main function end

#exchange_environment_report
