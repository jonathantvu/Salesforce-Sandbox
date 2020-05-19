@RestResource(urlMapping='/Webhook')
global class DelightedWebhook {

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
	    RestResponse res = RestContext.response;
        
        try {
            string body = req.requestBody.toString();
            
            DelightedHelper.HandleWebhook(body);
            
            res.statusCode = 200;
        } catch(Exception ex) {
            res.statusCode = 500;
        }
    }
    
}