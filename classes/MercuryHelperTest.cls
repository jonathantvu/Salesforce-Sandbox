/**
 * Created by Ivan Garcia on 5/22/2019.
 */

@IsTest public with sharing class MercuryHelperTest {
    @testSetup static void setup(){
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',Phone = '1234567891',
                AccountID = acc.Id);
        insert con2;

        /* 4/2/2019 Sundar Subramaniam - Is_there_Co_App__c removed from query for Data Model Cleanup */
        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = '2-4 Family',
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,Lien_First_Lender_Balance__c = 100,Property_Street_Number_and_Name__c='1256 Fisher St',Property_City__c='SanFrancisco',Property_State__c='CA',Property_Zip_Code__c='95687',Property_County__c='San SanFrancisco');
        insert oppty;
    }

    @isTest private static void test0(){
        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());
        Opportunity tmpOpp = [SELECT id,Property_Type__c,Encompass_Loan_Number__c,Applicant__r.Name,Applicant__r.Mercury_Phone__c,Applicant__r.Email,Co_Applicant__r.Name,Final_OAV_Calculation__c,Lien_First_Lender_Balance__c, Owner.Name,Property_Street_Number_and_Name__c,Property_State__c,Property_County__c,Property_Zip_Code__c FROM Opportunity LIMIT 1];

        Test.startTest();
        try{
            MercuryHelper.GetAMCCompanies();
        }catch(Exception e){}

        try{
            MercuryHelper.GetTypesOfAppraisal();
        }catch(Exception e){}

        try{
            String xml = '<root xmlns="http://alamode.com/"><to>Tove</to><bResult>true</bResult><TrackingID>Reminder</TrackingID><body><bResult>true</bResult><TrackingID>Reminder</TrackingID></body></root>';
            MercuryAPICustom.PlaceAppraisalOrderEx(xml);
        }catch(Exception e){}
        try{
            MercuryAPICustom.GetTypesOfAppraisal();
        }catch(Exception e){}



        try{
            MercuryHelper.GetCurrentStatus('132456789');
        }catch(Exception e){}

        try{
            MercuryHelper.GenerateXMLPost(tmpOpp,'test product', System.Today(),'TestAmc');
        }catch(Exception e){}

        tmpOpp.Property_Type__c = 'Condominium';
        update tmpOpp;
        try{
            MercuryHelper.GenerateXMLPost(tmpOpp,'test product', System.Today(),'TestAmc');
        }catch(Exception e){}

        tmpOpp.Property_Type__c = 'PUD';
        update tmpOpp;
        try{
            MercuryHelper.GenerateXMLPost(tmpOpp,'test product', System.Today(),'TestAmc');
        }catch(Exception e){}

        tmpOpp.Property_Type__c = 'Other';
        update tmpOpp;
        try{
            MercuryHelper.GenerateXMLPost(tmpOpp,'test product', System.Today(),'TestAmc');
        }catch(Exception e){}

        tmpOpp.Property_Type__c = 'Single-family detached';
        update tmpOpp;
        try{
            MercuryHelper.GenerateXMLPost(tmpOpp,'test product', System.Today(),'TestAmc');
        }catch(Exception e){}

        tmpOpp.Property_Type__c = 'Townhouse';
        update tmpOpp;
        try{
            MercuryHelper.GenerateXMLPost(tmpOpp,'test product', System.Today(),'TestAmc');
        }catch(Exception e){}


        Test.stopTest();
    }

    @isTest static void GenerateOrderAppraisalTest(){
        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());
        Opportunity tmpOpp = [SELECT id,Property_Type__c,Encompass_Loan_Number__c,Property_City__c,Property_State__c,Property_County__c,Property_Zip_Code__c,Applicant__r.Name,Co_Applicant__r.Name,Final_OAV_Calculation__c,Lien_First_Lender_Balance__c, Owner.Name,Property_Street_Number_and_Name__c FROM Opportunity LIMIT 1];

        Test.startTest();
        try{
        MercuryHelper.GenerateOrderAppraisal(tmpOpp,'test product', System.Today(),'TestAmc');
        }catch(Exception e){}
        Test.stopTest();


    }
}