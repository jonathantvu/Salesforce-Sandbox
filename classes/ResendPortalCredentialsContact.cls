public class ResendPortalCredentialsContact {
    static String URL = 'https://portal.unison.com/api/v1/users/welcome_email';
    static String HTTP_METHOD = 'POST';
    static String AUTH_KEY = 'Basic c2FsZXNmb3JjZTpwYXNzd29yZA==';
    static String CONTENT_TYPE = 'application/json;charset=UTF-8';

    @AuraEnabled
    public static String ResendWelcomeEmail(Id contactId) {
        try {
            String CaseSafeID = [SELECT Id, Case_Safe_ID__c FROM Contact WHERE Id =: contactId].Case_Safe_ID__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            if(CaseSafeID != null) {
                request.setEndpoint(URL);
                request.setMethod(HTTP_METHOD);
                request.setHeader('Authorization', AUTH_KEY);
                request.setHeader('Content-Type', CONTENT_TYPE);
                request.setBody('{"salesforce_id": ' + '"' + CaseSafeID + '"' + '}');
                if(!Test.IsRunningTest()) {
                    response = http.send(request);
                }
            }
            return response.getBody();
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}