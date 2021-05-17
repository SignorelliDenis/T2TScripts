Function Get-Requirement {
    <#
    .SYNOPSIS
    Checks requirements
    
    .DESCRIPTION
    Checks requirements
    
    .PARAMETER Requirements
    Lists the available Services requirements to be checked. Currently Available is 'AADConnect'.
    
    .EXAMPLE
    PS C:\> Get-Requirement -Requirements PSFramework, EXO
    Checks if PSFramework and EXO v2 modure is installed. If not, we install it.
    #>

    [CmdletBinding()]
    param (
        [ValidateSet('AADConnect')]
        [String[]]
        $Requirements
    )

    Switch ( $Requirements ) {

        AADConnect {

            $title    = Write-PSFMessage -Level Output -Message  "AD Sync status"
            $question = Write-PSFMessage -Level Output -Message  "Did you stopped the Azure AD Connect sync cycle?"
            $choices  = '&Yes', '&No'
            $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

            if ($decision -eq 0) {
            
                Write-PSFMessage -Level Output -Message  "Loading parameters..."

            } else {
            
                Write-PSFMessage -Level Output -Message  "AD sync cycle should be stopped before moving forward."
            
                $title1    = Write-PSFMessage -Level Output -Message  ""
                $question1 = Write-PSFMessage -Level Output -Message  "Type 'Yes' if you want that we automatically stop AD Sync cycle or type 'No' if you want to stop yourself."
                $choices1  = '&Yes', '&No'
                $decision1 = $Host.UI.PromptForChoice($title1, $question1, $choices1, 1)

                if ($decision1 -eq 0) {
            
                    $AADC = Read-Host "$(Get-Date -Format "HH:mm:ss") - Please enter the Azure AD Connect server hostname"

                        Write-PSFMessage -Level Output -Message  "Disabling AD Sync cycle..."
                        $sessionAADC = New-PSSession -ComputerName $AADC
                        Invoke-Command {
        
                            Import-Module ADSync
                            Set-ADSyncScheduler -SyncCycleEnabled $false
        
                            } -Session $sessionAADC

                        $SynccycleStatus = Invoke-Command {
        
                            Import-Module ADSync
                            Get-ADSyncScheduler | Select-Object SyncCycleEnabled
                        
                            } -Session $sessionAADC

                            if ($SynccycleStatus.SyncCycleEnabled -eq $false) {
        
                                Write-PSFMessage -Level Output -Message  "Azure AD sync cycle succesfully disabled."
                                $AADCStoped = 1
                                
                            } else {

                                Write-PSFMessage -Level Output -Message  "Azure AD sync cycle could not be stopped, please stop it manually with the following cmdlet: Set-ADSyncScheduler -SyncCycleEnabled 0"
                                $AADCStoped = 0
                                
                            }
                        
                } else {
                    
                    $AADCStoped = 0
                    Write-PSFMessage -Level Output -Message  "Please stop the AD sync cycle and run the script again."

                }
            }
            Get-PSSession | Remove-PSSession
        }
    }

    return $AADCStoped

}