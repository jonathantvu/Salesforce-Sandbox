trigger AddMRDFiles on Lead (after update) {
    Set<Id> leadids = new Set<Id>();
    Map<Id, Lead> oldMap = Trigger.OldMap;
    for (Lead newLead: Trigger.New) {        
        if(newLead.Quality_Control_Status__c != Null && newLead.Quality_Control_Status__c == 'Passed'
           && oldMap.get(newLead.Id).Quality_Control_Status__c != 'Passed'){
            leadids.add(newLead.Id);                
        }
    }
    
    if(leadids.size() > 0){
        LeadUtilityClass.addMRDAttachments(leadids);
    }
}