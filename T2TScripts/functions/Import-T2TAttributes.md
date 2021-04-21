# Import-T2TAttributes

The **Import-T2TAttributes** is the second function that should be used in the cross-tenant migration process. This function creates the MailUser and eventually contacts in the target environment based on the UserListToImport.csv.


## Requirements

- The function will ask you to stop Azure AD Connect sync cycle before the execution. You can leave the function to stoping it for you as long as you provide the Azure AD Connect machine hostname, or you can stop yourself before the script execution.

- Once the function finishes, you can validate that the MEU objects were successfully created and manually re-enable the Azure AD Connect sync sycle using the following cmdled: `Set-ADSyncScheduler -SyncCycleEnabled 1`

- All MEU objects will be created using the UPN suffix that you passed through `-UPNSuffix` parameter. If you need to create MEUs with different UPN suffix, you should segment the MEU creation based on the UPN suffix, it means run the function for each UPN suffix.

- Depending on the current powershell execution policy state, it could require to be set as Unrestricted.

- You need Active Directory and Exchange Server On-Premises. In other words, the function was not developed to work in Azure AD cloud-only scenarios or with AD On-Premises in hybrid but with no Exchange On-Premises. 

- You can run the functions from an Exchange Server machine or from any other domain-joined machine as long as you set `-LocalMachineIsNotExchange` switch and the `-ExchangeHostname` parameter with Exchange Server hostname.

- If you run the functions from an Exchange Server machine, the functons will leverage the local AD module present on Exchange. Otherwise, the functions will export a PSSession from the Domain Controller which your PC is authenticated.

- The Exchange and AD PSSession are authenticated through Kerberos relying on the credential used on the Windows sign-in. Thus, be sure to sign-in using AD and Exchange admin credential.


## Parameters

| Parameter | Value | Required or Optional
|-----------------------------------------|-------------------------|---------------|
| UPNSuffix                               | UPN domain for the new MEU objects e.g: contoso.com  | Required |
| Password                                | Choose a password for all new MEU objects. If no password is chosen, the function will define '?r4mdon-_p@ss0rd!' as password. | Optional |
| ResetPassword                           | Switch to require password change on next logon. | Optional |
| OU                                      | Create MEU objects in a specific Organization Unit. Valid values are name, CN, DN or GUID. If not defined, the MEU object will be created on Users container. | Optional |
| OUContacts                              | Create Mail Contact objects in a specific Organization Unit. Valid values are name, CN, DN or GUID. If not defined, the contacts will be created on Users container. | Optional |
| UserListToImport                        | Custom output path to import the UserListToImport.csv. if no value is defined the function will try to get it from the Desktop. | Optional |
| ContactListToImport                     | Custom output path to import the ContactListToImport.csv. if no value is defined the function will try to get it from the Desktop. | Optional |
| LocalMachineIsNotExchange               | Switch to be used when the function is executed from a non-Exchange Server machine. | Optional |
| ExchangeHostname                        | Exchange server hostname that the function will connect to. | Required¹ |
||||

¹ *Required only if `-LocalMachineIsNotExchange` is used.*

## Examples

Example: Running from an Exchange Server
```Powershell
PS C:\> Import-T2TAttributes -UPNSuffix fabrikam.com -Password "P@$$w04d_Fabr!karn" -ResetPassword -OU "Fabrikam-Users" -OUContacts "Fabrikam-Contacts"
```
