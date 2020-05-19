@isTest
private with sharing class ResendPortalCredentialsContactTest {

    @testSetup static void setup() {
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
        insert newContact;
    }

    @IsTest
    static void testSendWelcomeEmail() {
        Contact contact = [SELECT Id, Name, Case_Safe_ID__c FROM Contact LIMIT 1];
        Test.startTest();
        ResendPortalCredentialsContact.ResendWelcomeEmail(contact.Id);
        Test.stopTest();
    }
}