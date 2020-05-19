/**************************************************************************************************
Purpose of the Trigger :To accomodate Auto Completion of Tasks Related to Document Metadata Whenever a
Document has been uploaded and Document_Upload_Needed__c checkbox is marked True on the Project Tasks.
Created Dated : 12/04/2018 
Author : Neeraja Cherukuri
**************************************************************************************************/

trigger DMDTrigger on Document_MetaData__c (before insert, after insert, before update, after update) {
    if (Trigger.isBefore && Trigger.isInsert){
        DMDTriggerHandler.handleBeforeInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isInsert){
        DMDTriggerHandler.handleAfterInsert(Trigger.New);
    }else if (Trigger.isAfter && Trigger.isUpdate){
        System.debug('====on after update DMD===');
        DMDTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.OldMap);
    }else if(Trigger.isBefore && Trigger.isUpdate){
        DMDTriggerHandler.handlebeforeUpdate(Trigger.newMap, Trigger.OldMap);
    }
    
    // Send update to AWS, but not doing this right now
    if (Trigger.isAfter && Trigger.isUpdate) {
        System.debug('====on after update DMD 22===');

        List<Document_MetaData__c> dmds = new List<Document_MetaData__c>();
            for (Document_MetaData__c dmd: Trigger.new) {
                Document_MetaData__c oldDmd = Trigger.oldMap.get(dmd.Id);
                system.debug(dmd.Box_File_URL__c);
                if (string.isBlank(dmd.Box_File_URL__c) || dmd.Box_File_URL__c.contains('Upload in progress')) {
                    dmds.add(dmd);
                }
            }

        //UnisonAPI.SendDocumentUpsert(Trigger.new);
        system.debug(dmds);
        UnisonAPI.SendDocumentUpsert(dmds);
    }
}