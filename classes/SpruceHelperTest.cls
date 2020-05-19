@isTest
private class SpruceHelperTest 
{	
	@isTest static void test_method_one() 
    {
		// Data Setup
        Attachment newAttachment = new Attachment();
        newAttachment.Body = Blob.valueOf('test');

        Account acc = new Account(Name = 'New Account');
        insert acc; 

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com', AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com', AccountID = acc.Id);
        insert con2;

        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', CloseDate = Date.today().addDays(20), Is_there_Co_App__c = true, Applicant__c = con.Id, Co_Applicant__c = con2.Id);
        insert oppty;

        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());

        // Test Code
        SpruceAPI.Fees fees = new SpruceAPI.Fees();
        SpruceAPI.SpruceAddress address = new SpruceAPI.SpruceAddress();
        SpruceAPI.SpruceContact contact = new SpruceAPI.SpruceContact();

        SpruceHelper.CreateRefinanceTransactionQuote(oppty);
        SpruceHelper.CreatePurchaseTransactionQuote();
        SpruceHelper.CreateRefinanceTransactionTitleOrder(oppty);
        SpruceHelper.CreatePurchaseMortgageTransactionTitleOrder();
        SpruceHelper.RetrieveOrderInfo('testOrderInfo');
        SpruceHelper.RetrieveAvailableDocumentTypesForOrder('testOrderInfo');
        SpruceHelper.RetrieveAvailableDocumentOfGivenType('testOrderInfo', 'testDocumentType');
        SpruceHelper.UploadDocument('testOrderInfo', 'testDocumentType', newAttachment);
        SpruceHelper.RetrieveDocumentTypesThatCanBeUploaded();
        SpruceHelper.GetTitleReportData('testOrderInfo');
        SpruceHelper.SubmitSchedulingRequestForLoanClosing('testOrderInfo');
        SpruceHelper.RetrieveClosingInfo('testOrderInfo');
        SpruceHelper.RetrieveClosingInfo('testOrderInfo2');
	}
}