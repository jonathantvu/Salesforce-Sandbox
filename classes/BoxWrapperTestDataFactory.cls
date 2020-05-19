@isTest
public class BoxWrapperTestDataFactory {
    public static Lead createLead(){
        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'test@test.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Company';
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'TestCode';
        insert newLead;
        
        return newLead;
    }
    
    public static Opportunity createOpp(){
        Date cDate = System.today() + 30;
        Account acct = createAccount();
        Opportunity newOpp = new Opportunity(
        	RecordTypeId='012E00000002OHB',
            Name='testing opp',
            StageName='Submit to Ops',
            CloseDate=cDate,
			AccountId=acct.Id            
        );
        insert newOpp;
        return newOpp;
    }
    
    public static Account createAccount(){
        Account newAcct = new Account(
        	Name='testing acct',
            RecordTypeId='012E00000002OGX'
        );
        insert newAcct;
        return newAcct;
    }
    
    public static Document_MetaData__c createDMD(Id lead, Id opp, Id req){
        Document_MetaData__c dmd = new Document_MetaData__c(
        	Lead__c = lead,
            Opportunity__c = opp,
            Requirement__c = req,
            Box_Folder_Id__c = '123456'
        );
        insert dmd;
        return dmd;
    }
    
    public static Current_Conditions__c createRequirement(Id lead, Id opp){
        Success_Factor__c successFactor = createSuccessFactor(lead, opp);
        Current_Conditions__c req = new Current_Conditions__c(
        	Requirement__c='R1041',
            Success_Factor__c=successFactor.Id,
            Lead__c=lead,
            Opportunity__c=opp
        );
        insert req;
        return req;
    }
    
    public static Success_Factor__c createSuccessFactor(Id lead, Id opp){
        Success_Factor__c successFactor = new Success_Factor__c(
        	Lead__c=lead,
            Opportunity__c=opp
        );
        insert successFactor;
        return successFactor;
    }
    
    public static ContentDocumentLink createCVAndCDL(Id linkedEntityId){
        Blob cvData = Blob.valueOf('testing w/ base64 encode');
        
        // Create a ContentVersion (and automatically a ContentDocument)
        ContentVersion cv = new ContentVersion();
        cv.Title = 'testing.pdf';
        //cv.FileExtension = '.pdf';
        cv.PathOnClient = 'test';
        cv.VersionData = cvData;
        Insert cv;
        
		ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
		
        // Create a ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = testcontent.contentdocumentid;
        cdl.LinkedEntityId = linkedEntityId;
        cdl.ShareType = 'I';
        Insert cdl;
        
        return cdl;
    }
    
}