@isTest
private class GetDocumentsControllerTest 
{	
	@isTest static void test_method_one() 
    {
		// Data Setup
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

        Property_Due_Diligence_Reports__c pddr = new Property_Due_Diligence_Reports__c();
        pddr.Spruce_Order_Id__c = 'testOrderInfo';
        pddr.Opportunity__c = oppty.Id;
        insert pddr;

        GetDocumentsController.DocumentTypeWrapper dtw = new GetDocumentsController.DocumentTypeWrapper();
        dtw.isChecked = true;
        dtw.documentType = 'testDocumentType';

        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());

        // Run Code
        ApexPages.StandardController sc = new ApexPages.StandardController(pddr);

        PageReference pageRef = Page.GetDocuments;
        pageRef.getParameters().put('id', String.valueOf(pddr.Id));
        Test.setCurrentPage(pageRef);
		
        GetDocumentsController.getSpruceCredentials();
        GetDocumentsController ctrl = new GetDocumentsController(sc);
        ctrl.GetRecordTypes();
        ctrl.documentTypeWrapperList.add(dtw);
        //ctrl.GetDocuments();
        ctrl.goBack();
       

        // Test Result
        //System.assertEquals(ctrl.attachmentList.size(), 1);*/
	}	
}