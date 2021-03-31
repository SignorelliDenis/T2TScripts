Function Export-T2TAttributes{
    <#
    .SYNOPSIS
    This script will dump all necessary attributes that cross-tenant MRS migration requires.
    No changes will be performed by this code.
    
    .DESCRIPTION
    This script will dump all necessary attributes that cross-tenant MRS migration requires.
    No changes will be performed by this code.

    .PARAMETER AdminUPN
    Optional parameter used to connect to to Exchange Online. Only the UPN is
    stored to avoid token expiration during the session, no password is stored.

    .PARAMETER CustomAttributeNumber
    Mandatory parameter used to inform the code which custom
    attributes will be used to scope the search. Valid range: 1-15.

    .PARAMETER CustomAttributeValue
    Mandatory parameter used to inform the code which value will be used to scope the search.

    .PARAMETER DomainMappingCSV
    Enter the CSV path which you mapped the source and target domains. You file header should have 2 columns and be: 'Source','Target'

    .PARAMETER BypassAutoExpandingArchiveCheck
    The script will check if you have Auto-Expanding archive enable on organization
    level, if yes each mailbox will be check if there is an Auto-Expanding archive mailbox
    This check might increase the script duration. You can opt-out using this switch

    .PARAMETER FolderPath
    Optional parameter used to inform which path will be used to save the
    CSV. If no path is chosen, the script will save on the Desktop path.

    .PARAMETER LocalMachineIsNotExchange
    Optional parameter used to inform that you are running the script from a
    non-Exchange Server machine. This parameter will require the -ExchangeHostname.

    .PARAMETER ExchangeHostname
    Mandatory parameter if the switch -LocalMachineIsNotExchange was used.
    Used to inform the Exchange Server FQDN that the script will connect.

    .PARAMETER IncludeSIP
    Switch to get SIP values from proxyAddresses. Without
    this switch the function returns only SMTP and X500.

    .PARAMETER IncludeManager
    Switch to get values from Manager attribute. Be sure to
    scope users and managers if this switch will be used.

    .EXAMPLE
    PS C:\> Export-T2TAttributes -CustomAttributeNumber 10 -CustomAttributeValue "T2T" -DomainMappingCSV sourcetargetmap.csv -FolderPath C:\LoggingPath
    The function will export all users matching the value "T2T" on the CustomAttribute 10, and based on all the users found, we will
    mapping source and target domains according to the CSV provided. All changes and CSV files will be generated in "C:\LoggingPath" folder.

    .EXAMPLE
    PS C:\> Export-T2TAttributes -CustomAttributeNumber 10 -CustomAttributeValue "T2T" -DomainMappingCSV sourcetargetmap.csv -FolderPath C:\LoggingPath -LocalMachineIsNotExchange -ExchangeHostname ExServer1
    The function will connect to the onprem Exchange Server "ExServer1" and export all users matching the value
    "T2T" on the CustomAttribute 10, and based on all the users found, we will mapping source and target domains
    according to the CSV provided. All changes and CSV files will be generated in "C:\LoggingPath" folder.

    .NOTES
    Title: Export-T2TAttributes.ps1
    Version: 1.1.0
    Date: 2021.02.04
    Authors: Denis Vilaca Signorelli (denis.signorelli@microsoft.com)
    Contributors: Agustin Gallegos (agustin.gallegos@microsoft.com)

    REQUIREMENTS
    
    1 - ExchangeOnlineManagement module (EXO v2)

    2 - PSFramework module

    3 - To make things easier, run this script from Exchange On-Premises machine powershell,
        the script will automatically import the Exchange On-Prem module. If you don't want
        to run the script from an Exchange machine, use the switch -LocalMachineIsNotExchange
        and enter the Exchange Server hostname.

    ##############################################################################################
    #This sample script is not supported under any Microsoft standard support program or service.
    #This sample script is provided AS IS without warranty of any kind.
    #Microsoft further disclaims all implied warranties including, without limitation, any implied
    #warranties of merchantability or of fitness for a particular purpose. The entire risk arising
    #out of the use or performance of the sample script and documentation remains with you. In no
    #event shall Microsoft, its authors, or anyone else involved in the creation, production, or
    #delivery of the scripts be liable for any damages whatsoever (including, without limitation,
    #damages for loss of business profits, business interruption, loss of business information,
    #or other pecuniary loss) arising out of the use of or inability to use the sample script or
    #documentation, even if Microsoft has been advised of the possibility of such damages.
    ##############################################################################################
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(DefaultParameterSetName="Default")]
    Param(
        [Parameter(Mandatory=$False)]
        [string]$AdminUPN,
        
        [Parameter(Mandatory=$true,
        HelpMessage="Enter the custom attribute number. Valid range: 1-15")]
        [ValidateRange(1,15)]
        [Int]$CustomAttributeNumber,
        
        [Parameter(Mandatory=$true,
        HelpMessage="Enter the custom attribute value that will be used")]
        [string]$CustomAttributeValue,
        
        [Parameter(Mandatory=$true,
        HelpMessage="Enter the CSV name where you mapped the source and target domains")]
        [string]$DomainMappingCSV,
        
        [Parameter(Mandatory=$false)]
        [switch]$BypassAutoExpandingArchiveCheck,
        
        [Parameter(ParameterSetName="RemoteExchange",Mandatory=$false)]
        [switch]$LocalMachineIsNotExchange,
        
        [Parameter(ParameterSetName="RemoteExchange",Mandatory=$true,
        HelpMessage="Enter the remote exchange hostname")]
        [string]$ExchangeHostname,

        [Parameter(Mandatory=$False)]
        [switch]$IncludeSIP,

        [Parameter(Mandatory=$false)]
        [switch]$IncludeManager,

        [Parameter(Mandatory=$false)]
        [string]$FolderPath
    )

    Set-PSFConfig -FullName PSFramework.Logging.FileSystem.ModernLog -Value $True
    Write-PSFMessage  -Level Output -Message "Starting export script. All logs are being saved in $((Get-PSFConfig PSFramework.Logging.FileSystem.LogPath).Value)"

    if ( $FolderPath )
    {
    
    $outFile = "$FolderPath\UserListToImport.csv"
    $AUXFile = "$FolderPath\AUXUsers.txt"
    
    } else {
    
    $outFile = "$home\desktop\UserListToImport.csv"
    $AUXFile = "$home\desktop\AUXUsers.txt"
    
    }
    
    $outArray = @()
    $CustomAttribute = "CustomAttribute$CustomAttributeNumber"
    $MappingCSV = Import-CSV -Path $DomainMappingCSV

    # Before move on getting the manager attribute
    # We need to know if we have the ADObjectId class
    if ($IncludeManager.IsPresent) {

        $ADObjectId = Get-TypeData -TypeName "Microsoft.Exchange.Data.ObjectId"

    }
    
    # Region check current connection status, and connect if needed
    if ( $LocalMachineIsNotExchange.IsPresent ) {
        
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeRemote, AD
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count ) { Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect -ExchangeHostname $ExchangeHostname}
    
    } else {
        
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeLocal
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count ) { Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect }
    
    }
    
    # Save all properties from MEU object to variable
    $RemoteMailboxes = Get-RemoteMailbox -resultsize unlimited | Where-Object {$_.$CustomAttribute -like $CustomAttributeValue}
    Write-PSFMessage -Level Output -Message "$($RemoteMailboxes.Count) mailboxes with $($CustomAttribute) as $($CustomAttributeValue) were returned"
    
    
    # Saving AUX org status if bypass switch is not present
    if ( $BypassAutoExpandingArchiveCheck.IsPresent ) {
    
        Write-PSFMessage -Level Output -Message "Bypassing Auto-Expand archive check"
    
    } else {
    
        $OrgAUXStatus = Get-EXOrganizationConfig | Select-Object AutoExpandingArchiveEnabled
    
        if ( $OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$True' ) {
    
            Write-PSFMessage -Level Output -Message "Auto-Expand archive is enabled at organization level"
    
        } else {
    
            Write-PSFMessage -Level Output -Message "Auto-Expand archive is not enabled at organization level, but we will check each mailbox"
    
        }
        
    }
    
    Write-PSFMessage -Level Output -Message "Getting EXO mailboxes necessary attributes. This may take some time..."

    [int]$counter = 0
    Foreach ($i in $RemoteMailboxes)
    {
        
        $counter++
        Write-Progress -Activity "Exporting mailbox attributes to CSV" -Status "Working on $($i.DisplayName)" -PercentComplete ($counter * 100 / $($RemoteMailboxes.Count) )
        
        $user = get-Recipient $i.alias
        $object = New-Object System.Object
        $object | Add-Member -type NoteProperty -name primarysmtpaddress -value $i.PrimarySMTPAddress
        $object | Add-Member -type NoteProperty -name alias -value $i.alias
        $object | Add-Member -type NoteProperty -name FirstName -value $User.FirstName
        $object | Add-Member -type NoteProperty -name LastName -value $User.LastName
        $object | Add-Member -type NoteProperty -name DisplayName -value $User.DisplayName
        $object | Add-Member -type NoteProperty -name Name -value $i.Name
        $object | Add-Member -type NoteProperty -name SamAccountName -value $i.SamAccountName
        $object | Add-Member -type NoteProperty -name legacyExchangeDN -value $i.legacyExchangeDN
        $object | Add-Member -type NoteProperty -name CustomAttribute -value $CustomAttribute
        $object | Add-Member -type NoteProperty -name CustomAttributeValue -value $CustomAttributeValue
        
        # If we have don't have ADObjectId class, we must resolve the CN to alias
        if ( $IncludeManager.IsPresent -and $ADObjectId -eq $Null -and $user.Manager -ne $Null ) {

            $Manager = ( Get-Recipient $user.Manager ).Alias
            $object | Add-Member -type NoteProperty -name Manager -value $Manager

        }
        if ( $IncludeManager.IsPresent -and $ADObjectId -eq $Null -and $user.Manager -eq $Null ) {

            $object | Add-Member -type NoteProperty -name Manager -value $Null

        }

        # Under ADObjectId class (Exchange or Exchange management tools) the output is
        # array when getting manager property so just we need to declare the name element
        if ( $IncludeManager.IsPresent -and $ADObjectId -ne $Null -and $user.Manager -ne $Null ) {

            $object | Add-Member -type NoteProperty -name Manager -value $user.Manager.Name

        }
        if ( $IncludeManager.IsPresent -and $ADObjectId -ne $Null -and $user.Manager -eq $Null ) {

            $object | Add-Member -type NoteProperty -name Manager -value $Null

        }

        if ( $BypassAutoExpandingArchiveCheck.IsPresent ) {
        
            # Save necessary properties from EXO object to variable avoiding AUX check
            $EXOMailbox = Get-EXOMailbox -Identity $i.Alias -PropertySets Retention,Hold,Archive,StatisticsSeed
        
        } else {

            if ($OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$True') {

                # If AUX is enable at org side, doesn't metter if the mailbox has it explicitly enabled
                $EXOMailbox = Get-EXOMailbox -Identity $i.Alias -Properties ExchangeGuid,MailboxLocations,LitigationHoldEnabled,SingleItemRecoveryEnabled,ArchiveDatabase,ArchiveGuid

            } else {

                # If AUX isn't enable at org side, we check if the mailbox has it explicitly enabled
                $EXOMailbox = Get-EXOMailbox -Identity $i.Alias -Properties ExchangeGuid,MailboxLocations,LitigationHoldEnabled,SingleItemRecoveryEnabled,ArchiveDatabase,ArchiveGuid,AutoExpandingArchiveEnabled
            
            }

        }

        if ( $BypassAutoExpandingArchiveCheck.IsPresent ) {
        
            # Save necessary properties from EXO object to variable avoiding AUX check
            Write-PSFMessage -Level Output -Message "Bypassing MailboxLocation check for Auto-Expanding archive"

        } else {

            # AUX enabled doesn't mean that the mailbox indeed have AUX
            # archive. We need to check the MailboxLocation to be sure
            if ( ($OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$True' -and $EXOMailbox.MailboxLocations -like '*;AuxArchive;*') -or
            ($OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$False' -and $EXOMailbox.AutoExpandingArchiveEnabled -eq '$True' -and
            $EXOMailbox.MailboxLocations -like '*;AuxArchive;*') )
            {

                $AuxMessage = "[$(Get-Date -format "HH:mm:ss")] User $($i.Alias) has an auxiliar Auto-Expanding archive mailbox. Be aware that any auxiliar archive mailbox will not be migrated"
                $AuxMessage | Out-File -FilePath $AUXFile -Append
                Write-PSFHostColor -String $AuxMessage -DefaultColor Cyan
                
            }
        }

        # Get mailbox guid from EXO because if the mailbox was created from scratch
        # on EXO the ExchangeGuid would not be write-backed to On-Premises
        $object | Add-Member -type NoteProperty -name ExchangeGuid -value $EXOMailbox.ExchangeGuid
        
        # Get mailbox ELC value
        $ELCValue = 0
        if ($EXOMailbox.LitigationHoldEnabled) {$ELCValue = $ELCValue + 8}
        if ($EXOMailbox.SingleItemRecoveryEnabled) {$ELCValue = $ELCValue + 16}
        if ($ELCValue -ge 0) { $object | Add-Member -type NoteProperty -name ELCValue -value $ELCValue}
        
        # Get the ArchiveGuid from EXO if it exist. The reason that we don't rely on
        # "-ArchiveStatus" parameter is that may not be trustable in certain scenarios
        # https://docs.microsoft.com/en-us/office365/troubleshoot/archive-mailboxes/archivestatus-set-none
        if ( $EXOMailbox.ArchiveDatabase -ne '' -and
                $EXOMailbox.ArchiveGuid -ne "00000000-0000-0000-0000-000000000000" )
        {
            
            $object | Add-Member -type NoteProperty -name ArchiveGuid -value $EXOMailbox.ArchiveGuid
        
        } else {

            $object | Add-Member -type NoteProperty -name ArchiveGuid -value $Null

        }

        # Get only SMTP, X500 and SIP if the switch is present
        # from proxyAddresses and define the targetAddress
        $ProxyArray = @()
        $TargetArray = @()
        $Proxy = $i.EmailAddresses
        foreach ($email in $Proxy)
        {
            if (($email -like 'SMTP:*' -or $email -like 'X500:*') -and $email -notlike '*.onmicrosoft.com')
            {

                $ProxyArray = $ProxyArray += $email

            }
            elseif ($IncludeSIP.IsPresent -and $email -like 'SIP:*')
            {

                $ProxyArray = $ProxyArray += $email

            }
            elseif ($email -like 'SMTP:*' -and $email -like '*.onmicrosoft.com')
            {

                $TargetArray = $TargetArray += $email

            }
        }

        # Join it using ";" and replace the old domain (source) to the new one (target)
        $ProxyToString = $ProxyArray -Join ";" -Replace "SMTP","smtp"

        # Map from the CSV which source domain will become which target domain
        Foreach ($Domain in $MappingCSV) {

            # Add @ before the domain to avoid issues with subdomains
            $SourceDomain = $Domain.Source.Insert(0,"@")
            $TargetDomain = $Domain.Target.Insert(0,"@")

            if ($ProxyToString -match $Domain.source) {

                $ProxyToString = $ProxyToString -replace $SourceDomain,$TargetDomain

            }

        }

        $object | Add-Member -type NoteProperty -name EmailAddresses -value $ProxyToString

        # Get ProxyAddresses only for *.mail.onmicrosoft to define in the target AD the targetAddress value
        $TargetToString = [system.String]::Join(";",$TargetArray)
        $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $TargetToString.Replace("smtp:","")

        # Connect to AD exported module only if this machine has not AD Module installed
        if ( $LocalMachineIsNotExchange.IsPresent -and $LocalAD -eq '' )
        {

            $Junk = Get-RemoteADUser -Identity $i.SamAccountName -Properties *

        } else {

            $Junk = Get-ADUser -Identity $i.SamAccountName -Properties *

        }

        # Get Junk hashes, these are SHA-265 write-backed from EXO. Check if the user
        # has any hash, if yes we convert the HEX to String removing the "-"
        if ( $junk.msExchSafeSendersHash.Length -gt 0 )
        {
        
            $SafeSender = [System.BitConverter]::ToString($junk.msExchSafeSendersHash)
            $Safesender = $SafeSender.Replace("-","")
            $object | Add-Member -type NoteProperty -name SafeSender -value $SafeSender
        
        } else {

            $object | Add-Member -type NoteProperty -name SafeSender $Null
        
        }
        
        if ( $junk.msExchSafeRecipientsHash.Length -gt 0 )
        {
            
            $SafeRecipient = [System.BitConverter]::ToString($junk.msExchSafeRecipientsHash)
            $SafeRecipient = $SafeRecipient.Replace("-","")
            $object | Add-Member -type NoteProperty -name SafeRecipient -value $SafeRecipient

        }  else {

            $object | Add-Member -type NoteProperty -name SafeRecipient -value $Null

        }

        if ( $junk.msExchBlockedSendersHash.Length -gt 0 )
        {
            
            $BlockedSender = [System.BitConverter]::ToString($junk.msExchBlockedSendersHash)
            $BlockedSender = $BlockedSender.Replace("-","")
            $object | Add-Member -type NoteProperty -name BlockedSender -value $BlockedSender
        
        } else {

            $object | Add-Member -type NoteProperty -name BlockedSender -value $Null

        }

        $outArray += $object
    
    }
    
    # Export to a CSV and clear up variables and sessions
    if ( $AuxMessage ) {

        Write-PSFMessage -Level Output -Message "Saving CSV on $($outfile)"
        Write-PSFMessage -Level Output -Message "Saving TXT on $($AUXFile)"

    } else {
    
        Write-PSFMessage -Level Output -Message "Saving CSV on $($outfile)"
    
    }
    
    $outArray | Export-CSV $outfile -notypeinformation
    Remove-Variable * -ErrorAction SilentlyContinue
    Get-PSSession | Remove-PSSession
    Disconnect-ExchangeOnline -Confirm:$false

}