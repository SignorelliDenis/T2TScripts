# Changelog

## 1.1.0 (2021-04-31)
- New: Include a new parameter to get vaule from manager attribute in Export-T2TScripts. From the Import-T2TScripts perspective, the function calls another internal function called Import-Manager to import the manager value attribute. 
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