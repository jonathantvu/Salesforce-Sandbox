/**
 * Created by Eliot Rojas on 5/23/2019.
 */

@IsTest
private class MRDRequirementsCreationHandlerTest {
    @testSetup
    static void setup() {
        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.Name = 'Test PCR';
        pcr.LASERCA__Co_Applicant_Credit_Score_Equifax__c = '670';
        pcr.LASERCA__Co_Applicant_Credit_Score_Experian__c = '670';
        pcr.LASERCA__Co_Applicant_Credit_Score_TransUnion__c = '670';
        insert pcr;

        List<LASERCA__Trade_Accounts__c> trdacclist = new List<LASERCA__Trade_Accounts__c>();

        LASERCA__Trade_Accounts__c trdacc = new LASERCA__Trade_Accounts__c();
        trdacc.Name = 'testacc';
        trdacc.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc.LASERCA__Monthly_Payment__c = 10000;
        trdacc.LASERCA__Account_Balance__c = 5000;
        trdacc.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacclist.add(trdacc);


        LASERCA__Trade_Accounts__c trdacc1 = new LASERCA__Trade_Accounts__c();
        trdacc1.Name = 'testacc1';
        trdacc1.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc1.LASERCA__Monthly_Payment__c = 10000;
        trdacc1.LASERCA__Account_Balance__c = 5000;
        trdacc1.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc1.To_Be_Paid_Off__c = FALSE;
        trdacc1.Lien_Position__c  = null;
        trdacclist.add(trdacc1);

        LASERCA__Trade_Accounts__c trdacc2 = new LASERCA__Trade_Accounts__c();
        trdacc2.Name = 'testacc2';
        trdacc2.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc2.To_Be_Paid_Off__c = FALSE;
        trdacc2.Lien_Position__c  = '2';
        trdacc2.Amount_To_Pay_Off2__c = 5000;
        trdacc2.LASERCA__Monthly_Payment__c = 10000;
        trdacc2.LASERCA__Account_Balance__c = 5000;
        trdacc2.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacclist.add(trdacc2);



        LASERCA__Trade_Accounts__c trdacc3 = new LASERCA__Trade_Accounts__c();
        trdacc3.Name = 'testacc3';
        trdacc3.Credit_Loan_Type_pick__c = 'Other Lien';
        trdacc3.LASERCA__Monthly_Payment__c = 10000;
        trdacc3.LASERCA__Account_Balance__c = 5000;
        trdacc3.Amount_To_Pay_Off2__c = 5000;
        trdacc3.Lien_Position__c  = '2';
        trdacc3.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacclist.add(trdacc3);


        LASERCA__Trade_Accounts__c trdacc4 = new LASERCA__Trade_Accounts__c();
        trdacc4.Name = 'testacc2';
        trdacc4.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc4.To_Be_Paid_Off__c = TRUE;
        trdacc4.Lien_Position__c  = '2';
        trdacc4.Amount_To_Pay_Off2__c = 5000;
        trdacc4.LASERCA__Monthly_Payment__c = 10000;
        trdacc4.LASERCA__Account_Balance__c = 5000;
        trdacc4.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc4.Target_Pct_Value_Of_Home__c = 10;
        trdacclist.add(trdacc4);

        LASERCA__Trade_Accounts__c trdacc5 = new LASERCA__Trade_Accounts__c();
        trdacc5.Name = 'testacc2';
        trdacc5.Credit_Loan_Type_pick__c = 'Mortgage';
        trdacc5.To_Be_Paid_Off__c = FALSE;
        trdacc5.Lien_Position__c  = '2';
        trdacc5.Amount_To_Pay_Off2__c = 5000;
        trdacc5.LASERCA__Monthly_Payment__c = 10000;
        trdacc5.LASERCA__Account_Balance__c = 5000;
        trdacc5.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacclist.add(trdacc5);

        LASERCA__Trade_Accounts__c trdacc6 = new LASERCA__Trade_Accounts__c();
        trdacc6.Name = 'testacc2';
        trdacc6.Credit_Loan_Type_pick__c = 'CreditCard';
        trdacc6.To_Be_Paid_Off__c = FALSE;
        trdacc6.LASERCA__Monthly_Payment__c = 10000;
        trdacc6.LASERCA__Account_Balance__c = 5000;
        trdacc6.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacclist.add(trdacc6);

        LASERCA__Trade_Accounts__c trdacc7 = new LASERCA__Trade_Accounts__c();
        trdacc7.Name = 'testacc3';
        trdacc7.Credit_Loan_Type_pick__c = 'Other Lien';
        trdacc7.LASERCA__Monthly_Payment__c = 10000;
        trdacc7.LASERCA__Account_Balance__c = 5000;
        trdacc7.LASERCA__Personal_Credit_Report__c = pcr.Id;
        trdacc7.To_Be_Paid_Off__c = true;
        trdacc7.Target_Pct_Value_Of_Home__c = 10;
        trdacclist.add(trdacc7);


        insert trdacclist;

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

        Lead objLead = new Lead();
        objLead.LastName = 'Test 436343';
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
        objLead.Income_Monthly_Base__c  = 6000;
        objLead.Home_Value__c =100000;
        insert objLead;

        List<Success_Factor__c>  sflist = new List<Success_Factor__c>();
        Success_Factor__c sf3     = new Success_Factor__c();
        sf3.Lead__c    = objLead.Id;
        sf3.Success_Factor__c  = 'LTV';

        sflist.add(sf3);

        Success_Factor__c sf4 = new Success_Factor__c();
        sf4.Lead__c    = objLead.Id;
        sf4.Success_Factor__c  = 'DTI';
        sflist.add(sf4);

        Success_Factor__c sf5 = new Success_Factor__c();
        sf5.Lead__c    = objLead.Id;
        sf5.Success_Factor__c  = 'Credit';
        sflist.add(sf5);

        if(sflist.size() > 0) {
            insert sflist;
        }

        Minimum_Required_Documents__c objMRD = new Minimum_Required_Documents__c();
        objMRD.Category__c = 'W2';
        objMRD.Applicant_Type__c = 'Applicant';
        objMRD.Lead__c = objLead.Id;
        Insert objMRD;

        Minimum_Required_Documents__c objMRD2 = new Minimum_Required_Documents__c();
        objMRD2.Category__c = 'W2';
        objMRD2.Applicant_Type__c = 'Co-Applicant';
        objMRD2.Lead__c = objLead.Id;
        Insert objMRD2;

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.Title = 'test.txt';
        cv.PathOnClient = 'test.txt';
        cv.VersionData = blob.valueOf('Test data');
        insert cv;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDoc;
        cdl.LinkedEntityId = objMRD.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        ContentVersion cv2 = new ContentVersion();
        cv2.ContentLocation = 'S';
        cv2.Title = 'test.txt';
        cv2.PathOnClient = 'test.txt';
        cv2.VersionData = blob.valueOf('Test data');
        insert cv2;

        Id conDoc2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = conDoc;
        cdl2.LinkedEntityId = objMRD2.Id;
        cdl2.ShareType = 'V';
        cdl2.Visibility = 'AllUsers';
        insert cdl2;
    }

    @IsTest
    static void testBehavior() {
        Lead mylead = [SELECT Id, Name, Convert_MRDs__c FROM Lead WHERE Company = 'Test 450990' LIMIT 1];
        mylead.Convert_MRDs__c = true;
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String folderResponseBody = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String boxFileId = '123456';
        String fileResponseBody = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponseBody, 'OK', 201)));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));


        Test.startTest();
        update mylead;
        Test.stopTest();
    }
}