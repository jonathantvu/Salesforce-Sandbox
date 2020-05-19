@isTest
public class Lead_Financial_Calc_Test {

    public static testmethod void test_Lead_Financial_Calc_EXT(){
        Lead l = new Lead();
        l.LastName = 'Test 436342';
        l.Company = 'Test 450989';
        l.Qualifies_for_New_HomeOwner_Pricing__c = false;
        l.Estimated_Funding_Amount__c = 1000;
        l.Income_Monthly_Base__c = 100;
        insert l;
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = l.Id;
        insert pcr;

        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.LASERCA__Credit_Text__c = '';
        trdacc.LASERCA__Account_Balance__c = 100;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        trdacc.LASERCA__Account_Type__c = 'Installment';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.Lien_Position__c = '1';
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        insert trdacc;

        l.Personal_Credit_Report__c = pcr.Id;
        update l;
        
        //TO-DO:  Add more trade accounts as test data
        
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        Lead_Financial_Calc_EXT ext = new Lead_Financial_Calc_EXT(sc);
        
        ext.updateCalcs();
        //TO-DO:  Add more testing here
    }

    public static testmethod void test_Lead_Financial_Calc_EXT_two(){
        Lead l = new Lead();
        l.LastName = 'Test 436342';
        l.Company = 'Test 450989';
        l.Qualifies_for_New_HomeOwner_Pricing__c = false;
        l.Estimated_Funding_Amount__c = 1000;
        l.Income_Monthly_Base__c = 100;
        insert l;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = l.Id;
        insert pcr;

        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.LASERCA__Credit_Text__c = '';
        trdacc.LASERCA__Account_Balance__c = 100;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        trdacc.LASERCA__Account_Type__c = 'Installment';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.Lien_Position__c = '2';
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        insert trdacc;

        l.Personal_Credit_Report__c = pcr.Id;
        update l;

        //TO-DO:  Add more trade accounts as test data

        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        Lead_Financial_Calc_EXT ext = new Lead_Financial_Calc_EXT(sc);

        ext.updateCalcs();
        //TO-DO:  Add more testing here
    }

    public static testmethod void test_Lead_Financial_Calc_EXT_three(){
        Lead l = new Lead();
        l.LastName = 'Test 436342';
        l.Company = 'Test 450989';
        l.Qualifies_for_New_HomeOwner_Pricing__c = false;
        l.Estimated_Funding_Amount__c = 1000;
        l.Income_Monthly_Base__c = 100;
        insert l;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = l.Id;
        insert pcr;

        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.LASERCA__Credit_Text__c = '';
        trdacc.LASERCA__Account_Balance__c = 100;
        trdacc.LASERCA__Account_Status_Type__c = 'Open';
        trdacc.LASERCA__Account_Type__c = 'Installment';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.Lien_Position__c = '3';
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        insert trdacc;

        l.Personal_Credit_Report__c = pcr.Id;
        update l;

        //TO-DO:  Add more trade accounts as test data

        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        Lead_Financial_Calc_EXT ext = new Lead_Financial_Calc_EXT(sc);

        ext.updateCalcs();
        //TO-DO:  Add more testing here
    }
    
}