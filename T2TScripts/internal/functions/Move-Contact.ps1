Function Move-Contact {
    <#
    .SYNOPSIS
    Function to handle export and import of mail enable contacts

    .PARAMETER Sync
    Decide to perform the export or import of mail contacts

    .DESCRIPTION
    Similar to the Export-T2TAttributes, this function dumps attributes
    from the source AD but only External Contacts. We rely on the same
    CustomAttributed passed through Export-T2TAttributes to filter which
    contacts will be fetched by this function. From the Import-T2TAttributes
    user must pass through param the CSV to import the mail contacts.

    .EXAMPLE
    PS C:\> Move-Contacts -Sync Export
    The cmdlet above perform an export of mail contacts filtered by the custom attribute chosen.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [CmdletBinding()]
    param (
        [ValidateSet('Export','Import')]
        [String[]]
        $Sync
    )

    Switch ($Sync)
    {

        Export {
            # region variables
            [int]$counter = 0
            $outArray = [System.Collections.ArrayList]::new()
            $outFile = "$home\desktop\ContactListToImport.csv"
            $ContactCustomAttribute = $CustomAttribute
            $ContactCustomAttributeValue = $CustomAttributeValue

            # region get Contacts filtering by custom attribute
            $Contacts = (Get-MailContact -ResultSize Unlimited).Where({$_.$CustomAttribute -like $CustomAttributeValue})
            Write-PSFMessage -Level Output -Message "$($Contacts.Count) Mail Contacts with $($ContactCustomAttribute) as $($ContactCustomAttributeValue) were returned"
            $ContactCount = ($Contacts | Measure-Object).count

            # region iterate objects
            ForEach ($i in $Contacts)
            {
                $counter++
                Write-Progress -Activity "Exporting Mail Contacts to CSV" -Status "Working on $($i.DisplayName)" -PercentComplete ($counter * 100 / $ContactCount)
        
                $user = get-Recipient $i.alias
                $object = [ordered]@{
                    PrimarySMTPAddress=$i.PrimarySMTPAddress
                    alias=$i.alias
                    FirstName=$User.FirstName
                    LastName=$User.LastName
                    DisplayName=$User.DisplayName
                    Name=$i.Name
                    legacyExchangeDN=$i.legacyExchangeDN
                }

                # ExternalEmailAddress should contains "SMTP:" depending on the
                # deserialization, we just try a replace to avoid that scenario
                [string]$j = $i.ExternalEmailAddress
                [void]$object.Add("ExternalEmailAddress",$j.Replace("SMTP:",""))

                # Get only non-primary smtp and X500 from proxyAddresses. If we get the primary
                # the CSV mapping domain logic will break as SMTP should be external for contacts
                $ProxyArray = [System.Collections.ArrayList]::new()
                $Proxy = $i.EmailAddresses
                foreach ($email in $Proxy)
                {
                    if ($email -clike 'smtp:*' -or $email -like 'x500:*' -and $email -notlike '*.onmicrosoft.com')
                    {
                        [void]$ProxyArray.Add($email)
                    }
                }

                # Join proxyAddresses using ";"
                $ProxyToString = $ProxyArray -Join ";"

                # Map through the CSV which source domain will become which target domain
                Foreach ($Domain in $MappingCSV)
                {
                    # Add @ before the domain to avoid issues with subdomains
                    $SourceDomain = $Domain.Source.Insert(0,"@")
                    $TargetDomain = $Domain.Target.Insert(0,"@")

                    if ($ProxyToString -match $Domain.source)
                    {
                        $ProxyToString = $ProxyToString.Replace($SourceDomain,$TargetDomain)
                    }
                }

                [void]$object.Add("EmailAddresses",$ProxyToString)

                # Connect to AD exported module only if this machine has not AD Module installed and
                # filtering based on what "Include" was passed to avoid dump too many unnecessary stuff
                if ($LocalMachineIsNotExchange.IsPresent -and $LocalAD -eq '')
                {
                    $ADUser = Get-RemoteADObject -Identity $i.DistinguishedName -Server $PreferredDC -Properties $ADProperties
                    # dump those "-Include" attributes only if we
                    # found more stuff than those junk properties
                    if ($ADProperties.Count -gt 3)
                    {
                        [void](Export-ADPersonalAttribute)
                    }
                }
                else
                {
                    $ADUser = Get-ADObject -Identity $i.DistinguishedName -Server $PreferredDC -Properties $ADProperties
                    # dump those "-Include" attributes only if we
                    # found more stuff than those junk properties
                    if ($ADProperties.Count -gt 3)
                    {
                        [void](Export-ADPersonalAttribute)
                    }
                }
                
                # Create PSObject from hashtable
                # and add PSObject to ArrayList
                $outPSObject = New-Object -TypeName PSObject -Property $object
                [void]$outArray.Add($outPSObject)
            }

            if ($outArray.Count -gt 0)
            {
                Write-PSFMessage -Level Output -Message "Saving CSV on $($outfile)"
                $outArray | Export-CSV $outfile -notypeinformation
            }
        }

        Import {
            # region local variables
            [int]$counter = 0
            $ContactsCount = ($ImportContactList | Measure-Object).count
            $CheckContactManager = ($ImportContactList[0].psobject.Properties).Where({$_.Name -eq "Manager"})

            # region iterate contacts. Variable kept as $user cause
            # the Import-ADPersonalAttribute relies on that value
            ForEach ($user in $ImportContactList)
            {
                $counter++
                Write-Progress -Activity "Creating MEU objects and importing attributes from CSV" -Status "Working on $($i.DisplayName)" -PercentComplete ($counter * 100 / $ContactsCount)
                $Replace = @{}
                $tmpContact = $null

                # If OU was passed through param, honor it.
                # Otherwise create the MEU without OU specification
                if ($OUContacts)
                {
                    $tmpContact = New-MailContact -ExternalEmailAddress $user.ExternalEmailAddress -PrimarySmtpAddress `
                    $user.PrimarySMTPAddress -FirstName $user.FirstName -LastName $user.LastName -Alias $user.alias -Name `
                    $user.Name -DisplayName $user.DisplayName -OrganizationalUnit $OUContacts
                }
                else
                {
                    $tmpContact = New-MailContact -ExternalEmailAddress $user.ExternalEmailAddress -PrimarySmtpAddress `
                    $user.PrimarySMTPAddress -FirstName $user.FirstName -LastName $user.LastName -Alias $user.alias -Name `
                    $user.Name -DisplayName $user.DisplayName
                }
                
                # we must resolve the GUID in order to
                # use Set-ADObject cmdlet down the road
                $ResolvedGUID = Get-MailContact -Identity $user.Alias | Select-Object GUID

                # Convert legacyDN to X500 and add all EmailAddresses to array
                $x500 = "x500:" + $user.legacyExchangeDN
                $proxy = $user.EmailAddresses.Replace(";",",")
                $ProxyArray = @()
                $ProxyArray = $proxy.Split(",") + $x500

                # region import old LegacyDN as X500 and CustomAttribute
                Set-MailContact -Identity $user.Alias -EmailAddresses @{Add=$ProxyArray}

                # region import "-Include" values
                if ($CheckContactManager -or $CheckGeneral -or $CheckAddress -or $CheckPhones -or $CheckOrganization -or $CheckCustomAttributes)
                {
                    [void](Import-ADPersonalAttribute)
                }

                # region set $replace hashtable to ADUser
                if ($LocalMachineIsNotExchange.IsPresent -and $null -eq $LocalAD -and $Replace.Count -gt 0)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Replace $Replace
                }
                elseif ($Replace.Count -gt 0)
                {
                    Set-ADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Replace $Replace
                }
            }
        }
    }
}