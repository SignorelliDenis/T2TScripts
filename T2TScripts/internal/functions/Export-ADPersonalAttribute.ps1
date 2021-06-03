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
        if ( $ADUser.physicalDeliveryOfficeName.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name physicalDeliveryOfficeName -value $ADUser.physicalDeliveryOfficeName.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name physicalDeliveryOfficeName -value $Null
        }

        if ( $ADUser.wWWHomePage.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name wWWHomePage -value $ADUser.wWWHomePage.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name wWWHomePage -value $Null
        }

        if ( $ADUser.url.Length -gt 0 )
        {
            $url = $ADUser.url -Join ";"
            $object | Add-Member -type NoteProperty -name url -value $url.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name url -value $Null
        }

        if ( $ADUser.description.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name description -value $ADUser.Description.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name description -value $Null
        }
    }

    # region -IncludeAddress
    if ($IncludeAddress.IsPresent)
    {
        if ( $ADUser.streetAddress.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name streetAddress -value $ADUser.streetAddress.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name streetAddress -value $Null
        }
            
        if ( $ADUser.postOfficeBox.Length -gt 0 )
        {
            $postOfficeBox = $ADUser.postOfficeBox -Join ";"
            $object | Add-Member -type NoteProperty -name postOfficeBox -value $postOfficeBox.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name postOfficeBox -value $Null
        }
            
        if ( $ADUser.l.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name l -value $ADUser.l.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name l -value $Null
        }
            
        if ( $ADUser.postalCode.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name postalCode -value $ADUser.postalCode.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name postalCode -value $Null
        }
            
        if ( $ADUser.c.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name c -value $ADUser.c
        }
        else
        {
            $object | Add-Member -type NoteProperty -name c -value $Null
        }
            
        if ( $ADUser.co.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name co -value $ADUser.co
        }
        else
        {
            $object | Add-Member -type NoteProperty -name co -value $Null
        }
            
        if ( $ADUser.countryCode -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name countryCode -value $ADUser.countryCode.ToString()
        }
        else
        {
            $object | Add-Member -type NoteProperty -name countryCode -value $Null
        }

        if ( $ADUser.st.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name st -value $ADUser.st.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name st -value $Null
        }
    }

    # region -IncludePhones
    if ($IncludePhones.IsPresent)
    {
        if ( $ADUser.telephoneNumber.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name telephoneNumber -value $ADUser.telephoneNumber.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name telephoneNumber -value $Null
        }

        if ( $ADUser.otherTelephone.Length -gt 0 )
        {
            $otherTelephone = $ADUser.otherTelephone -Join ";"
            $object | Add-Member -type NoteProperty -name otherTelephone -value $otherTelephone.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name otherTelephone -value $Null
        }

        if ( $ADUser.homePhone.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name homePhone -value $ADUser.homePhone.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name homePhone -value $Null
        }
            
        if ( $ADUser.otherHomePhone.Length -gt 0 )
        {
            $otherHomePhone = $ADUser.otherHomePhone -Join ";"
            $object | Add-Member -type NoteProperty -name otherHomePhone -value $otherHomePhone.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name otherHomePhone -value $Null
        }
            
        if ( $ADUser.pager.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name pager -value $ADUser.pager.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name pager -value $Null
        }
            
        if ( $ADUser.otherPager.Length -gt 0 )
        {
            $otherPager = $ADUser.otherPager -Join ";"
            $object | Add-Member -type NoteProperty -name otherPager -value $otherPager.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name otherPager -value $Null
        }
            
        if ( $ADUser.mobile.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name mobile -value $ADUser.mobile.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name mobile -value $Null
        }
            
        if ( $ADUser.otherMobile.Length -gt 0 )
        {
            $otherMobile = $ADUser.otherMobile -Join ";"
            $object | Add-Member -type NoteProperty -name otherMobile -value $otherMobile.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name otherMobile -value $Null
        }
            
        if ( $ADUser.facsimileTelephoneNumber.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name facsimileTelephoneNumber -value $ADUser.facsimileTelephoneNumber.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name facsimileTelephoneNumber -value $Null
        }
            
        if ( $ADUser.otherFacsimileTelephoneNumber.Length -gt 0 )
        {
            $otherFacsimileTelephoneNumber = $ADUser.otherFacsimileTelephoneNumber -Join ";"
            $object | Add-Member -type NoteProperty -name otherFacsimileTelephoneNumber -value $otherFacsimileTelephoneNumber.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name otherFacsimileTelephoneNumber -value $Null
        }
            
        if ( $ADUser.ipPhone.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name ipPhone -value $ADUser.ipPhone.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name ipPhone -value $Null
        }
            
        if ( $ADUser.otherIpPhone.Length -gt 0 )
        {
            $otherIpPhone = $ADUser.otherIpPhone -Join ";"
            $object | Add-Member -type NoteProperty -name otherIpPhone -value $otherIpPhone.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name otherIpPhone -value $Null
        }
            
        if ( $ADUser.info.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name info -value $ADUser.info.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name info -value $Null
        }
    }

    # region -IncludeOrganization
    if ($IncludeOrganization.IsPresent)
    {
        if ( $ADUser.title.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name title -value $ADUser.title.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name title -value $Null
        }

        if ( $ADUser.department.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name department -value $ADUser.department.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name department -value $Null
        }

        if ( $ADUser.company.Length -gt 0 )
        {
            $object | Add-Member -type NoteProperty -name company -value $ADUser.company.Replace(",","---")
        }
        else
        {
            $object | Add-Member -type NoteProperty -name company -value $Null
        }
    }

    # region -IncludeManager. We must
    # resolve the manager's CN to alias
    if ($Null -ne $user.Manager -and $IncludeManager.IsPresent)
    {
        $Manager = (Get-Recipient $user.Manager).Alias
        $object | Add-Member -type NoteProperty -name Manager -value $Manager
    }
    elseif ($Null -eq $user.Manager -and $IncludeManager.IsPresent)
    {
        $object | Add-Member -type NoteProperty -name Manager -value $Null
    }

    return $object
}