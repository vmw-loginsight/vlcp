1. Compatibility:
------------------
Microsoft©  SQL server®  version 2008, 2012, 2014 and 2016

2. Installation
----------------
Navigate to the "Content Pack" menu in Log Insight.  Select the "Import Content Pack" button.  In the "Import Content Pack" menu, do the following:
-	Select the "Browse..." button and select the content pack you are trying to import
-	Select the "Install as content pack" radio button
-	Select the "Import" button

Alternately, you can also install the content pack from the marketplace available on Log Insight UI
-   On Log Insight UI, browse to Content Pack -> Marketplace 
-   Click on the content pack and then click "Install"


3. Configuration: 
------------------

The "Microsoft - SQL Server" content pack requires the use of the Log Insight agent with the cfapi protocol (default) and the included agent group configuration. To apply the agent group configuration:

* Go to the  Administration -> Management -> Agents  page (requires Super Admin privileges)
* Select the  "All Agents" drop down at the top of the window and select the "Copy Template" button to the right of the "Microsoft - SQL" agent group
* Change the log directory of MSSQL as per the environment by using Build/Edit mode.
* Add the desired filters to restrict which agent receive the configuration (optional)
* Select the "Refresh" button at the top of the page
* Select the "Save Configuration" button at the bottom of the page

Note: 
* The reason of the missing logs can be incorrect log directory of MSSQL. Do not forget to update the directory in agent group config as per the environment.
* This content pack does not read SQL Server backup reports which are encoded as UTF8/ASCII.

IMPORTANT: If you have already enable some of the winlog channels on the mentioned agent you will get the configuration error or duplicate logs.
To avoid such situation before applying "Microsoft - SQL" agent group make sure that there is no any winlog channel enabled.
(One of the conflict reason can be already installed "Microsoft - Windows" CP that is enable winlog channel)
