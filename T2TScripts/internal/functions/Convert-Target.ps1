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
        ForEach ($i in $MEU)
        {
            Write-Progress -Activity "Verifying move request status" -Status "Verifying user $($i)"

            # define variables
            $MoveRequest = $Null
            $object = [ordered]@{}

            # Get the move request. If it doesn't exist, set MoveRequestStatus as NotFound
            try
            {
                $MoveRequest = (Get-EXMoveRequest -Identity $i -ErrorAction Stop).Status
            }
            catch
            {
                Write-PSFMessage  -Level Output -Message "MoveRequestNotExist: No move request for the user $($i) was found."
                [void]$object.Add("ExternalEmailAddress",$i)
                [void]$object.Add("PrimarySMTPAddress",$Null)
                [void]$object.Add("Alias",$Null)
                [void]$object.Add("MoveRequestStatus","MoveRequestNotExist")
                $BreakLoop.Remove($i)
            }
            finally
            {
                if ($MoveRequest -like "Completed*")
                {
                    # We must resolve the Alias because ExternalEmailAddress isn't a valid
                    # identity. We also need resolve the PrimarySMTPAddress cause it might
                    # be used in Convert-Source if "-UseMOERATargetAddress" is not present
                    try
                    {
                        $user = Get-MailUser -identity $i -ErrorAction Stop
                        if ($?)
                        {
                            [void]$object.Add("ExternalEmailAddress",$i)
                            [void]$object.Add("PrimarySMTPAddress",$user.PrimarySMTPAddress)
                            [void]$object.Add("Alias",$user.Alias)
                            $Null = Enable-RemoteMailbox -identity $user.Alias -RemoteRoutingAddress $i -ErrorAction Stop
                            if ($?)
                            {
                                Write-PSFMessage  -Level Output -Message "Converted MailUser $($i) to RemoteMailbox and changed ExternalEmailAddress successfully."
                                [void]$object.Add("MoveRequestStatus","Completed")
                                $BreakLoop.Remove($i)
                            }
                        }
                    }
                    catch
                    {
                        if (Get-RemoteMailbox -Identity $user.Alias)
                        {
                            Write-PSFMessage -Level Output -Message "AlreadyRemoteMailbox: User $($i) was not converted to RemoteMailbox because the object type is already RemoteMailbox."
                            [void]$object.Add("ExternalEmailAddress",$i)
                            [void]$object.Add("PrimarySMTPAddress",$Null)
                            [void]$object.Add("Alias",$Null)
                            [void]$object.Add("MoveRequestStatus","IsAlreadyRemoteMailbox")
                            $BreakLoop.Remove($i)
                        }
                        else
                        {
                            Write-PSFMessage -Level Output -Message "MEUNotFound: The MailUser $($i) was not found."
                            [void]$object.Add("ExternalEmailAddress",$i)
                            [void]$object.Add("PrimarySMTPAddress",$Null)
                            [void]$object.Add("Alias",$Null)
                            [void]$object.Add("MoveRequestStatus","MEUNotFound")
                            $BreakLoop.Remove($i)
                        }
                    }
                }

                if ($MoveRequest -like "Failed")
                {
                    Write-PSFMessage  -Level Output -Message "MoveRequestFailed: The $($i) move request was failed"
                    [void]$object.Add("ExternalEmailAddress",$i)
                    [void]$object.Add("PrimarySMTPAddress",$Null)
                    [void]$object.Add("Alias",$Null)
                    [void]$object.Add("MoveRequestStatus","MoveRequestFailed")
                    $BreakLoop.Remove($i)
                }
            }
            
            # add object to array only if there is MoveRequestStatus
            # to avoid empty lines while the move does not finished.
            if ($object.MoveRequestStatus)
            {
                $outPSObject = New-Object -TypeName PSObject -Property $object
                [void]$outArray.Add($outPSObject)
            }
        }

        # Remove from $MEU array any object that has MoveRequestStatus value.
        # it means that the object should not go through the iteration anymore
        ForEach ($element in $outArray)
        {
            if ($element.MoveRequestStatus)
            {
                $MEU.Remove($element.ExternalEmailAddress)
            }
        }
    }

    # region export to a CSV
    Write-PSFMessage -Level Output -Message "Saving CSV on $($outfile)"
    try
    {
        $outArray | Export-CSV $outfile -NoTypeInformation -ErrorAction Stop
    }
    catch
    {
        Write-PSFMessage -Level Output -Message "The path $($outfile) could not be found. The file will be saved on $($home)\desktop\MigratedUsers.csv"
        $outArray | Export-CSV "$home\desktop\MigratedUsers.csv" -NoTypeInformation
    }

    # region clean up variables and sessions
    Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
    Get-PSSession | Remove-PSSession
    Remove-Variable * -ErrorAction SilentlyContinue

}