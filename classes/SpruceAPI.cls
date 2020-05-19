/**********************************************************
 *
 * @className   : SpruceAPI.cls
 * @testClass   : SpruceHelperTest.cls
 * @author      : Omnivo Digital (www.omnivodigital.com)
 * @date        : May 15, 2018
 *
 **********************************************************/ 

public with sharing class SpruceAPI 
{
	private static SpruceAPICredentials__mdt SETTING_PRIVATE;

    public static SpruceAPICredentials__mdt SETTINGS
    {
        get
        {
            if(SETTING_PRIVATE == null)
            {
                List<SpruceAPICredentials__mdt> apiCredentials =
                [
                    SELECT Id, Token__c, URL__c
                    FROM SpruceAPICredentials__mdt
                    WHERE DeveloperName = 'SpruceAPICredentials'
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
    * Get token from the custom metadata
    *
    *****/
    public static String getToken()
    {
        String serverToken = null;

        if(SETTINGS != null)
        { 
            serverToken = SETTINGS.Token__c; 
        }

        return serverToken;
    }

    public static CreateRefinanceTransactionQuoteResponse CreateRefinanceTransactionQuote(CreateRefinanceTransactionQuoteRequest request)
    {
        CreateRefinanceTransactionQuoteResponse response = new CreateRefinanceTransactionQuoteResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/quotes/v3/refinance', 'POST', Json.serialize(request));
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (CreateRefinanceTransactionQuoteResponse)JSON.deserialize(callResult.message, CreateRefinanceTransactionQuoteResponse.class);
        }

        return response;
    }

    public static CreateRefinanceTransactionQuoteResponse CreatePurchaseTransactionQuote(CreatePurchaseTransactionQuoteRequest request)
    {
        CreateRefinanceTransactionQuoteResponse response = new CreateRefinanceTransactionQuoteResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/quotes/v3/purchase', 'POST', Json.serialize(request));
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (CreateRefinanceTransactionQuoteResponse)JSON.deserialize(callResult.message, CreateRefinanceTransactionQuoteResponse.class);
        }

        return response;
    }

    public static CreateRefinanceTransactionTitleOrderResponse CreateRefinanceTransactionTitleOrder(CreateRefinanceTransactionTitleOrderRequest request)
    {
        CreateRefinanceTransactionTitleOrderResponse response = new CreateRefinanceTransactionTitleOrderResponse();
        
        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/orders/v3/refinance', 'POST', Json.serialize(request));
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (CreateRefinanceTransactionTitleOrderResponse)JSON.deserialize(callResult.message, CreateRefinanceTransactionTitleOrderResponse.class);
        }

        return response;
    }

    public static CreateRefinanceTransactionTitleOrderResponse CreatePurchaseMortgageTransactionTitleOrder(CreatePurchaseMortgageTransactionTitleOrderRequest request)
    {
        CreateRefinanceTransactionTitleOrderResponse response = new CreateRefinanceTransactionTitleOrderResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/orders/v3/purchase', 'POST', Json.serialize(request));
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (CreateRefinanceTransactionTitleOrderResponse)JSON.deserialize(callResult.message, CreateRefinanceTransactionTitleOrderResponse.class);
        }

        return response;
    }

    public static CreateRefinanceTransactionTitleOrderResponse RetrieveOrderInfo(String orderId)
    {
        CreateRefinanceTransactionTitleOrderResponse response = new CreateRefinanceTransactionTitleOrderResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/orders/v3/' + orderId, 'GET', null);
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (CreateRefinanceTransactionTitleOrderResponse)JSON.deserialize(callResult.message, CreateRefinanceTransactionTitleOrderResponse.class);
        }

        return response;
    }

    public static RetrieveAvailableDocumentTypesForOrderResponse RetrieveAvailableDocumentTypesForOrder(String orderId)
    {
        RetrieveAvailableDocumentTypesForOrderResponse response = new RetrieveAvailableDocumentTypesForOrderResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/public_documents/v1/' + orderId + '/downloadable_document_types', 'GET', null);
        
        if(callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response.availableDocumentTypes = (List<String>)JSON.deserialize(callResult.message, List<String>.class);
        }

        return response;
    }

    public static RetrieveAvailableDocumentOfGivenTypeResponse RetrieveAvailableDocumentOfGivenType(String orderId, String documentType)
    {
        RetrieveAvailableDocumentOfGivenTypeResponse response = new RetrieveAvailableDocumentOfGivenTypeResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/public_documents/v1/' + orderId + '/' + documentType, 'GET', null, true, false);
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response.file = callResult.blobMessage;
        }

        return response;
    }

    public static RetrieveAvailableDocumentOfGivenTypeResponse UploadDocument(String orderId, String documentType, Attachment file)
    {
        RetrieveAvailableDocumentOfGivenTypeResponse response = new RetrieveAvailableDocumentOfGivenTypeResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/orders/v3/' + orderId + '/documents/' + documentType, 'POST', EncodingUtil.base64Encode(file.Body));
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }

        return response;
    }

    public static RetrieveAvailableDocumentTypesForOrderResponse RetrieveDocumentTypesThatCanBeUploaded()
    {
        RetrieveAvailableDocumentTypesForOrderResponse response = new RetrieveAvailableDocumentTypesForOrderResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/orders/v3/document_types', 'GET', null);
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response.availableDocumentTypes = (List<String>)JSON.deserialize(callResult.message, List<String>.class);
        }

        return response;
    }

    public static GetTitleReportDataResponse GetTitleReportData(String orderId)
    {
        GetTitleReportDataResponse response = new GetTitleReportDataResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/title_reports/v1/' + orderId, 'GET', null);

        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (GetTitleReportDataResponse)JSON.deserialize(callResult.message, GetTitleReportDataResponse.class);
        }

        return response;
    }

    public static SubmitSchedulingRequestForLoanClosingResponse SubmitSchedulingRequestForLoanClosing(SubmitSchedulingRequestForLoanClosingRequest request, String orderId)
    {
        SubmitSchedulingRequestForLoanClosingResponse response = new SubmitSchedulingRequestForLoanClosingResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/orders/v3/' + orderId + '/closing/schedule', 'POST', Json.serialize(request));
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (SubmitSchedulingRequestForLoanClosingResponse)JSON.deserialize(callResult.message, SubmitSchedulingRequestForLoanClosingResponse.class);
        }

        return response;
    }

    public static RetrieveClosingInfoResponse RetrieveClosingInfo(String orderId)
    {
        RetrieveClosingInfoResponse response = new RetrieveClosingInfoResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + '/orders/v3/' + orderId + '/closing', 'GET', null);
        
        if (callResult.error)
        {
            response.errorMessage = callResult.message;
        }
        else
        {
            response = (RetrieveClosingInfoResponse)JSON.deserialize(callResult.message, RetrieveClosingInfoResponse.class);
        }

        return response;
    }
    
    private static APICallResult MakeAPICall(String url, String action, String request) {
        return  MakeAPICall(url, action, request, false, true);
    }
    
    private static APICallResult MakeAPICall(String url, String action, String request, boolean isFile, boolean saveCallLogs) {
        
        APICallResult toReturn = new APICallResult();
        
        if(SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(action);
            req.setHeader('Authorization', 'Bearer ' + getToken());
            req.setHeader('Content-Type', 'application/json');            
            req.setTimeout(60000);
            if (request != null)
            	req.setBody(request);
           
            HttpResponse apiResponse;
			system.debug('Spruce API request---' + request);
            if(!System.Test.isRunningTest())
            {
                Http http = new Http();
                apiResponse = http.send(req);
            }
            else
            {
                apiResponse = SpruceCalloutMock.respond(req);
            }

            System.debug(apiResponse);

            CreateLogEntry(url, action, request, apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus(), saveCallLogs);

            if (String.valueOf(apiResponse.getStatusCode()) != '200' && String.valueOf(apiResponse.getStatusCode()) != '201')
            {
                toReturn.error = true;
                toReturn.message = 'Response error message : ' + apiResponse.getBody() + ' - Response status code: ' + String.valueOf(apiResponse.getStatusCode());
            }
            else
            {
                toReturn.error = false;
                if (isFile) {
                    toReturn.blobMessage = apiResponse.getBodyAsBlob();
                } else {
                	toReturn.message = apiResponse.getBody();
                }
            }
            
        } else {
            toReturn.error = true;
            toReturn.message = 'No Settings';
        }
        
        return toReturn;
        
    }
    
    private class APICallResult {
        public boolean error { get; set; }
        public string message { get; set; }
        public Blob blobMessage { get; set; }
    }

    /*****
    *
    * @name         : CreateLogEntry
    * @description  : This method is used to generate Log entries records and insert them in SF
    *
    ******/
    public static void CreateLogEntry(String url, String method, String request, String response, String statusCode, String statusMessage)
    {
        CreateLogEntry(url, method, request, response, statusCode, statusMessage, true);
    }
    
    public static void CreateLogEntry(String url, String method, String request, String response, String statusCode, String statusMessage, boolean alsoInsert)
    {
        Spruce_Call_Log__c newLogEntry = new Spruce_Call_Log__c();
        newLogEntry.Name = 'Log call at:  ' + Datetime.now();
        newLogEntry.Method__c = method;
        newLogEntry.Request__c = request;
        newLogEntry.Response__c = response.left(131000);
        newLogEntry.Status_Code__c = statusCode;
        newLogEntry.Status_Message__c = statusMessage;
        newLogEntry.URL__c = url;
        if (alsoInsert) {
        	insert newLogEntry;
        } else {
            if (callLogsBuffer == null) {
                callLogsBuffer = new List<Spruce_Call_Log__c>();
            }
            callLogsBuffer.add(newLogEntry);
        }
    }
    
    private static List<Spruce_Call_Log__c> callLogsBuffer { get; set; }
    
    public static void InsertCallLogBuffer() {
        if (callLogsBuffer != null && callLogsBuffer.size() > 0) {
            insert callLogsBuffer;
            callLogsBuffer = new List<Spruce_Call_Log__c>();
        }
    }

    public class RetrieveClosingInfoResponse
    {
        public String errorMessage {get; set;}
        public String closing_date {get; set;}
        public String closing_time {get; set;}
        public Closing_Location closing_location {get; set;}
        public Notary notary {get; set;}

        public RetrieveClosingInfoResponse()
        {
            closing_location = new Closing_Location();
            notary = new Notary();
        }
    }

    public class Notary
    {
        public String name {get; set;}
        public String phone_number {get; set;}
    }

    public class SubmitSchedulingRequestForLoanClosingResponse
    {
        public String errorMessage {get; set;}
    }

    public class SubmitSchedulingRequestForLoanClosingRequest
    {
        public String closing_date {get; set;}
        public String closing_time {get; set;}
        public Closing_Location closing_location {get; set;}

        public SubmitSchedulingRequestForLoanClosingRequest()
        {
            closing_location = new Closing_Location();
        }
    }

    public class Closing_Location
    {
        public String street_address {get; set;}
        public String unit {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String zip_code {get; set;}
    }

    public class GetTitleReportDataResponse
    {
        public String errorMessage {get; set;}
        public String effective_date {get; set;}
        public String vesting_info {get; set;}
        public String legal_description {get; set;}
        public String apn {get; set;}
        public Integer num_of_open_mortgages {get; set;}
        public Integer num_of_bankruptcies {get; set;}
        public Integer num_of_judgements {get; set;}
        public Integer num_of_other_liens {get; set;}

        public GetTitleReportDataResponse()
        {
            errorMessage = '';
        }
    }

    public class RetrieveAvailableDocumentOfGivenTypeResponse
    {
        public String errorMessage {get; set;}
        public Blob file {get; set;}
    }

    public class RetrieveAvailableDocumentTypesForOrderResponse
    {
        public List<String> availableDocumentTypes {get; set;}
        public String errorMessage {get; set;}
    }

    public class CreateRefinanceTransactionTitleOrderResponse
    {
        public String id {get; set;}
        public String order_status {get; set;}
        public List<Fees> fees {get; set;}          
        public Settlement_Agent settlement_agent {get; set;}
        public String errorMessage {get; set;}
        
        public CreateRefinanceTransactionTitleOrderResponse()
        {
            fees = new List<Fees>();
            settlement_agent = new Settlement_Agent();
            errorMessage = '';
        }
    }

    public class CreatePurchaseMortgageTransactionTitleOrderRequest
    {
        public Decimal loan_amount {get; set;}
        public Decimal purchase_price {get; set;}
        public Property_Address property_address {get; set;}
        public List<Borrowers> borrowers {get; set;}

        public CreatePurchaseMortgageTransactionTitleOrderRequest()
        {
            property_address = new Property_Address();
            borrowers = new List<Borrowers>();
        }
    }

    public class CreateRefinanceTransactionTitleOrderRequest
    {
        public Decimal loan_amount {get; set;}
        public String loan_id { get; set; }
        public Decimal estimated_property_value {get; set;}
        public Property_Address property_address {get; set;}
        public List<Borrowers> borrowers {get; set;}
        public List<Parties> parties {get; set;}


        public CreateRefinanceTransactionTitleOrderRequest()
        {
            property_address = new Property_Address();
            borrowers = new List<Borrowers>();
            parties = new List<Parties>();
        }
    }

    public class Borrowers
    {
        public String first_name {get; set;}
        public String middle_name {get; set;}
        public String last_name {get; set;}
        public String email {get; set;}
        public String phone_number {get; set;}
        public String ssn {get; set;}
    }
    
    public class Parties
    {
        public string purpose {get;set;}
        public string lender_user_id {get;set;}
    }

    public class CreatePurchaseTransactionQuoteRequest
    {
        public Decimal loan_amount {get; set;}
        public Decimal purchase_price {get; set;}
        public Boolean buyer_pays_transfer_taxes {get; set;}
        public Property_Address property_address {get; set;}

        public CreatePurchaseTransactionQuoteRequest()
        {
            property_address = new Property_Address();
        }
    }

    public class CreateRefinanceTransactionQuoteRequest
    {
        public Decimal loan_amount {get; set;}
        public Decimal estimated_property_value {get; set;}
        public Property_Address property_address {get; set;}

        public CreateRefinanceTransactionQuoteRequest()
        {
            property_address = new Property_Address();
        }
    }

    public class Property_Address
    {
        public String street_address {get; set;}
        public String unit {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String zip_code {get; set;}
    }

    public class CreateRefinanceTransactionQuoteResponse
    {
        public List<Fees> fees {get; set;}  
        public Settlement_Agent settlement_agent {get; set;}
        public String errorMessage {get; set;}
        
        public CreateRefinanceTransactionQuoteResponse()
        {
            fees = new List<Fees>();
            settlement_agent = new Settlement_Agent();
        }  
    }

    public class Fees
    {
        public String type {get; set;}
        public String label {get; set;}
        public Decimal amount {get; set;}
        public String section {get; set;}    

        public Fees()
        {
            type = '';
            label = '';
            amount = 0;
            section = '';
        }
    }

    public class Settlement_Agent
    {
        public String name {get; set;}
        public SpruceContact contact {get; set;}
        public SpruceAddress address {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public license_info license_info {get; set;}
        public String contact_license_id {get; set;}
        public Wiring_Instructions wiring_instructions {get; set;}

        public Settlement_Agent()
        {
            wiring_instructions = new Wiring_Instructions();
            address = new SpruceAddress();
            contact = new SpruceContact();
        }
    }
    
    public class license_info
    {
        public string state_license_id {get;set;}
        public string contact_license_id {get;set;}
    }
    
    public class SpruceContact
    {
        public String first_name {get; set;}
        public String last_name {get; set;}
        public String formatted_contact {get; set;}

        public SpruceContact()
        {
            first_name = '';
            last_name = '';
            formatted_contact = '';
        }
    }
    
    public class SpruceAddress
    {
        public String street_address {get; set;}
        public String unit {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String zip_code {get; set;}
        public String formatted_address {get; set;}

        public SpruceAddress()
        {
            street_address = '';
            unit = '';
            city = '';
            state = '';
            zip_code = '';
            formatted_address = '';
        }
    }

    public class Wiring_Instructions
    {
        public String account_number {get; set;}
        public String routing_number {get; set;}
        public String obi {get; set;}
    }
}