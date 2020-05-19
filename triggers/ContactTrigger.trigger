trigger ContactTrigger on Contact (before insert,before update, before delete, after insert, after update, after delete, after undelete) { 
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        InvalidateEmail.invalidateEmail(Trigger.new);
        ContactTriggerHandler.rewritePhoneOnLead(Trigger.new);
    }
	if (Trigger.isBefore && Trigger.isUpdate) 
    {
        InvalidateEmail.invalidateEmail(Trigger.new);
    	ContactTriggerHandler.CalculateNumberOfReferredLeads(Trigger.new);
        ContactTriggerHandler.rewritePhoneOnLead(Trigger.new);
    }
    
    if(!System.IsBatch()) {
        if(Trigger.IsBefore) {

            List<Contact> contactCreateList = new List<Contact>();
            List<Contact> contactUpdateList = new List<Contact>();
            List<Contact> contactDeleteList = new List<Contact>();
            
            if(Trigger.IsUpdate) {
                for(contact objContact : Trigger.new) {
                    if(!Trigger.oldMap.get(objContact.Id).Create_LOP_User__c && objContact.Create_LOP_User__c) {
                        contactCreateList.add(objContact);
                    } else if(!Trigger.oldMap.get(objContact.Id).Update_LOP_User__c && objContact.Update_LOP_User__c) {
                        contactUpdateList.add(objContact);
                    } else if(!Trigger.oldMap.get(objContact.Id).Deactivate_LOP_User__c && objContact.Deactivate_LOP_User__c) {
                        contactDeleteList.add(objContact);
                    }
                }
                ContactTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_CREATE, contactCreateList);
                ContactTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_UPDATE, contactUpdateList);
                ContactTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_DELETE, contactDeleteList);            
            } else if(Trigger.IsDelete) {
                for(contact objContact : Trigger.old) {
                    if(objContact.LOP_User__c) {
                        contactDeleteList.add(objContact);
                    }
                }
                ContactTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_DELETE, contactDeleteList);            
            }          
        } else {
            // Trigger : IsAfter Code Here
        }
    }
    

    if (Trigger.isAfter && Trigger.isInsert){
        ContactTriggerHandler.handleAfterInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isUpdate){
        ContactTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.OldMap);
    }else if(Trigger.isAfter && Trigger.isDelete){
        ContactTriggerHandler.handleAfterDelete(Trigger.Old);
    }else if(Trigger.isAfter && Trigger.isUndelete) {
        ContactTriggerHandler.handleAfterUndelete(Trigger.new);
    }
}