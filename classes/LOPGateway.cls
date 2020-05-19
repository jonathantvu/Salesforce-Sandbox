/**
 *  
 * @Created Date : 05-04-2017
 * @Authors      : StarrData
 */
public with sharing class LOPGateway {
    
    private HTTPRequest request;    
    private APIConfigurationWrapper config;
    
    /**
     * Class Contructure.
     */
    public LOPGateway(APIConfigurationWrapper config) {
        this.request = new HTTPRequest();
        // Default headers
        for(String header: config.defaultHeaders.keySet()) {
            request.setHeader(header, config.defaultHeaders.get(header));
        }
        this.config = config;
    }
    
    /** 
     * Method for send HTTP request to specified endpoint and return responce.
     * @Param       -
     * @Returns     HTTPResponse
     */
    public HTTPResponse sendRequest(){
        HTTP httpService = new HTTP();
        system.debug('HTTP request----' + request);
        system.debug('HTTP Authorization header---' + request.getHeader('Authorization'));
        system.debug('HTTP request body---' + request.getBody() );        
        HTTPResponse response = httpService.send(request);
        system.debug('HTTP response body---' + response.getBody());
        return response;
    }
    
    /** 
     * Method for perform POST request to API endpoint.
     * @Param       body, contains JSON Format Data to post.
     * @Returns     HttpResponse
     */
    public HttpResponse apiPost(String body){
        request.setMethod('POST');
        request.setBody(body);
        prepareRequest();
        return sendRequest();
    }
    
    /** 
     * Method for perform DELETE request to API endpoint.
     * @Param       -
     * @Returns     HttpResponse
     */
    public HttpResponse apiDelete(){
        request.setMethod('DELETE');
        prepareRequest();
        return sendRequest();
    }
    
    /** 
     * Method for prepare request to send.
     * - set required headers values, and common header values.
     * @Param       -
     * @Returns     -
     */
    private void prepareRequest(){
        String endpoint = config.API_BASE_URL + config.API_ENDPOINT;
        request = addBasicAuth(request);        
        request.setEndpoint(endpoint);
        request.settimeout(120000);
    }
    
    /** 
     * Method for generate header contains header's value for basic authentication.
     * @Param       request, in which user need to set basic auth values in header.
     * @Returns     Basic Auth compatible HTTPRequest.
     */
    private HTTPRequest addBasicAuth(HTTPRequest request) {
        LOP_Credential__c LOPCredential = LOP_Credential__c.getInstance();
        String b64AuthString = EncodingUtil.base64Encode(Blob.valueOf(LOPCredential.UserName__c+ ':' +LOPCredential.Password__c));
        request.setHeader('Authorization', 'Basic ' + b64AuthString);
        return request;
    }
}