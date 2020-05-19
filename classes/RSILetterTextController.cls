/*************************************
    Owner :- Unison
    Developer:- Sundar Subramaniam
    Created Date:- 04/26/2019
    Modified Date:- 
     Description:-This class is as a controller for RequirementListOfOpportunity Page
*************************************/
public class RSILetterTextController {
    // Declaration for StandardController fields
    public string opportunityid{get;set;}
    public List<Current_Conditions__c> todisplay{get;set;}
    public Boolean errorhasoccured{get;set;}
    public string errormessage{get;set;}
    public Opportunity mainopportunity{get;set;}
    public RSILetterTextController()
    {
        errorhasoccured=false;
        errormessage = '';
        //Retreiving id passed by parameter
        opportunityid = Apexpages.currentPage().getParameters().get('Id');
        //Retreiving the Opportunity to check RSI Count
        mainopportunity = [select id,RSI_Count__c,Name from Opportunity where id =:opportunityid ];
        todisplay = new List<Current_Conditions__c>();
        //Retreiving the all the Requirements with the neccasary conditions
        todisplay = [select id,Name,RSI_Letter_Text_Insert__c,Requirement__c from Current_Conditions__c where Opportunity__c =:opportunityid AND Status__c= 'Document Received, In progress' AND RSI_Eligible__c = TRUE];
        system.debug('todisplay==>'+todisplay);
    }
    //Function to update the Requirements and the task
    public void updaterequirements()
    {
        Set<String> requirementids = new Set<String>();
        List<Project_Task__c> listoftasks = new List<Project_Task__c>();
        errorhasoccured=true;
        errormessage = '';
        Project_Tasks_Vs_Task_Codes__mdt metadata = [select Task_Code__c,Label from Project_Tasks_Vs_Task_Codes__mdt where Label = 'Send RSI Letter'];
        for(Current_Conditions__c obj:todisplay)
        {
            requirementids.add(obj.id);
            //Condition to check if all the RSI Letter Text Insert is entered.
            if(obj.RSI_Letter_Text_Insert__c == null || obj.RSI_Letter_Text_Insert__c == '')
            {
                errormessage = 'One or more RSI Eligible Requirement reasons has not been populated.';
                system.debug('Error on==>'+obj);
                //errorhasoccured=TRUE;
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'One or more RSI Eligible Requirement reasons has not been populated.'));                
                return;
            }
        }
        //Update Requirements
        system.debug('todisplay==>'+todisplay);
        errorhasoccured=false;
        update todisplay;
        //Update 'Notify file is ready for RSI' Task to completed
        List<Project_Task__c> projectlist = [select id,Requirement__c from Project_Task__c where Requirement__c in:requirementids AND completed__c = FALSE AND Code__c = 'Task-380' AND Name = 'Notify file is ready for RSI'];
        if(projectlist.size()>0)
        {
            for(Project_Task__c obj:projectlist)
            {
                obj.completed__c = true;
                Project_Task__c newTask = new Project_Task__c();
                newTask.Name = metadata.Label;
                newTask.Requirement__c = obj.Requirement__c;
                newTask.Code__c = metadata.Task_Code__c;
                listoftasks.add(newTask);
            }
            update projectlist;
            insert listoftasks;
             
        }
    }
}