Function Import-Manager {
    <#
    .SYNOPSIS
        Import Manager Attribute
    
    .DESCRIPTION
        Function called by Import-T2TAttributes if we found the Manager property on the UserListToImport.csv and/or ContactsListToImport.csv
    
    .PARAMETER ObjType
        Type of object that the function will work, valid values are MEU or Contact
    
    .EXAMPLE
        PS C:\> Import-Manager -ObjType MEU, Contacts
        Import the manager attribute valies from from the UserListToImport.csv and ContactsListToImport.csv
    #>

    [CmdletBinding()]
    param (
    [ValidateSet('MEU','Contact')]
    [String]$ObjType
    )

    Switch ( $ObjType ) {

        MEU {

            Write-PSFMessage -Level Output -Message  "Starting Manager attribute import"
    
            [int]$counter = 0
            $ManagerCount = ($ImportUserList | Measure-Object).count
            foreach ( $i in $ImportUserList ) {

                $counter++
                Write-Progress -Activity "Importing Manager Attribute" -Status "Working on $($i.DisplayName)" -PercentComplete ($counter * 100 / $ManagerCount )

                if ( $LocalMachineIsNotExchange.IsPresent -and $i.Manager ) {

                    Try
                    {

                        Set-RemoteADUser -Identity $i.SamAccountName -Manager $i.Manager -ErrorAction Stop

                    }
                    catch
                    {

                        Write-PSFMessage -Level Output -Message "Failed to add the user's $($i.DisplayName) manager attribute"

                    }
                }
                elseif ( $i.Manager ) {

                    Try
                    {

                        Set-ADUser -Identity $i.SamAccountName -Manager $i.Manager -ErrorAction Stop

                    }
                    catch
                    {

                        Write-PSFMessage -Level Output -Message "Failed to add the user's $($i.DisplayName) manager attribute"

                    }
                }
            }
        }

        Contact {

            Write-PSFMessage -Level Output -Message  "MailContacts - Starting manager attribute import"
    
            [int]$counter = 0
            $ManagerCount = ($ImportContactList | Measure-Object).count
            foreach ( $i in $ImportContactList ) {

                $counter++
                Write-Progress -Activity "MailContacts - Importing Manager Attribute" -Status "Working on $($i.DisplayName)" -PercentComplete ($counter * 100 / $ManagerCount )

                Try
                {

                    Set-Contact -Identity $i.Alias -Manager $i.Manager -ErrorAction Stop

                }
                catch
                {

                    Write-PSFMessage -Level Output -Message "MailContacts - Failed to add the user's $($i.DisplayName) manager attribute"

                }
            }
        }
    }
}