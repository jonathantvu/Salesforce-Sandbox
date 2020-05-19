/**
 * Created by Ivan Garcia on 5/21/2019.
 */

@IsTest public with sharing class DealHistoryTriggerHandlerTest {
    @TestSetup private static void Testdata() {
        Account newAcc = new Account (Name='Test Account');
        insert newAcc;
        Id homeOwnerRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        Opportunity newOppty = new Opportunity();
        newOppty.Name = 'Test Opportunity';
        newOppty.AccountId = newAcc.Id;
        newOppty.StageName = 'Investment Due Diligence';
        newOppty.CloseDate = System.today();
        newOppty.UnisonProcessor__c = UserInfo.getUserId();
        newOppty.Investment_Analyst2__c = UserInfo.getUserId();
        newOppty.Process_Program_Knowledge_Review__c = false;
        newOppty.Appraisal_Received__c = false;
        newOppty.Appraisal_Ordered__c = false;
        newOppty.Second_Appraisal_Ordered__c = false;
        newOppty.Second_Appraisal_Received__c = false;
        newOppty.Home_Inspection_Ordered__c = false;
        newOppty.Home_Inspection_Received__c = false;
        newOppty.Property_Report_Ordered__c = false;
        newOppty.Property_Report_Received__c = false;
        newOppty.IA_OAV_Override__c = 10.0;
        newOppty.Estimated_Funding_Amount__c = 11.0;
        newOppty.Pricing_Ratio__c = 10.0;
        newOppty.CloseDate = system.today() + 2;
        newOppty.DMA_Count__c = 0;
        newOppty.RecordTypeId = homeOwnerRT;
        insert newOppty;

        Success_Factor__c tmpSucc = new Success_Factor__c(Success_Factor__c = 'Final Approval', Opportunity__c = newOppty.id);
        insert tmpSucc;

        Deal_History__c DH = new Deal_History__c();
        DH.Opportunity__c = newOppty.Id;
        DH.Passbook_Status__c = 'Approved';
        DH.Post_Close_LTV__c = 10;
        insert DH;
    }

    @IsTest private static void mainTest() {
        Opportunity tmpOpp = [SELECT id,recordtype.name FROM Opportunity LIMIT 1];
        Id RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        tmpOpp.RecordTypeId = RT;
        update tmpOpp;
        system.debug('tmpOpp: '+tmpOpp);

        Deal_History__c tmpDH = [SELECT id,Passbook_Status__c FROM Deal_History__c LIMIT 1];
        tmpDH.FICO__c = 1;
        tmpDH.Post_Close_LTV__c = 11;
        update tmpDH;
    }
}