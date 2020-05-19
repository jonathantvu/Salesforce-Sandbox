@isTest
public class AccountPartnerEvent_EXT_Test {

    public static testMethod void testAccountPartnerEvent(){
        Account acct = new Account(Name = 'A Lender Account');        
        insert acct;
        
        Contact cont = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Lender').getRecordTypeId());
        cont.AccountId = acct.id;
        cont.LastName = 'LastName';
        cont.FirstName = 'FirstName';
        cont.Email = 'arandomemail21343@example123.com';
        cont.title = 'Loan Officer';
        cont.Contact_Role__c = 'Loan Officer';
        insert cont;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        AccountPartnerEvent_EXT ext = new AccountPartnerEvent_EXT(sc);
        
        ext.getContactOptions();        
        ext.theEvent.Partner_Event_Type__c = 'LOP Training';
        ext.theEvent.Partner_Event_Method__c = 'In Person';
        ext.selectedContactId = cont.Id;        
        ext.theEvent.StartDateTime = datetime.now();
        ext.theEvent.EndDateTime = datetime.now().addHours(4);        
        ext.populateSubject();        
        ext.saveEvent();        
    }
    
}