# Export-T2TLogs

All tasks performed by the T2TScripts functions will generate logs. These logs are available in a local folder, but you can also use the `Export-T2Tlogs` which can easily extract the logs.

# Example

For example you can run:
``` powershell
PS C:\> Export-T2Tlogs -OutputType CSV,GridView -DaysOld 5
```  

In this example, the script will fetch all logs within the last 5 days, export to CSV to default location at the Desktop and also displays in powershell's GridView.