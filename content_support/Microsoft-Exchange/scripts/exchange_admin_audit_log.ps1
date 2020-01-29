function ex_admin_auditlog()
{
  $file_name            = "last_run_date";
  $date_from_file       = Import-Clixml $file_name -ErrorAction SilentlyContinue;
  $result               = $null;
  $latest_run_date      = $date_from_file;
  $previous_error_count = $Error.Count;

  # Get the appropriate entries.
  if ($date_from_file -eq $null) {
    $result = Search-AdminAuditLog -ErrorAction SilentlyContinue;
  } else {
    $result = Search-AdminAuditLog -StartDate $date_from_file -ErrorAction SilentlyContinue;
  }

  # Handle Search-AdminAuditLog call failure.
  if ($Error.Count -gt $previous_error_count) {
    Write-Host ([string]::Format("An error was encountered while attempting to run 'Search-AdminAuditLog'.  Entries will not be written to the output log that Log Insight is monitoring until the command completes successfully.  Error: <{0}>.", $Error[0]));
    return;
  }

  # Verify the output directory exists.
  $logs_directory = ".\\logs";
  if (!(Test-Path $logs_directory)) {
    $tempPath = New-Item -ItemType directory -Path $logs_directory;
  }
  
   #deleting the file if it exists already 
  if ( Test-Path $logs_directory\exchange_admin_audit_log.log ){
	Remove-Item $logs_directory\exchange_admin_audit_log.log
  }

  foreach ($entry in $result) {
    Write-Verbose "Checking $entry"
    $originating_server = (("" + $entry.OriginatingServer).Split(" "))[0];
    #$entryparameters = [string]::Format("OriginatingServer='{0}' Grep='{1}' Computer Name='{2}'", $entry.OriginatingServer, $originating_server, $env:computername);
    #Out-File -FilePath ([string]::Format("{0}\\exchange_admin_audit_log.log", $logs_directory)) -Append -Force -InputObject $entryparameters -Encoding "UTF8";

    if($originating_server -eq $env:computername) {
        $output_entry = [string]::Format("{0} OriginatingServer='{1}', Caller='{2}', ObjectModified='{3}', CmdletName='{4}', CmdletParameters='{5}', ModifiedProperties='{6}', Succeeded='{7}', Error='{8}', IsValid='{9}'", ($entry.RunDate | Get-Date -format "yyyy MMM %d HH:mm:ss"), (("" + $entry.OriginatingServer).Split(" "))[0], $entry.Caller, $entry.ObjectModified, $entry.CmdletName, [string]::Join(",", $entry.CmdletParameters), [string]::Join(",", $entry.ModifiedProperties), $entry.Succeeded, $entry.Error, $entry.IsValid);
        
        if ($entry.RunDate -ge $latest_run_date) {
            $latest_run_date = $entry.RunDate;
        }

        if ($entry.RunDate -gt $date_from_file) {
            Out-File -FilePath ([string]::Format("{0}\\exchange_admin_audit_log.log", $logs_directory)) -Append -Force -InputObject $output_entry -Encoding "UTF8";
        }
    }
  }

  $latest_run_date | Export-Clixml $file_name;
  $result
}

#ex_admin_auditlog
