public class ContentDocumentLinkTriggerHandler{

    public static void onAfterInsert(List<ContentDocumentLink> newcdllist){
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        Set<Id> cId = new Set<Id>();
        Set<Id> oppids = new Set<Id>();
        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        System.debug('*****inside Trigger****');
        List<Opportunity> updopplist = new List<Opportunity>();
        for(ContentDocumentLink cdl: newcdllist){
            system.debug('*****cdl*******'+cdl);
            //String Id = cdl.LinkedEntityId;
            System.debug('****checking LinkedEntityId*****');
            if(cdl.LinkedEntityId != Null && String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'Opportunity') {
                cId.add(cdl.ContentDocumentId);
                oppids.add(cdl.LinkedEntityId);                                   
            }           
        }
        system.debug('*****cId*******'+cId);
        system.debug('*****oppids*******'+oppids);
        
        if(cId.size() > 0 && oppids.size() > 0){
            System.debug('**** Querying CDL for Title****'); 
            List<ContentDocumentLink> docList = [Select ContentDocumentId, linkedentityid, ContentDocument.Title 
                                                 from ContentDocumentLink 
                                                 Where ContentDocumentId =: cId and linkedentityid =: oppids];
           system.debug('******docList*****'+docList);
                                                      
               List<Current_Conditions__c> reqlist = [Select Id, Requirement__c, Opportunity__c from Current_Conditions__c where opportunity__c =: oppids];
                
                for(ContentDocumentLink cdl: docList){
                    for(Current_Conditions__c req: reqlist) {
                        
                        system.debug('******cdl*****'+cdl);
                        if(cdl.ContentDocument.Title.contains('ClosingDocuments') && req.Requirement__c == 'Closing') {
                                      
                            Document_MetaData__c d = new Document_MetaData__c();
                            d.Requirement__c           = req.Id;
                            d.Document_Type__c         = 'Closing Documents';
                            //d.Category__c              = 'Credit';
                            d.Opportunity__c           = req.Opportunity__c;
                            dmdlist.add(d);
            
                        }  else if(cdl.ContentDocument.Title.contains('HOOfferPackage') && req.Requirement__c == 'Offer Package') {
                                      
                            Document_MetaData__c d = new Document_MetaData__c();
                            d.Requirement__c           = req.Id;
                            d.Document_Type__c         = 'Offer Package';
                            //d.Category__c              = 'Credit';
                            d.Opportunity__c           = req.Opportunity__c;
                            dmdlist.add(d);
            
                        } else if(cdl.ContentDocument.Title.contains('RSI Letter') && req.Requirement__c == 'RSI Letter') {
                                      
                            Document_MetaData__c d = new Document_MetaData__c();
                            d.Requirement__c           = req.Id;
                            d.Document_Type__c         = 'RSI Letter';
                            //d.Category__c              = 'Credit';
                            d.Opportunity__c           = req.Opportunity__c;
                            dmdlist.add(d);
            
                        } else if(cdl.ContentDocument.Title.contains('HBCAP') && req.Requirement__c == 'CAP Completed') {
                                      
                            Document_MetaData__c d = new Document_MetaData__c();
                            d.Requirement__c           = req.Id;
                            d.Document_Type__c         = 'CAP Completed';
                            //d.Category__c              = 'Credit';
                            d.Opportunity__c           = req.Opportunity__c;
                            dmdlist.add(d);
            
                        } else if(cdl.ContentDocument.Title.contains('ClosingDocuments') && req.Requirement__c == 'HB Closing Tasks') {
                                      
                            Document_MetaData__c d = new Document_MetaData__c();
                            d.Requirement__c           = req.Id;
                            d.Document_Type__c         = 'Closing Documents';
                            //d.Category__c              = 'Credit';
                            d.Opportunity__c           = req.Opportunity__c;
                            dmdlist.add(d);
            
                        }
                   }  
                   
                   if(dmdlist.size() > 0) {
                       insert dmdlist;
                   }
                   
                   for(Document_MetaData__c d: dmdlist) {
                       if(cdl.ContentDocument.Title.contains('ClosingDocuments') && d.Document_Type__c == 'Closing Documents') {
                            ContentDocumentLink cd = new ContentDocumentLink();
                            cd.ContentDocumentId = cdl.ContentdocumentId;
                            cd.LinkedEntityId = d.id;
                            cd.ShareType = 'V';
                            cd.Visibility = 'AllUsers';
                            cdllist.add(cd);
                            
                            /*Opportunity opp = new Opportunity();
                            opp.Id = cdl.LinkedEntityid;
                            opp.Closing_Document_Created_Date_Time__c = system.Now();
                            updopplist.add(opp);  */  
                       } else if(cdl.ContentDocument.Title.contains('HOOfferPackage') && d.Document_Type__c == 'Offer Package') {
                            ContentDocumentLink cd = new ContentDocumentLink();
                            cd.ContentDocumentId = cdl.ContentdocumentId;
                            cd.LinkedEntityId = d.id;
                            cd.ShareType = 'V';
                            cd.Visibility = 'AllUsers';
                            cdllist.add(cd);
                            
                            /*Opportunity opp = new Opportunity();
                            opp.Id = cdl.LinkedEntityid;
                            opp.Closing_Document_Created_Date_Time__c = system.Now();   
                            updopplist.add(opp); */
                       } else if(cdl.ContentDocument.Title.contains('RSI Letter') && d.Document_Type__c == 'RSI Letter') {
                            ContentDocumentLink cd = new ContentDocumentLink();
                            cd.ContentDocumentId = cdl.ContentdocumentId;
                            cd.LinkedEntityId = d.id;
                            cd.ShareType = 'V';
                            cd.Visibility = 'AllUsers';
                            cdllist.add(cd);
                               
                       } else if(cdl.ContentDocument.Title.contains('HBCAP') && d.Document_Type__c == 'CAP Completed') {
                            ContentDocumentLink cd = new ContentDocumentLink();
                            cd.ContentDocumentId = cdl.ContentdocumentId;
                            cd.LinkedEntityId = d.id;
                            cd.ShareType = 'V';
                            cd.Visibility = 'AllUsers';
                            cdllist.add(cd);
                            
                           /* Opportunity opp = new Opportunity();
                            opp.Id = cdl.LinkedEntityid;
                            opp.Closing_Document_Created_Date_Time__c = system.Now(); 
                            updopplist.add(opp);   */
                       } else if(cdl.ContentDocument.Title.contains('ClosingDocuments') && d.Document_Type__c == 'Closing Documents') {
                            ContentDocumentLink cd = new ContentDocumentLink();
                            cd.ContentDocumentId = cdl.ContentdocumentId;
                            cd.LinkedEntityId = d.id;
                            cd.ShareType = 'V';
                            cd.Visibility = 'AllUsers';
                            cdllist.add(cd);
                            
                            /*Opportunity opp = new Opportunity();
                            opp.Id = cdl.LinkedEntityid;
                            opp.Closing_Document_Created_Date_Time__c = system.Now();
                            updopplist.add(opp);  */  
                       }
                   }
               } 
                   
           }           
           
               
       // system.debug('******updopplist*****'+updopplist);
        //system.debug('******cdllist*****'+cdllist);        
       /* if(updopplist.size()>0){
            update updopplist;
        } */
        
        if(cdllist.size() > 0){       
            insert cdllist;
        }             
    }

}