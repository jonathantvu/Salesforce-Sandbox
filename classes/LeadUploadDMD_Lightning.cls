public class LeadUploadDMD_Lightning {    
    @AuraEnabled public static String objectName {get;set;}
    @AuraEnabled public static String recordName {get;set;}
    
    @AuraEnabled
    public static Id createDocument(Document_MetaData__c theDMD, Id recordId, String objectType) {    
        try {
            List<ContentDocumentLink> contentDocumentLink = [SELECT ContentDocumentId, LinkedEntityId
                                                             FROM ContentDocumentLink
                                                             WHERE LinkedEntityId =: recordId];
            Set<Id> contentDocIds = new Set<Id>();
            for(ContentDocumentLink cdl : contentDocumentLink) {
                contentDocIds.add(cdl.ContentDocumentId);
            }
            ContentDocument contentDocument = [SELECT Id, CreatedDate FROM ContentDocument
                                               WHERE Id IN : contentDocIds
                                               ORDER BY CreatedDate DESC LIMIT 1];
            if(objectType == 'Lead') {
                theDMD.Lead__c = recordId;
            } else if (objectType == 'Opportunity') {
                theDMD.Opportunity__c = recordId;
            }
            theDMD.Upload_Date__c = system.now();
            theDMD.Uploaded__c = true;
            insert theDMD;
            
            for(ContentDocumentLink cdl : contentDocumentLink) {
                if(cdl.ContentDocumentId == contentDocument.Id) {
                    ContentDocumentLink newCDL = new ContentDocumentLink();
                    newCDL.ShareType = 'V';
                    newCDL.Visibility = 'AllUsers';
                    newCDL.LinkedEntityId = theDMD.Id;
                    newCDL.ContentDocumentId = contentDocument.Id;
                    
                    if(!test.isRunningTest()) {
                        insert newCDL;
                    }
                }
            }
            return theDMD.Id;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static String getRecordName(Id recordId) {
        Schema.sObjectType sObjType = recordId.getSObjectType();
        objectName = sObjType != null ? String.valueOf(sObjType) : '';
        recordName = '';
        if(objectName == 'Lead') {
            recordName = [SELECT Id, Name FROM Lead WHERE Id =: recordId LIMIT 1].Name;
        } else if(objectName == 'Opportunity') {
            recordName = [SELECT Id, Name FROM Opportunity WHERE Id =: recordId LIMIT 1].Name;
        }
        return recordName;
    }

    @AuraEnabled
    public static String getSObjectType(Id recordId) {
        Schema.sObjectType sObjType = recordId.getSObjectType();
        objectName = sObjType != null ? String.valueOf(sObjType) : '';
        return objectName;
    }
    
    @AuraEnabled
    public static List<Current_Conditions__c> getRequirements(Id recordId) {
        Schema.sObjectType sObjType = recordId.getSObjectType();
        objectName = sObjType != null ? String.valueOf(sObjType) : '';
        List<Current_Conditions__c> reqs = new List<Current_Conditions__c>();
        if(objectName == 'Lead') { 
            reqs = [SELECT Id, Name, Code__c, Requirement__c, Lead__c FROM Current_Conditions__c WHERE Lead__c =: recordId];
        } else if(objectName == 'Opportunity') {
            reqs = [SELECT Id, Name, Code__c, Requirement__c, Opportunity__c FROM Current_Conditions__c WHERE Opportunity__c =: recordId];
        }
        return reqs;
    }

    @AuraEnabled
    public static DMDUploadWrapper init(Id recordId) {
        DMDUploadWrapper wrapper = new DMDUploadWrapper();
        wrapper.recordName = getRecordName(recordId);
        wrapper.objectType = getSObjectType(recordId);
        wrapper.requirements = getRequirements(recordId);
        return wrapper;
    }

    public class DMDUploadWrapper {
        @AuraEnabled public Document_MetaData__c theDMD {get;set;}
        @AuraEnabled public List<Current_Conditions__c> requirements {get;set;}
        @AuraEnabled public String recordName {get;set;}
        @AuraEnabled public String objectType {get;set;}

        DMDUploadWrapper() {
            theDMD = new Document_MetaData__c();
            requirements = new List<Current_Conditions__c>();
            recordName = '';
            objectType = '';
        }
    }
}