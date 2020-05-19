trigger BoxLeadTrigger on Lead (before update) {
    //Prevent recursive future calls
    if(System.isFuture()) return;
    
    //Initialize lists which will eventually be passed to the BoxWrapper @future methods
    List<Id> parentIds = new List<Id>();
    List<String> folderNames = new List<String>();
    List<Id> leadsToUpload = new List<Id>();
    
    System.debug('Starting BoxLeadTrigger');
    for (Lead lead: Trigger.new){
        Lead oldLead = Trigger.oldMap.get(lead.Id);
        
        //check if the manual override checkbox was selected
        Boolean manualOverride = false;
        if (lead.Create_Box_Folder__c && !oldLead.Create_Box_Folder__c){
            System.debug('Create_Box_Folder checkbox selected');
            
            manualOverride = true;
            
            //clear value in case an error had previously occurred
            lead.Box_Folder_Id__c = '';
        }
        
        System.debug('Lead status: ' + lead.Status + ' | OldLead status: ' + oldLead.Status);
        
        //check if lead is transitioning to 'Application Received' status
        if (manualOverride || (lead.Status == 'Application Received' && oldLead.Status <> 'Application Received')) {
            System.debug('FRX: ' + lead.Application_Tracking_ID__c);
            System.debug('Box Folder: ' + lead.Box_Folder_Id__c);
            //ensure that the lead has a FRX# and make sure it does not already have a folder
            if (!String.isBlank(lead.Application_Tracking_ID__c) && (String.isBlank(lead.Box_Folder_Id__c))){
                //put placeholder for Box Folder Id to ensure a folder only gets created once
                lead.Box_Folder_Id__c = 'Creating...';
                
                //add Lead ID and FRX# to respective lists
                parentIds.add(lead.Id);
                folderNames.add(lead.Application_Tracking_ID__c);
            }
        }
        
        //Manual process to upload files directly attached to a lead
        if (lead.Upload_Files_to_Box__c && !oldLead.Upload_Files_to_Box__c) {
            leadsToUpload.add(lead.Id);
            //lead.Upload_Files_to_Box__c = false;
        }

        /* Dropped requirement: converting Box files to Attachments when Quality Control is passed
        if (lead.Quality_Control_Info_Needed__c <> oldLead.Quality_Control_Info_Needed__c){
            System.debug('QC passed');
            //Find all DMDs
            List<Current_Conditions__c> reqList = [SELECT Id FROM Current_Conditions__c WHERE Lead__c = :lead.Id];
            List<Document_MetaData__c> dmdList = [SELECT Id, Box_File_Id__c FROM Document_MetaData__c WHERE Requirement__c in :reqList OR Lead__c = :lead.Id];
            
            //Mark as tentatively downloaded?
            
            //Future method for each file
            //  download file
            //  create attachment
            //  copy file to attachment body
            //  upadate attachment
            //  update DMD with download completed
            for(Document_MetaData__c dmd: dmdList){
                if (! String.isBlank(dmd.Box_File_Id__c)){
                    BoxWrapper.downloadBoxFileToAttachment(dmd.Box_File_Id__c, lead.Id);
                }
            }
        }
		*/
    }
    
    if (leadsToUpload.size() > 0) {
        Map<Id, List<ContentDocumentLink>> map_Lead_CDL = new Map<Id, List<ContentDocumentLink>>();
        List<ContentDocumentLink> listCDLsExisting = new List<ContentDocumentLink>();
        Set<Id> set_CD = new Set<Id>();
       	Map<Id, ContentDocument> map_CD = new Map<Id, ContentDocument>();
        List<Document_MetaData__c> listDMDsToInsert = new List<Document_MetaData__c>();
        List<Id> listCDIds = new List<Id>();
        List<ContentDocumentLink> listCDLsToInsert = new List<ContentDocumentLink>();
        
		// Create ContentDocuments from Attachments
        List<ContentVersion> listCVsToInsert = new List<ContentVersion>();
        //List<Id> listCVIds = new List<Id>();
        Map<Id, Id> map_cv_parent = new Map<Id, Id>();
		List<Attachment> listAttachments = [SELECT Id, Name, Body, ContentType, ParentId, OwnerId From Attachment WHERE ParentId in :leadsToUpload];
        for (Attachment attach : listAttachments ){
            ContentVersion objCV = new ContentVersion();
            objCV.ContentLocation = 'S'; 
			objCV.PathOnClient = attach.Name;
            objCV.OwnerId = attach.OwnerId;
            //objCV.firstPublishLocationId = attach.ParentId;
            objCV.Title = attach.Name;
            objCV.VersionData = attach.Body;
            
            Document_MetaData__c objDMD = new Document_MetaData__c();
            objDMD.Lead__c = attach.ParentId;
            objDMD.Document_Description__c = attach.Name;
            
            listDMDsToInsert.add(objDMD);
            listCVsToInsert.add(objCV);
        }
        //Insert CVs and create CDLs
        if (listCVsToInsert.size() > 0){
            insert listDMDsToInsert;
            
            for (Integer i = 0; i < listDMDsToInsert.size(); i++) {
                listCVsToInsert[i].firstPublishLocationId = listDMDsToInsert[i].id;
            }
            
            insert listCVsToInsert;
            
            /*for (Integer i = 0; i < listCVsToInsert.size(); i++) {
                map_cv_parent.put(listCVsToInsert[i].id, listAttachments[i].ParentId);
            }
            
            Set<Id> setCVIds = (new Map<Id, ContentVersion>(listCVsToInsert)).keySet();
            for (ContentVersion objCV : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id in :setCVIds]){
            	set_CD.add(objCV.ContentDocumentId);
                
                Id leadId = map_cv_parent.get(objCV.Id);
                
                ContentDocumentLink objCDL = new ContentDocumentLink();
                objCDL.ContentDocumentId = objCV.ContentDocumentId;
                objCDL.LinkedEntityId = leadId;
                
                listCDLsExisting.add(objCDL);
            }*/
            
            listDMDsToInsert.clear();
        }
        
        listCDLsExisting.addAll([SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :leadsToUpload]);
        
        //Get CDLs attached (and the associated filenames)
        for (ContentDocumentLink objCDL : listCDLsExisting){
            if (!map_Lead_CDL.containsKey(objCDL.LinkedEntityId)) {
                // if not, create the map entry with the first CDL
                map_Lead_CDL.put(objCDL.LinkedEntityId, new List<ContentDocumentLink> {objCDL});
            }
            else {
                // otherwise pull the current list,
                List<ContentDocumentLink> lstCDL = map_Lead_CDL.get(objCDL.LinkedEntityId);
                // add this CDL,
                lstCDL.add(objCDL);
                // and put the list back
                map_Lead_CDL.put(objCDL.LinkedEntityId, lstCDL);
            }
            
            set_CD.add(objCDL.ContentDocumentId);
        }
        
        map_CD.putAll([SELECT Id, Title, FileExtension, FileType FROM ContentDocument WHERE Id IN :set_CD]);
        
        /*for (ContentDocument objDoc : [SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN :set_CD]){
            map_CD.put(objDoc.Id, objDoc);
        }*/
        
        //create a list of DMDs to insert
        for (Id leadId : leadsToUpload){
            if (!map_Lead_CDL.containsKey(leadId) || map_Lead_CDL.get(leadId).size() == 0){
                continue;
            }
            for (ContentDocumentLink objCDL : map_Lead_CDL.get(leadId)){
                ContentDocument objDoc = map_CD.get(objCDL.ContentDocumentId);

                if (objDoc.FileType == 'SNOTE') {
					// this CD is a Note instead of File
					continue;                    
                }
                
                Document_MetaData__c objDMD = new Document_MetaData__c();
                objDMD.Lead__c = leadId;
                objDMD.Document_Description__c = objDoc.Title;
                
                listDMDsToInsert.add(objDMD);
                listCDIds.add(objCDL.ContentDocumentId);
            }
        }
        
        //insert DMDs
        if (listDMDsToInsert.size() > 0){
        	insert listDMDsToInsert;    
        }
        
        //create a list of CDLs to insert
        for (Integer i = 0; i < listDMDsToInsert.size(); i++){
            Document_MetaData__c objDMD = listDMDsToInsert[i];
            ContentDocumentLink objCDL = new ContentDocumentLink();
            objCDL.ContentDocumentId = listCDIds[i];
            objCDL.LinkedEntityId = objDMD.Id;
            objCDL.ShareType = 'V';
            listCDLsToInsert.add(objCDL);
        }
        
        //insert CDLs (which triggers upload to Box)
        if (listCDLsToInsert.size() > 0){
            insert listCDLsToInsert;
        }
    }
    
    if (parentIds.size() > 0){
        //create Box folders for all leads listed
        BoxWrapper.createBoxFolders(parentIds, folderNames);
    }
}