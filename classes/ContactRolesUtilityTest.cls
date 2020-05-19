/**
 * Created by Carolina Veliz on 7/16/2019.
 */
@istest(seeAllData=true)
        //need to see data, because the contact are already created in the ORG
        //The contact will be created on the Production ORG
public with sharing class ContactRolesUtilityTest {

    @istest
    private static void test1() {
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());

        Account acc          = new Account();
        acc.Name             = 'test acc';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.AccountId    = acc.Id;
        opp.Name         = 'test opp';
        opp.StageName    = 'Investment Due Diligence';
        opp.CloseDate    = System.today();
        opp.Estimated_Funding_Amount__c = 2;
        opp.Pricing_Ratio__c = 2;
        opp.Final_OAV_Calculation__c = 4;
        opp.Property_State__c = 'CO';
        opp.Property_County__c = 'Yuma';
        insert opp;
        ContactRolesUtility.createEscrowOfficerForSpruce(opp);
        ContactRolesUtility.createEscrowOfficerForVantage(opp);

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);
        ContactRolesUtility.createContactRoles(opps);

        opp.Property_State__c = 'CO';
        opp.Property_County__c = 'YumaTest';
        update opp;
        ContactRolesUtility.createContactRoles(opps);

        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Opportunity__c = opp.Id;
        sf1.Success_Factor__c = 'Cash to Consumer';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        insert sf1;

        Current_Conditions__c req = new Current_Conditions__c();
        req.Requirement__c = 'Revised CAP';
        req.Success_Factor__c = sf1.Id;
        req.Opportunity__c = opp.id;
        req.code__c = 'R1035';
        Insert req;


        Lead objLead = new Lead();
        objLead.LastName = 'Test 436343';
        objLead.FirstName = 'Test 432569';
        objLead.Company = 'Test 450990';
        objLead.Qualifies_for_New_HomeOwner_Pricing__c = false;
        objLead.Estimated_Funding_Amount__c = 1000;
        objLead.Status = 'Application Received';
        objLead.Box_Folder_Id__c = '70476889338';
        objLead.Adults_Occupying_Property_Dropdown__c = 'Yes';
        objLead.Applicant_Bankrupcy_Dropdown__c = 'Yes';
        objLead.Application_Deed_of_Foreclosure_Dropdown__c = 'Yes';
        objLead.Applicant_Felony_Dropdown__c = 'Yes';
        objLead.Applicant_Foreclosure_Dropdown__c = 'Yes';
        objLead.Co_Applicant_Bankruptcy_Dropdown__c = 'Yes';
        objLead.Co_Applicant_Deed_of_Foreclosure__c = 'Yes';
        objLead.Co_Applicant_Felony__c = 'Yes';
        objLead.Co_Applicant_Foreclosure_Dropdown__c = 'Yes';
        objLead.Is_there_Co_App__c = true;
        objLead.IsConverted = true;
        objLead.Campaign_Source__c = 'facebook';
        objLead.ConvertedOpportunityId = opp.id;
        objLead.ConvertedAccountId = acc.id;
        objLead.property_county__c = 'San Diego';
        objLead.Loss_Reason_Type__c = 'Other';
        objLead.Other_Loss_Reason__c = 'Other';
        objLead.Income_Monthly_Base__c = 100;
        objLead.Applicant_Social_Security_Number__c = '000000000';
        objLead.Marital_Status__c = 'Single';
        objLead.Applicant_Birth_Date_Free_Response__c = '01/01/1975';
        objLead.co_Applicant_Social_Security_Number__c = '000000000';
        objLead.Marital_Status_co__c = 'Single';
        objLead.Co_Applicant_Birth_Date_Free_Response__c = '01/01/1975';
        objLead.Property_State__c = 'VA';

        objLead.Delighted_Survey_Sent__c = true;
        objLead.Marketing_Opt_Out__c = true;
        Contact thecontact = new contact( firstName = 'Test', lastName = 'Test');
        objLead.Loan_Officer__c = thecontact.id;
        LeadTriggerHandlerPC.createdRequirements= true;
        test.startTest();
        insert objLead;
        test.stopTest();

        ContactRolesUtility.createContactRoles(objLead);

    }

}