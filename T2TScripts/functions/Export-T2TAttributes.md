﻿# Export-T2TAttributes

This is the first function that should be used in the cross-tenant migration process. This function will dump all necessary attributes from the source environment to a CSV called UserListToImport.csv.


## Requirement

- You must fill a custom attribute field with some value by your preference in order to be used by the function as a filter to get only mailboxes that have the custom attribute and value filled by you. This will provide more security once the function will not get anything else than you want to.

- You must fill a CSV that maps which souce domain will become which target domain. Start the first line as *source,target* and then map each source domain for each target domain, including `mail.onmicrosoft.com` e.g:

    ```DomainMapping.csv
    source,target
    fabrikam.com,contoso.com
    fabrikam.mail.onmicrosoft.com,contoso.mail.onmicrosoft.com
    source1.com,target1.com
    sub.source.com,sub.target.com
    ```
    Note: Any domain which is not included in the CSV domain mapping file will not be converted. Thus, be sure that you are covering all yours accepted domains.

- The function will connect to the Exchange Online using v2 module. If you don't have it installed, this module will install it for you as long as the PC may reach the PowerShell gallery.

- Depending on the current powershell execution policy state, it could require to be set as Unrestricted.

- You need Active Directory and Exchange Server On-Premises. In other words, the function was not developed to work in Azure AD cloud-only scenarios or with AD On-Premises in hybrid but with no Exchange On-Premises. 

- You can run the functions from an Exchange Server machine or from any other domain-joined machine as long as you set `-LocalMachineIsNotExchange` switch and the `-ExchangeHostname` parameter with Exchange Server hostname.

- If you run the functions from an Exchange Server machine, the functons will leverage the local AD module present on Exchange. Otherwise, the functions will export a PSSession from the Domain Controller which your PC is authenticated.

- The Exchange and AD PSSession are authenticated through Kerberos relying on the credential used on the Windows sign-in. Thus, be sure to sign-in using AD and Exchange admin credential.


## Parameters

| Parameter | Value | Required or Optional
|-----------------------------------------|-------------------------|---------------|
| AdminUPN                                | Exchange Online administrator UPN. | Required |
| CustomAttributeNumber                   | Exchange Custom Attribute number (1-15) where the function will use to filter. | Required |
| CustomAttributeValue                    | Exchange Custom Attribute value where the function will use to filter. | Required |
| DomainMappingCSV                        | Enter the CSV path which you mapped the source and target domains. | Required |
| IncludeContacts                         | Switch to get mail contacts. Mail contact dump also relies on the Custom Attibute filter. | Optional |
| IncludeSIP                              | Switch to get SIP values from proxyAddresses. If not used the function returns only SMTP and X500. | Optional |
| IncludeGeneral                          | Switch to dump the following values: description, physicalDeliveryOfficeName, wWWHomePage and url. | Optional |
| IncludeAddress                          | Switch to get values from Address AD tab. The list of attributes is avaiable in the [Common RemoteMailbox and Contact attributes](https://github.com/SignorelliDenis/T2TScripts/blob/main/T2TScripts/functions/Export-T2TAttributes.md#common-remotemailbox-and-contact-attributes) | Optional |
| IncludePhones                           | Switch to get all AD phone attributes. The list of attributes is avaiable in the [Common RemoteMailbox and Contact attributes](https://github.com/SignorelliDenis/T2TScripts/blob/main/T2TScripts/functions/Export-T2TAttributes.md#common-remotemailbox-and-contact-attributes) | Optional |
| IncludeOrganization                     | Switch to get values from the AD Organization tab. The list of attributes is avaiable in the [Common RemoteMailbox and Contact attributes](https://github.com/SignorelliDenis/T2TScripts/blob/main/T2TScripts/functions/Export-T2TAttributes.md#common-remotemailbox-and-contact-attributes) | Optional |
| IncludeCustomAttributes                 | Switch to get custom attribute values. The list of attributes is avaiable in the [Common RemoteMailbox and Contact attributes](https://github.com/SignorelliDenis/T2TScripts/blob/main/T2TScripts/functions/Export-T2TAttributes.md#common-remotemailbox-and-contact-attributes) | Optional |
| IncludeManager                          | Switch to get values from Manager attribute. Be sure to scope users and managers if this switch will be used. | Optional |
| BypassAutoExpandingArchiveCheck         | Switch to bypass the check if there are Auto-Expanding¹ archive mailboxes. If not used the function will perform the check and this can increase the duration time. | Optional |
| LocalMachineIsNotExchange               | Switch to be used when the function is executed from a non-Exchange Server machine. | Optional |
| ExchangeHostname                        | Exchange server hostname that the function will connect to. | Required² |
| PreferredDC                             | Domain Controller FQDN. Use this parameter to avoid replication issues in environments with too many DCs or to avoid multiple domains issues. | Optional |
| FolderPath                              | Custom output path for the csv. if no value is defined it will be saved as **UserListToImport.csv** on Desktop. | Optional |
||||


¹ *The Auto-Expanding archive is verified because MRS does not support move mailbox of auxiliar archive mailbox. You can see the [official article for more details](https://docs.microsoft.com/en-us/microsoft-365/enterprise/cross-tenant-mailbox-migration?view=o365-worldwide#known-issues). The function will dump all mailboxes that have auxiliar Auto-Expanding archive mailbox to a TXT file. Be aware that this check might increase the function duration.*

² *Required only if `-LocalMachineIsNotExchange` is used.*

## Examples

Running from a non-Exchange Server filtering mailboxes by the custom attribute 1 with value "T2T", including the SIP values and connecting to a specific domain controller:
```Powershell
PS C:\> Export-T2TAttributes -AdminUPN admin@contoso.com -CustomAttributeNumber 1 -CustomAttributeValue T2T -DomainMappingCSV "C:\sourcetarget.csv" -IncludeSIP -LocalMachineIsNotExchange -ExchangeHostname ExchHostname -PreferredDC DC01.contoso.com
```

Running from an Exchange Server filtering mailboxes by the custom attribute 5 with value "Move", including the manager attribute and the contacts:
```Powershell
PS C:\> Export-T2TAttributes -AdminUPN admin@contoso.com -CustomAttributeNumber 5 -CustomAttributeValue Move -DomainMappingCSV "C:\domainmapping.csv" -IncludeManager -IncludeContacts
```


## RemoteMailbox attributes

The **Export-T2TAttributes** will dump to a CSV the following RemoteMailbox properties:

- Alias
- ArchiveGuid
- DisplayName
- EmailAddresses
- ExchangeGuid
- ExternalEmailAddress ¹
- FirstName
- LastName
- legacyExchangeDN
- LitigationHoldEnabled ²
- MailboxLocations ³
- msExchBlockedSendersHash
- msExchSafeRecipientsHash
- msExchSafeSendersHash
- Name
- PrimarySMTPAddress
- SamAccountName
- SingleItemRecoveryEnabled ²

¹ *The ExternalEmailAddress is defined by the **mail.onmicrosoft.com** [(MOERA)](https://docs.microsoft.com/en-us/troubleshoot/azure/active-directory/proxyaddresses-attribute-populate#terminology) SMTP address found on the source user object proxyAddresses property. The function will convert the MOERA address according to the domain mapping CSV but only to the proxyAddresses property. The ExternalEmailAddress value remains the same.*

² *These properties are converted to a number which represents the ELC mailbox flag.*

³ *The function does not really dump the MailboxLocations attribute to the CSV but it dumps the Alias from any users that might have an Auto-Expanding archive mailbox to a TXT called AUXUser. Then you can use the AUXUser.txt to start the export PST using Content Search or eDiscovery and manually import these PST in the target tenant.*


## Contact attributes

If `-IncludeContacts` is used, **Export-T2TAttributes** will dump to a CSV the following contact AD properties:

- Alias
- DisplayName
- EmailAddresses
- ExternalEmailAddress ¹
- FirstName
- LastName
- legacyExchangeDN
- Name
- PrimarySMTPAddress

¹ *The ExternalEmailAddress is defined by the **mail.onmicrosoft.com** [(MOERA)](https://docs.microsoft.com/en-us/troubleshoot/azure/active-directory/proxyaddresses-attribute-populate#terminology) SMTP address found on the source user object proxyAddresses property. The function will convert the MOERA address according to the domain mapping CSV but only to the proxyAddresses property. The ExternalEmailAddress value remains the same.*


## Common RemoteMailbox and Contact attributes

The following properties will be dumped for RemoteMailbox and either Contact if `-IncludeContacts` is used:

**`-IncludeManager` parameter will dump the following AD property:**
- Manager

**`-IncludeGeneral` parameter will dump the following AD properties:**
- physicalDeliveryOfficeName
- wWWHomePage
- url
- description

**`-IncludeAddress` parameter will dump the following AD properties:**
- streetAddress
- postOfficeBox
- l
- postalCode
- c
- co
- countryCode
- st

**`-IncludePhones` parameter will dump the following AD properties:**
- telephoneNumber
- otherTelephone
- homePhone
- otherHomePhone
- pager
- otherPager
- mobile
- otherMobile
- facsimileTelephoneNumber
- otherFacsimileTelephoneNumber
- ipPhone
- otherIpPhone
- info

**`-IncludeOrganization` parameter will dump the following AD properties:**
- title
- department
- company

**`-IncludeCustomAttributes` parameter will dump the following AD property:**
- extensionAttribute1
- extensionAttribute2
- extensionAttribute3
- extensionAttribute4
- extensionAttribute5
- extensionAttribute6
- extensionAttribute7
- extensionAttribute8
- extensionAttribute9
- extensionAttribute10
- extensionAttribute11
- extensionAttribute12
- extensionAttribute13
- extensionAttribute14
- extensionAttribute15


## Tips

- Once the function is finished, have a look at *UserListToImport.csv* file to be sure that the function exported all necessary attributes.

- AD Property values which contain comma "," will be converted to a sequence of dashes "---" in the CSV. This happens to avoid issues with the CSV delimiter, but these values will be roll-backed to comma "," once they are imported.