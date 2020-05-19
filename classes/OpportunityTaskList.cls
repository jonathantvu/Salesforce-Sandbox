public class OpportunityTaskList 



{
    private ApexPages.StandardController std;
     
    public String message{get;set;}
     
    // the associated dox
   public List<Project_Task__c> ptask {get; set;}
    
    public OpportunityTaskList (ApexPages.StandardController stdCtrl)
    {
     std=stdCtrl;
     ptask=[ select id, Name, Status__c //Completed__c /*<--Caro Veliz: BUS-155110073*/
             from  Project_Task__c
             where Opportunity__c=:std.getId() 
             AND Opportunity_Stage__c ='Investment Due Diligence'
             //AND Completed__c = false /*<--Caro Veliz: BUS-155110073*/
             AND Status__c = 'In Progress'
             order by Name];
    }
 
    public PageReference save()
    {
     // first save the account
     std.save();
      
     // then save the contacts
     update ptask;
      
     PageReference result=ApexPages.currentPage();
     result.setRedirect(true);
      
     return result;
    }
     
}