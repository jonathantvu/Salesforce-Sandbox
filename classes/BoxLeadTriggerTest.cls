@isTest
public class BoxLeadTriggerTest {
    @isTest static void boxLeadTriggerTest(){
        String boxFolderId = '123456';
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String mockResponseBody = '{"type":"folder","id":"'+boxFolderId+'","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(mockResponseBody, 'Created', 201)));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));
        
        Lead newLead = BoxWrapperTestDataFactory.createLead();
        
        Test.startTest();
        newLead.Create_Box_Folder__c = True;
        //newLead.Upload_Files_to_Box__c = True;
        update newLead;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Box_Folder_Id__c FROM Lead WHERE Id = :newLead.Id];
        
        //System.assertEquals(boxFolderId, updatedLead.Box_Folder_Id__c);
    }

    @isTest static void boxLeadTriggerTest2(){
        String boxFolderId = '123456';
        String boxFileId = '654321';
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String mockResponseBody = '{"type":"folder","id":"'+boxFolderId+'","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(mockResponseBody, 'Created', 201)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));
        
        Lead newLead = BoxWrapperTestDataFactory.createLead();
        
        Document_MetaData__c theDMD = new Document_MetaData__c();
        theDMD.Upload_Date__c = system.now();
        theDMD.Uploaded__c = true;
        theDMD.Document_Description__c = 'Signed Offer Letter';
        theDMD.Lead__c = newLead.id;
        insert theDMD;
        
        ContentVersion theDocument = new ContentVersion();
        theDocument.ContentLocation = 'S';
        theDocument.Title = 'Signed Offer Letter';
        theDocument.PathOnClient = 'Signed Offer Letter';
        theDocument.VersionData = Blob.valueOf('testing testing');
        insert theDocument;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :theDocument.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDoc;
        cdl.LinkedEntityId = newLead.id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        Attachment att = new Attachment();
        att.ParentId = newLead.id;
        att.Body = Blob.valueOf('test');
        att.Name = 'test';
        insert att;
        
        Test.startTest();
        //newLead.Create_Box_Folder__c = True;
        //update newLead;
        newLead.Upload_Files_to_Box__c = True;
        update newLead;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Box_Folder_Id__c FROM Lead WHERE Id = :newLead.Id];
        
        //System.assertEquals(boxFolderId, updatedLead.Box_Folder_Id__c);
    }
}