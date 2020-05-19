/**********************************************************
 * @className   : YodleeAPI.cls
 * @testClass   : YodleeHelper_TEST.cls
 * @author      : Omnivo Digital (www.omnivodigital.com)
 * @date        : May 7, 2018
 * @description : -
 *
 *
 **********************************************************/ 

public with sharing class YodleeAPI 
{
    private static RiskInsightCredential__mdt SETTING_PRIVATE;

    public static RiskInsightCredential__mdt SETTINGS
    {
        get
        {
            if(SETTING_PRIVATE == null)
            {
                List<RiskInsightCredential__mdt> apiCredentials =
                [
                    SELECT Id, API_Key__c, Secret_Key__c, URL__c, Product_Code__c
                    FROM RiskInsightCredential__mdt
                    WHERE DeveloperName = 'RiskInsightCredential'
                ];

                if(apiCredentials.size() > 0)
                {
                    SETTING_PRIVATE = apiCredentials[0];
                }
            }

            return SETTING_PRIVATE;
        }
    }    


    /****
    *
    * Authentication API Call
    *
    *****/
    public static String authenticate()
    {
        String serverToken = null;

        if(SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(SETTINGS.URL__c + '/v3/tenants/login');
            req.setMethod('POST');
            req.setHeader('Authorization','Basic ' + EncodingUtil.base64Encode(Blob.valueOf(SETTINGS.API_Key__c + ':' + SETTINGS.Secret_Key__c)));
           
            Jsonparser parser;
            if(!System.Test.isRunningTest()){
                Http http = new Http();
                Httpresponse apiResponse = http.send(req);
            
                parser = Json.createParser(apiResponse.getBody());
            }else{
                parser = Json.createParser(YodleeCalloutMockImpl.AuthenticateResp().getBody());
            }

            while (parser.nextToken() != null) 
            {
                parser.nextValue();
                String fieldName = parser.getCurrentName();
                String fieldValue = parser.getText();

                if(fieldName == 'token')
                {
                    serverToken = fieldValue;
                    break;
                }
            }
        }

        return serverToken;
    }


    /*****
    *
    * Notification Email Reissue
    *
    ******/
    public static EmailReIssueResponse EmailReIssue(String orderId)
    {
        EmailReIssueResponse response = new EmailReIssueResponse();

        if(SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            String url = SETTINGS.URL__c + '/v3/orders/' + orderId + '/notify';
            req.setEndpoint(url);
            req.setMethod('PUT');
            req.setHeader('X-Tenant-Token', YodleeHelper.yodleeAccessToken);
            
            Httpresponse apiResponse;
            if(!System.Test.isRunningTest()){
                Http http = new Http();
                apiResponse = http.send(req);
            }else{
                apiResponse = YodleeCalloutMockImpl.CreateOrderResp();
            }

            /*system.debug(apiResponse.getStatusCode() + ' -- ' + apiResponse.getStatus());
            system.debug(apiResponse.getBody());*/
            
            response.statusCode = String.valueOf(apiResponse.getStatusCode());

            CreateLogEntry(url, 'PUT', '', apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus());
        }

        return response;
    }

    /*****
    *
    * Check Order Status
    *
    ******/
    public static CheckOrderStatusResponse CheckOrderStatus(String orderId, Boolean createLog)
    {
        CheckOrderStatusResponse response = new CheckOrderStatusResponse();

        List<OrderStatusCodes__c> orderStatusCodes = 
            [
                SELECT Id, Description__c, Status__c, Value__c
                FROM OrderStatusCodes__c
            ];

        if(SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            String url = SETTINGS.URL__c + '/v3/orders/' + orderId + '/status';
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setHeader('X-Tenant-Token', YodleeHelper.yodleeAccessToken);
           
            Httpresponse apiResponse;
            if(!System.Test.isRunningTest()){
                Http http = new Http();
                apiResponse = http.send(req);
            }else{
                apiResponse = YodleeCalloutMockImpl.OrderStatusResp();
            }

            /*system.debug(apiResponse.getStatusCode() + ' -- ' + apiResponse.getStatus());
            system.debug(apiResponse.getBody());*/

            response.statusCode = String.valueOf(apiResponse.getStatusCode());

            Jsonparser parser = Json.createParser(apiResponse.getBody());

            while(parser.nextToken() != null) 
            {
                parser.nextValue();
                String fieldName = parser.getCurrentName();
                String fieldValue = parser.getText();

                if(fieldName == 'status')
                {
                    response.value = fieldValue;
                    break;
                }
            }

            for(OrderStatusCodes__c orderStatusCode : orderStatusCodes)
            {
                if(response.value == orderStatusCode.Value__c )
                {
                    response.description = orderStatusCode.Description__c;
                    response.orderStatus = orderStatusCode.Status__c;
                    break;
                }
            }

            if (createLog){
                CreateLogEntry(url, 'GET', '', apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus());
            }
            
       }

       return response;
    }

    /*****
    *
    *  Create Order Call
    *
    ******/
    public static CreateOrderResponseWrapper CreateOrder(CreateOrderCallServerRequest request)
    {
        CreateOrderResponseWrapper response = new CreateOrderResponseWrapper();

        if(SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            String url = SETTINGS.URL__c + '/v3/orders';
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('X-Tenant-Token', YodleeHelper.yodleeAccessToken);
            req.setBody(Json.serialize(request));
           
            Httpresponse apiResponse;
            if(!System.Test.isRunningTest()){
                Http http = new Http();
                apiResponse = http.send(req);

                /*system.debug(apiResponse.getStatusCode() + ' -- ' + apiResponse.getStatus());
                system.debug(apiResponse.getBody());*/
            }else{
                apiResponse = YodleeCalloutMockImpl.CreateOrderResp();
            }

            response.serverResponse = (CreateOrderCallServerResponse)JSON.deserialize(apiResponse.getBody(), CreateOrderCallServerResponse.class);

            if(String.valueOf(apiResponse.getStatusCode()) != '200')
            {
                response.errorMessage = apiResponse.getBody();
            }

            CreateLogEntry(url, 'POST', Json.serialize(request), apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus());
        }

        return response;
    }

    /*****
    *
    * @name         : RetriveOrder
    * @description  : This method is used to retrive an order from Yodlee based on it's id 
    * @param        : (String) orderId
    *
    ******/
    public static CreateOrderResponseWrapper RetriveOrder(String orderId){
        CreateOrderResponseWrapper response = new CreateOrderResponseWrapper();

        if(SETTINGS != null)
        {
            HttpRequest req = new HttpRequest();
            String endPointUrl = SETTINGS.URL__c + '/v3/orders/' + orderId;
            req.setEndpoint(endPointUrl);
            req.setMethod('GET');
            req.setHeader('X-Tenant-Token', YodleeHelper.yodleeAccessToken);

            Httpresponse apiResponse;
            if(!System.Test.isRunningTest()){
                Http http = new Http();
                apiResponse = http.send(req);
            }else{
                apiResponse = YodleeCalloutMockImpl.CreateOrderResp();
            }

            response.serverResponse = (CreateOrderCallServerResponse)JSON.deserialize(apiResponse.getBody(), CreateOrderCallServerResponse.class);
            
            if(String.valueOf(apiResponse.getStatusCode()) != '200')
            {
                response.errorMessage = apiResponse.getBody();
            }

            //create log entry
            CreateLogEntry(endPointUrl, 'GET', '', apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus());
        }

        return response;
    }

    /*****
    *
    * @name         : RetriveReport
    * @description  : This method is used to retrive a report in pdf format from Yodlee based on it's id 
    * @param        : (String) orderId
    *
    ******/
    public static Blob RetriveReport(String orderId){
        Blob bodyReq;

        if (SETTINGS != null){ 
            HttpRequest req = new HttpRequest();
            String endPointUrl = SETTINGS.URL__c + '/v3/orders/' + orderId + '/report.pdf';
            req.setEndpoint(endPointUrl);
            req.setMethod('GET');
            req.setHeader('X-Tenant-Token', YodleeHelper.yodleeAccessToken);

            Httpresponse apiResponse;
            if(!System.Test.isRunningTest()){
                Http http = new Http();
                apiResponse = http.send(req);
                System.debug('****apiResponse: ' + apiResponse);
            }else{
                apiResponse = YodleeCalloutMockImpl.CreateOrderResp();
            }

            bodyReq = apiResponse.getBodyAsBlob();

            //create log entry
            CreateLogEntry(endPointUrl, 'GET', '', 'Report File in .pdf format', String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus());
        }

        return bodyReq;
    
    }

    /*****
    *
    * @name         : CreateLogEntry
    * @description  : This method is used to generate Log entries records and insert thme in SF
    *
    ******/
    public static void CreateLogEntry(String url, String method, String request, String response, String statusCode, String statusMessage)
    {
        Yodlee_Call_Log__c newLogEntry = new Yodlee_Call_Log__c();
        newLogEntry.Name = 'Log call at:  ' + Datetime.now();
        newLogEntry.Method__c = method;
        newLogEntry.Request__c = request;
        newLogEntry.Response__c = response;
        newLogEntry.Status_Code__c = statusCode;
        newLogEntry.Status_Message__c = statusMessage;
        newLogEntry.URL__c = url;
        insert newLogEntry;
    }

    public class CheckOrderStatusResponse
    {
        public String statusCode {get; set;}
        public String orderStatus {get; set;}
        public String description {get; set;}
        public String value {get; set;}
    }

    public class EmailReIssueResponse
    {
        public String statusCode {get; set;}
    }

    public class CreateOrderResponseWrapper
    {
        public CreateOrderCallServerResponse serverResponse {get; set;}
        public String errorMessage {get; set;}

        public CreateOrderResponseWrapper()
        {
            serverResponse = new CreateOrderCallServerResponse(); 
            errorMessage = '';
        }
    }

    // Create new order call Request, data structure
    public class CreateOrderCallServerRequest
    {
        public Applicant applicant {get; set;}
        public List<Co_applicants> co_applicants {get; set;}
        public Requestor requestor {get; set;}
        public String webhook {get; set;}
        public Boolean skip_notification {get; set;}
        public String product {get; set;}

        public CreateOrderCallServerRequest()
        {
            applicant = new Applicant();
            co_applicants = new List<Co_applicants>();
            requestor = new Requestor();
        }
    }

    // Create new order call Response, data structure
    public class CreateOrderCallServerResponse
    {
        public String public_id {get; set;}
        public String consumer_id {get; set;}
        public Applicant applicant {get; set;}
        public List<Co_applicants> co_applicants {get; set;}
        public Requestor requestor {get; set;}
        public String webhook {get; set;}
        public Boolean skip_notification {get; set;}
        public Product product {get; set;}
        public String status {get;set;}

        public CreateOrderCallServerResponse()
        {
            applicant = new Applicant();
            co_applicants = new List<Co_applicants>();
            requestor = new Requestor();
            product = new Product();
        }
    }

    public class Product
    {
        public String code {get; set;}
        public String description {get; set;}
        public Integer flow_type {get; set;}
    }

    public class Requestor
    {
        public String company_id {get; set;}
        public String company_name {get; set;}
        public String broker {get; set;}
        public String processor {get; set;}
        public String phone {get; set;}
        public String email {get; set;}
        public String reference_no {get; set;}
    }

    public class Co_applicants
    {
        public String first_name {get; set;}
        public String middle_name {get; set;}
        public String last_name {get; set;}
        public String suffix {get; set;}
        public String email {get; set;}
        public String zip {get; set;}
        public String ssn {get; set;}
        public Employer employer {get; set;}
        public List<Previous_employers> previous_employers {get; set;}
        public String dob {get; set;}
        public String mobile_phone {get; set;}
        public String work_phone {get; set;}
        public String home_phone {get; set;}
        public String address {get; set;}
        public String address2 {get; set;}
        public String city {get; set;}
        public String state {get; set;}

        public Co_applicants()
        {
            employer = new Employer();
            previous_employers = new List<Previous_employers>();
        }
    }

    public class Applicant
    {
        public String first_name {get; set;}
        public String middle_name {get; set;}
        public String last_name {get; set;}
        public String suffix {get; set;}
        public String ssn {get; set;}
        public String dob {get; set;}
        public String email {get; set;}
        public String mobile_phone {get; set;}
        public String work_phone {get; set;}
        public String home_phone {get; set;}
        public String address {get; set;}
        public String address2 {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String zip {get; set;}
        public Employer employer {get; set;}
        public List<Previous_employers> previous_employers {get; set;}
        public List<Institutions> institutions {get; set;}
        public Integer annual_income {get; set;}
        public Integer monthly_income {get; set;}
        public Integer weekly_income {get; set;}
        public Integer net_income {get; set;}
        public String marital_status {get; set;}
        public Integer dependents {get; set;}

        public Applicant()
        {
            employer = new Employer();
            previous_employers = new List<Previous_employers>();
            institutions = new List<Institutions>();
        }
    }

    public class Institutions
    {
        public String name {get; set;}
        public String site_id {get; set;}
        public String routing_no {get; set;}
        public List<Accounts> accounts {get; set;}

        public Institutions()
        {
            accounts = new List<Accounts>();
        }
    }

    public class Accounts
    {
        public String name {get; set;}
        public String account_type {get; set;}
        public String account_no {get; set;}
        public String name_on_account {get; set;}
        public String account_nickname {get; set;}
        public String account_address {get; set;}
        public Boolean shared {get; set;}
    }

    public class Previous_employers
    {
        public String name {get; set;}
        public String position {get; set;}
        public Integer length_months {get; set;}
        public String pay_cycle {get; set;}
        public String type {get; set;}
        public String start_date {get; set;}
        public String end_date {get; set;}
        public Integer pay_amt_gross {get; set;}
        public Integer pay_amt_net {get; set;}
    }

    public class Employer
    {
        public String name {get; set;}
        public String position {get; set;}
        public Integer length_months {get; set;}
        public String pay_cycle {get; set;}
        public String type {get; set;}
        public String start_date {get; set;}
        public String end_date {get; set;}
        public Integer pay_amt_gross {get; set;}
        public Integer pay_amt_net {get; set;}
    }

    public class Webhook_Order{
        public String order_id {get;set;}
        public String status {get;set;}

        public Webhook_Order(){
            this.order_id = '';
            this.status = '';
        }
    }
}