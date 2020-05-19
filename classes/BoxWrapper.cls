public class BoxWrapper {
    
    //Takes a list of Leads/Opps and creates appropriately named folders 
    //to store documents
    @future(callout=true)
    public static void createBoxFolders(List<Id> parentIDs, list<String> folderNames){
        
        System.debug('Creating Box folders: ' + parentIDs.size());
        
        Box_API_Setting__mdt settings = [SELECT Base_URL__c, Client_Id__c, Client_Secret__c, Enterprise_Id__c, Folder_Id__c, JWT_Public_Key_Id__c, JWT_Private_Key__c FROM Box_API_Setting__mdt LIMIT 1];  
        
        //API initialization
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setPublicKeyId(settings.JWT_Public_Key_Id__c);
        prefs.setPrivateKey(settings.JWT_Private_Key__c);
        BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(settings.Enterprise_Id__c, settings.Client_Id__c, settings.Client_Secret__c, prefs);
        
        //iterate through folders to be created
        for (Integer i = 0; i < parentIDs.size(); i++){
            createBoxFolder(api, folderNames[i], settings.Folder_Id__c, parentIDs[i]);
        }
        
    } 
    
    //Helper function to create a single Box Folder 
    //and write back the Folder Id to a Lead/Opp
    public static String createBoxFolder(BoxApiConnection api, String folderName, String parentFolderId, Id updateId){
        String newFolderId;
        
        //Get parent folder by Id
        BoxFolder docsFolder = new BoxFolder(api, parentFolderId);
        
        //Create the new folder
        BoxFolder.info newFolderInfo = docsFolder.createFolder(folderName);
        System.debug('Folder created');
        
        //System.debug('type: ' + newFolderInfo.getValue('type'));
        //System.debug('status: ' + newFolderInfo.getValue('status'));
        //System.debug('code: ' + newFolderInfo.getValue('code'));
        //System.debug('context_info: ' + newFolderInfo.getValue('context_info'));
        
        //check if the folder already exists
        if (newFolderInfo.getValue('code') == 'item_name_in_use'){
            //Find the Folder ID from the returned conflict JSON object
            String regexPattern = '\\{"conflicts"\\s:\\s\\[\\{"type"\\s:\\s"folder","id"\\s:\\s"(\\d{11})"';
            Pattern pat = Pattern.compile(regexPattern);
            Matcher match = pat.matcher(newFolderInfo.getValue('context_info'));

            if (match.find()){
                newFolderId = match.group(1);
            } else {
                System.debug('Regex (' + regexPattern + ') does not match string: ' + newFolderInfo.getValue('context_info'));
                return null;
            }
        } else {
            newFolderId = newFolderInfo.getValue('id');
        }
        
        //Write back Box Folder ID if requested
        if (updateId != null) {
            switch on String.valueOf(updateId.getSobjectType()) {
                when 'Lead' {
                    System.debug('Updating Lead with Box Folder Id');
                    Lead leadToUpdate = [SELECT Box_Folder_Id__c FROM Lead WHERE Id = :updateId];
                    leadToUpdate.Box_Folder_Id__c = newFolderId;
                    update leadToUpdate;
                }
                when 'Opportunity'{
                    System.debug('Updating Opportunity with Box Folder Id');
                    Opportunity oppToUpdate = [SELECT Box_Folder_Id__c FROM Opportunity WHERE Id = :updateId];
                    oppToUpdate.Box_Folder_Id__c = newFolderId;
                    update oppToUpdate;
                }
                when else {
                    System.debug('Unknown object type (' + String.valueOf(updateId.getSobjectType()) + ') found for id: ' + updateId);
                }
                
            }
        }
        return newFolderId;
    }
    
    @future(callout=true)
    public static void handleAttachments(List<Id> cvIds) {
        system.debug('******cvIds*******'+cvIds);
        
        Box_API_Setting__mdt settings = [SELECT Base_URL__c, Client_Id__c, Client_Secret__c, Enterprise_Id__c, Folder_Id__c, JWT_Public_Key_Id__c, JWT_Private_Key__c FROM Box_API_Setting__mdt LIMIT 1];  
        
        //API initialization
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setPublicKeyId(settings.JWT_Public_Key_Id__c);
        prefs.setPrivateKey(settings.JWT_Private_Key__c);
        BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(settings.Enterprise_Id__c, settings.Client_Id__c, settings.Client_Secret__c, prefs);
        system.debug('*****api******'+api);
        
        //Iterate through names and contents to upload each attachment to the designated folder        
        List<ContentVersion> cvs = [SELECT Id, ContentDocumentId, Title, FileExtension, VersionData, ContentSize FROM ContentVersion WHERE Id in :cvIds]; 
        system.debug('*******cvs******'+cvs);
        Set<Id> docids = new set<Id>();
        for (ContentVersion cv: cvs){
            docids.add(cv.ContentDocumentId);
        }
        system.debug('******docids*******'+docids);
        List<ContentDocumentLink> cdl = [select linkedentityid, ContentDocumentId from contentdocumentlink where contentdocumentid =: docids
                                         and linkedentityid in (select id from Document_MetaData__c)];
        system.debug('******cdl*******'+cdl);
        
        List<Document_MetaData__c> listDMD = new List<Document_MetaData__c>();
        List<Opportunity> listOpp = new List<Opportunity>();
        List<Lead> listLead = new List<Lead>();
        Map<Id, String> map_LeadOppId_FolderId = new Map<Id, String>();
        
        for (ContentVersion cv: cvs){
            
            System.debug('ContentDocumentId: ' + cv.ContentDocumentId);
            //List<ContentDocumentLink> docLinks = [SELECT Id, ContentDocumentId, LinkedEntity.type, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentID = :cv.ContentDocumentId];
            //List<ContentDocumentLink> docLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentID = :cv.ContentDocumentId];
            //ContentDocumentLink cdl = new ContentDocumentLink();
            
            Id dmdId = null; 
            /*for (ContentDocumentLink docLink: [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentID = :cv.ContentDocumentId]){
                if (String.valueOf(docLink.LinkedEntityId.getSobjectType()) == 'Document_MetaData__c') {
                    dmdId = docLink.LinkedEntityId;
                    break;
                }
            } */
            
            // made changes to get DMD id from the contentversion
            if(cdl != Null && cdl.size() > 0){
                for(contentdocumentlink c : cdl){
                    system.debug('*****c.LinkedEntityId*******'+c.LinkedEntityId+'*****objname*****'+String.valueOf(c.LinkedEntityId.getSobjectType()));
                    if(String.valueOf(c.LinkedEntityId.getSobjectType()) == 'Document_MetaData__c' && c.ContentDocumentId == cv.ContentDocumentId){
                        system.debug('*****objname inside*****'+String.valueOf(c.LinkedEntityId.getSobjectType()));
                        dmdId = c.LinkedEntityId;
                    }
                }               
            } 
            system.debug('******dmdId*******'+dmdId);
            if (dmdId == null) {
                System.debug('Cannot find DMD for CV: ' + cv.Id);
                continue;
            }            
            
            Document_MetaData__c dmd = [SELECT Requirement__r.Opportunity__r.Box_Folder_Id__c, Requirement__r.Lead__r.Box_Folder_Id__c, Opportunity__r.Box_Folder_Id__c, Lead__r.Box_Folder_Id__c, Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :dmdId LIMIT 1];
            
            //Check if the file is too large to upload and write back error messages to the DMD fields
            if (cv.ContentSize >= 12000000) {
                dmd.Box_File_URL__c = 'ERROR: file too large to upload automatically';
				
                listDMD.add(dmd);
                System.debug('Filesize too large (' + cv.ContentSize + ')');
                continue;
            }
            
            //Now that we have the DMD, we need to find the associated FolderID
            Id reqId = dmd.Requirement__c;
            Id oppId = dmd.Opportunity__c;
            Opportunity opp = null;
            Id leadId = dmd.Lead__c;
            Lead lead = null;
            String boxFolderId = null;
            Boolean oppNeedsFolder = false;
            Boolean leadNeedsFolder = false;

            //first look for the FolderID through the Requirement relationship if it exists
            if (reqId != null && (dmd.Requirement__r.Opportunity__c != null || dmd.Requirement__r.Lead__c != null)){
                if (dmd.Requirement__r.Opportunity__c != null){
                    //Found the associated Opp, now check if that Opp has a folder created yet
                    oppId = dmd.Requirement__r.Opportunity__c;
                    if (map_LeadOppId_FolderId.containsKey(oppId)){
                        boxFolderId = map_LeadOppId_FolderId.get(oppId);
                        oppNeedsFolder = false;
                    } 
                    else if (String.isBlank(dmd.Requirement__r.Opportunity__r.Box_Folder_Id__c)) {
                        oppNeedsFolder = true;
                    }
                    else {
                        boxFolderId = dmd.Requirement__r.Opportunity__r.Box_Folder_Id__c;
                        oppNeedsFolder = false;
                    }
                }
                else if (dmd.Requirement__r.Lead__c != null){
                    leadId = dmd.Requirement__r.Lead__c;
                    if (map_LeadOppId_FolderId.containsKey(leadId)){
                        boxFolderId = map_LeadOppId_FolderId.get(leadId);
                        leadNeedsFolder = false;
                    } 
                    else if (String.isBlank(dmd.Requirement__r.Lead__r.Box_Folder_Id__c)){
                        leadNeedsFolder = true;
                    }
                    else {
                        boxFolderId = dmd.Requirement__r.Lead__r.Box_Folder_Id__c;
                        leadNeedsFolder = false;
                    }
                }
            }
            //next check the Opportunity relationship
            else if (dmd.Opportunity__c != null) {
                oppId = dmd.Opportunity__c;
                if (map_LeadOppId_FolderId.containsKey(oppId)){
                    boxFolderId = map_LeadOppId_FolderId.get(oppId);
                    oppNeedsFolder = false;
                } 
                else if (String.isBlank(dmd.Opportunity__r.Box_Folder_Id__c)) {
                    oppNeedsFolder = true;
                }
                else {
                    boxFolderId = dmd.Opportunity__r.Box_Folder_Id__c;
                    oppNeedsFolder = false;
                }
            //then check the Lead relationship
            } else if (dmd.Lead__c != null){
                leadId = dmd.Lead__c;
                if (map_LeadOppId_FolderId.containsKey(leadId)){
                    boxFolderId = map_LeadOppId_FolderId.get(leadId);
                    leadNeedsFolder = false;
                } 
                else if (String.isBlank(dmd.Lead__r.Box_Folder_Id__c)) {
                    leadNeedsFolder = true;
                }
                else {
                    boxFolderId = dmd.Lead__r.Box_Folder_Id__c;
                    leadNeedsFolder = false;
                }
            //finally, give up
            } else {
                System.debug('No lead/opp found for DMD: ' + dmd.Id);
                continue;
            }
            
            if (oppNeedsFolder == true){
                opp = [SELECT Encompass_Loan_Number__c, Box_Folder_Id__c FROM Opportunity WHERE Id = :oppId];
                boxFolderId = createBoxFolder(api, opp.Encompass_Loan_Number__c, settings.Folder_Id__c, null);
            }
            if (leadNeedsFolder == true){
                lead = [SELECT Application_Tracking_ID__c, Box_Folder_Id__c FROM Lead WHERE Id = :leadId];
                boxFolderId = createBoxFolder(api, lead.Application_Tracking_ID__c, settings.Folder_Id__c, null);
            }  
            
            //By now, we have found the Folder ID, now time to upload the file. 
            System.debug('**********Box_folder_id******' + boxFolderId); 
            String fileExtension = cv.FileExtension;
            if (fileExtension == null) fileExtension = '';
            
            String fileName = cv.Title.removeEndIgnoreCase(fileExtension) + '_' + cv.Id + '_' + dmd.Id + '.' + fileExtension;
            Blob fileData = cv.VersionData;
            
            BoxFolder destinationFolder = new BoxFolder(api, boxFolderId);
            BoxFile.Info fileInfo = destinationFolder.uploadFile(fileData, fileName);
            system.debug('****fileInfo*****'+fileInfo);
            
            //Update fields in DMD
            String fileId = fileInfo.getValue('id');
            dmd.Box_Folder_Id__c = boxFolderId;
            dmd.Box_File_Id__c = fileId;
            dmd.Box_File_URL__c = settings.Base_URL__c + '/file/' + fileId;
            //update dmd;
            listDMD.add(dmd);
            
            if (oppNeedsFolder == true){
                opp.Box_Folder_Id__c = boxFolderId;
                //update opp;
                listOpp.add(opp);
                map_LeadOppId_FolderId.put(opp.Id, boxFolderId);
            }    
            if (leadNeedsFolder == true){
                lead.Box_Folder_Id__c = boxFolderId;
                //update lead;
                listLead.add(lead);
                map_LeadOppId_FolderId.put(lead.Id, boxFolderId);
            }
        }
        
        if(listOpp.size() > 0){
            update listOpp;
        }
        if(listLead.size() > 0){
            update listLead;
        }
        
        if(listDMD.size() > 0){
            update listDMD;
        }
        
        
    }

    /*
    //Get email for Service user, used for new service app authorizations
    public static void getEmailAlias(){
        //Http http = new Http();
        
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setPublicKeyId(publicKeyID_p);
        prefs.setPrivateKey(privateKey_p);
        BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(enterpriseID_p, clientID_p, clientSecret_p, prefs);
        
        BoxAPIRequest request = new BoxAPIRequest(api, 'https://api.box.com/2.0/users/me', 'GET');
        request.setTimeout(110000);
        
        HttpResponse resp = request.send();
        System.debug('HttpResponse: ' + resp.getBody());
        System.debug('HttpResponseAsText: ' + resp.toString());
    } */
    
    /* Deprecated in favor of handleAttachments(List<Id> cvIds)
    //Uploads every new file (that is uploaded to a DMD) to Box
    @future(callout=true)
    public static void handleAttachments(List<String> folderIds, List<String> fileNames, List<Blob> fileContents, List<Id> writebackIds, List<Id> oppIds) {
        
        //API initialization
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setPublicKeyId(publicKeyID);
        prefs.setPrivateKey(privateKey);
        BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(enterpriseID, clientID, clientSecret, prefs);
        
        //Iterate through names and contents to upload each attachment to the designated folder
        for (Integer i = 0; i < fileNames.size(); i++){
            if(String.isBlank(folderIds[i])){
                continue;
            }
            BoxFolder destinationFolder = new BoxFolder(api, folderIds[i]);
            BoxFile.Info fileInfo = destinationFolder.uploadFile(fileContents[i], fileNames[i]);
            
            //Write back file details to the DMD
            if (writebackIds[i] != null){
                //TODO check id for type?
                String fileId = fileInfo.getValue('id');
                Document_MetaData__c dmd = [SELECT Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :writebackIds[i]];
                dmd.Box_Folder_Id__c = folderIds[i];
                dmd.Box_File_Id__c = fileId;
                dmd.Box_File_URL__c = baseUrl + '/file/' + fileId;
                update dmd;
            }
        }
    }
    */
    
    //Partial implementation for creating attachments from Box Files
    //Ended up getting scrapped, but may be useful down the road
 /*   @future(callout=true)
    public static void downloadBoxFileToAttachment(String boxFileId, Id leadId){
        Http http = new Http();
        
        //API initialization
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setPublicKeyId(publicKeyID);
        prefs.setPrivateKey(privateKey);
        BoxPlatrmApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(enterpriseID, clientID, clientSecret, prefs);
        
        BoxFile file = new BoxFile(api, boxFileId);
        BoxFile.Info fileInfo = file.getFileInfo();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://dl.boxcloud.com/d/1/b1!qG2XPvbAa3MxgIk61ZXC5Nb-DpFGntqFjwCxAHNREItZo1p3Tlfs2Aj9YqDfFDQdwrMde49s0Ql-UBH2ioemQaExxvEMzG89eqn-m06xUatn-2YjMDxP1LEpd4VhKv9vIhbD9fJWug3V1qXk3GLGeFpu2ZMuNWwU2t3YoXhNucxmi1sF5CdqEK6lsvrYFCeCigTuItVpjDTdka7QPSEdgFZjk1rAq7IwaU85NxNSNbZ7-izUM1THaJU7nCyoG3oIRfwmjCWtyB8DtqnLHGoR7BnfJ0eIt4OsIDYs_JaMY1snJYDHOvIeQ1DT6tOU5pkH7Qlvn7uFggLeLdd3DhqlXXk1IbHWJHdXMi7xO0jvjQS0XYQpBtGWUoZtuPvVjGRJ7M9NzqI9pqj5j2O_0dgthXoCf1LVzMwZaQ_xlONSGoj5c4BX78oN5Ld_zWwNKDm7ZkO4GnPFvbuB9gxBTZ5ov82ZTPnlF6N6DeWUI66tXNbxKtImWE23tSw69VHpIR3CyxrQp9juLbsd6lU2OcFWJv_ztW9d9XjmhBK9ce08I-We8GNbJZjZfamD3ZXc5cXrpDWgNgpfygjYjYofnicE7FISoH6rt3NQtCzyBEqnnF9AK2_MulGcNAbzw_etTnGIyE-lIRZD-V51dckgG8w3uDXxTyxfEXHroZkkUQFYNaJHGTY8ebKssjAEDxLycpsnlVnk1CDTyrQ91M_HTlkM1ouOVlef6UTWKaTpmNUNpdQTqtsW7vyajdXsnV2DqTq-M6xZ7UpJfFEMAldWxpw8_tJFVNgWkmRgkgrVMrWXcqL-dSsy78TsPOurPC41w7jTY33m0Mbk19GoWXozdTS081ceZ6-OitJdk1e9vVd3bzYY47a3b3E2mOznxKxczZ3ouAPU8_2uHhnASUn0i89praaC6uXqamKhUyyeV7qm4pxjdwZILV3ra4XWPskOaG-ZG9FBP8KCnMSnkNLliZJefd7na4qlBfu5z_VGikOBDLlsqNSpm0QbQ7Mej9xzJgJOs1gwXEJV-IZ6pmKWx4g4D7p1LFgavELLXuvVMkD-eZ6t2DlF7Yj0xbPq8o9NEQ0Nk8D3i_SGl4W5UiW04jL8Pq81NvoYQzJ262XwfkXcs_4Fcd7gnu8x-1kZKp-jeoK-ZMcOiBgMoLQ_h5xKdexqk-UHpZba4jInvJseXAn2jxrlPNRpexur_vVix4D8eA2U8BEKXBG8SLUCKFg4j17mhZdtLpqVp3ld54DkfpYekNg6ketAYwH0pZq9nMbbRw8JUqNoVw../download');
        req.setMethod('GET');
        
        HttpResponse resp = http.send(req);
        System.debug('HttpResponse: ' + resp.getBody());
        
    }*/
}