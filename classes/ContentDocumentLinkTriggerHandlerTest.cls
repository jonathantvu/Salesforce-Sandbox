@isTest(seealldata=true)
public class ContentDocumentLinkTriggerHandlerTest{

    @isTest
    static void datacreate(){
       Test.setMock(HttpCalloutMock.class, new SFDC2SFDCAPIMock()); 
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
                
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.Estimated_Funding_Amount__c  = 2;
        newOpportunity.Pricing_Ratio__c  = 2;
        newOpportunity.Final_OAV_Calculation__c = 4;
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
          /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup       
        newOpportunity.Billboard_Property_Approval__c = true;           
*/
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.Estimated_Funding_Amount__c = 2;
		newOpportunity.Pricing_Ratio__c = 2;
		newOpportunity.Final_OAV_Calculation__c = 4;
        insert newOpportunity;     
        
        Success_Factor__c sf = new Success_Factor__c();
        sf.Opportunity__c = newOpportunity.Id;
        sf.Status__c = 'In Progress';
        sf.Success_Factor__c = 'Closing';
        sf.Program__c = 'HO';
        insert sf;
        
        Current_Conditions__c req = new Current_Conditions__c();
        req.Opportunity__c = newOpportunity.Id;
        req.Requirement__c = 'Closing';
        req.Code__c = 'R1018';
        req.Category__c = 'Mortgage';
        req.Internal_vs_External__c = 'Internal';
        //req.Assigned_To__c = 'PS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        req.Success_Factor__c = sf.Id;
        
        insert req;
        system.debug('++++++req '+ req);
        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        
        Document_MetaData__c dmd = new Document_MetaData__c();
        dmd.Opportunity__c = newOpportunity.Id;
        dmd.Requirement__c = req.Id;
        dmd.Document_Type__c = 'Closing Documents';
        dmdlist.add(dmd);
        
        insert dmdlist;
        
        List<ContentVersion> cvlist = new List<ContentVersion>();
        
        ContentVersion cv = new ContentVersion(
            Title = 'ClosingDocuments',
            PathOnClient = 'Test.doc',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        cvlist.add(cv);
        
        insert cvlist;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = newOpportunity.Id;
        cdl.ContentDocumentId = documents[0].Id;
        //cdl.ContentDocument.Title  = 'ClosingDocuments';
        cdl.shareType = 'V';
        cdllist.add(cdl);
        
        Test.starttest();
        insert cdllist; 
        Test.stoptest();
       
    }
    
    @isTest
    static void datacreate1(){
        Test.setMock(HttpCalloutMock.class, new SFDC2SFDCAPIMock());
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
                
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
                 /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup
        newOpportunity.Billboard_Property_Approval__c = true;           
*/
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.Estimated_Funding_Amount__c = 2;
		newOpportunity.Pricing_Ratio__c = 2;
		newOpportunity.Final_OAV_Calculation__c = 4;
        insert newOpportunity;     
        
        Success_Factor__c sf = new Success_Factor__c();
        sf.Opportunity__c = newOpportunity.Id;
        sf.Status__c = 'In Progress';
        sf.Success_Factor__c = 'Closing';
        sf.Program__c = 'HO';
        insert sf;
        
        Current_Conditions__c req = new Current_Conditions__c();
        req.Opportunity__c = newOpportunity.Id;
        req.Requirement__c = 'Offer Package';
        req.Code__c = 'R1072';
        req.Category__c = 'Mortgage';
        req.Internal_vs_External__c = 'Internal';
        //req.Assigned_To__c = 'PS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        req.Success_Factor__c = sf.Id;
        
        insert req;
        system.debug('++++++req '+ req);
        
        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        
        Document_MetaData__c dmd1 = new Document_MetaData__c();
        dmd1.Opportunity__c = newOpportunity.Id;
        dmd1.Requirement__c = req.Id;
        dmd1.Document_Type__c = 'Offer Package';
        dmdlist.add(dmd1);
        
        insert dmdlist;
        
        List<ContentVersion> cvlist = new List<ContentVersion>();
        
        ContentVersion cv1 = new ContentVersion(
            Title = 'HOOfferPackage',
            PathOnClient = 'Test.doc',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        cvlist.add(cv1);
        
        insert cvlist;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = newOpportunity.Id;
        cdl1.ContentDocumentId = documents[0].Id;
        cdl1.shareType = 'V';
        cdllist.add(cdl1);
        
        
        Test.starttest();
        insert cdllist; 
        Test.stoptest(); 
       
    }
    
    @isTest
    static void datacreate2(){
        Test.setMock(HttpCalloutMock.class, new SFDC2SFDCAPIMock());
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
                
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
              /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup       
        newOpportunity.Billboard_Property_Approval__c = true;           
*/
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.Estimated_Funding_Amount__c = 2;
		newOpportunity.Pricing_Ratio__c = 2;
		newOpportunity.Final_OAV_Calculation__c = 4;
        insert newOpportunity;     
        
        Success_Factor__c sf = new Success_Factor__c();
        sf.Opportunity__c = newOpportunity.Id;
        sf.Status__c = 'In Progress';
        sf.Success_Factor__c = 'Program';
        sf.Program__c = 'HO';
        insert sf;
        
        Current_Conditions__c req = new Current_Conditions__c();
        req.Opportunity__c = newOpportunity.Id;
        req.Requirement__c = 'RSI Letter';
        req.Code__c = 'R1104';
        req.Category__c = 'Mortgage';
        req.Internal_vs_External__c = 'Internal';
        //req.Assigned_To__c = 'PS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        req.Success_Factor__c = sf.Id;
        
        insert req;
        system.debug('++++++req '+ req);
        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();

        Document_MetaData__c dmd2 = new Document_MetaData__c();
        dmd2.Opportunity__c = newOpportunity.Id;
        dmd2.Requirement__c = req.Id;
        dmd2.Document_Type__c = 'RSI Letter';
        dmdlist.add(dmd2);
        
        insert dmdlist;
        
        List<ContentVersion> cvlist = new List<ContentVersion>();
        
        ContentVersion cv2 = new ContentVersion(
            Title = 'RSI Letter',
            PathOnClient = 'Test.doc',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        cvlist.add(cv2);
        
        insert cvlist;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = newOpportunity.Id;
        cdl2.ContentDocumentId = documents[0].Id;
        cdl2.shareType = 'V';
        cdllist.add(cdl2);
        
        Test.starttest();
        insert cdllist; 
        Test.stoptest(); 
       
    }
    
    @isTest
    static void datacreate3(){
        Test.setMock(HttpCalloutMock.class, new SFDC2SFDCAPIMock());
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
                
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
              /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup
        newOpportunity.Billboard_Property_Approval__c = true;            
*/
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.Estimated_Funding_Amount__c = 2;
		newOpportunity.Pricing_Ratio__c = 2;
		newOpportunity.Final_OAV_Calculation__c = 4;
        insert newOpportunity;     
        
        Success_Factor__c sf = new Success_Factor__c();
        sf.Opportunity__c = newOpportunity.Id;
        sf.Status__c = 'In Progress';
        sf.Success_Factor__c = 'Program';
        sf.Program__c = 'HO';
        insert sf;
        
        Current_Conditions__c req = new Current_Conditions__c();
        req.Opportunity__c = newOpportunity.Id;
        req.Requirement__c = 'CAP Completed';
        req.Code__c = 'R1015';
        req.Category__c = 'Mortgage';
        req.Internal_vs_External__c = 'Internal';
        //req.Assigned_To__c = 'PS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        req.Success_Factor__c = sf.Id;
        insert req;
        system.debug('++++++req '+ req);

        List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        
        Document_MetaData__c dmd3 = new Document_MetaData__c();
        dmd3.Opportunity__c = newOpportunity.Id;
        dmd3.Requirement__c = req.Id;
        dmd3.Document_Type__c = 'CAP Completed';
        dmdlist.add(dmd3);
        
        insert dmdlist;
        
        List<ContentVersion> cvlist = new List<ContentVersion>();
        
        ContentVersion cv3 = new ContentVersion(
            Title = 'HBCAP',
            PathOnClient = 'Test.doc',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        cvlist.add(cv3);
        
        insert cvlist;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = newOpportunity.Id;
        cdl3.ContentDocumentId = documents[0].Id;
        cdl3.shareType = 'V';
        cdllist.add(cdl3);
        
        Test.starttest();
        insert cdllist; 
        Test.stoptest(); 
       
    }
@isTest
    static void datacreate4(){
        Test.setMock(HttpCalloutMock.class, new SFDC2SFDCAPIMock());
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
                
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.StageName = 'Property in Contract';
        newOpportunity.CloseDate = System.today();
        newOpportunity.Agency_or_Non_Agency__c = 'Agency';
              /* 4/10/2019 Jonathan Vu - Commented for Data Model Cleanup
        newOpportunity.Billboard_Property_Approval__c = true;            
*/
        newOpportunity.DocuSign_Returned__c = true;
        newOpportunity.Loan_Officer_ID__c = '12345';
        newOpportunity.Property_Street_Number_and_Name__c = 'Street';
        newOpportunity.Property_City__c = 'City';
        newOpportunity.Property_State__c = 'State';
        newOpportunity.Property_Zip_Code__c = '12345';
        newOpportunity.Estimated_Funding_Amount__c = 2;
		newOpportunity.Pricing_Ratio__c = 2;
		newOpportunity.Final_OAV_Calculation__c = 4;
        insert newOpportunity;     
        
        Success_Factor__c sf = new Success_Factor__c();
        sf.Opportunity__c = newOpportunity.Id;
        sf.Status__c = 'In Progress';
        sf.Success_Factor__c = 'Closing';
        sf.Program__c = 'HO';
        insert sf;
        
        Current_Conditions__c req = new Current_Conditions__c();
        req.Opportunity__c = newOpportunity.Id;
        req.Requirement__c = 'HB Closing Tasks';
        req.Code__c = 'R1035';
        req.Category__c = 'Mortgage';
        req.Internal_vs_External__c = 'Internal';
        //req.Assigned_To__c = 'PS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        req.Success_Factor__c = sf.Id;
        
        insert req;
    system.debug('++++++req '+ req);

    List<Document_MetaData__c> dmdlist = new List<Document_MetaData__c>();
        
        Document_MetaData__c dmd3 = new Document_MetaData__c();
        dmd3.Opportunity__c = newOpportunity.Id;
        dmd3.Requirement__c = req.Id;
        dmd3.Document_Type__c = 'Closing Documents';
        dmdlist.add(dmd3);
        
        insert dmdlist;
        
        List<ContentVersion> cvlist = new List<ContentVersion>();
        
        ContentVersion cv3 = new ContentVersion(
            Title = 'ClosingDocuments',
            PathOnClient = 'Test.doc',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        cvlist.add(cv3);
        
        insert cvlist;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = newOpportunity.Id;
        cdl3.ContentDocumentId = documents[0].Id;
        cdl3.shareType = 'V';
        cdllist.add(cdl3);
        
        Test.starttest();
        try{
        insert cdllist;
        }
        catch(Exception e){

        }
    Test.stoptest();
       
    }
}