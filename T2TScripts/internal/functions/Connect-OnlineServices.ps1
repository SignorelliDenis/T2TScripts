function Connect-OnlineServices {
    <#
    .SYNOPSIS
        Connect to Online Services.

    .DESCRIPTION
        Use this function to connect to EXO, Exchange Onprem and Active Directory.

    .PARAMETER AdminUPN
        Passes the administrator's UPN to be used in the authentication prompts.

    .PARAMETER Services
        List of the desired services to connect to. Current available services: EXO, ExchangeLocal, ExchangeRemote, AD.

    .PARAMETER ExchangeHostname
        Used to inform the Exchange Server FQDN that the script will connect.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
   
    .EXAMPLE
        PS C:\> Connect-OnlineServices -Services EXO
        Connects to Exchange Online.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param(
        [String]
        $AdminUPN,

        [ValidateSet('EXO','ExchangeLocal', 'ExchangeRemote', 'AD')]
        [String[]]
        $Services,
     
        [Parameter(Mandatory = $false, HelpMessage="Enter the remote exchange hostname")]
        [string]$ExchangeHostname
     )

    Switch ( $Services ) {

        EXO {
            Invoke-PSFProtectedCommand -Action "Connecting to Exchange Online" -Target "EXO" -ScriptBlock {
                Write-PSFMessage -Level Output -Message "Connecting to Exchange Online"
                try {

                    Connect-ExchangeOnline -UserPrincipalName $AdminUPN -ShowProgress:$True -ShowBanner:$False -Prefix EX
                    Write-PSFMessage -Level Output -Message "Connected to Exchange Online"

                }
                catch {
                    return $_
                }
            } -EnableException $true -PSCmdlet $PSCmdlet
        }

        ExchangeLocal {
            Invoke-PSFProtectedCommand -Action "Connecting to Exchange Onprem locally." -Target "ExchangeLocal" -ScriptBlock {
                Write-PSFMessage -Level Output -Message "Connecting to Exchange Onprem locally."
                try {
                    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
                    Write-PSFMessage -Level Output -Message "Connected to Exchange Onprem locally."
                }
                catch { Write-PSFMessage -Level Output -Message "Error: The function could not connect on local Exchange" }
            } -EnableException $true -PSCmdlet $PSCmdlet
        }

        ExchangeRemote {
            Invoke-PSFProtectedCommand -Action "Connecting to Exchange Onprem remotely." -Target "ExchangeRemote" -ScriptBlock {
                Write-PSFMessage -Level Output -Message "Connecting to Exchange Onprem remotely."
                try {
                    $exOnPremSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeHostname/PowerShell/ -Authentication Kerberos
                    Import-PSSession $exOnPremSession -AllowClobber -DisableNameChecking | Out-Null
                    Write-PSFMessage -Level Output -Message "Connected to Exchange Onprem remotely."
                 }
                catch { Write-PSFMessage -Level Output -Message "Error: The function could not connect on remote Exchange" }
            } -EnableException $true -PSCmdlet $PSCmdlet
        }

        AD {
            Invoke-PSFProtectedCommand -Action "Connecting to Active Directory." -Target "AD" -ScriptBlock {
                Write-PSFMessage -Level Output -Message "Connecting to Active Directory."
                try {
                    $sessionAD = New-PSSession -ComputerName $env:LogOnServer.Replace("\\","")
                    Invoke-Command { Import-Module ActiveDirectory } -Session $sessionAD
                    Export-PSSession -Session $sessionAD -CommandName *-AD* -OutputModule RemoteAD -AllowClobber -Force | Out-Null
                    Remove-PSSession -Session $sessionAD
                    
                    # Create copy of the module on the local computer
                    Import-Module RemoteAD -Prefix Remote -DisableNameChecking -ErrorAction Stop
                
                } catch {
                    
                    # Sometimes the following path is not registered as system variable for PS modules path, thus we catch explicitly the .psm1
                    Import-Module "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\RemoteAD\RemoteAD.psm1" -Prefix Remote -DisableNameChecking
                        
                } finally {

                    If (Get-Module -Name RemoteAD) {

                        Write-PSFMessage -Level Output -Message "AD Module was succesfully installed."

                    } else {

                        Write-PSFMessage -Level Error -Message "AD module failed to load. Please run the script from an Exchange Server."
                        throw

                    }
                }
            } -EnableException $true -PSCmdlet $PSCmdlet
        }
    }
}