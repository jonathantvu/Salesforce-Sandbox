@isTest
public class UnconvertLeadsBatchTest {

    private static final Schema.DescribeSObjectResult acctDesc = Schema.SObjectType.Account;
    private static final Map<string, Schema.RecordTypeInfo> acctRTMap = acctDesc.getRecordTypeInfosByName();
    private static final Schema.DescribeSObjectResult contDesc = Schema.SObjectType.Contact;
    private static final Map<string, Schema.RecordTypeInfo> contRTMap = contDesc.getRecordTypeInfosByName();

    public static testMethod void Test1() {
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        Test.startTest();

        Account brokerAccount = new Account(recordTypeId = acctRTMap.get('Real Estate Broker').GetRecordTypeId(), Name = 'Test RE Broker');
        insert brokerAccount;

        Contact REAgentContact = new Contact(recordTypeId = contRTMap.get('Real Estate Broker').GetRecordTypeId(), FirstName = 'Reggie', LastName ='REAgent', accountId = brokerAccount.id, Personalized_Referral_Code__c = 'REAGENT123', Sales_Director__c = UserInfo.getUserId());
        insert REAgentContact;

        Account newAccount = new Account();
        newAccount.Name = 'Lender Account';
        newAccount.RecordTypeId = acctRTMap.get('Lender').GetRecordTypeId();
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
        insert newContact;
        
        Opportunity opp1 = new Opportunity();
             opp1.Name = 'test';
             opp1.AccountId = newAccount.Id;
             opp1.StageName = 'Submit to Ops';
             opp1.CloseDate = system.today();
             opp1.Estimated_Funding_Amount__c = 2;
opp1.Final_OAV_Calculation__c = 2; opp1.Pricing_Ratio__c = 2;
opp1.IA_OAV_Override__c =2;
        insert opp1;
        Schema.DescribeSObjectResult leadDescribe = Lead.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> leadRTMap = leadDescribe.getRecordTypeInfosByName();

        Lead convertedLead = new Lead();
        convertedLead.RecordTypeId = leadRTMap.get('HomeBuyer').getRecordTypeId();
        convertedLead.FirstName = 'Tst091373';
        convertedLead.LastName = 'Tst938233';
        convertedLead.Company = 'Tst398733';
        convertedLead.Status = 'Pending Qualification';
        convertedLead.Property_Street_Number_and_Name__c = 'Tst397923';
        convertedLead.Property_City__c = 'Los Angeles';
        convertedLead.Property_State__c = 'Ca';
        convertedLead.Property_Zip_Code__c = '00000';
        convertedLead.Agency_or_Non_Agency__c = 'Agency';
        convertedLead.Property_Type__c = 'Single-family detached';
        convertedLead.Title_Held__c = 'Individually';
        convertedLead.Occupancy_Statement_Dropdown__c = 'Principal Residence';
        convertedLead.New_Construction_Dropdown__c = 'No';
        convertedLead.Property_Pre_Qualification_Status__c = 'Approved';
        convertedLead.Purchase_Price__c = 100000;
        convertedLead.Loan_Amount__c = 80000;
        convertedLead.Estimated_Funding_Amount__c = 10000;
        convertedLead.Household_Down_Payment__c = 10000;
        convertedLead.Real_Estate_Agent__c = REAgentContact.Id;
        convertedLead.Selling_Real_Estate_Agent__c = REAgentContact.Id;
        convertedLead.Loan_officer__c = newContact.id;
        convertedLead.Sales_Director_User__c = [SELECT Id FROM User WHERE IsActive=TRUE LIMIT 1][0].Id;
        convertedLead.Insurance_Agent__c = REAgentContact.Id;
        convertedLead.Close_Date__c = date.today();
        convertedLead.Income_Monthly_Base__c = 25000;
        convertedLead.Applicant_Social_Security_Number__c = '000000000';
        convertedLead.Marital_Status__c = 'Single';
        convertedLead.Applicant_Birth_Date_Free_Response__c = '01/01/1975';
        convertedLead.Property_County__c = 'AC';
        insert convertedLead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(convertedLead.id);
        lc.setDoNotCreateOpportunity(false);
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true AND MasterLabel = 'Submitted' limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        string oppname = lc.getOpportunityName();
        System.debug('oppname: '+oppname);

        List<Opportunity> opplist = [SELECT id,Probability FROM Opportunity];
        //System.debug('opplist: '+opp);
        for(opportunity opp:opplist){
        opp.Probability = 10;
        }
        update opplist;


        UncovertLeadsBatch c = new UncovertLeadsBatch();
        Database.executeBatch(c);

        (new UncovertLeadsBatch()).execute(null);

        Test.stopTest();
    }
}