Function Convert-Source {
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
        PS C:\> Convert-Source
        The following example run this function.
    #>
    
    # region local variables
    $MigratedUsersImportCheck = Get-CSVStatus -UsersMigrated
    if ($MigratedUsersImportCheck -eq 0) {Break}
    if ($SnapshotPath) {$outFile = "$SnapshotPath"}
    else {$outFile = "$home\desktop\"}
    [int]$UsersCount = ($updatelist | Measure-Object).count
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
    foreach ($i in $updatelist)
    {

        $counter++
        Write-Progress -Activity "Converting RemoteMailbox to MEU and changing ExternalEmailAddress" -Status "Working on $($i.ExternalEmailAddress)" -PercentComplete ($counter * 100 / $UsersCount)

        if ($i.MoveRequestStatus -eq 'Completed')
        {

            # save user properties to $user variable before disable remote mailbox
            try
            {
                if ($SnapshotToXML.IsPresent)
                {
                    $user = Get-RemoteMailbox -Identity $i.Alias -ErrorAction Stop
                    if ($?)
                    {
                        $user | Export-Clixml -Path "$outFile\$($i.Alias).xml" -Force -Confirm:$false
                    }
                }
                else
                {
                    $user = Get-RemoteMailbox -Identity $i.Alias -ErrorAction Stop
                }

                # save custom attributes to $aduser variable
                if ($LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
                {
                    $aduser = Get-RemoteADUser $i.Alias -Server $PreferredDC -Properties $Properties -ErrorAction Stop
                }
                else
                {
                    $aduser = Get-ADUser $i.Alias -Server $PreferredDC -Properties $Properties -ErrorAction Stop
                }
            }
            catch
            {
                Write-PSFMessage  -Level Output -Message "The RemoteMailbox $($i.PrimarySMTPAddress) was not found."
            }

            # disable remote mailbox
            if ($user)
            {
                Disable-RemoteMailbox -Identity $i.Alias -IgnoreLegalHold -Confirm:$false
                if ($?)
                {
                    Write-PSFMessage  -Level Output -Message "RemoteMailbox $($i.PrimarySMTPAddress) successfully converted to MailUser."

                    # if both -UseMOERATargetAddress and -KeepOldPrimarySMTPAddress are present, object should be like this:
                    # PrimarySMTPAddress: bill@source.com
                    # ExternalEmailAddress: bill@destination.mail.onmicrosoft.com
                    if ($UseMOERATargetAddress.IsPresent -and $KeepOldPrimarySMTPAddress.IsPresent)
                    {
                        [void](Enable-MailUser -Identity $i.Alias -ExternalEmailAddress $i.ExternalEmailAddress -PrimarySMTPAddress $user.PrimarySmtpAddress)
                    }
                    # if -UseMOERATargetAddress is preset, object should be like this:
                    # PrimarySMTPAddress: bill@destination.mail.onmicrosoft.com
                    # ExternalEmailAddress: bill@destination.mail.onmicrosoft.com
                    elseif ($UseMOERATargetAddress.IsPresent)
                    {
                        [void](Enable-MailUser -Identity $i.Alias -ExternalEmailAddress $i.ExternalEmailAddress)
                    }
                    # if -KeepOldPrimarySMTPAddress is preset, object should be like this:
                    # PrimarySMTPAddress: bill@source.com
                    # ExternalEmailAddress: bill@destination.com
                    elseif ($KeepOldPrimarySMTPAddress.IsPresent)
                    {
                        [void](Enable-MailUser -Identity $i.Alias -ExternalEmailAddress $i.PrimarySMTPAddress -PrimarySMTPAddress $user.PrimarySmtpAddress)
                    }
                    # everything else should be like this:
                    # PrimarySMTPAddress: bill@destination.com
                    # ExternalEmailAddress: bill@destination.com
                    else
                    {
                        [void](Enable-MailUser -Identity $i.Alias -ExternalEmailAddress $i.PrimarySMTPAddress)
                    }

                    # convert legacyDN to X500 and set proxyAddresses
                    $x500 = "x500:" + $user.legacyExchangeDN
                    $proxy = $user.EmailAddresses
                    $ProxyArray = @()
                    $ProxyArray = $Proxy -split "," -replace "SMTP:","smtp:"
                    $ProxyArray = $ProxyArray + $x500
                    Set-MailUser -Identity $i.Alias -EmailAddresses @{Add=$ProxyArray} -HiddenFromAddressListsEnabled $user.HiddenFromAddressListsEnabled

                    # if there were custom attribues before, readd 'em all
                    $Replace = @{}
                    foreach ($element in $Properties)
                    {
                        if ($aduser.$element)
                        {
                            $Replace.Add($element,$aduser.$element)
                        }
                    }
                    # replace only if there is a Custom Attribute being used
                    if ($Replace.Count -gt 0 -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
                    {
                        Set-RemoteADUser -Identity $i.Alias -Server $PreferredDC -Replace $Replace
                    }
                    elseif ($Replace.Count -gt 0)
                    {
                        Set-ADUser -Identity $i.Alias -Server $PreferredDC -Replace $Replace
                    }
                }
            }
        }
    }

    # region clean up variables and sessions
    Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
    Get-PSSession | Remove-PSSession
    Remove-Variable * -ErrorAction SilentlyContinue

}