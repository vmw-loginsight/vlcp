1. Compatibility:
- Windows Desktop: Vista and newer
- Windows Server: 2008 and newer


2. Installation
Navigate to the "Content Pack" menu in Log Insight. Select the "Import Content Pack" button. In the "Import Content Pack" menu, do the following:
- Select the "Browse..." button and select the content pack you are trying to import
- Select the "Install as content pack" radio button
- Select the "Import" button

Alternately, you can also install the content pack from the marketplace available on Log Insight UI
-On Log Insight UI, browse to Content Pack ->Marketplace 
-Click on the content pack and then click ‘Install’

3.. Configuration

The "Microsoft - Windows" content pack requires the use of the Log Insight agent with the cfapi protocol (default) and the included agent group configuration. To apply the agent group configuration:

* Go to the  Administration -> Management -> Agents  page (requires Super Admin privileges)
* Select the  All Agents  drop-down at the top of the window and select the  “Copy Template”  button to the right of the "Microsoft – Windows" agent group
* Add the desired filters to restrict which agent receive the configuration (optional)
* Select the "Refresh" button at the top of the page
* Select the "Save Configuration" button at the bottom of the page


IMPORTANT: For the "Security - Object Auditing" dashboard to work in the "Microsoft - Windows" content pack, Object Access Auditing must be enabled on all Windows clients sending events. To enable object auditing you need to alter the local security policy and enable auditing on the desired object. To alter the local security policy:
 
* Open up Administrative Tools > Local Security Policy, or run secpol.msc
* Open Local Policies > Audit Policy
* Right-click on "Object Access Audit" and select Properties
* Ensure "Success" and "Failure" are checked
* Click on OK, and then close the Local Security Policy window

Note: You can also create Group Policy to enable object access auditing on multiple systems easily.
 
Once object auditing is enabled, you need to enable auditing for a specific folder (and all its sub-folders and files): 
*  Open up the File Explorer by right-clicking and selecting Run as Administrator
*  Browse to the folder you want to turn auditing on
*  Right-click on the folder and select Properties
*  Select the Security Tab
*  Click on Advanced, then Auditing
*  Click on Add
*  Enter the name of the users you wish auditing, click on Find Now to ensure it is registered, and then click on OK
*  Check the Successful and Failed boxes, and then click on OK
*  Close the windows by clicking OK

 Note: You should only do this for a select few objects, since the information generated is very chatty.
