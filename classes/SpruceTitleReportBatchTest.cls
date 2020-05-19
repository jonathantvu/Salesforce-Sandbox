@isTest
private class SpruceTitleReportBatchTest 
{	
	@isTest static void test_method_one() 
    {
        // Data Setup
        Id devRecordTypeId = Schema.SObjectType.Property_Due_Diligence_Reports__c.getRecordTypeInfosByName().get('Spruce Order').getRecordTypeId();

        Account acc = new Account(Name = 'New Account');
        insert acc; 

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com', AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com', AccountID = acc.Id);
        insert con2;

        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', CloseDate = Date.today().addDays(20), Is_there_Co_App__c = true, Applicant__c = con.Id, Co_Applicant__c = con2.Id);
        oppty.UnisonProcessor__c = UserInfo.getUserId();
        insert oppty;

        Property_Due_Diligence_Reports__c ppdr = new Property_Due_Diligence_Reports__c();
        ppdr.Spruce_Title_Report_Downloaded__c = false;
        ppdr.Opportunity__c = oppty.Id;
        ppdr.Spruce_Order_Id__c = 'testOrderId';
        ppdr.Status__c = 'title_report_available';
        ppdr.RecordTypeId = devRecordTypeId;
        insert ppdr;

        // Test Code
        Test.startTest();       
            Database.executeBatch(new SpruceTitleReportBatch(), 10);
        Test.stopTest();
	}
}