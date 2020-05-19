@isTest
private class LeadConversionProcessTest{
    private static final string CONVERTED_LEAD_STATUS = 'Submitted';
    private static final Schema.DescribeSObjectResult acctDesc = Schema.SObjectType.Account;
    private static final Map<string, Schema.RecordTypeInfo> acctRTMap = acctDesc.getRecordTypeInfosByName();
    private static final Schema.DescribeSObjectResult contDesc = Schema.SObjectType.Contact;
    private static final Map<string, Schema.RecordTypeInfo> contRTMap = contDesc.getRecordTypeInfosByName();
    private static final User salesDirectorUser = [SELECT Id FROM User WHERE IsActive=TRUE LIMIT 1];

    @testSetup
    private static void createMethod(){

        insert new List<Digital_Campaign_Sources__c>{
                new Digital_Campaign_Sources__c(Name='facebook',Campaign_Audience__c='Consumer',Campaign_Media_Type__c='Digital',Outbound_Marketing_Channel__c='Social'),
                new Digital_Campaign_Sources__c(Name='theSource',Campaign_Audience__c='Consumer',Campaign_Media_Type__c='Digital',Outbound_Marketing_Channel__c='Social')
        };

        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Lead');
        Schema.DescribeSobjectResult objTypeDesc = objType.getDescribe();
        map<Id, Schema.RecordTypeInfo> recTypeMap = objTypeDesc.getRecordTypeInfosById();
        system.debug('**recTypeMap**'+recTypeMap);
        Map<string,Id> mapretypes = new Map<string,Id>();
        for(Schema.RecordTypeInfo s : recTypeMap.values()){
            mapretypes.put(s.getDeveloperName(),s.getrecordtypeId());
        }

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Contact newContact = new Contact();
        newContact.AccountId = newAccount.Id;
        newContact.OwnerId = UserInfo.getUserId();
        newContact.FirstName = 'First';
        newContact.LastName = 'Last';
        newContact.Email = 'test@test.com';
        newContact.MailingStreet = 'Test Street';
        newContact.MailingCity = 'Test City';
        newContact.MailingState = 'Test State';
        newContact.MailingPostalCode = 'TestCode';
        newContact.Personalized_Referral_Code__c = 'test referral code';
        insert newContact;

        List<Lead> ldlist = new List<Lead>();
        Lead ld1 = new Lead();
        ld1.recordtypeid = mapretypes.get('HomeBuyer');
        //remaining fields mapping
        ld1.FirstName = 'First';
        ld1.LastName = 'Last';
        ld1.FormID__c = 'testID';
        //ld1.Referring_Contact__c = newContact.Id;               
        //ld1.Email = 'test@test.com';
        //ld1.Phone = '1234567890'; 
        ld1.Company = 'Test Company';
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
        ld1.Income_Monthly_Base__c = 100;
        ldlist.add(ld1);

        Lead ld2 = new Lead();
        ld2.recordtypeid = mapretypes.get('HomeOwner');
        //remaining fields mapping
        ld2.FirstName = 'First1';
        ld2.LastName = 'Last1';
        //ld2.Referring_Contact__c = newContact.Id;
        ld2.OwnerId = UserInfo.getUserId();
        //ld2.Email = 'test@test.com';
        //ld2.Phone = '1234567890';
        ld2.Company = 'Test Company1';
        ld2.Status = 'New';
        ld2.Street = 'Test Street1';
        ld2.City = 'Test City1';
        ld2.State = 'Test State1';
        ld2.Country = 'United States1';
        ld2.PostalCode = 'TX1234';
        ld2.Co_Applicant_Address__c = 'Street1';
        ld2.Co_Applicant_BirthDate__c = System.Today();
        ld2.Co_Applicant_City__c = 'City';
        ld2.Co_Applicant_Email__c  = 'coapplicant@test.com';

        ld2.Co_Applicant_First_Name__c  = 'CoApplicantFirst1';
        ld2.Co_Applicant_Last_Name__c  = 'CoApplicantLast1';

        ld2.Co_Applicant_Postal_Code__c = '12345';
        ld2.Co_Applicant_State__c = 'State';
        ld2.Bankrupcy_in_last_seven_years_co__c = true;
        ld2.Estimated_Total_Monthly_Income_co__c = 12345;
        ld2.Felonies_co__c = true;
        ld2.Given_deed_for_foreclosure_in_7_years_co__c = true;
        ld2.Marital_Status_co__c = 'Single';
        ld2.Previous_Foreclosure_co__c = true;
        ld2.Agency_or_Non_Agency__c = 'Agency';
        ld2.Street = 'Test Street';
        ld2.City = 'Test City';
        ld2.State = 'CA';
        ld2.PostalCode = 'TestCode';
        ld2.Income_Monthly_Base__c = 100;
        ldlist.add(ld2);

        insert ldlist;
        system.debug('**********'+ldlist[0].isconverted);
        system.debug('**********'+ldlist[1].isconverted);

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = ld1.Id;
        insert pcr;

    }

    @isTest
    private static void testleadconversion(){
        //String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        //Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());

        
        Lead newLead = [select Id, OwnerId, Property_County__c from Lead limit 1];
        
        newLead.Property_County__c = 'San Diego';

        newLead.Applicant_Social_Security_Number__c = '000000000';
        newLead.Marital_Status__c = 'Single';
        newLead.Applicant_Birth_Date_Free_Response__c = '01/01/1975';
        newLead.co_Applicant_Social_Security_Number__c = '000000000';
        newLead.Marital_Status_co__c = 'Single';
        newLead.Co_Applicant_Birth_Date_Free_Response__c = '01/01/1975';


        Update newLead;

        Success_Factor__c sf3 = new Success_Factor__c();
        sf3.Lead__c = newLead.Id;
        sf3.Success_Factor__c = 'Credit';
        insert sf3;

        Current_Conditions__c req1 = new Current_Conditions__c();
        req1.Lead__c = newLead.Id;
        req1.Requirement__c = 'Credit Supplement';
        req1.Code__c = 'R1022';
        req1.Category__c = 'Mortgage';
        req1.Internal_vs_External__c = 'Internal';
        req1.Success_Factor__c = sf3.Id;
        insert req1;

        Project_Task__c task = new Project_Task__c();
        task.Name = 'Request Power of Attorney documents';
        task.Requirement__c = req1.Id;
        task.Document_Upload_Needed__c = true;
        Insert task;

        test.starttest();

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setOwnerId(newLead.OwnerId);
        lc.setLeadId(newLead.Id);
        lc.setConvertedStatus('Submitted');

        Database.convertLead(lc);
        System.assertEquals(100, [SELECT Fund_Number__c FROM Recorded_Information__c LIMIT 1].Fund_Number__c);

        task = [SELECT Opportunity__c FROM Project_Task__c WHERE Id = :task.Id];
        System.assert(task.Opportunity__c != null);
        
        test.stoptest();
    }

    @istest
    private static void insertLeadLoanOfficer(){

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Contact newContact = new Contact();
        newContact.AccountId = newAccount.Id;
        newContact.FirstName = 'First';
        newContact.LastName = 'Last';
        newContact.Email = 'testLoanOfficer@test.com';
        newContact.MailingStreet = 'Test Street';
        newContact.MailingCity = 'Test City';
        newContact.MailingState = 'Test State';
        newContact.MailingPostalCode = 'TestCode';
        newContact.Personalized_Referral_Code__c = 'test referral code';
        insert newContact;

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.Country = 'United States';
        newLead.PostalCode = 'TX1234';
        newLead.Co_Applicant_BirthDate__c = System.Today();
        newLead.Co_Applicant_City__c = 'City';
        newLead.Co_Applicant_Email__c  = 'coapplicant@test.com';
        newLead.Co_Applicant_First_Name__c  = 'CoApplicantFirst';
        newLead.Co_Applicant_Last_Name__c  = 'CoApplicantLast';
        newLead.Co_Applicant_Postal_Code__c = '12345';
        newLead.Co_Applicant_State__c = 'State';
        newLead.Bankrupcy_in_last_seven_years_co__c = true;
        newLead.Estimated_Total_Monthly_Income_co__c = 12345;
        newLead.Felonies_co__c = true;
        newLead.FormId__c = 'testLoanOfficer@test.com';
        newLead.Given_deed_for_foreclosure_in_7_years_co__c = true;
        newLead.Marital_Status_co__c = 'Single';
        newLead.Previous_Foreclosure_co__c = true;
        newLead.Income_Monthly_Base__c = 100;



        Test.startTest();

        insert newLead;

        Test.stopTest();

        System.assertNotEquals(0, [Select Id FROM Lead WHERE Id = :newLead.Id AND IsConverted = FALSE].size());
        System.assertEquals(0, [Select Id FROM Opportunity].size());
        System.assertEquals(0, [Select Id FROM OpportunityContactRole].size());
    }

    @istest
    private static void insertLeadLoanOfficer2(){

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Contact newContact = new Contact();
        newContact.AccountId = newAccount.Id;
        newContact.FirstName = 'First';
        newContact.LastName = 'Last';
        newContact.Email = 'testLoanOfficer@test.com';
        newContact.MailingStreet = 'Test Street';
        newContact.MailingCity = 'Test City';
        newContact.MailingState = 'Test State';
        newContact.MailingPostalCode = 'TestCode';
        newContact.Personalized_Referral_Code__c = 'test referral code';
        insert newContact;

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.Country = 'United States';
        newLead.PostalCode = 'TX1234';
        newLead.Co_Applicant_BirthDate__c = System.Today();
        newLead.Co_Applicant_City__c = 'City';
        newLead.Co_Applicant_Email__c  = 'coapplicant@test.com';
        newLead.Co_Applicant_First_Name__c  = 'CoApplicantFirst';
        newLead.Co_Applicant_Last_Name__c  = 'CoApplicantLast';
        newLead.Co_Applicant_Postal_Code__c = '12345';
        newLead.Co_Applicant_State__c = 'State';
        newLead.Bankrupcy_in_last_seven_years_co__c = true;
        newLead.Estimated_Total_Monthly_Income_co__c = 12345;
        newLead.Felonies_co__c = true;
        newLead.FormId__c = 'testLoanOfficer@test.com';
        newLead.Given_deed_for_foreclosure_in_7_years_co__c = true;
        newLead.Marital_Status_co__c = 'Single';
        newLead.Previous_Foreclosure_co__c = true;
        newLead.Income_Monthly_Base__c = 100;


        Test.startTest();

        insert newLead;



        Test.stopTest();

        System.assertNotEquals(0, [Select Id FROM Lead WHERE Id = :newLead.Id AND IsConverted = FALSE].size());
        System.assertEquals(0, [Select Id FROM Opportunity].size());
        System.assertEquals(0, [Select Id FROM OpportunityContactRole].size());
    }

    @isTest
    private static void testCreateRequirements()
    {
        Requirement__mdt mrMDT = new Requirement__mdt();
        mrMDT.Requirement_Type__c = 'Home Inspection';
        mrMDT.Code__c= 'R1046';
        mrMDT.Category__c ='Home Condition';
        mrMDT.Type__c = 'Data Request';
        mrMDT.Applicant_Type__c = 'Applicant';
        LeadConversionProcess.createRequirements(mrMDT);
    }

    @istest
    private static void testCampaignCodeAttribution(){

        Campaign_Code_Attribution__c setting = new Campaign_Code_Attribution__c(Name ='OfferCode', Campaign_Medium__c = 'theMedium', Campaign_Source__c = 'theSource', Campaign_Name__c = 'theName', Campaign_Term__c = 'theTerm', Branding_Type__c ='Open Market', Campaign_Media_Type__c ='Digital', Lead_Source__c = 'Website', Outbound_Marketing_Channel__c = 'Social');
        insert setting;

        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Contact newContact = new Contact();
        newContact.AccountId = newAccount.Id;
        newContact.FirstName = 'First';
        newContact.LastName = 'Last';
        newContact.Email = 'testLoanOfficer@test.com';
        newContact.MailingStreet = 'Test Street';
        newContact.MailingCity = 'Test City';
        newContact.MailingState = 'Test State';
        newContact.MailingPostalCode = 'TestCode';
        //newcontact.Regional_Manager__c = UserInfo.getUserId();
        insert newContact;

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Campaign_Content__c = 'OfferCode';
        newLead.Manually_Generated_Lead__c = 'Yes';
        newLead.Income_Monthly_Base__c = 100;

        insert newLead;

        Lead createdLead = [SELECT Campaign_Content__c,Campaign_Medium__c,Campaign_Name__c,Campaign_Source__c,Campaign_Term__c,Branding_Type__c, Campaign_Media_Type__c, LeadSource, Outbound_Marketing_Channel__c FROM Lead WHERE Id = :newLead.Id];

        system.assertEquals('theMedium', createdLead.Campaign_Medium__c);
        system.assertEquals('theName', createdLead.Campaign_Name__c);
        system.assertEquals('theSource', createdLead.Campaign_Source__c);
        system.assertEquals('theTerm', createdLead.Campaign_Term__c);
        system.assertEquals('Open Market', createdLead.Branding_Type__c);
        system.assertEquals('Digital', createdLead.Campaign_Media_Type__c);
        system.assertEquals('Website', createdLead.LeadSource);
        system.assertEquals('Social', createdLead.Outbound_Marketing_Channel__c);

        //Test update case where referring contact gets populated
        newLead.Referring_Contact__c = newContact.Id;
        update newLead;

        Lead updatedLead = [SELECT Referring_Account__c,LeadSource,Sales_Director_User__c FROM Lead WHERE Id = :newLead.Id];

        system.assertEquals(newContact.accountId,updatedLead.Referring_Account__c);
        //system.assertEquals(newContact.Regional_Manager__c,updatedLead.Sales_Director_User__c);  

    }

    @isTest
    private static void testautocreatedlead(){
        Campaign_Code_Attribution__c setting = new Campaign_Code_Attribution__c(Name ='OfferCode', Campaign_Medium__c = 'theMedium', Campaign_Source__c = 'theSource', Campaign_Name__c = 'theName', Campaign_Term__c = 'theTerm', Branding_Type__c ='Open Market', Campaign_Media_Type__c ='Digital', Lead_Source__c = 'Website', Outbound_Marketing_Channel__c = 'Social');
        insert setting;

        Account acc = new Account();
        acc.Name='Test Account';
        insert acc;

        Id lenderid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Lender').getRecordTypeId();

        Contact c = new Contact();
        c.FirstName ='firstname';
        c.LastName = 'lastname';
        c.AccountId = acc.Id;
        c.RecordTypeId = lenderid;
        c.Personalized_Referral_Code__c = 'OfferCode';
        c.Contact_Role__c = 'loan officer';
        c.Email = 'test@gmail.com';
        insert c;
        //REAL_ESTATE_BROKER_LABEL
        //LENDER_LABEL
        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Sales_Director_User__c  = UserInfo.getUserId();
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Campaign_Content__c = 'OfferCode';
        newLead.Manually_Generated_Lead__c = 'No';
        newLead.Income_Monthly_Base__c = 100;
        insert newLead;
        system.debug('*******newLead.Campaign_Content__c********'+newLead.Campaign_Content__c);


        //newLead.Campaign_Content__c != NULL && getPersonalCodeContactMap().get(newLead.Campaign_Content__c) != NULL
    }

    @isTest
    private static void testautocreatedlead1(){
        Campaign_Code_Attribution__c setting = new Campaign_Code_Attribution__c(Name ='OfferCode', Campaign_Medium__c = 'theMedium', Campaign_Source__c = 'theSource', Campaign_Name__c = 'theName', Campaign_Term__c = 'theTerm', Branding_Type__c ='Open Market', Campaign_Media_Type__c ='Digital', Lead_Source__c = 'Website', Outbound_Marketing_Channel__c = 'Social');
        insert setting;

        Account acc = new Account();
        acc.Name='Test Account';
        insert acc;

        Id realestbrokid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Real Estate Broker').getRecordTypeId();

        Contact c = new Contact();
        c.FirstName ='firstname';
        c.LastName = 'lastname';
        c.AccountId = acc.Id;
        c.RecordTypeId = realestbrokid;
        c.Personalized_Referral_Code__c = 'OfferCode';
        insert c;
        //REAL_ESTATE_BROKER_LABEL
        //LENDER_LABEL
        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Campaign_Content__c = 'OfferCode';
        newLead.Manually_Generated_Lead__c = 'No';
        newLead.Income_Monthly_Base__c = 100;
        insert newLead;
        system.debug('*******newLead.Campaign_Content__c********'+newLead.Campaign_Content__c);


        //newLead.Campaign_Content__c != NULL && getPersonalCodeContactMap().get(newLead.Campaign_Content__c) != NULL
    }

    @isTest
    private static void testautocreatedlead2(){
        Account acc = new Account();
        acc.Name='Test Account';
        insert acc;

        Id realestbrokid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Real Estate Broker').getRecordTypeId();

        Contact c = new Contact();
        c.FirstName ='firstname';
        c.LastName = 'lastname';
        c.AccountId = acc.Id;
        c.RecordTypeId = realestbrokid;
        c.Personalized_Referral_Code__c = 'OfferCode';
        insert c;

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Manually_Generated_Lead__c = 'No';
        newLead.Campaign_Source__c = 'facebook';
        newLead.Campaign_Term__c = c.Id;
        newLead.Income_Monthly_Base__c = 100;
        insert newLead;
        system.debug('*******newLead.Campaign_Content__c********'+newLead.Campaign_Content__c);


        //newLead.Campaign_Content__c != NULL && getPersonalCodeContactMap().get(newLead.Campaign_Content__c) != NULL
    }


    @isTest
    private static void testautocreatedlead3(){

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Manually_Generated_Lead__c = 'No';
        newLead.Campaign_Source__c = 'facebook';
        newLead.Income_Monthly_Base__c = 100;
        insert newLead;
        system.debug('*******newLead.Campaign_Content__c********'+newLead.Campaign_Content__c);


        //newLead.Campaign_Content__c != NULL && getPersonalCodeContactMap().get(newLead.Campaign_Content__c) != NULL
    }

    @isTest
    private static void testautocreatedlead4(){

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        newLead.Manually_Generated_Lead__c = 'No';
        newLead.Income_Monthly_Base__c = 100;
        insert newLead;

    }



    /*  @isTest
  private static void test_addingMRDfiles(){
      Lead newLead = new Lead();
      newLead.OwnerId = UserInfo.getUserId();
      newLead.Income_Monthly_Base__c = 83333.33;
      newLead.Payment_Monthly_First_Mortgage__c = 0.00;
      newLead.Payment_Monthly_Second_Mortgage__c = 0.00;
      newLead.Phone = '111-555-1212';
      newLead.Email = 'William.lee@myunison.com';
      newLead.Company =    'the William Lee Household';
      newLead.Status  =    'Application Received';
      newLead.Probability__c =    41.50;
      newLead.Close_Date__c =  system.today();
      newLead.RecordTypeId  =  '01244000000DHFN';
      newLead.Income_QC__c  =   'Passed';
      newLead.Mortgage_QC_Status__c =  'Passed';
      newLead.Credit_Review__c  =      'Passed';
      newLead.Ratios__c =      'Passed';
      newLead.Unison_Transaction_Fee__c = 3.90;
      newLead.FirstName   =     'William';
      newLead.LastName = 'Lee';
      newLead.Quality_Assurance_Specialist__c = UserInfo.getuserid();
      newLead.LASERCA__Home_Address__c  =  '534 Cardinal St';
      newLead.LASERCA__Home_City__c  =  'Brea';
      newLead.LASERCA__Home_State__c  =  'CA';
      newLead.LASERCA__Home_Zip__c   =   '92823';
      newLead.Applicant_Birth_Date_Free_Response__c =  '06/30/1993';
      newLead.LASERCA__SSN__c   =  '222222222';
      newLead.Marital_Status__c =  'Single';
      newLead.Highest_Degree_Earned__c =  'Some College';
      newLead.Preferred_Phone__c   = 'Home';
      newLead.Inbound_Response_Channel__c  = 'Phone';
      newLead.Assets_Bank_Acct__c = 10000;
      newLead.Assets_Brokerage_Acct__c  = 10000;
      newLead.Assets_Other_Real_Estate__c  = 10000.00;
      newLead.Property_Street_Number_and_Name__c  = '534 Cardinal St';
      newLead.Property_City__c =  'Brea';
      newLead.Property_State__c =   'CA';
      newLead.Property_Zip_Code__c = '92833';
      newLead.Occupancy_Statement_Dropdown__c = 'Principal Residence';
      newLead.Property_Type__c = 'Single-family detached';
      newLead.Title_Held__c  = 'Individually';
      newLead.Credit_Pre_Qualification_Status__c = 'Approved';
      newLead.Applicant_Social_Security_Number__c = '222222222';
      newLead.Campaign_Audience__c  = 'Consumer';
      newLead.Channel__c   =  'Direct to Consumer';

      insert newLead;

      Minimum_Required_Documents__c mrd = new Minimum_Required_Documents__c(Lead__c=newLead.id, Category__c='W2', Applicant_Type__c='Applicant');
      insert mrd;

      List<ContentVersion> contentVersionInsert = new List<ContentVersion>{new ContentVersion(Title = 'Test',PathOnClient = 'Test.jpg',VersionData = Blob.valueOf('Test Content Data'),IsMajorVersion = true),
        new ContentVersion(Title = 'Test1',PathOnClient = 'Test1.jpg',VersionData = Blob.valueOf('Test Content Data'),IsMajorVersion = true)
      };
      insert contentVersionInsert;

      List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
      List<ContentDocumentLink> cdl = new List<ContentDocumentLink>{
          new ContentDocumentLink(LinkedEntityId = mrd.Id,ContentDocumentId = documents[0].Id,ShareType = 'V'),
          new ContentDocumentLink(LinkedEntityId = mrd.Id,ContentDocumentId = documents[1].Id,ShareType = 'V')
      };
      insert cdl;



      newLead.Quality_Control_Status__c = 'Passed';
      newLead.Credit_Review__c = 'Passed';
      newLead.Income_QC__c = 'Passed';
      newLead.Mortgage_QC_Status__c = 'Passed';
      newLead.Minimum_Required_Documents__c = 'Passed';
      newLead.Ratios__c = 'Passed';
      update newLead;

      List<Attachment> leadattac = [select Id from Attachment where parentId =: newLead.Id];
      //system.assertEquals(leadattac.size(),2);
  }*/

    @isTest
    private static void LeadConversionWithRelations(){
        test.starttest();
        try{
            Contact newContact = new Contact();
            newContact.FirstName = 'First';
            newContact.LastName = 'Last';
            newContact.Email = 'testLoanOfficer@test.com';
            newContact.MailingStreet = 'Test Street';
            newContact.MailingCity = 'Test City';
            newContact.MailingState = 'Test State';
            newContact.MailingPostalCode = 'TestCode';
            insert newContact;

            Lead newLead = [select Id, OwnerId, Property_County__c from Lead limit 1];
            newLead.Property_County__c = 'San Diego';
            newLead.Referring_Contact__c = newContact.id;
            newLead.Manually_Generated_Lead__c = 'Yes';
            update newLead;

            LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
            pcr.LASERCA__Lead__c = newLead.Id;
            pcr.Name = 'test';
            insert pcr;
            Case tmpCase = new Case(Status = 'New', Origin = 'Email', Lead__c = newLead.id);
            insert tmpCase;

            Current_Conditions__c tmpReq = new Current_Conditions__c();
            tmpReq.Lead__c           = newLead.id;
            insert tmpReq;

            dsfs__DocuSign_Status__c doc = new dsfs__DocuSign_Status__c();
            doc.dsfs__Lead__c           = newLead.id;
            insert tmpReq;

            Document_MetaData__c d = new Document_MetaData__c();
            d.Requirement__c           = tmpReq.Id;
            d.Document_Type__c         = 'CAP Completed';
            //d.Category__c              = 'Credit';
            d.Lead__c           = newLead.id;
            insert d;

            Database.LeadConvert lc = new database.LeadConvert();
            lc.setOwnerId(newLead.OwnerId);
            lc.setLeadId(newLead.Id);
            lc.setConvertedStatus('Submitted');
            Database.convertLead(lc);
        }catch(Exception e){}
        test.stoptest();
    }

    @isTest
    private static void updateAppicantstoOpportunity() {
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;

        Opportunity opp = new Opportunity(name= 'test');
        opp.AccountId = newAccount.id;
        opp.Name         = 'test opp';
        opp.StageName    = 'Investment Due Diligence';
        opp.CloseDate    = System.today();
        opp.Estimated_Funding_Amount__c = 2;
        opp.Pricing_Ratio__c = 2;
        opp.Final_OAV_Calculation__c = 4;
        opp.IA_OAV_Override__c = 4;
        insert opp;

        Contact newContact = new Contact();
        newContact.AccountId = newAccount.Id;
        newContact.FirstName = 'First';
        newContact.LastName = 'Last';
        newContact.Email = 'testLoanOfficer@test.com';
        newContact.MailingStreet = 'Test Street';
        newContact.MailingCity = 'Test City';
        newContact.MailingState = 'Test State';
        newContact.MailingPostalCode = 'TestCode';
        newContact.Personalized_Referral_Code__c = 'test referral code';
        insert newContact;

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.Country = 'United States';
        newLead.PostalCode = 'TX1234';
        newLead.Co_Applicant_BirthDate__c = System.Today();
        newLead.Co_Applicant_City__c = 'City';
        newLead.Co_Applicant_Email__c  = 'coapplicant@test.com';
        newLead.Co_Applicant_First_Name__c  = 'CoApplicantFirst';
        newLead.Co_Applicant_Last_Name__c  = 'CoApplicantLast';
        newLead.Co_Applicant_Postal_Code__c = '12345';
        newLead.Co_Applicant_State__c = 'State';
        newLead.Bankrupcy_in_last_seven_years_co__c = true;
        newLead.Estimated_Total_Monthly_Income_co__c = 12345;
        newLead.Felonies_co__c = true;
        newLead.FormId__c = 'testLoanOfficer@test.com';
        newLead.Given_deed_for_foreclosure_in_7_years_co__c = true;
        newLead.Marital_Status_co__c = 'Single';
        newLead.Previous_Foreclosure_co__c = true;
        newLead.Income_Monthly_Base__c = 100;

        List<Account> acclist = new List<Account>();
        Set<Id> appids = new set<id>();
        Set<Id> coappids = new set<id>();
        List<Contact> newcoapps = new List<Contact>();
        List<Lead> ldlist = new List<Lead>();
        List<Recorded_Information__c> recinfolist = new List<Recorded_Information__c>();

        Test.startTest();

        insert newLead;


        acclist.add(newAccount);
        ldlist.add(newLead);

        //LeadConversionProcess.updateAppicantstoOpportunity(appids,coappids,newcoapps,acclist,ldlist, recinfolist);
        test.stopTest();
    }

    @isTest
    private static void testleadconversion3(){
        //String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        //Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());

        test.starttest();
        try {
            Lead newLead = [select Id, OwnerId, Property_County__c from Lead limit 1];

			newLead.Property_County__c = 'San Diego';
            Update newLead;
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setOwnerId(newLead.OwnerId);
            lc.setLeadId(newLead.Id);
            lc.setConvertedStatus('Submitted');

            Database.convertLead(lc);
        }catch(Exception e){}
        test.stoptest();
    }

    @isTest
    private static void testleadconversion2(){
        //String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        //Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));


        // try {
        /*
            Lead newLead = new Lead();
            newLead.FirstName = 'First3';
            newLead.LastName = 'Last3';
            newLead.Email = 'test3@test3.com';
            newLead.Phone = '12345678902';
            newLead.Company = 'Test2 Company';
            newLead.Status = 'New';
            newLead.Street = 'Test2 Street';
            newLead.City = 'Test2 City';
            newLead.State = 'Test2 State';
            newLead.Country = 'United States';
            newLead.PostalCode = 'TX12342';
            newLead.Co_Applicant_BirthDate__c = System.Today();
            newLead.Co_Applicant_City__c = 'City';
            newLead.Co_Applicant_Email__c  = 'coapplicant2@test2.com';
            newLead.Co_Applicant_First_Name__c  = 'CoApplicantFirst2';
            newLead.Co_Applicant_Last_Name__c  = 'CoApplicantLast2';
            newLead.Co_Applicant_Postal_Code__c = '122345';
            newLead.Co_Applicant_State__c = 'State';
            newLead.Bankrupcy_in_last_seven_years_co__c = true;
            newLead.Estimated_Total_Monthly_Income_co__c = 12345;
            newLead.Felonies_co__c = true;
            newLead.FormId__c = 'testLoanOfficer2@test2.com';
            newLead.Given_deed_for_foreclosure_in_7_years_co__c = true;
            newLead.Marital_Status_co__c = 'Single';
            newLead.Previous_Foreclosure_co__c = true;


            insert newLead;*/
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        test.starttest();

        List<Lead> leads = [select Id, OwnerId from Lead limit 1];
        Lead newLead = leads[0];
        newLead.Property_County__c = 'San Diego';
        update newLead;
        set <id> ids= new set <id>();
        ids.add(leads[0].id);

        LASERCA__Personal_Credit_Report__c pcr = new LASERCA__Personal_Credit_Report__c();
        pcr.LASERCA__Lead__c = newLead.Id;
        pcr.Name = 'test';
        insert pcr;

        Case tmpCase = new Case(Status = 'New', Origin = 'Email', Lead__c = newLead.id);
        insert tmpCase;

        Success_Factor__c sf = new Success_Factor__c();
        sf.Lead__c  = newLead.id;
        sf.Status__c = 'In Progress';
        sf.Success_Factor__c = 'DTI';
        sf.Program__c = 'HO';
        insert sf;

        Current_Conditions__c tmpReq = new Current_Conditions__c();
        tmpReq.Lead__c           = newLead.id;
        tmpReq.Requirement__c = 'CAP Completed';
        tmpReq.Code__c = 'R1046';
        tmpReq.Category__c = 'Mortgage';
        tmpReq.Internal_vs_External__c = 'Internal';
        tmpReq.Success_Factor__c = sf.Id;
        insert tmpReq;

        dsfs__DocuSign_Status__c doc = new dsfs__DocuSign_Status__c();
        doc.dsfs__Lead__c           = newLead.id;
        insert doc;

        Document_MetaData__c d = new Document_MetaData__c();
        d.Requirement__c           = tmpReq.Id;
        d.Document_Type__c         = 'CAP Completed';
        //d.Category__c              = 'Credit';
        d.Lead__c           = newLead.id;
        insert d;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setOwnerId(newLead.OwnerId);
        lc.setLeadId(newLead.Id);
        lc.setConvertedStatus('Submitted');

        //Database.convertLead(lc);
        //LeadConversionProcess.createchildforconvLead(ids);
        //}catch(Exception e){}
        test.stoptest();
    }
}