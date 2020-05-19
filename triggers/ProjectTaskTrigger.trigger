/**
 * Created by Eliot Rojas on 5/1/2019.
 */

trigger ProjectTaskTrigger on Project_Task__c (before insert, before update, after update, after insert) {
    if (Trigger.isBefore && Trigger.isInsert){

    }else if (Trigger.isAfter && Trigger.isInsert){
        ProjectTasksTriggerHandler.handleAfterInsert(Trigger.New);
    }else if (Trigger.isBefore && Trigger.isUpdate){

    }else if(Trigger.isAfter && Trigger.isUpdate) {
        ProjectTasksTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.OldMap);
    }
}