public class AccountPartnerEvent_EXT {

    public Event theEvent {get;set;}
    public Account theAccount {get;set;}  
    public string selectedContactId {get;set;}  
    private Map<Id,Contact> contactMap = new Map<Id,Contact>();
    
    public static final Map<string,string> eventTypeSubjectMap = new Map<string,string>{
        'Lunch and Learn' => 'Lunch and Learn - ', 
        'Product Training' => 'Product Training - ',
        'Re-Engaged Training' => 'Re-Engaged Training - ', 
        'LOP Training' => 'LOP Training - ', 
        'Dinner / Cocktail Event' => 'Dinner / Cocktail Event - ', 
        'Conference Expo' => 'Conference Expo - ' 
    };
        
    //method to get valid contacts under the account    
    public List<selectOption> getContactOptions(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('','--None--'));        
        for(Contact c: contactMap.values()){
            options.add(new SelectOption(c.Id,c.Name));        
        }
        return options;     
    }
    
    
    public AccountPartnerEvent_EXT(ApexPages.StandardController sc){
        Id accountId = sc.getId();
        theAccount = [SELECT Id, Name,(SELECT Name FROM Contacts WHERE RecordType.Name = 'Lender' OR RecordType.Name = 'Real Estate Broker' ) FROM Account WHERE Id=:accountId];
        for(Contact c: theAccount.Contacts){
            contactMap.put(c.Id,c);
        }        
        
        theEvent = new Event(whatId = theAccount.Id);
        theEvent.WhatId = theAccount.Id;
        theEvent.recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Partner Event').getRecordTypeId();
        theEvent.OwnerId = UserInfo.getUserId();
        theEvent.Event_Status__c = 'Not Started';
    }
    
    public void populateSubject(){
        /*if(this.selectedContactId == NULL || this.selectedContactId == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Contact')); return;        
        }*/
        if(contactMap.get(selectedContactId) != NULL){
            theEvent.Subject = eventTypeSubjectMap.get(theEvent.Partner_Event_Type__c) + contactMap.get(selectedContactId).Name + ', ' + theAccount.Name;
        }
        else{
            theEvent.Subject = eventTypeSubjectMap.get(theEvent.Partner_Event_Type__c) + theAccount.Name;            
        }
        system.debug('theEvent---' + theEvent);
    }
    
    public pageReference saveEvent(){
        populateSubject();
        theEvent.whoId = (selectedContactId != NULL && selectedContactId != '') ? selectedContactId: NULL ;
        insert theEvent;
        
        return new PageReference('/' + theEvent.Id);
    }
    
    
}