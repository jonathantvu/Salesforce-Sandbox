/**
 * Created by Eliot Rojas on 4/30/2019.
 */

@IsTest
private class OpportunityChatterUpdatesTest {
    @testSetup static void setup() {
        Account newAcc = new Account (Name='Test Account');
        insert newAcc;
        Id homeOwnerRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

        Contact con = new Contact(FirstName = 'FirstName', Opp_Lookup_Helper__c = 'test', LastName = 'LastName',  Phone = '4123156', Email = 'fisrtName.lastName@test.com',
                AccountID = newAcc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Phone = '4123156', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = newAcc.Id);
        insert con2;
/*
        Opportunity newOppty = new Opportunity();
        newOppty.Name = 'Test Opportunity';
        newOppty.AccountId = newAcc.Id;
        newOppty.Applicant__c = con.Id;
        newOppty.Co_Applicant__c = con2.Id;
        newOppty.Applicant__c = con.Id;
        newOppty.StageName = 'Submit to Ops';
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
        insert newOppty;*/
    }

    @IsTest
    static void testBehaviorInsert() {
        Account newAcc = new Account (Name='Test Account');
        insert newAcc;
        Id homeOwnerRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

        Contact con = new Contact(FirstName = 'FirstName', Opp_Lookup_Helper__c = 'test', LastName = 'LastName',  Phone = '12341', Email = 'fisrtName.lastName@test.com',
                AccountID = newAcc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Phone = '12341', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = newAcc.Id);
        insert con2;

        Opportunity newOppty = new Opportunity();
        newOppty.Name = 'Test Opportunity';
        newOppty.Applicant__c = con.Id;
        newOppty.Co_Applicant__c = con2.Id;
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
        Test.startTest();
        insert newOppty;
        Test.stopTest();

    }

    @IsTest
    static void testBehaviorUpdate() {
        /*
        Recorded_Information__c recordedInfo = new Recorded_Information__c();
        recordedInfo.Opportunity2__c = newOppty.Id;
        recordedInfo.Applicant1_Name__c = 'John';
        insert recordedInfo;

        Success_Factor__c SF = new Success_Factor__c();
        SF.Opportunity__c = newOppty.Id;
        SF.Success_Factor__c = 'Cash to Consumer';
        SF.Program__c = 'HO';
        SF.Status__c = 'Completed';
        insert SF;

        Deal_History__c DH = new Deal_History__c();
        DH.Opportunity__c = newOppty.Id;
        DH.Passbook_Status__c = 'Approved';
        insert DH;*/
/*
     Recorded_Information__c ri = [SELECT Id, Opportunity2__c, Opportunity2__r.Final_OAV_Calculation__c, Opportunity2__r.Investor_Percentage__c, Opportunity2__r.Estimated_Funding_Amount__c,
        Opportunity2__r.Pricing_Ratio__c, Option_Agreement_Expiration__c, Option_Purchase_Price__c, Option_Purchase_Price_Balance__c FROM Recorded_Information__c WHERE Opportunity2__c =: newOppty.Id LIMIT 1];
        system.debug('RECORDED INFO');
        system.debug(ri.Opportunity2__r.Final_OAV_Calculation__c); // 0
        system.debug(ri.Opportunity2__r.Investor_Percentage__c);// null ((Estimated_Funding_Amount__c * Pricing_Ratio__c) / Final_OAV_Calculation__c)
        system.debug(ri.Opportunity2__r.Estimated_Funding_Amount__c); // 11.00
        system.debug(ri.Opportunity2__r.Pricing_Ratio__c); // 10.00
        system.debug(ri.Option_Purchase_Price__c); // null
        system.debug(ri.Option_Purchase_Price_Balance__c); // null
*/
/*

        Opportunity refreshedOpp = [SELECT Id, Recorded_Information__c, Applicant__c, Applicant__r.Email, (SELECT Id, Opportunity2__c, Option_Purchase_Price_Balance__c FROM Recorded_Informations__r) FROM Opportunity WHERE
        Id =: newOppty.Id];

        refreshedOpp.StageName = 'Investment Due Diligence';
        system.debug('refreshedOpp ' + refreshedOpp.Recorded_Informations__r);
        update refreshedOpp;

*/
        Account newAcc = new Account (Name='Test Account');
        insert newAcc;

        Contact con = new Contact(FirstName = 'FirstName', Opp_Lookup_Helper__c = 'test', LastName = 'LastName',  Phone = '4123156', Email = 'fisrtName.lastName@test.com',
                AccountID = newAcc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Phone = '4123156', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = newAcc.Id);
        insert con2;

        Opportunity opp = new Opportunity();
        opp.AccountId = newAcc.Id;
        opp.Name = 'test opp';
        opp.StageName = 'Investment Due Diligence';
        opp.CloseDate = System.today();
        opp.Investment_Analyst2__c = UserInfo.getUserId();
        opp.UnisonProcessor__c = UserInfo.getUserId();
        opp.Maximum_Authorized_DTI__c = 19;
        opp.Maximum_Authorized_LTV__c = 19;
        opp.Estimated_Funding_Amount__c = 0.6;
        opp.Final_OAV_Calculation__c = 1;
        opp.Pricing_Ratio__c = 1;
        insert opp;


     //   Opportunity refreshedOpp2 = [SELECT Id, Recorded_Information__c, Applicant__c, Co_Applicant__c, Applicant__r.Email, (SELECT Id, Opportunity2__c, Option_Purchase_Price_Balance__c FROM Recorded_Informations__r) FROM Opportunity WHERE
   //    Name = 'Test Opportunity' LIMIT 1];
       /* Opportunity opp = new Opportunity();
        opp.AccountId = newAcc.Id;
        opp.Name = 'test opp';
        opp.StageName = 'Investment Due Diligence';
        opp.CloseDate = System.today();
        opp.Maximum_Authorized_DTI__c = 19;
        opp.Maximum_Authorized_LTV__c = 19;
        opp.Estimated_Funding_Amount__c = 0.6;
        opp.Final_OAV_Calculation__c = 1;
        opp.Pricing_Ratio__c = 1;
        insert opp;*/


        /* // refreshedOpp2.Applicant__c = con.Id;
         // refreshedOpp2.Co_Applicant__c = con2.Id;
          refreshedOpp2.Process_Program_Knowledge_Review__c = true;
          refreshedOpp2.Appraisal_Received__c = true;
          //refreshedOpp2.StageName = 'Final Approval';
          refreshedOpp2.Appraisal_Ordered__c = true;
          refreshedOpp2.Second_Appraisal_Ordered__c = true;
          refreshedOpp2.Second_Appraisal_Received__c = true;
          refreshedOpp2.Home_Inspection_Ordered__c = true;
          refreshedOpp2.Home_Inspection_Received__c = true;
          refreshedOpp2.Property_Report_Ordered__c = true;
          refreshedOpp2.Property_Report_Received__c = true;
          refreshedOpp2.DMA_Count__c = 3;
        //  refreshedOpp2.CloseDate = system.today() + 5;
          refreshedOpp2.Wire_to_Agent_Date__c = system.today();
          refreshedOpp2.Maximum_Authorized_DTI__c = 15.0;
          refreshedOpp2.Maximum_Authorized_LTV__c = 16.0;*/

        Test.startTest();
        opp.Home_Inspection_Received__c = true;
        opp.Property_Report_Ordered__c = true;
        opp.Property_Report_Received__c = true;
        opp.Second_Appraisal_Received__c = true;
        opp.Second_Appraisal_Ordered__c = true;
        opp.Appraisal_Received__c = true;
        opp.Process_Program_Knowledge_Review__c = true;
        Map<Id, Opportunity> mymap = new Map<Id, Opportunity>();
        List<Opportunity> mylist = new List<Opportunity>();
        mylist.add(opp);
        mymap.put(opp.Id, opp);
        OpportunityChatterUpdates.doChatterUpdates(mylist,mymap);
        update opp;
        Test.stopTest();
    }
}