global class ProjectTaskStatusUpdate implements Database.Batchable<sObject> {   
    
    global List <String> codes = new List <String> {'T10011','T10009','T10201','T10017','T10080','T10092','T10157','T10172','T10180','T10013','T10186','T10015','T10190','T10104'};
    global List <String> stages = new List <String> {'Funded Won', 'Closed Won', 'Post-Closing', 'Closed Lost'};
    global String idt = 'a4wP00000005H9A';
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'select Completed__c, Status__c, requirement__r.Status__c, Code__c, Prevent_Rollback_from_Complete__c from Project_Task__c where Status__c = null and opportunity__r.stagename not in :stages';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List <Project_Task__c> tasks) {
        
        for (Project_Task__c task: tasks){
            
            if(codes.contains(task.Code__c)){
                task.Prevent_Rollback_from_Complete__c = true;
            }
    
            if(task.Requirement__r.Status__c == 'Waived'){
                task.Status__c = 'Waived';
            }
            else if (task.Completed__c){        
                task.Status__c = 'Completed';
            }
            else{        
                task.Status__c = 'In Progress';
            }
            System.debug(task);
        }
        
        update tasks;
    }

    global void finish(Database.BatchableContext bc) {
       
    }    
    
}