public class UnisonAPI {
    public static string documentApiVersion = 'v2';

    public static string newId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    @Future(callout=true)
    public static void fSendMRDUpsert(string mrdId) {
            UnisonAPI.SendMRDUpsert(mrdId);       
    }
    public static HttpResponse SendMRDUpsert(string mrdId) {
        MrdToAwsTrigger_Endpoint__mdt AwsEndpointSetting = [SELECT Id, AWS_Endpoint__c FROM MrdToAwsTrigger_Endpoint__mdt LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(AwsEndpointSetting.AWS_Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><notifications xmlns="http://soap.sforce.com/2005/09/outbound"><OrganizationId test="Chris">00D1100000013SvEAI</OrganizationId><ActionId>04k11000000CbyCAAS</ActionId><SessionId xsi:nil="true"/><EnterpriseUrl>https://unisonstage--Stage.cs18.my.salesforce.com/services/Soap/c/43.0/00D1100000013Sv</EnterpriseUrl><PartnerUrl>https://unisonstage--Stage.cs18.my.salesforce.com/services/Soap/u/43.0/00D1100000013Sv</PartnerUrl><Notification><Id>' + UnisonAPI.newId() + '</Id><sObject xsi:type="sf:Minimum_Required_Documents__c " xmlns:sf="urn:sobject.enterprise.soap.sforce.com"><sf:Id>' + mrdId + '</sf:Id></sObject></Notification></notifications></soapenv:Body></soapenv:Envelope>');
        HttpResponse response = new HttpResponse();
        if (!Test.isRunningTest()) {
            response = http.send(request);
        } else {
            response = UnisonAPIHttpCalloutMock.respond(request);
        }
        
            Box_Logs__c log = new Box_Logs__c();
            log.Request_Body__c = request.getBody();
            if (log.Request_Body__c.length() > 131071) {
                log.Request_Body__c = log.Request_Body__c.substring(0, 131067) + '...';
            }
            log.Response_Body__c = response.getBody();
            if (log.Response_Body__c.length() > 8192) {
                log.Response_Body__c = log.Response_Body__c.substring(0, 8192) + '...';
            }
            log.Response_Code__c = response.getStatusCode();
            insert log;
        // Parse the JSON response
        if (response.getStatusCode() >= 400) {
            System.Debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
        return response;
    }

    public static List<Map<String, object>> CreateRequirementsPayload(List<Current_Conditions__c> requirements) {
        Map<String, object> awsObj;
        List<Map<String, object>> data = new List<Map<String, object>>();

        for (Current_Conditions__c req : requirements) {
            EOS_Requirements__mdt reqMeta;
            // We need to filter so we only send certain requirements
            if (req.Code__c == null || req.Code__c == '') {
                continue;
            }
            try {
                reqMeta = [select Type__c from EOS_Requirements__mdt where Label = :req.Code__c limit 1];
            } catch (exception e) {
                System.debug('Failed to get the EOS Requirement meta-data.');
                continue;
            }
            if (reqMeta.Type__c == 'Data Request') {
                awsObj = new Map<String, object>();
                awsObj.put('Id', req.Id);
                awsObj.put('AWS_id__c', null);
                awsObj.put('Lead__c', req.Lead__c);
                awsObj.put('Opportunity__c', req.Opportunity__c);
                awsObj.put('Category__c', req.Category__c);
                awsObj.put('Requirement__c', req.Requirement__c);
                awsObj.put('Internal_vs_External__c', req.Internal_vs_External__c);
                //awsObj.put('Box_Folder_Id__c', req.Box_Folder_Id__c);
                awsObj.put('Reuploaded__c', req.IsReuploaded__c);
                awsObj.put('Reupload_Comments__c', req.Reupload_Comments__c);
                awsObj.put('Applicant_Type__c', req.Applicant_Type__c);
                awsObj.put('Uploaded__c', req.Uploaded__c);
                awsObj.put('Customer_Description__c', req.Customer_Description__c);
                awsObj.put('CreatedDate', req.CreatedDate);
                awsObj.put('LastModifiedDate', req.LastModifiedDate);
                awsObj.put('IsDeleted', req.IsDeleted);
                data.add(awsObj);
            }
        }
        return data;
    }
    public static void SendRequirementUpsert(List<Current_Conditions__c> requirements) {
        system.debug('***********SendRequirementUpsert********');
        List<Map<String, object>> data = UnisonAPI.CreateRequirementsPayload(requirements);
        system.debug('********data *********'+data);
        if (!data.isEmpty()) {
            system.debug('***********SendRequirementUpsert*2*******');
            UnisonAPI.fSendRequirementUpsert(JSON.serialize(data));
        }
    }
    @Future(callout=true)
    public static void fSendRequirementUpsert(String body) {
        if (!Test.isRunningTest()) {
            UnisonAPI.SendRequirementUpsertRequest(body);
        }
    }
    public static HttpResponse SendRequirementUpsertRequest(String body) {
        RequirementToAWSEndpoint__mdt AwsEndpointSetting = [SELECT X_API_Key__c, AWSEndpoint__c FROM RequirementToAWSEndpoint__mdt LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(AwsEndpointSetting.AWSEndpoint__c);
        system.debug('********endpoint*********'+AwsEndpointSetting.AWSEndpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('x-api-key', AwsEndpointSetting.X_API_Key__c);
        request.setBody(body);
        HttpResponse response = http.send(request);
        system.debug('*******response **********'+response);
        // Parse the JSON response
        if (response.getStatusCode() >= 400) {
            System.Debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
        
         Box_Logs__c log = new Box_Logs__c();
            log.Request_Body__c = request.getBody();
            if (log.Request_Body__c.length() > 131071) {
                log.Request_Body__c = log.Request_Body__c.substring(0, 131067) + '...';
            }
            log.Response_Body__c = response.getBody();
            if (log.Response_Body__c.length() > 8192) {
                log.Response_Body__c = log.Response_Body__c.substring(0, 8192) + '...';
            }
            log.Response_Code__c = response.getStatusCode();
            insert log;
        
        return response;
    }

    public static List<Map<String, object>> CreateDocumentsPayload(List<Document_MetaData__c> docs) {
        Map<String, object> awsObj;
        List<Map<String, object>> data = new List<Map<String, object>>();

        for (Document_MetaData__c doc : docs) {
            awsObj = new Map<String, object>();
            awsObj.put('Id', doc.Id);
            awsObj.put('AWS_id__c', null);
            awsObj.put('Requirement__c', doc.Requirement__c);
            awsObj.put('Lead__c', doc.Lead__c);
            awsObj.put('Opportunity__c', doc.Opportunity__c);
            awsObj.put('Category__c', doc.Category__c);
            awsObj.put('Document_Type__c', doc.Document_Type__c);
            awsObj.put('CreatedDate', doc.CreatedDate);
            awsObj.put('LastModifiedDate', doc.LastModifiedDate);
            awsObj.put('Box_File_Id__c', doc.Box_File_Id__c);
            awsObj.put('Box_File_URL__c', doc.Box_File_URL__c);
            awsObj.put('Box_Folder_Id__c', doc.Box_Folder_Id__c);
            data.add(awsObj);
        }
        return data;
    }

    public static List<Map<String, object>> CreateDocumentsPayload_v2(List<Document_MetaData__c> docs) {
        Map<String, object> awsObj;
        List<Map<String, object>> data = new List<Map<String, object>>();

        //alternative process using inner class
        //List<DocumentPayload> data = new List<DocumentPayload>();

        for (Document_MetaData__c doc : docs) {
            awsObj = new Map<String, object>();
            awsObj.put('Id', doc.Id);
            awsObj.put('IsDeleted', false);
            awsObj.put('Name', doc.Name);
            awsObj.put('CreatedDate', doc.CreatedDate);
            awsObj.put('LastModifiedDate', doc.LastModifiedDate);
            awsObj.put('AWS_id__c', null);
            awsObj.put('Category__c', doc.Category__c);
            awsObj.put('Customer_Uploaded__c', false);
            awsObj.put('Last_Modified_in_Box__c', null);
            awsObj.put('Lead__c', doc.Lead__c);
            awsObj.put('Opportunity__c', doc.Opportunity__c);
            awsObj.put('Requirement__c', doc.Requirement__c);
            awsObj.put('shouldUpload', true);
            data.add(awsObj);

            //alternative process using inner class
            /*
            awsObj = new DocumentPayload();
            awsObj.docId = doc.Id;
            awsObj.isDeleted = false;
            awsObj.name = doc.Name;
            awsObj.createdDate = doc.CreatedDate;
            awsObj.lastModifiedDate = doc.LastModifiedDate;
            awsObj.AWS_id = null;
            awsObj.categoryId = doc.Category__c;
            awsObj.customerUploaded = false;
            awsObj.lastModifiedInBox = null;
            awsObj.leadId = doc.Lead__c;
            awsObj.oppportunityId = doc.Opportunity__c;
            awsObj.requirementId = doc.Requirement__c;          
            awsObj.shouldUpload = true;
            data.add(awsObj);
            */
        }
        return data;
    }
    public static void SendDocumentUpsert(List<Document_MetaData__c> docs) {
        List<Map<String, object>> data = new List<Map<String, object>>();
        switch on UnisonAPI.documentApiVersion{
            when ''{
                data = UnisonAPI.CreateDocumentsPayload(docs);
            }
            when else{
                System.debug('Calling v2 method');
                data = UnisonAPI.CreateDocumentsPayload_v2(docs);
            }
        }

        if (!data.isEmpty()) {
            UnisonAPI.fSendDocumentUpsert(JSON.serialize(data));
        }
    }
    @Future(callout=true)
    public static void fSendDocumentUpsert(String body) {
        switch on UnisonAPI.documentApiVersion{
            when ''{
                UnisonAPI.SendDocumentUpsertRequest(body);
            }
            when else{
                System.debug('Calling v2 method');
                UnisonAPI.SendDocumentUpsertRequest_versioned(body, UnisonAPI.documentApiVersion);
                //TO-DO: 
                //1) Save status code response from callout
                /* HttpResponse res = UnisonAPI.SendDocumentUpsertRequest_versioned(body, UnisonAPI.documentApiVersion);*/
                //2) De-serialize body and parse for document ids
                /*
                Set<Id> originalIds = new Set<Id>();
                List<DocumentPayload> originalList = (List<DocumentPayload>) JSON.deserialize(body, List<DocumentPayload>.class);
                for(DocumentPayload dp: originalList){
                    Id currentId = dp.docId;
                    originalIds.add(currentId);
                }
                List<Document_MetaData__c> recordsToUpdate = [SELECT Id from Document_MetaData__c WHERE Id in :originalIds];
                */
                //3) Update each document record with the response
                /*
                for(Document_MetaData__c doc : recordsToUpdate){
                    //make the update to the selected field here
                }

                update recordsToUpdate;
                */
            }
        }
    }

    /**********     
    Document Upsert    
    ***********/
    public static HttpResponse SendDocumentUpsertRequest(String body) {
        DocumentToAWSEndpoint__mdt AwsEndpointSetting = [SELECT X_API_Key__c, AWSEndpoint__c FROM DocumentToAWSEndpoint__mdt LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(AwsEndpointSetting.AWSEndpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('x-api-key', AwsEndpointSetting.X_API_Key__c);
        request.setBody(body);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() >= 400) {
            System.Debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
        
         Box_Logs__c log = new Box_Logs__c();
            log.Request_Body__c = request.getBody();
            if (log.Request_Body__c.length() > 131071) {
                log.Request_Body__c = log.Request_Body__c.substring(0, 131067) + '...';
            }
            log.Response_Body__c = response.getBody();
            if (log.Response_Body__c.length() > 8192) {
                log.Response_Body__c = log.Response_Body__c.substring(0, 8192) + '...';
            }
            log.Response_Code__c = response.getStatusCode();
            insert log;
        
        return response;
    }

    public static HttpResponse SendDocumentUpsertRequest_versioned(String body, string versionName) {
        String labelName = '%'+ versionName + '%';
        DocumentToAWSEndpoint__mdt AwsEndpointSetting = [SELECT X_API_Key__c, AWSEndpoint__c FROM DocumentToAWSEndpoint__mdt WHERE Label LIKE :labelName LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(AwsEndpointSetting.AWSEndpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('x-api-key', AwsEndpointSetting.X_API_Key__c);
        request.setBody(body);
        if(!Test.isRunningTest()) {
            HttpResponse response = http.send(request);

            // Parse the JSON response
            if (response.getStatusCode() >= 400) {
                System.Debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
            return response;
        }else{
            return null;
        }
    }

    public class DocumentPayload{
        public Id docId;
        public boolean isDeleted;
        public string name;
        public Date createdDate;
        public Date lastModifiedDate;
        public string AWS_id;
        public string categoryId;
        public boolean customerUploaded;
        public string lastModifiedInBox;
        public Id leadId;
        public Id opportunityId;
        public Id requirementId;
        public boolean shouldUpload;
    }

}