/**
 *  About
 *  -----
 *  Author: Cloud Mine Consulting
 *  Create date: 9/29/2017
 *  
 *  Details
 *  -----
 *  Schedulable class for Lead Touch Batch
 *  
 *  Update History
 *  -----
 * 
 *  Issues / TODOs
 *  -----
 * 
**/
global class Schedule_LeadTouch_Batch implements schedulable {

    global void execute(system.SchedulableContext sc){
        OpportunityTouch_Batch batch = new OpportunityTouch_Batch('Lead');
        database.executeBatch(batch);
    }
    
}