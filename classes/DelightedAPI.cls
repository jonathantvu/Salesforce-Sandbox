public class DelightedAPI {
    
    private static Delighted_API__mdt settingsPrivate;
    public static Delighted_API__mdt Settings { 
        get {
            if (settingsPrivate == null)
                settingsPrivate = [SELECT Id, Base_URL__c, API_Key__c, Project_API_Key__c FROM Delighted_API__mdt LIMIT 1];
            return settingsPrivate;
        }
    }
    
    private static Map<String, String> apiKeyMapPrivate;
    public static Map<String, String> apiKeyMap {
        get {
            if (apiKeyMapPrivate == null) {
                List<Delighted_API_Key__mdt> apiKeylist = [Select Id, DeveloperName, Key__c from Delighted_API_Key__mdt];
                apiKeyMapPrivate = new Map<String, String>();
                for(Delighted_API_Key__mdt apiKey: apiKeylist){
                    apiKeyMapPrivate.put(apiKey.DeveloperName, apiKey.Key__c);
                }
            }
            return apiKeyMapPrivate;
        }
    }

    public static SendSurveyResponse SendSurvey(String apiKeyName, String email, String name, String phone, String ownerId, 
												String recordTypeId, String recordTypeName, String recType, String recId, String stageOrStatus, 
												Boolean smsOptOut, String lossReasonType, String npsTriggerEvent, String ownerName) {
        
        String requestStr;
        if(!String.isBlank(email)){
            requestStr = 'email=' + EncodingUtil.UrlEncode(email , 'UTF-8');
        }
        if(!String.isBlank(phone)){
        	requestStr += '&phone_number=' + EncodingUtil.UrlEncode(phone , 'UTF-8');                                                
        }                                           
        requestStr += '&name=' + (name == null ? '' : EncodingUtil.UrlEncode(name , 'UTF-8'));                                           
        requestStr += '&channel=' + (String.isBlank(phone) || smsOptOut ? 'email' : 'sms');
		//requestStr += '&phone_number=' + (phone == null ? '' : EncodingUtil.UrlEncode(phone , 'UTF-8'));
        requestStr += '&properties[phone]=' + (phone == null ? '' : EncodingUtil.UrlEncode(phone , 'UTF-8'));
        requestStr += '&properties[stageOrStatus]=' + (stageOrStatus == null ? '' : EncodingUtil.UrlEncode(stageOrStatus , 'UTF-8'));
        requestStr += '&properties[lossReasonType]=' + (lossReasonType == null ? '' : EncodingUtil.UrlEncode(lossReasonType , 'UTF-8'));
        requestStr += '&properties[npsTriggerEvent]=' + (npsTriggerEvent == null ? '' : EncodingUtil.UrlEncode(npsTriggerEvent , 'UTF-8'));
        requestStr += '&properties[ownerId]=' + (ownerId == null ? '' : EncodingUtil.UrlEncode(ownerId , 'UTF-8'));
        requestStr += '&properties[ownerName]=' + (ownerName == null ? '' : EncodingUtil.UrlEncode(ownerName , 'UTF-8'));
        requestStr += '&properties[recordTypeId]=' + (recordTypeId == null ? '' : EncodingUtil.UrlEncode(recordTypeId , 'UTF-8'));
        requestStr += '&properties[Product]=' + (recordTypeName == null ? '' : EncodingUtil.UrlEncode(recordTypeName , 'UTF-8'));
        requestStr += '&properties[' + recType + ']=' + (recId == null ? '' : EncodingUtil.UrlEncode(recId , 'UTF-8'));
                                                    
        /*String delightedPhone;
        if( !String.isBlank( phone ) ){
            delightedPhone = '+1' + phone.deleteWhitespace().remove('(').remove(')').remove('-'); //TO DO: Add logic for generalized country codes
            requestStr += '&phone_number=' + (delightedPhone == null ? '' : EncodingUtil.UrlEncode(delightedPhone , 'UTF-8'));
        }*/
                                                    
        String responseStr = MakeAPICall(Settings.Base_URL__c + '/v1/people.json', 'POST', requestStr, apiKeyMap.get(apiKeyName));
        
        if (responseStr.startsWith('Error:')) {
            return new SendSurveyResponse(responseStr);
        } else {
            SendSurveyResponse resp = (SendSurveyResponse)JSON.deserialize(responseStr, SendSurveyResponse.class);
            resp.success = true;
            return resp;
        }
        
    }

	public static SendSurveyResponse SendLOSurvey(String email, String name, String phone, String ownerId, String accountName, String contact_status, 
												String recordTypeId, String recordTypeName, String recType, String recId, String stageOrStatus, 
												Boolean smsOptOut, String lossReasonType, String npsTriggerEvent, String ownerName, String contactType,
												String apiKeyName) { 
        
        String requestStr = 'email=' + (email == null ? '' : EncodingUtil.UrlEncode(email , 'UTF-8'));
        requestStr += '&name=' + (name == null ? '' : EncodingUtil.UrlEncode(name , 'UTF-8'));
        requestStr += '&channel=' + (String.isBlank(phone) || smsOptOut ? 'email' : 'sms');
        requestStr += '&properties[phone]=' + (phone == null ? '' : EncodingUtil.UrlEncode(phone , 'UTF-8'));
        requestStr += '&properties[stageOrStatus]=' + (stageOrStatus == null ? '' : EncodingUtil.UrlEncode(stageOrStatus , 'UTF-8'));
        requestStr += '&properties[lossReasonType]=' + (lossReasonType == null ? '' : EncodingUtil.UrlEncode(lossReasonType , 'UTF-8'));
        requestStr += '&properties[npsTriggerEvent]=' + (npsTriggerEvent == null ? '' : EncodingUtil.UrlEncode(npsTriggerEvent , 'UTF-8'));
        requestStr += '&properties[ownerId]=' + (ownerId == null ? '' : EncodingUtil.UrlEncode(ownerId , 'UTF-8'));
		requestStr += '&properties[accountName]=' + (accountName == null ? '' : EncodingUtil.UrlEncode(accountName , 'UTF-8'));
		requestStr += '&properties[contactStatus]=' + (contact_status == null ? '' : EncodingUtil.UrlEncode(contact_status , 'UTF-8'));
		requestStr += '&properties[contactType]=' + (contactType == null ? '' : EncodingUtil.UrlEncode(contactType , 'UTF-8'));
        requestStr += '&properties[ownerName]=' + (ownerName == null ? '' : EncodingUtil.UrlEncode(ownerName , 'UTF-8'));
        requestStr += '&properties[recordTypeId]=' + (recordTypeId == null ? '' : EncodingUtil.UrlEncode(recordTypeId , 'UTF-8'));
        requestStr += '&properties[Product]=' + (recordTypeName == null ? '' : EncodingUtil.UrlEncode(recordTypeName , 'UTF-8'));
        requestStr += '&properties[' + recType + ']=' + (recId == null ? '' : EncodingUtil.UrlEncode(recId , 'UTF-8'));
                                                    
        String delightedPhone;
        if( !String.isBlank( phone ) ){
            delightedPhone = '+1' + phone.deleteWhitespace().remove('(').remove(')').remove('-'); //TO DO: Add logic for generalized country codes
            requestStr += '&phone_number=' + (delightedPhone == null ? '' : EncodingUtil.UrlEncode(delightedPhone , 'UTF-8'));
        }
                                                    
        String responseStr = MakeAPICall(Settings.Base_URL__c + '/v1/people.json', 'POST', requestStr, apiKeyMap.get(apiKeyName));
        
        if (responseStr.startsWith('Error:')) {
            return new SendSurveyResponse(responseStr);
        } else {
            SendSurveyResponse resp = (SendSurveyResponse)JSON.deserialize(responseStr, SendSurveyResponse.class);
            resp.success = true;
            return resp;
        }
        
    }

    private static string MakeAPICall(string url, string method, string body, string apiKey) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(apiKey + ':');
        req.setHeader('Authorization', 'BASIC ' + EncodingUtil.base64Encode(headerValue));
        req.setEndpoint(url);
        req.setMethod(method);
        if (body != null)
            req.setBody(body);
        HttpResponse res = new HttpResponse();
        if(!test.isRunningTest()){
	        res = h.send(req);            
        }
        else{
            DelightedMock mock = new DelightedMock();
            res = mock.respond(req);
        }
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300)
            return res.getBody();
        else
            return 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();

    }

    public class SendSurveyResponse {
        public string id { get; set; }
        public boolean success { get; set; }
        public string error { get; set; }

        public SendSurveyResponse(string error) {
            this.error = error;
            this.success = false;
        }
    }
    
    public class SurveyWebhookBody {
        public string event_type { get; set; }
        public SurveyWebhookBodyData event_data { get; set; }
    }
    public class SurveyWebhookBodyData {
        public string survey_type { get; set; }
        public integer score { get; set; }
        public string comment { get; set; }
        public string permalink { get; set; }
        public SurveyWebhookBodyProperties person_properties { get; set; }
        public List<SurveyWebhookBodyAnswer> additional_answers { get; set; }
    }
    public class SurveyWebhookBodyProperties {
        public string lead { get; set; }
        public string opportunity { get; set; }
		public string contact { get; set; }
    }
    public class SurveyWebhookBodyAnswer {
        public SurveyWebhookBodyAnswerQuestion question { get; set; }
        public SurveyWebhookBodyAnswerValue value { get; set; }
    }
    public class SurveyWebhookBodyAnswerQuestion {
        public string type { get; set; }
        public string text { get; set; }
    }
    public class SurveyWebhookBodyAnswerValue {
        public string free_response { get; set; }
        public integer scale { get; set; }
        public SurveyWebhookBodyAnswerChoice select_one { get; set; }
        public List<SurveyWebhookBodyAnswerChoice> select_many { get; set; }
    }
    public class SurveyWebhookBodyAnswerChoice {
        public string text { get; set; }
    }
    
}