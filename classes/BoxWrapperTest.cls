@isTest
public class BoxWrapperTest {
    @isTest static void testFolderCreation(){
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String mockResponseBody = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(mockResponseBody, 'Created', 201)));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));
        List<Id> parentIds = new List<Id>();
        List<String> folderNames = new List<String>();
        //folderNames.add('FRX-0000');
        
        Lead newLead = BoxWrapperTestDataFactory.createLead();
        
        parentIds.add(newLead.Id);
        folderNames.add(newLead.Application_Tracking_ID__c);
        
        Test.startTest();
        BoxWrapper.createBoxFolders(parentIDs, folderNames);
        Test.stopTest();
        
        Lead leadUpdated = [SELECT Box_Folder_Id__c FROM Lead WHERE Id = :newLead.Id];
        
        System.assert(!String.isBlank(leadUpdated.Box_Folder_Id__c));
    }
    
    @isTest static void testFolderCreationOpp(){
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String mockResponseBody = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(mockResponseBody, 'Created', 201)));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));
        List<Id> parentIds = new List<Id>();
        List<String> folderNames = new List<String>();
        //folderNames.add('FRX-0000');
        
        Opportunity newOpp = BoxWrapperTestDataFactory.createOpp();
        
        parentIds.add(newOpp.Id);
        folderNames.add(newOpp.Encompass_Loan_Number__c);
        
        Test.startTest();
        BoxWrapper.createBoxFolders(parentIDs, folderNames);
        Test.stopTest();
        
        Opportunity oppUpdated = [SELECT Box_Folder_Id__c FROM Opportunity WHERE Id = :newOpp.Id];
        
        System.assert(!String.isBlank(oppUpdated.Box_Folder_Id__c));
    }
    
    @isTest static void testFolderCreationWithCollision(){
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String mockResponseBody = '{"type":"error","status":409,"code":"item_name_in_use","context_info":{"conflicts":[{"type":"folder","id":"53310364698","sequence_id":"0","etag":"0","name":"testing2"}]},"help_url":"http:\\/\\/developers.box.com\\/docs\\/#errors","message":"Item with the same name already exists","request_id":"tchindfw8l053ykj"}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(mockResponseBody, 'Conflict', 409)));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));
        List<Id> parentIds = new List<Id>();
        List<String> folderNames = new List<String>();
        folderNames.add('FRX-0000');
        
        Lead newLead = BoxWrapperTestDataFactory.createLead();
        
        parentIds.add(newLead.Id);
        folderNames.add(newLead.Application_Tracking_ID__c);
        
        Test.startTest();
        BoxWrapper.createBoxFolders(parentIDs, folderNames);
        Test.stopTest();
        
        Lead leadUpdated = [SELECT Box_Folder_Id__c FROM Lead WHERE Id = :newLead.Id];
        
        System.assert(!String.isBlank(leadUpdated.Box_Folder_Id__c));
    }
}