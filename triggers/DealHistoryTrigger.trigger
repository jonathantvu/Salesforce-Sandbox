trigger DealHistoryTrigger on Deal_History__c (before insert, after insert, before update, after update) {
    if (Trigger.isAfter && Trigger.isUpdate){
        DealHistoryTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.OldMap);
    }   
}