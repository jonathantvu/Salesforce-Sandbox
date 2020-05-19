/************************************************************************************
 Apex Class Name     : DMDTriggerHandlerTest
 Version             : 1.0
 Created Date        : 20th Jan 2019
 Function            : Test Class for DMDTriggerHandler class
 Author              : Neeraja Cherukuri
 
 Modification Log    :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Neeraja Cherukuri            01/20/2019                Original Version
*************************************************************************************
*/
@isTest
public class DMDTriggerHandlerTest
{
    @testsetup static void setup(){
        Account acc          = new Account();
        acc.Name         = 'test acc';
        insert acc;

        Opportunity opp      = new Opportunity();
        opp.AccountId      = acc.Id;
        opp.Name         = 'test opp';
        opp.StageName    = 'Investment Due Diligence';
        opp.CloseDate    = System.today();
        opp.Income_App1__c = 12;
        opp.Income_Co_App1__c =13;
        opp.Additional_Applicant_Income__c = 15;
        opp.Estimated_Funding_Amount__c = 0.6;
        opp.Final_OAV_Calculation__c = 1;
        opp.Pricing_Ratio__c = 1;
        opp.IA_OAV_Override__c = 2;
        insert opp;

        Success_Factor__c sf3     = new Success_Factor__c();
        sf3.Opportunity__c     = opp.Id;
        sf3.Success_Factor__c  = 'Credit';

        insert sf3;

        Current_Conditions__c req1 = new Current_Conditions__c();
        req1.Opportunity__c = opp.Id;
        req1.Requirement__c = 'Credit Supplement';
        req1.Code__c = 'R1022';
        req1.Category__c = 'Mortgage';
        req1.Internal_vs_External__c = 'Internal';
        //req.Assigned_To__c = 'PS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        req1.Success_Factor__c = sf3.Id;
        insert req1;

        Project_Task__c ObjPT = new Project_Task__c();

        ObjPT.Name = 'Request Power of Attorney documents';
        ObjPT.Requirement__c = req1.Id;
        objPT.Document_Upload_Needed__c = true;

        Insert ObjPT;

        /*Caro Veliz: BUS-155110073*/
        //ObjPT.Completed__c = true;
        ObjPT.Status__c = 'Completed';
        /* * */
        ObjPT.Complete_By_User__c = UserInfo.getUserId();
        ObjPT.Completed_Date_Time_Stamp__c = System.now();
        // ObjPT.Requirement__c = req1.Id;
        Update ObjPT;


    }

    static testMethod void CreateDMD(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Current_Conditions__c req1 = [SELECT id FROM Current_Conditions__c LIMIT 1];
        Project_Task__c ObjPT = [SELECT id FROM Project_Task__c LIMIT 1];

        Document_MetaData__c DMD = new Document_MetaData__c();
        DMD.Box_File_Id__c = '369364196050';
        DMD.Box_File_URL__c  = 'https://unison.account.box.com/login?redirect_url=%2Ffile%2F369364196050';
        DMD.Box_Folder_Id__c = '60147005559';
        DMD.Requirement__c = req1.Id;
        DMD.Document_Code__c = '234235';
        DMD.ProjectTask__c =ObjPT.Id;
        DMD.Opportunity__c = opp.Id;

        Insert Dmd;

        Document_MetaData__c objD = new Document_MetaData__c(Id = dmd.Id);
        objD.Box_File_Id__c = '369364196051';
        objD.Box_File_URL__c  = 'https://unison.account.box.com/login?redirect_url=%2Ffile%2F369364196051';
        objD.Box_Folder_Id__c = '60147005560';
        objD.Requirement__c = req1.Id;
        update objD;

        Test.stopTest();
    }

    static testMethod void CreateDMD1(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Current_Conditions__c req1 = [SELECT id FROM Current_Conditions__c LIMIT 1];
        Project_Task__c ObjPT = [SELECT id FROM Project_Task__c LIMIT 1];

        Document_MetaData__c DMD = new Document_MetaData__c();

        DMD.Box_File_Id__c = '369364196050';
        DMD.Box_File_URL__c  = 'https://unison.account.box.com/login?redirect_url=%2Ffile%2F369364196050';
        DMD.Box_Folder_Id__c = '60147005559';
        DMD.Requirement__c = req1.Id;
        DMD.Document_Code__c = '234235';
        DMD.ProjectTask__c =ObjPT.Id;
        DMD.Opportunity__c = opp.Id;
        Insert Dmd;

        Document_MetaData__c objD = new Document_MetaData__c(Id = dmd.Id);
        objD.Box_File_Id__c = '369364196051';
        objD.Box_File_URL__c  = 'https://unison.account.box.com/login?redirect_url=%2Ffile%2F369364196051';
        objD.Box_Folder_Id__c = '60147005560';
        objD.Requirement__c = null;
        update objD;

        Test.stopTest();
    }

}