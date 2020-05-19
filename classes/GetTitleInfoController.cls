public with sharing class GetTitleInfoController 
{
    public Id propertyDueDiligenceId {get; set;}

	public GetTitleInfoController(ApexPages.StandardController stdController) 
    {
        propertyDueDiligenceId = ((Property_Due_Diligence_Reports__c)stdController.getRecord()).Id;
	}

    public PageReference UpdateRecordInfo()
    {   
        List<Property_Due_Diligence_Reports__c> pddrList =
            [
                SELECT Id, Status__c, Spruce_Order_Id__c
                FROM Property_Due_Diligence_Reports__c
                WHERE Id = :propertyDueDiligenceId
            ];

        if(pddrList.size() > 0)
        {
            if(pddrList[0].Status__c != 'new' && pddrList[0].Status__c != 'initial_docs_available')
            {
                if(String.isEmpty(pddrList[0].Spruce_Order_Id__c))
                { 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This record has no Order Id.'));
                }
                else
                {                    
                    SpruceAPI.GetTitleReportDataResponse serverResponse = SpruceHelper.GetTitleReportData(pddrList[0].Spruce_Order_Id__c);

                    // if no error was encounter
                    if(String.isEmpty(serverResponse.errorMessage))
                    {       
                        if(!String.isEmpty(serverResponse.effective_date))
                        {
                            pddrList[0].Effective_Date__c = Date.valueOf(serverResponse.effective_date);                       
                        }
                        
                        pddrList[0].Property_Legal_Description__c = serverResponse.legal_description;
                        pddrList[0].Property_Parcel_Number__c = serverResponse.apn;

                        update pddrList[0];

                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The record info were updated successfully.'));
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred: ' + serverResponse.errorMessage));
                    }
                }
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The status for this record must be \'Title Report Available\' or higher.'));
            }
        }

        return null;
    }

    public PageReference goBack()
    {
        PageReference url = new PageReference('/'+ propertyDueDiligenceId);
        url.setRedirect(true);
        return url;
    }
}