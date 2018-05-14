Setup and configuration
1.Compatibility
=================
Microsoft SharePoint Server version 2010 Service Pack 2
Microsoft SharePoint Server version 2013

Note: For SharePoint 2013 there would be no data seen for the dashboard “Site Inventory Usage“ as the default view SiteInventory is not present. in the database.

2. Installation
===============
Navigate to the "Content Pack" menu in Log Insight. Select the "Import Content Pack" button. In the "Import Content Pack" menu, do the following:
-	Select the "Browse..." button and select the content pack you are trying to import
-	Select the "Install as content pack" radio button
-	Select the "Import" button

Alternately, you can also install the content pack from the marketplace available on Log Insight UI
-On Log Insight UI, browse to Content Pack ->Marketplace 
-Click on the content pack and then click ‘Install’

3. Configuration
===================
3.1 Scripts : For SharePoint Usage data  
---------------------------------------------

Prerequisites:  Enable health and usage data collection:
To enable it follow the instructions at: https://technet.microsoft.com/en-in/library/ee663480.aspx

Copy the scripts directory from the root of the archive downloaded from Solution Exchange to a permanent location. For example: C:\ProgramData\VMware\Log Insight Agent\sharepoint and then follow the steps below to create a task in Windows Task Scheduler.

a)	For SharePoint 2010
ms_sharePoint_usageData_logging.ps1
•	Run as user with sufficient permissions
•	Edit the SPServerName.txt file in the script folder to input the SharePoint database server name in this file.
•	Browse to Control Panel --> All Control Panel Items --> Administrative Tools --> Task Scheduler and click on create task.
•	Set to: Run whether user is logged on or not
•	Set to: Run with highest privileges
•	Action is set to: Start a program
•	Program: “C:\ProgramData\VMware\Log Insight Agent\sharepoint\scripts\open_powershell.cmd”
•	Parameters: ms_sharePoint_usageData_logging.ps1
•	Start in: C:\ProgramData\VMware\Log Insight Agent\sharepoint\scripts\
•	Trigger is set to Daily
•	Repeat task every 5 minutes for the duration of 1 day
•	Set to: Enabled

Note: The duration can be set as per the actual environment.

b)	For SharePoint 2013
ms_sharePoint_usageData_logging_2013.ps1
•	Run as user with sufficient permissions
•	Edit the SPServerName.txt file in the script folder to input the SharePoint database server name in this file.
•	Browse to Control Panel --> All Control Panel Items --> Administrative Tools --> Task Scheduler and click on create task.
•	Set to: Run whether user is logged on or not
•	Set to: Run with highest privileges
•	Action is set to: Start a program
•	Program: “C:\ProgramData\VMware\Log Insight Agent\sharepoint\scripts\open_powershell.cmd”
•	Parameters: ms_sharePoint_usageData_logging_2013.ps1
•	Start in: C:\ProgramData\VMware\Log Insight Agent\sharepoint\scripts\
•	Trigger is set to Daily
•	Repeat task every 5 minutes for the duration of 1 day
•	Set to: Enabled

Note:
- For SharePoint 2013 default view 'SiteInventory' is not present, therefore there would be no data seen for the dashboard "Site Inventory Usage" 
- The duration can be set as per the actual environment.


3.2 liagent.ini configuration:
--------------------------------
3.2.1	Using Agent Group:
---------------------------
The  "Microsoft - SharePoint"  content pack requires the use of the Log Insight agent with the cfapi protocol (default) and the included agent group configuration. To apply the agent group configuration:

* Go to the  Administration -> Management -> Agents page (requires Super Admin privileges)
* Select the  All Agents  drop-down at the top of the window and select the  “Copy Template”  button to the right of the "Microsoft - SharePoint" agent group
* Add the desired filters to restrict which agent receive the configuration (optional)
* Select the "Refresh" button at the top of the page
* Select the "Save Configuration" button at the bottom of the page