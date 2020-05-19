/**
 * Created by Eliot Rojas on 5/22/2019.
 */

public with sharing class BoxAttachmentRetrievalQueueable implements Queueable, Database.AllowsCallouts {
    public static Map<Id, List<Attachment>> leadFilesMap = new Map<Id, List<Attachment>>();
    public static Box_API_Setting__mdt settings = new Box_API_Setting__mdt();
    public Map<Id, Lead> leadMap;

    public BoxAttachmentRetrievalQueueable(Map<Id, Lead> leadMap) {
        this.leadMap = leadMap;
    }

    public void execute(QueueableContext context) {
        try {
            // Get Box API Settings
            settings = getBoxAPISettings();
            // Make API call to get file information and their contents
            for(Document_MetaData__c documentMetaData : [SELECT Id, Lead__c, Box_File_Id__c, Box_Folder_Id__c, Box_File_URL__c
            FROM Document_MetaData__c WHERE Lead__c IN : leadMap.keySet()
            AND Box_File_Id__c != null]) {
                if(leadMap.get(documentMetaData.Lead__c).Id != null) {
                    getAttachments(documentMetaData.Box_File_Id__c, leadMap.get(documentMetaData.Lead__c).Id);
                }
            }
            system.debug('++ leadFilesMap: ' + leadFilesMap);

            // Insert Attachment records
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            for(String leadId : leadFilesMap.keySet()) {
                if(leadFilesMap.get(leadId).isEmpty() != true) {
                    for(Attachment att : leadFilesMap.get(leadId)) {
                        attachmentsToInsert.add(att);
                    }
                }
            }
            // Insert Attachment records
            if(!attachmentsToInsert.isEmpty()) {
                insert attachmentsToInsert;
            }
         } catch (Exception ex) {
            System.debug('Error Message: ' + ex.getMessage() + ' \nLine: ' + ex.getLineNumber() + ' \nStack: ' + ex.getStackTraceString());
        }
    }

    public static void getAttachments(String boxFileId, Id leadId) {
        Http http = new Http();

        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setPublicKeyId(settings.JWT_Public_Key_Id__c);
        prefs.setPrivateKey(settings.JWT_Private_Key__c);
        BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(settings.Enterprise_Id__c, settings.Client_Id__c, settings.Client_Secret__c, prefs);

        //Get file info, including filename which can be used to create an Attachment
        BoxFile file = new BoxFile(api, boxFileId);
        BoxFile.Info fileInfo = file.getFileInfo();
        system.debug('++ File: ' + fileInfo);


        HttpResponse response = new HttpResponse();

        //Making callouts is not allowd in Tests
        if(!System.Test.isRunningTest()) {
            //Get link to download
            String requestURL = 'https://api.box.com/2.0/files/' + boxFileId + '/content';
            BoxAPIRequest request = new BoxAPIRequest(api, requestURL, BoxApiRequest.METHOD_GET);
            request.setTimeout(api.getTimeout());

            response = request.send();
            system.debug('++ response: ' + response);
            system.debug('++ response StatusCode: ' + response.getStatusCode());
        }

        // if (response.getStatusCode() == 302) {
        Attachment att = new Attachment();
        att.ParentId = leadId;
        att.Name = fileInfo.name;
        att.Body = response.getBodyAsBlob();

        List<Attachment> temp = new List<Attachment>();
        if ((temp = leadFilesMap.get(leadId)) == null) {
            leadFilesMap.put(leadId, temp = new Attachment[0]);
        }
        temp.add(att);
        system.debug('++ temp: ' + temp);
        // }
    }

    @TestVisible private static Box_API_Setting__mdt getBoxAPISettings(){
        return [SELECT DeveloperName, Base_URL__c, Client_Id__c, Client_Secret__c, Enterprise_Id__c, Folder_Id__c, JWT_Public_Key_Id__c, JWT_Private_Key__c
        FROM Box_API_Setting__mdt LIMIT 1];
    }
}