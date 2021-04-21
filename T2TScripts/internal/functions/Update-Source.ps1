Function Update-Source {
    <#
    .SYNOPSIS
        Function to convert RemoteMailbox to MailUser
        and update the targetAddress to destination.

    .DESCRIPTION
        This function is called by Update-T2TPostMigration function through
        -Source param. Basically we need to save a bunch of Exchange attributes
        before the convertion, as there is no easy way to do that in a supported
        we must disable the remotemailbox and enable the MEU, but doing so all
        Exchange attributes will be deleted so the function needs to re-assign.

    .EXAMPLE
        PS C:\> Update-Source
        The following example run this function.
    #>

    # region local variables
    $MigratedUsersImportCheck = Get-CSVStatus -UsersMigrated
    if ( $MigratedUsersImportCheck -eq 0 ) { Break }
    $UsersCount = ($updatelist | Measure-Object).count
    [int]$counter = 0
    $Properties = @(
        'extensionAttribute1'
        'extensionAttribute2'
        'extensionAttribute3'
        'extensionAttribute4'
        'extensionAttribute5'
        'extensionAttribute6'
        'extensionAttribute7'
        'extensionAttribute8'
        'extensionAttribute9'
        'extensionAttribute10'
        'extensionAttribute11'
        'extensionAttribute12'
        'extensionAttribute13'
        'extensionAttribute14'
        'extensionAttribute15'
    )
    
    
    # region loop each user
    foreach ( $i in $updatelist ) {

        $counter++
        Write-Progress -Activity "Converting RemoteMailbox to MEU and changing ExternalEmailAddress" -Status "Working on $($i.ExternalEmailAddress)" -PercentComplete ( $counter * 100 / $UsersCount )

        if ( $i.MoveRequestStatus -eq 'Completed' ) {

            # save user properties to variable before disable remote mailbox
            try
            {
                $user = Get-RemoteMailbox -Identity $i.Alias -ErrorAction Stop
                if ( $LocalMachineIsNotExchange.IsPresent -and $LocalAD -eq '' ) {

                    $aduser = Get-RemoteADUser $i.Alias -Properties * | Select-Object -Property $Properties -ErrorAction Stop

                } else {

                    $aduser = Get-ADUser $i.Alias -Properties * | Select-Object -Property $Properties -ErrorAction Stop

                }
            }
            catch
            {
                Write-PSFMessage  -Level Output -Message "The RemoteMailbox $($i.PrimarySMTPAddress) was not found."
            }


            # disable remote mailbox
            if ( $user ) {
                
                Disable-RemoteMailbox -Identity $i.Alias -Confirm:$false
                if ( $? ) {
                    
                    Write-PSFMessage  -Level Output -Message "RemoteMailbox $($i.PrimarySMTPAddress) successfully converted to MailUser."

                    # if -UsePrimarySMTPAsTargetAddress is preset,
                    # honor it, otherwise set MOERA as targetAddress
                    if ( $UsePrimarySMTPAsTargetAddress.IsPresent ) {

                        Enable-MailUser -Identity $i.Alias -ExternalEmailAddress $i.PrimarySMTPAddress | Out-Null

                    } else {

                        Enable-MailUser -Identity $i.Alias -ExternalEmailAddress $i.ExternalEmailAddress | Out-Null

                    }

                    # convert legacyDN to X500 and set proxyAddresses
                    $x500 = "x500:" + $user.legacyExchangeDN
                    $proxy = $user.EmailAddresses
                    $ProxyArray = @()
                    $ProxyArray = $Proxy -split ","
                    $ProxyArray = $ProxyArray + $x500
                    Set-MailUser -Identity $i.Alias -EmailAddresses @{ Add = $ProxyArray } -HiddenFromAddressListsEnabled $user.HiddenFromAddressListsEnabled

                    # if there were custom attribues before, re-add them
                    $Replace = @{}
                    foreach ( $element in $Properties ) {
                        if ( $aduser.$element ) {
                            $Replace.Add( $element, $aduser.$element )
                            }
                        }
                    if ( $Replace ) { Set-ADUser -Identity $i.Alias -Replace $Replace }
                }
            }
        }
    }

    # region clean up variables and sessions
    Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
    Get-PSSession | Remove-PSSession
    Remove-Variable * -ErrorAction SilentlyContinue

}