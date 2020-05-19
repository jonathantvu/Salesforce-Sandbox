trigger BoxContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    //Initialize list of ContentVersions which will eventually be passed 
    //to BoxWrapper for processing
    List<Id> cvIds = new List<Id>();
    
    //Iterate through each ContentDocumentLink to find any that point to a DMD
    for (ContentDocumentLink cdl_ref: Trigger.new){

        if (String.valueOf(cdl_ref.LinkedEntityId.getSobjectType()) == 'Document_MetaData__c'){
            
            //Query for the ContentVersion and ContentDocumentId
            ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion 
            WHERE ContentDocumentId = :cdl_ref.ContentDocumentId LIMIT 1];
            cvIds.add(cv.Id);
            
            //check if a DMD has already been uploaded to (or is in the process of such)
            Document_MetaData__c dmd = [SELECT Id, Box_File_URL__c, Lead__c, Opportunity__c, Requirement__c, 
            Account_Name__c, Available_for_Customer_IM__c, Available_for_Internal_Users__c, 
            Available_for_Investors__c, Available_for_Partner_Portal__c, Category__c, Document_Type__c, 
            Document_Year__c, Minimum_Required_Documents__c FROM Document_MetaData__c WHERE Id = :cdl_ref.LinkedEntityId];
            
            if (!String.isBlank(dmd.Box_File_URL__c)){
                system.debug('****Blank box file URL**********');
                //if it has, then we need to create a (limited) clone of it and point the current ContentDocumentLink to that clone
                Document_MetaData__c dmdClone = dmd.clone(false, false, false, false);
                //dmdClone.Box_File_Id__c = null;
                dmdClone.Box_File_URL__c = 'Upload in progress....';
                //dmdClone.Box_Folder_Id__c = null;
                //dmdClone.AWS_id__c = null;
                dmdClone.Customer_Uploaded__c = false;
                System.debug('dmd cloning in progress, id: ' + dmdClone.Id);
                insert dmdClone;
                System.debug('dmd cloning complete, id: ' + dmdClone.Id);
                cdl_ref.LinkedEntityId = dmdClone.Id;
                                
            } else {
                //if not, then we mark it as an upload in progress
                system.debug('*******Not Blank box file URL**********');
                dmd.Box_File_URL__c = 'Upload in progress...';
                update dmd;
            } 
            
        } 
    }
    
    if (cvIds.size() > 0){
        //Pass all ContentVersionIds to BoxWrapper for uploading and
        //Box URL writeback
        system.debug('******BoxWrapper********');
        //BoxWrapper.handleAttachments(cvIds);
    }
}