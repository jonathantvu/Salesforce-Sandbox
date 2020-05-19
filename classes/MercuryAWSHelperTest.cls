/**
 * Created by Ivan Garcia on 5/22/2019.
 */

@IsTest public with sharing class MercuryAWSHelperTest {
    @testSetup static void setup(){
        Account acc  = new Account(Name = 'acc test');
        insert acc;

        Opportunity opp  = new opportunity(Name = 'opp test', AccountId = acc.Id, StageName= 'Closed Won', CloseDate = System.today());
        insert opp;

        Appraisal__c tmpApp = new Appraisal__c(Appraisal_Status__c = 'Ordered', Opportunity__c = opp.Id);
        insert tmpApp;
    }

    @isTest private static void test0(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        Test.startTest();
        Appraisal__c tmpApp = [SELECT id FROM Appraisal__c LIMIT 1];
        MercuryAWSHelper.CallAWS(tmpApp.id);
        Test.stopTest();
    }
}