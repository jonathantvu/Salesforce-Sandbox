/**
 *  About
 *  -----
 *  Author: Cloud Nerd
 *  Create date: Tue Jun 26 2016
 *  
 *  Details
 *  -----
 *  Apex trigger for dsfs__DocuSign_Status__c object
 *
 *  Update History
 *  -----
 *  
 *  Issues / TODOs
 *  -----
 *  
**/

Trigger CN_DocusignStatusTrigger on dsfs__DocuSign_Status__c (after insert, after update) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        CN_DocusignStatusTriggerHandler.onAfterInsert(Trigger.newMap);
    }else if(Trigger.isUpdate && Trigger.isAfter){
        CN_DocusignStatusTriggerHandler.onAfterUpdate(Trigger.newMAP,Trigger.oldMap);
    }
}