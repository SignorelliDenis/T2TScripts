Function Import-ADPersonalAttribute {
    <#
    .SYNOPSIS
    Function to handle the import of many AD attribute

    .DESCRIPTION
    The function is called by Import-T2TAttributes when any of the following bool are
    $true: $IncludeGeneral, $IncludeAddress, $IncludePhones, $IncludeOrganization or
    -IncludeManager. Basically, the function must add a set of values and properties
    to the $Replace hashtable. The function also will handle the split in array cases
    and the replace of "---" to "," whenever would be necessary.

    .EXAMPLE
    PS C:\> Import-ADPersonalAttribute
    The cmdlet above will add a set of attributes to the $Replace array and return it to Import-T2TAttributes.
    #>

    # region -IncludeGeneral
    if ($CheckGeneral)
    {
        # In scenarios where the function doesn't have RSAT and AD module was exported from a
        # DC, there is a bug which prevent us from add all values as hashtable but we need to
        # loop the array and add one by one. This happens only for AD multi-value properties.
        if ($user.description -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$descriptionArr = $user.description.Split(";")
            ForEach ($description in $descriptionArr)
            {
                # We check the $ResolvedGUID to understand if it's a contact. Everything else should be user.
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{description=$description.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{description=$description.Replace("---",",")}
                }
            }
        }
        elseif ($user.description)
        {
            $descriptionArr = $user.description.Split(";")
            [void]$Replace.Add("description",$descriptionArr.Replace("---",","))
        }

        if ($user.physicalDeliveryOfficeName)
        {
            [void]$Replace.Add("physicalDeliveryOfficeName",$user.physicalDeliveryOfficeName.Replace("---",","))
        }

        if ($user.wWWHomePage)
        {
            [void]$Replace.Add("wWWHomePage",$user.wWWHomePage.Replace("---",","))
        }

        if ($user.url -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$urlArr = $user.url.Split(";")
            ForEach ($url in $urlArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{url=$url.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{url=$url.Replace("---",",")}
                }
            }
        }
        elseif ($user.url)
        {
            $urlArr = $user.url.Split(";")
            [void]$Replace.Add("url",$urlArr.Replace("---",","))
        }
    }

    # region -IncludeAddress
    if ($CheckAddress)
    {
        if ($user.streetAddress)
        {
            [void]$Replace.Add("streetAddress",$user.streetAddress.Replace("---",","))
        }

        if ($user.l)
        {
            [void]$Replace.Add("l",$user.l.Replace("---",","))
        }

        if ($user.st)
        {
            [void]$Replace.Add("st",$user.st.Replace("---",","))
        }

        if ($user.postalCode)
        {
            [void]$Replace.Add("postalCode",$user.postalCode.Replace("---",","))
        }

        if($user.c)
        {
            [void]$Replace.Add("c",$user.c)
        }

        if ($user.co)
        {
            [void]$Replace.Add("co",$user.co)
        }

        if ($user.countryCode)
        {
            [void]$Replace.Add("countryCode",$user.countryCode)
        }

        if ($user.postOfficeBox -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$postOfficeBoxArr = $user.postOfficeBox.Split(";")
            ForEach ($postOfficeBox in $postOfficeBoxArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{postOfficeBox=$postOfficeBox.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{postOfficeBox=$postOfficeBox.Replace("---",",")}
                }
            }
        }
        elseif ($user.postOfficeBox)
        {
            $postOfficeBoxArr = $user.postOfficeBox.Split(";")
            [void]$Replace.Add("postOfficeBox",$postOfficeBoxArr.Replace("---",","))
        }
    }

    # region -IncludePhones
    if ($CheckPhones)
    {
        if ($user.telephoneNumber)
        {
            [void]$Replace.Add("telephoneNumber",$user.telephoneNumber.Replace("---",","))
        }

        if ($user.otherTelephone -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$otherTelephoneArr = $user.otherTelephone.Split(";")
            ForEach ($otherTelephone in $otherTelephoneArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{otherTelephone=$otherTelephone.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{otherTelephone=$otherTelephone.Replace("---",",")}
                }
            }
        }
        elseif ($user.otherTelephone)
        {
            $otherTelephoneArr = $user.otherTelephone.Split(";")
            [void]$Replace.Add("otherTelephone",$otherTelephoneArr.Replace("---",","))
        }

        if ($user.homePhone)
        {
            [void]$Replace.Add("homePhone",$user.homePhone.Replace("---",","))
        }

        if ($user.otherHomePhone -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$otherHomePhoneArr = $user.otherHomePhone.Split(";")
            ForEach ($otherHomePhone in $otherHomePhoneArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{otherHomePhone=$otherHomePhone.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{otherHomePhone=$otherHomePhone.Replace("---",",")}
                }
            }
        }
        elseif ($user.otherHomePhone)
        {
            $otherHomePhoneArr = $user.otherHomePhone.Split(";")
            [void]$Replace.Add("otherHomePhone",$otherHomePhoneArr.Replace("---",","))
        }

        if ($user.pager)
        {
            [void]$Replace.Add("pager",$user.pager.Replace("---",","))
        }
        
        if ($user.otherPager -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$otherPagerArr = $user.otherPager.Split(";")
            ForEach ($otherPager in $otherPagerArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{otherPager=$otherPager.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{otherPager=$otherPager.Replace("---",",")}
                }
            }
        }
        elseif ($user.otherPager)
        {
            $otherPagerArr = $user.otherPager.Split(";")
            [void]$Replace.Add("otherPager",$otherPagerArr.Replace("---",","))
        }

        if ($user.mobile)
        {
            [void]$Replace.Add("mobile",$user.mobile.Replace("---",","))
        }

        if ($user.otherMobile -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$otherMobileArr = $user.otherMobile.Split(";")
            ForEach ($otherMobile in $otherMobileArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{otherMobile=$otherMobile.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{otherMobile=$otherMobile.Replace("---",",")}
                }
            }
        }
        elseif ($user.otherMobile)
        {
            $otherMobileArr = $user.otherMobile.Split(";")
            [void]$Replace.Add("otherMobile",$otherMobileArr.Replace("---",","))
        }

        if ($user.facsimileTelephoneNumber)
        {
            [void]$Replace.Add("facsimileTelephoneNumber",$user.facsimileTelephoneNumber.Replace("---",","))
        }

        if ($user.otherFacsimileTelephoneNumber -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$otherFacsimileTelephoneNumberArr = $user.otherFacsimileTelephoneNumber.Split(";")
            ForEach ($otherFacsimileTelephoneNumber in $otherFacsimileTelephoneNumberArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{otherFacsimileTelephoneNumber=$otherFacsimileTelephoneNumber.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{otherFacsimileTelephoneNumber=$otherFacsimileTelephoneNumber.Replace("---",",")}
                }
            }
        }
        elseif ($user.otherFacsimileTelephoneNumber)
        {
            $otherFacsimileTelephoneNumberArr = $user.otherFacsimileTelephoneNumber.Split(";")
            [void]$Replace.Add("otherFacsimileTelephoneNumber",$otherFacsimileTelephoneNumberArr.Replace("---",","))
        }

        if ($user.ipPhone)
        {
            [void]$Replace.Add("ipPhone",$user.ipPhone.Replace("---",","))
        }

        if ($user.otherIpPhone -and $LocalMachineIsNotExchange.IsPresent -and $Null -eq $LocalAD)
        {
            [System.Collections.ArrayList]$otherIpPhoneArr = $user.otherIpPhone.Split(";")
            ForEach ($otherIpPhone in $otherIpPhoneArr)
            {
                if ($ResolvedGUID.Guid)
                {
                    Set-RemoteADObject -Identity $ResolvedGUID.Guid -Server $PreferredDC -Add @{otherIpPhone=$otherIpPhone.Replace("---",",")}
                }
                else
                {
                    Set-RemoteADUser -Identity $user.SamAccountName -Server $PreferredDC -Add @{otherIpPhone=$otherIpPhone.Replace("---",",")}
                }
            }
        }
        elseif ($user.otherIpPhone)
        {
            $otherIpPhoneArr = $user.otherIpPhone.Split(";")
            [void]$Replace.Add("otherIpPhone",$otherIpPhoneArr.Replace("---",","))
        }

        if ($user.info)
        {
            [void]$Replace.Add("info",$user.info.Replace("---",","))
        }
    }

    # region -IncludeOrganization
    if ($CheckOrganization)
    {
        if ($user.title)
        {
            [void]$Replace.Add("title",$user.title.Replace("---",","))
        }

        if ($user.department)
        {
            [void]$Replace.Add("department",$user.department.Replace("---",","))
        }

        if ($user.company)
        {
            [void]$Replace.Add("company",$user.company.Replace("---",","))
        }
    }

    # region -IncludeCustomAttributes
    if ($CheckCustomAttributes)
    {
        if ($user.extensionAttribute1)
        {
            [void]$Replace.Add("extensionAttribute1",$user.extensionAttribute1.Replace("---",","))
        }

        if ($user.extensionAttribute2)
        {
            [void]$Replace.Add("extensionAttribute2",$user.extensionAttribute2.Replace("---",","))
        }

        if ($user.extensionAttribute3)
        {
            [void]$Replace.Add("extensionAttribute3",$user.extensionAttribute3.Replace("---",","))
        }

        if ($user.extensionAttribute4)
        {
            [void]$Replace.Add("extensionAttribute4",$user.extensionAttribute4.Replace("---",","))
        }

        if ($user.extensionAttribute5)
        {
            [void]$Replace.Add("extensionAttribute5",$user.extensionAttribute5.Replace("---",","))
        }

        if ($user.extensionAttribute6)
        {
            [void]$Replace.Add("extensionAttribute6",$user.extensionAttribute6.Replace("---",","))
        }

        if ($user.extensionAttribute7)
        {
            [void]$Replace.Add("extensionAttribute7",$user.extensionAttribute7.Replace("---",","))
        }

        if ($user.extensionAttribute8)
        {
            [void]$Replace.Add("extensionAttribute8",$user.extensionAttribute8.Replace("---",","))
        }

        if ($user.extensionAttribute9)
        {
            [void]$Replace.Add("extensionAttribute9",$user.extensionAttribute9.Replace("---",","))
        }

        if ($user.extensionAttribute10)
        {
            [void]$Replace.Add("extensionAttribute10",$user.extensionAttribute10.Replace("---",","))
        }

        if ($user.extensionAttribute11)
        {
            [void]$Replace.Add("extensionAttribute11",$user.extensionAttribute11.Replace("---",","))
        }

        if ($user.extensionAttribute12)
        {
            [void]$Replace.Add("extensionAttribute12",$user.extensionAttribute12.Replace("---",","))
        }

        if ($user.extensionAttribute13)
        {
            [void]$Replace.Add("extensionAttribute13",$user.extensionAttribute13.Replace("---",","))
        }

        if ($user.extensionAttribute14)
        {
            [void]$Replace.Add("extensionAttribute14",$user.extensionAttribute14.Replace("---",","))
        }

        if ($user.extensionAttribute15)
        {
            [void]$Replace.Add("extensionAttribute15",$user.extensionAttribute15.Replace("---",","))
        }
    }

    # region CheckContactManager. We can leverage this function to
    # import only contact managers' as MEU are previous created.
    if ($CheckContactManager -and $user.Manager)
    {
        try
        {
            # we must resolve the manager DN. Better using try/catch to avoid
            # scenarios that manager does not exist in the target environment
            $ManagerResolved = Get-ADUser -Identity $user.Manager -Properties distinguishedName -ErrorAction Stop
            if ($?)
            {
                [void]$Replace.Add("manager",$ManagerResolved.DistinguishedName)
            }
        }
        catch
        {
            Write-PSFMessage -Level Output -Message "Error: The manager $($user.Manager) could not be found and was not added to the contact $($user.DisplayName)."
        }
    }

    return $Replace
}