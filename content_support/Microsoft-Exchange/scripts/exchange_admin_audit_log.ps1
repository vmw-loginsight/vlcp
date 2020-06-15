
function ex_admin_auditlog()
{
  $file_name            = "last_run_date";
  $date_from_file       = $null;
  $result               = $null;
  $latest_run_date      = $null;
  $previous_error_count = $Error.Count;
  $logs_directory = ".\\logs";
  
  # Check last_run_date file exitansy
  if (Test-Path $file_name) {
    Write-Host ("Pick up script last execution date from last_run_date file.");
	$date_from_file       = Get-Content $file_name -ErrorAction SilentlyContinue;
	# Conver to date format
	$date_from_file       = (Get-Date $date_from_file)
  }
  
  # Store current date before getting logs
  $last_run_date = Get-Date
  
  # Get the appropriate entries.
  if ($date_from_file -eq $null) {
    $result = Search-AdminAuditLog -ErrorAction SilentlyContinue;
  } else {
    $result = Search-AdminAuditLog -StartDate "$date_from_file" -ErrorAction SilentlyContinue;
  }

  # Handle Search-AdminAuditLog call failure.
  if ($Error.Count -gt $previous_error_count) {
    Write-Host ([string]::Format("An error was encountered while attempting to run 'Search-AdminAuditLog'.  Entries will not be written to the output log that Log Insight is monitoring until the command completes successfully.  Error: <{0}>.", $Error[0]));
    return;
  }

  # Create logs output directory if not exists.
  if (!(Test-Path $logs_directory)) {
    $tempPath = New-Item -ItemType directory -Path $logs_directory;
  }
  
  # Deleting the file if it exists already and new logs are collected
  if ((Test-Path $logs_directory\exchange_admin_audit_log.log) -and ($result.length -gt 0)) {
	Remove-Item $logs_directory\exchange_admin_audit_log.log
  }

  # Check if there are new logs.
  if ($result.length -eq 0) {
	Write-Host "There are no any new logs to get"
  } else {  
    # Formating result and write to the exchange_admin_audit_log.log file
    foreach ($entry in $result) {
      Write-Verbose "Checking $entry"
      $originating_server = (("" + $entry.OriginatingServer).Split(" "))[0];
      #$entryparameters = [string]::Format("OriginatingServer='{0}' Grep='{1}' Computer Name='{2}'", $entry.OriginatingServer, $originating_server, $env:computername);
      #Out-File -FilePath ([string]::Format("{0}\\exchange_admin_audit_log.log", $logs_directory)) -Append -Force -InputObject $entryparameters -Encoding "UTF8";
   
      if($originating_server -eq $env:computername) {
          $output_entry = [string]::Format("{0} OriginatingServer='{1}', Caller='{2}', ObjectModified='{3}', CmdletName='{4}', CmdletParameters='{5}', ModifiedProperties='{6}', Succeeded='{7}', Error='{8}', IsValid='{9}'", ($entry.RunDate | Get-Date -format "yyyy MMM %d HH:mm:ss"), (("" + $entry.OriginatingServer).Split(" "))[0], $entry.Caller, $entry.ObjectModified, $entry.CmdletName, [string]::Join(",", $entry.CmdletParameters), [string]::Join(",", $entry.ModifiedProperties), $entry.Succeeded, $entry.Error, $entry.IsValid);
          
          Out-File -FilePath ([string]::Format("{0}\\exchange_admin_audit_log.log", $logs_directory)) -Append -Force -InputObject $output_entry -Encoding "UTF8";
      }
    }
  }
  # Updating latest_run_date file with lates exeuction date  
  Out-File $file_name -InputObject $last_run_date.ToString();
  
  #Print result in output
  $result
}

#ex_admin_auditlog
