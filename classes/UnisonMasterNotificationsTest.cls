/**
 * Created by Eliot Rojas on 6/28/2019.
 */
@isTest
private with sharing class UnisonMasterNotificationsTest {

    @testSetup static void setup() {
        Account newAcc = new Account (Name='Test Account');
        insert newAcc;
        Id homeOwnerRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

        Opportunity newOppty = new Opportunity();
        newOppty.Name = 'Test Opportunity';
        newOppty.AccountId = newAcc.Id;
        newOppty.StageName = 'Ready for Ops';
        newOppty.CloseDate = System.today();
        newOppty.Process_Program_Knowledge_Review__c = false;
        newOppty.RecordTypeId = homeOwnerRT;
        newOppty.Appraisal_Received__c = true;
        newOppty.Appraisal_Ordered__c = true;
        newOppty.Second_Appraisal_Ordered__c = true;
        newOppty.Second_Appraisal_Received__c = true;
        newOppty.Home_Inspection_Ordered__c = true;
        newOppty.Home_Inspection_Received__c = true;
        newOppty.Property_Report_Ordered__c = true;
        newOppty.Property_Report_Received__c = true;
        newOppty.DMA_Count__c = 3;
        newOppty.CloseDate = system.today() + 5;
        newOppty.Summary_Appraised_Value__c = 120;
        newOppty.OAV_Discount_Pct__c = 20;
        newOppty.Pricing_Ratio__c = 15.0;
        newOppty.Maximum_Authorized_DTI__c = 15.0;
        newOppty.Maximum_Authorized_LTV__c = 16.0;
        newOppty.Final_OAV_Calculation__c = 10.0;
        newOppty.Estimated_Funding_Amount__c = 110.0;
        newOppty.Maximum_Authorized_DTI__c = 15.0;
        newOppty.Maximum_Authorized_LTV__c = 16.0;
        newOppty.Payment_Monthly_First_Mortgage__c = 1.0;
        insert newOppty;

        Success_Factor__c SF = new Success_Factor__c();
        SF.Success_Factor__c = 'LTV';
        SF.Program__c = 'HO';
        SF.Opportunity__c = newOppty.Id;
        SF.Status__c = 'In Progress';
        insert SF;
    }

    @IsTest
    static void testBehaviorInsert_Requirement() {
        Opportunity myOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Success_Factor__c successFactor = [SELECT Id, Name, Opportunity__c FROM Success_Factor__c WHERE Opportunity__c =: myOpportunity.Id LIMIT 1];
        Current_Conditions__c newReq = new Current_Conditions__c();
        newReq.Opportunity__c = myOpportunity.Id;
        newReq.Code__c = 'R1048';
        newReq.Success_Factor__c = successFactor.Id;
        newReq.Status__c = 'Ready to Review';

        Test.startTest();
        insert newReq;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_Requirement() {
        Opportunity myOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Success_Factor__c successFactor = [SELECT Id, Name, Opportunity__c FROM Success_Factor__c WHERE Opportunity__c =: myOpportunity.Id LIMIT 1];
        Current_Conditions__c newReq = new Current_Conditions__c();
        newReq.Opportunity__c = myOpportunity.Id;
        newReq.Code__c = 'R1048';
        newReq.Success_Factor__c = successFactor.Id;
        newReq.Status__c = 'Ready to Review';
        insert newReq;

        Test.startTest();
        newReq.Status__c = 'Waived';
        update newReq;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_ProjectTask_Completed() {
        Opportunity myOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Success_Factor__c successFactor = [SELECT Id, Name, Opportunity__c FROM Success_Factor__c WHERE Opportunity__c =: myOpportunity.Id LIMIT 1];
        Current_Conditions__c newReq = new Current_Conditions__c();
        newReq.Opportunity__c = myOpportunity.Id;
        newReq.Code__c = 'R1048';
        newReq.Success_Factor__c = successFactor.Id;
        newReq.Status__c = 'Ready to Review';
        insert newReq;

        Project_Task__c pTask = new Project_Task__c();
        pTask.Opportunity__c = myOpportunity.Id;
        pTask.Name = 'TestPT2';
        pTask.Code__c = 'T10013';
        pTask.Requirement__c = newReq.Id;
        insert pTask;

        Test.startTest();
	/*Caro Veliz: BUS-155110073*/
        //pTask.Completed__c = true;
        pTask.Status__c = 'Completed';
        update pTask;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_SuccessFactor_Status() {
        Opportunity myOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Success_Factor__c successFactor = [SELECT Id, Name, Opportunity__c, Status__c FROM Success_Factor__c WHERE Opportunity__c =: myOpportunity.Id LIMIT 1];

        Test.startTest();
        successFactor.Status__c = '';
        update successFactor;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_SuccessFactor_Completed() {
        Opportunity myOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Success_Factor__c successFactor = [SELECT Id, Name, Opportunity__c, Status__c FROM Success_Factor__c WHERE Opportunity__c =: myOpportunity.Id LIMIT 1];

        Test.startTest();
        successFactor.Status__c = 'Completed';
        update successFactor;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_FieldChanges() {
        Opportunity myOpportunity = [SELECT Id, Name, StageName, MAD__c, Pricing_Ratio__c, Program_Floor__c, Estimated_Funding_Amount__c,
                UnisonProcessor__c, Investment_Analyst2__c, Final_OAV_Calculation__c, Wire_to_Agent_Date__c, Post_Close_Specialist__c, Sales_Director__c
        FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];

        Test.startTest();
        myOpportunity.MAD__c = 120;
        myOpportunity.Pricing_Ratio__c = 13;
        myOpportunity.Program_Floor__c = '';
        myOpportunity.Estimated_Funding_Amount__c = 1;
        myOpportunity.Wire_to_Agent_Date__c = system.today() + 2;
        myOpportunity.Final_OAV_Calculation__c = 122;
        myOpportunity.UnisonProcessor__c = UserInfo.getUserId();
        myOpportunity.Investment_Analyst2__c = UserInfo.getUserId();
        myOpportunity.Post_Close_Specialist__c = UserInfo.getUserId();
        myOpportunity.Sales_Director__c = UserInfo.getUserId();
        myOpportunity.Approval_Status__c = 'Approved';
        update myOpportunity;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_FieldChanges2() {
        Opportunity myOpportunity = [SELECT Id, Name, StageName, MAD__c, Pricing_Ratio__c, Program_Floor__c, Estimated_Funding_Amount__c,
                UnisonProcessor__c, Investment_Analyst2__c, Final_OAV_Calculation__c, Wire_to_Agent_Date__c, Post_Close_Specialist__c, Sales_Director__c
        FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];

        Test.startTest();
        myOpportunity.Approval_Status__c = 'Denied';
        myOpportunity.Process_Program_Knowledge_Review__c = true;
        myOpportunity.StageName = 'Closed Lost';
        myOpportunity.Loss_Type__c = 'Declined';
        myOpportunity.Loss_Reason_Code__c = 'Bankruptcy';
        myOpportunity.Wire_to_Agent_Date__c = system.today();
        update myOpportunity;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_StageChange() {
        Opportunity myOpportunity = [SELECT Id, Name, StageName, MAD__c, Pricing_Ratio__c, Program_Floor__c, Estimated_Funding_Amount__c,
                UnisonProcessor__c, Investment_Analyst2__c, Final_OAV_Calculation__c, Wire_to_Agent_Date__c, Post_Close_Specialist__c, Sales_Director__c, OwnerId
        FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];

        myOpportunity.StageName = 'Investment Due Dilligence';
        update myOpportunity;

        Test.startTest();
        UnisonMasterNotificationsWrapper.ManageNotificationsForOpportunityStage(new List<Opportunity> { myOpportunity });
        Test.stopTest();
    }
    @IsTest
    static void testStipulations() {
        Opportunity myOpportunity = [SELECT Id, Name, StageName, MAD__c, Pricing_Ratio__c, Program_Floor__c, Estimated_Funding_Amount__c,
                UnisonProcessor__c, Investment_Analyst2__c, Final_OAV_Calculation__c, Wire_to_Agent_Date__c, Post_Close_Specialist__c, Sales_Director__c, OwnerId
        FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];

        UnisonMasterNotifications.ManageNotificationsForStipulations(myOpportunity.id,'Post to chatter');

    }


}