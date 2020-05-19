trigger SuccessFactorsTrigger on Success_Factor__c(before insert, after insert, before update, after update) {
    if (Trigger.isBefore && Trigger.isInsert){
       // SuccessFactorsTriggerPC.handleBeforeInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isInsert){
       // SuccessFactorsTriggerPC.handleAfterInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isUpdate){
        SuccessFactorsTriggerPC.handleAfterUpdate(Trigger.New, Trigger.OldMap);
    }else if(Trigger.isBefore && Trigger.isUpdate){
       // SuccessFactorsTriggerPC.handlebeforeUpdate(Trigger.newMap, Trigger.OldMap);
    }
}