public class AccountUtilityClass {

    private static List<SFDC_to_SFDC_Mapping__mdt> fieldsPrivate;
    public static List<SFDC_to_SFDC_Mapping__mdt> fields {
        get {
            if (fieldsPrivate == null) {
                fieldsPrivate = [SELECT Object__c, Field__c, JSON_Field__c FROM SFDC_to_SFDC_Mapping__mdt];
            }
            return fieldsPrivate;
        }
    }

    @future(callout=true)
    public static void createAccount(set<Id> accids) {

        List<Account> accList = [select Name, (select Id from Opportunities) from Account where id =:accids];

        //Opportunities for the Accounts updated
        Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>((List<Opportunity>)Database.query(BuildQuery('AccountId = :accids')));

        Map<Id, List<Document_Metadata__c>> dmdMap = BuildDocumentMetadataMap(oppMap.keyset());
        Map<Id, List<LASERCA__Trade_Accounts__c>> tasMap = BuildTradeAccountMap(oppMap.keyset());
        Map<Id, List<ContentNote>> cnMap = BuildContentNoteMap(oppMap.keyset());

        if (accList != Null && accList.size() > 0) {

            SendCallout(accList, oppMap, dmdMap, tasMap, cnMap);

        }
    }

    public static String SendCallout(List<Account> accList, Map<Id, Opportunity> oppMap, Map<Id, List<Document_Metadata__c>> dmdMap, Map<Id, List<LASERCA__Trade_Accounts__c>> tasMap, Map<Id, List<ContentNote>> cnMap) {

        DataIntegrationCredential__mdt cred;
        try {
            cred = [SELECT Endpoint__c FROM DataIntegrationCredential__mdt WHERE MasterLabel = :DataIntegrationClass.OrgIdentifier()];
        } catch (Exception ex) {
            SFDC_to_SFDC_Log__c log = DataIntegrationClass.CreateLog('Credentials metadata not found',
                                    'Could not find a DataIntegrationCredential__mdt record with label "' + DataIntegrationClass.OrgIdentifier() + '"', 500);
            log.Error__c = true;
            insert log;
            return 'No credentials found';
        }

        string accoppend = cred.Endpoint__c;

        String accessToken = DataIntegrationClass.ReturnAccessToken();

        Map<Id, String> approvalActorMap = new Map<Id, String>();
        for (ProcessInstance pi : [SELECT  TargetObjectId, LastActor.Name, 
                        (SELECT OriginalActor.Name FROM StepsAndWorkitems WHERE StepStatus != 'Started' LIMIT 1)
                        FROM ProcessInstance WHERE TargetObjectId IN :oppMap.keyset()])
        {
            if (pi.StepsAndWorkitems.size() > 0)
                approvalActorMap.put(pi.TargetObjectId, pi.StepsAndWorkitems[0].OriginalActor.Name);
            else
                approvalActorMap.put(pi.TargetObjectId, pi.LastActor.Name);
        }

        if (accessToken != null) {

            //constructing data to send
            List<AccountWrapper> accdata = new List<AccountWrapper>();
            for (Account acc : accList) {
                List<Opportunity> opplist = new List<Opportunity>();
                if (acc.Opportunities != Null && acc.Opportunities.size() > 0) {
                    for (Opportunity opp : acc.Opportunities) {
                        opplist.add(oppmap.get(opp.Id));
                    }
                }
                accdata.add(new AccountWrapper(acc, opplist, approvalActorMap, dmdMap, tasMap, cnMap));
            }
            string jsonstr = '{"Accounts":' + JSON.serialize(accdata) + '}';

            String endPoint = accoppend;
            
            Http h2 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setHeader('Authorization','Bearer ' + accessToken);
            req1.setHeader('Content-Type','application/json');
            req1.setHeader('accept','application/json');
            req1.setBody(jsonstr);System.debug(jsonStr);
            req1.setMethod('POST');
            req1.setEndpoint(endPoint);
            req1.setTimeout(50000);

            HttpResponse res1 = h2.send(req1);

            SFDC_to_SFDC_Log__c log = DataIntegrationClass.CreateLog(jsonstr, res1.getBody(), res1.getStatusCode());

            PostResult pr;
            try {
                pr = (PostResult)JSON.deserialize(res1.getBody(), PostResult.class);
            } catch(Exception ex) {
                log.Error__c = true;
                insert log;
                insert DataIntegrationClass.accessTokenLog;
                return 'Invalid JSON';
            }
            
            log.Error__c = res1.getStatusCode() != 200 || pr.success == false;
            insert log;
            insert DataIntegrationClass.accessTokenLog;
            
            try {
                if (pr.success && pr.opportunities != null) {
                    List<Opportunity> toUpdate = new List<Opportunity>();
                    for (String keyId : pr.opportunities.keyset()) {
                        toUpdate.add(new Opportunity(Id = keyId, Orissa_Wire_Sync__c = true, SFDC2_Opportunity_Id__c = pr.opportunities.get(keyId)));
                    }
                    if (toUpdate.size() > 0)
                        update toUpdate;
                }
    
                if (res1.getStatusCode() == 200)
                    return 'OK';
                else
                    return pr.error_message;
            } catch(Exception ex) {
                return ex.getMessage();
            }
            
        } else {
            insert DataIntegrationClass.accessTokenLog;
            return 'No accessToken';
        }

    }

    public class PostResult {
        public boolean success { get; set; }
        public string error_message { get; set; }
        public Map<String, String> opportunities { get; set; }
    }

    public static string BuildQuery(String condition) {
        STRING query = 'SELECT Id, RecordType.Name';

        // Opportunity fields
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Opportunity') {
                query += ', ' + field.Field__c;
            }
        }

        // OpportunityContactRole fields
        query += ', ( SELECT Id, Contact.Account.Name FROM OpportunityContactRoles WHERE Role = \'Trustee\' LIMIT 1)';

        // OpportunityLineItem fields
        query += ', ( SELECT Id, Final_Amount__c FROM OpportunityLineItems WHERE Product2.Name = \'Acquisition Fee\' LIMIT 1)';

        // Application fields
        query += ', ( SELECT Id';
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Application') {
                query += ', ' + field.Field__c;
            }
        }
        query += ' FROM Applications__r LIMIT 1)';

        // DMA fields
        query += ', ( SELECT Id';
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'DMA') {
                query += ', ' + field.Field__c;
            }
        }
        query += ' FROM DMAs__r)';

        // Personal Credit Report fields
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Personal Credit Report') {
                query += ', Personal_Credit_Report__r.' + field.Field__c;
            }
        }
        
        // Property fields
        query += ', ( SELECT Id';
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Property') {
                query += ', ' + field.Field__c;
            }
        }
        query += ' FROM Properties__r LIMIT 1)';
        
        // Recorded Information fields
        query += ', ( SELECT Id';
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Recorded Information') {
                query += ', ' + field.Field__c;
            }
        }
        query += ' FROM Recorded_Informations__r LIMIT 1)';
        
        // Trade Account fields
        // Moved this part in the BuildTradeAccountMap method, since the link between Opportunity and Trade Account is not direct

        // Appraisal fields
        query += ', ( SELECT Id';
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Appraisal') {
                query += ', ' + field.Field__c;
            }
        }
        query += ' FROM Appraisals__r LIMIT 1)';

        // Document MetaData fields
        // Moved this part in the BuildDocumentMetadataMap method, since there are too many child records and we get this error:
        // "Aggregate query has too many rows for direct assignment, use FOR loop"

        // Note fields
        query += ', ( SELECT Id, Title, Body, ParentId from Notes)';
        
        // Content Note fields
        // Moved this part in the BuildContentNoteMap method, since the link between Opportunity and ContentNote is not direct

        query += ' FROM Opportunity WHERE ' + condition;
        
        return query;
    }

    public static Map<Id, List<LASERCA__Trade_Accounts__c>> BuildTradeAccountMap(Set<Id> oppIds) {
        Map<Id, List<LASERCA__Trade_Accounts__c>> toReturn = new Map<Id, List<LASERCA__Trade_Accounts__c>>();
       
        for (Id oppId : oppIds) {
            toReturn.put(oppId, new List<LASERCA__Trade_Accounts__c>());
        }
        
        Map<Id, Id> pcrToOppMap = new Map<Id, Id>();
        for (Opportunity opp : [SELECT Id, Personal_Credit_Report__c FROM Opportunity WHERE Id IN :oppIds]) {
            if (opp.Personal_Credit_Report__c != null) {
                pcrToOppMap.put(opp.Personal_Credit_Report__c, opp.Id);
            }
        }
        Set<Id> pcrIds = pcrToOppMap.keyset();

        string query = 'SELECT Id, LASERCA__Personal_Credit_Report__c';
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Trade Account') {
                query += ', ' + field.Field__c;
            }
        }
        query += ' FROM LASERCA__Trade_Accounts__c WHERE LASERCA__Personal_Credit_Report__c IN :pcrIds ' +
            	'AND ((Credit_Loan_Type_pick__c = \'Mortgage\' AND LASERCA__Account_Status_Type__c = \'Open\' AND To_Close_Account__c = FALSE ) OR Credit_Loan_Type_pick__c = \'Other_Lien\')';

        for (LASERCA__Trade_Accounts__c ta : Database.query(query)) {
            Id pcrId = ta.LASERCA__Personal_Credit_Report__c;
            if (pcrToOppMap.containsKey(pcrId)) {
            	toReturn.get(pcrToOppMap.get(pcrId)).add(ta);
            }
        }

        return toReturn;
    }

    public static Map<Id, List<Document_MetaData__c>> BuildDocumentMetadataMap(Set<Id> oppIds) {
        Map<Id, List<Document_MetaData__c>> toReturn = new Map<Id, List<Document_MetaData__c>>();
       
        for (Id oppId : oppIds) {
            toReturn.put(oppId, new List<Document_MetaData__c>());
        }

        string query = 'SELECT Id, Opportunity__c';
        for (SFDC_to_SFDC_Mapping__mdt field : fields) {
            if (field.Object__c == 'Document MetaData') {
                query += ', ' + field.Field__c;
            }
        }
        query += ' FROM Document_MetaData__c WHERE Opportunity__c IN :oppIds';

        for (Document_MetaData__c dmd : Database.query(query)) {
            toReturn.get(dmd.Opportunity__c).add(dmd);
        }

        return toReturn;
    }
    
    public static Map<Id, List<ContentNote>> BuildContentNoteMap(Set<Id> oppIds) {
        Map<Id, List<ContentNote>> toReturn = new Map<Id, List<ContentNote>>();
       
        for (Id oppId : oppIds) {
            toReturn.put(oppId, new List<ContentNote>());
        }

        Map<Id, Id> contentDocOppMap = new Map<Id, Id>(); // ContentDocument Id => OpportunityId
        for (ContentDocumentLink eachCDLink : [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID IN :oppIds]) {
            contentDocOppMap.put(eachCDLink.ContentDocumentId, eachCDLink.LinkedEntityId);
        }

        for (ContentNote cn : [SELECT ID, Title, Content FROM ContentNote WHERE Id IN :contentDocOppMap.keyset()]) {
            toReturn.get(contentDocOppMap.get(cn.Id)).add(cn);
        }

        return toReturn;
    }

    public class AccountWrapper{
        public string Id;
        public string Name;
        public List<Object> newopplist;

        public AccountWrapper(Account acc, List<Opportunity> opplist, Map<Id, String> approvalActorMap, Map<Id, List<Document_Metadata__c>> dmdMap, Map<Id, List<LASERCA__Trade_Accounts__c>> tasMap, Map<Id, List<ContentNote>> cnMap) {
            Id = acc.Id;
            name = acc.Name;
            newopplist = new List<Object>();
            
            if (opplist != Null && opplist.size() > 0) {
                for (Opportunity opp : opplist) {
                    newopplist.add(BuildOpportunity(opp, approvalActorMap, dmdMap, tasMap, cnMap));
                }
            }
        }

        private Map<String, Object> BuildOpportunity(Opportunity opp, Map<Id, String> approvalActorMap, Map<Id, List<Document_Metadata__c>>dmdMap, Map<Id, List<LASERCA__Trade_Accounts__c>> tasMap, Map<Id, List<ContentNote>> cnMap) {

            Map<String, Object> toReturn = new Map<String, Object>();

            // Opportunity data
            toReturn.put('Id', opp.Id);
            toreturn.put('recordtypeName', opp.RecordType.Name);
            if (opp.Account.Latest_Opportunity_Id__c != null) {
                toReturn.put('acctrackid', opp.Account.Latest_Opportunity_Id__c);
            }
            if (approvalActorMap.containsKey(opp.Id)) {
                toReturn.put('IMApprover', approvalActorMap.get(opp.Id));
            }
            for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                if (field.Object__c == 'Opportunity' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                    toReturn.put(field.JSON_Field__c, opp.get(field.Field__c));
                }
            }

            // Application data
            if (opp.Applications__r != null && opp.Applications__r.size() > 0) {
                for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                    if (field.Object__c == 'Application' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                        toReturn.put(field.JSON_Field__c, opp.Applications__r[0].get(field.Field__c));
                    }
                }
            }

            // OpportunityContactRole -> for trustee
            if (opp.OpportunityContactRoles != null && opp.OpportunityContactRoles.size() > 0) {
                toReturn.put('ottrustee', opp.OpportunityContactRoles[0].Contact.Account.Name);
            }

            // OpportunityLineItem -> for acquisition fee
            if (opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 0) {
                toReturn.put('olifinalamount', opp.OpportunityLineItems[0].Final_Amount__c);
            }

            // Personal Credit Report data
            if (opp.Personal_Credit_Report__r != Null) {
                for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                    if (field.Object__c == 'Personal Credit Report' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                        toReturn.put(field.JSON_Field__c, opp.Personal_Credit_Report__r.get(field.Field__c));
                    }
                }
            }

            // Property data
            if (opp.Properties__r != Null && opp.Properties__r.size() > 0) {
                for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                    if (field.Object__c == 'Property' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                        toReturn.put(field.JSON_Field__c, opp.Properties__r[0].get(field.Field__c));
                    }
                }
            }

            // Recorded Information data
            if (opp.Recorded_Informations__r != Null && opp.Recorded_Informations__r.size() > 0) {
                for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                    if (field.Object__c == 'Recorded Information' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                        toReturn.put(field.JSON_Field__c, opp.Recorded_Informations__r[0].get(field.Field__c));
                    }
                }
            }

            // Appraisal data
            if (opp.Appraisals__r != Null && opp.Appraisals__r.size() > 0) {
                for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                    if (field.Object__c == 'Appraisal' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                        toReturn.put(field.JSON_Field__c, opp.Appraisals__r[0].get(field.Field__c));
                    }
                }
            }

            // DMD Data
            List<Object> dmddata = new List<Object>();
            if (dmdMap.containsKey(opp.Id) && dmdMap.get(opp.Id).size() > 0) {
                for (Document_MetaData__c dmd : dmdMap.get(opp.Id)) {
                    Map<String, Object> dmdObj = new Map<String, Object>();
                    dmdObj.put('Id', dmd.Id);
                    for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                        if (field.Object__c == 'Document MetaData' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                            dmdObj.put(field.JSON_Field__c, dmd.get(field.Field__c));
                        }
                    }
                    dmddata.add(dmdObj);
                }
            }
            toReturn.put('dmddata', dmddata);

            // DMA Data
            List<Object> dmadata = new List<Object>();
            if (opp.DMAs__r != Null && opp.DMAs__r.size() > 0) {
                for (DMA__c dma : opp.DMAs__r) {
                    Map<String, Object> dmaObj = new Map<String, Object>();
                    dmaObj.put('Id', dma.Id);
                    for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                        if (field.Object__c == 'DMA' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                            dmaObj.put(field.JSON_Field__c, dma.get(field.Field__c));
                        }
                    }
                    dmadata.add(dmaObj);
                }
            }
            toReturn.put('dmadata', dmadata);

            // Trade Account Data
            List<Object> taccdata = new List<Object>();
            if (tasMap.containsKey(opp.Id) && tasMap.get(opp.Id).size() > 0) {
                for (LASERCA__Trade_Accounts__c tacc : tasMap.get(opp.Id)) {
                    Map<String, Object> taccObj = new Map<String, Object>();
                    taccObj.put('Id', tacc.Id);
                    for (SFDC_to_SFDC_Mapping__mdt field : AccountUtilityClass.fields) {
                        if (field.Object__c == 'Trade Account' && field.JSON_Field__c != null && field.JSON_Field__c.trim() != '') {
                            taccObj.put(field.JSON_Field__c, tacc.get(field.Field__c));
                        }
                    }
                    taccdata.add(taccObj);
                }
            }
            toReturn.put('taccdata', taccdata);

            // Note Data
            List<Object> notesdata = new List<Object>();
            if (opp.Notes != null && opp.Notes.size() > 0) {
                for (Note nt : opp.Notes) {
                    Map<String, Object> noteObj = new Map<String, Object>();
                    noteObj.put('Id', nt.Id);
                    noteObj.put('noteTitle', nt.Title);
                    noteObj.put('noteBody', nt.Body);
                    notesdata.add(noteObj);
                }
            }
            toReturn.put('notesdata', notesdata);

            // ContentNote Data
            List<Object> contentnotesdata = new List<Object>();
            if (cnMap.containsKey(opp.Id) && cnMap.get(opp.Id).size() > 0) {
                for (ContentNote cn : cnMap.get(opp.Id)) {
                    if (cn.Content != null && cn.Content.toString() != null) {
                        Map<String, Object> cnObj = new Map<String, Object>();
                        cnObj.put('Id', cn.Id);
                        cnObj.put('noteTitle', cn.Title);
                        cnObj.put('noteContent', cn.Content.toString().replaceAll('<img[^>]*>', '[IMAGE IN EOS]').replaceAll('</img>', ''));
                        contentnotesdata.add(cnObj);
                    }
                }
            }
            toReturn.put('contentnotesdata', contentnotesdata);

            return toReturn;
        }
    }

}