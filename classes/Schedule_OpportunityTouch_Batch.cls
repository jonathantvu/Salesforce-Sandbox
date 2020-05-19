/**
 *  About
 *  -----
 *  Author: Cloud Mine Consulting
 *  Create date: 9/7/2017
 *  
 *  Details
 *  -----
 *  Schedulable class for Opportunity Touch Batch
 *  
 *  Update History
 *  -----
 * 
 *  Issues / TODOs
 *  -----
 * 
**/
global class Schedule_OpportunityTouch_Batch implements schedulable {

    global void execute(system.SchedulableContext sc){
        OpportunityTouch_Batch batch = new OpportunityTouch_Batch('Opportunity');
        database.executeBatch(batch);
    }
    
}