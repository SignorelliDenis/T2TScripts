Function Update-T2TPostMigration {
    <#
    .SYNOPSIS
        Function developed to update objects post-moverequest.

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

    .PARAMETER UseMOERATargetAddress
        Switch param to indicate that ExternalEmailAddress will be the
        destination MOERA (destination.mail.onmicrosoft.com) address.
        If not used, the default value is the target PrimarySMTPAddress

    .PARAMETER KeepOldPrimarySMTPAddress
        Switch to indicate that PrimarySMTPAddress will be kept as the
        source domain value. If not used, the primary address will be the
        same as the ExternalEmailAddress value pointing to destination.

    .PARAMETER SnapshotToXML
        Switch to dump RemoteMailbox attributes and export to an XML
        file before the conversion from RemoteMailbox to MailUser.

    .PARAMETER SnapshotPath
        Define the folder path such as: C:\Temp\Export. If param isn't defined
        and -SnapshotToXML is used, the XML files will be saved on desktop.

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

    .PARAMETER PreferredDC
        Preferred domain controller to connect with. Consider using this parameter
        to avoid replication issues in environments with too many domain controllers.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation
        before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages
        will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Update-T2TPostMigration -Destination -EXOAdmin admin@contoso.com
        Running from an Exchange Server in the destionaron environment.

    .EXAMPLE
        PS C:\> Update-T2TPostMigration -Source -AdminUPN admin@contoso.com -SnapshotToXML -SnapshotPath "C:\Snapshot\" -LocalMachineIsNotExchange -ExchangeHostname "Exchange02" -PreferredDC "DC02"
        The function will connect to the onprem Exchange Server "ExchangeServer02" and the Domain Controller "DC02". Then every remote
        mailboxes present in MigratedUsers.csv with "Completed" value as MoveRequestStatus will be converted to MEU with the new destination
        ExternalEmailAddress. Besides, for each converted MEU, an XML will be created including all attributes values before the convertion.

    .EXAMPLE
        PS C:\> Update-T2TPostMigration -Source -AdminUPN admin@contoso.com -KeepOldPrimarySMTPAddress
        The function will connect to the locally Exchange Server. Then every remote mailboxes present in MigratedUsers.csv
        with "Completed" value as MoveRequestStatus will be converted to MEU with the new destination ExternalEmailAddress.
        Besides, the old primary SMTP address will be kept and the MEU will not be updated by the EmailAddressPolicy.

    .NOTES
        Title: Update-T2TPostMigration.ps1
        Version: 2.1.5
        Date: 2021.04.21
        Author: Denis Vilaca Signorelli (denis.signorelli@microsoft.com)

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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    [CmdletBinding(DefaultParameterSetName="Default")]
    Param(
        [Parameter(ParameterSetName="Destination",Mandatory=$true,
        HelpMessage="Switch Parameter to indicate the destination tenant to connect")]
        [switch]$Destination,

        [Parameter(ParameterSetName="Source",Mandatory=$true,
        HelpMessage="SwitchParameter to indicate that the
        machine running the function is not an Exchange Server")]
        [switch]$Source,

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

        [Parameter(ParameterSetName="Source",Mandatory=$false,
        HelpMessage="Switch to indicate that ExternalEmailAddress will be
        the destination MOERA (destination.mail.onmicrosoft.com) address.
        If not used, the default value is the target PrimarySMTPAddress")]
        [switch]$UseMOERATargetAddress,

        [Parameter(ParameterSetName="Source",Mandatory=$false,
        HelpMessage="Switch to indicate that PrimarySMTPAddress will be kept
        as the source domain value. If not used, the primary address will be
        the same as the ExternalEmailAddress value pointing to destination")]
        [switch]$KeepOldPrimarySMTPAddress,

        [Parameter(ParameterSetName="Source",Mandatory=$false,
        HelpMessage="Switch to Dump RemoteMailbox attributes and export to an XML file")]
        [switch]$SnapshotToXML,

        [Parameter(ParameterSetName="Source",Mandatory=$false,
        HelpMessage="Define the folder path such as: C:\Temp\Export if param is not
        defined and -SnapshotToXML is used, the XML files will be saved on desktop")]
        [string]$SnapshotPath,

        [Parameter(ParameterSetName="Source",Mandatory=$false,
        HelpMessage="Enter a custom import path for the csv. if no value is defined
        the script will search on Desktop path for the MigratedUsers.csv")]
        [string]$MigratedUsers,

        [Parameter(Mandatory=$false,HelpMessage="SwitchParameter to indicate
        that the machine running the function is not an Exchange Server")]
        [switch]$LocalMachineIsNotExchange,

        [Parameter(Mandatory=$false,HelpMessage="Enter the remote exchange hostname")]
        [string]$ExchangeHostname,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter the preferred domain controller FQDN to connect with")]
        [string]$PreferredDC
    )

    Set-PSFConfig -FullName PSFramework.Logging.FileSystem.ModernLog -Value $True
    Write-PSFMessage  -Level Output -Message "Starting script. All logs are being saved in: $((Get-PSFConfig PSFramework.Logging.FileSystem.LogPath).Value)"

    if ( $LocalMachineIsNotExchange.IsPresent -and $ExchangeHostname -like '' )
    {
        $ExchangeHostname = Read-Host "$(Get-Date -Format "HH:mm:ss") - Please enter the Exchange Server hostname"
    }

    # region global variables
    if ($MigratedUsers) { $Global:MigratedUsers | Out-Null }
    if ($MigratedUsersOutputPath) { $Global:MigratedUsersOutputPath  | Out-Null }
    if ($SnapshotToXML) { $Global:SnapshotToXML | Out-Null }
    if ($SnapshotPath) { $Global:SnapshotPath | Out-Null }
    if ($UseMOERATargetAddress) { $Global:UseMOERATargetAddress | Out-Null }
    if ($KeepOldPrimarySMTPAddress) { $Global:KeepOldPrimarySMTPAddress | Out-Null }
    if ($LocalMachineIsNotExchange) { $Global:LocalMachineIsNotExchange | Out-Null }
    if ($PreferredDC) { $Global:PreferredDC | Out-Null }

    # region connections
    if ($LocalMachineIsNotExchange.IsPresent -and $Destination.IsPresent)
    {
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeRemote
        # Connect to services if ServicesToConnect is not empty
        if ($ServicesToConnect.Count)
        {
            Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect -ExchangeHostname $ExchangeHostname
        }
    }
    elseif ($Destination.IsPresent)
    {
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeLocal
        # Connect to services if ServicesToConnect is not empty
        if ($ServicesToConnect.Count)
        {
            Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect
        }
    }
    elseif ($LocalMachineIsNotExchange.IsPresent -and $Source.IsPresent)
    {
        $ServicesToConnect = Assert-ServiceConnection -Services ExchangeRemote, AD
        # Connect to services if ServicesToConnect is not empty
        if ($ServicesToConnect.Count)
        {
            Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect -ExchangeHostname $ExchangeHostname
        }
    }
    elseif ($Source.IsPresent)
    {
        $ServicesToConnect = Assert-ServiceConnection -Services ExchangeLocal
        # Connect to services if ServicesToConnect is not empty
        if ($ServicesToConnect.Count)
        {
            Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect
        }
    }

    # view entire forest and set the preferred DC. If no preferred
    # DC was set, use the same that dclocator is already connected
    if ($PreferredDC)
    {
        try
        {
            Set-AdServerSettings -ViewEntireForest $true -PreferredServer $PreferredDC -ErrorAction Stop
        }
        catch
        {
            # if no valid DC is used, break and clean up sessions. This will
            # avoid EXO throttling limit with appended sessions down the road
            Write-PSFMessage -Level Output -Message "Error: DC was not found. Please run the function again providing a valid Domain Controller FQDN. For example: 'DC01.contoso.com'"
            if ($Destination.IsPresent)
            {
                Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
            }
            Get-PSSession | Remove-PSSession
            Remove-Variable * -ErrorAction SilentlyContinue
            Break
        }
    }
    else
    {
        $PreferredDC = $env:LogOnServer.Replace("\\","")
    }

    # region call target internal function
    if ($Destination.IsPresent)
    {
        Convert-Target
    }

    # region call source internal function
    if ($Source.IsPresent)
    {
        Convert-Source
    }

}