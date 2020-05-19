@isTest
private class LeadUploadDMD_LightningTest {
	@isTest static void test_method_one()
    {
        String boxFolderId = '123456';
        String boxFileId = '654321';
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String mockResponseBody = '{"type":"folder","id":"'+boxFolderId+'","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(mockResponseBody, 'Created', 201)));
        BoxTestMockCallout.MockResponse m= new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201);
        system.debug(m);
        responseList.add((m));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));

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
        newLead.Income_Monthly_Base__c = 10;
        newLead.Income_Monthly_Bonuses__c = 10;
        newLead.Income_Monthly_Commissions__c = 10;
        newLead.Income_Monthly_Div_Interest__c = 10;
        newLead.Income_Monthly_Other__c = 10;
        newLead.Home_Value__c = 10;
        insert newLead;
        
        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Lead__c = newLead.Id;
        sf1.Success_Factor__c = 'Cash to Consumer';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        insert sf1;

        Current_Conditions__c req = new Current_Conditions__c();
        req.Requirement__c = 'Revised CAP';
        req.Success_Factor__c = sf1.Id;
        req.Lead__c = newLead.id;
        req.code__c = 'R1084';
        Insert req;

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.Title = 'MyFile.txt';
        cv.PathOnClient = 'MyFile.xtx';
        cv.VersionData = blob.valueOf('This is text');
        insert cv;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDoc;
        cdl.LinkedEntityId = newLead.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        test.startTest();
        Document_MetaData__c dmd = New Document_MetaData__c(Lead__c=newLead.Id, Requirement__c=req.Id);
        LeadUploadDMD_Lightning.init(newLead.Id);
        LeadUploadDMD_Lightning.createDocument(dmd, newLead.Id, 'Lead');
        test.stopTest();
    }
}