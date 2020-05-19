public without sharing class SegmentAPI {
    
    private static Segment_API_Setting__mdt settingPrivate;
    public static Segment_API_Setting__mdt Setting {
        get {
            if (settingPrivate == null) {
                settingPrivate = [SELECT Id, Base_URL__c, Write_Key__c FROM Segment_API_Setting__mdt LIMIT 1];
            }
            return settingPrivate;
        }
    }

    public static APICallResult CallTrack(TrackRequest req) {

        APICallResult callResult = MakeAPICall('/track', 'POST', JSON.serialize(req));

        System.debug(callResult);

        return callResult;
    }

    private static APICallResult MakeAPICall(String url, String action, String request) {        
        APICallResult toReturn = new APICallResult();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Setting.Base_URL__c + url);
        req.setMethod(action);
        req.setTimeout(60000);
        req.setHeader('Authorization', 'Basic ' + system.EncodingUtil.base64Encode( blob.valueOf(Setting.Write_Key__c) ) );
        req.setHeader('Content-Type', 'application/json');

        if(request != null) {
            req.setBody(request);
        }
		system.debug('segment Headers---');
		system.debug('Authorization---'); 
		system.debug(req.getHeader('Authorization'));
		system.debug('Content-Type');        
		system.debug(req.getHeader('Content-Type'));        
		system.debug('segment JSON body---');
		system.debug(request);
        
        Http http = new Http();
	        HttpResponse apiResponse = new httpResponse();        
        if(!test.isRunningTest()){
	        apiResponse = http.send(req);            
        }else{
            SegmentAPIMock mock = new SegmentAPIMock();
            apiResponse = mock.respond(req);
        }
        
        if(String.valueOf(apiResponse.getStatusCode()) != '200') {
            toReturn.error = true;
            toReturn.message = 'Response error message (status code ' + String.valueOf(apiResponse.getStatusCode()) + ') :' + apiResponse.getBody();
        } else {
            toReturn.message = apiResponse.getBody();
        }  

        return toReturn;       
    }

    public class APICallResult {
        public Boolean error { get; set; }
        public String message { get; set; }

        public APICallResult() {
            error = false;
            message = '';
        }
    }

    public class TrackRequest {
        public string anonymousId { get; set; }
        public string type { get; set; }
        public string event { get; set; }
        public string timestamp { get; set; }
        public TrackRequestProperties properties { get; set; }

        public TrackRequest() {
            properties = new TrackRequestProperties();
        }
    }

    public class TrackRequestProperties {
        public string email { get; set; }
        public string first_name { get; set; }
        public string last_name { get; set; }
        public string phone { get; set; }
        public string lead_id { get; set; }
    }

}