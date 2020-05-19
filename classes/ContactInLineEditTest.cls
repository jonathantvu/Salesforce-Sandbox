@isTest
public with sharing class ContactInLineEditTest {

    public static testMethod void contactlist(){

        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);

        ContactInLineEdit test = new ContactInLineEdit(sc);
    }

}