/* Test class for CN_DocusignStatusTrigger its tandler and helper */
@isTest
private class CN_DocusignStatusTrigger_Test {
    
    @testsetup
    private static void createTestData() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.Today().addMonths(3);
        opp.StageName = 'New';
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        //opp.Converted_Close_Date__c = System.Today().addMonths(3);
        insert opp;
        
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        dsStatus.dsfs__Envelope_Status__c = CN_Constants.DSFS_SENT;
        dsStatus.dsfs__Opportunity__c = opp.Id;
        insert dsStatus;
    }
    
    //Test when envelope is sent and opportunity is updated
    private static testMethod void testOppStageUpdateOnSent() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       
        Test.startTest();
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        dsStatus.dsfs__Opportunity__c = opp.Id;
        dsStatus.dsfs__Envelope_Status__c = CN_Constants.DSFS_SENT;
        insert dsStatus;
         System.Debug('## dsStatus: '+dsStatus);
        Test.stopTest();
    }
    
    //Test when envelope is xompleted and opportunity is updated
    private static testMethod void testOppStageUpdateOnCompleted() {
        dsfs__DocuSign_Status__c testDS1 = [Select dsfs__Envelope_Status__c, Id, dsfs__Opportunity__c from dsfs__DocuSign_Status__c Limit 1];
        testDS1.dsfs__Envelope_Status__c = CN_Constants.DSFS_COMPLETED;
        update testDS1;
    }

}