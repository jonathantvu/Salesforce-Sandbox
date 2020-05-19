/**
 *  About
 *  -----
 *  Author: Sundar Subramaniam
 *  Create date: Tue Apr 16 2019
 *  
 *  Details
 *  -----
 *  Single Trigger to take care of all the operations on Lead
 *  
 *  
 *  -----
 *  
**/

trigger PropertyTrigger on Property__c (before insert, after insert, before update, after update) {
    if (Trigger.isBefore && Trigger.isInsert){
        
    }else if (Trigger.isAfter && Trigger.isInsert){
        PropertyTriggerHandler.handleAfterInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isUpdate){
        PropertyTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.OldMap);
    }else if(Trigger.isBefore && Trigger.isUpdate){
        
    }
}