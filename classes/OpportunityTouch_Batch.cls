/**
 *  About
 *  -----
 *  Author: Cloud Mine Consulting
 *  Create date: 9/7/2017
 *  
 *  Details
 *  -----
 *  Batch Class for Opportunity Touch operations
 *  
 *  Update History
 *  -----
 *  9/29/17 --- Extended Class to take handle Leads also
 * 
 *  Issues / TODOs
 *  -----
 * 
**/
global class OpportunityTouch_Batch implements Database.Batchable<sObject> {

    global string objectType;
	    
    global OpportunityTouch_Batch(string objectType) {
        this.objectType = objectType;
    }    
    
	global Iterable<sObject> start(Database.BatchableContext bc) {
        List<sObject> sObjectList = new List<sObject>();
        if(this.objectType =='Opportunity'){
            sObjectList = [SELECT Id FROM Opportunity WHERE IsClosed = FALSE];
        }
        if(this.objectType =='Lead'){
            sObjectList = [SELECT Id FROM Lead WHERE IsConverted = FALSE AND Status != 'Closed Lost'];
        }        
        return sObjectList;
    }
    
    global void execute(Database.BatchableContext bc,List<sObject> sObjectList) {
        update sObjectList;
    }

    global void finish(Database.BatchableContext bc) {
       
    }    
    
}