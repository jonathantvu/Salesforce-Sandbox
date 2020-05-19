/************************************************************************************
 Apex Class Name     : OpportunityTriggerHandlerTest
 Version             : 1.0
 Created Date        : 20th Feb 2019
 Function            : Test Class for OpportunityTriggerHandler class
 Author              : Neeraja Cherukuri
 
 Modification Log    :I have Deprecated all the Test methods that were Commented by the Prior Teams.

* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Neeraja Cherukuri            02/20/2019                Original Version
*************************************************************************************
*/



@isTest
public class OpportunityTriggerHandlerTest 
{
    @testSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock());
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'My TestOpp', AccountId = objAcc.Id,
                StageName = 'Ready for Ops', CloseDate = System.today(),RecordTypeId=optyHomeBuyerRecId,
                UnisonProcessor__c=u.id,Investment_Analyst2__c=u.id,Estimated_Funding_Amount__c = 2,
                Final_OAV_Calculation__c = 2, Pricing_Ratio__c = 2,Title_Held__c= 'In Trust',SEND_TO_ENCOMPASS__c = False,
                IA_OAV_Override__c =2, Passbook_Status__c = 'Approved', Payment_Monthly_HOA__c = 0, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = objOpty.Id;
        sf1.Success_Factor__c  = 'Program';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        Insert sf1;


        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'Revised CAP';
        req2.Success_Factor__c  = sf1.Id;
        req2.opportunity__c      = objOpty.id;
        req2.Code__c = 'R1115';

        Insert req2;

        Property__c newprop = new Property__c();
        newprop.Name = 'Test';
        newprop.Property_Type__c = '2-4 Family';
        newprop.Build_Year__c = '2019';
        newprop.Property_New_Construction_Flag__c = True;
        newprop.Property_Street_Number_and_Name__c = 'test asd 123';
        newprop.Property_City__c = 'test asd 123';
        newprop.Property_State__c = 'CA';
        newprop.Property_Zip_Code__c = '12345';
        newprop.Property_County__c = 'test asd 123';
        newprop.Opportunity__c=objOpty.Id;
        newprop.Property_Condo_PUD_Name__c = 'Condo PUD Name';        
        insert newprop;
        
        DMA__c dma = new DMA__c();
        dma.Opportunity__c = objOpty.Id;
        insert dma;

    }

   private static testMethod void test() {       
       test.startTest();

       Opportunity myOpp = [SELECT Id, StageName, Passbook_Status__c FROM Opportunity WHERE Name = 'My TestOpp' LIMIT 1];
        myOpp.StageName = 'Closing';
        myOpp.Payment_Monthly_HOA__c = 200;
        update myOpp;
       List<Opportunity> opplist = new List<Opportunity>();
       opplist.add(myOpp);

       OpportunityUtilityClass.createClosingOppRequirements(oppList);

        test.stopTest();
    }

   private static testMethod void test_OfferPrevent() {       
       test.startTest();

       Opportunity myOpp = [SELECT Id, StageName, Passbook_Status__c FROM Opportunity WHERE Name = 'My TestOpp' LIMIT 1];
       
        myOpp.StageName = 'Offer';
        update myOpp;
       OpportunityUtilityClass.createOfferOppRequirements(new List<Opportunity> { myOpp });
        myOpp.StageName = 'Closing';
        update myOpp;
       
        test.stopTest();
    }

    private static testMethod void validateForHomeOwner4()
    {
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock());
        test.startTest();
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                StageName = 'Ready for Ops', CloseDate = System.today(),RecordTypeId=optyHomeOwnerRecId,
                UnisonProcessor__c=u.id,Investment_Analyst2__c=u.id,Estimated_Funding_Amount__c = 2,
                Final_OAV_Calculation__c = 2, Pricing_Ratio__c = 2,Title_Held__c= 'In Trust',SEND_TO_ENCOMPASS__c = False,
                IA_OAV_Override__c =2,Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = objOpty.Id;
        sf1.Success_Factor__c  = 'Program';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        Insert sf1;


        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'Revised CAP';
        req2.Success_Factor__c  = sf1.Id;
        req2.opportunity__c      = objOpty.id;
        req2.Code__c = 'R1115';

        Insert req2;

        req2.Status__c = 'Cleared';
        update req2;

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
        newprop.Opportunity__c=objOpty.Id;
        insert newprop;

        Property__c newprop2 = new Property__c();
        newprop2.Name = 'Test';
        newprop2.Property_Type__c = 'PUD';
        newprop2.Build_Year__c = '2019';
        newprop2.Property_New_Construction_Flag__c = True;
        newprop2.Property_Street_Number_and_Name__c = 'test asd 123';
        newprop2.Property_City__c = 'test asd 123';
        newprop2.Property_State__c = 'CA';
        newprop2.Property_Zip_Code__c = '12345';
        newprop2.Property_County__c = 'test asd 123';
        newprop2.Opportunity__c=objOpty.Id;
        insert newprop2;

        // Utility method that can be called by Apex tests to create price book entries.
        // static testmethod void addPricebookEntries() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Acquisition Fee',
                Family = 'Hardware');
        insert prod;

        Product2 prod2 = new Product2(Name = 'Transaction Fee',
                Family = 'Hardware');
        insert prod2;

        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();

        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Fee', isActive=true);
        insert customPB;

        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
        insert customPrice;




        objOpty.StageName = 'Investment Due Diligence';
        update objOpty;
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(objOpty);
        //cv//OpportunityTriggerHandler.handleAfterInsert(opplist);

        try {
            OpportunityUtilityClass.createIDDOppRequirements(oppList);
        }
        catch(Exception e){

        }
        test.stopTest();
    }


    private static testMethod void validateForHomeBuyer()
    {
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock());
        test.startTest();
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                                            StageName = 'Ready for Ops', CloseDate = System.today(),RecordTypeId=optyHomeBuyerRecId,
                                            UnisonProcessor__c=u.id,Investment_Analyst2__c=u.id,Estimated_Funding_Amount__c = 2,
                                            Final_OAV_Calculation__c = 2, Pricing_Ratio__c = 2,Title_Held__c= 'In Trust',SEND_TO_ENCOMPASS__c = False,
                                            IA_OAV_Override__c =2,Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;

        Success_Factor__c sf1     = new Success_Factor__c();
            sf1.Opportunity__c     = objOpty.Id;
            sf1.Success_Factor__c  = 'Program';
            sf1.Status__c = 'In Progress';
            sf1.Program__c = 'HO';
        Insert sf1;
        
                
        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'Revised CAP';   
        req2.Success_Factor__c  = sf1.Id; 
        req2.opportunity__c      = objOpty.id;
        req2.Code__c = 'R1115';

        Insert req2;
        
        req2.Status__c = 'Cleared';
        update req2;

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
        newprop.Opportunity__c=objOpty.Id;
        insert newprop;

        Property__c newprop2 = new Property__c();
        newprop2.Name = 'Test';
        newprop2.Property_Type__c = 'PUD';
        newprop2.Build_Year__c = '2019';
        newprop2.Property_New_Construction_Flag__c = True;
        newprop2.Property_Street_Number_and_Name__c = 'test asd 123';
        newprop2.Property_City__c = 'test asd 123';
        newprop2.Property_State__c = 'CA';
        newprop2.Property_Zip_Code__c = '12345';
        newprop2.Property_County__c = 'test asd 123';
        newprop2.Opportunity__c=objOpty.Id;
        insert newprop2;

        // Utility method that can be called by Apex tests to create price book entries.
        // static testmethod void addPricebookEntries() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Acquisition Fee',
                Family = 'Hardware');
        insert prod;

        Product2 prod2 = new Product2(Name = 'Transaction Fee',
                Family = 'Hardware');
        insert prod2;

        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();

        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Fee', isActive=true);
        insert customPB;

        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
        insert customPrice;




        objOpty.StageName = 'Investment Due Diligence';
        update objOpty;
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(objOpty);
        //cv//OpportunityTriggerHandler.handleAfterInsert(opplist);

        try {
            OpportunityUtilityClass.createIDDOppRequirements(oppList);
        }
        catch(Exception e){

        }
        test.stopTest();
    } 
    private static testMethod void validateWitoutOAVValue()
    {        
        test.startTest();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,Pricing_Ratio__c = 4,
                                                            StageName = 'Property in Contract', CloseDate = System.today(),Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;
        
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        /* 4/5/2019 Neeraja Cherukuri - Replaced with New Fieldsfor Data Model Clean Up */

        objOpty.Summary_Appraised_Value__c= 0;

        update objOpty;

        test.stopTest();
    }
    private static testMethod void validateForHomeOwner()
    {        
        test.startTest();
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Id optyHomeOwnerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        System.debug('=====optyHomeBuyerRecId===='+optyHomeOwnerRecId);
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,RecordTypeId=optyHomeOwnerRecId,
                                                            StageName = 'Property in Contract', CloseDate = System.today(),UnisonProcessor__c=u.id,
                                                            Investment_Analyst2__c=u.id,Estimated_Funding_Amount__c = 2,
                                                            Final_OAV_Calculation__c = 2, Pricing_Ratio__c = 2,
                                                            Post_Close_Home_Inspection_Check__c = True,
                                                            IA_OAV_Override__c =2,
                                                            Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;


        Success_Factor__c sf1     = new Success_Factor__c();
            sf1.Opportunity__c     = objOpty.Id;
            sf1.Success_Factor__c  = 'Cash to Consumer';
           // sf1.Status__c = 'Completed';
            sf1.Status__c = 'In Progress';
        Insert sf1; 
        
        
          
        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'Natural Hazard Disclosure';   
        req2.Success_Factor__c  = sf1.Id; 
        req2.opportunity__c      = objOpty.id;
        Insert req2;
        
        req2.Status__c = 'Document Ready for Review';
        update req2;
        
        
        //sf1.Status__c = 'Completed';
        //update sf1;
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        /* 4/5/2019 Neeraja Cherukuri - Replaced fo new fields in Data Model Cleanup */

        objOpty.Summary_Appraised_Value__c= 0;
      //  objOpty.StageName = 'Final Approval';
        update objOpty;
        test.stopTest();
    }


    private static testMethod void validateForHomeOwner2()
    {        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());        
        test.startTest();
        OpportunityTriggerHandler.createdRequirements = true;
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                StageName = 'Closing', CloseDate = System.today(),RecordTypeId=optyHomeBuyerRecId,
                UnisonProcessor__c=u.id,Investment_Analyst2__c=u.id,Estimated_Funding_Amount__c = 2,
                Final_OAV_Calculation__c = 2, Pricing_Ratio__c = 2,Title_Held__c= 'In Trust',SEND_TO_ENCOMPASS__c = False,
                IA_OAV_Override__c =2,Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0, OIP_Confirmed__c = true);

        insert objOpty;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = objOpty.Id;
        sf1.Success_Factor__c  = 'Cash to Consumer';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        Insert sf1;


        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'Revised CAP';
        req2.Success_Factor__c  = sf1.Id;
        req2.opportunity__c      = objOpty.id;
        req2.Code__c = 'R1115';
        Insert req2;

        req2.Status__c = 'Cleared';
        update req2;


        // Utility method that can be called by Apex tests to create price book entries.
        // static testmethod void addPricebookEntries() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Acquisition Fee',
                Family = 'Hardware');
        insert prod;

        Product2 prod2 = new Product2(Name = 'Transaction Fee',
                Family = 'Hardware');
        insert prod2;

        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();

        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Fee', isActive=true);
        insert customPB;

        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
        insert customPrice;



        //objOpty.IA_OAV_Override__c = 456456;
        // objOpty.StageName = 'Investment Due Diligence';
        update objOpty;
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(objOpty);
        //cv//OpportunityTriggerHandler.handleAfterInsert(opplist);

        try {
            //OpportunityTriggerHandler.createRequirementsatStages(oppList);
        }
        catch(Exception e){

        }
        test.stopTest();
    }


    private static testMethod void validateForHomeOwner3()
    {
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock());
        test.startTest();
        OpportunityTriggerHandler.createdRequirements = true;
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                StageName = 'Investment Due Diligence', CloseDate = System.today(),RecordTypeId=optyHomeBuyerRecId,
                UnisonProcessor__c=u.id,Investment_Analyst2__c=u.id,Estimated_Funding_Amount__c = 2,
                Final_OAV_Calculation__c = 2, Pricing_Ratio__c = 4,Title_Held__c= 'In Trust',IA_OAV_Override__c =2,Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = objOpty.Id;
        sf1.Success_Factor__c  = 'Program';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        Insert sf1;


        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'Revised CAP';
        req2.Success_Factor__c  = sf1.Id;
        req2.opportunity__c      = objOpty.id;
        req2.Code__c = 'R1115';
        Insert req2;

        req2.Status__c = 'Cleared';
        update req2;

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
        newprop.Opportunity__c=objOpty.Id;
        insert newprop;

        Property__c newprop2 = new Property__c();
        newprop2.Name = 'Test';
        newprop2.Property_Type__c = 'PUD';
        newprop2.Build_Year__c = '2019';
        newprop2.Property_New_Construction_Flag__c = True;
        newprop2.Property_Street_Number_and_Name__c = 'test asd 123';
        newprop2.Property_City__c = 'test asd 123';
        newprop2.Property_State__c = 'CA';
        newprop2.Property_Zip_Code__c = '12345';
        newprop2.Property_County__c = 'test asd 123';
        newprop2.Opportunity__c=objOpty.Id;
        insert newprop2;


        // Utility method that can be called by Apex tests to create price book entries.
        // static testmethod void addPricebookEntries() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Acquisition Fee',
                Family = 'Hardware');
        insert prod;

        Product2 prod2 = new Product2(Name = 'Transaction Fee',
                Family = 'Hardware');
        insert prod2;

        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();

        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Fee', isActive=true);
        insert customPB;

        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
        insert customPrice;



        objOpty.IA_OAV_Override__c = 456456;
        // objOpty.StageName = 'Investment Due Diligence';
        update objOpty;
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(objOpty);

        OpportunityTriggerHandler.handleAfterInsert(opplist);

        try {
            //OpportunityTriggerHandler.createRequirementsatStages(oppList);
        }
        catch(Exception e){

        }
        test.stopTest();
    }

    /*
    private static testMethod void requirementStagesInvestmentDueDiligence()
    {
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                StageName = 'Investment Due Diligence', CloseDate = System.today());
        insert objOpty;

        objOpty.Summary_Appraised_Value__c= 0;

        update objOpty;

        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(objOpty);

        OpportunityUtilityClass.createIDDOppRequirements(oppList);

    }*/

    private static testMethod void test1()
    {        
        test.startTest();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                StageName = 'Property in Contract', CloseDate = System.today(), Pricing_Ratio__c = 4,
                Opportunity_Created_From_Lead__c=true,Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;

        objOpty.Summary_Appraised_Value__c= 0;
        objOpty.Payment_Monthly_HOA__c=150;
        update objOpty;
        test.stopTest();

    }
    
    @istest
    private static void updateFinalAmounttest(){        
        test.startTest();
        Product2 prod1 = new Product2(Name = 'Transaction Fee',
                Family = 'Hardware');
        insert prod1;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod1.Id,
                UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Pricebook2 customPB = new Pricebook2(Name='Fee', isActive=true);
        insert customPB;

        PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod1.Id,
                UnitPrice = 12000, IsActive = true);
        insert customPrice;


        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                StageName = 'Property in Contract', CloseDate = System.today(),Pricing_Ratio__c = 4,
                Opportunity_Created_From_Lead__c=true,Estimated_Funding_Amount__c=50,Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;


        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=objOpty.Id, PricebookEntryId=customPrice.Id,UnitPrice=100, Quantity=1);
        //insert oli1;


        objOpty.Estimated_Funding_Amount__c= 100;

        update objOpty;

        test.stopTest();
    }
        
    private static testMethod void test_PostClosingRequirements()
    {
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock());
        test.startTest();
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Id optyHomeBuyerRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                                            StageName = 'Ready for Ops', CloseDate = System.today(),RecordTypeId=optyHomeBuyerRecId,
                                            UnisonProcessor__c=u.id,Investment_Analyst2__c=u.id,Estimated_Funding_Amount__c = 2,
                                            Final_OAV_Calculation__c = 2, Pricing_Ratio__c = 2,Title_Held__c= 'In Trust',SEND_TO_ENCOMPASS__c = False,
                                            IA_OAV_Override__c =2,Payment_Monthly_HOA__c = 25, Payment_Monthly_First_Mortgage__c = 1.0);
        insert objOpty;

        Success_Factor__c sf1     = new Success_Factor__c();
            sf1.Opportunity__c     = objOpty.Id;
            sf1.Success_Factor__c  = 'Program';
            sf1.Status__c = 'In Progress';
            sf1.Program__c = 'HO';
        Insert sf1;
        
                
        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'Revised CAP';   
        req2.Success_Factor__c  = sf1.Id; 
        req2.opportunity__c      = objOpty.id;
        req2.Code__c = 'R1115';

        Insert req2;
        
        req2.Status__c = 'Cleared';
        update req2;

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
        newprop.Opportunity__c=objOpty.Id;
        insert newprop;

        Property__c newprop2 = new Property__c();
        newprop2.Name = 'Test';
        newprop2.Property_Type__c = 'PUD';
        newprop2.Build_Year__c = '2019';
        newprop2.Property_New_Construction_Flag__c = True;
        newprop2.Property_Street_Number_and_Name__c = 'test asd 123';
        newprop2.Property_City__c = 'test asd 123';
        newprop2.Property_State__c = 'CA';
        newprop2.Property_Zip_Code__c = '12345';
        newprop2.Property_County__c = 'test asd 123';
        newprop2.Opportunity__c=objOpty.Id;
        insert newprop2;

        // Utility method that can be called by Apex tests to create price book entries.
        // static testmethod void addPricebookEntries() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Acquisition Fee',
                Family = 'Hardware');
        insert prod;

        Product2 prod2 = new Product2(Name = 'Transaction Fee',
                Family = 'Hardware');
        insert prod2;

        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();

        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Fee', isActive=true);
        insert customPB;

        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
        insert customPrice;

        objOpty.StageName = 'Post-Closing';
        update objOpty;
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(objOpty);

        //try
        {
            OpportunityUtilityClass.createPostClosingOppRequirements(oppList);
        }
        //catch(Exception e)
    {

        }
        test.stopTest();
    }        
    /*
    private static testMethod void test_SetQualifiesforNewHOPricing()
    {

        Test.startTest();

        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test287836';
        opp1.StageName = 'Investment Due Diligence';
        opp1.CloseDate = Date.today();
        opp1.New_HomeOwner_Purchase_Date__c = Date.today();
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test287837';
        opp2.StageName = 'Investment Due Diligence';
        opp2.CloseDate = Date.today();
        opp2.New_HomeOwner_Purchase_Date__c = Date.today().addYears(2);

        insert new List<Opportunity> { opp1, opp2 };

        Test.stopTest();

        opp1 = [SELECT Qualifies_for_New_HomeOwner_Pricing__c FROM Opportunity WHERE Id = :opp1.Id];
        System.assertEquals(true, opp1.Qualifies_for_New_HomeOwner_Pricing__c);
        opp2 = [SELECT Qualifies_for_New_HomeOwner_Pricing__c FROM Opportunity WHERE Id = :opp2.Id];
        System.assertEquals(false, opp2.Qualifies_for_New_HomeOwner_Pricing__c);

    }*/        
}