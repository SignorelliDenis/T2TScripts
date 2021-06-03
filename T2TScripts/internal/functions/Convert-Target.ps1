Function Convert-Target {
    <#
    .SYNOPSIS
        Function to convert the targetAddress and
        object type from MailUser to RemoteMailbox

    .DESCRIPTION
        This function is called by Convert-T2TPostMigration
        function through the parameter -Destination

    .EXAMPLE
        PS C:\> Convert-Target
        The following example run this function.
    #>

    # region import CSV
    $UserListToImportCheck = Get-CSVStatus -User
    if ($UserListToImportCheck -eq 0) {Break}

    # region local variables
    if ($MigratedUsersOutputPath) {$outFile = "$MigratedUsersOutputPath\MigratedUsers.csv"}
    else {$outFile = "$home\desktop\MigratedUsers.csv"}
    [System.Collections.ArrayList]$outArray = @()
    [System.Collections.ArrayList]$MEU = @()
    [System.Collections.ArrayList]$BreakLoop = @()
    $MEU = @(($ImportUserList).ExternalEmailAddressPostMove)
    $BreakLoop = @(($ImportUserList).ExternalEmailAddressPostMove)

    # Loop until all move requests from the MigratedUsers.csv
    # are Completed, CompletedWithWarning or Failed
    while ($BreakLoop.Count -gt 0)
    {
        ForEach ( $i in $MEU )
        {
            Write-Progress -Activity "Verifying move request status" -Status "Verifying user $($i)"

            # Reset variables
            $MoveRequest = $Null
            $object = New-Object System.Object

            # Get the move request. If it doesn't exist, set MoveRequestStatus as NotFound
            try
            {
                $MoveRequest = (Get-EXMoveRequest -Identity $i -ErrorAction Stop).Status
            }
            catch
            {
                Write-PSFMessage  -Level Output -Message "MoveRequestNotExist: No move request for the user $($i) was found."
                $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $i
                $object | Add-Member -type NoteProperty -name MoveRequestStatus -value MoveRequestNotExist
                $object | Add-Member -type NoteProperty -name PrimarySMTPAddress -value $Null
                $object | Add-Member -type NoteProperty -name Alias -value $Null
                $BreakLoop.Remove($i)
            }
            finally
            {
                if ($MoveRequest -like "Completed*")
                {
                    # We must resolve the Alias because ExternalEmailAddress isn't a valid
                    # identity. We also need resolve the PrimarySMTPAddress cause it might
                    # be used in Convert-Source if "-UseMOERATargetAddress" is not present.
                    try
                    {
                        $user = Get-MailUser -identity $i -ErrorAction Stop
                        if ($?)
                        {
                            $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $i
                            $object | Add-Member -type NoteProperty -name PrimarySMTPAddress -value $user.PrimarySMTPAddress
                            $object | Add-Member -type NoteProperty -name Alias -value $user.Alias
                            Enable-RemoteMailbox -identity $user.Alias -RemoteRoutingAddress $i -ErrorAction Stop | Out-Null
                            if ($?)
                            {
                                Write-PSFMessage  -Level Output -Message "Converted MailUser $($i) to RemoteMailbox and changed ExternalEmailAddress successfully."
                                $object | Add-Member -type NoteProperty -name MoveRequestStatus -value Completed
                                $BreakLoop.Remove($i)
                            }
                        }
                    }
                    catch
                    {
                        if (Get-RemoteMailbox -Identity $user.Alias)
                        {
                            Write-PSFMessage  -Level Output -Message "AlreadyRemoteMailbox: User $($i) was not converted to RemoteMailbox because the object type is already RemoteMailbox."
                            $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $i
                            $object | Add-Member -type NoteProperty -name MoveRequestStatus -value IsAlreadyRemoteMailbox
                            $object | Add-Member -type NoteProperty -name PrimarySMTPAddress -value $Null
                            $object | Add-Member -type NoteProperty -name Alias -value $Null
                            $BreakLoop.Remove($i)
                        }
                        else
                        {
                            Write-PSFMessage  -Level Output -Message "MEUNotFound: The MailUser $($i) was not found."
                            $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $i
                            $object | Add-Member -type NoteProperty -name MoveRequestStatus -value MEUNotFound
                            $object | Add-Member -type NoteProperty -name PrimarySMTPAddress -value $Null
                            $object | Add-Member -type NoteProperty -name Alias -value $Null
                            $BreakLoop.Remove($i)
                        }
                    }
                }

                if ($MoveRequest -like "Failed")
                {
                    Write-PSFMessage  -Level Output -Message "MoveRequestFailed: The $($i) move request was failed"
                    $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $i
                    $object | Add-Member -type NoteProperty -name MoveRequestStatus -value MoveRequestFailed
                    $object | Add-Member -type NoteProperty -name PrimarySMTPAddress -value $Null
                    $object | Add-Member -type NoteProperty -name Alias -value $Null
                    $BreakLoop.Remove($i)
                }
            }
            
            # add object to array only if there is MoveRequestStatus
            # to avoid empty lines while the move does not finish
            if ($object.MoveRequestStatus)
            {
                [void]$outArray.Add($object)
            }
        }

        # Remove from the $MEU array all objects that have MoveRequestStatus value
        # it means that the object should not go through the foreach anymore.
        foreach ($element in $outArray)
        {
            if ($element.MoveRequestStatus)
            {
                $MEU.Remove($element.ExternalEmailAddress)
            }
        }
    }

    # region export to a CSV
    Write-PSFMessage -Level Output -Message "Saving CSV on $($outfile)"
    $outArray | Export-CSV $outfile -notypeinformation

    # region clean up variables and sessions
    Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
    Get-PSSession | Remove-PSSession
    Remove-Variable * -ErrorAction SilentlyContinue

}