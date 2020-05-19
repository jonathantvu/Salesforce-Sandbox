/**
 * Created by Ivan Garcia on 5/23/2019.
 */

@IsTest public with sharing class RequestRSIControllerTest {

    @testSetup static void setup(){
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;

        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Post-Closing',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = 'Condominium',
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,Lien_First_Lender_Balance__c = 100, Title_Held__c = 'In Trust');
        insert oppty;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = oppty.Id;
        sf1.Success_Factor__c  = 'Post-Closing';
        sf1.Status__c = 'In Progress';
        Insert sf1;

        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'RSI Letter';
        req2.Success_Factor__c  = sf1.Id;
        req2.Status__c = 'Document Received, In progress';
        req2.Reason__c  = 'test';
        req2.RSI_Eligible__c = true;
        req2.opportunity__c      = oppty.id;
        Insert req2;

        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT2';
        PT.Code__c = 'T10182';
        PT.Status__c = 'In Progress';
        PT.Requirement__c = req2.Id;
        PT.Opportunity__c = oppty.Id;
        insert PT;
    }

    @IsTest static void test0(){
        RequestRSIController ctrl = new RequestRSIController();
        ctrl.saveReq();
    }

    @IsTest static void testData(){
        Opportunity tmpOpp = [SELECT id FROM Opportunity LIMIT 1];
        ApexPages.currentPage().getParameters().put('id',tmpOpp.Id);
        RequestRSIController ctrl = new RequestRSIController();
        //ctrl.recordid = tmpOpp.id;
        ctrl.saveReq();
        ctrl.propertyReportIsReady();
    }

    @IsTest static void testNullReason(){
        Current_Conditions__c tmpCondition = [SELECT id FROM Current_Conditions__c LIMIT 1];
        tmpCondition.Reason__c = null;
        update tmpCondition;

        Opportunity tmpOpp = [SELECT id FROM Opportunity LIMIT 1];
        ApexPages.currentPage().getParameters().put('id',tmpOpp.Id);
        RequestRSIController ctrl = new RequestRSIController();
        ctrl.prjtask = null;
        ctrl.completeReportsTask = 'true';
        ctrl.saveReq();
        ctrl.completeRSIOnly();
    }

    @IsTest static void testCompletePropertyReportTask(){
        Current_Conditions__c tmpCondition = [SELECT id FROM Current_Conditions__c LIMIT 1];
        tmpCondition.Reason__c = null;
        update tmpCondition;

        Opportunity tmpOpp = [SELECT id FROM Opportunity LIMIT 1];
        ApexPages.currentPage().getParameters().put('id',tmpOpp.Id);
        RequestRSIController ctrl = new RequestRSIController();
        ctrl.isPropertyReportCompleted = true;
        ctrl.completeReportsTask = 'true';
        ctrl.orderPropertyReports = 'true';
        ctrl.prjtask = null;
        ctrl.completeProjectTask();
    }
}