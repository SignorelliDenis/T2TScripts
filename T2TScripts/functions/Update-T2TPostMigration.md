# Update-T2TPostMigration

The **Update-T2TPostMigration** function is intended to update all necessary attributes in the source and target environment once the migration batch is finished. The function is divided between two switch parameters called `-Source` and `-Destination`.

## Scenario

Before explaining how the function works, you should be familiar with what exactly happen when the MRS completes the cross tenant move. Consider that the user bill@fabrikam.com was migrated to bill@contoso.com:

- Source cloud MailUser: Once the move is completed, MRS converts the mailbox object to MailUser and add the MOERA domain bill@contoso.mail.onmicrosoft.com as ExternalEmailAddress.
- Target cloud Mailbox: MailUser is converted to Mailbox and MRS add the PrimarySMTAddress bill@contoso.com.
- Source On-Prem RemoteMailbox: Remains as RemoteMailbox object type, still pointing to the ExternalEmailAddress bill@fabrikam.com and doesn't update to the target MOERA domain bill@contoso.mail.onmicrosoft.com.
- Target On-Prem MailUser: Remains as MailUser object type and doesn't update the ExternalEmailAddress to bill@contoso.com and remains the old value pointing to the source MOERA domain bill@fabrikam.mail.onmicrosoft.com

Basically we have four issues in the post-migration: wrong ExternalEmailAddress and object type on both sides. If ExternalEmailAddress values are not updated once the migration is completed, this will cause email looping and free/busy issues if you have on-prem mailboxes. The **Update-T2TPostMigration** goal is exactly address these four issues as soon as the move request is finished.

## How it works

1 - Assuming that you start the migration batch avoiding the -AutoComplete switch, you should wait until all move requests reach the Synced state at 95%.

2 - When you run the Complete-MigrationBatch to complete the final sync, you should also run `Update-T2TPostMigration -Destination`.

3 - The function will monitoring in real-time as the move requests are finishing. For each completed move request, the function will switch ExternalEmailAddress to the destination and convert the target on-premises object from MailUser to RemoteMailbox.

4 - Once all move requests are Completed or Failed, the function will stop to monitor the migration batch and will generate a CSV file containing the final result of each user.

5 - Run the `Update-T2TPostMigration -Source` in the source environment in order to convert the completed move requests RemoteMailbox to MailUser and change the ExternalEmailAddress to the destination.

## Parameters

The function is divided in two patameter sets: *Destination* or *Source*. You cannot mix Destination and Source parameters. Refer to the following table to parameter description:

| Parameter | Use with source or destination | Description | Required or Optional
|----------------------------- |-------------|-------------------------|---------------|
| Destination                  | Destination | Switch to update the objects in the destination environment  | Required |
| AdminUPN                     | Destination | Exchange Online administrator UPN.  | Required |
| UserListToImport             | Destination | Custom path to import the UserListToImport.csv. If no value is defined the function will try to get it from the Desktop. | Optional |
| MigratedUsersOutputPath      | Destination | Custom output path to export the MigratedUsers.csv. If no value is defined the function will export in the Desktop. | Optional |
| Source                       | Source      | Switch to update the objects in the source environment. | Required |
| MigratedUsers                | Source      | Custom path to import the MigratedUsers.csv. If no value is defined the function will try to get it from the Desktop. | Required |
| UsePrimarySMTPAsTargetAddress| Source      | Switch to indicate that targetAddress (ExternalEmailAddress) will be the PrimarySMTPAddress. If not used, the default value is the MOERA domain | Optional |
| LocalMachineIsNotExchange    | Both        | Switch to be used when the function is executed from a non-Exchange Server machine. | Optional |
| ExchangeHostname             | Both        | Exchange server hostname that the function will connect to. | Optional |
|||||


## -Destination

- When the function is called using the -Destination parameter, you must provide the UserListToImport.csv in the desktop path or manually indicate the CSV path.

- The function relies on the CSV to get the move request status of each user. Thus, doesn't matter if you have old migration baches, the function will filter to get the status only from the UserListToImport.csv users. Besides, the function will not delete the migration batch once it's finished.

- Once all move requests are completed or failed, the function will generate a new CSV file called *MigratedUsers.csv*. The CSV contains the information of each user that was handled by the function. There are five possible events that could be generated for each user:
	- Completed: The migration batch is completed, the MailUser was converted to RemoteMailbox and the RemoteRoutingAddress was changed to the destination MOERA address.
	- MoveRequestFailed: The move request is failed and no other action was taken.
	- MoveRequestNotExist: There is no move request associated with the user and no other action was taken.
	- MEUNotFound: There is a move request for the user, but no MailUser object was found.
	- IsAlreadyRemoteMailbox: The user is already a RemoveMailbox, thus probably it has been already migrated.

The following flowchart describes how the function acts when using `-Destination`:

![Update-T2TPostMigration-Destination](https://user-images.githubusercontent.com/43185536/115460309-67468b00-a228-11eb-84c5-f5e7fab63eb6.png)


## -Source

- When the function is called using the -Source parameter, it will search by the MigratedUsers.csv on desktop or you can manually indicate the CSV path.

- The function relies on MigratedUsers.csv to get all users where the MoveRequestStatus is Completed. That's exactly the reason why the MigratedUsers.csv must be imported, because the -Source can only convert the RemoteMailbox and change the Update-T2TPostMigration if the move request was successfully concluded and the target objects are addressed.

- As there is not cmdlet to easily convert RemoteMailbox to MailUser, the RemoteMailbox should disable in order to enable the MailUser. Disabling the RemoteMailbox causes the removal of all Exchange attributes. The function will save the following attributes to be re-added once the object is converted:
	- CustomAttribute: All custom attributes that have values
	- EmailAddresses: All proxyAddresses values
	- HiddenFromAddressListsEnabled: If it was hidden or not on GAL
	- legacyExchangeDN: Add as X500 into the EmailAddresses because a new legacyDN will be generated

- If the `-UsePrimarySMTPAsTargetAddress` is used, the source on-prem object will have the ExternalEmailAddress set as PrimarySMTPAddress, for example bill@contoso.com. If not used, it will be the MOERA domain such as bill@mail.contoso.onmicrosoft.com. The goal of this parameter is to force messages from source to destination to follow the destination MX record avoiding the MOERA MX record which points to Office 365, in other words in a scenario where the target MX recort point to On-Prem. This can also be achieved by a Send Connector (On-Prem) and Outbound Connector (EXO) using smart host.

The following flowchart describes how the function acts when using `-Source`:

![Update-T2TPostMigration-Source](https://user-images.githubusercontent.com/43185536/115555908-593c4d00-a2b0-11eb-9189-faa8a6619610.png)