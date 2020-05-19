/**********************************************************
 * Class        : ExceptionGuidlineCtrl_TEST.cls
 * Created Date : January 11, 2018
 * Modified by  : -
 * Modified Date: -
 * Objective    : This class provide test methods for ExceptionGuidlineCtrl.cls
 *
 *
 **********************************************************/ 

@isTest 
private class ExceptionGuidlineCtrl_TEST {

    @isTest
    private static void testName() {

        // Data setup
        Exception_Fico_Guideline__c fico1 = new Exception_Fico_Guideline__c();
        fico1.Name = 'fico1';
        fico1.FICO__c = 800;
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
        
        // Run the code
        Test.startTest();
        ExceptionGuidlineCtrl ctrl = new ExceptionGuidlineCtrl();
        Map<integer, string> allFicoValuesMap = ctrl.allFicoValuesMap;
        Map<integer, string> allLtvValuesMap = ctrl.allLtvValuesMap;
        Map<integer, string> allDtiValuesMap = ctrl.allDtiValuesMap;
        ctrl.SaveEverything();
        Test.stopTest();
        
        // Verify Results
        System.assertEquals(1008, [SELECT COUNT() FROM Exception_Fico_Guideline__c]);
        System.assertEquals(1596, [SELECT COUNT() FROM Exception_Dti_Guideline__c]);
        System.assertEquals(12, allFicoValuesMap.size());
        System.assertEquals(21, allLtvValuesMap.size());
        System.assertEquals(19, allDtiValuesMap.size());
        
    }
}