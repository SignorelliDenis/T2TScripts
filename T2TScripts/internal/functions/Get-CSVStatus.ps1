Function Get-CSVStatus {
    <#
    .SYNOPSIS
        Checks CSV Status
    
    .DESCRIPTION
        This functions is used to import CSV and check if the CSV was successfully imported.
    
    .PARAMETER User
        Import UserListToImport.csv and check if the file was successfully imported

    .PARAMETER Contact
        Import ContactListToImport.csv and check if the file was successfully imported

    .PARAMETER MappingFile
        Import the domain mapping file and check if the file was successfully imported
    
    .EXAMPLE
        PS C:\> Get-CSVStatus -MappingFile
        Import the CSV mapping file and provide a return to the main function if the file was successfully imported.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$User,
        [Parameter(Mandatory=$false)]
        [switch]$UsersMigrated,
        [Parameter(Mandatory=$false)]
        [switch]$Contact,
        [Parameter(Mandatory=$false)]
        [switch]$MappingFile
    )

    if ( $User.IsPresent ) {

        $UserListToImportCheck = 1
        if ( $UserListToImport ) {
        
            Try {

                $global:ImportUserList = Import-CSV "$UserListToImport" -ErrorAction Stop
                Write-PSFMessage -Level Output -Message  "The UserListToImport.csv successfully imported."
            }
            catch
            {

                $UserListToImportCheck = 0
                Write-PSFMessage -Level Output -Message  "The UserListToImport.csv does not exist. Please import a valid CSV file e re-run the function."

            }

            } else {

                Try
                {

                    $global:ImportUserList = Import-CSV "$home\desktop\UserListToImport.csv" -ErrorAction Stop
                    Write-PSFMessage -Level Output -Message  "The UserListToImport.csv successfully imported from $($home)\Desktop."

                }
                catch
                {

                    $UserListToImportCheck = 0
                    Write-PSFMessage -Level Output -Message  "The UserListToImport.csv was not found in $($home)\Desktop'. Please import a valid CSV file e re-run the function."

                }
            }

        return $UserListToImportCheck

        }

    if ( $UsersMigrated.IsPresent ) {

        $MigratedUsersImportCheck = 1
        if ( $MigratedUsers ) {
        
            Try {

                $Global:updatelist = Import-CSV "$MigratedUsers" -ErrorAction Stop
                Write-PSFMessage -Level Output -Message  "The MigratedUsers.csv successfully imported."
            }
            catch
            {

                $MigratedUsersImportCheck = 0
                Write-PSFMessage -Level Output -Message  "The MigratedUsers.csv does not exist. Please import a valid CSV file e re-run the function."

            }

            } else {

                Try
                {

                    $Global:updatelist = Import-CSV "$home\desktop\MigratedUsers.csv" -ErrorAction Stop
                    Write-PSFMessage -Level Output -Message  "The MigratedUsers.csv successfully imported from $($home)\Desktop."

                }
                catch
                {

                    $MigratedUsersImportCheck = 0
                    Write-PSFMessage -Level Output -Message  "The MigratedUsers.csv was not found in $($home)\Desktop'. Please import a valid CSV file e re-run the function."

                }
            }

        return $MigratedUsersImportCheck

        }

    if ( $Contact.IsPresent ) {

        $ContactListToImportCheck = 1
        if ( $ContactListToImport ) {

            Try
            {
                
                $global:ImportContactList = Import-CSV "$ContactListToImport" -ErrorAction Stop
                Write-PSFMessage -Level Output -Message  "The ContactListToImport.csv successfully imported."
                $ContactListToImportCheck = 1

            }
            catch
            {

                $ContactListToImportCheck = 0
                Write-PSFMessage -Level Output -Message  "The ContactListToImport.csv does not exist. Please import a valid CSV file e re-run the function."

            }

        } else {

            Try
            {

                $global:ImportContactList = Import-CSV "$home\desktop\ContactListToImport.csv" -ErrorAction Stop
                Write-PSFMessage -Level Output -Message  "The ContactListToImport.csv successfully imported from $($home)\Desktop."
                $ContactListToImportCheck = 1

            }
            catch
            {

                $ContactListToImportCheck = 0
                Write-PSFMessage -Level Output -Message  "ContactListToImport.csv was not found in $($home)\Desktop'. No Mail Contact will be imported."

            }
        }

        return $ContactListToImportCheck
    
    }

    if ( $MappingFile.IsPresent ) {
        $CSVMappingExist = 1
        Try {

            Import-CSV -Path $DomainMappingCSV -ErrorAction Stop

        }
        catch
        {

            $CSVMappingExist = 0
            Write-PSFMessage -Level Output -Message  "The Domain File Mapping does not exist. Please import a valid CSV file e re-run the function."
            if ($CSVMappingExist) { return $CSVMappingExist }

        }

        return $CSVMappingExist

    }

}