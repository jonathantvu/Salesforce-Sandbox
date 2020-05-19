trigger CopyGroupTypeTrigger on OpportunityLineItem (before insert, before update, after update,after insert,after delete) {
    if (Trigger.isBefore && Trigger.isInsert){
        OpportunityLineItemTriggerhandler.handleBeforeInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isInsert){
        OpportunityLineItemTriggerhandler.handleAfterInsert(Trigger.New);
    }else if (Trigger.isBefore && Trigger.isUpdate){
        OpportunityLineItemTriggerhandler.handleBeforeUpdate(Trigger.New, Trigger.OldMap);
    }else if(Trigger.isAfter && Trigger.isUpdate) {
        OpportunityLineItemTriggerhandler.handleAfterUpdate(Trigger.New, Trigger.OldMap);    
    }else if(Trigger.isAfter && Trigger.isDelete) {
        OpportunityLineItemTriggerhandler.handleAfterDelete(Trigger.Old, Trigger.OldMap);    
    }
    
    
    /*Set<Id> productIds = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    for(OpportunityLineItem item : Trigger.new) {
        productIds.add(item.Product2Id);
        oppIds.add(item.OpportunityId);
    }

    Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id, Name, ProductCode, Group__c, Type__c FROM Product2 where Id IN: productIds]);
    Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Name,Estimated_Funding_Amount__c,Unison_Transaction_Fee__c FROM Opportunity where Id IN: oppIds]);

    for(OpportunityLineItem item : Trigger.new) {
        item.Amount__c = item.UnitPrice;
        if(productMap.containsKey(item.Product2Id)) {
            item.Group__c = productMap.get(item.Product2Id).Group__c;
            item.Type__c = productMap.get(item.Product2Id).Type__c;
            if(productMap.get(item.Product2Id).Name == 'Acquisition Fee' && oppMap.containsKey(item.OpportunityId) && oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c != null) {
                item.Amount__c = 0.1 * oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c;
                item.UnitPrice = item.Amount__c;
            }
            if(productMap.get(item.Product2Id).Name == 'Transaction Fee' && oppMap.containsKey(item.OpportunityId) && oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c != null
                && oppMap.get(item.OpportunityId).Unison_Transaction_Fee__c != null) {
                
                if(oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c >= 360000) {
                    item.Amount__c = 14000;
                } else if(oppMap.get(item.OpportunityId).Unison_Transaction_Fee__c != null) {
                    item.Amount__c = (oppMap.get(item.OpportunityId).Unison_Transaction_Fee__c/100) * oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c;
                }
                item.UnitPrice = item.Amount__c;
            }
            
        }
        
        //if(item.Discount__c != null && item.Type__c =)
    }*/
}