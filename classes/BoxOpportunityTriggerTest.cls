@isTest
public class BoxOpportunityTriggerTest {
    @isTest static void boxOpportunityTriggerTest(){
        String boxFolderId = '123456';
        List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String mockResponseBody = '{"type":"folder","id":"'+boxFolderId+'","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(mockResponseBody, 'Created', 201)));
        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));
        
        Opportunity newOpp = BoxWrapperTestDataFactory.createOpp();
        
        Test.startTest();
        newOpp.Create_Box_Folder__c = True;
        update newOpp;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, Box_Folder_Id__c FROM Opportunity WHERE Id = :newOpp.Id];
        
        //System.assertEquals(boxFolderId, updatedOpp.Box_Folder_Id__c);
    }
}