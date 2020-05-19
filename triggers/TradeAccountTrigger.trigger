trigger TradeAccountTrigger on LASERCA__Trade_Accounts__c (before insert, after insert, before update, after update) {
    if(Trigger.isBefore && Trigger.isInsert) {
        TradeAccountTriggerHandler.handleBeforeInsert(Trigger.New);
    } else if(Trigger.isAfter && Trigger.isInsert) {
        TradeAccountTriggerHandler.handleAfterInsert(Trigger.New);
        //TradeAccountTriggerHandler.createrequirementandtask(Trigger.New, null);
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        //TradeAccountTriggerHandler.createrequirementandtask(Trigger.New, Trigger.oldMap);
       TradeAccountTriggerHandler.handleBeforeUpdate(Trigger.New, Trigger.oldMap);
    } else if(Trigger.isAfter && Trigger.isUpdate) {
        TradeAccountTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.oldMap);
    }
}