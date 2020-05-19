/**
 *  About
 *  -----
 *  Author: Cloud Nerd
 *  Create date: Tue Jun 26 2016
 *  
 *  Details
 *  -----
 *  Apex helper class for CN_DocusignStatusTriggerHandler
 *
 *  Update History
 *  -----
 *  
 *  Issues / TODOs
 *  -----
 *  
**/
public class CN_DocusignStatusTriggerHelper{
    
    /* Method to update opportunity Status */
    public static void updateOpportunityStatus(Set<id> setOpportunityId, String oppStage){
        // retrieve these opportunities
        // TODO: Replace DeliveryInstallationStatus__c with the field you want to update, replace Opportunity to your object name, ex: Contact or Lead
        List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE Id IN :setOpportunityId];
    
        // update these opportunities
        for(Opportunity o : opportunities) {                  
            o.StageName = oppStage;    //TODO: Updated opportunity stage
        }
        
        try{
            update opportunities;
        }catch(Exception ex){
            System.Debug('An error occured while updating opportunity: '+ex);
        }
    }
}