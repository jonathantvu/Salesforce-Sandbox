/**********************************************************
 * @className   : CreateSubmitOrdersCtrl_TEST.cls
 * @date        : March 6, 2018
 * @description : This class provides test methods for CreateSubmitOrdersCtrl.cls
 * @param       :
 * @return      :
 *
 *
 **********************************************************/

@isTest
private class CreateSubmitOrdersCtrl_TEST {

    @isTest
    private static void testName() {
        Test.setMock(HttpCalloutMock.class, new HCCalloutMockImpl());

        Account acc = new Account(Name = 'New Account');
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
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        //oppty.Property_Type__c = 'Single-family detached';
        try {
            insert oppty;
        }
        catch (exception e){}

        System.Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        CreateSubmitOrdersCtrl ctrl = new CreateSubmitOrdersCtrl(sc);
        ctrl.InsertPddrItem();
        ctrl.createAndSubmitOrders();
        ctrl.result = '{"id":232,"customer_order_id":"a1P2F000000ZX9vUAG","name":"Property Test1","order_type":"devFakeInspectAndEvaluate","intended_use":"test","inspection_partner":4,"valuation_partner":5,"special_comments":null,"client_name":"Unison Home Ownership Investments","client_address":"650 California St","client_city":"San Francisco","client_state":"CA","client_zipcode":"94108","client_phone":"(415) 992-4200","lender_name":null,"lender_address":null,"lender_city":null,"lender_state":null,"lender_zipcode":null,"lender_phone":null,"desired_delivery_date":"2018-02-21","label":"Appraisal","items":[{"id":260,"customer_item_id":"a1P2F000000ZX9vUAG","address":"741 Venice Way Apt 7","unit":null,"city":"Inglewood","state":"CA","zipcode":"90302","property_type":"condo"}]}';
        ctrl.createAndSubmitOrders();


       /* Property_Due_Diligence_Reports__c tmpPDDR = new Property_Due_Diligence_Reports__c(Name = 'Property Test1', Type__c = 'Inspection', Order_Type__c = 'devFakeInspectAndEvaluate', Opportunity__c = oppty.id);
        insert tmpPDDR;
        ctrl.pddr = tmpPDDR;
        ctrl.createAndSubmitOrders();*/
        System.Test.stopTest();
    }

    @isTest
    private static void testCreateandSubmit() {
        Test.setMock(HttpCalloutMock.class, new HCCalloutMockImpl());

        Account acc = new Account(Name = 'New Account');
        insert acc;
        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Opportunity o = new Opportunity();
        o.AccountId = acc.Id;
        o.Name = 'Test Opp';
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        //o.Converted_Close_Date__c = System.Today().addMonths(3);
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.Estimated_Funding_Amount__c = 1000;
        insert o;
        System.Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        CreateSubmitOrdersCtrl ctrl = new CreateSubmitOrdersCtrl(sc);

        ctrl.result = '{"id":232,"customer_order_id":"a1P2F000000ZX9vUAG","name":"Property Test1","order_type":"devFakeInspectAndEvaluate","intended_use":"test","inspection_partner":4,"valuation_partner":5,"special_comments":null,"client_name":"Unison Home Ownership Investments","client_address":"650 California St","client_city":"San Francisco","client_state":"CA","client_zipcode":"94108","client_phone":"(415) 992-4200","lender_name":null,"lender_address":null,"lender_city":null,"lender_state":null,"lender_zipcode":null,"lender_phone":null,"desired_delivery_date":"2018-02-21","label":"Appraisal","items":[{"id":260,"customer_item_id":"a1P2F000000ZX9vUAG","address":"741 Venice Way Apt 7","unit":null,"city":"Inglewood","state":"CA","zipcode":"90302","property_type":"condo"}]}';

        Property_Due_Diligence_Reports__c tmpPDDR = new Property_Due_Diligence_Reports__c(Name = 'Property Test1', Order_Type__c = 'devFakeInspectAndEvaluate', Opportunity__c = o.id);
        insert tmpPDDR;
        ctrl.pddr = tmpPDDR;
        ctrl.createAndSubmitOrders();
        System.Test.stopTest();
    }

    @isTest
    private static void testCreateandSubmit2() {
        Test.setMock(HttpCalloutMock.class, new HCCalloutMockImpl());

        Account acc = new Account(Name = 'New Account');
        insert acc;
        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Opportunity o = new Opportunity();
        o.AccountId = acc.Id;
        o.Name = 'Test Opp';
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        //o.Converted_Close_Date__c = System.Today().addMonths(3);
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.Estimated_Funding_Amount__c = 1000;
        insert o;
        System.Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        CreateSubmitOrdersCtrl ctrl = new CreateSubmitOrdersCtrl(sc);


        Property_Due_Diligence_Reports__c tmpPDDR = new Property_Due_Diligence_Reports__c(Name = 'Property Test1', Order_Type__c = 'devFakeInspectAndEvaluate', Opportunity__c = o.id);
        insert tmpPDDR;
        ctrl.pddr = tmpPDDR;
        ctrl.createAndSubmitOrders();
        System.Test.stopTest();
    }
}