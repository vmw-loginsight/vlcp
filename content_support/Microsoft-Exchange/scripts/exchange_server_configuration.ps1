[string] $exchange_output_string

function append_to_output_string([string] $key, [string] $value)
{
  $global:exchange_output_string = [string]::Format("{0}{1}={2}{3}{2} ", $global:exchange_output_string, $key, '"', $value)
}

function ex_serverconf()
{
  $server                        = $env:ComputerName
  $global:exchange_output_string = [string]::Format("{0} ", (Get-Date -format "yyyy MMM %d HH:mm:ss"))
  $exchange_server               = Get-ExchangeServer -Identity ($server)
  $ex_setup_version_info         = (Get-Command ExSetup).FileVersionInfo 
  $free_space_on_data_path_drive = (gwmi win32_logicaldisk | where {$_.DeviceId -eq ($exchange_server.DataPath.DriveName)}).FreeSpace
  $free_space_as_percentage      = $free_space_on_data_path_drive / ((gwmi win32_logicaldisk | where {$_.DeviceId -eq ($exchange_server.DataPath.DriveName)}).Size) * 100.00
  $DataPathStr=[string]($exchange_server.DataPath)
  $free_space_on_data_path_drive = (gwmi win32_logicaldisk | where {$_.DeviceId -eq ($DataPathStr.Substring(0,2))}).FreeSpace/1MB
  $free_space_as_percentage      = $free_space_on_data_path_drive / ((gwmi win32_logicaldisk | where {$_.DeviceId -eq ($DataPathStr.Substring(0,2))}).Size/1MB) * 100.00
  $role_health                   = Test-ServiceHealth -Server ($server)
  $services_running              = New-Object 'System.Collections.Generic.List[string]'
  $services_not_running          = New-Object 'System.Collections.Generic.List[string]'
  
  #$exchange_server | format-list;
  #$ex_setup_version_info | format-list;
  #$role_health | format-list;

  foreach ($role in $role_health) {
    foreach ($running_service in $role.ServicesRunning) {
      if (!$services_running.Contains($running_service)) {
        $services_running.Add($running_service)
      }
    }
    foreach ($not_running_service in $role.ServicesNotRunning) {
      if (!$services_not_running.Contains($not_running_service)) {
        $services_not_running.Add($not_running_service)
      }
    }
  }

  $services_running_string     = [string]::Join(",", $services_running)
  $services_not_running_string = [string]::Join(",", $services_not_running)

  append_to_output_string "Fqdn"                                     $exchange_server.Fqdn
  append_to_output_string "ExchangeVersion"                          $ex_setup_version_info.ProductVersion
  append_to_output_string "Edition"                                  $exchange_server.Edition
  append_to_output_string "Site"                                     $exchange_server.Site
  append_to_output_string "IsHubTransportServer"                     $exchange_server.IsHubTransportServer
  append_to_output_string "IsClientAccessServer"                     $exchange_server.IsClientAccessServer
  append_to_output_string "IsEdgeServer"                             $exchange_server.IsEdgeServer
  append_to_output_string "IsMailboxServer"                          $exchange_server.IsMailboxServer
  append_to_output_string "IsProvisionedServer"                      $exchange_server.IsProvisionedServer
  append_to_output_string "IsUnifiedMessagingServer"                 $exchange_server.IsUnifiedMessagingServer
  append_to_output_string "ServerRole"                               ("" + $exchange_server.ServerRole).Replace(", ", ",")
  append_to_output_string "ServicesRunningForServerRoles"            $services_running_string
  append_to_output_string "ServicesNotRunningForServerRoles"         $services_not_running_string
  append_to_output_string "NumberOfServicesNotRunningForServerRoles" $services_not_running.Count
  append_to_output_string "DataPath"                                 $exchange_server.DataPath
  append_to_output_string "FreeSpaceInMBOnDataPathDrive"             ("{0:N2}" -f $free_space_on_data_path_drive).Replace(",","")
  append_to_output_string "FreeSpaceAsPercentage"                    ("{0:N2}" -f $free_space_as_percentage)

  $global:exchange_output_string = ($global:exchange_output_string).Trim()
  $global:exchange_output_string;

  $logs_directory = ".\\logs";
  if (!(Test-Path $logs_directory)) {
    $tempPath = New-Item -ItemType directory -Path $logs_directory
  }
  
  if ( Test-Path $logs_directory\exchange_server_configuration.log ){
	Remove-Item $logs_directory\exchange_server_configuration.log
  }
  Out-File -FilePath ([string]::Format("{0}\\exchange_server_configuration.log", $logs_directory)) -Append -Force -InputObject $global:exchange_output_string -Encoding "UTF8";
}

#ex_serverconf