/**
 * Created by Eliot Rojas on 5/23/2019.
 */

@IsTest
private class BoxAttachmentRetrievalQueueableTest {
    @testSetup static void setup() {
        Test.setMock(HttpCalloutMock.class, new UnisonRequirementUpsertHttpCalloutMock());
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Name = 'Test PCR';
        pcr.LASERCA__Co_Applicant_Credit_Score_Equifax__c = '670';
        pcr.LASERCA__Co_Applicant_Credit_Score_Experian__c = '670';
        pcr.LASERCA__Co_Applicant_Credit_Score_TransUnion__c = '670';
        insert pcr;

        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        insert trdacc;

        Lead objLead = new Lead();
        objLead.LastName = 'John 436343';
        objLead.Company = 'Test 450990';
        objLead.Qualifies_for_New_HomeOwner_Pricing__c = false;
        objLead.Estimated_Funding_Amount__c = 1000;
        objLead.Status = 'Application Received';
        objLead.Box_Folder_Id__c = '70476889338';
        objLead.Adults_Occupying_Property_Dropdown__c = 'Yes';
        objLead.Applicant_Bankrupcy_Dropdown__c = 'Yes';
        objLead.Income_Monthly_Base__c = 100;
        objLead.Application_Deed_of_Foreclosure_Dropdown__c = 'Yes';
        objLead.Applicant_Felony_Dropdown__c = 'Yes';
        objLead.Applicant_Foreclosure_Dropdown__c = 'Yes';
        objLead.Co_Applicant_Bankruptcy_Dropdown__c = 'Yes';
        objLead.Co_Applicant_Deed_of_Foreclosure__c = 'Yes';
        objLead.Co_Applicant_Felony__c = 'Yes';
        objLead.Co_Applicant_Foreclosure_Dropdown__c = 'Yes';
        objLead.Is_there_Co_App__c = true;
        insert objLead;

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
        newOpportunity.Estimated_Funding_Amount__c = 10;
        newOpportunity.Pricing_Ratio__c = 10;
        newOpportunity.Final_OAV_Calculation__c = 10;
        newOpportunity.IA_OAV_Override__c = 10;
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.SEND_TO_ENCOMPASS__c = true;
        insert newOpportunity;

        Recorded_Information__c recordedInfo = new Recorded_Information__c();
        recordedInfo.Opportunity2__c = newOpportunity.Id;
        recordedInfo.Applicant1_Name__c = 'John';
        insert recordedInfo;

        Success_Factor__c SF = new Success_Factor__c();
        SF.Opportunity__c = newOpportunity.Id;
        SF.Success_Factor__c = 'LTV';
        SF.Program__c = 'HO';
        insert SF;

        Success_Factor__c SF2 = new Success_Factor__c();
        SF2.Opportunity__c = newOpportunity.Id;
        SF2.Success_Factor__c = 'DTI';
        SF2.Program__c = 'HO';
        insert SF2;

        Current_Conditions__c req = new Current_Conditions__c();
        req.Opportunity__c = newOpportunity.Id;
        req.Lead__c = objLead.Id;
        req.Requirement__c = 'Urgent Property Fix';
        req.Code__c = 'R1046';
        req.Category__c = 'Mortgage';
        req.Internal_vs_External__c = 'Internal';
        req.Success_Factor__c = SF.Id;
        insert req;

        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Opportunity__c = newOpportunity.Id;
        req2.Lead__c = objLead.Id;
        req2.Requirement__c = 'Urgent Property Fix';
        req2.Code__c = 'R1046';
        req2.Category__c = 'Mortgage';
        req2.Internal_vs_External__c = 'Internal';
        req2.Success_Factor__c = SF2.Id;
        insert req2;

        Document_MetaData__c dmd = new Document_MetaData__c(
                Opportunity__c = newOpportunity.Id,
                Lead__c = objLead.Id,
                Requirement__c = req.Id,
                Box_File_Id__c = '5000948880'
        );
        insert dmd;

        Document_MetaData__c dmd2 = new Document_MetaData__c(
                Opportunity__c = newOpportunity.Id,
                Lead__c = objLead.Id,
                Requirement__c = req2.Id,
                Box_File_Id__c = '5000948880'
        );
        insert dmd2;
    }

    @IsTest
    static void testBehavior() {


        Lead mylead = [SELECT Id, Name, Company, Quality_Control_Status__c FROM Lead WHERE Company = 'Test 450990' LIMIT 1];
        mylead.Quality_Control_Status__c = 'Passed';
        /*
        BoxJwtEncryptionPreferences.EncryptionAlgorithm algorithm = BoxJwtEncryptionPreferences.EncryptionAlgorithm.RSA_SHA_256;
        String privateKey = BoxTestJsonResponseFactory.AUTH_PRIVATE_KEY;
        String privateKeyPassword = 'privateKeyPassword';
        String publicKeyId = 'publicKeyId';

        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setEncryptionAlgorithm(algorithm);
        prefs.setPrivateKey(privateKey);
        prefs.setPrivateKeyPassword(privateKeyPassword);
        prefs.setPublicKeyId(publicKeyId);
*/
        /*
        BoxPlatform.PlatformEntityType entityType = BoxPlatform.PlatformEntityType.USER;
        BoxJwtEncryptionPreferences encryptionPref = prefs;
        //String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
       // Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));
       */
        String boxFileId = '123456';

        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String folderResponse = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(folderResponse, 'Created', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 200)));

        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));




        Test.startTest();
        //update mylead;
        Map<Id, Lead> leadsEncompass = new Map<Id, Lead>();
        leadsEncompass.put(mylead.Id, mylead);
        if(!leadsEncompass.isEmpty()) {
            try {
                System.enqueueJob(new BoxAttachmentRetrievalQueueable(leadsEncompass));
            }
            catch(exception e){}
        }

        Test.stopTest();
    }
}