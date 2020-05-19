public class GreenLightAPI {

    public static boolean AutoSaveLogs = false;

    private static GreenLight_Integration_Settings__mdt settingsPrivate;
    public static GreenLight_Integration_Settings__mdt Settings { 
        get {
            if (settingsPrivate == null)
                settingsPrivate = [SELECT Id, Base_URL__c, /*Auth_Token__c,*/ Save_Logs__c FROM GreenLight_Integration_Settings__mdt LIMIT 1];
            return settingsPrivate;
        }
    }

    public static InquiryResponse PostInquiry(PostInquiryRequest req) { 

        String request = JSON.serialize(req);
        request = request.replace('_c_c', '__c'); // The JSON requires some fields ending in __c, which apex does not allow, so we're doing this trick
        String responseStr = MakeAPICall('api/v3/inquiries', 'POST', request);
        responseStr = responseStr.replace('__c', '_c_c'); // The JSON requires some fields ending in __c, which apex does not allow, so we're doing this trick
        
        if (responseStr.startsWith('Error: ')) {
            InquiryResponse toReturn = new InquiryResponse();
            toReturn.success = false;
            toReturn.error = responseStr.substring(7);
            return toReturn;
        } else {
            InquiryResponse toReturn = (InquiryResponse)JSON.deserialize(responseStr, InquiryResponse.class);
            toReturn.success = true;
            toReturn.error = null;
            return toReturn;
        }

    }

    public static InquiryResponse PutInquiry(PutInquiryRequest req) { 

        String request = JSON.serialize(req);
        request = request.replace('_c_c', '__c'); // The JSON requires some fields ending in __c, which apex does not allow, so we're doing this trick
        String responseStr = MakeAPICall('api/v3/inquiries/' + req.inquiry_id, 'PUT', request);
        responseStr = responseStr.replace('__c', '_c_c'); // The JSON requires some fields ending in __c, which apex does not allow, so we're doing this trick
        
        if (responseStr.startsWith('Error: ')) {
            InquiryResponse toReturn = new InquiryResponse();
            toReturn.success = false;
            toReturn.error = responseStr.substring(7);
            return toReturn;
        } else {
            InquiryResponse toReturn = (InquiryResponse)JSON.deserialize(responseStr, InquiryResponse.class);
            toReturn.success = true;
            toReturn.error = null;
            return toReturn;
        }

    }

    private static List<GreenLight_API_Log__c> logs { get; set; }

    private static string MakeAPICall(string url, string method, string body) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //req.setHeader('Authorization', 'Bearer ' + Settings.Auth_Token__c);
        req.setHeader('x-unison-request-user',userInfo.getUserName());
        req.setHeader('x-unison-request-source','salesforce');        
        if (method == 'POST')
            req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(Settings.Base_URL__c + url);
        req.setMethod(method);
        if (body != null)
            req.setBody(body);
        HttpResponse res = h.send(req);

        if (Settings.Save_Logs__c) {
            if (logs == null) {
                logs = new List<GreenLight_API_Log__c>();
            }
            GreenLight_API_Log__c log = new GreenLight_API_Log__c();
            log.URL__c = Settings.Base_URL__c + url;
            log.Method__c = method;
            if (body != null) {
                log.Request_Body__c = body;
                if (log.Request_Body__c.length() > 131070) {
                    log.Request_Body__c = log.Request_Body__c.substring(0, 131060) + ' ...';
                }
            }
            log.Response_Code__c = res.getStatusCode();
            log.Response_Body__c = res.getBody();
            if (log.Response_Body__c.length() > 131070) {
                log.Response_Body__c = log.Response_Body__c.substring(0, 131060) + ' ...';
            }
            if (AutoSaveLogs) {
                insert log;
            } else {
                logs.add(log);
            }
        }

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300){
            system.debug('Greenlight response body---' + res.getBody());              
            return res.getBody();           
        }
        else{
            return 'Error: ' + res.getBody();            
        }

    }

    public static void SaveLogs() {
        if (Settings.Save_Logs__c && logs != null && logs.size() > 0) {
            insert logs;
            logs = new List<GreenLight_API_Log__c>();
        }
    }


    // Request classes

    public class PostInquiryRequest {
        public string program_type { get; set; }
        public string lead_id { get; set; }
        public string tracking_id { get; set; }
        public InquiryRequestProperty property { get; set; }   
        public InquiryRequestProgram program {get; set;}        
        public InquiryRequestFinancial financial {get; set;}

        public PostInquiryRequest() {
            property = new InquiryRequestProperty();
            program_type = '';
            lead_id = '';
            tracking_id = '';
            program = new InquiryRequestProgram();
            financial = new InquiryRequestFinancial();
        }
    }

    public class PutInquiryRequest {
        public string inquiry_id { get; set; }
        public string inquiry_sequence_id { get; set; }
        public string lead_id { get; set; }
        public string tracking_id { get; set; }
        public InquiryRequestProperty property { get; set; }
        public InquiryRequestProgram program {get; set;}        
        public InquiryRequestFinancial financial {get; set;}        

        public PutInquiryRequest() {
            property = new InquiryRequestProperty();
            inquiry_id = '';
            inquiry_sequence_id = '';
            lead_id = '';
            tracking_id = '';
            program = new InquiryRequestProgram();
            financial = new InquiryRequestFinancial();            
        }
    }

    public class InquiryRequestProperty {
        public string property_type { get; set; }
        public RequestInputAddress input_address { get; set; }
        public string occupancy_status {get; set;}
        public boolean is_new_construction {get; set;}           

        public InquiryRequestProperty() {
            input_address = new RequestInputAddress();
            property_type = '';
            occupancy_status = '';
            is_new_construction = false;
        }
    }

    public class InquiryRequestProgram{
        public boolean Qualifies_for_New_HomeOwner_Pricing_c_c {get; set;}
        
        public InquiryRequestProgram(){
            Qualifies_for_New_HomeOwner_Pricing_c_c = false;
        }
        
    }
    
    public class InquiryRequestFinancial{
        public decimal origination_credit_score {get; set;}
        
        public InquiryRequestFinancial(){
            origination_credit_score = 0;
        }
        
    }    
    
    public class RequestInputAddress {
        public string delivery_line { get; set; }
        public string city { get; set; }
        public string state_abbreviation { get; set; }
        public string postal_code { get; set; }

        public RequestInputAddress() {
            delivery_line = '';
            city = '';
            state_abbreviation = '';
            postal_code = '';
        }
    }

    // Response classes

    public class InquiryResponse {
        public boolean success { get; set; }
        public string error { get; set; }

        public string inquiry_id { get; set; }
        public string inquiry_sequence_id { get; set; }
        public string decision { get; set; }
        public InquiryResponseProperty property { get; set; }
        public InquiryResponseProgram program { get; set; }
        public InquiryResponesNotes notes {get; set;}
        public decimal estimated_valuation {get; set;}
    }

    public class InquiryResponseProperty {
        public string cl_property_id { get; set; }
    }
    
    public class InquiryResponseProgram {
        public decimal Pricing_Ratio_c_c { get; set; }
    }    
    
    public class InquiryResponesNotes {
        public InquiryResponseGreenlight greenlight {get; set;}
    }
    
    public class InquiryResponseGreenlight{
        public string finalNotes {get; set;}        
    }

}