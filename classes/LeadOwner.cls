global class LeadOwner implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC){      
//Sundar Subramaniam 03/27/2019 - change in the criteria with respect to HB Lead Status Update Project - CM-50  
      // return Database.getQueryLocator('select Id,OwnerId,Status FROM Lead where Owner.Name = \'Daily Dialer Queue\' and Status IN (\'closed lost\', \'Credit Qualified\', \'Guideline Qualified\', \'Application Sent\', \'Application Received\', \'Documents In\')');
  return Database.getQueryLocator('select Id,OwnerId,Status FROM Lead where Owner.Name = \'Daily Dialer Queue\' and Status IN (\'closed lost\', \'Credit Qualified\', \'Pre Discovery\', \'Discovery\', \'Guideline Qualified\', \'Pending Lender Approval\', \'Lender Approved / Shopping\', \'Application Sent\', \'Application Received\', \'Documents In\', \'Pending Submission\')');
  }
  

    global void execute(Database.BatchableContext BC, List<Lead> scope){
       
       Group jumbballqueue = [Select Id from Group where DeveloperName = 'Jump_Ball' and Type = 'Queue' Limit 1];
       Auto_Lead_OwnerId__mdt userid = [select UserId__c from Auto_Lead_OwnerId__mdt limit 1];
       
       List<Lead> leadList = new List<Lead>();  
       for(Lead l: scope){
           if(l.Status != Null && l.Status != 'Closed Lost' && jumbballqueue != Null && jumbballqueue.Id != Null){
               l.OwnerId = jumbballqueue.Id;
               leadList.add(l);
           } else if(l.Status != Null && l.Status == 'Closed Lost' && userid != Null && userid.UserId__c!= Null) {
                 l.OwnerId = userid.UserId__c;
                 leadList.add(l);
           }
       }
       if(leadList.size() > 0) {
           update leadList;
       }
    } 
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Lead owner update BatchJob' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    }
   
    global void execute(SchedulableContext sc) {
        LeadOwner b = new LeadOwner();
        database.executebatch(b);
        

    }    
}