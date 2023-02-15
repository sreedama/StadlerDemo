/* 
 @<COPYRIGHT>@
 ==================================================
 Copyright 2012
 Siemens Product Lifecycle Management Software Inc.
 All Rights Reserved.
 ==================================================
 @<COPYRIGHT>@
*/

#ifndef TEAMCENTER_SERVICES_CUSTOM_2021_12_WEIGHTMANAGEMENT_IMPL_HXX 
#define TEAMCENTER_SERVICES_CUSTOM_2021_12_WEIGHTMANAGEMENT_IMPL_HXX


#include <weightmanagement2112.hxx>

#include <Custom_exports.h>

namespace SR5
{
    namespace Soa
    {
        namespace Custom
        {
            namespace _2021_12
            {
                class WeightManagementImpl;
            }
        }
    }
}


class SOACUSTOM_API SR5::Soa::Custom::_2021_12::WeightManagementImpl : public SR5::Soa::Custom::_2021_12::WeightManagement

{
public:

    virtual WeightManagementImpl::WeightResponse calculateAndSetWeight ( const std::string uid );


};

#include <Custom_undef.h>
#endif
