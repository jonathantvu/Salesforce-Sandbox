public class ContactPartnerEvent_EXT {

    public Event theEvent {get;set;}
    public Contact theContact {get;set;}    
    
    public static final Map<string,string> eventTypeSubjectMap = new Map<string,string>{
        'Lunch and Learn' => 'Lunch and Learn - ', 
        'Product Training' => 'Product Training - ',
        'Re-Engaged Training' => 'Re-Engaged Training - ', 
        'LOP Training' => 'LOP Training - ', 
        'Dinner / Cocktail Event' => 'Dinner / Cocktail Event - ', 
        'Conference Expo' => 'Conference Expo - ' 
    };
    
    
    public ContactPartnerEvent_EXT(ApexPages.StandardController sc){
        Id contactId = sc.getId();
        theContact = [SELECT Id, Name, AccountId, Account.Name FROM Contact WHERE Id=:contactId];
        
        theEvent = new Event(whoId = theContact.Id);
        theEvent.WhatId = theContact.AccountId;
        theEvent.recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Partner Event').getRecordTypeId();
        theEvent.OwnerId = UserInfo.getUserId();
        theEvent.Event_Status__c = 'Not Started';
    }
    
    public void populateSubject(){
        theEvent.Subject = eventTypeSubjectMap.get(theEvent.Partner_Event_Type__c) + theContact.Name + ', ' + theContact.Account.Name;
        system.debug('theEvent---' + theEvent);
    }
    
    public pageReference saveEvent(){
        insert theEvent;
        
        return new PageReference('/' + theEvent.Id);
    }
    
    
}