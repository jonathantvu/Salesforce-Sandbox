/**
    @Purpose : Provides Fake Response For LOP HttpRequest
*/
@isTest
global class LOP_MockResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond( HTTPRequest request ) {    
       
        HttpResponse response;

        if( request.getEndPoint().contains('salesforce_create') ) {

            response = new HttpResponse();
            response.setHeader( 'content-type', 'application/json' );
            response.setBody( getSucecssMockResopnse(request) );
            response.setStatusCode( 200 );            
            
        } else If( request.getEndPoint().containsAny('salesforce_delete') ) {
            response = new HttpResponse();
            response.setHeader( 'content-type', 'application/json' );
            response.setBody( getErrorMockResopnse(request) );
            response.setStatusCode( 404 );
        } else {
            response = new HttpResponse();
            response.setHeader( 'content-type', 'application/json' );
            //response.setBody();
            response.setStatusCode( 200 );        
        }
        return response;
    }
    
    Private String getSucecssMockResopnse( HTTPRequest request ) {
        return request.getBody();
    }
    
    Private String getErrorMockResopnse( HTTPRequest request ) {
        return ('{'+
                '   "status": 404,'+
                '   "error": "Not Found"'+
                '}');
    }
}