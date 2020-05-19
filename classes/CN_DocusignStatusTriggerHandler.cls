/**
 *  About
 *  -----
 *  Author: Cloud Nerd
 *  Create date: Tue Jun 26 2016
 *  
 *  Details
 *  -----
 *  Apex class which handles operations for CN_DocusignStatusTrigger
 *
 *  Update History
 *  -----
 *  
 *  Issues / TODOs
 *  -----
 *  
**/

public class CN_DocusignStatusTriggerHandler {
    
    //Method to handle after Insert
    public static void onAfterInsert(Map<Id, dsfs__DocuSign_Status__c> newMap){
        // get a set of all created docusign statuses with opportunities
        Set<Id> setOpportunityId = new Set<Id>();
        
        for(dsfs__DocuSign_Status__c newObj : newMap.values()) {
           if (newObj.dsfs__Opportunity__c != null && newObj.dsfs__Envelope_Status__c.equalsIgnoreCase(CN_Constants.DSFS_SENT)) {  //check if its attached to Opportunity and document status is sent
               setOpportunityId.add(newObj.dsfs__Opportunity__c);                                                                                     
           }
        }
        
        //call helper method
        if(!setOpportunityId.isEmpty()){
            CN_DocusignStatusTriggerHelper.updateOpportunityStatus(setOpportunityId, CN_Constants.OPP_STAGE_APPLICATION_SENT);
        }
    }
    
    
    
    //Method to handle after Update
    public static void onAfterUpdate(Map<Id, dsfs__DocuSign_Status__c> newMap, Map<Id, dsfs__DocuSign_Status__c> oldMap ){
        // get a set of all completed docusign statuses with opportunities
        Set<Id> setOpportunityId = new Set<Id>();
        for(dsfs__DocuSign_Status__c newObj : newMap.values()) {
           dsfs__DocuSign_Status__c oldObj = oldMap.get(newObj.Id);
           if (newObj.dsfs__Opportunity__c != null && (newObj.dsfs__Envelope_Status__c != oldObj.dsfs__Envelope_Status__c) && newObj.dsfs__Envelope_Status__c.equalsIgnoreCase(CN_Constants.DSFS_COMPLETED)) {  //check if its attached to Opportunity and document status is sent      
               setOpportunityId.add(newObj.dsfs__Opportunity__c);                                                                                     
           }
        }
        
        //call helper method
        if(!setOpportunityId.isEmpty()){
            CN_DocusignStatusTriggerHelper.updateOpportunityStatus(setOpportunityId, CN_Constants.OPP_STAGE_APPLICATION_SIGNED);
        }
    }
}