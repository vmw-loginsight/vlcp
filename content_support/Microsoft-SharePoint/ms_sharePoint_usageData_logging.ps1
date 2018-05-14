$LogPath = ".\\logs";
if (!(Test-Path $LogPath)) {
    $blah = New-Item -ItemType directory -Path $LogPath;
  }
if(Test-Path $LogPath\SPFeatureUsage.csv)
{
	Remove-Item $LogPath\SPFeatureUsage.csv;
}
if(Test-Path $LogPath\SPRequestUsage.csv)
{
	Remove-Item $LogPath\SPRequestUsage.csv;
}
if(Test-Path $LogPath\SPSiteInventory.csv)
{
	Remove-Item $LogPath\SPSiteInventory.csv;
}
#Connection Strings
$Database = "WSS_Logging"
$Server = Get-Content ".\SPServerName.txt"
#=======================
#Page Request Report
#=======================
#Export File
$AttachmentPath = "$LogPath\SPRequestUsage.csv"
# Connect to SQL and query data, extract data to SQL Adapter
$SqlQuery = "SELECT 'SPRequestUsage' as SPPageRequestField,[RowId],[LogTime],[SiteSubscriptionId],[CorrelationId],[WebApplicationId],[SiteId],[WebId],[WebUrl] ,[DocumentPath]
,[ContentTypeId],[QueryString],[BytesConsumed],[SessionId],[ReferrerQueryString],[Browser],[UserAgent] ,[RequestCount],[QueryCount],[QueryDurationSum],[ServiceCallCount]
,[ServiceCallDurationSum],[OperationCount],[Duration],[RequestType],[MachineName],[FarmId],[UserLogin],[UserAddress],[ServerUrl],[SiteUrl],[ReferrerUrl],[HttpStatus],[Title],[RowCreatedTime]
  FROM [WSS_Logging].[dbo].[RequestUsage] where LogTime between (SELECT CAST(getdate() as datetime) - CAST('00:05' AS datetime)) and getdate()"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;Integrated Security = True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$nRecs = $SqlAdapter.Fill($DataSet)
$nRecs | Out-Null
#Populate Hash Table
$objTable = $DataSet.Tables[0]
#Export Hash Table to CSV File
$objTable | Export-CSV $AttachmentPath

#=======================
#Site Inventory Usage
#=======================
#Export File
$AttachmentPath = "$LogPath\SPSiteInventory.csv"
# Connect to SQL and query data, extract data to SQL Adapter
$SqlQuery = "select  'SPSiteInventory' as SPSiteInventoryField, * from WSS_Logging.dbo.SiteInventory where LogTime between (SELECT CAST(getdate() as datetime) - CAST('00:05' AS datetime)) and getdate()" 
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;Integrated Security = True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$nRecs = $SqlAdapter.Fill($DataSet)
$nRecs | Out-Null
#Populate Hash Table
$objTable = $DataSet.Tables[0]
#Export Hash Table to CSV File
$objTable | Export-CSV $AttachmentPath


#=======================
#Feature Usage Report
#=======================
#Export File
$AttachmentPath = "$LogPath\SPFeatureUsage.csv"
# Connect to SQL and query data, extract data to SQL Adapter
$SqlQuery = "select  'SPFeatureUsage' as SPFeatureUsageField, * from WSS_Logging.dbo.FeatureUsage where LogTime between (SELECT CAST(getdate() as datetime) - CAST('00:05' AS datetime)) and getdate()" 
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;Integrated Security = True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$nRecs = $SqlAdapter.Fill($DataSet)
$nRecs | Out-Null
#Populate Hash Table
$objTable = $DataSet.Tables[0]
#Export Hash Table to CSV File
$objTable | Export-CSV $AttachmentPath
