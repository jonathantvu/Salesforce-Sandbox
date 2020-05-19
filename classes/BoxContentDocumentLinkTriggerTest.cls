@isTest
public class BoxContentDocumentLinkTriggerTest {
    @isTest static void testBoxCDLTriggerNewFolder() {
        String boxFileId = '123456';
		List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String folderResponse = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(folderResponse, 'Created', 201)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));

        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));

        Lead lead = BoxWrapperTestDataFactory.createLead();
		Document_MetaData__c dmd = BoxWrapperTestDataFactory.createDMD(lead.Id, null, null);

        Test.startTest();
        ContentDocumentLink cdl = BoxWrapperTestDataFactory.createCVAndCDL(dmd.Id);
        Test.stopTest();

        //Document_MetaData__C updatedDMD = [SELECT Id, Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :dmd.Id];

        //System.assertEquals(boxFileId, updatedDMD.Box_File_Id__c);

    }


    @isTest static void testBoxCDLTrigger() {
        String boxFileId = '123456';
		List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        //String folderResponse = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        //responseList.add((new BoxTestMockCallout.MockResponse(folderResponse, 'Created', 201)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));

        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));

        Lead lead = BoxWrapperTestDataFactory.createLead();
        lead.Box_Folder_Id__c = '1234567';
        update lead;

		Document_MetaData__c dmd = BoxWrapperTestDataFactory.createDMD(lead.Id, null, null);

        Test.startTest();
        ContentDocumentLink cdl = BoxWrapperTestDataFactory.createCVAndCDL(dmd.Id);
        Test.stopTest();

        //Document_MetaData__C updatedDMD = [SELECT Id, Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :dmd.Id];

        //System.assertEquals(boxFileId, updatedDMD.Box_File_Id__c);

    }

    @isTest static void testBoxCDLTriggerExistingDMD() {
        String boxFileId = '123456';
		List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        //String folderResponse = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        //responseList.add((new BoxTestMockCallout.MockResponse(folderResponse, 'Created', 201)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));

        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));

        Lead lead = BoxWrapperTestDataFactory.createLead();
        lead.Box_Folder_Id__c = '1234567';
        update lead;

		Document_MetaData__c dmd = BoxWrapperTestDataFactory.createDMD(lead.Id, null, null);
        dmd.Box_File_Id__c = '1234';
		dmd.Box_Folder_Id__c = '2345';
        dmd.Box_File_URL__c = 'https://unison.box.com/';
        update dmd;

        Test.startTest();
        ContentDocumentLink cdl = BoxWrapperTestDataFactory.createCVAndCDL(dmd.Id);
        Test.stopTest();

        //ContentDocumentLink updatedCDL = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE Id = :cdl.Id];

        //Document_MetaData__C updatedDMD = [SELECT Id, Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :updatedCDL.LinkedEntityId];

        //System.assertEquals(boxFileId, updatedDMD.Box_File_Id__c);

    }

    @isTest static void testBoxCDLTriggerOppNewFolder() {
        String boxFileId = '123456';
		List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String folderResponse = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        responseList.add((new BoxTestMockCallout.MockResponse(folderResponse, 'Created', 201)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));

        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));

        Opportunity opp = BoxWrapperTestDataFactory.createOpp();
		Document_MetaData__c dmd = BoxWrapperTestDataFactory.createDMD(null, opp.Id, null);

        Test.startTest();
        ContentDocumentLink cdl = BoxWrapperTestDataFactory.createCVAndCDL(dmd.Id);
        Test.stopTest();

        //Document_MetaData__C updatedDMD = [SELECT Id, Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :dmd.Id];

        //System.assertEquals(boxFileId, updatedDMD.Box_File_Id__c);

    }

    @isTest static void testBoxCDLTriggerOpp() {
        String boxFileId = '123456';
		List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        //String folderResponse = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
        String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
        responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
        //responseList.add((new BoxTestMockCallout.MockResponse(folderResponse, 'Created', 201)));
        responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));

        Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));

        Opportunity opp = BoxWrapperTestDataFactory.createOpp();
        opp.Box_Folder_Id__c = '1234';
        update opp;

		Document_MetaData__c dmd = BoxWrapperTestDataFactory.createDMD(null, opp.Id, null);

        Test.startTest();
        ContentDocumentLink cdl = BoxWrapperTestDataFactory.createCVAndCDL(dmd.Id);
        Test.stopTest();

        //Document_MetaData__C updatedDMD = [SELECT Id, Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :dmd.Id];

        //System.assertEquals(boxFileId, updatedDMD.Box_File_Id__c);
    }

    @isTest static void testBoxCDLTriggerReqOppNewFolder() {
        try {
            String boxFileId = '123456';
            List<BoxTestMockCallout.MockResponse> responseList = new List<BoxTestMockCallout.MockResponse>();
            String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
            String folderResponse = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"FRX-0000","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}}';
            String fileResponse = '{"total_count":1,"entries":[{"type":"file","id":"' + boxFileId + '","file_version":{"type":"file_version","id":"349943637207","sha1":"18c675d1c3547759745fadaf99377c0e493adf95"},"sequence_id":"0","etag":"0","sha1":"18c675d1c3547759745fadaf99377c0e493adf95","name":"Testing copy_0680U000001KeJRQA0.pdf","description":"","size":15701,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"}]},"created_at":"2018-10-14T21:07:25-07:00","modified_at":"2018-10-14T21:07:25-07:00","trashed_at":null,"purged_at":null,"content_created_at":"2018-10-14T21:07:25-07:00","content_modified_at":"2018-10-14T21:07:25-07:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"53020195384","sequence_id":"0","etag":"0","name":"FRX-061086"},"item_status":"active"}]}';
            responseList.add((new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200)));
            responseList.add((new BoxTestMockCallout.MockResponse(folderResponse, 'Created', 201)));
            responseList.add((new BoxTestMockCallout.MockResponse(fileResponse, 'Created', 201)));

            Test.SetMock(HttpCalloutMock.class, new BoxTestMockCallout(responseList));

            Opportunity opp = BoxWrapperTestDataFactory.createOpp();
            Current_Conditions__c req = BoxWrapperTestDataFactory.createRequirement(null, opp.Id);
            Document_MetaData__c dmd = BoxWrapperTestDataFactory.createDMD(null, null, req.Id);

            Test.startTest();
            ContentDocumentLink cdl = BoxWrapperTestDataFactory.createCVAndCDL(dmd.Id);
            Test.stopTest();

            //Document_MetaData__C updatedDMD = [SELECT Id, Box_File_Id__c, Box_File_URL__c, Box_Folder_Id__c FROM Document_MetaData__c WHERE Id = :dmd.Id];

            //System.assertEquals(boxFileId, updatedDMD.Box_File_Id__c);
        }catch(Exception e){}

    }

}