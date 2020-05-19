/************************************************************************************
 Apex Class Name     : OpportunityServiceTest
 Version             : 1.0
 Created Date        : 3rd March 2019
 Function            : Test Class for OpportunityService class
 Author              : Neeraja Cherukuri
 
 Modification Log    :To Handle Fomulas Calculations ,We are using the Service class.
* Developer                   Date                    Description
*
*
----------------------------------------------------------------------------------
* Neeraja Cherukuri            02/20/2019                Original Version
*************************************************************************************
*/
@isTest
public class OpportunityServiceTest {
    private static testMethod void validateWithouthOAV(){
        Account objAcc = new Account(Name = 'New Account');
        insert objAcc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = objAcc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = objAcc.Id);
        insert con2;

        /* 4/2/2019 Sundar Subramaniam - Is_there_Co_App__c removed from query for Data Model Cleanup */
        Opportunity objOpp = new Opportunity(Name = 'New Oppty', AccountId = objAcc.Id, StageName = 'Submitted to Underwriting',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = '2-4 Family',
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Pricing_Ratio__c = 4,Final_OAV_Calculation__c=100,Lien_First_Lender_Balance__c = 100, Summary_Appraised_Value__c = 10, Purchase_Price__c = 10);
        Insert objOpp;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = objOpp.Id;
        sf1.Success_Factor__c  = 'LTV';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        Insert sf1;

        try{
            objOpp.Purchase_Price__c = 5000000;
            objOpp.Summary_Appraised_Value__c= 6000000;
            objOpp.IA_OAV_Override__c = 456456;
            objOpp.OAV_Discount_Pct__c = 30;
            objOpp.Purchase_Price__c = 200;
            objOpp.StageName = 'Investment Due Diligence';
            objOpp.Success_Factor_Cleared__c = False;
            update objOpp;
        }catch(Exception e){}
    }

    private static testMethod void validateForHomeOwner(){
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty1 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,

                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty1.Post_Close_Mortgage_Debt__c= 10000;
        objOpty1.Present_Total_Mortgage_Debt__c = 20000;
        objOpty1.Final_OAV_Calculation__c = 500000;
        objOpty1.Pricing_Ratio__c = 4;
        objOpty1.Post_Close_BE_Ratio__c = 90;
        objOpty1.Pre_Close_BE_Ratio__c = 80;
        objOpty1.Post_Close_LTV2__c = 80;
        objOpty1.Pre_Close_LTV2__c = 80;
        objOpty1.Income_App1__c  = 10000;
        insert objOpty1;
    }

    private static testMethod void validateForHomeOwner_Qualifies_IsNoo1(){
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeOwnerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty1 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,

                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty1.Post_Close_Mortgage_Debt__c= 1576695;
        objOpty1.Present_Total_Mortgage_Debt__c = 1576695;
        objOpty1.Additional_Applicant_Income__c = 0;
        objOpty1.Income_App1__c = 4854.83;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Final_OAV_Calculation__c = 3500000;
        objOpty1.IA_OAV_Override__c = 3500000;
        objOpty1.Pricing_Ratio__c = 6;
        objOpty1.Post_Close_BE_Ratio__c = 45.05;
        objOpty1.Pre_Close_BE_Ratio__c = 45.05;
        objOpty1.Post_Close_FE_Ratio2__c = 45.05;
        objOpty1.Pre_Close_FE_Ratio2__c = 45.05;
        objOpty1.Post_Close_LTV2__c = 45.05;
        objOpty1.Pre_Close_LTV2__c = 45.05;
        objOpty1.Income_App1__c  = 10000;
        objOpty1.Qualifies_for_New_HomeOwner_Pricing__c = true;
        objOpty1.Is_NOO__c = false;
        insert objOpty1;

        Property__c newprop = new Property__c();
        newprop.Name = 'Test';
        newprop.Property_Type__c = 'Condominium';
        newprop.Build_Year__c = '2019';
        newprop.Property_New_Construction_Flag__c = True;
        newprop.Property_Street_Number_and_Name__c = 'test asd 123';
        newprop.Property_City__c = 'test asd 123';
        newprop.Property_State__c = 'CA';
        newprop.Property_Zip_Code__c = '12345';
        newprop.Property_County__c = 'test asd 123';
        newprop.Property_Number_of_Units__c = 2;
        newprop.Opportunity__c=objOpty1.Id;
        insert newprop;

        objOpty1.Is_NOO__c = true;
        update objOpty1;

        // RecordType = HomeOwner && Qualifies_for_New_HomeOwner_Pricing__c == true && Is_NOO__c == false
        // then use .95 for calculation
        Opportunity updatedOppty = [SELECT Id, Post_Close_LTV2__c, Pricing_Ratio__c, Final_OAV_Calculation__c, Estimated_Funding_Amount__c ,OIP_Maximum__c FROM Opportunity WHERE Id =: objOpty1.Id LIMIT 1];
        system.assert(updatedOppty.OIP_Maximum__c == 408333.00);
    }

    private static testMethod void validateForHomeOwner_Qualifies_IsNoo2(){
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeOwnerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty1 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,

                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty1.Post_Close_Mortgage_Debt__c= 1576695;
        objOpty1.Present_Total_Mortgage_Debt__c = 1576695;
        objOpty1.Additional_Applicant_Income__c = 0;
        objOpty1.Income_App1__c = 4854.83;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Final_OAV_Calculation__c = 3200000;
        objOpty1.IA_OAV_Override__c = 3200000;
        objOpty1.Pricing_Ratio__c = 6;
        objOpty1.Post_Close_BE_Ratio__c = 45.05;
        objOpty1.Pre_Close_BE_Ratio__c = 45.05;
        objOpty1.Post_Close_FE_Ratio2__c = 45.05;
        objOpty1.Pre_Close_FE_Ratio2__c = 45.05;
        objOpty1.Post_Close_LTV2__c = 45.05;
        objOpty1.Pre_Close_LTV2__c = 45.05;
        objOpty1.Income_App1__c  = 10000;
        objOpty1.Is_NOO__c = true;
        objOpty1.Qualifies_for_New_HomeOwner_Pricing__c = false;
        insert objOpty1;

        // RecordType = HomeOwner && Qualifies_for_New_HomeOwner_Pricing__c == false && Is_NOO__c == true
        // then use .80 for calculation
        Opportunity updatedOppty = [SELECT Id, Post_Close_LTV2__c, Pricing_Ratio__c, Final_OAV_Calculation__c, Estimated_Funding_Amount__c ,OIP_Maximum__c FROM Opportunity WHERE Id =: objOpty1.Id LIMIT 1];
        system.assert(updatedOppty.OIP_Maximum__c == 373333.00);
    }

    private static testMethod void validateForHomeOwner_Qualifies_IsNoo3(){
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeOwnerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty1 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,

                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty1.Post_Close_Mortgage_Debt__c= 1576695;
        objOpty1.Present_Total_Mortgage_Debt__c = 1576695;
        objOpty1.Additional_Applicant_Income__c = 0;
        objOpty1.Income_App1__c = 4854.83;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Final_OAV_Calculation__c = 4500000;
        objOpty1.IA_OAV_Override__c = 4500000;
        objOpty1.Pricing_Ratio__c = 6;
        objOpty1.Post_Close_BE_Ratio__c = 45.05;
        objOpty1.Pre_Close_BE_Ratio__c = 45.05;
        objOpty1.Post_Close_FE_Ratio2__c = 45.05;
        objOpty1.Pre_Close_FE_Ratio2__c = 45.05;
        objOpty1.Post_Close_LTV2__c = 45.05;
        objOpty1.Pre_Close_LTV2__c = 45.05;
        objOpty1.Income_App1__c  = 10000;
        objOpty1.Qualifies_for_New_HomeOwner_Pricing__c = true;
        objOpty1.Is_NOO__c = true;
        insert objOpty1;

        // RecordType = HomeOwner && Qualifies_for_New_HomeOwner_Pricing__c == true && Is_NOO__c == true
        // then use 87.5 for calculation
        Opportunity updatedOppty = [SELECT Id, Post_Close_LTV2__c, Pricing_Ratio__c, Final_OAV_Calculation__c, Estimated_Funding_Amount__c ,OIP_Maximum__c FROM Opportunity WHERE Id =: objOpty1.Id LIMIT 1];
        // 500k cap if oip max > $500,000.00
        system.assert(updatedOppty.OIP_Maximum__c == 500000.00);
    }


    private static testMethod void validateForHomeBuyer()
    {
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Post_Close_Mortgage_Debt__c= 10000;
        objOpty2.Present_Total_Mortgage_Debt__c = 20000;
        objOpty2.Final_OAV_Calculation__c = 3500000;
        objOpty2.Pricing_Ratio__c = 6;
        objOpty2.Post_Close_BE_Ratio__c = 70;
        objOpty2.Pre_Close_BE_Ratio__c = 60;
        objOpty2.Post_Close_LTV2__c = 45.05;
        objOpty2.Pre_Close_LTV2__c = 45.05;
        objOpty2.Income_App1__c  = 10000;
        insert objOpty2;
    }

    private static testMethod void validateForHomeBuyer_Qualifies_IsNoo1()
    {
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Record_Type_Name__c = 'HomeBuyer';
        objOpty2.Is_NOO__c = true;
        objOpty2.Sum_of_Debt_to_be_Paid_Off__c = 0;
        objOpty2.Summary_Appraised_Value__c = 0;
        objOpty2.Purchase_Price__c = 10;
        objOpty2.OAV_Discount_Pct__c = 20;
        objOpty2.Post_Close_LTV_Redux_Sum__c = null;
        objOpty2.Post_Close_Mortgage_Debt__c= 1576695;
        objOpty2.Present_Total_Mortgage_Debt__c = 1576695;
        objOpty2.Additional_Applicant_Income__c = 0;
        objOpty2.Income_App1__c = 4854.83;
        objOpty2.Income_Co_App1__c = 3052.50;
        objOpty2.Income_Co_App1__c = 3052.50;
        objOpty2.Final_OAV_Calculation__c = 3130000;
        objOpty2.IA_OAV_Override__c = 3130000;
        objOpty2.Pricing_Ratio__c = 6;
        objOpty2.Post_Close_BE_Ratio__c = 45.05;
        objOpty2.Pre_Close_BE_Ratio__c = 45.05;
        objOpty2.Post_Close_FE_Ratio2__c = 45.05;
        objOpty2.Pre_Close_FE_Ratio2__c = 45.05;
        objOpty2.Post_Close_LTV2__c = 45.05;
        objOpty2.Pre_Close_LTV2__c = 45.05;
        insert objOpty2;

        // RecordType = HomeBuyer && Is_NOO__c == false
        // then use .95 for calculation
        Opportunity updatedOppty = [SELECT Id, Post_Close_LTV2__c, Pricing_Ratio__c, Final_OAV_Calculation__c, Estimated_Funding_Amount__c ,OIP_Maximum__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        system.assert(updatedOppty.OIP_Maximum__c == 365167.00);
    }

    private static testMethod void validateForHomeBuyer_Qualifies_IsNoo2()
    {
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Record_Type_Name__c = 'HomeBuyer';
        objOpty2.Post_Close_Mortgage_Debt__c= 1576695;
        objOpty2.Present_Total_Mortgage_Debt__c = 1576695;
        objOpty2.Additional_Applicant_Income__c = 0;
        objOpty2.Income_App1__c = 4854.83;
        objOpty2.Income_Co_App1__c = 3052.50;
        objOpty2.Income_Co_App1__c = 3052.50;
        objOpty2.Final_OAV_Calculation__c = 3160000;
        objOpty2.IA_OAV_Override__c = 3160000;
        objOpty2.Pricing_Ratio__c = 6;
        objOpty2.Post_Close_BE_Ratio__c = 45.05;
        objOpty2.Pre_Close_BE_Ratio__c = 45.05;
        objOpty2.Post_Close_FE_Ratio2__c = 45.05;
        objOpty2.Pre_Close_FE_Ratio2__c = 45.05;
        objOpty2.Post_Close_LTV2__c = 45.05;
        objOpty2.Pre_Close_LTV2__c = 45.05;
        objOpty2.Is_NOO__c = true;
        objOpty2.Sum_of_Debt_to_be_Paid_Off__c = 0;
        objOpty2.Summary_Appraised_Value__c = 10;
        objOpty2.Purchase_Price__c = 0;
        objOpty2.OAV_Discount_Pct__c = 20;
        insert objOpty2;

        // RecordType = HomeBuyer && Is_NOO__c == true
        // then use 87.5 for calculation
        Opportunity updatedOppty = [SELECT Id, Post_Close_LTV2__c, Pricing_Ratio__c, Final_OAV_Calculation__c, Estimated_Funding_Amount__c ,OIP_Maximum__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        system.assert(updatedOppty.OIP_Maximum__c == 368667.00);
    }

    private static testMethod void validateForHomeBuyer_Number_Of_Units_Null()
    {
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeOwnerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty1 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,

                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty1.Post_Close_Mortgage_Debt__c= 1576695;
        objOpty1.Present_Total_Mortgage_Debt__c = 1576695;
        objOpty1.Additional_Applicant_Income__c = 0;
        objOpty1.Income_App1__c = 4854.83;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Income_Co_App1__c = 3052.50;
        objOpty1.Final_OAV_Calculation__c = 3500000;
        objOpty1.IA_OAV_Override__c = 3500000;
        objOpty1.Pricing_Ratio__c = 6;
        objOpty1.Post_Close_BE_Ratio__c = 45.05;
        objOpty1.Pre_Close_BE_Ratio__c = 45.05;
        objOpty1.Post_Close_FE_Ratio2__c = 45.05;
        objOpty1.Pre_Close_FE_Ratio2__c = 45.05;
        objOpty1.Post_Close_LTV2__c = 45.05;
        objOpty1.Pre_Close_LTV2__c = 45.05;
        objOpty1.Income_App1__c  = 10000;
        objOpty1.Qualifies_for_New_HomeOwner_Pricing__c = false;
        objOpty1.Is_NOO__c = true;
        insert objOpty1;

        Property__c newprop = new Property__c();
        newprop.Name = 'Test';
        newprop.Property_Type__c = 'Condominium';
        newprop.Build_Year__c = '2019';
        newprop.Property_New_Construction_Flag__c = True;
        newprop.Property_Street_Number_and_Name__c = 'test asd 123';
        newprop.Property_City__c = 'test asd 123';
        newprop.Property_State__c = 'CA';
        newprop.Property_Zip_Code__c = '12345';
        newprop.Property_County__c = 'test asd 123';
        newprop.Property_Number_of_Units__c = null;
        newprop.Opportunity__c=objOpty1.Id;
        insert newprop;

        objOpty1.Is_NOO__c = false;
        update objOpty1;

        // RecordType = HomeOwner && Qualifies_for_New_HomeOwner_Pricing__c == true && Is_NOO__c == false
        // then use .95 for calculation
        Opportunity updatedOppty = [SELECT Id, Post_Close_LTV2__c, Pricing_Ratio__c, Final_OAV_Calculation__c, Estimated_Funding_Amount__c ,OIP_Maximum__c FROM Opportunity WHERE Id =: objOpty1.Id LIMIT 1];
        system.assertEquals(updatedOppty.OIP_Maximum__c, 408333.00);
    }

    private static testMethod void validateRoundOIP_beforeInsert()
    {
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Post_Close_Mortgage_Debt__c= 10000;
        objOpty2.Present_Total_Mortgage_Debt__c = 20000;
        objOpty2.Final_OAV_Calculation__c = 500000;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Post_Close_BE_Ratio__c = 70;
        objOpty2.Pre_Close_BE_Ratio__c = 60;
        objOpty2.Post_Close_LTV2__c = 80;
        objOpty2.Pre_Close_LTV2__c = 80;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 20.66;
        insert objOpty2;
        system.debug(' afterInsert ' + objOpty2.Estimated_Funding_Amount__c);

        Opportunity roundedOIP_Opportunity = [SELECT Id, Estimated_Funding_Amount__c FROM Opportunity WHERE Id =: objOpty2.Id];
        system.assert(roundedOIP_Opportunity.Estimated_Funding_Amount__c == 21);
    }

    private static testMethod void validateRoundOIP_beforeUpdate()
    {
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Post_Close_Mortgage_Debt__c= 10000;
        objOpty2.Present_Total_Mortgage_Debt__c = 20000;
        objOpty2.Final_OAV_Calculation__c = 500000;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Post_Close_BE_Ratio__c = 70;
        objOpty2.Pre_Close_BE_Ratio__c = 60;
        objOpty2.Post_Close_LTV2__c = 80;
        objOpty2.Pre_Close_LTV2__c = 80;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 20.66;
        insert objOpty2;

        Opportunity roundedOIP_Opportunity = [SELECT Id, Estimated_Funding_Amount__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        roundedOIP_Opportunity.Estimated_Funding_Amount__c = 55.66;
        update roundedOIP_Opportunity;

        Opportunity roundedOIP_OpportunityAfterUpdate = [SELECT Id, Estimated_Funding_Amount__c FROM Opportunity WHERE Id =: roundedOIP_Opportunity.Id LIMIT 1];
        system.assert(roundedOIP_OpportunityAfterUpdate.Estimated_Funding_Amount__c == 56);
    }

    private static testMethod void validateProgramFloor_1() {
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Post_Close_Mortgage_Debt__c= 10000;
        objOpty2.Present_Total_Mortgage_Debt__c = 20000;
        objOpty2.Final_OAV_Calculation__c = 500000;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Post_Close_BE_Ratio__c = 70;
        objOpty2.Pre_Close_BE_Ratio__c = 60;
        objOpty2.Post_Close_LTV2__c = 80;
        objOpty2.Pre_Close_LTV2__c = 80;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 20.66;
        objOpty2.Opportunity_Created_From_Lead__c = true;
        insert objOpty2;

        Test.startTest();
        Opportunity updateProgramFloor = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        updateProgramFloor.Is_NOO__c = true;
        update updateProgramFloor;
        Test.stopTest();

        Opportunity opportunityAfterUpdate = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: updateProgramFloor.Id LIMIT 1];
        system.assert(opportunityAfterUpdate.Program_Floor__c == '5 Year');
    }

    private static testMethod void validateProgramFloor_HB() {
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeBuyerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeBuyerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Post_Close_Mortgage_Debt__c= 10000;
        objOpty2.Present_Total_Mortgage_Debt__c = 20000;
        objOpty2.Final_OAV_Calculation__c = 500000;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Post_Close_BE_Ratio__c = 70;
        objOpty2.Pre_Close_BE_Ratio__c = 60;
        objOpty2.Post_Close_LTV2__c = 80;
        objOpty2.Pre_Close_LTV2__c = 80;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 20.66;
        objOpty2.Opportunity_Created_From_Lead__c = true;
        objOpty2.Is_NOO__c = true;
        insert objOpty2;

        Test.startTest();
        Opportunity updateProgramFloor = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        updateProgramFloor.Is_NOO__c = false;
        update updateProgramFloor;
        Test.stopTest();

        Opportunity opportunityAfterUpdate = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: updateProgramFloor.Id LIMIT 1];
        system.debug('programFloor ' + opportunityAfterUpdate.Program_Floor__c);
        system.assert(opportunityAfterUpdate.Program_Floor__c == '3 Year');
    }

    private static testMethod void validateProgramFloor_HO_1() {
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Post_Close_Mortgage_Debt__c= 10000;
        objOpty2.Present_Total_Mortgage_Debt__c = 20000;
        objOpty2.Final_OAV_Calculation__c = 500000;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Post_Close_BE_Ratio__c = 70;
        objOpty2.Pre_Close_BE_Ratio__c = 60;
        objOpty2.Post_Close_LTV2__c = 80;
        objOpty2.Pre_Close_LTV2__c = 80;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 20.66;
        objOpty2.Opportunity_Created_From_Lead__c = true;
        insert objOpty2;

        Test.startTest();
        Opportunity updateProgramFloor = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        updateProgramFloor.Qualifies_for_New_HomeOwner_Pricing__c = true;
        updateProgramFloor.Is_NOO__c = false;
        update updateProgramFloor;
        Test.stopTest();

        Opportunity opportunityAfterUpdate = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: updateProgramFloor.Id LIMIT 1];
        system.assert(opportunityAfterUpdate.Program_Floor__c == '3 Year');
    }

    private static testMethod void validateProgramFloor_HO_2() {
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Post_Close_Mortgage_Debt__c= 10000;
        objOpty2.Present_Total_Mortgage_Debt__c = 20000;
        objOpty2.Final_OAV_Calculation__c = 500000;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Post_Close_BE_Ratio__c = 70;
        objOpty2.Pre_Close_BE_Ratio__c = 60;
        objOpty2.Post_Close_LTV2__c = 80;
        objOpty2.Pre_Close_LTV2__c = 80;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 20.66;
        objOpty2.Opportunity_Created_From_Lead__c = true;
        insert objOpty2;

        Test.startTest();
        Opportunity updateProgramFloor = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        updateProgramFloor.Qualifies_for_New_HomeOwner_Pricing__c = false;
        updateProgramFloor.Is_NOO__c = false;
        update updateProgramFloor;
        Test.stopTest();

        Opportunity opportunityAfterUpdate = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: updateProgramFloor.Id LIMIT 1];
        system.assert(opportunityAfterUpdate.Program_Floor__c == '3 Year');
    }

    private static testMethod void validateProgramFloor_HO_3() {
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Final_OAV_Calculation__c = 4000.0;
        objOpty2.IA_OAV_Override__c = 4000.0;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 500000;
        objOpty2.Opportunity_Created_From_Lead__c = true;
        objOpty2.Qualifies_for_New_HomeOwner_Pricing__c = true;
        insert objOpty2;

        Test.startTest();
        Opportunity updateProgramFloor = [SELECT Id, Program_Floor__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        updateProgramFloor.Qualifies_for_New_HomeOwner_Pricing__c = false;
        update updateProgramFloor;
        Test.stopTest();

        Opportunity opportunityAfterUpdate = [SELECT Id, Program_Floor__c, Equity_less_than_origination__c, OIP_Percentage__c, Final_OAV_Calculation__c, Post_Close_LTV2_Converted__c FROM Opportunity WHERE Id =: updateProgramFloor.Id LIMIT 1];
        system.assert(opportunityAfterUpdate.Program_Floor__c == '5 Year');
    }

    private static testMethod void validateIADeclineReason() {
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeOwnerRecId);
        Account objAcc1 = new Account (Name='Test Account');
        insert objAcc1;
        Opportunity objOpty2 = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc1.Id,RecordTypeId=optyHomeOwnerRecId,
                StageName = 'Property in Contract', CloseDate = System.today());

        objOpty2.Final_OAV_Calculation__c = 4000.0;
        objOpty2.IA_OAV_Override__c = 4000.0;
        objOpty2.Pricing_Ratio__c = 4;
        objOpty2.Income_App1__c  = 10000;
        objOpty2.Estimated_Funding_Amount__c = 500000;
        objOpty2.Opportunity_Created_From_Lead__c = true;
        objOpty2.Qualifies_for_New_HomeOwner_Pricing__c = true;
        objOpty2.IA_Decline_Reason__c = 'C5 rating';

        Test.startTest();
        insert objOpty2;
        Test.stopTest();

        Opportunity opportunityAfterUpdate = [SELECT Id, PS_Decline_Reasons__c, AA_Letter_Decline_Reasons__c FROM Opportunity WHERE Id =: objOpty2.Id LIMIT 1];
        system.assert(opportunityAfterUpdate.PS_Decline_Reasons__c == '\u2022 Poor Condition');
        system.assert(opportunityAfterUpdate.AA_Letter_Decline_Reasons__c == '\u2022 Type, condition, or typicality of property unacceptable');
    }
}