/**
 * Created by anas on 5/23/19.
 */

@isTest
public with sharing class RSILetterTextControllerTest {

    @testSetup
    static void testSetup(){

        Account acc          = new Account();
        acc.Name             = 'test acc';
        insert acc;

        Opportunity opp      = new Opportunity();
        opp.AccountId      = acc.Id;
        opp.Name         = 'test opp';
        opp.StageName    = 'Investment Due Diligence';
        opp.CloseDate    = System.today();
        opp.Estimated_Funding_Amount__c = 2;
        opp.Pricing_Ratio__c = 2;
        opp.Final_OAV_Calculation__c = 4;
        opp.IA_OAV_Override__c  = 4;
        insert opp;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = opp.Id;
        sf1.Success_Factor__c  = 'Cash to Consumer';
        sf1.Status__c  = 'In Progress';
        sf1.Program__c = 'HO';
        insert sf1;


        Current_Conditions__c cc = new Current_Conditions__c();
        cc.Requirement__c = 'Home Inspection';
        cc.Status__c= 'Document Received, In progress';
        cc.RSI_Eligible__c = TRUE ;
        cc.RSI_Letter_Text_Insert__c = 'T';
        cc.Opportunity__c = opp.Id;
        cc.Success_Factor__c = sf1.Id;
        cc.Code__c = 'R1035';
        insert cc;


        Current_Conditions__c cc2 = new Current_Conditions__c();
        cc2.Requirement__c = 'Home Inspection';
        cc2.Status__c= 'Document Received, In progress';
        cc2.RSI_Eligible__c = TRUE ;
        cc2.RSI_Letter_Text_Insert__c = 'T';
        cc2.Opportunity__c = opp.Id;
        cc2.Success_Factor__c = sf1.Id;
        cc2.Code__c = 'R1035';
        insert cc2;

        Project_Task__c prj = new Project_Task__c();
        prj.Requirement__c = cc2.Id;
        prj.completed__c = FALSE;
        prj.Code__c = 'Task-380';
        prj.Name = 'Notify file is ready for RSI';
        prj.Requirement__c = cc.id;
        insert prj;

        Project_Task__c prj2 = new Project_Task__c();
        prj2.Requirement__c = cc.Id;
        prj2.completed__c = FALSE;
        prj2.Code__c = 'Task-380';
        prj2.Name = 'Notify file is ready for RSI';
        prj2.Requirement__c =  cc.id;
        insert prj2;

    }

    @isTest
    static void updaterequirementsTest()
    {
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE Name='test opp' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id', opps[0].Id);
        RSILetterTextController ctrl = new RSILetterTextController();
        ctrl.updaterequirements();
    }

}