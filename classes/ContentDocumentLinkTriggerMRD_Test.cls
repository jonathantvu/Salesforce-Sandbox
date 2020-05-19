@isTest 
public class ContentDocumentLinkTriggerMRD_Test {
    @isTest static void TestInsertDelete() {
    	Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock());
        
        Test.startTest();
        Lead lead = new Lead(LastName = 'Test', Email = 'test@unison.com', mobilephone = '+1234567890', Company = 'Test company');
        insert lead;
        
        // Try creating an MRD
        Minimum_Required_Documents__c mrd = new Minimum_Required_Documents__c(Lead__c=lead.id, Category__c='W2', Applicant_Type__c='Applicant');
        insert mrd;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Title',
            PathOnClient = 'Test.doc',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = mrd.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Minimum_Required_Documents__c myMrd = [SELECT Id, Uploaded__c FROM Minimum_Required_Documents__c WHERE Id =:mrd.Id];
        system.assertEquals(true, myMrd.Uploaded__c);
        
        delete cdl;
        
        system.assertEquals(false, mrd.Uploaded__c);
        Test.stopTest();
    }

}