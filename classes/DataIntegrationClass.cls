public class DataIntegrationClass {

    public static String ReturnAccessToken() {
        DataIntegrationCredential__mdt cred = [SELECT ClientID__c, TokenURL__c ,ClientSecret__c, Password__c, SecurityToken__c, Username__c 
                                                FROM DataIntegrationCredential__mdt 
                                                WHERE MasterLabel = :OrgIdentifier()];

        String clientId = cred.ClientID__c;
        String clientSecret = cred.ClientSecret__c;
        String username = cred.Username__c;
        String password = cred.Password__c;

        String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=' + username + '&password=' + password;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(cred.TokenURL__c);
        
        HttpResponse res = h.send(req);

        accessTokenLog = CreateLog(reqbody, res.getbody(), res.getStatusCode());
        if (res.getStatusCode() != 200) {
            accessTokenLog.Error__c = true;
        }
        
        try {
            deserializeResponse resp1 = (deserializeResponse)JSON.deserialize(res.getbody(), deserializeResponse.class);
            return resp1.access_token;
        }
        catch (Exception ex) {
            accessTokenLog.Error__c = true;
            return null;
        }
    }
    public static SFDC_to_SFDC_Log__c accessTokenLog { get; set; }

    private static string orgIdentifierName;
    public static string OrgIdentifier() {
        if (orgIdentifierName == null) {
            Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
            if (!org.IsSandbox) {
                orgIdentifierName = 'Production';
            } else {
                orgIdentifierName = getUsersSuffix();
            }
        }
        return orgIdentifierName;
    }
    
    @TestVisible
    private static string getUsersSuffix() {
        List<User> allUsers = [SELECT Username FROM User LIMIT 100];
        Map<String, Integer> suffixMap = new Map<String, Integer>();
        for (User usr : allUsers) {
            if (usr.Username.contains('.')) {
                string suffix = usr.Username.substring(usr.Username.lastIndexOf('.') + 1);
                if (!suffixMap.containsKey(suffix)) {
                    suffixMap.put(suffix, 0);
                }
                suffixMap.put(suffix, suffixMap.get(suffix) + 1);
            }
        }
        string maxSuffix = null;
        for (string key : suffixMap.keySet()) {
            if (maxSuffix == null || suffixMap.get(key) > suffixMap.get(maxSuffix)) {
                maxSuffix = key;
            }
        }
        return 'Sandbox : ' + maxSuffix;
    }

    public static SFDC_to_SFDC_Log__c CreateLog(string requestBody, string responseBody, integer statusCode) {
        SFDC_to_SFDC_Log__c log = new SFDC_to_SFDC_Log__c();

        log.Request_Body__c = requestBody;
        if (log.Request_Body__c.length() > 131070) {
            log.Request_Body__c = log.Request_Body__c.substring(0, 131060) + '...';
        }
        log.Response_Body__c = responseBody;
        if (log.Response_Body__c.length() > 8190) {
            log.Response_Body__c = log.Response_Body__c.substring(0, 8180) + '...';
        }
        log.Response_Code__c = statusCode;

        return log;
    }
    
    public class deserializeResponse{
        public String id;
        public String access_token;
    }

}