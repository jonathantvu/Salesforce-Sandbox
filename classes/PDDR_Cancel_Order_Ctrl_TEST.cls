/**********************************************************
 * @className   : PDDR_Cancel_Order_Ctrl_TEST.cls
 * @date        : April 10, 2018
 * @description : This class provides test methods for PDDR_Cancel_Order_Ctrl.cls
 * @param       :
 * @return      :
 *
 *
 **********************************************************/ 

@isTest 
private class PDDR_Cancel_Order_Ctrl_TEST {

    @isTest
    private static void testName() {
        /*Account acc = new Account(Name = 'New Account');
        insert acc; 
        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                                  AccountID = acc.Id);
        insert con;

        String homBuyerRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Oppty Name';
        oppty.AccountId = acc.Id;
        oppty.RecordTypeId = homBuyerRTId;
        oppty.StageName = 'Closed Lost';
        oppty.CloseDate = Date.today().addDays(20);
        oppty.Loss_Type__c = 'Withdrawn';
        oppty.Loss_Reason_Code__c = 'Customer information is fake or cannot be used to contact the customer';
        oppty.Property_Street_Number_and_Name__c = 'street 1';
        oppty.Property_City__c = 'San Francisco';
        oppty.Property_State__c = 'CA';
        oppty.Property_Zip_Code__c = '12354';
        *//* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup *//*
        //oppty.Property_Type__c = 'Single-family detached';
        insert oppty;*/

        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;

        /* 4/2/2019 Sundar Subramaniam - Is_there_Co_App__c removed from query for Data Model Cleanup */
        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = '2-4 Family',
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,Lien_First_Lender_Balance__c = 100);
        insert oppty;

        Property_Due_Diligence_Reports__c pddr = new Property_Due_Diligence_Reports__c();
        pddr.Opportunity__c = oppty.Id;
        pddr.House_Canary_Order_Id__c = '255';
        pddr.Order_Type__c = 'devFakeInspectAndEvaluate';
        pddr.Name = 'Property Test1';
        insert pddr;

        System.Test.startTest();
            
            ApexPages.StandardController sc = new ApexPages.StandardController(pddr);
            PDDR_Cancel_Order_Ctrl ctrl = new PDDR_Cancel_Order_Ctrl(sc);
            ctrl.CancelOrder();
            ctrl.isCancelled = true;
            ctrl.CancelOrder();
        System.Test.stopTest();
    }
}