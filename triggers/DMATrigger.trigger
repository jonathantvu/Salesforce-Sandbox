trigger DMATrigger on DMA__c (before insert, after Insert, before update, after update)
{
    if(Trigger.isBefore && Trigger.isInsert) 
    {
     //   DMATriggerHandler.onbeforeInsert(Trigger.new);
    }
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        //DMATriggerHandler.onAfterInsert(Trigger.new);
    }
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
     //   DMATriggerHandler.onAfterUpdate(Trigger.New, Trigger.OldMap);
    }
}