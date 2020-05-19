/************************************************************************************
 Apex Class Name     :  DMDTriggerHandler
 Version             : 1.0
 Created Date        : 4th Dec 2018
 Function            : To accomodate Auto Completion of Tasks Related to Document Metadata whenever a
                        Document has been uploaded and Document_Upload_Needed__c checkbox is marked True on the Project Tasks.
 Author              : Neeraja Cherukuri
 
 Modification Log    :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Neeraja Cherukuri            12/04/2018                Original Version
*************************************************************************************
*/


public class DMDTriggerHandler {

    //Constants 
    
    public static void handleBeforeInsert(List<Document_MetaData__c> newList){
        
        
        
    }
    
    public static void handleAfterInsert(List<Document_MetaData__c> lstDMDs)
    {
        
     
    }
    /*
    private static void UpdateUploadedOnRequirement(List<id> lstReqUploadedIds)
    {
        ID IDHomeBuyer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ID IDHomeOwner = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

        //Ticket: https://unison-technology.atlassian.net/browse/BUS-155109402

        List<current_conditions__c> lstReqs = [ select id, name, lead__c,
                                            lead__r.name, lead__r.status,
                                            lead__r.RecordTypeId, Uploaded__c
                                            from current_conditions__c
                                            where
                                            (id in :lstReqUploadedIds) and
                                            ((lead__r.RecordTypeId = :IDHomeOwner and lead__r.status = 'Application Received') or
                                            (lead__r.RecordTypeId = :IDHomeBuyer and lead__r.status = 'Pending Submission'))
                                            ];

        for (current_conditions__c cc: lstReqs)
        {
            cc.Uploaded__c = true;
        }

        update lstReqs;
    }*/

    public static void handleAfterUpdate(List<Document_MetaData__c> newList, Map<Id, Document_MetaData__c> oldMap)
    {
        
        List<Id> lstReqIds = new List<Id>();
        List<Id> lstReqUploadedIds = new List<Id>();
        List<Project_Task__c> lstPTForUpdate = new List<Project_Task__c>();
        
        for(Document_MetaData__c objDMD : newList)
        
        {
            if((objDMD.Requirement__c != null && objDMD.Box_Folder_Id__c != null && objDMD.Box_File_URL__c != null) &&
               (oldMap.get(objDMD.Id).Box_Folder_Id__c != objDMD.Box_Folder_Id__c  || 
               oldMap.get(objDMD.Id).Box_File_URL__c != objDMD.Box_File_URL__c   || 
               oldMap.get(objDMD.Id).Box_File_Id__c != objDMD.Box_File_Id__c)  ) 
            {
                lstReqIds.add(objDMD.Requirement__c);
            }
            if(objDMD.Uploaded__c == true)
                lstReqUploadedIds.add(objDMD.Requirement__c);
        }
        
        for(Project_Task__c objProjTask : [SELECT Id,Requirement__c FROM Project_Task__c WHERE Requirement__c IN: lstReqIds and Document_Upload_Needed__c = true])
        {
              //Project_Task__c objPT = new Project_Task__c(Id= objProjTask);
              //objProjTask.Completed__c = true;
              objProjTask.Status__c = 'Completed';
              objProjTask.Complete_By_User__c = UserInfo.getUserId();
              objProjTask.Completed_Date_Time_Stamp__c = System.now();
            // objProjTask.Requirement__c 
          
              
              lstPTForUpdate.add(objProjTask);    
        }
        
        if(!lstPTForUpdate.isEmpty())
        {
            try
            {
                update lstPTForUpdate;    
            }
            catch(Exception ex)
            {
               System.debug('=====Exception on update== '+ex.getStackTraceString());
            }
            
        } 
        
        System.debug('===='+lstReqIds.size());
   /*     if(lstReqIds.size() == 0 )
        {
            List<Id> lstPTIds = new List<Id>();
            List<Document_MetaData__c> lstValidDMDs = new List<Document_MetaData__c>();
            Map<String, String> mapDMDCode_ProjectCode = new Map<String, String>();
            Map<String,String> DMD_mdt = new Map<String,String>();
        //    List<Project_Task__c> lstPTForUpdate = new List<Project_Task__c>();
            Map<Id, Id> mapDMDId_ProjectTaskId = new Map<Id, Id>();
            Map<Id, Project_Task__c> mapPTId_ProjectTask = new Map<Id, Project_Task__c>(); 
            
            for(Document_MetaData__c objDMD : newList)
            {
                if(oldMap.get(objDMD.Id).Box_Folder_Id__c != objDMD.Box_Folder_Id__c  || oldMap.get(objDMD.Id).Box_File_URL__c != objDMD.Box_File_URL__c   || oldMap.get(objDMD.Id).Box_File_Id__c != objDMD.Box_File_Id__c  )
                {
                    if(objDMD.Box_File_Id__c != null 
                            && objDMD.Box_File_URL__c != null 
                            && objDMD.Box_Folder_Id__c != null 
                            && objDMD.Document_Code__c != null
                            && objDMD.ProjectTask__c != null)
                        
                            lstPTIds.add(objDMD.ProjectTask__c); 
                            lstValidDMDs.add(objDMD);   
                }
            }
            System.debug('====lstPTIds==='+lstPTIds);
            if(lstPTIds.size() > 0 )
            {
                for(Project_Task__c objPT : [SELECT Id,DMD__c,DMD__r.Document_Code__c ,Code__c FROM Project_Task__c WHERE Id IN : lstPTIds])
                {
                    
                    if(objPT.Code__c != null && objPT.DMD__r.Document_Code__c != null)
                       // mapProjectCode_DMDCode.put(objPT.Code__c, objPT.DMD__r.Document_Code__c); 
                        mapDMDCode_ProjectCode.put(objPT.DMD__r.Document_Code__c, objPT.Code__c); 
                        mapPTId_ProjectTask.put(objPT.Id, objPT);
                        mapDMDId_ProjectTaskId.put(objPT.DMD__c, objPT.Id);  
                }
            }
            for(DMD_Complete_Project_Task__mdt objDMD_mdt : [SELECT Document_Code__c, Projet_Code__c FROM DMD_Complete_Project_Task__mdt])
            {
                DMD_mdt.put(objDMD_mdt.Document_Code__c, objDMD_mdt.Projet_Code__c);
            }
                      
            Project_Task__c objPT = new Project_Task__c();
            for(Document_MetaData__c objDMD : lstValidDMDs)
            {
                if(objDMD.Box_File_Id__c != null && objDMD.Box_File_URL__c != null && objDMD.Box_Folder_Id__c != null && objDMD.Document_Code__c != null)
                {
                    if(DMD_mdt.containsKey(objDMD.Document_Code__c) 
                                && mapDMDCode_ProjectCode.containsKey(objDMD.Document_Code__c))
                    {
                        if(DMD_mdt.get(objDMD.Document_Code__c).equalsIgnoreCase(mapDMDCode_ProjectCode.get(objDMD.Document_Code__c)))
                        {
                            objPT = new Project_Task__c(Id=mapDMDId_ProjectTaskId.get(objDMD.Id)); 
                            objPT.Completed__c = true;
                            objPT.Complete_By_User__c = UserInfo.getUserId();
                            objPT.Completed_Date_Time_Stamp__c = System.now();
                            
                            lstPTForUpdate.add(objPT);          
                        }
                    }   
            }
            System.debug('======lstPTForUpdate====='+lstPTForUpdate);
            if(!lstPTForUpdate.isEmpty())
            {
               //Update lstPTForUpdate;
            }
        }         
    }*/

        //Caro Veliz: Commented temporaly while we fix antoher problem
        //UpdateUploadedOnRequirement(lstReqUploadedIds);

    }  
    
    public static void handlebeforeUpdate(Map<Id, Document_MetaData__c> newMap, Map<Id, Document_MetaData__c> oldMap){
        
    }
}