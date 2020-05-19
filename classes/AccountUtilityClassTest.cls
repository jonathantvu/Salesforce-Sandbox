/**
 * Created by Ivan Garcia on 5/6/2019.
 */

@IsTest public with sharing class AccountUtilityClassTest {

    public class MockClass implements HttpCalloutMock {

        private Id oppId;

        public MockClass(Id oppId) {
            this.oppId = oppId;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().contains('token')) {
                res.setBody('{"access_token":"test"}');
            } else {
                if (oppId != null) {
                    res.setBody('{"success":true,"opportunities":{"' + oppId + '":"0061700000LSODhAAP"},"error_message":null}');
                } else {
                    res.setBody('{"success":false,"error_message":"Test error message"}');
                    res.setStatusCode(500);
                }
            }
            return res;
        }
    }

    @IsTest private static void mainTest() {
        
        // Data Setup
        Account acc = new Account();
        acc.Name = 'Test123452';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test435733';
        opp.AccountId = acc.Id;
        opp.StageName = 'Introduction';
        opp.CloseDate = System.today();
        opp.Property_Street_Number_and_Name__c = '10';
        opp.Application_DateTime__c = system.today();
        opp.Property_City__c = 'catest';
        opp.Post_Close_LTV2__c = 1;
        opp.Encompass_Loan_Number__c = '1';
        opp.Wire_to_Agent_Date__c = system.today();
        opp.Approval_Status__c = 'Pending';
        opp.IM_Approved_Date__c = system.today();
        opp.Qualifies_for_New_HomeOwner_Pricing__c = true;
        opp.Final_Title_Held__c = 'test';
        opp.Property_State__c = 'test';
        opp.Property_Zip_Code__c = '12345';
        insert opp;
        
        Success_Factor__c sf = new Success_Factor__c();
        sf.Opportunity__c = opp.Id;
        sf.Success_Factor__c = 'Property Ownership';
        sf.Status__c ='In Progress';
        sf.Program__c = 'HO';
        insert sf;

        Application__c tmpApp = new Application__c();
        tmpApp.Name = 'tmpApp';
        tmpApp.Opportunity__c = opp.id;
        tmpApp.Birthdate__c = system.today();
        tmpApp.Declaration_Intent_of_Proceeds__c = '1';
        tmpApp.Applicant_Address__c = '1';
        tmpApp.Applicant_City__c = '1';
        tmpApp.Applicant_Middle_Name__c = '1';
        tmpApp.Applicant_Postal_Code__c = '12345';
        tmpApp.Applicant_Social_Security_Number__c = '123456789';
        tmpApp.Applicant_State__c = 'ca';
        tmpApp.Co_Applicant_Address__c = '10';
        tmpApp.Co_Applicant_City__c = 'test';
        tmpApp.Co_Applicant_Middle_Name__c = 'test';
        tmpApp.Co_Applicant_Postal_Code__c = '12345';
        tmpApp.Co_Applicant_Social_Security_Number__c = '1234567890';
        tmpApp.Co_Applicant_State__c = 'ca';
        tmpApp.Declaration_Adult_Name_and_Relationship__c = 'test';
        tmpApp.Declaration_Bankruptcy__c = 'Yes';
        tmpApp.Declaration_Bankruptcy_Co__c = 'Yes';
        tmpApp.Declaration_Deed_in_Lieu__c = 'Yes';
        tmpApp.Declaration_Deed_in_Lieu_Co__c = 'Yes';
        tmpApp.Declaration_Explanation__c = 'yes';
        tmpApp.Declaration_Felony_Co__c = 'yes';
        tmpApp.Declaration_Felony__c = 'no';
        tmpApp.Declaration_Foreclosure__c = 'no';
        tmpApp.Declaration_Foreclosure_Co__c = 'no';
        tmpApp.Declaration_Outstanding_Judgments__c = 'no';
        tmpApp.Declaration_Outstanding_Judgments_Co__c = 'no';
        tmpApp.Declaration_Permanent_Resident__c = 'no';
        tmpApp.Declaration_Permanent_Resident_Co__c = 'no';
        tmpApp.Declaration_Power_of_Attorney__c = 'no';
        tmpApp.Declaration_Power_of_Attorney_Co__c = 'no';
        tmpApp.Declaration_US_Citizen__c ='yes';
        tmpApp.Declaration_US_Citizen_Co__c = 'yes';
        tmpApp.Email__c = 'test@email.com';
        tmpApp.Email_Co__c = 'test@email.com';
        tmpApp.Employer_Name__c = 'test';
        tmpApp.Employer_Name_Co__c = 'test';
        tmpApp.Employer_Address__c = 'test';
        tmpApp.Employer_Address_Co__c = 'test';
        tmpApp.First_Name__c = 'test';
        tmpApp.First_Name_Co__c = 'test';
        tmpApp.Gender__c = 'male';
        tmpApp.Gender_Co__c = 'male';
        tmpApp.Highest_Degree_Earned__c = 'test';
        tmpApp.Highest_Degree_Earned_Co__c = 'test';
        tmpApp.How_did_you_hear_about_FirstREX__c = 'test';
        tmpApp.Income_Monthly_Base__c = 1;
        tmpApp.Income_Monthly_Base_Co__c = 1;
        tmpApp.Income_Monthly_Commissions__c = 1;
        tmpApp.Income_Monthly_Commissions_Co__c = 1;
        tmpApp.Income_Monthly_Div_Interest__c = 1;
        tmpApp.Income_Monthly_Div_Interest_Co__c = 1;
        tmpApp.Income_Monthly_Other__c = 1;
        tmpApp.Income_Monthly_Other_Co__c = 1;
        tmpApp.Income_Monthly_Overtime__c = 1;
        tmpApp.Income_Monthly_Overtime_Co__c = 1;
        tmpApp.Industry__c = 'Other';
        tmpApp.Industry_Co__c = 'Other';
        tmpApp.Last_Name__c = 'test';
        tmpApp.Last_Name_Co__c = 'test';
        tmpApp.Marital_Status__c = 'single';
        tmpApp.Marital_Status_Co__c = 'single';
        tmpApp.MobilePhone__c = '1234567890';
        tmpApp.MobilePhone_Co__c = '3216549870';
        tmpApp.Months_in_Current_Job__c = 1;
        tmpApp.Months_in_Current_Job_Co__c = 1;
        tmpApp.Persons_on_Title_Dropdown__c = '2';
        tmpApp.Phone__c = '1234567890';
        tmpApp.Phone_Co__c = '3216549870';
        tmpApp.Preferred_Phone__c = '1234567890';
        tmpApp.Preferred_Phone_Co__c = '1234567890';
        tmpApp.Profession__c = 'test';
        tmpApp.Profession_Co__c = 'test';
        tmpApp.Property_Number_of_Years__c = 1;
        tmpApp.Property_Years_Planning_to_Stay__c = '1';
        tmpApp.School__c = 'test';
        tmpApp.School_Co__c = 'test';
        tmpApp.Title__c = 'test';
        tmpApp.Title_Co__c = 'test';
        tmpApp.Work_Phone__c = '1234567890';
        tmpApp.Work_Phone_Co__c = '1234567890';
        tmpApp.Years_In_This_Profession_Co__c = 1;
        tmpApp.Years_of_School__c = 1;
        tmpApp.Years_of_School_Co__c = 1;
        tmpApp.Years_on_This_Job_Co__c = 1;
        insert tmpApp;

        LASERCA__Personal_Credit_Report__c tmpCR = new LASERCA__Personal_Credit_Report__c();
        tmpCR.Name = 'TestCR';
        tmpCR.Opportunity__c = opp.id;
        tmpCR.LASERCA__Credit_Score_Equifax__c = '0';
        tmpCR.LASERCA__Credit_Score_Experian__c = '0';
        tmpCR.LASERCA__Credit_Score_TransUnion__c = '0';
        tmpCR.LASERCA__Co_Applicant_Credit_Score_Equifax__c = '0';
        tmpCR.LASERCA__Co_Applicant_Credit_Score_Experian__c = '0';
        tmpCR.LASERCA__Co_Applicant_Credit_Score_TransUnion__c = '0';
        insert tmpCR;

        Property__c tmpPcr = new Property__c();
        tmpPcr.Name='tmpPcr';
        tmpPcr.Opportunity__c = opp.id;
        tmpPcr.Property_Rooms_Baths__c = 0;
        tmpPcr.Property_Rooms_Beds__c = 0;
        tmpPcr.Property_Building_Sqft__c = 0;
        tmpPcr.Property_Condition__c = 'C1';
        tmpPcr.Property_Condo_PUD_Name__c = '0';
        tmpPcr.Property_Flood_Zone__c = 'A';
        tmpPcr.Greenlight_Id__c = '0';
        tmpPcr.Property_Legal_Description__c = '0';
        tmpPcr.Property_Lot_Sqft__c = 0;
        tmpPcr.Property_Parcel_Number__c = '0';
        tmpPcr.Property_Type__c = 'Condominium';
        tmpPcr.Property_Rooms_Total__c = 0;
        tmpPcr.Property_Number_of_Units__c = 0;
        tmpPcr.Property_CBSA_Name__c = '0';
        insert tmpPcr;

        Recorded_Information__c tmpRI = new Recorded_Information__c();
        tmpRI.Fund_Name__c='Odin US Residential Real Estate Fund I LP';
        tmpRI.Opportunity2__c = opp.id;
        tmpRI.Fund_Number__c = 0;
        tmpRI.Dot_or_Mortgage__c = 'Mortgage';
        tmpRI.DOT_or_Mortgage_Instrument_No__c = '0';
        tmpRI.Effective_Date__c = system.today();
        tmpRI.Memorandum_of_Agreement_Instrument_No__c = '0';
        tmpRI.Option_Agreement_Expiration__c = system.today();
        tmpRI.Servicing_Org_AKA__c = '0';
        tmpRI.Vesting_Name__c = '0';
        tmpRI.Vesting_Organization_Final_Description2__c = '0';
        tmpRI.Vesting_Organization_State__c = '0';
        tmpRI.Vesting_Organization_Tax_ID__c = '0';
        tmpRI.Vesting_Organization_Type__c = '0';
        tmpRI.Unison_Program_Legal__c = '0';
        tmpRI.Unison_Program_Name__c = '0';
        insert tmpRI;

        Document_MetaData__c tmpDmd = new Document_MetaData__c();
        tmpDmd.Opportunity__c = opp.id;
        insert tmpDmd;

        DMA__c tmpDma = new DMA__c();
        tmpDma.Inspection_Date__c = system.today();
        tmpDma.Opportunity__c = opp.id;
        insert tmpDma;

        LASERCA__Trade_Accounts__c tmpTA = new LASERCA__Trade_Accounts__c();
        tmpTA.Opportunity__c = opp.id;
        tmpTA.Name = 'TestTA';
        tmpTA.LASERCA__Personal_Credit_Report__c = tmpCR.id;
        tmpTA.Credit_Loan_Type_pick__c = 'Mortgage';
        tmpTA.LASERCA__Account_Status_Type__c = 'Open';
        insert tmpTA;

        Note nt = new Note();
        nt.ParentId = opp.Id;
        nt.Title = 'Test 1';
        nt.Body = 'Test Body 1';
        insert nt;

        ContentNote cnt = new ContentNote();
        cnt.Title = 'Test 2';
        cnt.Content = Blob.valueOf('Test Body 2');
        insert cnt;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cnt.Id;
        cdl.LinkedEntityId = opp.Id;
        cdl.ShareType = 'V';
        insert cdl;

        Test.setMock(HttpCalloutMock.class, new MockClass(opp.Id));

        // Run the code
        Test.startTest();
        AccountUtilityClass.createAccount(new Set<Id> { acc.Id });
        DataIntegrationClass.getUsersSuffix();
        Test.stopTest();

        // Verify results
        opp = [SELECT SFDC2_Opportunity_Id__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('0061700000LSODhAAP', opp.SFDC2_Opportunity_Id__c);

        SFDC_to_SFDC_Log__c log = [SELECT Response_Code__c FROM SFDC_to_SFDC_Log__c LIMIT 1];
        System.assertEquals(200, log.Response_Code__c);
    }

}