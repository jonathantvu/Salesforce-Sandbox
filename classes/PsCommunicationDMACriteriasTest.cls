@isTest
public class PsCommunicationDMACriteriasTest {



    @isTest
    static void sendEmailToPsTest()
    {
        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;

        Opportunity opp   = new Opportunity();
        opp.AccountId  = acc.Id;
        opp.Name  = 'test opp';
        opp.StageName  = 'Investment Due Diligence';
        opp.CloseDate  = System.today();
        opp.Estimated_Funding_Amount__c = 2;
        opp.Pricing_Ratio__c = 2;
        opp.Final_OAV_Calculation__c = 4;
        opp.Home_Inspection_Received__c = false;
        opp.IA_OAV_Override__c =2;

        insert opp;

        dma__c dma = new dma__c();
        //dma.Name = 'test dma';
        dma.Opportunity__c = opp.Id;

        insert dma;



        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = opp.Id;
        sf1.Success_Factor__c  = 'Cash to Consumer';
        sf1.Status__c  = 'In Progress';
        sf1.Program__c = 'HO';
        insert sf1;


       // Current_Conditions__c cc = new Current_Conditions__c();
       // cc.Requirement__c = 'Home Inspection';
       // cc.Status__c = 'Completed';
       // cc.Success_Factor__c = sf1.Id;
       // insert cc;

        Current_Conditions__c cc = new Current_Conditions__c();
        cc.Requirement__c = 'Home Inspection';
        cc.Status__c= 'Completed';
        cc.RSI_Eligible__c = TRUE ;
        cc.RSI_Letter_Text_Insert__c = 'T';
        cc.Opportunity__c = opp.Id;
        cc.Success_Factor__c = sf1.Id;
        insert cc;


        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();

        mapOpp.put(opp.Id, opp);

        Opportunity opp2 = opp.clone(true, true, false, false);

        Opportunity opp3 = [SELECT Id, Name, OwnerId, Home_Inspection_Received__c FROM Opportunity WHERE Id =: opp2.Id LIMIT 1];
        opp3.Home_Inspection_Received__c = true;

        id emailTemplate = [select id from EmailTemplate where developername = 'PS_Communication_DMAs'].id;
        Test.startTest();
        PsCommunicationDMACriterias.sendEmailToPs( new List<Opportunity>{opp3}, mapOpp, emailTemplate);
        Test.stopTest();
    }

}