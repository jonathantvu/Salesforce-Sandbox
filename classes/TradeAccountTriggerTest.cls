/************************************************************************************
 Apex Class Name     : TradeAccountTriggerTest
 Version             : 1.0
 Created Date        : 3rd March 2019
 Function            : Test Class for TradeAccountTriggerHandler class and TradeAccountTrigger Trigger
 Author              : Vinitha Bhodhe
 
 Modification Log    :To Handle Trigger and Handler after Data CleanUp.

* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Vinitha Bhodhe             03/08/2019                Original Version
* Sundar Subramaniam         04/16/2019                Modified Version
*************************************************************************************
*/
@isTest
private class TradeAccountTriggerTest{

    @TestSetup
    static void makeData() {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        //newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
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
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = newOpportunity.Id;
        pcr.Name = 'Test PCR';
        insert pcr;

        Trade_Account_Changes__c tac = new Trade_Account_Changes__c();
        tac.Account_Identifier__c = 'id837345';
        tac.Monthly_Payment__c = 10000;
        tac.Interest_Rate__c = 6;
        insert tac;
        
        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc.Target_Pct_Value_Of_Home__c = 0.10;
        trdacc.Exclude__c = false;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        trdacc.Interest_Rate__c = 6;
        trdacc.LASERCA__Account_Identifier__c = 'id837345';
        trdacc.Trade_Account_Changes__c = tac.Id;
        insert trdacc;
    }
    /**
            *  About
            *  -----
            *  Author: Sundar Subramaniam
            *  
            *  Details
            *  -----
            *  Method to take care of all functionalities of POST, PRE-MDEBTS, PAYOFF in the Handler
    **/
    @isTest
    private static void testMethod1(){
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Name = 'Test PCR';
        insert pcr;
        
        List<LASERCA__Trade_Accounts__c> trdacclist = new List<LASERCA__Trade_Accounts__c>();
        
        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc.Target_Pct_Value_Of_Home__c = 0.10;
        trdacc.Exclude__c = false;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        trdacclist.add(trdacc);
        
        
        LASERCA__Trade_Accounts__c trdacc1 = new LASERCA__Trade_Accounts__c();
        trdacc1.Name = 'testacc1';
        trdacc1.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc1.LASERCA__Monthly_Payment__c = 10000;
        trdacc1.LASERCA__Account_Balance__c = 5000;
        trdacc1.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc1.To_Be_Paid_Off__c = TRUE;
        trdacc1.Lien_Position__c  = null;
        trdacc1.Target_Pct_Value_Of_Home__c = 0.10;
        trdacclist.add(trdacc1);
        
        LASERCA__Trade_Accounts__c trdacc2 = new LASERCA__Trade_Accounts__c();
        trdacc2.Name = 'testacc2';
        trdacc2.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc2.To_Be_Paid_Off__c = TRUE;
        trdacc2.Lien_Position__c  = '2';
        trdacc2.Amount_To_Pay_Off2__c = 5000;
        trdacc2.LASERCA__Monthly_Payment__c = 10000;
        trdacc2.LASERCA__Account_Balance__c = 5000;
        trdacc2.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc2.Target_Pct_Value_Of_Home__c = 0.10;
        trdacclist.add(trdacc2);
        
        

        LASERCA__Trade_Accounts__c trdacc3 = new LASERCA__Trade_Accounts__c();
        trdacc3.Name = 'testacc3';
        trdacc3.Credit_Loan_Type_pick__c = 'Other Lien';
        trdacc3.LASERCA__Monthly_Payment__c = 10000;
        trdacc3.LASERCA__Account_Balance__c = 5000;
        trdacc3.Amount_To_Pay_Off2__c = 5000;
        trdacc3.Lien_Position__c  = '2';
        trdacc3.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc3.Target_Pct_Value_Of_Home__c = 0.10;
        trdacclist.add(trdacc3);       
        

        LASERCA__Trade_Accounts__c trdacc4 = new LASERCA__Trade_Accounts__c();
        trdacc4.Name = 'testacc4';
        trdacc4.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc4.To_Be_Paid_Off__c = TRUE;
        trdacc4.Lien_Position__c  = '2';
        trdacc4.Amount_To_Pay_Off2__c = 5000;
        trdacc4.LASERCA__Monthly_Payment__c = 10000;
        trdacc4.LASERCA__Account_Balance__c = 5000;
        trdacc4.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc4.Target_Pct_Value_Of_Home__c = 0.10;
        trdacclist.add(trdacc4);

        LASERCA__Trade_Accounts__c trdacc5 = new LASERCA__Trade_Accounts__c();
        trdacc5.Name = 'testacc5';
        trdacc5.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc5.To_Be_Paid_Off__c = FALSE;
        trdacc5.Lien_Position__c  = '2';
        trdacc5.Amount_To_Pay_Off2__c = 5000;
        trdacc5.LASERCA__Monthly_Payment__c = 10000;
        trdacc5.LASERCA__Account_Balance__c = 5000;
        trdacc5.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc5.Target_Pct_Value_Of_Home__c = 0.10;
        trdacclist.add(trdacc5);

        LASERCA__Trade_Accounts__c trdacc6 = new LASERCA__Trade_Accounts__c();
        trdacc6.Name = 'testacc6';
        trdacc6.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc6.To_Be_Paid_Off__c = FALSE;
        trdacc6.LASERCA__Monthly_Payment__c = 10000;
        trdacc6.LASERCA__Account_Balance__c = 5000;
        trdacc6.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc6.Target_Pct_Value_Of_Home__c = 0.10;
        trdacclist.add(trdacc6);

        LASERCA__Trade_Accounts__c trdacc7 = new LASERCA__Trade_Accounts__c();
        trdacc7.Name = 'testacc7';
        trdacc7.Credit_Loan_Type_pick__c = 'Other Lien';
        trdacc7.LASERCA__Account_Status_Type__c = 'Open';
        trdacc7.Exclude__c = false;
        trdacc7.LASERCA__Monthly_Payment__c = 10000;
        trdacc7.LASERCA__Credit_Limit__c = 4000;
        trdacc7.To_Close_Account__c = true;
        trdacc7.Lien_Interest_Rate_Sub_Type__c = 'HELOC';
        trdacc7.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc7.To_Be_Paid_Off__c = true;
        trdacc7.Target_Pct_Value_Of_Home__c = 0.10;
        trdacclist.add(trdacc7);

        LASERCA__Trade_Accounts__c trdacc8 = new LASERCA__Trade_Accounts__c();
        trdacc8.Name = 'testacc8';
        trdacc8.Credit_Loan_Type_pick__c = 'Other Lien';
        trdacc8.LASERCA__Account_Status_Type__c = 'Open';
        trdacc8.Exclude__c = false;
        trdacc8.LASERCA__Monthly_Payment__c = 10000;
        trdacc8.LASERCA__Account_Balance__c = 5000;
        trdacc8.In_Repayment__c = true;
        trdacc8.LASERCA__Credit_Limit__c = 6000;
        trdacc8.To_Close_Account__c = true;
        trdacc8.Lien_Interest_Rate_Sub_Type__c = 'HELOC';
        trdacc8.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc8.To_Be_Paid_Off__c = false;
        trdacc8.To_Be_Paid_Off__c = true;
        trdacc8.Target_Pct_Value_Of_Home__c = 0.10;

        trdacclist.add(trdacc8);


        insert trdacclist;

         Account newAccount = new Account();
        newAccount.Name = 'Test Account';        
        insert newAccount;
                
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
                /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup
        newOpportunity.Billboard_Property_Approval__c = true;          
*/
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
        
        List<Current_Conditions__c>   reqlist  = new List<Current_Conditions__c>();
        Current_Conditions__c  req1 = new Current_Conditions__c();
        req1.Requirement__c     = 'Credit Supplement';   
        req1.Success_Factor__c  = sf1.Id; 
        req1.Opportunity__c     = newOpportunity.id;
        req1.Code__c            = 'R1035';
        req1.Category__c        = 'Credit';
        req1.Type__c='Stipulation';
        reqlist.add(req1);
        
        insert reqlist;
        
        Test.startTest();

        Opportunity newOpportunity1 = new Opportunity();
        newOpportunity1.Name = 'Test Opportunity';
        newOpportunity1.AccountId = newAccount.Id;
        newOpportunity1.StageName = 'Property in Contract';
        newOpportunity1.CloseDate = System.today();
        newOpportunity1.Agency_or_Non_Agency__c = 'Agency';
                /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup
        newOpportunity.Billboard_Property_Approval__c = true;          
*/
        newOpportunity1.DocuSign_Returned__c = true;
        newOpportunity1.Loan_Officer_ID__c = '12345';
        newOpportunity1.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity1.Property_City__c = 'City';
        newOpportunity1.Property_State__c = 'State';
        newOpportunity1.Property_Zip_Code__c = '12345';
        newOpportunity1.IA_OAV_Override__c  = 2;

        insert newOpportunity1;

        Opportunity newOpportunity2 = new Opportunity();
        newOpportunity2.Name = 'Test Opportunity';
        newOpportunity2.AccountId = newAccount.Id;
        newOpportunity2.StageName = 'Property in Contract';
        newOpportunity2.CloseDate = System.today();
        newOpportunity2.Agency_or_Non_Agency__c = 'Agency';
                /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup
        newOpportunity.Billboard_Property_Approval__c = true;          
*/
        newOpportunity2.DocuSign_Returned__c = true;
        newOpportunity2.Loan_Officer_ID__c = '12345';
        newOpportunity2.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity2.Property_City__c = 'City';
        newOpportunity2.Property_State__c = 'State';
        newOpportunity2.Property_Zip_Code__c = '12345';
        newOpportunity2.IA_OAV_Override__c  = 2;

        insert newOpportunity2;

        List<LASERCA__Trade_Accounts__c> trdlist = [select opportunity__c from LASERCA__Trade_Accounts__c];
        for(LASERCA__Trade_Accounts__c ta : trdlist){
            ta.Opportunity__c = newOpportunity.Id;
        }
        

        trdlist[4].Opportunity__c = newOpportunity1.id;
        trdlist[5].Opportunity__c = newOpportunity1.id;
        trdlist[6].Opportunity__c = newOpportunity1.id;
        trdlist[7].Opportunity__c = newOpportunity2.id;
        trdlist[7].Target_Pct_Value_Of_Home__c = null;
        trdlist[8].Opportunity__c = newOpportunity2.id;
        trdlist[8].To_Be_Paid_Off__c = true;

        TriggrUtility.resetForTest();
        update trdlist;
        
        Test.stopTest();
    }


    @isTest
    private static void test_CopyChanges_1(){
        
        // Setup Data
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';        
        insert newAccount;
        
        Opportunity newOpportunity1 = new Opportunity();
        newOpportunity1.Name = 'Test Opportunity';
        newOpportunity1.AccountId = newAccount.Id;
        newOpportunity1.StageName = 'Property in Contract';
        newOpportunity1.CloseDate = System.today();
        newOpportunity1.Agency_or_Non_Agency__c = 'Agency';
        newOpportunity1.DocuSign_Returned__c = true;
        newOpportunity1.Loan_Officer_ID__c = '12345';
        newOpportunity1.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity1.Property_City__c = 'City';
        newOpportunity1.Property_State__c = 'State';
        newOpportunity1.Property_Zip_Code__c = '12345';
        newOpportunity1.IA_OAV_Override__c  = 2;
        insert newOpportunity1;
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = newOpportunity1.Id;
        pcr.Name = 'Test PCR';
        insert pcr;
        
        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc.Target_Pct_Value_Of_Home__c = 0.10;
        trdacc.Exclude__c = false;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        trdacc.LASERCA__Account_Identifier__c = 'id837345';
        trdacc.Interest_Rate__c = 5;
        insert trdacc;

        // Run Code
        Test.startTest();

        trdacc.Interest_Rate__c = 6;
        update trdacc;

        Test.stopTest();

        // Verify Results
        trdacc = [SELECT Trade_Account_Changes__c, Trade_Account_Changes__r.Account_Identifier__c, Trade_Account_Changes__r.Interest_Rate__c
                    FROM LASERCA__Trade_Accounts__c WHERE Id = :trdacc.Id];
        System.assert(trdacc.Trade_Account_Changes__c != null);
        System.assertEquals('id837345', trdacc.Trade_Account_Changes__r.Account_Identifier__c);
        System.assertEquals(6, trdacc.Trade_Account_Changes__r.Interest_Rate__c);
    }


    @isTest
    private static void test_CopyChanges_2(){
        
        // Setup Data
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';        
        insert newAccount;
        
        Opportunity newOpportunity1 = new Opportunity();
        newOpportunity1.Name = 'Test Opportunity';
        newOpportunity1.AccountId = newAccount.Id;
        newOpportunity1.StageName = 'Property in Contract';
        newOpportunity1.CloseDate = System.today();
        newOpportunity1.Agency_or_Non_Agency__c = 'Agency';
        newOpportunity1.DocuSign_Returned__c = true;
        newOpportunity1.Loan_Officer_ID__c = '12345';
        newOpportunity1.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity1.Property_City__c = 'City';
        newOpportunity1.Property_State__c = 'State';
        newOpportunity1.Property_Zip_Code__c = '12345';
        newOpportunity1.IA_OAV_Override__c  = 2;
        insert newOpportunity1;
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = newOpportunity1.Id;
        pcr.Name = 'Test PCR';
        insert pcr;

        Trade_Account_Changes__c tac = new Trade_Account_Changes__c();
        insert tac;
        
        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc.Target_Pct_Value_Of_Home__c = 0.10;
        trdacc.Exclude__c = false;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        trdacc.LASERCA__Account_Identifier__c = 'id837345';
        trdacc.Trade_Account_Changes__c = tac.Id;
        trdacc.Interest_Rate__c = 5;
        insert trdacc;

        // Run Code
        Test.startTest();

        trdacc.Interest_Rate__c = 6;
        update trdacc;

        Test.stopTest();

        // Verify Results
        tac = [SELECT Id, Account_Identifier__c, Interest_Rate__c FROM Trade_Account_Changes__c WHERE Id = :tac.Id];
        System.assertEquals('id837345', tac.Account_Identifier__c);
        System.assertEquals(6, tac.Interest_Rate__c);
    }

    @isTest
    private static void test_FindTradeAccountChanges(){
        
        // Setup Data
        // Moved in @testSetup

        // Run Code
        Test.startTest();

        LASERCA__Trade_Accounts__c trdacc2 = new LASERCA__Trade_Accounts__c();
        trdacc2.Name = 'testacc2';
        trdacc2.LASERCA__Personal_Credit_Report__c = [SELECT Id FROM LASERCA__Personal_Credit_Report__c LIMIT 1].Id;
        trdacc2.LASERCA__Account_Identifier__c = 'id837345';
        insert trdacc2;

        Test.stopTest();

        // Verify Results
        trdacc2 = [SELECT Id, Trade_Account_Changes__c, Interest_Rate__c FROM LASERCA__Trade_Accounts__c WHERE Id = :trdacc2.Id];
        List<Trade_Account_Changes__c> tacs = [SELECT Id FROM Trade_Account_Changes__c];
        System.assertEquals(1, tacs.size());
        System.assertEquals(tacs[0].Id, trdacc2.Trade_Account_Changes__c);
        System.assertEquals(6, trdacc2.Interest_Rate__c);
    }

    /*@isTest
    private static void test_SetTheRightPCROnNewTradeAccounts() {
        
        // Setup Data
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        //newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
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
        
        LASERCA__Personal_Credit_Report__c pcr1 = new LASERCA__Personal_Credit_Report__c();
        pcr1.Opportunity__c = newOpportunity.Id;
        pcr1.Name = 'Test PCR 1';
        insert pcr1;
        LASERCA__Personal_Credit_Report__c pcr2 = new LASERCA__Personal_Credit_Report__c();
        pcr2.Opportunity__c = newOpportunity.Id;
        pcr2.Name = 'Test PCR 2';
        insert pcr2;

        newOpportunity.Personal_Credit_Report__c = pcr1.Id;
        update newOpportunity;

        // Run Code
        Test.startTest();

        LASERCA__Trade_Accounts__c trdacc2 = new LASERCA__Trade_Accounts__c();
        trdacc2.Name = 'testacc2';
        trdacc2.Opportunity__c = newOpportunity.Id;
        trdacc2.LASERCA__Personal_Credit_Report__c = pcr2.Id;
        insert trdacc2;

        Test.stopTest();

        // Verify Results
        trdacc2 = [SELECT Id, LASERCA__Personal_Credit_Report__c FROM LASERCA__Trade_Accounts__c WHERE Id = :trdacc2.Id];
        System.assertEquals(pcr1.Id, trdacc2.LASERCA__Personal_Credit_Report__c);

    }*/


}