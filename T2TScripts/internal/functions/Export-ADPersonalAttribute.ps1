Function Export-ADPersonalAttribute {
    <#
    .SYNOPSIS
    Function to handle the export of a set AD attributes

    .DESCRIPTION
    The function is called by Export-T2TAttributes when any of the following param are
    passed: -IncludeGeneral, -IncludeAddress, -IncludePhones, -IncludeOrganization or
    -IncludeManager. Basically the function dump the a set of attribute to the $object
    variable and for return it to the Export-T2TAttributes.

    .EXAMPLE
    PS C:\> Export-ADPersonalAttribute
    The cmdlet above will dump the necessary attributes based on what param was passed.
    #>

    # region -IncludeGeneral
    if ($IncludeGeneral.IsPresent)
    {
        if ($ADUser.physicalDeliveryOfficeName.Length -gt 0)
        {
            [void]$object.Add("physicalDeliveryOfficeName",$ADUser.physicalDeliveryOfficeName.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("physicalDeliveryOfficeName",$Null)
        }

        if ($ADUser.wWWHomePage.Length -gt 0)
        {
            [void]$object.Add("wWWHomePage",$ADUser.wWWHomePage.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("wWWHomePage",$Null)
        }

        if ($ADUser.url.Length -gt 0)
        {
            $url = $ADUser.url -Join ";"
            [void]$object.Add("url",$url.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("url",$Null)
        }

        if ($ADUser.description.Length -gt 0)
        {
            [void]$object.Add("description",$ADUser.Description.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("description",$Null)
        }
    }

    # region -IncludeAddress
    if ($IncludeAddress.IsPresent)
    {
        if ($ADUser.streetAddress.Length -gt 0)
        {
            [void]$object.Add("streetAddress",$ADUser.streetAddress.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("streetAddress",$Null)
        }

        if ($ADUser.postOfficeBox.Length -gt 0)
        {
            $postOfficeBox = $ADUser.postOfficeBox -Join ";"
            [void]$object.Add("postOfficeBox",$postOfficeBox.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("postOfficeBox",$Null)
        }
            
        if ($ADUser.l.Length -gt 0)
        {
            [void]$object.Add("l",$ADUser.l.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("l",$Null)
        }
            
        if ($ADUser.postalCode.Length -gt 0)
        {
            [void]$object.Add("postalCode",$ADUser.postalCode.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("postalCode",$Null)
        }
            
        if ($ADUser.c.Length -gt 0)
        {
            [void]$object.Add("c",$ADUser.c)
        }
        else
        {
            [void]$object.Add("c",$Null)
        }
            
        if ($ADUser.co.Length -gt 0)
        {
            [void]$object.Add("co",$ADUser.co)
        }
        else
        {
            [void]$object.Add("co",$Null)
        }
            
        if ($ADUser.countryCode -gt 0)
        {
            [void]$object.Add("countryCode",$ADUser.countryCode.ToString())
        }
        else
        {
            [void]$object.Add("countryCode",$Null)
        }

        if ($ADUser.st.Length -gt 0)
        {
            [void]$object.Add("st",$ADUser.st.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("st",$Null)
        }
    }

    # region -IncludePhones
    if ($IncludePhones.IsPresent)
    {
        if ($ADUser.telephoneNumber.Length -gt 0)
        {
            [void]$object.Add("telephoneNumber",$ADUser.telephoneNumber.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("telephoneNumber",$Null)
        }

        if ($ADUser.otherTelephone.Length -gt 0)
        {
            $otherTelephone = $ADUser.otherTelephone -Join ";"
            [void]$object.Add("otherTelephone",$otherTelephone.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("otherTelephone",$Null)
        }

        if ($ADUser.homePhone.Length -gt 0)
        {
            [void]$object.Add("homePhone",$ADUser.homePhone.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("homePhone",$Null)
        }
            
        if ($ADUser.otherHomePhone.Length -gt 0)
        {
            $otherHomePhone = $ADUser.otherHomePhone -Join ";"
            [void]$object.Add("otherHomePhone",$otherHomePhone.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("otherHomePhone",$Null)
        }
            
        if ($ADUser.pager.Length -gt 0)
        {
            [void]$object.Add("pager",$ADUser.pager.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("pager",$Null)
        }

        if ($ADUser.otherPager.Length -gt 0)
        {
            $otherPager = $ADUser.otherPager -Join ";"
            [void]$object.Add("otherPager",$otherPager.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("otherPager",$Null)
        }

        if ($ADUser.mobile.Length -gt 0)
        {
            [void]$object.Add("mobile",$ADUser.mobile.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("mobile",$Null)
        }
            
        if ($ADUser.otherMobile.Length -gt 0)
        {
            $otherMobile = $ADUser.otherMobile -Join ";"
            [void]$object.Add("otherMobile",$otherMobile.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("otherMobile",$Null)
        }

        if ($ADUser.facsimileTelephoneNumber.Length -gt 0)
        {
            [void]$object.Add("facsimileTelephoneNumber",$ADUser.facsimileTelephoneNumber.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("facsimileTelephoneNumber",$Null)
        }

        if ($ADUser.otherFacsimileTelephoneNumber.Length -gt 0)
        {
            $otherFacsimileTelephoneNumber = $ADUser.otherFacsimileTelephoneNumber -Join ";"
            [void]$object.Add("otherFacsimileTelephoneNumber",$otherFacsimileTelephoneNumber.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("otherFacsimileTelephoneNumber",$Null)
        }
            
        if ($ADUser.ipPhone.Length -gt 0)
        {
            [void]$object.Add("ipPhone",$ADUser.ipPhone.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("ipPhone",$Null)
        }

        if ($ADUser.otherIpPhone.Length -gt 0)
        {
            $otherIpPhone = $ADUser.otherIpPhone -Join ";"
            [void]$object.Add("otherIpPhone",$otherIpPhone.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("otherIpPhone",$Null)
        }
            
        if ($ADUser.info.Length -gt 0)
        {
            [void]$object.Add("info",$ADUser.info.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("info",$Null)
        }
    }

    # region -IncludeOrganization
    if ($IncludeOrganization.IsPresent)
    {
        if ($ADUser.title.Length -gt 0)
        {
            [void]$object.Add("title",$ADUser.title.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("title",$Null)
        }

        if ($ADUser.department.Length -gt 0)
        {
            [void]$object.Add("department",$ADUser.department.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("department",$Null)
        }

        if ($ADUser.company.Length -gt 0)
        {
            [void]$object.Add("company",$ADUser.company.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("company",$Null)
        }
    }

    # region -IncludeManager. We must
    # resolve the manager's CN to alias
    if ($Null -ne $user.Manager -and $IncludeManager.IsPresent)
    {
        $Manager = (Get-Recipient $user.Manager).Alias
        [void]$object.Add("Manager",$Manager)
    }
    elseif ($Null -eq $user.Manager -and $IncludeManager.IsPresent)
    {
        [void]$object.Add("Manager",$Null)
    }

    # region -IncludeCustomAttributes
    if ($IncludeCustomAttributes.IsPresent)
    {
        if ($ADUser.extensionAttribute1.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute1",$ADUser.extensionAttribute1.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute1",$Null)
        }

        if ($ADUser.extensionAttribute2.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute2",$ADUser.extensionAttribute2.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute2",$Null)
        }

        if ($ADUser.extensionAttribute3.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute3",$ADUser.extensionAttribute3.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute3",$Null)
        }

        if ($ADUser.extensionAttribute4.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute4",$ADUser.extensionAttribute4.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute4",$Null)
        }

        if ($ADUser.extensionAttribute5.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute5",$ADUser.extensionAttribute5.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute5",$Null)
        }

        if ($ADUser.extensionAttribute6.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute6",$ADUser.extensionAttribute6.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute6",$Null)
        }

        if ($ADUser.extensionAttribute7.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute7",$ADUser.extensionAttribute7.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute7",$Null)
        }

        if ($ADUser.extensionAttribute8.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute8",$ADUser.extensionAttribute8.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute8",$Null)
        }

        if ($ADUser.extensionAttribute9.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute9",$ADUser.extensionAttribute9.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute9",$Null)
        }

        if ($ADUser.extensionAttribute10.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute10",$ADUser.extensionAttribute10.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute10",$Null)
        }

        if ($ADUser.extensionAttribute11.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute11",$ADUser.extensionAttribute11.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute11",$Null)
        }

        if ($ADUser.extensionAttribute12.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute12",$ADUser.extensionAttribute12.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute12",$Null)
        }

        if ($ADUser.extensionAttribute13.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute13",$ADUser.extensionAttribute13.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute13",$Null)
        }

        if ($ADUser.extensionAttribute14.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute14",$ADUser.extensionAttribute14.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute14",$Null)
        }

        if ($ADUser.extensionAttribute15.Length -gt 0)
        {
            [void]$object.Add("extensionAttribute15",$ADUser.extensionAttribute15.Replace(",","---"))
        }
        else
        {
            [void]$object.Add("extensionAttribute15",$Null)
        }
    }

    return $object
}