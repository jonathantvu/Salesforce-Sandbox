@isTest
private class GetTitleInfoControllerTest 
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
        pddr.Status__c = 'Ordered';
        insert pddr;

        Property_Due_Diligence_Reports__c pddr2 = new Property_Due_Diligence_Reports__c();
        pddr2.Opportunity__c = oppty.Id;
        pddr2.Status__c = 'Ordered';
        insert pddr2;

        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());

        // Run Code
		ApexPages.StandardController sc = new ApexPages.StandardController(pddr);

        PageReference pageRef = Page.GetTitleInfo;
        pageRef.getParameters().put('id', String.valueOf(pddr.Id));
        Test.setCurrentPage(pageRef);

        GetTitleInfoController ctrl = new GetTitleInfoController(sc);
        ctrl.UpdateRecordInfo();
        ctrl.goBack();

        // Verify Result
        List<Property_Due_Diligence_Reports__c> pddrList = 
            [
                SELECT Id, Property_Parcel_Number__c
                FROM Property_Due_Diligence_Reports__c
            ];

        //System.assertEquals(pddrList[0].Property_Parcel_Number__c, '230-110-023');
	}
}