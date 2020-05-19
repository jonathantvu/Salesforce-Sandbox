/**
 * Created by Carolina Veliz on 12/19/2019.
 */

@isTest
private with sharing class StipulationsHelperTest {

    @testSetup static void setup() {


    }



    @IsTest
    static void test() {

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Name = 'Test PCR';
        insert pcr;

        //List<LASERCA__Trade_Accounts__c> trdacclist = new List<LASERCA__Trade_Accounts__c>();

        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc.Target_Pct_Value_Of_Home__c = 0.10;
        trdacc.Exclude__c = false;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        //trdacclist.add(trdacc);
        insert trdacc;

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Investment Due Diligence';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.Estimated_Funding_Amount__c = 2;
        newOpportunity.Pricing_Ratio__c = 2;
        newOpportunity.Final_OAV_Calculation__c = 4;
        newOpportunity.IA_OAV_Override__c  = 4;

        insert newOpportunity;

        List<Success_Factor__c>  sflist = new List<Success_Factor__c>();
        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = newOpportunity.Id;
        sf1.Success_Factor__c  = 'LTV';
        sf1.Status__c  = 'In Progress';
        sf1.Program__c = 'HO';
        sflist.add(sf1);

        insert sflist;


        Current_Conditions__c  req1 = new Current_Conditions__c();
        req1.Requirement__c     = 'Credit Supplement';
        req1.Success_Factor__c  = sf1.Id;
        req1.Opportunity__c     = newOpportunity.id;
        req1.Code__c            = 'R1003';
        req1.Category__c        = 'Credit';
        req1.Type__c ='Stipulation';


        insert req1;

        Test.startTest();
        StipulationsHelper.newStipulations(newOpportunity.id,
                trdacc.id,
                trdacc.name,
                '',
                'Add Applicant to Title at Closing',
                false);
        StipulationsHelper.waiveStipulations(req1.id);
        StipulationsHelper.postToChatter('Test');

        req1.Trade_Account__c = trdacc.id;
        update req1;

        StipulationsHelper.newStipulations(newOpportunity.id,
                trdacc.id,
                trdacc.name,
                '',
                'Add Applicant to Title at Closing',
                false);

        Test.stopTest();
    }

}