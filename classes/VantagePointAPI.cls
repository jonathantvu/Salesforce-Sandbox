public with sharing class VantagePointAPI 
{
	private static VantagePointCredential__mdt SETTING_PRIVATE;

    public static VantagePointCredential__mdt SETTINGS
    {
        get
        {
            if(SETTING_PRIVATE == null)
            {
                List<VantagePointCredential__mdt> apiCredentials =
                [
                    SELECT Id, UserName__c, URL__c, Password__c
                    FROM VantagePointCredential__mdt
                    WHERE DeveloperName = 'VantagePointCredentials'
                ];

                if(apiCredentials.size() > 0)
                {
                    SETTING_PRIVATE = apiCredentials[0];
                }
            }

            return SETTING_PRIVATE;
        }
    }

    public static PlaceOrderResponse PlaceOrder(PlaceOrderRequest request)
    {
        PlaceOrderResponse response = new PlaceOrderResponse();

        APICallResult callResult = MakeAPICall(SETTINGS.URL__c + 'api/orders', 'POST', Json.serialize(request));
        
        if (callResult.error)
        {
            System.debug(callResult.message);

            response = (PlaceOrderResponse)JSON.deserialize(callResult.message, PlaceOrderResponse.class);
            response.hasErrors = true;
        }
        else
        {
            response = (PlaceOrderResponse)JSON.deserialize(callResult.message, PlaceOrderResponse.class);
            response.hasErrors = false;
        }

        system.debug(response);

        return response;
    }

    private static APICallResult MakeAPICall(String url, String action, String request) 
    {
        return MakeAPICall(url, action, request, false, true);
    }
    
    private static APICallResult MakeAPICall(String url, String action, String request, boolean isFile, Boolean saveCallLogs) 
    {        
        APICallResult toReturn = new APICallResult();
        
        if(SETTINGS != null)
        { 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(action);
            req.setHeader('Authorization','Basic ' + EncodingUtil.base64Encode(Blob.valueOf(SETTINGS.UserName__c + ':' + SETTINGS.Password__c)));
            req.setHeader('Content-Type', 'application/json');   
            req.setHeader('Accept', 'application/json');         
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

                System.debug(apiResponse);
            }
            else
            {
                apiResponse = VantagePointCalloutMock.respond(req);
            }   
            
            CreateLogEntry(url, action, request, apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus(), saveCallLogs);

            if (String.valueOf(apiResponse.getStatusCode()) != '200')
            {
                toReturn.error = true;
                toReturn.message = apiResponse.getBody();
            }
            else
            {
                toReturn.error = false;

                if(isFile) 
                {
                    toReturn.blobMessage = apiResponse.getBodyAsBlob();
                } 
                else 
                {
                    toReturn.message = apiResponse.getBody();
                }
            }
            
        }
        else 
        {
            toReturn.error = true;
            toReturn.message = 'No Settings';
        }
        
        return toReturn;        
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

        insert newLogEntry;
    }

    private class APICallResult 
    {
        public Boolean error { get; set; }
        public String message { get; set; }
        public Blob blobMessage { get; set; }

        public APICallResult()
        {
            error = false;
            message = '';
            blobMessage = null;
        }
    }

    public class PlaceOrderResponse
    {
        public ResponseStatus ResponseStatus {get; set;}
        public Integer FileID {get; set;}
        public String FileNumber {get; set;}
        public Boolean hasErrors {get; set;}

        public PlaceOrderResponse()
        {
            ResponseStatus = new ResponseStatus();
            hasErrors = false;
        }
    }

    public class ResponseStatus
    {
        public String ErrorCode {get; set;}
        public String Message {get; set;}
        public List<Errors> Errors {get; set;}

        public ResponseStatus()
        {   
            ErrorCode = '';
            Message = '';
            Errors = new List<Errors>();
        }
    }

    public class Errors
    {
        public String ErrorCode {get; set;}
        public String FieldName {get; set;}
        public String Message {get; set;}

        public Errors()
        {
            ErrorCode = '';
            FieldName = '';
            Message = '';
        }
    }

    public class PlaceOrderRequest
    {
        public List<Sellers> Sellers {get;set;}
        public List<Buyers> Buyers {get;set;}        
        public String EstimatedSettlementDate {get; set;}
        public String ClientFileNumber {get; set;}
        public TransactionProductType TransactionProductType {get; set;}
        public String SettlementStatementVersion {get; set;}
        public Decimal SalesPrice {get; set;}
        public List<Loans> Loans {get; set;}
        public List<Property> Properties {get; set;}
        public String EncompassLoanNumber {get; set;}

        public PlaceOrderRequest()
        {
            Buyers = new List<Buyers>();            
            Sellers = new List<Sellers>();
            EstimatedSettlementDate = '';
            TransactionProductType = new TransactionProductType();            
            SalesPrice = 0;
            Loans = new List<Loans>();
            Properties = new List<Property>();
            ClientFileNumber = '';
            SettlementStatementVersion = '';
            EncompassLoanNumber = '';
        }
    }

	public class Buyers
    {
        public String EntityType {get; set;}
        public Boolean IsPrimaryTransactee {get; set;}
        public Primary Primary {get; set;}
        public Boolean UsePropertyAddress {get; set;}
        public Address Address {get; set;}
        public String MaritalStatus {get; set;}
        public String Email {get; set;}
        public String HomePhone {get; set;}

        public Buyers()
        {
            EntityType = '';
            IsPrimaryTransactee = false;
            Primary = new Primary();
            UsePropertyAddress = false;
            Address = new Address();
            MaritalStatus = '';
            Email = '';
            HomePhone = '';
        }
    }    
    
    public class Sellers
    {
        public String EntityType {get; set;}
        public Boolean IsPrimaryTransactee {get; set;}
        public Primary Primary {get; set;}
        public Boolean UsePropertyAddress {get; set;}
        public Address Address {get; set;}
        public String MaritalStatus {get; set;}
        public String Email {get; set;}
        public String HomePhone {get; set;}
        public String Company {get; set;}

        public Sellers()
        {
            EntityType = '';
            IsPrimaryTransactee = false;
            Primary = new Primary();
            UsePropertyAddress = false;
            Address = new Address();
            MaritalStatus = '';
            Email = '';
            HomePhone = '';
            Company = '';
        }
    }

    public class Primary
    {
        public String First {get; set;}
        public String Last {get; set;}
        public String Middle {get; set;}
        public String TaxID {get; set;}

        public Primary()
        {
            First = '';
            Last = '';
            Middle = '';
            TaxID = '';
        }
    }

    public class Address
    {
        public String Address1 {get; set;}
        public String City {get; set;}
        public String State {get; set;}
        public String Zip {get; set;}

        public Address()
        {
            Address1 = '';
            City = '';
            State = '';
            Zip = '';
        }
    }

    public class TransactionProductType
    {
        public Integer TransactionTypeID {get; set;}
        public Integer ProductTypeID {get; set;}

        public TransactionProductType()
        {
            TransactionTypeID = 0;
            ProductTypeID = 0;
        }
    }

    public class Loans
    {
        public Integer LienPosition {get; set;}
        public Decimal LoanAmount {get; set;}
        public String LoanType {get; set;}

        public Loans()
        {
            LienPosition = 0;
            LoanAmount = 0;
            LoanType = '';
        }
    }  
   
    public class Property
    {
        public Boolean IsPrimary {get; set;}
        public String StreetNumber {get; set;}
        public String StreetName {get; set;}
        public String City {get; set;}
        public String State {get; set;}
        public String County {get; set;}
        public String Zip {get; set;}
        //public Boolean ValidateAddress {get; set;}

        public Property()
        {
            IsPrimary = false;
            StreetNumber = '';
            StreetName = '';
            City = '';
            State = '';
            County = '';
            Zip = '';
        }
    }
}