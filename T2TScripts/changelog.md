﻿# Changelog

## 2.1.7 (2021-07-24)
- Fix: [[Import-T2TAttributes] Splatting New-MailUser cmdlet](https://github.com/SignorelliDenis/T2TScripts/issues/68)
- Fix: [[Move-Contacts] Splatting New-MailContact cmdlet](https://github.com/SignorelliDenis/T2TScripts/issues/69)


## 2.1.6 (2021-07-18)
- Fix: [Export-T2TAttributes.md] Documentation improvement
- Fix: [Export-T2TAttributes.ps1] Code adjustment to reduce few unnecessary lines


## 2.1.5 (2021-07-05)
- New: [[Export-ADPersonalAttribute] - Provide all custom attributes dump through -IncludeCustomAttributes](https://github.com/SignorelliDenis/T2TScripts/issues/63)
- Fix: [Functions which export CSV must export using try/catch](https://github.com/SignorelliDenis/T2TScripts/issues/64)
- Fix: [[Export-T2TAttributes] - Improve how we get ADUser properties](https://github.com/SignorelliDenis/T2TScripts/issues/62)
- Fix: [Performance improvement](https://github.com/SignorelliDenis/T2TScripts/issues/61)

## 2.1.4 (2021-06-04)
- New: Implementation of new parameters and properties option to dump
- Fix: [[Export-T2TAttributes] UserListToImport.csv being exported even if no RemoteMailbox was found](https://github.com/SignorelliDenis/T2TScripts/issues/59)
- Fix: [[Move-Contact] ContactListToImport.csv being saved even if no contact was found](https://github.com/SignorelliDenis/T2TScripts/issues/58)
- Fix: [Functions performance improvement v2.1.4](https://github.com/SignorelliDenis/T2TScripts/issues/56)
- Fix: [[Convert-Source] Exchange can't disable the mail user "contoso.local/Users/User1" because it is on litigation hold](https://github.com/SignorelliDenis/T2TScripts/issues/55)
- Fix: [[Update-T2TPostMigration] Param -MigratedUsersOutputPath not being honored](https://github.com/SignorelliDenis/T2TScripts/issues/54)

## 2.0.3 (2021-05-16)
- New: [[Update-T2TPostMigration] Add a new param called -KeepPrimarySMTPAddress](https://github.com/SignorelliDenis/T2TScripts/issues/49)
- New: [[Update-T2TPostMigration] Add a new param called -UseMOERATargetAddress](https://github.com/SignorelliDenis/T2TScripts/issues/51)
- Fix: [[Update-Source] Missing $PreferredDC on Set-ADUser cmdlet](https://github.com/SignorelliDenis/T2TScripts/issues/48)
- Fix: [[Update-Source] Set-ADUser : Cannot validate argument on parameter 'Replace'. The argument is null, empty, or an element of the argument collection contains a null value](https://github.com/SignorelliDenis/T2TScripts/issues/50)

## 2.0.2 (2021-05-03)
- New: [[Update-Source] Save a "snapshot" of RemoteMailbox properties before convert to MEU](https://github.com/SignorelliDenis/T2TScripts/issues/46)
- Fix: [[Update-Source] ExchangeGuid and ArchiveGuid is not being re-added](https://github.com/SignorelliDenis/T2TScripts/issues/45)
- Fix: [Change not propagated across domain controller](https://github.com/SignorelliDenis/T2TScripts/issues/44)
- Fix: [User not found in multiple domains scenario](https://github.com/SignorelliDenis/T2TScripts/issues/43)

## 2.0.1 (2021-04-25)
- Fix: [[Update-Target] Cannot convert the "" value of type "System.String" to type "System.Collections.ArrayList"](https://github.com/SignorelliDenis/T2TScripts/issues/41)
- Update: [Update-T2TPostMigration] Documentation Improvement

## 2.0.0 (2021-04-20)
- New: [Function to handle the post-migration called Update-T2TPostMigration](/T2TScripts/functions/Update-T2TPostMigration.md)
- Fix: [v2.0.0 Update-T2TPostMigration -Destination Image](https://github.com/SignorelliDenis/T2TScripts/issues/36)
- Fix: [v2.0.0 Update-T2TPostMigration-Source.png Image](https://github.com/SignorelliDenis/T2TScripts/issues/37)
- Fix: [v2.0.0 Timeline Image](https://github.com/SignorelliDenis/T2TScripts/issues/35)
- Fix: [[Import-T2TAttributes] - New-MailUser : ExternalEmailAddress has an invalid value](https://github.com/SignorelliDenis/T2TScripts/issues/34)

## 1.2.1 (2021-04-08)
- Fix: [MigrationPermanentException: The target mailbox doesn't have an SMTP proxy matching '.mail.onmicrosoft.com'](https://github.com/SignorelliDenis/T2TScripts/issues/30)
- Update: [Export-T2TAttributes] Dump the RemoteRecipientType property. This property might be user further.

## 1.2.0 (2021-04-06)
- New: Include a new parameter to dump mail contacts called -IncludeContacts. A function called Move-Contacts was created to handle the export and import of mail contacts.
- Fix: [[README.md] Wrong parameter: OrganizationalInit](https://github.com/SignorelliDenis/T2TScripts/issues/27)
- Fix: [[Export-T2TAttributes] Remove ADObjectId class check](https://github.com/SignorelliDenis/T2TScripts/issues/26)
- Fix: [[Import-T2TAttributes] Rename -FilePath to -UserListToImport](https://github.com/SignorelliDenis/T2TScripts/issues/24)
- Update: [[Export-T2TAttributes] PrimarySMTPAddress is defined by UPN](https://github.com/SignorelliDenis/T2TScripts/issues/25)
- Update: [Move UserListToImport.csv Import CSV to a new function](https://github.com/SignorelliDenis/T2TScripts/issues/23)
- Update: [Import-CSV : Could not find file 'C:\...\UserListToImport.csv'](https://github.com/SignorelliDenis/T2TScripts/issues/22)

## 1.1.0 (2021-03-31)
- New: Include a new parameter to get value from manager attribute in Export-T2TScripts. From the Import-T2TScripts perspective, the function calls another internal function called Import-Manager to import the manager attribute value.
- Fix: [Running Export-T2TAttributes from a non-Exchange is not dumping proxyAddresses](https://github.com/SignorelliDenis/T2TScripts/issues/19)
- Fix: [Export-T2TAttributes - Get-RemoteADUser is not recognized as a cmdlet](https://github.com/SignorelliDenis/T2TScripts/issues/18)

## 1.0.9 (2021-03-19)
- New: Include a new parameter to get SIP addresses from the proxyAddresses property (Export-T2TScripts).
- Update: Changing export logic, to export all proxy addresses to lower-case.
- Fix: Fix import Write-Progress logic to not break and divide by zero (Import-T2TScripts).

## 1.0.8 (2021-03-11)
- Update: Get only SMTP and X500 values from the source proxyAddresses object. Other values such as EUM and X400 might break the query and are useless.
- Fix: The AUXFile output message was showing even if no AUXFile was created. Added an if condition to show the message only if the AUXFile really exist.

## 1.0.7 (2021-02-23)
 - Update: Just updated cosmetic addition to readme files, adding Export-T2Tlogs examples.
 - New: Added 'Version History' at the bottom of readme files.

## 1.0.6 (2021-02-22)
 - Update: Updated Export-T2Tlogs function splitting timestamp column, into indivual 'Date' and 'Time' columns. This is better for filtering and parsing.
 - New: start tracking changes in changelog.md file in the repository.

## 1.0.5 (2021-02-21)
 - Fix: Readme spelling and some paragraphs.
 - Update: Update LocalAD logic in both Export and Import functions.
 - Update: Some variables names and default values.

## 1.0.0 (2021-02-18)
 - New: First Release