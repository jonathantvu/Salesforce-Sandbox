/**
 * Created by Eliot Rojas on 5/1/2019.
 */

public with sharing class ProjectTasksTriggerHandler {

    public static void handleAfterInsert(List<Project_Task__c> newList) {
        //ProjectTasksDocumentNotification.notifyPS(newList);
    }
    
    public static void handleAfterUpdate(List<Project_Task__c> newList, Map<Id, Project_Task__c> oldMap) {
        //ProjectTasksDocumentNotification.notifyPS(newList, oldMap);
        List<Project_Task__c> projectTasksToProcess = new List<Project_Task__c>();
        for(Project_Task__c pTask : newList) {
    	    /*Caro Veliz: BUS-155110073*/
            //if(pTask.Completed__c != oldMap.get(pTask.Id).Completed__c && pTask.Completed__c) {
            if(pTask.Status__c != oldMap.get(pTask.Id).Status__c && pTask.Status__c == 'Completed') {
                projectTasksToProcess.add(pTask);
            }
        }
        UnisonMasterNotifications.ManageNotificationsForProjectTasks(projectTasksToProcess);
    }
}