Function Update-T2TPostMigration {
    <#
    .SYNOPSIS
        Function developed to update objects once post-moverequest.

    .DESCRIPTION
        The Update-T2TPostMigration function is intended to update all necessary attributes
        in the source and target environment once the migration batch is finished. The function
        is divided between two switch parameters called -Source and -Destination.

    .PARAMETER Destination
        Required switch parameter to update the objects in the destination environment

    .PARAMETER AdminUPN
        Enter the user admin to connect to the target Exchange Online

    .PARAMETER UserListToImport
        Custom path to import the UserListToImport.csv. if no value
        is defined the function will try to get it from the Desktop.

    .PARAMETER MigratedUsersOutputPath
        Enter the file path used to save the MigratedUsers.csv. If
        no value is defined, default value will be the Desktop path

    .PARAMETER Source
        Required switch parameter to update the objects in the source environment.

    .PARAMETER MigratedUsers
        Custom path to import the MigratedUsers.csv. if no value is
        defined the function will try to get it from the Desktop.

    .PARAMETER UsePrimarySMTPAsTargetAddress
        Switch to indicate if the targetAddress (ExternalEmailAddress) will be
        the PrimarySMTPAddress. If not used, the default value is the MOERA domain

    .PARAMETER LocalMachineIsNotExchange
        Optional parameter used to inform that you are running the script from a
        non-Exchange Server machine. This parameter will require the -ExchangeHostname.

    .PARAMETER ExchangeHostname
        Mandatory parameter if the switch -LocalMachineIsNotExchange was used.
        Used to inform the Exchange Server FQDN that the script will connect.


    .EXAMPLE
        PS C:\> Update-T2TPostMigration -Destination -EXOAdmin admin@contoso.com
        The function will export all users matching the value "T2T" on the CustomAttribute 10, and based on all the users found, we will
        mapping source and target domains according to the CSV provided. All changes and CSV files will be generated in "C:\LoggingPath" folder.

    .EXAMPLE
        PS C:\> Update-T2TPostMigration -Source -EXOAdmin admin@contoso.com -UsePrimarySMTPAsTargetAddress
        The function will connect to the onprem Exchange Server "ExServer1" and export all users matching the value
        "T2T" on the CustomAttribute 10, and based on all the users found, we will mapping source and target domains
        according to the CSV provided. All changes and CSV files will be generated in "C:\LoggingPath" folder.

    .NOTES
        Title: Update-T2TPostMigration.ps1
        Version: 2.0.0
        Date: 2021.04.21
        Authors: Denis Vila�a Signorelli (denis.signorelli@microsoft.com)

    REQUIREMENT
        1.ExchangeOnlineManagement module (EXO v2)
        2.PSFramework module
        3.To make things easier, run this script from Exchange On-Premises machine powershell,
        the script will automatically import the Exchange On-Prem module. If you don't want
        to run the script from an Exchange machine, use the switch -LocalMachineIsNotExchange
        and enter the Exchange Server hostname.

    #########################################################################
    # This sample script is provided AS IS without warranty of any kind and #
    # not supported under any Microsoft standard support program or service #
    #########################################################################
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(DefaultParameterSetName="Default")]
    Param(
        [Parameter(ParameterSetName="Destination",Mandatory=$true,
        HelpMessage="Switch Parameter to indicate the destination tenant to connect")]
        [switch]$Destination,

        [Parameter(ParameterSetName="Destination",Mandatory=$true,
        HelpMessage="Enter the user admin to connect to Exchange Online")]
        [string]$AdminUPN,

        [Parameter(ParameterSetName="Destination",Mandatory=$false,
        HelpMessage="Enter a custom import path for the csv. if no value is defined
        the script will search on Desktop path for the UserListToImport.csv")]
        [string]$UserListToImport,

        [Parameter(ParameterSetName="Destination",Mandatory=$false,
        HelpMessage="Enter the file path used to save the MigratedUsers.csv.
        If no value is defined, default value will be the Desktop path")]
        [string]$MigratedUsersOutputPath,

        [Parameter(ParameterSetName="Source",Mandatory=$true,
        HelpMessage="SwitchParameter to indicate that the
        machine running the function is not an Exchange Server")]
        [switch]$Source,

        [Parameter(ParameterSetName="Source",Mandatory=$false,
        HelpMessage="Enter a custom import path for the csv. if no value is defined
        the script will search on Desktop path for the MigratedUsers.csv")]
        [string]$MigratedUsers,

        [Parameter(ParameterSetName="Source",Mandatory=$false,
        HelpMessage="Switch to indicate if the targetAddress (ExternalEmailAddress) will
        be the PrimarySMTPAddress. If not used, the default value is the MOERA domain")]
        [switch]$UsePrimarySMTPAsTargetAddress,

        [Parameter(Mandatory=$false,
        HelpMessage="SwitchParameter to indicate that the
        machine running the function is not an Exchange Server")]
        [switch]$LocalMachineIsNotExchange,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter the remote exchange hostname")]
        [string]$ExchangeHostname
    )

    Set-PSFConfig -FullName PSFramework.Logging.FileSystem.ModernLog -Value $True
    Write-PSFMessage  -Level Output -Message "Starting script. All logs are being saved in: $((Get-PSFConfig PSFramework.Logging.FileSystem.LogPath).Value)"

    # region global variables
    if ( $MigratedUsers ) { $Global:MigratedUsers | Out-Null }
    if ( $MigratedUsersOutputPath ) { $Global:FolderPath | Out-Null}
    if ( $UsePrimarySMTPAsTargetAddress ) { $Global:UsePrimarySMTPAsTargetAddress | Out-Null }
    if ( $LocalMachineIsNotExchange ) { $Global:LocalMachineIsNotExchange | Out-Null }

    # region connections
    if ( $LocalMachineIsNotExchange.IsPresent -and $Destination.IsPresent ) {
        
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeRemote
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count ) { Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect -ExchangeHostname $ExchangeHostname }
    
    }
    elseif ( $Destination.IsPresent )
    {
        
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeLocal
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count ) { Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect }
    
    }
    elseif ( $LocalMachineIsNotExchange.IsPresent -and $Source.IsPresent )
    {
        
        $ServicesToConnect = Assert-ServiceConnection -Services ExchangeRemote
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count ) { Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect -ExchangeHostname $ExchangeHostname }
    
    }
    elseif ( $Source.IsPresent )
    {
        
        $ServicesToConnect = Assert-ServiceConnection -Services ExchangeLocal
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count ) { Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect }
    
    }
    

    # region target function
    if ( $Destination.IsPresent ) { Update-Target }

    # region source function
    if ( $Source.IsPresent ) { Update-Source }


}