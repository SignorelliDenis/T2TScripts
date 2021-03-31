function Import-Manager {
    <#
    .SYNOPSIS
    Import Manager Attribute
    
    .DESCRIPTION
    Function called by Import-T2TAttributes if we found the Manager property on the UserListToImport.csv 
    
    .PARAMETER CSVPath
    Path where the function can find the UserListToImport.csv 
    
    .EXAMPLE
    PS C:\> Import-Manager
    #>

    Write-PSFMessage -Level Output -Message  "Starting Manager attribute import"
    
    [int]$counter = 0
    foreach ( $i in $ImportUserList ) {

        $counter++
        Write-Progress -Activity "Importing Manager Attribute" -Status "Working on $($i.DisplayName)" -PercentComplete ($counter * 100 / $($ImportUserList.Count) )

        if ( $LocalMachineIsNotExchange.IsPresent -and $i.Manager ) {

            Try {

                Set-RemoteADUser -Identity $i.SamAccountName -Manager $i.Manager -ErrorAction Stop

            }
            catch
            {

                Write-PSFMessage -Level Output -Message "Failed to add the user's $($i.DisplayName) manager attribute"

            }
        }
        elseif ( $i.Manager ) {

            Try {

                Set-ADUser -Identity $i.SamAccountName -Manager $i.Manager -ErrorAction Stop

            }
            catch
            {

                Write-PSFMessage -Level Output -Message "Failed to add the user's $($i.DisplayName) manager attribute"

            }
        }
    }
}