@isTest
global class SFDC2SFDCAPIMock implements HttpCalloutMock {
    
    global HTTPResponse respond( HTTPRequest request ) {    
        if(request.getEndpoint()=='https://test.salesforce.com/services/oauth2/token'){
            system.debug('******mocktest********');
            HttpResponse response;
            response = new HttpResponse();
            response.setBody('{"access_token":"lltTsohKzwu7e8WqU53EzJyjPMkklT8dEvCX3T0yIwk","instance_url":"https://unisonimmap--MapIn.cs61.my.salesforce.com","id":"https://test.salesforce.com/id/00D4C000000LE8wUAG/0054C000001Is69QAC","token_type":"Bearer","issued_at":"1546738228964","signature":"lltTsohKzwu7e8WqU53EzJyjPMkklT8dEvCX3T0yIwk="}');
            response.setHeader( 'content-type', 'application/json' );
            response.setStatusCode( 200 );            
            return response;
        }else if(request.getEndpoint()=='https://api.box.com/oauth2/token'){
            HttpResponse response;
            response = new HttpResponse();
            response.setBody('{"access_token":"7cYhlsh6CDPTjnUofS5zCIVtjTJykJxc","expires_in":4162,"restricted_to":[],"token_type":"bearer"}');
            response.setHeader( 'content-type', 'application/json' );
            response.setStatusCode( 200 );
            response.setStatus('OK');
                        
            return response;       
        }else if(request.getEndpoint().contains('https://upload.box.com/api/2.0/files/content')){
            HttpResponse response;
            response = new HttpResponse();
            response.setBody('{"total_count":1,"entries":[{"type":"file","id":"392004801293","file_version":{"type":"file_version","id":"414446987693","sha1":"6f2a3c5c6def22e9a162beab21087149c96844d2"},"sequence_id":"0","etag":"0","sha1":"6f2a3c5c6def22e9a162beab21087149c96844d2","name":"RSI Letter._0680U000001LQtfQAG.pdf","description":"","size":92475,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"52507195342","sequence_id":"0","etag":"0","name":"SFDC.CUSTDOCS.SECURE.TEST"},{"type":"folder","id":"57516514894","sequence_id":"0","etag":"0","name":"FRX-066756"}]},"created_at":"2019-01-28T22:03:52-08:00","modified_at":"2019-01-28T22:03:52-08:00","trashed_at":null,"purged_at":null,"content_created_at":"2019-01-28T22:03:52-08:00","content_modified_at":"2019-01-28T22:03:52-08:00","created_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"modified_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"owned_by":{"type":"user","id":"3919732702","name":"Unison Document Manager","login":"AutomationUser_641165_JkhqMAEuBc@boxdevedition.com"},"shared_link":null,"parent":{"type":"folder","id":"57516514894","sequence_id":"0","etag":"0","name":"FRX-066756"},"item_status":"active"}]}');
            response.setHeader( 'content-type', 'application/json' );
            response.setStatusCode( 201 );
            response.setStatus('OK');
                        
            return response;       
        }else {
        
            HttpResponse response;
            response = new HttpResponse();
            response.setBody('{"access_token":"lltTsohKzwu7e8WqU53EzJyjPMkklT8dEvCX3T0yIwk","instance_url":"https://unisonimmap--MapIn.cs61.my.salesforce.com","id":"https://test.salesforce.com/id/00D4C000000LE8wUAG/0054C000001Is69QAC","token_type":"Bearer","issued_at":"1546738228964","signature":"lltTsohKzwu7e8WqU53EzJyjPMkklT8dEvCX3T0yIwk="}');
            response.setHeader( 'content-type', 'application/json' );
            response.setStatusCode( 200 ); 
            
            return response;
        }
        
    }
    
}