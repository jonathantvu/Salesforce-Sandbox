/**
 *  About
 *  -----
 *  Author: Cloud Nerd
 *  Create date: Tue Jun 21 2016
 *  
 *  Details
 *  -----
 *  Single Trigger to take care of all the operations on Lead
 *  
 *  Issues / TODOs
 *  -----
 *  
**/

trigger LeadTrigger on Lead(before insert, after insert, before update, after update, after delete)
{
    if (Trigger.isBefore && Trigger.isInsert)
    {
        LeadTriggerHandlerPC.handleBeforeInsert(Trigger.New);
        LeadTriggerHandlerPC.rewritePhoneOnLead(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isInsert)
    {
        LeadTriggerHandlerPC.handleAfterInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isUpdate)
    {
        LeadTriggerHandlerPC.handleAfterUpdate(Trigger.New, Trigger.OldMap);
      //  LeadUtilityClass.createRequirements(Trigger.New, Trigger.OldMap);
    }else if(Trigger.isBefore && Trigger.isUpdate)
    {
        LeadTriggerHandlerPC.handlebeforeUpdate(Trigger.newMap, Trigger.OldMap);
         LeadTriggerHandlerPC.rewritePhoneOnLead(Trigger.New);
     }else if(Trigger.isAfter && Trigger.isDelete){
        LeadTriggerHandlerPC.handleAfterDelete(Trigger.old);
    }
}