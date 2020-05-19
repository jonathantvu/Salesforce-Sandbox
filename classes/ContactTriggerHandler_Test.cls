@istest
private class ContactTriggerHandler_Test {
    @TestSetup
    private static void Testdata() {
        Schema.DescribeSObjectResult conDesc = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContRTMapByName = conDesc.getRecordTypeInfosByName();
        
        Account account1 = new Account();
        account1.Name = 'Test Account';
        insert account1;

        Contact contact1 = new Contact();
        Contact1.AccountId = account1.Id;
        Contact1.FirstName = 'First1';
        Contact1.LastName = 'Last1';
        Contact1.Contact_Role__c = 'Loan Officer';
        Contact1.RecordTypeId = ContRTMapByName.get('Lender').getRecordTypeId();
        Contact1.Sales_Director__c = UserInfo.getUserId();
        Contact1.Branch_Name__c = 'Sanjose';
        contact1.Territory__c = '03 - Los Angeles/Orange County';
        Contact1.Email = 'test@test.com';
        Contact1.MailingStreet = 'Test Street';
        Contact1.MailingCity = 'Test City';
        Contact1.MailingState = 'Test State';
        Contact1.MailingPostalCode = 'TestCode';
        insert contact1;
        
        Account account2 = new Account();
        account2.Name = 'Test Account';
        insert account2;
        
        Contact contact2 = new Contact();
        contact2.AccountId = account2.Id;
        contact2.FirstName = 'First';
        contact2.LastName = 'Last';
        Contact2.Contact_Role__c = 'Loan Officer';
        Contact2.RecordTypeId = ContRTMapByName.get('Lender').getRecordTypeId();
        Contact2.Sales_Director__c = UserInfo.getUserId();
        Contact2.Branch_Name__c = 'Sanjose';
        contact2.Territory__c = '03 - Los Angeles/Orange County';
        contact2.Email = 'test2@test.com';
        contact2.MailingStreet = 'Test Street';
        contact2.MailingCity = 'Test City';
        contact2.MailingState = 'Test State';
        contact2.MailingPostalCode = 'TestCode';
        insert contact2;
    }
    
    @istest
    private static void contactsRollUp() {
        List<Contact> con = [select Id, AccountId from Contact limit 2];
        
        con[0].AccountId = con[1].Accountid;
        update con[0];
        
        delete con[0];
        
        undelete con[0];
                
    }
}