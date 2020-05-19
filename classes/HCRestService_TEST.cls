/**********************************************************
 * Class        : HCRestService_TEST.cls
 * Created Date : February 20, 2018
 * Modified by  : -
 * Modified Date: -
 * Objective    : This class provide test methods for HCRestService.cls
 *
 *
 **********************************************************/ 

@isTest 
private class HCRestService_TEST {

    @isTest
    private static void testName() {
        
		DelightedHelper.skipCall = true;
        
        Account acc = new Account(Name = 'New Account');
        insert acc; 
        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                                  AccountID = acc.Id);
        insert con;
        
        Opportunity oppty = new Opportunity(Name = 'test oppty', AccountId = acc.Id, StageName = 'Submit to Ops', CloseDate = Date.today());
        insert oppty;

        Property_Due_Diligence_Reports__c pddrRep = new Property_Due_Diligence_Reports__c();
        pddrRep.House_Canary_Order_Id__c = '27';
        pddrRep.House_Canary_Status__c = 'ClientReview';
        pddrRep.Opportunity__c = oppty.ID;
        insert pddrRep;

        OrdersRestHelper.HC_Message hcmessage = new OrdersRestHelper.HC_Message();
        hcmessage.order_id = '27';
        hcmessage.message_id = '13840';
        hcmessage.new_status = 'ClientReview';
        hcmessage.customer_item_id = pddrRep.Id;

        System.Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/HouseCanary/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(hcmessage));
        RestContext.request = req;
        RestContext.response = res;

        HCRestService.OrderValidation();

        System.Test.stopTest();

        List<Property_Due_Diligence_Reports__c> pddrList = [Select Id, House_Canary_Order_Validation_Results__c FROM Property_Due_Diligence_Reports__c
                                                                                    WHERE Id= :pddrRep.Id];
        System.assert(pddrList.get(0).House_Canary_Order_Validation_Results__c != null);

        List<Webhook_Log__c> logs = [Select Id from Webhook_Log__c];
        System.assert(logs.size() > 0);
                            
    }
}