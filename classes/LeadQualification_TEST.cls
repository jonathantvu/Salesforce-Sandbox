@isTest
public class LeadQualification_TEST {

    @isTest
    private static void testYes() {

        // Data setup
        Exception_Fico_Guideline__c fico1 = new Exception_Fico_Guideline__c();
        fico1.Name = 'fico1';
        fico1.FICO__c = 720;
        fico1.LTV__c = 0.60;
        fico1.Status__c = 'Yes';
        fico1.Type__c = 'HO';
        insert fico1;
        Exception_Dti_Guideline__c dti1 = new Exception_Dti_Guideline__c();
        dti1.Name = 'dti1';
        dti1.DTI__c = 0.30;
        dti1.LTV__c = 0.60;
        dti1.Status__c = 'Yes';
        dti1.Type__c = 'HO';
        insert dti1;
        
        Lead_to_Case_Mapping__c map1 = new Lead_to_Case_Mapping__c();
        map1.Name = 'Map1';
        map1.Case_field_API_Name__c = 'OwnerId';
        map1.Lead_Field_API_Name__c = 'OwnerId';
        Lead_to_Case_Mapping__c map2 = new Lead_to_Case_Mapping__c();
        map2.Name = 'Map2';
        map2.Case_field_API_Name__c = 'Subject';
        map2.Default_Value__c = 'Test 232899';
        insert new List<Lead_to_Case_Mapping__c> { map1, map2 };
        
        Lead l = new Lead();
        l.LastName = 'John Class';
        l.Company = 'Class Company';
        l.Qualifies_for_New_HomeOwner_Pricing__c = false;
        l.Estimated_Funding_Amount__c = 1000;
        l.status = 'Credit Qualified';
        l.Income_Monthly_Base__c = 5000;
        l.Home_Value__c = 500000;
        insert l;
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = l.Id;
        insert pcr;
        
        l.Personal_Credit_Report__c = pcr.Id;
        update l;
        
        // Run the code
        Test.startTest();
        LeadQualification ctrl = new LeadQualification(new ApexPages.StandardController(l));
        ctrl.MortgageType = 'Amortizing';
        //ctrl.Calculate();
        //ctrl.ContinueLead();
        ctrl.RaiseException();
        ctrl.SaveCase();
        //ctrl.passbookContinueLead();
        ctrl.passbookCalculate();
        Test.stopTest();
        
    }
    
    /*@isTest
    private static void testOther() {

        // Data setup
        Lead l = new Lead();
        l.LastName = 'Test 436343';
        l.Company = 'Test 450990';
        l.Qualifies_for_New_HomeOwner_Pricing__c = false;
        l.Estimated_Funding_Amount__c = 1000;
        insert l;
        
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = l.Id;
        insert pcr;
        
        l.Personal_Credit_Report__c = pcr.Id;
        update l;
        
        // Run the code
        Test.startTest();
        LeadQualification ctrl = new LeadQualification(new ApexPages.StandardController(l));
        ctrl.ResultT1 = 'Yes';
        ctrl.ResultT2 = 'No';
        //ctrl.ContinueLead();
        ctrl.ResultT1 = 'No';
        ctrl.ResultT2 = 'Yes';
        //ctrl.ContinueLead();
        ctrl.ResultT1 = 'Exception';
        ctrl.ResultT2 = 'No';
        //ctrl.ContinueLead();
        ctrl.ResultT1 = 'No';
        ctrl.ResultT2 = 'Exception';
        //ctrl.ContinueLead();
        ctrl.ResultT1 = 'No';
        ctrl.ResultT2 = 'No';
        //ctrl.ContinueLead();
        ctrl.SaveCase();
        
        Test.stopTest();
    }*/
    
}