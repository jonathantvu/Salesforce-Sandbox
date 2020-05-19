/**
 *  About
 *  -----
 *  Author: Cloud Nerd
 *  Create date: Sun Jul 17 2016
 *  
 *  Details
 *  -----
 *  Single Trigger to take care of all the operations on Opportunity
 *  
 *  Issues / TODOs
 *  -----
 *  Modifed by Sundar 04/19/2019 - added ,after insert in trigger events
**/

trigger OpportunityTrigger on Opportunity(before insert, before update, after update,after insert) {
   
    if (Trigger.isBefore && Trigger.isInsert){
        OpportunityTriggerHandler.handleBeforeInsert(Trigger.New);
        
    }else if (Trigger.isAfter && Trigger.isInsert){
        OpportunityTriggerHandler.handleAfterInsert(Trigger.New);
        
    }else if (Trigger.isBefore && Trigger.isUpdate){
        OpportunityTriggerHandler.handleBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
        
    }else if(Trigger.isAfter && Trigger.isUpdate ) {
        OpportunityTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.OldMap); 
        
    }
}