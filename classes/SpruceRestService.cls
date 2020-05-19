@RestResource(urlMapping='/SpruceRS/*')
global class SpruceRestService {
	
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            boolean validrequest = false;
            
            for(string key : req.headers.keySet()){
                if(key.equalsIgnoreCase('apikey') && req.headers.get(key) ==  System.Label.Spruce_Header){
                    validrequest = true;
                }
            }
            
            if(validrequest){
                System.debug('request body'+req.requestBody.toString());
                RequestWrapper rw = (RequestWrapper)JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);
                
                List<Property_Due_Diligence_Reports__c> pddrs = [SELECT Id FROM Property_Due_Diligence_Reports__c WHERE Spruce_Order_Id__c = :rw.payload.file_number];
                
                for (Property_Due_Diligence_Reports__c pddr : pddrs) {
                    pddr.Status__c = rw.payload.status;
                }
                if(!pddrs.isempty()){
                    update pddrs;
                }
            }else{
                return 'apikey Incorrect';    
            }
            return 'OK';
        } catch (Exception ex) {
            res.statusCode = 500;
            return ex.getMessage();
        }
    }
    public class RequestWrapper {
        //public EventWrapper event { get; set; }
        public string event_id { get; set; }
        public string event { get; set; }
        public string timestamp {get; set; }
        public payloadWrapper payload {get; set; }
    }
    public class payloadWrapper {
        public string file_number { get; set; }
        public string order_id { get; set; }
        public string status { get; set; }
    }
    /*
    public class EventWrapper {
        public string event_status { get; set; }
        public string event_time { get; set; }
    }*/
    /*public class OrderWrapper {
        public string id { get; set; }
        public string order_status { get; set; }
    }*/
    
}