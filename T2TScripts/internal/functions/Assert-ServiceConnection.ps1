function Assert-ServiceConnection {
    <#
    .SYNOPSIS
    Checks current connection status for SCC, EXO and AzureAD
    
    .DESCRIPTION
    Checks current connection status for SCC, EXO and AzureAD
    
    .PARAMETER Services
    List of the desired services to assert the connection to. Current available services: EXO, SCC, MicrosoftTeams, MSOnline, AzureAD, AzureADPreview, Azure, ExchangeLocal, ExchangeRemote, AD.

    .EXAMPLE
    PS C:\> Assert-ServiceConnection -Services ExchangeLocal, AD
    Checks current connection status for Exchange Onprem in local machine and Active Directory.
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('EXO', 'SCC', 'MicrosoftTeams', 'MSOnline', 'AzureAD', 'AzureADPreview', 'Azure', 'ExchangeLocal', 'ExchangeRemote', 'AD')]
        [String[]]
        $Services
    )
    $Sessions = Get-PSSession
    $ServicesToConnect = New-Object -TypeName "System.Collections.ArrayList"

    Switch ( $Services ) {
        Azure {}
        AzureAD {
            try {
            $Null = Get-AzureADCurrentSessionInfo -ErrorAction Stop
            }
            catch {
                $null = $ServicesToConnect.add("AzureAD")
            }
        }
        AzureADPreview {}
        MSOnline {}
        MicrosoftTeams {}
        SCC {
            if ( -not ($Sessions.ComputerName -match "ps.compliance.protection.outlook.com") ) { $null = $ServicesToConnect.add("SCC") }
        }
        EXO {
            if ( $Sessions.ComputerName -notcontains "outlook.office365.com" ) { $null = $ServicesToConnect.add("EXO") }
        }
        ExchangeLocal {
            if ( $sessions.name -notmatch "Session" ) { $null = $ServicesToConnect.add("ExchangeLocal") }
        }
        ExchangeRemote {
            if ( $sessions.name -notmatch "WinRM" ) { $null = $ServicesToConnect.add("ExchangeRemote") }
        }
        AD {
            if ( -not (Get-Module ActiveDirectory -ListAvailable) ) {
            
                $null = $ServicesToConnect.add("AD")
            
            } else {

                    Import-Module ActiveDirectory
                    # Variable to be used when the machine is not
                    # an Exchange but the AD module is installed
                    [switch]$LocalAD = $True

            }
        }
    }
    return $ServicesToConnect
    return $LocalAD
}