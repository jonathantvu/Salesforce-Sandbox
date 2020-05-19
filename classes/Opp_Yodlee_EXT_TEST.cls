/**********************************************************
 * @className   : Opp_Yodlee_EXT_TEST.cls
 * @date        : May 7, 2018
 * @description : This class provide test methods for Opp_Yodlee_EXT.cls
 *
 *
 **********************************************************/ 

@isTest 
private class Opp_Yodlee_EXT_TEST {

    @isTest
    private static void testName() {


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
                                    CloseDate = Date.today().addDays(20), Applicant__c = con.Id,
                                    Co_Applicant__c = con2.Id);
        insert oppty;
        
        System.Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
            Opp_Yodlee_EXT ctrl = new Opp_Yodlee_EXT(sc);
            ctrl.generateYodleeOrder();
            ctrl.BackToOppty();

        System.Test.stopTest();

        List<Yodlee_Order_Request__c> yodleeOrderRequests = [Select Id from Yodlee_Order_Request__c];

        System.assert(yodleeOrderRequests.size() > 0);
    }

    @isTest
    private static void testName2() {


        Account acc = new Account(Name = 'New Account');
        insert acc; 

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                                  AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                                  AccountID = acc.Id);
        insert con2;

        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', 
                                    CloseDate = Date.today().addDays(20));
        insert oppty;
        
        System.Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
            Opp_Yodlee_EXT ctrl = new Opp_Yodlee_EXT(sc);
            ctrl.generateYodleeOrder();
            ctrl.BackToOppty();

        System.Test.stopTest();

        List<Yodlee_Order_Request__c> yodleeOrderRequests = [Select Id from Yodlee_Order_Request__c];

        System.assert(yodleeOrderRequests.size() == 0);
    }
}