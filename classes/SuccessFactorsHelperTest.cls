/************************************************************************************
 Apex Class Name     : SuccessFactorsHelperTest
 Version             : 1.0
 Created Date        : 19th September 2019
 Function            : APEX test class for SuccessFactorsHelper
 Author              : Jason Sun
 
 Modification Log    :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Jason Sun           	09/19/2019                Original Version
*************************************************************************************
*/
@isTest
public class SuccessFactorsHelperTest {

    public static testMethod void test_generateLeadSuccessFactors(){
		Lead ld1 = new Lead();
        ld1.recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ld1.FirstName = 'First';
        ld1.LastName = 'Last';
        ld1.Company = 'First Last Household';
        ld1.OwnerId = UserInfo.getUserId();
        ld1.Status = 'New';
        ld1.Street = 'Test Street';
        ld1.City = 'Test City';
        ld1.State = 'Test State';
        ld1.Country = 'United States';
        ld1.PostalCode = 'TX1234';
        ld1.Co_Applicant_Address__c = 'Street';
        ld1.Co_Applicant_BirthDate__c = System.Today();
        ld1.Co_Applicant_City__c = 'City';
        ld1.Co_Applicant_Email__c  = 'coapplicant@test.com';
        ld1.Co_Applicant_First_Name__c  = 'CoApplicantFirst';
        ld1.Co_Applicant_Last_Name__c  = 'CoApplicantLast';
        ld1.Co_Applicant_Postal_Code__c = '12345';
        ld1.Co_Applicant_State__c = 'State';
        ld1.Bankrupcy_in_last_seven_years_co__c = true;
        ld1.Estimated_Total_Monthly_Income_co__c = 12345;
        ld1.Felonies_co__c = true;
        ld1.Given_deed_for_foreclosure_in_7_years_co__c = true;
        ld1.Marital_Status_co__c = 'Single';
        ld1.Previous_Foreclosure_co__c = true;
        ld1.Agency_or_Non_Agency__c = 'Agency';
        ld1.Street = 'Test Street';
        ld1.City = 'Test City';
        ld1.State = 'CA';
        ld1.PostalCode = 'TestCode';     
        insert ld1;
        
        //Process Builder that invokes SuccessFactorsHelper fires on Lead Create
        //confirm that successFactors were created        
        List<Success_Factor__c> sfList = [SELECT Id FROM Success_Factor__c WHERE Lead__c = :ld1.Id];
        system.assertNotEquals(0, sfList.size());
        
    }
    
    public static testMethod void test_CloseLostLead_SuccessFactors(){
		Lead ld1 = new Lead();
        ld1.recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ld1.FirstName = 'First';
        ld1.LastName = 'Last';
        ld1.Company = 'First Last Household';
        ld1.OwnerId = UserInfo.getUserId();
        ld1.Status = 'Closed Lost';
        ld1.Street = 'Test Street';
        ld1.City = 'Test City';
        ld1.State = 'Test State';
        ld1.Country = 'United States';
        ld1.PostalCode = 'TX1234';
        ld1.Co_Applicant_Address__c = 'Street';
        ld1.Co_Applicant_BirthDate__c = System.Today();
        ld1.Co_Applicant_City__c = 'City';
        ld1.Co_Applicant_Email__c  = 'coapplicant@test.com';
        ld1.Co_Applicant_First_Name__c  = 'CoApplicantFirst';
        ld1.Co_Applicant_Last_Name__c  = 'CoApplicantLast';
        ld1.Co_Applicant_Postal_Code__c = '12345';
        ld1.Co_Applicant_State__c = 'State';
        ld1.Bankrupcy_in_last_seven_years_co__c = true;
        ld1.Estimated_Total_Monthly_Income_co__c = 12345;
        ld1.Felonies_co__c = true;
        ld1.Given_deed_for_foreclosure_in_7_years_co__c = true;
        ld1.Marital_Status_co__c = 'Single';
        ld1.Previous_Foreclosure_co__c = true;
        ld1.Agency_or_Non_Agency__c = 'Agency';
        ld1.Street = 'Test Street';
        ld1.City = 'Test City';
        ld1.State = 'CA';
        ld1.PostalCode = 'TestCode';     
        insert ld1;
        
        //delete all success Factors
        List<Success_Factor__c> sfList = [SELECT Id FROM Success_Factor__c WHERE Lead__c = :ld1.Id];
		delete sfList;
        
        //return lead from Closed Lost
        ld1.Status = 'Discovery';
        update ld1;             
        
        //confirm that successFactors were created        
        sfList = [SELECT Id FROM Success_Factor__c WHERE Lead__c = :ld1.Id];
        system.assertNotEquals(0, sfList.size());        
    }    
    
}