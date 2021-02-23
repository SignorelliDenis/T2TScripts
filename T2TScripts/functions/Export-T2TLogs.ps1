function Export-T2TLogs
{
	<#
	.SYNOPSIS
	This function will export current PSFramework logs.
	
	.DESCRIPTION
	This function will export current PSFramework logs based on the amount of days old define in the 'DaysOld' parameter.
	It will allow to export to CSV file and/or display in powershell GridView.
	Output will have the following header: "ComputerName","Username","Timestamp","Level","Message","Type","FunctionName","ModuleName","File","Line","Tags","TargetObject","Runspace","Callstack"
	
	.PARAMETER FilePath
	Defines the path file to export the CSV file.
	Default value is the user's Desktop with a file name like "yyyy-MM-dd HH_mm_ss" - T2T logs.csv"
	
	.PARAMETER OutputType
	Defines the output types available. Can be a single output or combined.
	Current available options are CSV, GridView.

	.PARAMETER DaysOld
	Defines how old we will go to fetch the logs. Valid range is between 1 through 7 days old. Default Value is 1
	
	.EXAMPLE
	PS C:\> Export-T2Tlogs -OutputType CSV
	In this example, the script will fetch all logs within the last 24 hrs (by default), and export to CSV to default location at the Desktop.
	
	.EXAMPLE
	PS C:\> Export-T2Tlogs -OutputType GridView -DaysOld 3
	In this example, the script will fetch all logs within the last 3 days, and displays them in powershell's GridView.

	.EXAMPLE
	PS C:\> Export-T2Tlogs -OutputType CSV,GridView -DaysOld 5
	In this example, the script will fetch all logs within the last 5 days, export to CSV to default location at the Desktop and also displays in powershell's GridView.

	.EXAMPLE
	PS C:\> Export-T2Tlogs -OutputType CSV,GridView -DaysOld 7 -FilePath "C:\Temp\newLog.csv"
	In this example, the script will fetch all logs within the last 7 days, export to CSV to path "C:\Temp\newLog.csv" and also displays them in powershell's GridView.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
	[CmdletBinding()]
	Param (
		[String]$FilePath = "$home\Desktop\$(get-date -Format "yyyy-MM-dd HH_mm_ss") - T2T logs.csv",
		
		[ValidateSet('CSV','GridView')]
		[string[]]$OutputType = "GridView",

		[ValidateRange(1,7)]
		[int]$DaysOld = 1
	)
	Import-module PSFramework
	$loggingpath = (Get-PSFConfig PSFramework.Logging.FileSystem.LogPath).Value
	$logFiles = Get-ChildItem -Path $loggingpath | Where-Object LastwriteTime -gt (Get-Date).adddays(-$DaysOld)
	$csv = Import-Csv -Path $logFiles.FullName
	Switch ( $OutputType)
	{
		CSV { $csv | Select-Object @{N="Date";E={($_.timestamp -split " ")[0]}},@{N="Time";E={ Get-Date ($_.timestamp.Substring($_.timestamp.IndexOf(" ")).trim()) -Format HH:mm:ss }},`
		"ComputerName","Username","Level","Message","Type","FunctionName","ModuleName","File","Line","Tags","TargetObject","Runspace","Callstack" | Sort-Object Date -Descending | export-csv -Path $FilePath -NoTypeInformation }
		GridView { $csv | Select-Object @{N="Date";E={($_.timestamp -split " ")[0]}},@{N="Time";E={Get-Date ($_.timestamp.Substring($_.timestamp.IndexOf(" ")).trim()) -Format HH:mm:ss }},`
		"ComputerName","Username","Level","Message","Type","FunctionName","ModuleName","File","Line","Tags","TargetObject","Runspace","Callstack" | Sort-Object Date -Descending | Out-GridView }
	}
}
