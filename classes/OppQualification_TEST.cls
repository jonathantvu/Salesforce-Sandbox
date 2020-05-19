@isTest
public class OppQualification_TEST {

    @isTest
    private static void testYes() {

        // Data setup
        Exception_Fico_Guideline__c fico1 = new Exception_Fico_Guideline__c();
        fico1.Name = 'fico1';
        fico1.FICO__c = 0;
        fico1.LTV__c = 80;
        fico1.Status__c = 'Yes';
        fico1.Type__c = 'HO';
        insert fico1;
        
        Exception_Dti_Guideline__c dti1 = new Exception_Dti_Guideline__c();
        dti1.Name = 'dti1';
        dti1.DTI__c = 80;
        dti1.LTV__c = 80;
        dti1.Status__c = 'Yes';
        dti1.Type__c = 'HO';
        insert dti1;
        
        /*Opp_to_Case_Mapping__c map1 = new Opp_to_Case_Mapping__c();
        map1.Name = 'Map1';
        map1.Case_field_API_Name__c = 'OwnerId';
        map1.Opp_Field_API_Name__c = 'OwnerId';
        Opp_to_Case_Mapping__c map2 = new Opp_to_Case_Mapping__c();
        map2.Name = 'Map2';
        map2.Case_field_API_Name__c = 'Subject';
        map2.Default_Value__c = 'Test 232899';
        insert new List<Opp_to_Case_Mapping__c> { map1, map2 };*/
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;            
            
        Opportunity o = new Opportunity(); 
        o.AccountId = newAccount.Id;
        o.Name = 'Test Opp';
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        //o.Converted_Close_Date__c = System.Today().addMonths(3);        
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';  
     	o.IA_Passbook_Override_Reasons__c = 'High Liquid Reserves';
        o.IA_Passbook_Override__c = true;
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.Estimated_Funding_Amount__c = 1000;
        insert o;
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = o.Id;
        insert pcr;
        
        o.Personal_Credit_Report__c = pcr.Id;
        update o;
        
        // Run the code
        Test.startTest();
        OppQualification ctrl = new OppQualification(new ApexPages.StandardController(o));
        ctrl.MortgageType = 'Amortizing';
        ctrl.Calculate();
        ctrl.ContinueOpp();
     //  ctrl.RaiseException();
        ctrl.SaveCase();
        
        Test.stopTest();
        
        // Verify Results
        System.assertNotEquals(1, [SELECT COUNT() FROM Case]);
        //l = [SELECT Id, Guideline_Prequalification_Date_Time__c FROM Opportunity WHERE Id = :l.Id];
        //System.assert(l.Guideline_Prequalification_Date_Time__c != null);
    }
    
    @isTest
    private static void testOther() {

        // Data setup
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;            
            
        Opportunity o = new Opportunity(); 
        o.AccountId = newAccount.Id;
        o.Name = 'Test Opp';
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        //o.Converted_Close_Date__c = System.Today().addMonths(3);        
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';    
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.IA_Passbook_Override__c = true;
        o.IA_Passbook_Override_Reasons__c = 'High Liquid Reserves';
        o.Estimated_Funding_Amount__c = 1000;
        insert o;        
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = o.Id;
        insert pcr;
        
        o.Personal_Credit_Report__c = pcr.Id;
        update o;
        
        // Run the code
        Test.startTest();
        OppQualification ctrl = new OppQualification(new ApexPages.StandardController(o));
        ctrl.ResultT1 = 'Yes';
        ctrl.ResultT2 = 'No';
        ctrl.ContinueOpp();
        ctrl.ResultT1 = 'No';
        ctrl.ResultT2 = 'Yes';
        ctrl.ContinueOpp();
        ctrl.ResultT1 = 'Exception';
        ctrl.ResultT2 = 'No';
        ctrl.ContinueOpp();
        ctrl.ResultT1 = 'No';
        ctrl.ResultT2 = 'Exception';
        ctrl.ContinueOpp();
        ctrl.ResultT1 = 'No';
        ctrl.ResultT2 = 'No';


        ctrl.ContinueOpp();
        ctrl.ResultT1 = 'Yes';
        ctrl.ResultT2 = 'Yes';
        ctrl.ContinueOpp();
        ctrl.SaveCase();
        
        Test.stopTest();
    }

    @isTest
    private static void testPassbookCalculation() {

        // Data setup
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity o = new Opportunity();
        o.AccountId = newAccount.Id;
        o.Name = 'Test Opp';
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.IA_Passbook_Override__c = true;
        o.IA_Passbook_Override_Reasons__c = 'High Liquid Reserves';
        o.Estimated_Funding_Amount__c = 1000;
        insert o;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = o.Id;
        insert pcr;

        o.Personal_Credit_Report__c = pcr.Id;
        update o;

        PassbookRestHelper.passbookResponse resp = new PassbookRestHelper.passbookResponse();
        resp.id = 'd1bf1580-344c-11e8-a212-f56282bb4517R';
        resp.response = 'Approve';
        resp.comments = 'None';
        resp.exception_reason = 'Resource not found';
        resp.loss_reason = '';
        resp.grid_one_result = 'Yes';
        resp.grid_two_result = '';


        // Run the code
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PassbookRestMockImpl());
        OppQualification ctrl = new OppQualification(new ApexPages.StandardController(o));
        ctrl.ResultT1 = 'Yes';
        ctrl.ResultT2 = 'No';
        ctrl.passbookResponse = resp;
        ctrl.IA_Passbook_Override_Reasons = 'Reason';
        ctrl.passbookCalculate();
        ctrl.passbookContinueOpp();

        Test.stopTest();
    }
    @isTest
    private static void testPassbookCalculation_Decline() {

        // Data setup
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity o = new Opportunity();
        o.AccountId = newAccount.Id;
        o.Name = 'Test Opp';
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.IA_Passbook_Override__c = true;
        o.IA_Passbook_Override_Reasons__c = 'High Liquid Reserves';
        o.Estimated_Funding_Amount__c = 1000;
        insert o;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = o.Id;
        insert pcr;

        o.Personal_Credit_Report__c = pcr.Id;
        update o;

        PassbookRestHelper.passbookResponse resp = new PassbookRestHelper.passbookResponse();
        resp.id = 'd1bf1580-344c-11e8-a212-f56282bb4517R';
        resp.response = 'Decline';
        resp.comments = 'None';
        resp.exception_reason = 'Resource not found';
        resp.loss_reason = '';
        resp.grid_one_result = 'Yes';
        resp.grid_two_result = '';


        // Run the code
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PassbookRestMockImpl());
        OppQualification ctrl = new OppQualification(new ApexPages.StandardController(o));
        ctrl.ResultT1 = 'No';
        ctrl.passbookResponse = resp;
        ctrl.passbookResult = null;
        ctrl.ResultT2 = 'No';
        ctrl.IA_Passbook_Override_Reasons = 'Reason';
        ctrl.passbookContinueOpp();

        Test.stopTest();
    }
    @isTest
    private static void testPassbookCalculation_Exception() {

        // Data setup
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity o = new Opportunity();
        o.AccountId = newAccount.Id;
        o.Name = 'Test Opp';
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.IA_Passbook_Override__c = true;
        o.IA_Passbook_Override_Reasons__c = 'High Liquid Reserves';
        o.Estimated_Funding_Amount__c = 1000;
        insert o;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = o.Id;
        insert pcr;

        o.Personal_Credit_Report__c = pcr.Id;
        update o;

        PassbookRestHelper.passbookResponse resp = new PassbookRestHelper.passbookResponse();
        resp.id = 'd1bf1580-344c-11e8-a212-f56282bb4517R';
        resp.response = 'Exception';
        resp.comments = 'None';
        resp.exception_reason = 'Resource not found';
        resp.loss_reason = '';
        resp.grid_one_result = '';
        resp.grid_two_result = '';



        // Run the code
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PassbookRestMockImpl());
        OppQualification ctrl = new OppQualification(new ApexPages.StandardController(o));
        ctrl.passbookResult = 'Exception';
        ctrl.ResultT1 = 'Exception';
        ctrl.ResultT2 = 'Exception';
        ctrl.passbookResponse = resp;
        ctrl.IA_Passbook_Override_Reasons = 'Reason';
        ctrl.passbookContinueOpp();
        ctrl.ContinueOpp();

        Test.stopTest();
    }

    @isTest
    private static void testPassbookCalculation_null() {

        // Data setup
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity o = new Opportunity();
        o.AccountId = newAccount.Id;
        o.Name = 'Test Opp';
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.IA_Passbook_Override__c = true;
        o.IA_Passbook_Override_Reasons__c = 'High Liquid Reserves';
        o.Estimated_Funding_Amount__c = 1000;
        insert o;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = o.Id;
        insert pcr;

        o.Personal_Credit_Report__c = pcr.Id;
        update o;

        PassbookRestHelper.passbookResponse resp = new PassbookRestHelper.passbookResponse();
        resp.id = 'd1bf1580-344c-11e8-a212-f56282bb4517R';
        resp.response = null;
        resp.comments = 'None';
        resp.exception_reason = 'Resource not found';
        resp.loss_reason = '';
        resp.grid_one_result = '';
        resp.grid_two_result = '';

        // Run the code
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PassbookRestMockImpl());
        OppQualification ctrl = new OppQualification(new ApexPages.StandardController(o));
        ctrl.passbookResult = 'Exception';
        ctrl.ResultT1 = 'Exception';
        ctrl.ResultT2 = 'Exception';
        ctrl.passbookResponse = resp;
        ctrl.IA_Passbook_Override_Reasons = 'Reason';
        ctrl.passbookContinueOpp();

        Test.stopTest();
    }

    @isTest
    private static void testPassbookCalculation_QualifBase() {

        // Data setup
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity o = new Opportunity();
        o.AccountId = newAccount.Id;
        o.Name = 'Test Opp';
        o.CloseDate = System.Today().addMonths(3);
        o.StageName = 'Submit to Ops';
        o.Qualifies_for_New_HomeOwner_Pricing__c = false;
        o.IA_Passbook_Override__c = true;
        o.IA_Passbook_Override_Reasons__c = 'High Liquid Reserves';
        o.Estimated_Funding_Amount__c = 1000;
        insert o;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Opportunity__c = o.Id;
        insert pcr;

        o.Personal_Credit_Report__c = pcr.Id;
        update o;

        PassbookRestHelper.passbookResponse resp = new PassbookRestHelper.passbookResponse();
        resp.id = 'd1bf1580-344c-11e8-a212-f56282bb4517R';
        resp.response = null;
        resp.comments = 'None';
        resp.exception_reason = 'Resource not found';
        resp.loss_reason = '';
        resp.grid_one_result = '';
        resp.grid_two_result = '';

        // Run the code
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PassbookRestMockImpl());
        OppQualification ctrl = new OppQualification(new ApexPages.StandardController(o));
        Metadata.Layout mylay = new Metadata.Layout();
        Metadata.LayoutSection layoutSection = new  Metadata.LayoutSection();
        QualificationBase.LayoutWrapper myLayout = new QualificationBase.LayoutWrapper(mylay);
        List<Metadata.LayoutSection> metadataLayouts = new List<Metadata.LayoutSection>();
        metadataLayouts.add(layoutSection);
        myLayout.layout.layoutSections = metadataLayouts;
        QualificationBase.SectionWrapper mySection = new QualificationBase.SectionWrapper(layoutSection);
        ctrl.caseLayout = myLayout;
        ctrl.passbookResult = 'Exception';
        ctrl.ResultT1 = 'Exception';
        ctrl.ResultT2 = 'Exception';
        ctrl.passbookResponse = resp;
        ctrl.IA_Passbook_Override_Reasons = 'Reason';
        ctrl.passbookContinueOpp();
        ctrl.Calculate();
        system.debug(ctrl.MetadataUiBehaviorRequired);

        for(SelectOption so : ctrl.MortgageTypes) {
            system.debug(so);
        }

        Test.stopTest();
    }

    
}