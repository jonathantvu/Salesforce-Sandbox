public class MercuryAWSAPI {

    public static boolean CallAWS(Request request) {
        
        integer retCode = MakeAPICall('POST', JSON.serialize(request));
        
        if (retCode >= 200 && retCode < 300) {
            return true;
        }
        return false;
        
    }
    
    public class Request {
        public List<RequestAppraisals> appraisals { get; set; }
    }
    public class RequestAppraisals {
        public string eventType { get; set; }
        public Map<String, object> appraisal { get; set; }
        
        public RequestAppraisals() {
            appraisal = new Map<String, object>();
        }
    }
    
    // Methods that can make a call
    private static integer MakeAPICall(String action, String request) 
    {
        if (SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(SETTINGS.AWSEndpoint__c);
            req.setHeader('x-api-key', SETTINGS.X_API_Key__c);
            req.setMethod(action);
            req.setTimeout(60000);
            req.setHeader('Content-Type', 'application/json; charset=utf8');

            if (request != null)
            {
                req.setBody(request);
            }  
           
            HttpResponse apiResponse;

            Http http = new Http();
            apiResponse = http.send(req);
            
            CreateLogEntry(SETTINGS.AWSEndpoint__c, action, request, apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus(), false);

            return apiResponse.getStatusCode();
            
        }
        else 
        {
            return 0;
        }    
    }
    // Custom settings
    private static AppraisaltoAWSEndpoint__mdt SETTING_PRIVATE;
    public static AppraisaltoAWSEndpoint__mdt SETTINGS
    {
        get
        {
            if(SETTING_PRIVATE == null)
            {
                List<AppraisaltoAWSEndpoint__mdt> apiCredentials =
                [
                    SELECT Id, AWSEndpoint__c, Appraisal_Code__c, X_API_Key__c 
                    FROM AppraisaltoAWSEndpoint__mdt
                    LIMIT 1
                ];

                if(apiCredentials.size() > 0)
                {
                    SETTING_PRIVATE = apiCredentials[0];
                }
            }

            return SETTING_PRIVATE;
        }
    }
    // Logging
    // Methods to add a call log entry
    private static List<Mercury_Call_Log__c> callLogs = new List<Mercury_Call_Log__c>();
    public static void CreateLogEntry(String url, String method, String request, String response, String statusCode, String statusMessage)
    {
        CreateLogEntry(url, method, request, response, statusCode, statusMessage, true);
    }
    public static void CreateLogEntry(String url, String method, String request, String response, String statusCode, String statusMessage, boolean alsoInsert)
    {        
        Mercury_Call_Log__c newLogEntry = new Mercury_Call_Log__c();

        newLogEntry.Name = 'Log call at:  ' + Datetime.now();
        newLogEntry.Method__c = method;
        newLogEntry.Request__c = request;
        newLogEntry.Response__c = response.left(131000);
        newLogEntry.Status_Code__c = statusCode;
        newLogEntry.Status_Message__c = statusMessage;
        newLogEntry.URL__c = url;

        if (alsoInsert)
        {
        	insert newLogEntry;
        }
        else
        {
            callLogs.add(newLogEntry);
        }
    }
    public static void InsertAllLogs() 
    {
        insert callLogs;

        callLogs = new List<Mercury_Call_Log__c>();
    }
        
}