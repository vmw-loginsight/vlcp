1. Compatibility:
=================
Microsoft Exchange Server 2013 and 2016.
The widgets in this dashboard would render correct data only if fed input logs from MS Exchange, previous versions of Exchange would show incorrect fields on the widget.

2. Requirement:
===============
This content pack requires the use of Log Insight's Windows agent and the use of the agent's cfapi protocol

3. Installation:
================
Navigate to the "Content Pack" menu in Log Insight. Select the "Import Content Pack" button. In the "Import Content Pack" menu, do the following:
-	Select the "Browse..." button and select the content pack you are trying to import
-	Select the "Install as content pack" radio button
-	Select the "Import" button

Alternately, you can also install the content pack from the marketplace available on Log Insight UI
-	On Log Insight UI, browse to Content Pack ->Marketplace 
-	Click on the content pack and then click ‘Install’

4. Configuration:
===================

4.1.	Enable Administrator Audit Logging :
---------------------------------------------
Enable Administrator Audit Logging by following the instructions here: http://technet.microsoft.com/en-us/library/dd298041(v=exchg.141).aspx 

4.2.	Enable SMTP :
------------------------
In the default installation of Microsoft exchange, SMTP server has logging turned off.
Follow the steps below to enable and configure the same: 

o	Under IIS click on SMTP services  -> Properties.
o	Under General tab: Check “Enable Logging”
o	Click on properties and enable all check boxes  and click ok
o	Also the "Extended Logging Properties" dialog box may be displayed by clicking on the "Advanced" button in the "Active Log Format" field. 
o	You can set the logging interval and specify log path where SMTP logs would be generated.
o	This path needs to be mentioned in liagent.ini file to enable forwarding these logs to LI Instance.

4.3.	Enable SMTP Protocol Logging :
----------------------------------------
SMTP Protocol logging is not enabled by default .To enable SMTP protocol logging using EAC or shell follow the steps mentioned at:
https://technet.microsoft.com/en-us/library/bb124531%28v=exchg.150%29.aspx 

Tip: To enable protocol logging for all send and receive connectors using shell use the following commands: 
Get-ReceiveConnector | Set-ReceiveConnector -ProtocolLoggingLevel verbose
Get-SendConnector | Set-SendConnector -ProtocolLoggingLevel verbose

Note:  Default log location for SMTP protocol logs for Exchange 2013 and 2016:

--------------
Send Connector:
o	Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpSend
o	Mailbox Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpSend
o	Front End Transport service on Client Access servers :%ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpSend

Receive Connector:
o	Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive
o	Mailbox Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpReceive
o	Front End Transport service on Client Access servers :%ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive
--------------

4.4.	Scripts :
------------------
Copy the scripts directory from the root of the archive downloaded from Solution Exchange to a permanent location. 
For example: C:\ProgramData\VMware\Log Insight Agent\exchange\  

Create the following two tasks in Windows Task Scheduler with the following configurations

a.	exchange_wrapper
---------------------
	-	Run as user with sufficient permissions to run Exchange Management Shell
	-	Set to: Run whether user is logged on or not
	-	Set to: Run with highest privileges
	-	Action is set to: Start a program
	-	Program: C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\open_exchange_powershell.cmd
	-	Parameters: exchange_wrapper.ps1
	-	Start in: C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\
	-	Trigger is set to Daily
	-	Repeat task every 5 minutes for the duration of 1 day
		(Note: This duration can be set as per requirement, depending on the size and complexity of the environment)
	-	Set to: Enabled

Note: The paths mentioned in above steps need to be modified as per the environment.


b.	exchange_mailbox_wrapper
------------------------------

	-	Run as user with sufficient permissions to run Exchange Management Shell
	-	Set to: Run whether user is logged on or not
	-	Set to: Run with highest privileges
	-	Action is set to: Start a program
	-	Program: C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\open_exchange_powershell.cmd
	-	Parameters: exchange_mailbox_wrapper.ps1
	-	Start in: C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\
	-	Trigger is set to Daily
	-	Repeat task every 6 hours for the duration of 1 day
	    (Note: This duration can be set as per requirement, depending on the size and complexity of the environment)
	-	Set to: Enabled
	
Note: The paths mentioned in above steps need to be modified as per the environment.


4.5.	 liagent.ini configuration:
--------------------------------------

a. Using Agent Group:
-----------------------
	For the content pack to work apply the agent group configuration "Microsoft - Exchange" available with this content pack under Administration -> Management -> Agents -> All Agents drop down.
	To apply, copy this template to active groups, add filters and save.


b. Editing the liagent.ini:
----------------------------

	You can also apply the above agent group configuration manually by editing the liagent.ini file.
	Note: In all the sections below change the directory path as per the environment.

	; Default windows event  log section 

	[winlog|mse_Application]
        channel=Application
	 
	[winlog|mse_MSExchange_Management]
	; Exchange specific windows channel
	channel=MSExchange Management
	
	[filelog|mse_ExchangeMessageTrack]
	; Exchange Message tracking logs
	; IMPORTANT: Change the directory as per the environment
	directory=C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\MessageTracking\
	tags={"ms_product":"exchange" , "ms_subproduct" : "exchange_msgtrack"}
	
	[filelog|mse_exchange_envStats]
	; Section for environment statistics
	; IMPORTANT: Change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchange_environment_report.csv
	event_marker=^\"Exchange-Health-Report\"
	parser=mse_exchange_envStats_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_envStats_parser]
	base_parser=csv
	delimiter=","
	fields=,,ms_ex_env_servername,ms_ex_env_storagegroup,ms_ex_env_dbname,ms_ex_env_dbtype,ms_ex_env_mailboxcount,ms_ex_env_avgmailboxsize_mb_keyword,ms_ex_env_archivemb,ms_ex_env_avg_archivesize_mb_keyword,ms_ex_env_dbsize_gb_keyword,ms_ex_env_dbwhitespace_gb_keyword,ms_ex_env_percent_dbfreedisk_keyword,ms_ex_env_percent_logfreedisk_keyword,ms_ex_env_bkptype,ms_ex_env_bkptime,ms_ex_env_bkpinprogress,ms_ex_env_lastfullbkp,ms_ex_env_circularlogging,ms_ex_env_copies
	exclude_fields=ms_ex_env_avgmailboxsize_mb_keyword;ms_ex_env_percent_dbfreedisk_keyword;ms_ex_env_avg_archivesize_mb_keyword;ms_ex_env_dbsize_gb_keyword;ms_ex_env_dbwhitespace_gb_keyword;ms_ex_env_percent_logfreedisk_keyword
	field_decoder={"ms_ex_env_percent_dbfreedisk_keyword":"mse_ms_ex_env_percent_dbfreedisk_decoder","ms_ex_env_avgmailboxsize_mb_keyword":"mse_ms_ex_env_avgmailboxsize_mb_decoder","ms_ex_env_avg_archivesize_mb_keyword":"mse_ms_ex_env_avg_archivesize_mb_decoder","ms_ex_env_dbsize_gb_keyword":"mse_ms_ex_env_dbsize_gb_decoder","ms_ex_env_dbwhitespace_gb_keyword":"mse_ms_ex_env_dbwhitespace_gb_decoder","ms_ex_env_percent_logfreedisk_keyword":"mse_ms_ex_env_percent_logfreedisk_decoder"}
	
	[parser|mse_ms_ex_env_avgmailboxsize_mb_decoder]
	base_parser=csv
	delimiter=" "
	fields=ms_ex_env_avgmailboxsize_mb,
	
	[parser|mse_ms_ex_env_percent_dbfreedisk_decoder]
	base_parser=csv
	delimiter=" "
	fields=ms_ex_env_percent_dbfreedisk,
	
	[parser|mse_ms_ex_env_avg_archivesize_mb_decoder]
	base_parser=csv
	delimiter=" "
	fields=ms_ex_env_avg_archivesize_mb,
	
	[parser|mse_ms_ex_env_dbsize_gb_decoder]
	base_parser=csv
	delimiter=" "
	fields=ms_ex_env_dbsize_gb,
	
	[parser|mse_ms_ex_env_dbwhitespace_gb_decoder]
	base_parser=csv
	delimiter=" "
	fields=ms_ex_env_dbwhitespace_gb,
	
	[parser|mse_ms_ex_env_percent_logfreedisk_decoder]
	base_parser=csv
	delimiter=" "
	fields=ms_ex_env_percent_logfreedisk,
	
	[filelog|mse_exchange_mailboxStats]
	; Exchange mailbox stats
	; IMPORTANT: Change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchange_mailbox_stats.csv
	event_marker=^\"ExchangeMailboxStats\"
	parser=mse_exchange_mailboxStats_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_mailboxStats_parser]
	base_parser=csv
	delimiter=","
	fields=,,ms_ex_mb_stats_username,ms_ex_mb_stats_mbsize,ms_ex_mb_stats_server_name
	
	[filelog|mse_exchange_serverInfo]
	; Exchange server info
	; IMPORTANT: change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchangeServerInfo.csv
	event_marker=^\"Get-Mailbox_info\"
	parser=mse_exchange_serverInfo_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_serverInfo_parser]
	base_parser=csv
	delimiter=","
	fields=,ms_ex_server_info_username,ms_ex_server_info_servername,ms_ex_server_info_database,ms_ex_server_info_ismailboxenabled,ms_ex_server_info_samaccountname,ms_ex_server_info_office,ms_ex_server_info_userprincipalname,ms_ex_server_info_originatingserver
	
	[filelog|mse_exchange_emailStats]
	; Exchange email stats
	; IMPORTANT: Change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchange_email_stats_all_servers.csv
	event_marker=^\"ExchangeEmailStats\"
	parser=mse_exchange_emailStats_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_emailStats_parser]
	base_parser=csv
	delimiter=","
	fields=,,,ms_ex_email_stats_user,ms_ex_email_stats_domain,ms_ex_email_stats_server,ms_ex_email_stats_sent_total,ms_ex_email_stats_recv_total,ms_ex_email_stats_sent_size,ms_ex_email_stats_recv_size,ms_ex_email_stats_total_size
	
	[filelog|mse_exchange_DBInfo]
	; Exchange DB info
	; IMPORTANT: Change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchangeServerDBInfo.csv
	parser=mse_exchange_DBInfo_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_DBInfo_parser]
	base_parser=csv
	delimiter=","
	fields=,,ms_ex_db_server_name,ms_ex_db_name,ms_ex_mailbox_count
	
	[filelog|mse_exchange_SMTP]
	; Exchange SMTP
	; IMPORTANT: Change the directory as per the environment
	directory=C:\WINNT\System32\LogFiles
	include=*.log
	parser=mse_exchange_SMTP_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_SMTP_parser]
	base_parser=csv
	delimiter=" "
	fields=,,ms_ex_client_ip,,,ms_ex_host_server_name,ms_ex_server_ip,ms_ex_server_port,ms_ex_method,,ms_ex_email_address_keyword,ms_ex_protocol_status,,ms_ex_sc_bytes,,ms_ex_time_taken,ms_ex_protocol_version,,,,
	exclude_fields=ms_ex_email_address_keyword
	field_decoder={"ms_ex_email_address_keyword":"mse_ms_ex_email_address_decoder"}
	
	[parser|mse_ms_ex_email_address_decoder]
	base_parser=csv
	delimiter=":"
	fields=ms_ex_email_type,ms_ex_email_address
	
	[filelog|mse_exchange_adminAudit]
	; Exchange admin audit
	; IMPORTANT: Change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchange_admin_audit_log.log
	parser=mse_exchange_adminAudit_parser01
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_adminAudit_parser01]
	base_parser=csv
	delimiter=", "
	fields=,,ms_ex_adminaudit_keyword03,,ms_ex_adminaudit_keyword05,ms_ex_adminaudit_keyword06,,,
	exclude_fields=ms_ex_adminaudit_keyword03;ms_ex_adminaudit_keyword05;ms_ex_adminaudit_keyword06
	field_decoder={"ms_ex_adminaudit_keyword03":"mse_ms_ex_adminaudit_decoder03","ms_ex_adminaudit_keyword05":"mse_ms_ex_adminaudit_decoder05","ms_ex_adminaudit_keyword06":"mse_ms_ex_adminaudit_decoder06"}
	next_parser=mse_exchange_adminAudit_parser02
	
	[parser|mse_ms_ex_adminaudit_decoder03]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_eaal_object_modified
	
	[parser|mse_ms_ex_adminaudit_decoder05]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_eaal_cmdlet_parameters
	
	[parser|mse_ms_ex_adminaudit_decoder06]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_eaal_modified_properties
	
	[parser|mse_exchange_adminAudit_parser02]
	base_parser=kvp
	fields=OriginatingServer,Caller,CmdletName,Succeeded,Error,IsValid
	field_rename={"OriginatingServer": "ms_ex_eaal_originating_server","Caller":"ms_ex_eaal_caller","CmdletName":"ms_ex_eaal_cmdlet_name","Succeeded":"ms_ex_eaal_succeeded","Error":"ms_ex_eaal_error","IsValid":"ms_ex_eaal_is_valid"}
	
	[filelog|mse_exchange_serverConfig]
	; Exchange server config
	; IMPORTANT: Change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchange_server_configuration.log
	parser=mse_exchange_serverConfig_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_serverConfig_parser]
	base_parser=kvp
	delimiter=" "
	fields=Fqdn,ExchangeVersion,Edition,Site,IsHubTransportServer,IsClientAccessServer,IsEdgeServer,IsMailboxServer,IsProvisionedServer,IsUnifiedMessagingServer,ServerRole,ServicesRunningForServerRoles,ServicesNotRunningForServerRoles,NumberOfServicesNotRunningForServerRoles,FreeSpaceInMBOnDataPathDrive,FreeSpaceAsPercentage
	field_rename={"Fqdn":"ms_ex_esc_fqdn","ExchangeVersion":"ms_ex_esc_exchange_version","Edition":"ms_ex_esc_edition","Site":"ms_ex_esc_site","IsHubTransportServer":"ms_ex_esc_is_hub_transport_server","IsClientAccessServer":"ms_ex_esc_is_client_access_server","IsEdgeServer":"ms_ex_esc_is_edge_server","IsMailboxServer":"ms_ex_esc_is_mailbox_server","IsProvisionedServer":"ms_ex_esc_is_provisioned_server","IsUnifiedMessagingServer":"ms_ex_esc_is_unified_messaging_server","ServerRole":"ms_ex_esc_server_role","ServicesRunningForServerRoles":"ms_ex_esc_services_running_for_server_roles","ServicesNotRunningForServerRoles":"ms_ex_esc_services_not_running_for_server_roles","NumberOfServicesNotRunningForServerRoles":"ms_ex_esc_number_of_services_not_running_for_server_roles","FreeSpaceInMBOnDataPathDrive":"ms_ex_esc_free_space_in_mb_on_data_path_drive","FreeSpaceAsPercentage":"ms_ex_esc_free_space_as_percentage"}
	
	[filelog|mse_exchange_performCounter]
	; Exchange performance counter
	; IMPORTANT: Change the directory as per the environment
	directory=C:\ProgramData\VMware\Log Insight Agent\exchange\scripts\logs
	include=exchange_perfmon_counters.log
	parser=mse_exchange_performCounter_parser
	tags={"ms_product":"exchange"}
	
	[parser|mse_exchange_performCounter_parser]
	base_parser=csv
	delimiter=" "
	fields=,,,,ms_ex_perf_keyword05,ms_ex_perf_keyword06,ms_ex_perf_keyword07,ms_ex_perf_keyword08,ms_ex_perf_keyword09,ms_ex_perf_keyword10,ms_ex_perf_keyword11
	exclude_fields=ms_ex_perf_keyword05;ms_ex_perf_keyword06;ms_ex_perf_keyword07;ms_ex_perf_keyword08;ms_ex_perf_keyword09;ms_ex_perf_keyword10;ms_ex_perf_keyword11
	field_decoder={"ms_ex_perf_keyword05":"mse_ms_ex_perf_decoder05","ms_ex_perf_keyword06":"mse_ms_ex_perf_decoder06","ms_ex_perf_keyword07":"mse_ms_ex_perf_decoder07","ms_ex_perf_keyword08":"mse_ms_ex_perf_decoder08","ms_ex_perf_keyword09":"mse_ms_ex_perf_decoder09","ms_ex_perf_keyword10":"mse_ms_ex_perf_decoder10","ms_ex_perf_keyword11":"mse_ms_ex_perf_decoder11"}
	
	[parser|mse_ms_ex_perf_decoder05]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_epc_smtp_receive_average_bytes_per_message
	
	[parser|mse_ms_ex_perf_decoder06]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_epc_smtp_receive_messages_received_per_second
	
	[parser|mse_ms_ex_perf_decoder07]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_epc_smtp_send_messages_sent_per_second
	
	[parser|mse_ms_ex_perf_decoder08]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_epc_store_driver_inbound_local_delivery_calls_per_second
	
	[parser|mse_ms_ex_perf_decoder09]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_epc_store_driver_inbound_message_delivery_attempt_per_sec
	
	[parser|mse_ms_ex_perf_decoder10]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_epc_store_driver_inbound_recipients_delivered_per_second
	
	[parser|mse_ms_ex_perf_decoder11]
	base_parser=csv
	delimiter="="
	fields=,ms_ex_epc_store_driver_outbound_submitted_mail_items_per_second
	
	[filelog|mse_msExSmtpSendLog]
	; Section for SMTP Protocol send logs
	; IMPORTANT: Change the directory as per the environment
	;Default location for Send connector protocol log files in Exchange 2013
	;Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpSend
	;Mailbox Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpSend
	;Front End Transport service on Client Access servers :%ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpSend
	directory=C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend
	include=SEND*.log
	parser=mse_msExSmtpSendParser
	tags={"ms_product":"exchange"}
	
	[parser|mse_msExSmtpSendParser]
	base_parser=csv
	delimiter=","
	fields=,ms_ex_smtp_connector_id,ms_ex_smtp_session_id,ms_ex_smtp_sequence_number,msExSmtpSendLocalEndpointKeyword,msExSmtpSendRemoteEndpointKeyword,ms_ex_smtp_event,ms_ex_smtp_data,ms_ex_smtp_context
	exclude_fields=msExSmtpSendLocalEndpointKeyword;msExSmtpSendRemoteEndpointKeyword
	field_decoder={"msExSmtpSendLocalEndpointKeyword": "mse_msExSmtpSendLocalEndpointDecoder","msExSmtpSendRemoteEndpointKeyword": "mse_msExSmtpSendRemoteEndpointDecoder"}
	
	[parser|mse_msExSmtpSendLocalEndpointDecoder]
	base_parser=csv
	delimiter=":"
	fields=ms_ex_smtp_local_ipaddress,ms_ex_smtp_local_tcpport
	
	[parser|mse_msExSmtpSendRemoteEndpointDecoder]
	base_parser=csv
	delimiter=":"
	fields=ms_ex_smtp_remote_ipaddress,ms_ex_smtp_remote_tcpport
	
	[filelog|mse_msExSmtpReceiveLog]
	; Section for SMTP Protocol receive logs
	; IMPORTANT: Change the directory as per the environment
	;Default location for Receive connector protocol log files in Exchange 2013
	;Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive
	;Mailbox Transport service on Mailbox servers :%ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpReceive
	;Front End Transport service on Client Access servers :%ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive
	directory=C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive
	include=RECV*.log
	parser=mse_msExSmtpReceiveParser
	tags={"ms_product":"exchange"}
	
	[parser|mse_msExSmtpReceiveParser]
	base_parser=csv
	delimiter=","
	fields=,ms_ex_smtp_connector_id,ms_ex_smtp_session_id,ms_ex_smtp_sequence_number,msExSmtpReceiveLocalEndpointKeyword,msExSmtpReceiveRemoteEndpointKeyword,ms_ex_smtp_event,ms_ex_smtp_data,ms_ex_smtp_context
	exclude_fields=msExSmtpReceiveLocalEndpointKeyword;msExSmtpReceiveRemoteEndpointKeyword
	field_decoder={"msExSmtpReceiveLocalEndpointKeyword": "mse_msExSmtpReceiveLocalEndpointDecoder","msExSmtpReceiveRemoteEndpointKeyword": "mse_msExSmtpReceiveRemoteEndpointDecoder"}
	
	[parser|mse_msExSmtpReceiveLocalEndpointDecoder]
	base_parser=csv
	delimiter=":"
	fields=ms_ex_smtp_local_ipaddress,ms_ex_smtp_local_tcpport
	
	[parser|mse_msExSmtpReceiveRemoteEndpointDecoder]
	base_parser=csv
	delimiter=":"
	fields=ms_ex_smtp_remote_ipaddress,ms_ex_smtp_remote_tcpport
