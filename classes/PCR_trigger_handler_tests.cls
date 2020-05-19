/**
 *  About
 *  -----
 *  Author: Cloud Mine Consulting
 *  Create date: 9/1/2017
 *  
 *  Details
 *  -----
 *  Test class for PCR Trigger and PCR Trigger Handler class
 *  
 *  Update History
 *  -----
 * 
 *  Issues / TODOs
 *  -----
 * 
**/
@isTest
public class PCR_trigger_handler_tests {

    /**
     *  About
     *  -----
     *  Author: Cloud Mine Consulting
     *  
     *  Details
     *  -----
     *  Test Class for PCR Trigger/Handlers
    **/
    private static testMethod void testPCRTriggers(){

        Schema.DescribeSObjectResult leadResult = Lead.SobjectType.getDescribe();
        Map<string, Schema.RecordTypeInfo> leadRTNameMap = leadResult.getRecordTypeInfosByName();

        Lead newLead = new Lead();
        newLead.RecordTypeId = leadRTNameMap.get('HomeBuyer').getRecordTypeId();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'firstlast@unison.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'First Last Household';
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Income_Monthly_Base__c = 8000;
        newLead.Home_Value__c = 500000;
        insert newLead;

        LASERCA__Personal_Credit_Report__c PCR = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR');
        PCR.LASERCA__Credit_Score_Equifax__c = '705';
        PCR.LASERCA__Credit_Score_Experian__c = '705';
        PCR.LASERCA__Credit_Score_TransUnion__c = '705';
        insert PCR;
        PCR.LASERCA__Lead__c = newLead.Id;
        update PCR;

        LASERCA__Personal_Credit_Report__c resultPCR = [SELECT Credit_Pre_Qualification_Status__c FROM LASERCA__Personal_Credit_Report__c WHERE Id =:PCR.Id];
        Lead resultLead = [SELECT Credit_Pre_Qualification_Status__c FROM Lead WHERE Id =:newLead.Id];
        system.assertEquals(resultPCR.Credit_Pre_Qualification_Status__c, resultLead.Credit_Pre_Qualification_Status__c);

        PCR.Credit_Pre_Qualification_Status__c = 'Approved';
        update PCR;
        resultLead = [SELECT Credit_Pre_Qualification_Status__c FROM Lead WHERE Id =:newLead.Id];
        system.assertEquals('Approved', resultLead.Credit_Pre_Qualification_Status__c);
        
        //Delete TEst
        delete PCR;
        //TO-DO: could use more assert statements here

        //Undelete Test
        undelete PCR;
        //TO-DO: could use more assert statements here
    }

    private static testMethod void test_HomeOwner_Tier1_Decline(){

        Schema.DescribeSObjectResult leadResult = Lead.SobjectType.getDescribe();
        Map<string, Schema.RecordTypeInfo> leadRTNameMap = leadResult.getRecordTypeInfosByName();

        Lead newLead = new Lead();
        newLead.RecordTypeId = leadRTNameMap.get('HomeOwner').getRecordTypeId();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'tester@unison.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'First Last Household';
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Income_Monthly_Base__c = 8000;
        newLead.Home_Value__c = 500000;
        insert newLead;

        LASERCA__Personal_Credit_Report__c PCR = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR');
        PCR.LASERCA__Credit_Score_Equifax__c = '685';
        PCR.LASERCA__Credit_Score_Experian__c = '685';
        PCR.LASERCA__Credit_Score_TransUnion__c = '685';
        insert PCR;
        PCR.LASERCA__Lead__c = newLead.Id;
        update PCR;

        LASERCA__Personal_Credit_Report__c resultPCR = [SELECT Credit_Pre_Qualification_Status__c FROM LASERCA__Personal_Credit_Report__c WHERE Id =:PCR.Id];
        Lead resultLead = [SELECT Credit_Pre_Qualification_Status__c FROM Lead WHERE Id =:newLead.Id];
        system.assertEquals(resultPCR.Credit_Pre_Qualification_Status__c, resultLead.Credit_Pre_Qualification_Status__c);
        system.assertEquals('Declined', resultLead.Credit_Pre_Qualification_Status__c);

    }

    private static testMethod void test_HomeBuyer_Tier1_Decline(){

        Schema.DescribeSObjectResult leadResult = Lead.SobjectType.getDescribe();
        Map<string, Schema.RecordTypeInfo> leadRTNameMap = leadResult.getRecordTypeInfosByName();

        Lead newLead = new Lead();
        newLead.RecordTypeId = leadRTNameMap.get('HomeBuyer').getRecordTypeId();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'tester@unison.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'First Last Household';
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Income_Monthly_Base__c = 8000;
        newLead.Home_Value__c = 500000;
        insert newLead;

        LASERCA__Personal_Credit_Report__c PCR = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR');
        PCR.LASERCA__Credit_Score_Equifax__c = '619';
        PCR.LASERCA__Credit_Score_Experian__c = '619';
        PCR.LASERCA__Credit_Score_TransUnion__c = '619';
        insert PCR;
        PCR.LASERCA__Lead__c = newLead.Id;
        update PCR;

        LASERCA__Personal_Credit_Report__c resultPCR = [SELECT Credit_Pre_Qualification_Status__c FROM LASERCA__Personal_Credit_Report__c WHERE Id =:PCR.Id];
        Lead resultLead = [SELECT Credit_Pre_Qualification_Status__c FROM Lead WHERE Id =:newLead.Id];
        system.assertEquals(resultPCR.Credit_Pre_Qualification_Status__c, resultLead.Credit_Pre_Qualification_Status__c);
        system.assertEquals('Declined', resultLead.Credit_Pre_Qualification_Status__c);

    }


    private static testMethod void test_Opportunity(){

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
        newOpportunity.Estimated_Funding_Amount__c = 10;
        newOpportunity.Pricing_Ratio__c = 10;
        newOpportunity.Final_OAV_Calculation__c = 10;
        newOpportunity.IA_OAV_Override__c = 10;
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.SEND_TO_ENCOMPASS__c = true;
        insert newOpportunity;

        Test.startTest();
        LASERCA__Personal_Credit_Report__c PCR = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR');
        PCR.LASERCA__Credit_Score_Equifax__c = '619';
        PCR.LASERCA__Credit_Score_Experian__c = '619';
        PCR.LASERCA__Credit_Score_TransUnion__c = '619';
        insert PCR;
        PCR.Opportunity__c = newOpportunity.Id;
        update PCR;
        Set<Id> ids = new Set<Id>();
        ids.add(newOpportunity.Id);
        PCR_trigger_handler.rollupPCRToOpp(ids);
        Test.stopTest();

        LASERCA__Personal_Credit_Report__c resultPCR = [SELECT Opportunity__c, Credit_Pre_Qualification_Status__c FROM LASERCA__Personal_Credit_Report__c WHERE Id =:PCR.Id];
        Opportunity resultOpportunity = [SELECT Personal_Credit_Report__c FROM Opportunity WHERE Id =: newOpportunity.Id];
        system.debug('++ resultPCR ' + resultPCR);
        system.debug('++ resultOpportunity ' + resultOpportunity.Personal_Credit_Report__c);
    }
    
    private static testMethod void test_manualTradeAcount(){

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
        newOpportunity.Estimated_Funding_Amount__c = 10;
        newOpportunity.Pricing_Ratio__c = 10;
        newOpportunity.Final_OAV_Calculation__c = 10;
        newOpportunity.IA_OAV_Override__c = 10;
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.SEND_TO_ENCOMPASS__c = true;
        insert newOpportunity;

        LASERCA__Personal_Credit_Report__c PCR1 = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR1');
        PCR1.LASERCA__Credit_Score_Equifax__c = '619';
        PCR1.LASERCA__Credit_Score_Experian__c = '619';
        PCR1.LASERCA__Credit_Score_TransUnion__c = '619';
        PCR1.Opportunity__c = newOpportunity.Id;
        insert PCR1;
        
        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'TestManualAccount988756';
        trdacc.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc.To_Be_Paid_Off__c = TRUE;
        trdacc.Lien_Position__c  = '2';
        trdacc.Amount_To_Pay_Off2__c = 5000;
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = PCR1.Id;
        trdacc.Target_Pct_Value_Of_Home__c = 0.10;
        
        LASERCA__Trade_Accounts__c trdacc2 = new LASERCA__Trade_Accounts__c();
        trdacc2.Name = 'TestManualAccount988751';
        trdacc2.LASERCA__Account_Identifier__c = '1234';
        trdacc2.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc2.To_Be_Paid_Off__c = TRUE;
        trdacc2.Lien_Position__c  = '2';
        trdacc2.Amount_To_Pay_Off2__c = 5000;
        trdacc2.LASERCA__Monthly_Payment__c = 10000;
        trdacc2.LASERCA__Account_Balance__c = 5000;
        trdacc2.LASERCA__Personal_Credit_Report__c = PCR1.Id;
        trdacc2.Target_Pct_Value_Of_Home__c = 0.10;
        insert new List<LASERCA__Trade_Accounts__c> { trdacc, trdacc2 };
            
        Test.startTest();
        
        LASERCA__Personal_Credit_Report__c PCR2 = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR2');
        PCR2.LASERCA__Credit_Score_Equifax__c = '619';
        PCR2.LASERCA__Credit_Score_Experian__c = '619';
        PCR2.LASERCA__Credit_Score_TransUnion__c = '619';
        PCR2.Opportunity__c = newOpportunity.Id;
        insert PCR2;
        
        Test.stopTest();

        //Verify results
		
        LASERCA__Trade_Accounts__c resultTAClone = [SELECT Id, Manual_TA_Copied__c FROM LASERCA__Trade_Accounts__c WHERE LASERCA__Personal_Credit_Report__c = :PCR2.Id LIMIT 1];
        System.assertEquals(false, resultTAClone.Manual_TA_Copied__c);
        
        LASERCA__Trade_Accounts__c resultTACopied = [SELECT Id, Manual_TA_Copied__c FROM LASERCA__Trade_Accounts__c WHERE Id = :trdacc.Id LIMIT 1];
        System.assertEquals(true, resultTACopied.Manual_TA_Copied__c);
        
        LASERCA__Trade_Accounts__c resultTARemain = [SELECT Id, LASERCA__Personal_Credit_Report__c FROM LASERCA__Trade_Accounts__c WHERE Id = :trdacc2.Id];
        System.assertEquals(pcr1.Id, resultTARemain.LASERCA__Personal_Credit_Report__c);
    }

}