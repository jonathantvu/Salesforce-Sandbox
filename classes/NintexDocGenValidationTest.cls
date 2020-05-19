@isTest
public class NintexDocGenValidationTest {
    
    @isTest
	public static void Test_Success() {
		
		// Data setup
		Account acc = new Account();
        acc.Name = 'Test123452';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test435733';
        opp.AccountId = acc.Id;
        opp.StageName = 'Introduction';
        opp.CloseDate = System.today();
        opp.Property_Street_Number_and_Name__c = '10';
        opp.Application_DateTime__c = system.today();
        opp.Property_City__c = 'catest';
        opp.Post_Close_LTV2__c = 1;
        opp.Encompass_Loan_Number__c = '1';
        opp.Wire_to_Agent_Date__c = system.today();
        opp.Approval_Status__c = 'Pending';
        opp.IM_Approved_Date__c = system.today();
        opp.Qualifies_for_New_HomeOwner_Pricing__c = true;
        opp.Final_Title_Held__c = 'test';
        opp.Property_State__c = 'test';
        opp.Property_Zip_Code__c = '12345';
        opp.IA_OAV_Override__c = 10;
        opp.MAD__c = 10;
        opp.Final_OAV_Calculation__c = 10;
        insert opp;
		
		// Run the code
		Test.startTest();
        NintexDocGenValidation ctrl = new NintexDocGenValidation(new ApexPages.StandardController(opp));
        PageReference pr = ctrl.Validate();
		Test.stopTest();
		
		// Verify Results
		System.assertNotEquals(null, pr);
    }
    
    @isTest
	public static void Test_Fail() {
		
		// Data setup
		Account acc = new Account();
        acc.Name = 'Test123452';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test435733';
        opp.AccountId = acc.Id;
        opp.StageName = 'Introduction';
        opp.CloseDate = System.today();
        opp.Property_Street_Number_and_Name__c = '10';
        opp.Application_DateTime__c = system.today();
        opp.Property_City__c = 'catest';
        opp.Post_Close_LTV2__c = 1;
        opp.Encompass_Loan_Number__c = '1';
        opp.Wire_to_Agent_Date__c = system.today();
        opp.Approval_Status__c = 'Pending';
        opp.IM_Approved_Date__c = system.today();
        opp.Qualifies_for_New_HomeOwner_Pricing__c = true;
        opp.Final_Title_Held__c = 'test';
        opp.Property_State__c = 'test';
        opp.Property_Zip_Code__c = '12345';
        insert opp;
		
		// Run the code
		Test.startTest();
        NintexDocGenValidation ctrl = new NintexDocGenValidation(new ApexPages.StandardController(opp));
        PageReference pr = ctrl.Validate();
		Test.stopTest();
		
		// Verify Results
		System.assertEquals(null, pr);
	}


}