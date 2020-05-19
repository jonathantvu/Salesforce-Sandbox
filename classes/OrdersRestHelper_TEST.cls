/**********************************************************
 * Class 	 	: OrdersRestHelper_TEST.cls
 * Created Date	: February 19, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: This class provide test methods for OrdersRestHelper.cls
 *
 *
 **********************************************************/ 

@isTest 
private class OrdersRestHelper_TEST {

	@isTest
	private static void testName() {
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
			Test.setMock(HttpCalloutMock.class, new HCCalloutMockImpl());

			OrdersRestHelper orderRest = new OrdersRestHelper();
			String jsonToSend = orderRest.serializeOrder(pddrRep);
			orderRest.SubmitOrders(jsonToSend);
			orderRest.ValidateOrder('107');
			orderRest.RejectOrder('107');
			orderRest.CancelOrder('107');
			orderRest.UpdateOrderItem('107','135');
			orderRest.retriveOrderItem('107');
			orderRest.CheckPermissions();

		System.Test.stopTest();

		System.assert(String.isNotBlank(jsonToSend));
	}
}