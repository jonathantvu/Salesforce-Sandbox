public class MercuryAPICustom 
{
    // Custom settings
    private static MercuryCredential__mdt SETTING_PRIVATE;

    public static MercuryCredential__mdt SETTINGS
    {
        get
        {
            if(SETTING_PRIVATE == null)
            {
                List<MercuryCredential__mdt> apiCredentials =
                [
                    SELECT Id, Username__c, URL__c, Password__c, EntityID__c
                    FROM MercuryCredential__mdt
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
    
    @TestVisible private static String sessionId { get; set; }
    
    private static string VMPOrderFormFieldsResults { get; set; }
    
    public static Map<String, String> GetAMCCompanies()
    {
        if (sessionId == null)
        {
            Login();
        }

        if (sessionId != null) 
        {            
            if (VMPOrderFormFieldsResults == null) {
                String request = 'SessionKey=' + EncodingUtil.UrlEncode(sessionId, 'UTF-8') + '&AppraiserID=' + String.valueOf(SETTINGS.EntityID__c).removeEnd('.0');
                
                VMPOrderFormFieldsResults = MakeAPICall('/GetVMPOrderFormFields', 'POST', request);
            }
            
			Dom.Document doc = new Dom.Document();
        	doc.load(VMPOrderFormFieldsResults);
        
            Map<String, String> toReturn = new Map<String, String>();
        	Dom.XmlNode rootNode = doc.getRootElement();
            for (Dom.XmlNode node : rootNode.getChildElements()) {
                if (node.getName() == 'FIELD' && node.getAttributeValue('Name', '') == 'SELECTED_AMC') 
                {
                    Dom.XmlNode valuesNode = node.getChildElement('VALUES', null);
                    
                    for (Dom.XmlNode valNode : valuesNode.getChildElements()) 
                    {
                    	toReturn.put(valNode.getText(), valNode.getAttributeValue('Description', ''));
                    }
                }
            }
            return toReturn;
        }
        
        return null;
    }

    public static Map<String, String> GetTypesOfAppraisal()
    {
        if (sessionId == null)
        {
            Login();
        }

        if (sessionId != null) 
        {            
            if (VMPOrderFormFieldsResults == null) {
                String request = 'SessionKey=' + EncodingUtil.UrlEncode(sessionId, 'UTF-8') + '&AppraiserID=' + String.valueOf(SETTINGS.EntityID__c).removeEnd('.0');
                
                VMPOrderFormFieldsResults = MakeAPICall('/GetVMPOrderFormFields', 'POST', request);
            }
            
			Dom.Document doc = new Dom.Document();
        	doc.load(VMPOrderFormFieldsResults);
        
            Map<String, String> toReturn = new Map<String, String>();
        	Dom.XmlNode rootNode = doc.getRootElement();
            for (Dom.XmlNode node : rootNode.getChildElements()) {
                if (node.getName() == 'FIELD' && node.getAttributeValue('Name', '') == 'TYPE_OF_APPRAISAL') {
                    Dom.XmlNode valuesNode = node.getChildElement('VALUES', null);
                    for (Dom.XmlNode valNode : valuesNode.getChildElements()) {
                    	toReturn.put(valNode.getText(), valNode.getAttributeValue('Description', ''));
                    }
                }
            }
            return toReturn;
        }
        
        return null;
    }

    public static GetCurrentStatusResponse GetCurrentStatusXSiteClientEx(String trackingId)
    {
        GetCurrentStatusResponse serverResponse = new GetCurrentStatusResponse();

        if (sessionId == null)
        {
            Login();
        }

        if (sessionId != null) 
        {            
            String request = 'SessionKey=' + EncodingUtil.UrlEncode(sessionId, 'UTF-8') + '&ProductItemID=' + EncodingUtil.UrlEncode(trackingId, 'UTF-8');
            
            String result = MakeAPICall('/GetCurrentStatusXSiteClientEx', 'POST', request);

            String callStatus = GetStringValue(result, new List<String> { 'Success' });

            if (callStatus == 'true')
            {
                serverResponse.status = GetStringValue(result, new List<String> { 'StatusName' });

                return serverResponse;
            }
        }
        
        return null;
    }

    public static String PlaceAppraisalOrderEx(String XML) {
        
        if (sessionId == null)
        {
            Login();
        }

        if (sessionId != null) 
        {            
            String request = 'SessionKey=' + EncodingUtil.UrlEncode(sessionId, 'UTF-8') + '&XMLPost=' + EncodingUtil.UrlEncode(XML, 'UTF-8');
            
            String result = MakeAPICall('/PlaceAppraisalOrderEx', 'POST', request);

            String auth = GetStringValue(result, new List<String> { 'bResult' });

            if (auth == 'true')
            {
                return GetStringValue(result, new List<String> { 'TrackingID' });
            }
        }
        
        return null;
    }
    
    private static void Login() 
    {
        if (SETTINGS != null)
        {
            string loginReq = 'username=' + EncodingUtil.UrlEncode(SETTINGS.Username__c, 'UTF-8') + '&password=' + EncodingUtil.UrlEncode(SETTINGS.Password__c, 'UTF-8');
            
            String loginResult = MakeAPICall('/Login', 'POST', loginReq);
            
            String auth = GetStringValue(loginResult, new List<String> { 'IsAuthenticated' });

            if (auth == 'true')
            {
                sessionid = GetStringValue(loginResult, new List<String> { 'SessionKey' });
            }
        }
    }
    
    private static String GetStringValue(String XML, List<String> path) 
    {
        Dom.Document doc = new Dom.Document();
        doc.load(XML);
        
        Dom.XmlNode node = doc.getRootElement();

        for (String pathElem : path) 
        {
            node = node.getChildElement(pathElem, 'http://alamode.com/');
        }
        
        return node.getText();
    }
    
    // Methods that can make a call
    private static String MakeAPICall(String url, String action, String request) 
    {
        if (SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(SETTINGS.URL__c + url);
            req.setMethod(action);
            //req.setHeader('Content-Type', 'text/xml');
            req.setTimeout(60000);

            if (request != null)
            {
                req.setBody(request);
            }  
           
            HttpResponse apiResponse;

            if(!System.Test.isRunningTest())
            {
                Http http = new Http();
                apiResponse = http.send(req);
            }
            else
            {
                apiResponse = SpruceCalloutMock.respond(req);
            }  
            
            CreateLogEntry(url, action, request, apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus(), false);

            return apiResponse.getBody();
            
        }
        else 
        {
            return 'No Settings';
        }    
    }
    
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

    public class GetCurrentStatusResponse
    {
        public String status {get; set;}
        public String errorMessage {get; set;}

        public GetCurrentStatusResponse()
        {
            status = '';
            errorMessage = '';
        }
    }
    
}