public with sharing class GetOrderAppraisalStatusController 
{
    public Id appraisalId {get; set;}

    public GetOrderAppraisalStatusController(ApexPages.StandardController stdController) 
    {
        appraisalId = ((Appraisal__c)stdController.getRecord()).Id;
    }

    public PageReference GetOrderStatus()
    {   
        List<Appraisal__c> appraisalList =
            [
                SELECT Id, MercuryTrackingId__c
                FROM Appraisal__c
                WHERE Id = :appraisalId
            ];/* 4/2/2019 Sundar Subramaniam - Removed "Mercury_Status__c" field from query for Data Model Cleanup */

        if(appraisalList.size() > 0 && appraisalList[0].MercuryTrackingId__c != null)
        {
            MercuryAPICustom.GetCurrentStatusResponse serverResponse = MercuryHelper.GetCurrentStatus(appraisalList[0].MercuryTrackingId__c);
        
            // if no error was encounter
            if(serverResponse.errorMessage == '')
            {                      
                //appraisalList[0].Mercury_Status__c = serverResponse.status;/* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */

                update appraisalList[0];

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The record info were updated successfully.'));
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred: ' + serverResponse.errorMessage));
            }
        }
        else
        {      
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Tracking Id found for the current appraisal record!'));
        }

        return null;
    }

    public PageReference goBack()
    {
        PageReference url = new PageReference('/'+ appraisalId);
        url.setRedirect(true);
        return url;
    }
}