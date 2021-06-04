Function Export-T2TAttributes {
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
        Enter the CSV path which you mapped the source and target domains.
        You file header should have 2 columns and be: 'Source','Target'

    .PARAMETER IncludeContacts
        Switch to get mail contacts. Mail contact dump
        also relies on the Custom Attibute filter.

    .PARAMETER IncludeSIP
        Switch to get SIP values from proxyAddresses. Without
        this switch the function returns only SMTP and X500.

    .PARAMETER IncludeManager
        Switch to get values from Manager attribute. Be sure to
        scope users and managers if this switch will be used.

    .PARAMETER IncludeGeneral
        Switch which indicates that the function must export attributes from the General
        AD tab such as: description, physicalDeliveryOfficeName, wWWHomePage and url.

    .PARAMETER IncludeAddress
        Switch which indicates that the function must export
        all attributes in the "Address" tab such as: street,
        P.O. Box, City, State/Province, ZIP Code and Country

    .PARAMETER IncludePhones
        Switch which indicates that the function must
        export all attributes in the phone tab such as
        Home, Pager, Mobile, Fax, IP Phone and Notes.

    .PARAMETER IncludeOrganization
        Switch which indicates that the function must export
        the Job Title, Department and Company attributes.

    .PARAMETER BypassAutoExpandingArchiveCheck
        The script will check if you have Auto-Expanding archive enable on organization
        level, if yes each mailbox will be check if there is an Auto-Expanding archive mailbox
        This check might increase the script duration. You can opt-out using this switch

    .PARAMETER LocalMachineIsNotExchange
        Optional parameter used to inform that you are running the script from a
        non-Exchange Server machine. This parameter will require the -ExchangeHostname.

    .PARAMETER ExchangeHostname
        Mandatory parameter if the switch -LocalMachineIsNotExchange was used.
        Used to inform the Exchange Server FQDN that the script will connect.

    .PARAMETER PreferredDC
        Preferred domain controller to connect with. Consider using this parameter
        to avoid replication issues in environments with too many domain controllers.

    .PARAMETER FolderPath
        Optional parameter used to inform which path will be used to save the
        CSV. If no path is chosen, the script will save on the Desktop path.

    .EXAMPLE
        PS C:\> Export-T2TAttributes -CustomAttributeNumber 10 -CustomAttributeValue "T2T" -DomainMappingCSV sourcetargetmap.csv -FolderPath C:\LoggingPath
        The function will export all users matching the value "T2T" on the CustomAttribute 10, and based on all the users found, we will
        mapping source and target domains according to the CSV provided. All changes and CSV files will be generated in "C:\LoggingPath" folder.

    .EXAMPLE
        PS C:\> Export-T2TAttributes -CustomAttributeNumber 10 -CustomAttributeValue "T2T" -DomainMappingCSV sourcetargetmap.csv -LocalMachineIsNotExchange -ExchangeHostname ExServer1
        The function will connect to the onprem Exchange Server "ExServer1" and export all users matching the value
        "T2T" on the CustomAttribute 10, and based on all the users found, we will mapping source and target domains
        according to the CSV provided. All changes and CSV files will be generated in "C:\LoggingPath" folder.

    .NOTES
        Title: Export-T2TAttributes.ps1
        Version: 2.1.4
        Date: 2021.02.04
        Authors: Denis Vilaca Signorelli (denis.signorelli@microsoft.com)
        Contributors: Agustin Gallegos (agustin.gallegos@microsoft.com)

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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [CmdletBinding(DefaultParameterSetName="Default")]
    Param(
        [Parameter(Mandatory=$False,
        HelpMessage="Enter the user admin to connect to Exchange Online")]
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

        [Parameter(Mandatory=$False,
        HelpMessage="SwitchParameter to get mail contacts. Mail contact dump
        also relies on the Custom Attibute filter")]
        [switch]$IncludeContacts,

        [Parameter(Mandatory=$False,
        HelpMessage="SwitchParameter to get SIP values from proxyAddresses.
        Only SMTP and X500 are dumped by default")]
        [switch]$IncludeSIP,

        [Parameter(Mandatory=$false,
        HelpMessage="SwitchParameter to dump the manager AD attribute value")]
        [switch]$IncludeManager,

        [Parameter(Mandatory=$false,
        HelpMessage="Switch which indicates that the function must export attributes from the
        General AD tab such as: description, physicalDeliveryOfficeName, wWWHomePage and url.")]
        [switch]$IncludeGeneral,

        [Parameter(Mandatory=$false,
        HelpMessage="SwitchParameter which indicates that the function
        must export all attributes in the Address tab such as: street,
        P.O. Box, City, State/Province, ZIP Code and Country")]
        [switch]$IncludeAddress,

        [Parameter(Mandatory=$false,
        HelpMessage="SwitchParameter which indicates that the function
        must export all attributes in the phone tab such as Home, Pager,
        Mobile, Fax, IP Phone and Notes.")]
        [switch]$IncludePhones,

        [Parameter(Mandatory=$false,
        HelpMessage="SwitchParameter which indicates that the function
        must export the Job Title, Department and Company attributes")]
        [switch]$IncludeOrganization,
        

        [Parameter(Mandatory=$false,
        HelpMessage="SwitchParameter used to bypass the Auto-Expanding
        Archive check as it can increase the function duration")]
        [switch]$BypassAutoExpandingArchiveCheck,

        [Parameter(ParameterSetName="RemoteExchange",Mandatory=$false,
        HelpMessage="SwitchParameter to indicate that the
        machine running the function is not an Exchange Server")]
        [switch]$LocalMachineIsNotExchange,
        
        [Parameter(ParameterSetName="RemoteExchange",Mandatory=$true,
        HelpMessage="Enter the remote exchange hostname")]
        [string]$ExchangeHostname,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter the preferred domain controller FQDN to connect with")]
        [string]$PreferredDC,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter the file path used to save the
        function output. Default value is the Desktop path")]
        [string]$FolderPath
    )

    Set-PSFConfig -FullName PSFramework.Logging.FileSystem.ModernLog -Value $True
    Write-PSFMessage  -Level Output -Message "Starting export script. All logs are being saved in: $((Get-PSFConfig PSFramework.Logging.FileSystem.LogPath).Value)"

    # region local variables
    $outArray = [System.Collections.ArrayList]::new()
    [int]$counter = 0
    if ( $FolderPath )
    {
        $outFile = "$FolderPath\UserListToImport.csv"
        $AUXFile = "$FolderPath\AUXUsers.txt"
    }
    else
    {
        $outFile = "$home\desktop\UserListToImport.csv"
        $AUXFile = "$home\desktop\AUXUsers.txt"
    }

    # region global variables
    $Global:CustomAttribute = "CustomAttribute$CustomAttributeNumber"
    $Global:CustomAttributeValue = $Global:CustomAttributeValue
    $Global:DomainMappingCSV

    # Check if $DomainMappingCSV is valid
    $CSVMappingExist =  Get-CSVStatus -MappingFile
    if ( $CSVMappingExist -eq 0 ) { Break }
    $Global:MappingCSV = Import-CSV -Path $DomainMappingCSV

    # region connections
    if ( $LocalMachineIsNotExchange.IsPresent )
    {
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeRemote, AD
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count )
        {
            Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect -ExchangeHostname $ExchangeHostname
        }
    }
    else
    {
        $ServicesToConnect = Assert-ServiceConnection -Services EXO, ExchangeLocal
        # Connect to services if ServicesToConnect is not empty
        if ( $ServicesToConnect.Count )
        {
            Connect-OnlineServices -AdminUPN $AdminUPN -Services $ServicesToConnect
        }
    }

    # view entire forest and set the preferred DC. If no preferred DC was set, use
    # the same that dclocator is already connected. PS: I coudn't pass this to a
    # different function cause there is a bug preventing the option to hidden the
    # Disconnect-ExchangeOnline banner when it's performed by a different function
    if ( $PreferredDC )
    {
        try
        {
            Set-AdServerSettings -ViewEntireForest $true -PreferredServer $PreferredDC -ErrorAction Stop
        }
        catch
        {
            # if no valid DC is used break and clean up sessions
            Write-PSFMessage -Level Output -Message "Error: DC was not found. Please run the function again providing a valid Domain Controller FQDN. For example: 'DC01.contoso.com'"
            Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
            Get-PSSession | Remove-PSSession
            Remove-Variable * -ErrorAction SilentlyContinue
            Break
        }
    }
    else
    {
        $PreferredDC = $env:LogOnServer.Replace("\\","")
    }
    
    # region dump contacts if -IncludeContacts is present
    if ( $IncludeContacts.IsPresent )
    {
        Move-Contact -Sync Export
    }

    # region dump all properties from MEU object to variable
    $RemoteMailboxes = (Get-RemoteMailbox -ResultSize Unlimited).Where({$_.$CustomAttribute -like $CustomAttributeValue})
    $UsersCount = ($RemoteMailboxes | Measure-Object).count
    Write-PSFMessage -Level Output -Message "$($UsersCount) mailboxes with $($CustomAttribute) as $($CustomAttributeValue) were returned"

    # dump AUX org status if bypass switch is not present
    if ( $BypassAutoExpandingArchiveCheck.IsPresent )
    {
        Write-PSFMessage -Level Output -Message "Bypassing Auto-Expand archive check"
    }
    else
    {
        $OrgAUXStatus = Get-EXOrganizationConfig | Select-Object AutoExpandingArchiveEnabled

        if ( $OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$True' )
        {
            Write-PSFMessage -Level Output -Message "Auto-Expand archive is enabled at organization level"
        }
        else
        {
            Write-PSFMessage -Level Output -Message "Auto-Expand archive is not enabled at organization level, but we will check each mailbox"
        }
    }
    
    Write-PSFMessage -Level Output -Message "Getting EXO mailboxes necessary attributes. This may take some time..."

    # region iterate objects
    ForEach ($i in $RemoteMailboxes)
    {
        $counter++
        Write-Progress -Activity "Exporting mailbox attributes to CSV" -Status "Working on $($i.DisplayName)" -PercentComplete ( $counter * 100 / $UsersCount )
        
        $user = get-Recipient $i.alias
        $object = New-Object System.Object
        $object | Add-Member -type NoteProperty -name alias -value $i.alias
        $object | Add-Member -type NoteProperty -name FirstName -value $User.FirstName
        $object | Add-Member -type NoteProperty -name LastName -value $User.LastName
        $object | Add-Member -type NoteProperty -name DisplayName -value $User.DisplayName
        $object | Add-Member -type NoteProperty -name Name -value $i.Name
        $object | Add-Member -type NoteProperty -name SamAccountName -value $i.SamAccountName
        $object | Add-Member -type NoteProperty -name legacyExchangeDN -value $i.legacyExchangeDN
        $object | Add-Member -type NoteProperty -name CustomAttribute -value $CustomAttribute
        $object | Add-Member -type NoteProperty -name CustomAttributeValue -value $CustomAttributeValue

        if ( $BypassAutoExpandingArchiveCheck.IsPresent )
        {
            try
            {
                # Save necessary properties from EXO object to variable avoiding AUX check
                $EXOMailbox = Get-EXOMailbox -Identity $i.Alias -PropertySets Retention,Hold,Archive,StatisticsSeed -ErrorAction Stop
            }
            catch
            {
                # If no EXO mailbox exist, continue the iteration
                Write-PSFMessage -Level Output -Message "Error: The user $($i.Alias) doesn't have an EXO mailbox."
                Continue
            }
        }
        else
        {
            if ($OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$True')
            {
                try
                {
                    # If AUX is enable at org side, doesn't metter if the mailbox has it explicitly enabled
                    $EXOMailbox = Get-EXOMailbox -Identity $i.Alias -Properties ExchangeGuid,MailboxLocations,LitigationHoldEnabled,SingleItemRecoveryEnabled,ArchiveDatabase,ArchiveGuid -ErrorAction Stop
                }
                catch
                {
                    # If no EXO mailbox exist, continue the iteration
                    Write-PSFMessage -Level Output -Message "Error: The user $($i.Alias) doesn't have an EXO mailbox."
                    Continue
                }
            }
            else
            {
                try
                {
                    # If AUX isn't enable at org side, we check if the mailbox has it explicitly enabled
                    $EXOMailbox = Get-EXOMailbox -Identity $i.Alias -Properties ExchangeGuid,MailboxLocations,LitigationHoldEnabled,SingleItemRecoveryEnabled,ArchiveDatabase,ArchiveGuid,AutoExpandingArchiveEnabled -ErrorAction Stop
                }
                catch
                {
                    # If no EXO mailbox exist, continue the iteration
                    Write-PSFMessage -Level Output -Message "Error: The user $($i.Alias) doesn't have an EXO mailbox."
                    Continue
                }
            }
        }

        if ( $BypassAutoExpandingArchiveCheck.IsPresent )
        {
            # Save necessary properties from EXO object to variable avoiding AUX check
            Write-PSFMessage -Level Output -Message "Bypassing $($i.Alias) MailboxLocation check for Auto-Expanding archive"
        }
        else
        {
            # AUX enabled doesn't mean that the mailbox indeed have AUX
            # archive. We need to check the MailboxLocation to be sure
            if (($OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$True' -and $EXOMailbox.MailboxLocations -like '*;AuxArchive;*') -or
            ($OrgAUXStatus.AutoExpandingArchiveEnabled -eq '$False' -and $EXOMailbox.AutoExpandingArchiveEnabled -eq '$True' -and
            $EXOMailbox.MailboxLocations -like '*;AuxArchive;*'))
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
        if ($EXOMailbox.LitigationHoldEnabled)
        {
            $ELCValue = $ELCValue + 8
        }
        if ($EXOMailbox.SingleItemRecoveryEnabled)
        {
            $ELCValue = $ELCValue + 16
        }
        if ($ELCValue -ge 0)
        {
            $object | Add-Member -type NoteProperty -name ELCValue -value $ELCValue
        }
        
        # Get the ArchiveGuid from EXO if it exist. The reason that we don't rely on
        # "-ArchiveStatus" parameter is that may not be trustable in certain scenarios
        # https://docs.microsoft.com/en-us/office365/troubleshoot/archive-mailboxes/archivestatus-set-none
        if ( $EXOMailbox.ArchiveDatabase -ne '' -and
             $EXOMailbox.ArchiveGuid -ne "00000000-0000-0000-0000-000000000000" )
        {
            $object | Add-Member -type NoteProperty -name ArchiveGuid -value $EXOMailbox.ArchiveGuid
        }
        else
        {
            $object | Add-Member -type NoteProperty -name ArchiveGuid -value $Null
        }

        # Get only SMTP, X500 and SIP if the switch is present
        # from proxyAddresses and define the targetAddress
        $ProxyArray = [System.Collections.ArrayList]::new()
        $Proxy = $i.EmailAddresses
        ForEach ($email in $Proxy)
        {
            if ($email -like 'SMTP:*' -or $email -like 'X500:*')
            {
                [void]$ProxyArray.Add($email)
            }
            if ($IncludeSIP.IsPresent -and $email -like 'SIP:*')
            {
                [void]$ProxyArray.Add($email)
            }
            if ($email -like 'SMTP:*' -and $email -like '*.onmicrosoft.com')
            {
                [string]$TargetString = $email -replace "smtp:",""
            }
        }

        # Join it using ";" and replace the old domain (source) to the new one (target)
        $ProxyToString = $ProxyArray -Join ";" -Replace "SMTP","smtp"

        # Declare PrymarySMTPAddress
        $PrimarySMTP = $i.PrimarySmtpAddress

        # Map from the CSV which source domain will become which target domain
        ForEach ($Domain in $MappingCSV)
        {
            # Add @ before the domain to avoid issues with subdomains
            $SourceDomain = $Domain.Source.Insert(0,"@")
            $TargetDomain = $Domain.Target.Insert(0,"@")

            if ($ProxyToString -match $Domain.source)
            {
                $ProxyToString = $ProxyToString -replace $SourceDomain,$TargetDomain
            }

            if ($PrimarySMTP -match $Domain.source)
            {
                $PrimarySMTP = $PrimarySMTP -replace $SourceDomain,$TargetDomain
            }

            if ($TargetString -match $Domain.source)
            {
                $TargetPostMigration = $TargetString -replace $SourceDomain,$TargetDomain
            }
        }

        $object | Add-Member -type NoteProperty -name EmailAddresses -value $ProxyToString
        $object | Add-Member -type NoteProperty -name PrimarySMTPAddress -value $PrimarySMTP

        # Get ProxyAddress only for *.mail.onmicrosoft to define in the target AD the
        # targetAddress value. This value should not be converted through the domain mapping CSV.
        $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $TargetString

        # Get only the proxyAddress which matches *.mail.onmicrosoft.com to define in the target AD the
        # targetAddress value post-migration. This value should be converted through the domain mapping CSV.
        $object | Add-Member -type NoteProperty -name ExternalEmailAddressPostMove -value $TargetPostMigration

        # Connect to AD exported module only if this machine has not AD Module installed and
        # filtering based on what "Include" was passed to avoid dump too many unnecessary stuff
        if (($IncludeManager.IsPresent -or $IncludeOrganization.IsPresent -or $IncludeGeneral.IsPresent -or $IncludePhones.IsPresent -or $IncludeAddress.IsPresent) -and $LocalMachineIsNotExchange.IsPresent -and $LocalAD -eq '')
        {
            $ADUser = Get-RemoteADUser -Identity $i.SamAccountName -Server $PreferredDC -Properties msExchSafeSendersHash,msExchSafeRecipientsHash,msExchBlockedSendersHash,physicalDeliveryOfficeName,wWWHomePage,url,Description,streetAddress,postOfficeBox,l,postalCode,c,co,countryCode,st,telephoneNumber,otherTelephone,homePhone,otherHomePhone,pager,otherPager,mobile,otherMobile,facsimileTelephoneNumber,otherFacsimileTelephoneNumber,ipPhone,otherIpPhone,info,title,department,company
            #Call function to dump those "-Include"
            [void](Export-ADPersonalAttribute)
        }
        elseif ($IncludeManager.IsPresent -or $IncludeOrganization.IsPresent -or $IncludeGeneral.IsPresent -or $IncludePhones.IsPresent -or $IncludeAddress.IsPresent)
        {
            $ADUser = Get-ADUser -Identity $i.SamAccountName -Server $PreferredDC -Properties msExchSafeSendersHash,msExchSafeRecipientsHash,msExchBlockedSendersHash,physicalDeliveryOfficeName,wWWHomePage,url,Description,streetAddress,postOfficeBox,l,postalCode,c,co,countryCode,st,telephoneNumber,otherTelephone,homePhone,otherHomePhone,pager,otherPager,mobile,otherMobile,facsimileTelephoneNumber,otherFacsimileTelephoneNumber,ipPhone,otherIpPhone,info,title,department,company
            #Call function to dump those "-Include"
            [void](Export-ADPersonalAttribute)
        }
        elseif ($LocalMachineIsNotExchange.IsPresent -and $LocalAD -eq '')
        {
            $ADUser = Get-RemoteADUser -Identity $i.SamAccountName -Server $PreferredDC -Properties msExchSafeSendersHash,msExchSafeRecipientsHash,msExchBlockedSendersHash
        }
        else
        {
            $ADUser = Get-ADUser -Identity $i.SamAccountName -Server $PreferredDC -Properties msExchSafeSendersHash,msExchSafeRecipientsHash,msExchBlockedSendersHash
        }

        # Get Junk hashes, these are SHA-265 write-backed from EXO. Check if the user
        # has any hash, if yes we convert the HEX to String removing the dash "-"
        if ($ADUser.msExchSafeSendersHash.Length -gt 0)
        {
            $SafeSender = [System.BitConverter]::ToString($ADUser.msExchSafeSendersHash)
            $Safesender = $SafeSender.Replace("-","")
            $object | Add-Member -type NoteProperty -name SafeSender -value $SafeSender
        }
        else
        {
            $object | Add-Member -type NoteProperty -name SafeSender -value $Null
        }

        if ($ADUser.msExchSafeRecipientsHash.Length -gt 0)
        {
            $SafeRecipient = [System.BitConverter]::ToString($ADUser.msExchSafeRecipientsHash)
            $SafeRecipient = $SafeRecipient.Replace("-","")
            $object | Add-Member -type NoteProperty -name SafeRecipient -value $SafeRecipient
        }
        else
        {
            $object | Add-Member -type NoteProperty -name SafeRecipient -value $Null
        }

        if ($ADUser.msExchBlockedSendersHash.Length -gt 0)
        {
            $BlockedSender = [System.BitConverter]::ToString($ADUser.msExchBlockedSendersHash)
            $BlockedSender = $BlockedSender.Replace("-","")
            $object | Add-Member -type NoteProperty -name BlockedSender -value $BlockedSender
        }
        else
        {
            $object | Add-Member -type NoteProperty -name BlockedSender -value $Null
        }

        # Add dumped values to ArrayList
        # 'til the iterator is finished.
        [void]$outArray.Add($object)

    }

    # region export CSV
    if ($outArray.Count -gt 0)
    {
        Write-PSFMessage -Level Output -Message "Saving CSV on $($outFile)"
        $outArray | Export-CSV $outFile -NoTypeInformation
    }
    if ($AuxMessage)
    {
        Write-PSFMessage -Level Output -Message "Saving TXT on $($AUXFile)"
    }
    
    # region clean up variables and sessions
    Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
    Get-PSSession | Remove-PSSession
    Remove-Variable * -ErrorAction SilentlyContinue

}