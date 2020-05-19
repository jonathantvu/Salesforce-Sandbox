/**
 * Created by Ivan Garcia on 5/22/2019.
 */

@IsTest public with sharing class OpportunityTaskListTest {
    @testSetup static void setup(){
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;

        /* 4/2/2019 Sundar Subramaniam - Is_there_Co_App__c removed from query for Data Model Cleanup */
        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id, IA_OAV_Override__c = 2,
                Co_Applicant__c = con2.Id);
        insert oppty;
    }

    @isTest private static void test0(){
        Opportunity tmpOpp = [SELECT id FROM Opportunity LIMIT 1];
        OpportunityTaskList ctrl = new OpportunityTaskList(new ApexPages.StandardController(tmpOpp));
        ctrl.message = 'test';
        ctrl.save();
    }
}