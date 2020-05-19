trigger ContentDocumentLinkTriggerMRD on ContentDocumentLink ( after insert, after update, after delete ) {

    //TO DO: Need to combine abstract all of this as a trigger handler class and combine with ContentDocumentLinkTrigger

    List<ContentDocumentLink> cdls = ( Trigger.new == null ? Trigger.old : Trigger.new ); //TO DO: Better to seperate out the logic and have handler class deal with this

    List<Minimum_Required_Documents__c> mrdList = new List<Minimum_Required_Documents__c>();

    set<id> parentIds = new set<id>();

    for ( ContentDocumentLink cdl : cdls ) {
        parentIds.add( cdl.LinkedEntityId );
    }

    //List<Minimum_Required_Documents__c> mrdList2 = [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Minimum_Required_Documents__c WHERE Id IN :parentIds ORDER BY Lead__c ];

    List<Minimum_Required_Documents__c> mrd = [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Minimum_Required_Documents__c WHERE Id IN :parentIds ORDER BY Lead__c ];

    /*for ( List<Minimum_Required_Documents__c> mrd : [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Minimum_Required_Documents__c WHERE Id IN :parentIds ORDER BY Lead__c ] ) {*/
    system.debug('mrd---' + mrd);
    for ( Minimum_Required_Documents__c m : mrd ) {
        m.Uploaded__c = ( m.ContentDocumentLinks.size() > 0 );
        mrdList.add(m);
    }
    //update mrd; This was not bulkified
    //}
    if(!mrdList.isEmpty()){
        update mrdList;

    }

}