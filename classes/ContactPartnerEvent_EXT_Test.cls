@isTest
public class ContactPartnerEvent_EXT_Test {

    public static testMethod void testContactPartnerEvent(){
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        ContactPartnerEvent_EXT ext = new ContactPartnerEvent_EXT(sc);
        
        ext.theEvent.Partner_Event_Type__c = 'LOP Training';
        ext.theEvent.Partner_Event_Method__c = 'In Person';        
        ext.theEvent.StartDateTime = datetime.now();
        ext.theEvent.EndDateTime = datetime.now().addHours(4);        
		ext.populateSubject();        
        ext.saveEvent();        
    }
    
}