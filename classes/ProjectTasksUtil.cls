/************************************************************************************
 Apex Class Name     : ProjectTasksUtil
 Version             : 1.0
 Created Date        : 13th MAY 2019
 Function            : 
 Author              : Neeraja Cherukuri
 
 Modification Log    :

* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Neeraja Cherukuri            13/05/2019               Original Version
*************************************************************************************
*/
public class ProjectTasksUtil
{
	public static Project_Task__c createProjectTasks(String projectTaskName, String projectTaskCode, Id OptyId, Id reqId, Id assignedTo, Boolean preventRollbackFromComplete)
    {
    	Project_Task__c ptask = new Project_Task__c();  
        ptask.Name                = projectTaskName;
        ptask.Code__c             = projectTaskCode;
        ptask.Opportunity__c      = OptyId;
        ptask.Requirement__c      = reqId;
        ptask.Assigned_To__c      = assignedTo; 
        ptask.Prevent_Rollback_from_Complete__c = preventRollbackFromComplete; /*Caro Veliz: BUS-155110073*/

        return ptask;  
    }
}