/**********************************************************
 * @className   : YodleeWebhook.cls
 * @testClass   : YodleeWebhook_TEST.cls
 * @date        : May 7, 2018
 * @description : This class provide test methods for YodleeWebhook.cls
 *
 *
 **********************************************************/ 

@isTest 
private class YodleeWebhook_TEST {

	@isTest
	private static void testName() {

		Account acc = new Account(Name = 'New Account');
		insert acc; 

		Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
		                          AccountID = acc.Id);
		insert con;

		Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
		                          AccountID = acc.Id);
		insert con2;

		Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', 
									CloseDate = Date.today().addDays(20), Is_there_Co_App__c = true, Applicant__c = con.Id,
									Co_Applicant__c = con2.Id);
		insert oppty;

		Yodlee_Order_Request__c yor = new Yodlee_Order_Request__c();
		yor.Opportunity__c = oppty.Id;
		yor.Name = 'YOR Name';
		yor.Yodlee_Public_Id__c = '6f098ce4-a14f-4604-622e-a0ab76d557dd';
		insert yor;

		YodleeAPI.Webhook_Order webhookOrder = new YodleeAPI.Webhook_Order();
		webhookOrder.order_id = '6f098ce4-a14f-4604-622e-a0ab76d557dd';
		webhookOrder.status = '2';
		
		System.Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Yodlee/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(webhookOrder));
        RestContext.request = req;
        RestContext.response = res;

        YodleeWebhook.UpdateOrderStatus();

        System.Test.stopTest();

		Yodlee_Order_Request__c yOrdReq = [Select Id, Status__c from Yodlee_Order_Request__c Where ID =: yor.ID];
		System.assertEquals(yOrdReq.Status__c, 2);

	}
}