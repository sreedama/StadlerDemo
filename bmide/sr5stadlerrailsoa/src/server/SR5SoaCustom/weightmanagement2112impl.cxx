/* 
 @<COPYRIGHT>@
 ==================================================
 Copyright 2012
 Siemens Product Lifecycle Management Software Inc.
 All Rights Reserved.
 ==================================================
 @<COPYRIGHT>@
*/

#include <unidefs.h>
#if defined(SUN)
#include <unistd.h>
#endif

#include <weightmanagement2112impl.hxx>
#include <sr5_register_callbacks.h>


using namespace SR5::Soa::Custom::_2021_12;
using namespace Teamcenter::Soa::Server;

WeightManagementImpl::WeightResponse WeightManagementImpl::calculateAndSetWeight ( const std::string uid )
{
	WeightManagementImpl::ErrorResponse errorResponse;
	WeightManagementImpl::DataResponse dataResponse;
	WeightManagementImpl::WeightResponse weightResponse;

	int iErrorCode = NULL;
	char *sErrorText = NULL;
	double dWeight = 0;

	// Here we switch to our external ITK code base
	// We perform a syslog before and after calling the external ITK function.
	TC_write_syslog("Stadler Rail SOA Weight Management: Before calling ITK function sr5_calculate_weight\n");
	sr5CalculateAndSetWeight(uid.c_str(), &iErrorCode, &sErrorText, &dWeight);
	TC_write_syslog("Stadler Rail SOA Weight Management: After calling ITK function sr5_calculate_weight\n");


	errorResponse.errorCode = iErrorCode != 0 ? iErrorCode : 0;
	errorResponse.errorText = sErrorText != NULL ? sErrorText : "NULL";

	dataResponse.weight = dWeight;

	weightResponse.errorResponse = errorResponse;
	weightResponse.dataResponse = dataResponse;

	return weightResponse;
}



