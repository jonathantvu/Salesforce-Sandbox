@isTest
public class ProcessTradeLines_test {

    public static testMethod void test_ProcessTradeLines(){
        LASERCA__Personal_Credit_Report__c PCR = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR');
        PCR.LASERCA__Co_Applicant_Credit_Score_Equifax__c = '670';
        PCR.LASERCA__Co_Applicant_Credit_Score_Experian__c = '670';
        PCR.LASERCA__Co_Applicant_Credit_Score_TransUnion__c = '670';
        insert PCR;        
        
        LASERCA__Trade_Accounts__c tradeAcct1 = new LASERCA__Trade_Accounts__c(LASERCA__Personal_Credit_Report__c = PCR.Id);
        tradeAcct1.LASERCA__Credit_Loan_Type__c = 'Revolving';
        tradeAcct1.LASERCA__Payment_Pattern_Start_Date__c = '2017-11';
        tradeAcct1.LASERCA__Payment_Pattern_Data__c = 'CCCCC1C';
        
        LASERCA__Trade_Accounts__c tradeAcct2 = new LASERCA__Trade_Accounts__c(LASERCA__Personal_Credit_Report__c = PCR.Id);        
        tradeAcct2.LASERCA__Credit_Loan_Type__c = 'Collection';
        tradeAcct2.LASERCA__Payment_Pattern_Start_Date__c = '2017-11';
        tradeAcct2.LASERCA__Payment_Pattern_Data__c = 'CCCCC1C';
        tradeAcct2.LASERCA__Account_Balance__c = 2000;  
        
        LASERCA__Trade_Accounts__c tradeAcct3 = new LASERCA__Trade_Accounts__c(LASERCA__Personal_Credit_Report__c = PCR.Id);        
        tradeAcct3.LASERCA__Credit_Loan_Type__c = 'Collection';
        tradeAcct3.LASERCA__Account_Balance__c = 1501;        
        
        insert tradeAcct1;
        insert tradeAcct2;
        insert tradeAcct3;
        
        List<Id> reportIds = new List<Id>();
        reportIds.add(PCR.Id);
        
        ProcessTradeLines.execute(reportIds);
        ProcessTradeLines.tier2CreditEval(PCR.Id,true);
        
    }
    
}