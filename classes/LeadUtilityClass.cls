global class LeadUtilityClass{
    public static boolean  flag = false;
    public static void addMRDAttachments(Set<Id> leadids){
        system.debug('******leadids*******'+leadids);
        List<Attachment> newcdl = new List<Attachment>();
        Map<Id,List<ContentDocumentLink>> cmap = new Map<Id,List<ContentDocumentLink>>();

        Map<Id,Minimum_Required_Documents__c> mrdlist = new Map<Id,Minimum_Required_Documents__c>([select Id,Lead__c from Minimum_Required_Documents__c where Lead__c =: leadids]);
        system.debug('mrdlist: '+mrdlist);
        system.debug('mrdlist empty?: '+mrdlist.isEmpty());
        system.debug('mrdlist null?: '+mrdlist == null);

        if(!mrdlist.isEmpty()){
            Set<Id> ser = mrdlist.keyset();
            system.debug('ser: '+ser);

            List<ContentDocumentLink> conlinks = [SELECT ContentDocument.LatestPublishedVersion.Title,ContentDocument.LatestPublishedVersion.versiondata,
                    ContentDocument.LatestPublishedVersion.FileExtension,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: ser];
            system.debug('conlinks: '+conlinks);

            for(ContentDocumentLink c: conlinks){
                List<ContentDocumentLink> tempc = new List<ContentDocumentLink>();
                if(!cmap.keyset().contains(mrdlist.get(c.LinkedEntityId).Lead__c)){
                    tempc.add(c);
                    cmap.put(mrdlist.get(c.LinkedEntityId).Lead__c, tempc);
                }else{
                    tempc = cmap.get(mrdlist.get(c.LinkedEntityId).Lead__c);
                    tempc.add(c);
                    cmap.put(mrdlist.get(c.LinkedEntityId).Lead__c, tempc);
                }
            }

            if(cmap.keyset() != Null && cmap.keyset().size() > 0){
                for(Id lid : cmap.keyset()){
                    if(cmap.get(lid) != Null && cmap.get(lid).size() > 0){
                        for(ContentDocumentLink cdl : cmap.get(lid)){
                            Attachment att = new Attachment();
                            att.ParentId = lid;
                            att.Body = cdl.ContentDocument.LatestPublishedVersion.versiondata;
                            att.Name = cdl.ContentDocument.LatestPublishedVersion.Title;

                            if(att.Name != Null && cdl.ContentDocument.LatestPublishedVersion.FileExtension != Null
                                    && !att.Name.endsWithIgnoreCase('.'+cdl.ContentDocument.LatestPublishedVersion.FileExtension)){
                                att.Name = att.Name +'.'+cdl.ContentDocument.LatestPublishedVersion.FileExtension;
                            }
                            newcdl.add(att);
                        }
                    }
                }
            }
        }else{

        }

        if(newcdl.size() > 0){
            insert newcdl;
        }

    }
    /**
     *  About
     *  -----
     *  Author: Sundar Subramaniam
     *  
     *  Details
     *  -----
     *  Method to take care of Making a API cal out to LQ as a future method
    **/
    //BUS-155110577 stop sending leads to LQ
    /*
    @future (callout=true)
    public static void LQ_CallWebService(Id leadIdList){

        List<SObject> leadList = new List<SObject>();
        String queryString;

        //Custom setting 
        LeadQual_Authentication__c CSetting = LeadQual_Authentication__c.getInstance();

        //Custom metadata for the field mapping details
        List<LeadQaul_Field_Mapping__mdt> LQFieldMap = [SELECT MasterLabel, QualifiedApiName, Sequence__c , SF_Field_API__c, LeadQaul_Field_Name__c FROM LeadQaul_Field_Mapping__mdt ORDER BY Sequence__c ASC];

        //Dynamic Lead query filed from the metadata  
        queryString = 'SELECT Name, LeadQual_LQ_Response__c, LeadQual_LQ_Response_Status__c, LQ_Status__c '  ;
        if(LQFieldMap.size() > 0 ){
            for(LeadQaul_Field_Mapping__mdt obj: LQFieldMap ){
                queryString = queryString + ' , ' + obj.SF_Field_API__c  ;
            }
        }

        //This condition is if the mapping metadata does not contain Id, this condition will add the ID to query 
        if(!queryString.contains('Id')){
            queryString = queryString + ' , Id' ;
        }

        queryString = queryString + ' FROM Lead WHERE Id =: leadIdList'  ;
        system.debug('queryString=>'+queryString);

        leadList = Database.query(queryString);

        try{

            //JSON body creation for the API request
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('Leads');
            gen.writeStartArray();

            if(leadList.size() > 0){
                for(SObject obj: leadList){
                    gen.writeStartObject();
                    for(LeadQaul_Field_Mapping__mdt FMapObj: LQFieldMap){
                        System.debug('Value=>'+obj.get(string.valueOf(FMapObj.SF_Field_API__c)));
                        if(obj.get(string.valueOf(FMapObj.SF_Field_API__c)) != null){
                            gen.writeStringField(FMapObj.LeadQaul_Field_Name__c, string.valueOf(obj.get(FMapObj.SF_Field_API__c)));
                        }
                    }
                    gen.writeEndObject();
                }
            }
            gen.writeEndArray();
            gen.writeEndObject();

            String jsonS = gen.getAsString();
            System.debug('responseJson=>'+jsonS);

            String endpoint = CSetting.Eed_Point_URL__c;

            //REST Request 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setbody(jsonS);
            Http http = new Http();
            HTTPResponse response = http.send(req); //commented tempeorily not to make API callout, uncomment this line and comment below line if the callout need to be done to LQ
            //HTTPResponse response = new HTTPResponse();

            System.debug('response=>'+response);
            //API Success or Error condition check 
            if (response.getStatusCode() == 200) {
                //On Success Parse the json response to get the details 
                JSONParser parser = JSON.createParser(response.getBody());
                string status_code = '1';
                String status_description = '';

                //JSON parsing to get the Status code and status description to save back on the Lead
                while (parser.nextToken() != null) {
                    //If it is status code 
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'status_code')) {
                        // Get the value of Status Code.
                        parser.nextToken();
                        status_code = parser.getText();
                    }
                    //If it is status description 
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'status_description')) {
                        // Get the value of Status Description.
                        parser.nextToken();
                        status_description = parser.getText();
                    }
                }
                System.debug('status_code==>'+status_code);
                System.debug('response==>'+response.getBody());

                //If the status code is '0' the Lead is successfully posted in the LQ
                if(status_code == '0'){
                    leadList[0].put('LeadQual_LQ_Response_Status__c','Success');
                    leadList[0].put('LeadQual_LQ_Response__c',status_description);
                }else{
                    leadList[0].put('LeadQual_LQ_Response_Status__c','Error');
                    leadList[0].put('LeadQual_LQ_Response__c',status_description);
                }
            }else{
                leadList[0].put('LeadQual_LQ_Response_Status__c','Error');
                leadList[0].put('LeadQual_LQ_Response__c',response.getBody());
            }

            //Update the Lead with status  description
            if(leadList[0].get('LeadQual_LQ_Response_Status__c') != null) {
                System.debug('leadList[0]==>'+leadList[0]);
                update leadList;
            }

        }catch(Exception e){
            system.debug('Exception==>'+e+'==Line Number==>'+e.getLineNumber());
        }
    }
	*/
    
    //BUS-155110577 stop sending leads to LQ
    /*
    @AuraEnabled
    webService static String customButtonCall(Id leadId) {
        Id HomeBuyerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        Id HomeOwnerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        List<Group> lqQueueList = new List<Group>();
        Id lqQueueId ;
        lqQueueList = [select Id from Group where Name = 'LQ Queue' and Type = 'Queue' LIMIT 1];
        if(lqQueueList.size() > 0){
            lqQueueId = lqQueueList[0].id;
        }

        Lead currentRecord = [SELECT Phone,RecordTypeId,Status,LeadQual_LQ_Response__c,LQ_Status__c,OwnerId FROM Lead WHERE Id = :leadId];
        //Sundar Subramaniam 03/27/2019 - change in the criteria with respect to HB Lead Status Update Project - CM-50
        //if(currentRecord.Status == 'Pending Qualification' && (currentRecord.RecordTypeId == HomeBuyerId || currentRecord.RecordTypeId == HomeOwnerId)){

        if(( lqQueueId != null && currentRecord.OwnerId == lqQueueId ) 
           && ( currentRecord.LQ_Status__c == null && currentRecord.LeadQual_LQ_Response__c == null ) 
           && (currentRecord.Status == 'Pre Discovery' || currentRecord.Status == 'Pending Qualification') 
           && (currentRecord.RecordTypeId == HomeBuyerId || currentRecord.RecordTypeId == HomeOwnerId))
        {

            LeadUtilityClass.LQ_CallWebService(currentRecord.Id);
            return 'Lead has been successfully sent to LQ';
        }else{
            return 'Cannot send the Lead to LQ. Please review your data and try again';
        }

    }
	*/

    /*
    public static void createCreditReport(Set<Id> dmdleadids){
        System.debug('**** inside createDMD****');
        Map<Id,Set<Id>> pcrcdmap = new Map<Id,Set<Id>>();
        List<LASERCA__Personal_Credit_Report__c> pcrlist = [select id, LASERCA__Lead__c, (select contentdocumentid,contentdocument.Title from contentdocumentlinks) 
                                                            from LASERCA__Personal_Credit_Report__c where LASERCA__Lead__c =: dmdleadids ORDER BY LastModifiedDate desc LIMIT 1];
        system.debug('******pcrlist******'+pcrlist);
        
        for(LASERCA__Personal_Credit_Report__c pcr : pcrlist){
            System.debug('**** PCR files***');
            system.debug('******pcr*******'+pcr);
            Set<Id> pcrset = new Set<Id>();
            if(!pcrcdmap.keyset().contains(pcr.LASERCA__Lead__c)){
                if(pcr.contentdocumentlinks != Null && pcr.contentdocumentlinks.size() > 0){
                    for(contentdocumentlink p : pcr.contentdocumentlinks){
                        if(p.contentdocument.Title != Null || p.contentdocument.Title.endsWith('.pdf')){
                            pcrset.add(p.contentdocumentid);
                        }
                    }
                }
                system.debug('*** PCR map with filename****');
                pcrcdmap.put(pcr.LASERCA__Lead__c,pcrset);
            }
        }
        
        system.debug('****pcrcdmap******'+pcrcdmap);
        
        Success_Factor__c leadsf = [select id from Success_Factor__c where Lead__c =: dmdleadids AND Success_Factor__c = 'Credit' limit 1];
        List<Current_Conditions__c> reqlist = new List<Current_Conditions__c>();
        Map<Id,Set<Id>> sfdocidmap = new Map<Id,Set<Id>>();
        
        for(Id dl: dmdleadids){
            system.debug('**** req creation ****');
            Current_Conditions__c req= new Current_Conditions__c();
            
            req.Requirement__c             = 'Credit Report';
            req.Category__c                = 'Credit';
            req.Code__c                    = 'R1021';
            req.Type__c                    = 'Data Request';
            req.Internal_vs_External__c    = 'External';
            req.Applicant_Type__c          = 'Applicant';
            //req.Assigned_To__c             = 'IA';
            req.Document_Code__c           = 'DOC-0110';
            req.Status__c                  = 'Cleared';
            //req.Customer_Response_Needed__c= TRUE;
            req.Uploaded__c                = FALSE;
            req.Lead__c                    = dl;
            req.Success_Factor__c          = leadsf.Id;
            reqlist.add(req);
            sfdocidmap.put(leadsf.Id,pcrcdmap.get(dl));
        }
        if(reqlist.size() > 0) {
            system.debug('*****requirement insert*********');
            insert reqlist;
            system.debug('*******reqlist********'+reqlist);
        }
        
        system.debug('*****sfdocidmap *********'+sfdocidmap);
        Map<Id,Set<Id>> reqdocidmap = new Map<Id,Set<Id>>();
        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        for(Current_Conditions__c req : reqlist){
            system.debug('**** inside DMD creation***');
            Document_MetaData__c d     = new Document_MetaData__c();
            d.Requirement__c           = req.Id;
            d.Document_Type__c         = 'Credit Report';
            d.Category__c              = 'Credit';
            d.Lead__c                  = req.Lead__c;
            dmdlist.add(d);
            reqdocidmap.put(req.Id,sfdocidmap.get(leadsf.Id));
        }
        system.debug('*****reqdocidmap*********'+reqdocidmap);
        
        if(dmdlist.size() > 0) {
            system.debug('*****dmd insert*********');
            insert dmdlist;        
        }        
        system.debug('******dmdlist******'+dmdlist);
        //List<Document_MetaData__c> dmd = [select Id, Lead__c, Current_Conditions_r.Id from Document_MetaData__c];
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        for(Document_MetaData__c c : dmdlist){
            System.debug('**** adding link ID to DMD*****');
            //for(Id docid : pcrcdmap.get(c.Lead__c)){
                if(reqdocidmap.keyset().size() > 0 && reqdocidmap.keyset().contains(c.Requirement__c) && reqdocidmap.get(c.Requirement__c) != Null){
                    for(Id docid : reqdocidmap.get(c.Requirement__c)){
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = docid;
                        cdl.LinkedEntityId = c.id;
                        cdl.ShareType = 'V';
                        cdl.Visibility = 'AllUsers';
                        cdllist.add(cdl);
                    }
                }
            //}
        }
        System.debug('*** insert CDL in DMD**');
        insert cdllist;
        system.debug('*****cdllist*****'+cdllist);
    } 
    */

    /*
    public static void createApplication(Set<Id> leadids){
        system.debug('******leadids********'+leadids);
        
        List<Current_Conditions__c> reqlist = new List<Current_Conditions__c>();
        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        
        Success_Factor__c leadsf = [select id from Success_Factor__c where Lead__c =: leadids AND Success_Factor__c = 'DTI' limit 1];
        
        
        List<ContentDocumentLink> conlinks = [select ContentdocumentId,ContentDocument.Title, linkedentityid from ContentDocumentLink where linkedentityid =: leadids];
        system.debug('******conlinks********'+conlinks);
        Map<Id,Id> sfdocidmap = new Map<Id,Id>();
        for(ContentDocumentLink cl: conlinks) {
            system.debug('******cl.ContentDocument.Title********'+cl.ContentDocument.Title);
            if(cl.ContentDocument.Title.contains('Completed_Application_Package_FRX')) {
                Current_Conditions__c req = new Current_Conditions__c();
                
                req.Requirement__c             = 'Application';
                req.Category__c                = 'Application Package';
                req.Code__c                    = 'CON-0142';
                req.Type__c                    = 'Data Request';
                req.Internal_vs_External__c    = 'External';
                req.Applicant_Type__c          = 'Applicant';
                //req.Assigned_To__c             = 'PS';
                req.Document_Code__c           = 'DOC-0142';
                req.Customer_Description__c    = 'Please complete a Unison application';
                req.Status__c                  = 'Document Received, In progress';
                //req.Customer_Response_Needed__c= TRUE;
                req.Uploaded__c                = FALSE;
                req.Success_Factor__c          = leadsf.Id;
                req.Lead__c                    = cl.linkedentityid;
                
                sfdocidmap.put(leadsf.Id,cl.ContentdocumentId);
                reqlist.add(req);                                   
            } 
        }
        
        if(reqlist.size() >0) {
            insert reqlist;
        }
         
        Map<Id,Id> reqdocidmap = new Map<Id,Id>();
        for(Current_Conditions__c c: reqlist) {           
            Document_MetaData__c dmd = new Document_MetaData__c();
                dmd.Lead__c = c.Lead__c;
                dmd.Requirement__c   = c.Id;
                dmd.Document_Type__c = 'Application';
                reqdocidmap.put(c.Id,sfdocidmap.get(c.Success_Factor__c));
                dmdlist.add(dmd);
        } 
        if(dmdlist.size() > 0){
            insert dmdlist;
        }
        
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        for(Document_MetaData__c c : dmdlist){
            System.debug('**** adding link ID to DMD*****');
            //for(ContentDocumentLink docid : conlinks){
            ContentDocumentLink cdl = new ContentDocumentLink();
            //cdl.ContentDocumentId = docid.ContentdocumentId;
            cdl.ContentDocumentId = reqdocidmap.get(c.Requirement__c);
            cdl.LinkedEntityId = c.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdllist.add(cdl);
            //}
        }
        System.debug('*** insert CDL in DMD**');
        insert cdllist;       
    } 
    */
    /*
 public static void applicationCreation(Set<Id> leadids, List<Success_Factor__c> sflist){
     List<Current_Conditions__c> reqlist = new List<Current_Conditions__c>();
     List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();

     List<ContentDocumentLink> conlinks = [select ContentdocumentId,ContentDocument.Title, linkedentityid from ContentDocumentLink where linkedentityid =: leadids];
     system.debug('******conlinks********'+conlinks);
     Map<Id,Id> sfdocidmap = new Map<Id,Id>();
     for(ContentDocumentLink cl: conlinks) {
         for(Success_Factor__c sf: sflist) {
             system.debug('******cl.ContentDocument.Title********'+cl.ContentDocument.Title);
             if(cl.ContentDocument.Title.contains('Completed_Application_Package_FRX')) {
                 if(sf.Success_Factor__c != Null && sf.Lead__c == cl.linkedentityid && sf.Success_Factor__c == 'DTI') {

                     Current_Conditions__c req = new Current_Conditions__c();

                     req.Requirement__c             = 'Application';
                     req.Category__c                = 'Application Package';
                     req.Code__c                    = 'R1093';
                     req.Type__c                    = 'Data Request';
                     req.Internal_vs_External__c    = 'External';
                     req.Applicant_Type__c          = 'Applicant';
                     //req.Assigned_To__c             = 'PS';
                     //req.Document_Code__c           = 'DOC-0142';
                     req.Customer_Description__c    = 'Please complete a Unison application';
                     req.Status__c                  = 'Document Received, In progress';
                     //req.Customer_Response_Needed__c= TRUE;
                     req.Uploaded__c                = FALSE;
                     req.Success_Factor__c          = sf.Id;
                     req.Lead__c                    = cl.linkedentityid;

                     sfdocidmap.put(sf.Id,cl.ContentdocumentId);
                     reqlist.add(req);
                 }
             }
         }
     }

     if(reqlist.size() >0) {
         insert reqlist;
     }

     Map<Id,Id> reqdocidmap = new Map<Id,Id>();
     for(Current_Conditions__c c: reqlist) {
         Document_MetaData__c dmd = new Document_MetaData__c();
             dmd.Lead__c = c.Lead__c;
             dmd.Requirement__c   = c.Id;
             dmd.Document_Type__c = 'Application';
             reqdocidmap.put(c.Id,sfdocidmap.get(c.Success_Factor__c));
             dmdlist.add(dmd);
     }
     if(dmdlist.size() > 0){
         insert dmdlist;
     }

     List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
     for(Document_MetaData__c c : dmdlist){
      //  System.debug('**** adding link ID to DMD*****');
         //for(ContentDocumentLink docid : conlinks){
         ContentDocumentLink cdl = new ContentDocumentLink();
         //cdl.ContentDocumentId = docid.ContentdocumentId;
         cdl.ContentDocumentId = reqdocidmap.get(c.Requirement__c);
         cdl.LinkedEntityId = c.id;
         cdl.ShareType = 'V';
         cdl.Visibility = 'AllUsers';
         cdllist.add(cdl);
         //}
     }
 //    System.debug('*** insert CDL in DMD**');
     insert cdllist;
 }
 */

    public static void creditCreation(Set<Id> leadids, List<Success_Factor__c> sflist){
        List<Current_Conditions__c> reqlist = new List<Current_Conditions__c>();
        Map<Id,Set<Id>> pcrcdmap = new Map<Id,Set<Id>>();
        List<LASERCA__Personal_Credit_Report__c> pcrlist = [select id, LASERCA__Lead__c, (select contentdocumentid,contentdocument.Title from contentdocumentlinks)
        from LASERCA__Personal_Credit_Report__c where LASERCA__Lead__c =: leadids ORDER BY LastModifiedDate desc LIMIT 1];
        //    system.debug('******pcrlist******'+pcrlist);

        for(LASERCA__Personal_Credit_Report__c pcr : pcrlist){
            System.debug('**** PCR files***');
            //    system.debug('******pcr*******'+pcr);
            Set<Id> pcrset = new Set<Id>();
            if(!pcrcdmap.keyset().contains(pcr.LASERCA__Lead__c)){
                if(pcr.contentdocumentlinks != Null && pcr.contentdocumentlinks.size() > 0){
                    for(contentdocumentlink p : pcr.contentdocumentlinks){
                        if(p.contentdocument.Title != Null || p.contentdocument.Title.endsWith('.pdf')){
                            pcrset.add(p.contentdocumentid);
                        }
                    }
                }
                //      system.debug('*** PCR map with filename****');
                pcrcdmap.put(pcr.LASERCA__Lead__c,pcrset);
            }
        }

        //   system.debug('****pcrcdmap******'+pcrcdmap);

        Map<Id,Set<Id>> sfdocidmap = new Map<Id,Set<Id>>();
        Map<Id, List<Current_Conditions__c>> leadReqsMap = new Map<Id, List<Current_Conditions__c>>();
        for(Current_Conditions__c req : [SELECT Id, Requirement__c, Status__c, Lead__c
        FROM Current_Conditions__c WHERE Lead__c IN : leadIds AND Requirement__c = 'Credit Report']) {
            if(leadReqsMap.containsKey(req.Lead__c)) {
                List<Current_Conditions__c> reqs = leadReqsMap.get(req.Lead__c);
                reqs.add(req);
                leadReqsMap.put(req.Lead__c, reqs);
            } else {
                leadReqsMap.put(req.Lead__c, new List<Current_Conditions__c> { req });
            }
        }
        system.debug('++ leadReqsMap? ' + leadReqsMap);
        system.debug('++ sflist ' + sflist);
        for(Id dl: leadids){
            if(!leadReqsMap.containsKey(dl)) {
            for(Success_Factor__c sf: sflist) {
                //   system.debug('**** req creation ****');
                Current_Conditions__c req= new Current_Conditions__c();

                req.Requirement__c             = 'Credit Report';
                req.Category__c                = 'Credit';
                req.Code__c                    = 'R1021';
                req.Type__c                    = 'Data Request';
                req.Internal_vs_External__c    = 'External';
                req.Applicant_Type__c          = 'Applicant';
                //req.Assigned_To__c             = 'IA'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
                //req.Document_Code__c           = 'DOC-0110';
                req.Status__c                  = 'Document Received, In progress';
                //req.Customer_Response_Needed__c= TRUE;/* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
                req.Uploaded__c                = FALSE;
                req.Lead__c                    = dl;
                req.Success_Factor__c          = sf.Id;
                reqlist.add(req);
                sfdocidmap.put(sf.Id,pcrcdmap.get(dl));
            }
            }
        }
        if(reqlist.size() > 0) {
            //       system.debug('*****requirement insert*********');
            system.debug('*******reqlist********'+reqlist);
            insert reqlist;
        }

        system.debug('*****sfdocidmap *********'+sfdocidmap);
        Map<Id,Set<Id>> reqdocidmap = new Map<Id,Set<Id>>();
        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        for(Current_Conditions__c req : reqlist){
            system.debug('**** inside DMD creation***');
            Document_MetaData__c d     = new Document_MetaData__c();
            d.Requirement__c           = req.Id;
            d.Document_Type__c         = 'Credit Report';
            d.Category__c              = 'Credit';
            d.Lead__c                  = req.Lead__c;
            dmdlist.add(d);
            reqdocidmap.put(req.Id,sfdocidmap.get(req.Success_Factor__c));
        }
        //   system.debug('*****reqdocidmap*********'+reqdocidmap);

        if(dmdlist.size() > 0) {
            //        system.debug('*****dmd insert*********');
            insert dmdlist;
        }
        //     system.debug('******dmdlist******'+dmdlist);
        //List<Document_MetaData__c> dmd = [select Id, Lead__c, Current_Conditions_r.Id from Document_MetaData__c];
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        for(Document_MetaData__c c : dmdlist){
            System.debug('**** adding link ID to DMD*****');
            //for(Id docid : pcrcdmap.get(c.Lead__c)){
            if(reqdocidmap.keyset().size() > 0 && reqdocidmap.keyset().contains(c.Requirement__c) && reqdocidmap.get(c.Requirement__c) != Null){
                for(Id docid : reqdocidmap.get(c.Requirement__c)){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = docid;
                    cdl.LinkedEntityId = c.id;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    cdllist.add(cdl);
                }
            }
            //}
        }
        //    System.debug('*** insert CDL in DMD**');
        insert cdllist;
        //  system.debug('*****cdllist*****'+cdllist);
    }
    public static void createRequirements(List<Lead> lstLeads, Map<Id, Lead> oldMap)
    {
        System.debug('====lstLeads===='+lstLeads);
        System.debug('====oldMap===='+oldMap);

        List<Current_Conditions__c> lstReqForInsert = new List<Current_Conditions__c>();
        Current_Conditions__c objReq;
        Map<String, List<Lead_Requirements__mdt>> mapRecName_lstRequirements = new Map<String, List<Lead_Requirements__mdt>>();
        List<Lead_Requirements__mdt> lstLeadRequirements = new List<Lead_Requirements__mdt>();

        Set<String> setLeadRecTypeNames = new Set<String> {'HomeOwner','HomeBuyer'};
        Set<String> setSuccessFactorNames =  new Set<String>();

        Map<ID,Schema.RecordTypeInfo> rt_Map = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
        Map<String, Id> mapSFType_SFID = new Map<String, Id>();

        List<Id> lstLeadIds = new List<Id>();
        Map<Id, List<Minimum_Required_Documents__c>> mapLeadId_lstMRD = new  Map<Id, List<Minimum_Required_Documents__c>>();
        for(Lead objLead : lstLeads)
        {
            if(objLead.Status == 'Application Received' && !flag ) //objLead.Status != oldMap.get(objLead.Id).Status && 
            {
                lstLeadIds.add(objLead.Id);
                flag = true;
            }
        }
        System.debug('====lstLeadIds==='+lstLeadIds);

        for(Lead_Requirements__mdt objMDT : getLeadRequirements()) //WHERE Lead_Record_Type__c IN :setLeadRecTypeNames
        {
            if(!mapRecName_lstRequirements.containsKey(objMDT.Lead_Record_Type__c))
            {
                mapRecName_lstRequirements.put(objMDT.Lead_Record_Type__c,  new List<Lead_Requirements__mdt> {objMDT });
            }
            else
            {
                List<Lead_Requirements__mdt> lstReq =  mapRecName_lstRequirements.get(objMDT.Lead_Record_Type__c);
                lstReq.add(objMDT);

                mapRecName_lstRequirements.put(objMDT.Lead_Record_Type__c,lstReq);
            }
            if(!String.isBlank(objMDT.Success_Factor__c))
            {
                setSuccessFactorNames.add(objMDT.Success_Factor__c);
            }
            lstLeadRequirements.add(objMDT);
        }
        for(Success_Factor__c objSuccessFactor : [SELECT Id, Success_Factor__c FROM Success_Factor__c WHERE Success_Factor__c IN :setSuccessFactorNames AND Opportunity__c != null])
        {
            mapSFType_SFID.put(objSuccessFactor.Success_Factor__c, objSuccessFactor.Id);
        }
        System.debug('====mapRecName_lstRequirements===='+mapRecName_lstRequirements.size());
        System.debug('====mapRecName_lstRequirements===='+mapRecName_lstRequirements);
        System.debug('====setSuccessFactorNames===='+setSuccessFactorNames);
        System.debug('====mapSFType_SFID===='+mapSFType_SFID);

        for(Minimum_Required_Documents__c objMRD : [SELECT Id, Applicant_Type__c, Lead__c,Category__c, Uploaded__c, Customer_Description__c, Reupload_Comments__c FROM Minimum_Required_Documents__c WHERE Lead__c IN : lstLeadIds])
        {
            System.debug('====objMRD===='+objMRD);
            if(!mapLeadId_lstMRD.containsKey(objMRD.Lead__c))
            {
                mapLeadId_lstMRD.put(objMRD.Lead__c, new List<Minimum_Required_Documents__c> {objMRD});
            }
            else
            {
                List<Minimum_Required_Documents__c> lstMRD =  mapLeadId_lstMRD.get(objMRD.Lead__c);
                lstMRD.add(objMRD);

                mapLeadId_lstMRD.put(objMRD.Lead__c,lstMRD);
            }
            System.debug('====mapLeadId_lstMRD===='+mapLeadId_lstMRD);
        }
        for(Lead objLead : lstLeads)
        {
            if(objLead.Status == 'Application Received') //objLead.Status != oldMap.get(objLead.Id).Status &&
            {
                if(mapLeadId_lstMRD.containsKey(objLead.Id))
                {
                    for(Minimum_Required_Documents__c objMRD : mapLeadId_lstMRD.get(objLead.Id) )
                    {
                        for(Lead_Requirements__mdt objMDT :   lstLeadRequirements)
                        {
                            if(objMRD.Category__c == objMDT.Requirement_Type__c && objMRD.Applicant_Type__c == objMDT.Applicant_Type__c )
                            {
                                objReq = new Current_Conditions__c(Lead__c = objLead.Id, Category__c = objMDT.Category__c, Type__c = objMDT.Type__c, Internal_vs_External__c = objMDT.Internal_vs_External__c,Applicant_Type__c = objMDT.Applicant_Type__c,Success_Factor__c = mapSFType_SFID.get(objMDT.Success_Factor__c),Requirement__c = objMDT.Requirement_Type__c);

                                lstReqForInsert.add(objReq);
                            }
                        }
                    }
                }
            }
        }

        /*     for(Lead objLead : lstLeads)
             {
                 if(objLead.Status != oldMap.get(objLead.Id).Status && objLead.Status == 'Application Received')
                 {
                     if(rt_map.get(objLead.recordTypeID).getName().containsIgnoreCase('HomeBuyer') || rt_map.get(objLead.recordTypeID).getName().containsIgnoreCase('HomeOwner'))
                     {
                         if(mapRecName_lstRequirements.containsKey('HomeBuyer'))
                         {
                             for(Lead_Requirements__mdt objLeadRequirements : mapRecName_lstRequirements.get('HomeBuyer'))
                             {
                                 System.debug('====objLeadRequirements===='+objLeadRequirements);
                                 System.debug('=====mapSFType_SFID.get(objLeadRequirements.Success_Factor__c)====='+mapSFType_SFID.get(objLeadRequirements.Success_Factor__c));
                                 if(mapSFType_SFID.containsKey(objLeadRequirements.Success_Factor__c))
                                 {
                                     objReq = new Current_Conditions__c();

                                     objReq.Lead__c                    = objLead.Id;
                                     objReq.Requirement__c             = objLeadRequirements.Requirement_Type__c;
                                     objReq.Category__c                = objLeadRequirements.Category__c;
                                     objReq.Type__c                    = objLeadRequirements.Type__c;
                                     objReq.Internal_vs_External__c    = objLeadRequirements.Internal_vs_External__c;
                                     objReq.Applicant_Type__c          = objLeadRequirements.Applicant_Type__c;
                                     objReq.Success_Factor__c          = mapSFType_SFID.get(objLeadRequirements.Success_Factor__c);

                                     lstReqForInsert.add(objReq);
                                 }
                             }
                         }
                         if(mapRecName_lstRequirements.containsKey('HomeOwner'))
                         {
                             for(Lead_Requirements__mdt objLeadRequirements : mapRecName_lstRequirements.get('HomeOwner'))
                             {
                                 if(mapSFType_SFID.containsKey(objLeadRequirements.Success_Factor__c))
                                 {
                                     objReq = new Current_Conditions__c();

                                     objReq.Lead__c                    = objLead.Id;
                                     objReq.Requirement__c             = objLeadRequirements.Requirement_Type__c;
                                     objReq.Category__c                = objLeadRequirements.Category__c;
                                     objReq.Type__c                    = objLeadRequirements.Type__c;
                                     objReq.Internal_vs_External__c    = objLeadRequirements.Internal_vs_External__c;
                                     objReq.Applicant_Type__c          = objLeadRequirements.Applicant_Type__c;
                                     objReq.Success_Factor__c          = mapSFType_SFID.get(objLeadRequirements.Success_Factor__c);

                                     lstReqForInsert.add(objReq);
                                 }
                             }
                         }
                     }

                 }
             }
             */
        System.debug('=====lstReqForInsert==='+lstReqForInsert);
        if(lstReqForInsert.size() > 0)
        {
            insert lstReqForInsert;
        }
    }

    @TestVisible private static List<Lead_Requirements__mdt> getLeadRequirements() {
        return [
                SELECT MasterLabel, Applicant_Type__c, Category__c,
                Internal_vs_External__c, Requirement_Type__c, Lead_Record_Type__c, Success_Factor__c, Type__c
                FROM Lead_Requirements__mdt
        ];
    }

    public static void switchR1125Req(List<Lead> newList, Map<Id, Lead> oldMap) {

        // This method creates a R1125 req when the Qualifies_for_New_HomeOwner_Pricing__c changes to true

        // First, which leads do we need to work with?
        Set<Id> leadIds = new Set<Id>();
        for (Lead newLead : newList) {
            Lead oldLead = oldMap.get(newLead.Id);
            if (newLead.Status == 'Application Received' || newLead.Status == 'Documents In') {
                leadIds.add(newLead.Id);
            }
        }

        if (leadIds.size() > 0) {

            // Let's obtain existing Requirements to update if needed
            Map<Id, List<Current_Conditions__c>> leadReqs = new Map<Id, List<Current_Conditions__c>>();
            for (Current_Conditions__c req : [SELECT Id, Lead__c, Code__c, Status__c,
                                                        (SELECT Id, Status__c FROM Project_Tasks__r)
                                                FROM Current_Conditions__c 
                                                WHERE Lead__c IN :leadIds AND Code__c = 'R1125'])
            {
                if (!leadReqs.containsKey(req.Lead__c)) {
                    leadReqs.put(req.Lead__c, new List<Current_Conditions__c>());
                }
                leadReqs.get(req.Lead__c).add(req);
            }

            List<Current_Conditions__c> reqsToUpsert = new List<Current_Conditions__c>();
            List<Project_Task__c> tasksToUpdate = new List<Project_Task__c>();

            for (Lead newLead : newList) {
                System.debug(newLead.Status);
                System.debug(newLead.Status);
                // If we switch from false to true, we create R1125 (if it exists, we just update them to 'In Progress')
                if ((newLead.Status == 'Application Received' || newLead.Status == 'Documents In') && newLead.Qualifies_for_New_HomeOwner_Pricing__c == true) {
                    
                    boolean R1125Found = false;
                    if (leadReqs.containsKey(newLead.Id)) {
                        for (Current_Conditions__c req : leadReqs.get(newLead.Id)) {
                            if (req.Code__c == 'R1125') {
                                if (req.Status__c == 'Waived') {
                                    req.Status__c = 'Document Received, In progress';
                                    reqsToUpsert.add(req);
                                    for (Project_Task__c pt : req.Project_Tasks__r) {
                                        if (pt.Status__c != 'Completed' && pt.Status__c != 'In Progress') {
                                            pt.Status__c = 'In Progress';
                                            tasksToUpdate.add(pt);
                                        }
                                    }
                                }
                                R1125Found = true;
                            }
                        }
                    }
                    if (!R1125Found) {
                        reqsToUpsert.add(new Current_Conditions__c(Lead__c = newLead.Id, Code__c = 'R1125'));
                    }
                }
				// If we switch from true to false, we waive existing R1125 and we create R1008 & R1040 (if it exists, we just update them to 'In Progress')
                if ((newLead.Status == 'Application Received' || newLead.Status == 'Documents In') && newLead.Qualifies_for_New_HomeOwner_Pricing__c == false) {
                    if (leadReqs.containsKey(newLead.Id)) {
                        for (Current_Conditions__c req : leadReqs.get(newLead.Id)) {                            
                            if (req.Code__c == 'R1125') {
                                if (req.Status__c == 'Document Received, In progress') {
                                    req.Status__c = 'Waived';
                                    reqsToUpsert.add(req);
                                    for (Project_Task__c pt : req.Project_Tasks__r) {
                                        if (pt.Status__c != 'Completed' && pt.Status__c != 'Waived') {
                                            pt.Status__c = 'Waived';
                                            tasksToUpdate.add(pt);
                                        }
                                    }
                                }
                            }
                        }
                    }
				}                
            }

            if (reqsToUpsert.size() > 0) {
                upsert reqsToUpsert;
            }

            if (tasksToUpdate.size() > 0) {
                update tasksToUpdate;
            }
        }

    }

    public static boolean createdRequirements = false;
    public static void CreateCurrentConditions(List<Lead> newList, Map<Id, Lead> oldMap) {
        //the Requirements should be created just once.
        //This code is executed several times in an Afterupdate
        if (!createdRequirements) {
            List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();

            Map<Id, Set<String>> req_codes_map = new Map<Id, Set<String>>();
            for (Current_Conditions__c r : [select Id, Lead__c, Code__c from Current_Conditions__c where Lead__c IN :newList]) {
                if (!req_codes_map.containsKey(r.Lead__c)) {
                    req_codes_map.put(r.Lead__c, new Set<String>());
                }
                req_codes_map.get(r.Lead__c).add(r.Code__c);
            }

            Map<String, Schema.RecordTypeInfo> recTypes = Schema.SObjectType.Lead.getRecordTypeInfosByName();
            List<Lead_Current_Contitions_Rule__mdt> rules = [SELECT Lead_Status__c, Record_Type__c, Other_Conditions__c, Code__c FROM Lead_Current_Contitions_Rule__mdt];

            for (Lead ld : newList) {

                if (!ld.isconverted) {

                    if (ld.Status != oldMap.get(ld.Id).Status) {

                        // Don't allow requirements to be created if they already exist on the lead.
                        // Get requirement codes that exist on the lead. If they already exist, skip them
                        Set<String> req_codes = new Set<String>();
                        if (req_codes_map.containsKey(ld.Id)) {
                            req_codes = req_codes_map.get(ld.Id);
                        }

                        for (Lead_Current_Contitions_Rule__mdt rule : rules) {
                            boolean match = true;
                            if (ld.Status != rule.Lead_Status__c) {
                                match = false;
                            }
                            if (ld.RecordTypeId != recTypes.get(rule.Record_Type__c).getRecordTypeId()) {
                                match = false;
                            }
                            if (rule.Other_Conditions__c != null && rule.Other_Conditions__c != '') {
                                if (!checkConditions(ld, rule.Other_Conditions__c)) {
                                    match = false;
                                }
                            }
                            if (match) {
                                if (!req_codes.contains(rule.Code__c)) {
                                    reqsForInsert.add(new Current_Conditions__c(Lead__c = ld.Id, Code__c = rule.Code__c));
                                }
                            }
                        }
                    }

                }

            }

            if (reqsForInsert.size() > 0 && !createdRequirements) {
                insert reqsForInsert;
                createdRequirements = true;
            }
        }
    }
    public static boolean checkConditions(Lead ld, String condition) {
        if (condition.contains('||')) {
            List<String> conditions = condition.split('||', 2);
            string condition1 = conditions[0].trim();
            string condition2 = conditions[1].trim();
            return checkConditions(ld, condition1) || checkConditions(ld, condition2);
        }
        if (condition.contains('&&')) {
            List<String> conditions = condition.split('&&', 2);
            string condition1 = conditions[0].trim();
            string condition2 = conditions[1].trim();
            return checkConditions(ld, condition1) && checkConditions(ld, condition2);
        }
        string operator;
        if (condition.contains('==')) {
            operator = '==';
        }
        if (condition.contains('!=')) {
            operator = '!=';
        }
        if (condition.contains('>')) {
            operator = '>';
        }
        if (condition.contains('<')) {
            operator = '<';
        }
        if (operator != null) {
            List<String> parts = condition.split(operator, 2);
            string field = parts[0].trim();
            string valueStr = parts[1].trim();

            object fieldVal = ld.get(field);

            if (valueStr == 'null') { // Handle nulls
                if (operator == '==') {
                    return (fieldVal == null);
                }
                if (operator == '!=') {
                    return (fieldVal != null);
                }
                return false;
            }

            if (valueStr.toLowerCase() == 'true' || valueStr.toLowerCase() == 'false') { // Handle booleans
                boolean value = Boolean.valueOf(valueStr.toLowerCase());
                if (operator == '==') {
                    return (fieldVal == value);
                }
                if (operator == '!=') {
                    return (fieldVal != value);
                }
                return false;
            }

            if (valueStr.startsWith('\'') && valueStr.endsWith('\'')) { // Handle strings
                string value = valueStr.substring(1, valueStr.length() - 1);
                if (operator == '==') {
                    return (fieldVal == value);
                }
                if (operator == '!=') {
                    return (fieldVal != value);
                }
                if (operator == '>') {
                    return ((String)fieldVal > value);
                }
                if (operator == '<') {
                    return ((String)fieldVal < value);
                }
                return false;
            }

            boolean isDecimal = false; // Handle numbers
            try {
                Decimal.valueOf(valueStr);
                isDecimal = true;
            } catch (Exception ex) {}
            if (isDecimal) {
                decimal value = Decimal.valueOf(valueStr);
                if (operator == '==') {
                    return (fieldVal == value);
                }
                if (operator == '!=') {
                    return (fieldVal != value);
                }
                if (operator == '>') {
                    return ((decimal)fieldVal > value);
                }
                if (operator == '<') {
                    return ((decimal)fieldVal < value);
                }
                return false;
            }
        }
        return false;
    }
}