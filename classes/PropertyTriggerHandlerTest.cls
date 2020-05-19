/**
 * Created by Ivan Garcia on 5/23/2019.
 */

@IsTest public with sharing class PropertyTriggerHandlerTest {
    @testSetup static void setup(){
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
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = '2-4 Family',Probability = 90,
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,Lien_First_Lender_Balance__c = 100);
        insert oppty;

        Success_Factor__c sf     = new Success_Factor__c();
        sf.Opportunity__c     = oppty.Id;
        sf.Success_Factor__c  = 'Property Ownership';
        sf.Status__c  = 'In Progress';
        sf.Program__c = 'HO';
        insert sf;
    }

    @isTest private static void testName() {
        Opportunity tmpOpp = [SELECT id FROM Opportunity LIMIT 1];

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
        newprop.Opportunity__c=tmpOpp.Id;
        insert newprop;

        newprop.Name = 'Test0';
        newprop.Property_Street_Number_and_Name__c = 'asd asd 123';
        newprop.Property_Number_of_Units__c = 3;
        update newprop;
    }
}