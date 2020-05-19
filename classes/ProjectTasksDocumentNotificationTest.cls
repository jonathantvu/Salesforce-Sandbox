/**
 * Created by Eliot Rojas on 5/2/2019.
 */

@IsTest
private class ProjectTasksDocumentNotificationTest {

    @testSetup static void setup() {
        /*     EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'Pest_Inspection_Received');
             insert e;
     */
        Id homeOwnerRT_Lead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        Lead newLead = new Lead();
        newLead.LastName = 'Doe';
        newLead.Company = 'TestCo';
        newLead.RecordTypeId = homeOwnerRT_Lead;
        newLead.Income_Monthly_Base__c = 100;
        insert newLead;

        Account newAcc = new Account (Name='Test Account');
        insert newAcc;
        Id homeOwnerRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

        Opportunity newOppty = new Opportunity();
        newOppty.Name = 'Test Opportunity';
        newOppty.AccountId = newAcc.Id;
        newOppty.StageName = 'Submit to Ops';
        newOppty.CloseDate = System.today();
        newOppty.UnisonProcessor__c = UserInfo.getUserId();
        newOppty.Investment_Analyst2__c = UserInfo.getUserId();
        newOppty.Process_Program_Knowledge_Review__c = true;
        newOppty.RecordTypeId = homeOwnerRT;
        newOppty.Process_Program_Knowledge_Review__c = true;
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
        newOppty.Wire_to_Agent_Date__c = system.today();
        newOppty.Pricing_Ratio__c = 15.0;
        newOppty.Maximum_Authorized_DTI__c = 15.0;
        newOppty.Maximum_Authorized_LTV__c = 16.0;
        newOppty.Final_OAV_Calculation__c = 10.0;
        newOppty.Wire_to_Agent_Date__c = system.today();
        newOppty.Estimated_Funding_Amount__c = 110.0;
        newOppty.Maximum_Authorized_DTI__c = 15.0;
        newOppty.Maximum_Authorized_LTV__c = 16.0;
        insert newOppty;

        Success_Factor__c SF = new Success_Factor__c();
        SF.Success_Factor__c = 'LTV';
        SF.Program__c = 'HO';
        SF.Opportunity__c = newOppty.Id;
        SF.Lead__c = newLead.Id;
        SF.Status__c = 'In Progress';
        insert SF;

        Current_Conditions__c newReq = new Current_Conditions__c();
        newReq.Opportunity__c = newOppty.Id;
        newReq.Requirement__c = '1040';
        newReq.Success_Factor__c = SF.Id;
        newReq.Status__c = 'Ready to Review';
        insert newReq;

        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT2';
        PT.Code__c = 'T10156';
        //PT.Completed__c = false;
        PT.Status__c = 'In Progress';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        insert PT;
    }

    // ON INSERT
    @IsTest
    static void testBehaviorInsert_Pest_Inspection() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10156';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_Appraisal_1004D() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10105';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_Natural_Hazard_Disclosure() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10093';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_HOA_Questionaire() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10010';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_Vesting_Addendum() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10079';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_Lender_Final_1003() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10196';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_Lender_Final_1008() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10113';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorInsert_RSI_Letter() {
        Opportunity newOppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Current_Conditions__c newReq = [SELECT Id, Opportunity__c FROM Current_Conditions__c WHERE  Opportunity__c =: newOppty.Id LIMIT 1];
        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT';
        PT.Code__c = 'T10182';
        //PT.Completed__c = true;
        PT.Status__c = 'Completed';
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        Test.startTest();
        insert PT;
        Test.stopTest();
    }

    // ON UPDATE
    @IsTest
    static void testBehaviorUpdate_Occupancy() {
        Test.startTest();
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId, Opportunity__c,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];

        // Related Req
        Current_Conditions__c req = [SELECT Id, Status__c, Opportunity__c FROM Current_Conditions__c WHERE Opportunity__c =: refreshedPT.Opportunity__c LIMIT 1];
        req.Status__c = '';
        req.Requirement__c = 'Certificate of Occupancy';


        refreshedPT.Code__c = 'T10158';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';


        update req;
        upsert refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_Pest_Inspection() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];

        refreshedPT.Code__c = 'T10156';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        upsert refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_Appraisal_1004D() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];
        refreshedPT.Code__c = 'T10158';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        update refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_Natural_Hazard_Disclosure() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];
        refreshedPT.Code__c = 'T10158';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        update refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_HOA_Questionaire() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];
        refreshedPT.Code__c = 'T10158';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        update refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_Vesting_Addendum() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];
        refreshedPT.Code__c = 'T10196';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        update refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_Lender_Final_1003() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];
        refreshedPT.Code__c = 'T10084';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        update refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_Lender_Final_1008() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];
        refreshedPT.Code__c = 'T10086';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        update refreshedPT;
        Test.stopTest();
    }

    @IsTest
    static void testBehaviorUpdate_RSI_Letter() {
        Project_Task__c refreshedPT = [SELECT Id, Name, Code__c, /*Completed__c*/Status__c, Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                Requirement__r.Success_Factor__r.Lead__r.OwnerId,
                Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId FROM Project_Task__c WHERE Name = 'TestPT2'];
        refreshedPT.Code__c = 'T10084';
        //refreshedPT.Completed__c = true;
        refreshedPT.Status__c = 'Completed';

        Test.startTest();
        update refreshedPT;
        Test.stopTest();
    }
}