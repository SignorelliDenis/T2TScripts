Function Move-Contacts {
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    param (
        [ValidateSet('Export','Import')]
        [String[]]
        $Sync
    )

    Switch ( $Sync ) {

        Export {

            # region variables
            $outArray = @()
            $outFile = "$home\desktop\ContactListToImport.csv"
            $ContactCustomAttribute = $CustomAttribute
            $ContactCustomAttributeValue = $CustomAttributeValue


            # Get Contacts filtering by custom attribute
            $Contacts = Get-MailContact -resultsize unlimited | Where-Object { $_.$ContactCustomAttribute -like $ContactCustomAttributeValue }
            Write-PSFMessage -Level Output -Message "$($Contacts.Count) Mail Contacts with $($ContactCustomAttribute) as $($ContactCustomAttributeValue) were returned"

            [int]$counter = 0
            $ContactCount = ($Contacts | Measure-Object).count
            Foreach ( $i in $Contacts )
            {
        
                $counter++
                Write-Progress -Activity "Exporting Mail Contacts to CSV" -Status "Working on $($i.DisplayName)" -PercentComplete ( $counter * 100 / $ContactCount )
        
                $user = get-Recipient $i.alias
                $object = New-Object System.Object
                $object | Add-Member -type NoteProperty -name PrimarySMTPAddress -value $i.PrimarySMTPAddress
                $object | Add-Member -type NoteProperty -name alias -value $i.alias
                $object | Add-Member -type NoteProperty -name FirstName -value $User.FirstName
                $object | Add-Member -type NoteProperty -name LastName -value $User.LastName
                $object | Add-Member -type NoteProperty -name DisplayName -value $User.DisplayName
                $object | Add-Member -type NoteProperty -name Name -value $i.Name
                $object | Add-Member -type NoteProperty -name legacyExchangeDN -value $i.legacyExchangeDN
                $object | Add-Member -type NoteProperty -name CustomAttribute -value $ContactCustomAttribute
                $object | Add-Member -type NoteProperty -name CustomAttributeValue -value $ContactCustomAttributeValue

                # ExternalEmailAddress should contains "SMTP:" depending
                # on the deserialization, just try a replace to avoid IF
                $j = $i.ExternalEmailAddress -replace "SMTP:",""
                $object | Add-Member -type NoteProperty -name ExternalEmailAddress -value $j

                # Get manager property and resolve CN to alias
                if ( $IncludeManager.IsPresent -and $user.Manager -ne $Null ) {

                    $Manager = ( Get-Recipient $user.Manager ).Alias
                    $object | Add-Member -type NoteProperty -name Manager -value $Manager

                }
                if ( $IncludeManager.IsPresent -and $user.Manager -eq $Null ) {

                    $object | Add-Member -type NoteProperty -name Manager -value $Null

                }

                # Get only non-primary smtp and X500 from proxyAddresses. If we get the primary
                # the CSV mapping domain logic will break as SMTP should be external for contacts
                $ProxyArray = @()
                $Proxy = $i.EmailAddresses
                foreach ($email in $Proxy)
                {
                    if ( $email -clike 'smtp:*' -or $email -like 'x500:*' -and $email -notlike '*.onmicrosoft.com' )
                    {

                        $ProxyArray = $ProxyArray += $email

                    }
                }

                # Join it using ";"
                $ProxyToString = $ProxyArray -Join ";"

                # Map from the CSV which source domain will become which target domain
                Foreach ($Domain in $MappingCSV) {

                    # Add @ before the domain to avoid issues with subdomains
                    $SourceDomain = $Domain.Source.Insert(0,"@")
                    $TargetDomain = $Domain.Target.Insert(0,"@")

                    if ($ProxyToString -match $Domain.source) {

                        $ProxyToString = $ProxyToString -replace $SourceDomain,$TargetDomain

                    }
                }

                $object | Add-Member -type NoteProperty -name EmailAddresses -value $ProxyToString
                $outArray += $object
            
            }

            Write-PSFMessage -Level Output -Message "Saving CSV on $($outfile)"
            $outArray | Export-CSV $outfile -notypeinformation

        }

        Import {

            [int]$counter = 0
            $ContactsCount = ( $ImportContactList | Measure-Object ).count
            foreach ( $i in $ImportContactList )
            {
                $counter++
                Write-Progress -Activity "Creating MEU objects and importing attributes from CSV" -Status "Working on $($i.DisplayName)" -PercentComplete ( $counter * 100 / $ContactsCount )
                $tmpContact = $null

                # If OU was passed through param, honor it.
                # Otherwise create the MEU without OU specification
                if ( $OUContacts )
                {
                    $tmpContact = New-MailContact -ExternalEmailAddress $i.ExternalEmailAddress -PrimarySmtpAddress `
                    $i.PrimarySMTPAddress -FirstName $i.FirstName -LastName $i.LastName -Alias $i.alias -Name `
                    $i.Name -DisplayName $i.DisplayName -OrganizationalUnit $OUContacts

                } else {

                    $tmpContact = New-MailContact -ExternalEmailAddress $i.ExternalEmailAddress -PrimarySmtpAddress `
                    $i.PrimarySMTPAddress -FirstName $i.FirstName -LastName $i.LastName -Alias $i.alias -Name `
                    $i.Name -DisplayName $i.DisplayName

                }

                # Convert legacyDN to X500, replace back to ","
                $x500 = "x500:" + $i.legacyExchangeDN
                $proxy = $i.EmailAddresses.Replace(";",",")
                $ProxyArray = @()
                $ProxyArray = $Proxy -split ","
                $ProxyArray = $ProxyArray + $x500

                # Matching the variable's name to the parameter's name
                $CustomAttributeParam = @{ $i.CustomAttribute=$i.CustomAttributeValue }

                # Set previou LegacyDN as X500 and CustomAttribute
                Set-MailContact -Identity $i.Alias -EmailAddresses @{ Add=$ProxyArray } @CustomAttributeParam

            }

            # Import Manager value if the CSV contains the manager header
            $IncludeManager = $ImportContactList[0].psobject.Properties | Where { $_.Name -eq "Manager" }
            if ( $IncludeManager ) { Import-Manager -ObjType Contact }

        }
    }
}