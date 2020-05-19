@isTest
private class LeadUtilityClassTest {
    private static String accessToken = 'accesstoken';
    private static String refreshToken = 'refreshtoken';
    private static String clientId = 'clientid';
    private static String clientSecret = 'clientsecret';
    private static String authCode = 'authcode';
    private static String entityId = 'entityid';
    private static String userId = 'userid';
    private static String enterpriseId = 'enterpriseid';
    private static String publicKeyId = 'publicKeyId';
    private static String privateKey = BoxTestJsonResponseFactory.AUTH_PRIVATE_KEY;
    private static String privateKeyPassword = 'privateKeyPassword';
    private static BoxJwtEncryptionPreferences.EncryptionAlgorithm algorithm = BoxJwtEncryptionPreferences.EncryptionAlgorithm.RSA_SHA_256;

    private static BoxJwtEncryptionPreferences constructEncryptionPrefs() {
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setEncryptionAlgorithm(algorithm);
        prefs.setPrivateKey(privateKey);
        prefs.setPrivateKeyPassword(privateKeyPassword);
        prefs.setPublicKeyId(publicKeyId);
        return prefs;
    }

    @testSetup static void dataCreatemethod() {
        test.startTest();
        Lead newLead = new Lead();
        newLead.OwnerId = UserInfo.getUserId();
        newLead.Income_Monthly_Base__c = 83333.33;
        newLead.Quality_Assurance_Specialist__c = UserInfo.getUserId();
        newLead.Payment_Monthly_First_Mortgage__c = 0.00;
        newLead.Payment_Monthly_Second_Mortgage__c = 0.00;
        newLead.Phone = '222-333-1515';

        newLead.Email = 'john.doe@myunison.com';
        newLead.Company = 'the William Lee Household';
        newLead.Probability__c = 41.50;
        newLead.Close_Date__c = system.today();
        newLead.RecordTypeId = '01244000000DHFN';
        newLead.Income_QC__c = 'Passed';
        newLead.Mortgage_QC_Status__c = 'Passed';
        newLead.Credit_Review__c = 'Passed';
        newLead.Ratios__c = 'Passed';
        newLead.Unison_Transaction_Fee__c = 3.90;
        newLead.FirstName = 'William';
        newLead.LastName = 'Lee';
        newLead.LASERCA__Home_Address__c = '534 Cardinal St';
        newLead.LASERCA__Home_City__c = 'Brea';
        newLead.LASERCA__Home_State__c = 'CA';
        newLead.LASERCA__Home_Zip__c = '92823';
        newLead.Applicant_Birth_Date_Free_Response__c = '06/30/1993';
        newLead.LASERCA__SSN__c = '222222222';
        newLead.Marital_Status__c = 'Single';
        newLead.Highest_Degree_Earned__c = 'Some College';
        newLead.Preferred_Phone__c = 'Home';
        newLead.Inbound_Response_Channel__c = 'Phone';
        newLead.Assets_Bank_Acct__c = 10000;
        newLead.Assets_Brokerage_Acct__c = 10000;
        newLead.Assets_Other_Real_Estate__c = 10000.00;
        newLead.Property_Street_Number_and_Name__c = '534 Cardinal St';
        newLead.Property_City__c = 'Brea';
        newLead.Property_State__c = 'CA';
        newLead.Property_Zip_Code__c = '92833';
        newLead.Occupancy_Statement_Dropdown__c = 'Principal Residence';
        newLead.Property_Type__c = 'Single-family detached';
        newLead.Title_Held__c = 'Individually';
        newLead.Credit_Pre_Qualification_Status__c = 'Approved';
        newLead.Applicant_Social_Security_Number__c = '222222222';
        newLead.Campaign_Audience__c = 'Consumer';
        newLead.Channel__c = 'Direct to Consumer';
        newLead.Campaign_Source__c = 'facebook';
        insert newLead;


        /*Lead newLead2 = new Lead();
        newLead2.OwnerId = UserInfo.getUserId();
        newLead2.Income_Monthly_Base__c = 83333.33;
        newLead2.Quality_Assurance_Specialist__c = UserInfo.getUserId();
        newLead2.Payment_Monthly_First_Mortgage__c = 0.00;
        newLead2.Payment_Monthly_Second_Mortgage__c = 0.00;
        newLead2.Phone = '111-555-1212';

        newLead2.Email = 'William.lee@myunison.com';
        newLead2.Company = 'the William Lee Household';
        newLead2.Status = 'Application Received';
        newLead2.Probability__c = 41.50;
        newLead2.Close_Date__c = system.today();
        newLead2.RecordTypeId = '01244000000DHFN';
        newLead2.Income_QC__c = 'Passed';
        newLead2.Mortgage_QC_Status__c = 'Passed';
        newLead2.Credit_Review__c = 'Passed';
        newLead2.Ratios__c = 'Passed';
        newLead2.Unison_Transaction_Fee__c = 3.90;
        newLead2.FirstName = 'William';
        newLead2.LastName = 'Lee';
        newLead2.LASERCA__Home_Address__c = '534 Cardinal St';
        newLead2.LASERCA__Home_City__c = 'Brea';
        newLead2.LASERCA__Home_State__c = 'CA';
        newLead2.LASERCA__Home_Zip__c = '92823';
        newLead2.Applicant_Birth_Date_Free_Response__c = '06/30/1993';
        newLead2.LASERCA__SSN__c = '222222222';
        newLead2.Marital_Status__c = 'Single';
        newLead2.Highest_Degree_Earned__c = 'Some College';
        newLead2.Preferred_Phone__c = 'Home';
        newLead2.Inbound_Response_Channel__c = 'Phone';
        newLead2.Assets_Bank_Acct__c = 10000;
        newLead2.Assets_Brokerage_Acct__c = 10000;
        newLead2.Assets_Other_Real_Estate__c = 10000.00;
        newLead2.Property_Street_Number_and_Name__c = '534 Cardinal St';
        newLead2.Property_City__c = 'Brea';
        newLead2.Property_State__c = 'CA';
        newLead2.Property_Zip_Code__c = '92833';
        newLead2.Occupancy_Statement_Dropdown__c = 'Principal Residence';
        newLead2.Property_Type__c = 'Single-family detached';
        newLead2.Title_Held__c = 'Individually';
        newLead2.Credit_Pre_Qualification_Status__c = 'Approved';
        newLead2.Applicant_Social_Security_Number__c = '333333333';
        newLead2.Campaign_Audience__c = 'Consumer';
        newLead2.Channel__c = 'Direct to Consumer';
        newLead2.Campaign_Source__c = 'facebook';
        insert newLead2;*/

        /*Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Lead__c = newLead2.Id;
        sf1.Success_Factor__c = 'Cash to Consumer';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        insert sf1;

        Current_Conditions__c req = new Current_Conditions__c();
        req.Requirement__c = 'Revised CAP';
        req.Success_Factor__c = sf1.Id;
        req.Lead__c = newLead2.id;
        req.code__c = 'R1035';
        Insert req;*/


        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = newLead.Id;
        pcr.Name = 'testpcr';
        pcr.Property_Address__c = 'Please populate Opportunity';
       // pcr.Opportunity__c = opp.id;

        insert pcr;

        /*LASERCA__Personal_Credit_Report__c pcr2 = new LASERCA__Personal_Credit_Report__c();
        pcr2.LASERCA__Lead__c = newLead2.Id;
        pcr2.Name = 'testpcr';
       // pcr2.Opportunity__c = opp.id;

        insert pcr2;*/

        Minimum_Required_Documents__c mrd = new Minimum_Required_Documents__c(Lead__c = newLead.id, Category__c = 'W2', Applicant_Type__c = 'Applicant');
        insert mrd;

        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Lead__c = newLead.Id;
        sf1.Success_Factor__c = 'Cash to Consumer';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';

        Success_Factor__c sf2 = new Success_Factor__c();
        sf2.Lead__c = newLead.Id;
        sf2.Success_Factor__c = 'OAV';
        sf2.Status__c = 'In Progress';
        sf2.Program__c = 'HO';
        insert new List<Success_Factor__c> { sf1, sf2 };

        Current_Conditions__c req = new Current_Conditions__c();
        req.Requirement__c = 'Credit Report';
        req.Success_Factor__c = sf1.Id;
        req.Lead__c = newLead.id;
        req.code__c = 'R1035';
        Insert req;

        /*Minimum_Required_Documents__c mrd2 = new Minimum_Required_Documents__c(Lead__c = newLead2.id, Category__c = 'W2', Applicant_Type__c = 'Applicant');
        insert mrd2;*/


        List<ContentVersion> contentVersionInsert = new List<ContentVersion>{
                new ContentVersion(Title = 'Test', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true),
                new ContentVersion(Title = 'Test1', PathOnClient = 'Test1.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true)
        };
        insert contentVersionInsert;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>{
                new ContentDocumentLink(LinkedEntityId = mrd.Id, ContentDocumentId = documents[0].Id, ShareType = 'V'),
                new ContentDocumentLink(LinkedEntityId = mrd.Id, ContentDocumentId = documents[1].Id, ShareType = 'V')/*,
                new ContentDocumentLink(LinkedEntityId = mrd2.Id, ContentDocumentId = documents[0].Id, ShareType = 'V'),
                new ContentDocumentLink(LinkedEntityId = mrd2.Id, ContentDocumentId = documents[1].Id, ShareType = 'V')*/

        };
        insert cdl;

        LeadQual_Authentication__c temp = new LeadQual_Authentication__c();
        temp.Eed_Point_URL__c = 'http:\\www.test.com';
        insert temp;
        test.stopTest();
    }
	
    //BUS-155110577 stop sending leads to LQ
    /*
    @isTest
    private static void test_LQCallout() {
        Lead newLead = [Select Id from Lead Limit 1];

        Test.setMock(HttpCalloutMock.class, new LQRequestMock());
        Test.startTest();
        LeadUtilityClass.LQ_CallWebService(newLead.Id);

        LeadUtilityClass.customButtonCall(newLead.Id);
        Test.stopTest();
    }
	*/

    @isTest
    private static void test_addingMRDfiles() {
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        Test.startTest();
        Lead newLead = [Select Id from Lead Limit 1];
        Minimum_Required_Documents__c mrd = [Select Id From Minimum_Required_Documents__c Limit 1];

        newLead.Quality_Control_Status__c = 'Passed';
        newLead.Credit_Review__c = 'Passed';
        newLead.Income_QC__c = 'Passed';
        newLead.Mortgage_QC_Status__c = 'Passed';
        newLead.Minimum_Required_Documents__c = 'Passed';
        newLead.Ratios__c = 'Passed';
        newLead.Count_of_MRDs__c = 4;

        update newLead;

        List<Attachment> leadattac = [select Id from Attachment where parentId = :newLead.Id];
        //system.assertEquals(leadattac.size(),2);
        Test.stopTest();
    }

    @isTest
    private static void test_CreditReport() {

        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        Test.startTest();
        Lead newLead = new Lead();
        newLead.OwnerId = UserInfo.getUserId();
        newLead.Income_Monthly_Base__c = 83333.33;
        newLead.Quality_Assurance_Specialist__c = UserInfo.getUserId();
        newLead.Payment_Monthly_First_Mortgage__c = 0.00;
        newLead.Payment_Monthly_Second_Mortgage__c = 0.00;
        newLead.Phone = '666-777-9999';

        newLead.Email = 'jane.doe@myunison.com';
        newLead.Company = 'the William Lee Household';
        newLead.Status = 'Documents In';
        newLead.Probability__c = 41.50;
        newLead.Close_Date__c = system.today();
        newLead.RecordTypeId = '01244000000DHFN';
        newLead.Income_QC__c = 'Passed';
        newLead.Mortgage_QC_Status__c = 'Passed';
        newLead.Credit_Review__c = 'Passed';
        newLead.Ratios__c = 'Passed';
        newLead.Unison_Transaction_Fee__c = 3.90;
        newLead.FirstName = 'William';
        newLead.LastName = 'Lee';
        newLead.LASERCA__Home_Address__c = '534 Cardinal St';
        newLead.LASERCA__Home_City__c = 'Brea';
        newLead.LASERCA__Home_State__c = 'CA';
        newLead.LASERCA__Home_Zip__c = '92823';
        newLead.Applicant_Birth_Date_Free_Response__c = '06/30/1993';
        newLead.LASERCA__SSN__c = '222222222';
        newLead.Marital_Status__c = 'Single';
        newLead.Highest_Degree_Earned__c = 'Some College';
        newLead.Preferred_Phone__c = 'Home';
        newLead.Inbound_Response_Channel__c = 'Phone';
        newLead.Assets_Bank_Acct__c = 10000;
        newLead.Assets_Brokerage_Acct__c = 10000;
        newLead.Assets_Other_Real_Estate__c = 10000.00;
        newLead.Property_Street_Number_and_Name__c = '534 Cardinal St';
        newLead.Property_City__c = 'Brea';
        newLead.Property_State__c = 'CA';
        newLead.Property_Zip_Code__c = '92833';
        newLead.Occupancy_Statement_Dropdown__c = 'Principal Residence';
        newLead.Property_Type__c = 'Single-family detached';
        newLead.Title_Held__c = 'Individually';
        newLead.Credit_Pre_Qualification_Status__c = 'Approved';
        newLead.Applicant_Social_Security_Number__c = '333333333';
        newLead.Campaign_Audience__c = 'Consumer';
        newLead.Channel__c = 'Direct to Consumer';
        newLead.Campaign_Source__c = 'facebook';

        insert newLead;

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = newLead.Id;
        pcr.Name = 'testpcr';
        pcr.Property_Address__c = 'Please populate Opportunity';
        insert pcr;

        newLead.Personal_Credit_Report__c = pcr.Id;
        newLead.Status = 'Documents In';
        //newlead.Quality_Control_Status__c   = 'Ready for QC Audit';
        newLead.Home_Value__c = 96539000;

        update newLead;

        Test.stopTest();
    }


    @isTest
    private static void test_Application() {
        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));


        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));


        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        Lead newLead = [Select Id from Lead Limit 1];

        LASERCA__Personal_Credit_Report__c tmpCR = new LASERCA__Personal_Credit_Report__c();
        tmpCR.Name = 'TestCR';
        tmpCR.LASERCA__Lead__c = newLead.id;
        tmpCR.LASERCA__Credit_Score_Equifax__c = '0';
        tmpCR.LASERCA__Credit_Score_Experian__c = '0';
        tmpCR.LASERCA__Credit_Score_TransUnion__c = '0';
        tmpCR.LASERCA__Co_Applicant_Credit_Score_Equifax__c = '0';
        tmpCR.LASERCA__Co_Applicant_Credit_Score_Experian__c = '0';
        tmpCR.LASERCA__Co_Applicant_Credit_Score_TransUnion__c = '0';
        insert tmpCR;

        List<ContentVersion> contentVersionInsert = new List<ContentVersion>{
                new ContentVersion(Title = 'Test', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true),
                new ContentVersion(Title = 'Completed_Application_Package_FRX', PathOnClient = 'Test1.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true)
        };
        insert contentVersionInsert;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title = 'Completed_Application_Package_FRX'];

        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>{
                new ContentDocumentLink(LinkedEntityId = newLead.Id, ContentDocumentId = documents[0].Id, ShareType = 'V'),
                new ContentDocumentLink(LinkedEntityId = tmpCR.Id, ContentDocumentId = documents[0].Id, ShareType = 'V')
        };
        insert cdl;
        test.starttest();
        //newLead.Quality_Control_Status__c = 'Ready for QC Audit';
        newLead.Home_Value__c = 96539000;
        newLead.Status = 'Documents In';

        update newLead;
        test.stoptest();
    }

    @isTest
    private static void test_createRequirements() {
        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));


        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));


        Test.setMock(HttpCalloutMock.class, new DelightedMock());

        List<Lead> leads = [Select Id, Status from Lead WHERE Applicant_Social_Security_Number__c = '222222222'];
        leads[0].Status = 'Application Received';

        test.starttest();
        try {
            LeadUtilityClass.createRequirements(leads, null);
        } catch (Exception e) {
        }

        test.stoptest();

    }

    public static testMethod void TestCreateCurrentConditions() {

        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
        
        // Data setup
        Lead le1 = new Lead();
        le1.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        le1.LastName = 'Test291953';
        le1.Company = 'Test336735';
        le1.Status = 'Pending Qualification';
        le1.Owns_Other_Real_Estate_Property__c = 'Yes';
        le1.Retired__c = true;
        insert le1;
        
        // Run the code
        Test.startTest();
        le1.Status = 'Application Received';
        update le1;
        Test.stopTest();
        
        // Verify Results
        System.assert([SELECT COUNT() FROM Current_Conditions__c WHERE Lead__c = :le1.Id] > 0, 'Current_Conditions__c records should have been created');
        
    }

    @isTest
	public static void Test_switchAppraisalReqs_1() {
        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));		
        
		// Data setup
        Lead le1 = new Lead();
        le1.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        le1.LastName = 'Test291953';
        le1.Company = 'Test336735';
        le1.Status = 'Pending Qualification';
        le1.New_HomeOwner_Purchase_Date__c = Date.today().addDays(-100);
        le1.NHO_Expected_Close_Date__c = Date.today().addDays(400);     
        //should set Qualifies_for_New_HomeOwner_Pricing__c = false;
        insert le1;
        
        
        // Run the code
        Test.startTest();

        le1.Status = 'Application Received';
        le1.NHO_Expected_Close_Date__c = Date.today().addDays(200);      
        // should set Qualifies_for_New_HomeOwner_Pricing__c = true;
        update le1;


        /*le1.Status = 'Documents In';
        le1.New_HomeOwner_Purchase_Date__c = Date.today().addDays(-300);      
        // should set Qualifies_for_New_HomeOwner_Pricing__c = false;
        update le1;*/
        
        LeadUtilityClass.getLeadRequirements();

        Test.stopTest();
        
        // Verify Results
        System.assertEquals('Document Received, In progress', [SELECT Status__c FROM Current_Conditions__c WHERE Lead__c = :le1.Id AND Code__c = 'R1125'].Status__c);        
    }

    @isTest
	public static void Test_switchAppraisalReqs_2() {
        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));		
        
		// Data setup
        Lead le1 = new Lead();
        le1.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        le1.LastName = 'Test291953';
        le1.Company = 'Test336735';
        le1.Status = 'Pending Qualification';
        le1.New_HomeOwner_Purchase_Date__c = Date.today().addDays(-100);
        le1.NHO_Expected_Close_Date__c = Date.today().addDays(400);     
        //should set Qualifies_for_New_HomeOwner_Pricing__c = false;
        insert le1;

        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Lead__c = le1.Id;
        sf1.Success_Factor__c = 'Cash to Consumer';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';

        Success_Factor__c sf2 = new Success_Factor__c();
        sf2.Lead__c = le1.Id;
        sf2.Success_Factor__c = 'OAV';
        sf2.Status__c = 'In Progress';
        sf2.Program__c = 'HO';
        insert new List<Success_Factor__c> { sf1, sf2 };
        
        Current_Conditions__c cc = new Current_Conditions__c();
        cc.Lead__c = le1.Id;
        cc.Code__c = 'R1125';
        cc.Status__c = 'Document Received, In progress';
        insert cc;
        
        // Run the code
        Test.startTest();

        le1.Status = 'Documents In';
        le1.NHO_Expected_Close_Date__c = Date.today().addDays(200);  
        le1.New_HomeOwner_Purchase_Date__c = Date.today().addDays(-300);      
        // should set Qualifies_for_New_HomeOwner_Pricing__c = false;
        update le1;
        
        LeadUtilityClass.getLeadRequirements();

        Test.stopTest();
        
        // Verify Results
        System.assertEquals('Waived', [SELECT Status__c FROM Current_Conditions__c WHERE Lead__c = :le1.Id AND Code__c = 'R1125'].Status__c);        
    }

    @isTest
	public static void Test_switchAppraisalReqs_3() {
        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));		
        
		// Data setup
        Lead le1 = new Lead();
        le1.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        le1.LastName = 'Test291953';
        le1.Company = 'Test336735';
        le1.Status = 'Pending Qualification';
        le1.New_HomeOwner_Purchase_Date__c = Date.today().addDays(-100);
        le1.NHO_Expected_Close_Date__c = Date.today().addDays(400);     
        //should set Qualifies_for_New_HomeOwner_Pricing__c = false;
        insert le1;

        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Lead__c = le1.Id;
        sf1.Success_Factor__c = 'Cash to Consumer';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';

        Success_Factor__c sf2 = new Success_Factor__c();
        sf2.Lead__c = le1.Id;
        sf2.Success_Factor__c = 'OAV';
        sf2.Status__c = 'In Progress';
        sf2.Program__c = 'HO';
        insert new List<Success_Factor__c> { sf1, sf2 };
        
        Current_Conditions__c cc = new Current_Conditions__c();
        cc.Lead__c = le1.Id;
        cc.Code__c = 'R1125';
        cc.Status__c = 'Waived';
        insert cc;
        
        // Run the code
        Test.startTest();

        le1.Status = 'Documents In';
        le1.NHO_Expected_Close_Date__c = Date.today().addDays(200);      
        // should set Qualifies_for_New_HomeOwner_Pricing__c = true;
        update le1;
        
        LeadUtilityClass.getLeadRequirements();

        Test.stopTest();
        
        // Verify Results
        System.assertEquals('Document Received, In progress', [SELECT Status__c FROM Current_Conditions__c WHERE Lead__c = :le1.Id AND Code__c = 'R1125'].Status__c);        
    }
    
}