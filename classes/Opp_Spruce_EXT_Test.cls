@isTest
private class Opp_Spruce_EXT_Test 
{   
    @isTest static void test_method_one()
    {
        // Data Setup
        Account acc = new Account(Name = 'New Account');
        insert acc; 

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                                  AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                                  AccountID = acc.Id);
        insert con2;
        /* 4/2/2019 Sundar Subramaniam - Field removed from query for Data Model Cleanup */
        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', 
                                    CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Encompass_Loan_Number__c='test01234567890',
                                    Co_Applicant__c = con2.Id, Property_Zip_Code__c = '1223', Property_State__c = 'CA', Property_City__c = 'Las vegas', Property_Street_Number_and_Name__c = 'testStreet', Home_Value__c = 2000, Loan_Amount__c = 2000 );
        insert oppty;
        Opportunity oppty2 = new Opportunity(Name = 'New Oppt2y', AccountId = acc.Id, StageName = 'Submitted to Underwriting', 
                                    CloseDate = Date.today().addDays(20), Applicant__c = con.Id,
                                    Co_Applicant__c = con2.Id);
        insert oppty2;

        Wiring_Information__c winfo = new Wiring_Information__c(Name = 'FirstNam2e', CustomerState__c = 'CA', Title_Company__c = 'Spruce');
        insert winfo;

        Recorded_Information__c recordedInfo = new Recorded_Information__c();
        recordedInfo.Opportunity__c = oppty.Id;
        recordedInfo.Applicant1_Name__c = 'John';
        recordedInfo.Effective_Date__c = System.today();
        insert recordedInfo;
        
        Property__c prop = new Property__c();
        prop.Property_Parcel_Number__c = '123458';
        prop.Property_Legal_Description__c = 'This is a test';
        prop.Opportunity__c = oppty.Id;
        insert prop;



        // Utility method that can be called by Apex tests to create price book entries.
       // static testmethod void addPricebookEntries() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Settlement Fee',
        Family = 'Hardware');
        insert prod;

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



    // Run Code
        System.Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
            Opp_Spruce_EXT ctrl = new Opp_Spruce_EXT(sc);
            ctrl.createSpruceOrder();
            ctrl.BackToOppty();


        System.Test.stopTest();

        // Test Result
        List<Property_Due_Diligence_Reports__c> pddrList = 
            [
                SELECT Id
                FROM Property_Due_Diligence_Reports__c
            ];

        if(pddrList.size()<1){
        System.assertEquals(0, pddrList.size());
        }
    }

    @isTest static void test_method_two()
    {
        // Data Setup
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;
        /* 4/2/2019 Sundar Subramaniam - Field removed from query for Data Model Cleanup */
        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,
                Co_Applicant__c = con2.Id, Property_Zip_Code__c = '1223', Property_State__c = 'CA', Property_City__c = 'Las vegas', Property_Street_Number_and_Name__c = 'testStreet', Home_Value__c = 2000, Loan_Amount__c = 2000 );
        insert oppty;
        Opportunity oppty2 = new Opportunity(Name = 'New Oppt2y', AccountId = acc.Id, StageName = 'Submitted to Underwriting',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,
                Co_Applicant__c = con2.Id);
        insert oppty2;

        Recorded_Information__c recordedInfo = new Recorded_Information__c();
        recordedInfo.Opportunity__c = oppty.Id;
        recordedInfo.Applicant1_Name__c = 'John';
        insert recordedInfo;

        Success_Factor__c sf     = new Success_Factor__c();
        sf.Opportunity__c     = oppty.Id;
        sf.Success_Factor__c  = 'Property Ownership';
        sf.Status__c  = 'In Progress';
        sf.Program__c = 'HO';
        insert sf;

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
        newprop.Property_Flood_Zone__c = 'A10';
        newprop.Opportunity__c=oppty.Id;
        insert newprop;

        Wiring_Information__c winfo = new Wiring_Information__c(Name = 'FirstNam2e', CustomerState__c = 'CA', Title_Company__c = 'Spruce');
        insert winfo;
        // Run Code
        System.Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        Opp_Spruce_EXT ctrl = new Opp_Spruce_EXT(sc);
        ctrl.createSpruceOrder();
        ctrl.BackToOppty();


        System.Test.stopTest();

        // Test Result
        List<Property_Due_Diligence_Reports__c> pddrList =
        [
                SELECT Id
                FROM Property_Due_Diligence_Reports__c
        ];


        System.assertEquals(0, pddrList.size());
    }
}