/**
 * Created by Carolina Veliz on 5/31/2019.
 */

public with sharing class LeadUploadDMD {

    public Document_MetaData__c theDMD  {get;set;}
    public ContentVersion theDocument  {get;set;}
    public transient blob theBlob  {get;set;}
    public string FileNameToAttach {get;set;}
    private final id theLeadId;
    public string selectedValue { get; set; }

    public List<SelectOption> conditionList{
        get {
            conditionList = new List<SelectOption>();
            conditionList.add(new SelectOption('-None-','-None-'));

            List<EOS_Requirements__mdt> eosReq = [select label, RequirementName__c
            from EOS_Requirements__mdt
            order by RequirementName__c];
            if (eosReq.size()>0 ){
                Map<string,string>  reqMDs = new Map<string,string>();
                for ( EOS_Requirements__mdt r : eosReq)
                {
                    reqMDs.put(r.label, r.RequirementName__c);
                }

                for(Current_Conditions__c item : [SELECT id, name, code__c, Requirement__c FROM Current_Conditions__c WHERE Lead__c =: theLeadid]){
                    string reqMD = reqMDs.get(item.code__c);
                    if (string.isNotEmpty(reqMD)) {
                        conditionList.add(new SelectOption(item.id, reqMD));
                    }
                    else{
                        if(item.Code__c == null || item.Code__c == '') {
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Requirement: '+ item.Requirement__c + ' code is missing.');
                            ApexPages.addMessage(msg);
                        } else {
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Requirement: '+ item.Requirement__c + ' Code: ' + item.code__c + ', does not exist in EOS Requirement' );
                            ApexPages.addMessage(msg);
                        }
                    }
                }
            }
            return conditionList;
        }
        set;
    }

    public LeadUploadDMD(ApexPages.StandardController sc){
        theDMD = new  Document_MetaData__c ();
        theLeadId = System.currentPagereference().getParameters().get('LeadId');

        this.theDMD  = (Document_MetaData__c)sc.getRecord();
        theDMD.Lead__c = theLeadId;
        theDocument = new ContentVersion();

    }

    public PageReference save(){
        List<ContentDocumentLink> contentDocumentLink = [SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId =: theLeadId];
        Set<Id> contentDocIds = new Set<Id>();
        for(ContentDocumentLink cdl : contentDocumentLink) {
            contentDocIds.add(cdl.ContentDocumentId);
        }
        ContentDocument contentDocument = [SELECT Id, CreatedDate FROM ContentDocument
        WHERE Id IN : contentDocIds
        ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('contentDocument ' + contentDocument);

        //if(String.isNotEmpty(FileNameToAttach)) {
        theDMD.Upload_Date__c = system.now();
        theDMD.Uploaded__c = true;
        if (string.isEmpty(theDMD.Document_Description__c))
            theDMD.Document_Description__c = FileNameToAttach;
        if (selectedValue != '-None-') {
            theDMD.Requirement__c = selectedValue;
        }
        if(theDMD.Requirement__c == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Requirement must be selected to upload a document.');
            ApexPages.addMessage(msg);
            return null;
        }
        insert theDMD;
        //ContentDocumentLink cdlToDelete = new ContentDocumentLink();
        for(ContentDocumentLink cdl : contentDocumentLink) {
            if(cdl.ContentDocumentId == contentDocument.Id) {
                //cdlToDelete.Id = cdl.Id;
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
        //delete cdlToDelete;
        return new PageReference('/' + theLeadId);

        /*   theDocument.VersionData = theBlob;
           system.debug('theBlob: ' + theBlob);
           system.debug('theDocument.VersionData: ' + theDocument.VersionData);

           theDocument.ContentLocation = 'S';
           theDocument.Title = FileNameToAttach;
           theDocument.PathOnClient = FileNameToAttach;
           //insert theDocument;*/

        //Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :theDocument.Id].ContentDocumentId;
        //    ContentDocumentLink cdl = new ContentDocumentLink();
        // cdl.ContentDocumentId = conDoc;
        //   cdl.LinkedEntityId = theDMD.Id;
        //  cdl.ShareType = 'V';
        // cdl.Visibility = 'AllUsers';
        //if( !test.isRunningTest())
        // insert cdl;
        // return new PageReference('/' + theDMD.Lead__c);
        /*}
        else if(theBlob == null){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select a file to upload.');
                ApexPages.addMessage(msg);
                return null;
        }*/


        /*  }else{
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select a file.');
              ApexPages.addMessage(msg);
              return null;
          }*/
        //return null;
        //   return new PageReference('/' + theLeadId);
    }

    public PageReference cancel(){
        return new PageReference('/' + theLeadid );
    }
}