@isTest
public class OpportunitySyncBatchTest {
    
    public static testMethod void Test_Success() {
        
        // Data setup
        Account ac1 = new Account();
        ac1.Name = 'Test498043';
        insert ac1;
        
        Opportunity op1 = new Opportunity();
        op1.AccountId = ac1.Id;
        op1.Name = 'Test681108';
        op1.StageName = 'Post-Closing';
        op1.Wire_Reference_Number__c = '1234';
        op1.CloseDate = Date.today();
        insert op1;

        Test.setMock(HttpCalloutMock.class, new AccountUtilityClassTest.MockClass(op1.Id));
        
        // Run the code
        Test.startTest();
        (new OpportunitySyncBatch()).execute(null);
        Test.stopTest();
        
        // Verify Results 
        op1 = [SELECT SFDC2_Opportunity_Id__c FROM Opportunity WHERE Id = :op1.Id];
        System.assertEquals('0061700000LSODhAAP', op1.SFDC2_Opportunity_Id__c);

        SFDC_to_SFDC_Log__c log = [SELECT Response_Code__c FROM SFDC_to_SFDC_Log__c LIMIT 1];
        System.assertEquals(200, log.Response_Code__c);
        
    }

    public static testMethod void Test_Error() {
        
        // Data setup
        Account ac1 = new Account();
        ac1.Name = 'Test498043';
        insert ac1;
        
        Opportunity op1 = new Opportunity();
        op1.AccountId = ac1.Id;
        op1.Name = 'Test681108';
        op1.StageName = 'Post-Closing';
        op1.Wire_Reference_Number__c = '1234';
        op1.CloseDate = Date.today();
        insert op1;

        Test.setMock(HttpCalloutMock.class, new AccountUtilityClassTest.MockClass(null));
        
        // Run the code
        Test.startTest();
        (new OpportunitySyncBatch()).execute(null);
        Test.stopTest();
        
        // Verify Results 
        SFDC_to_SFDC_Log__c log = [SELECT Response_Code__c FROM SFDC_to_SFDC_Log__c LIMIT 1];
        System.assertEquals(500, log.Response_Code__c);
        
    }
    
}