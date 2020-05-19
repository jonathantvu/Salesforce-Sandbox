/**
 *  About
 *  -----
 *  Author: Cloud Mine Consulting
 *  Create date: Sun Mar 25 2018
 *  
 *  Details
 *  -----
 *  Apex class to handle integration with Passbook
 *
 *  Update History
 *  -----
 * 
 *  Issues / TODOs
 *  -----
 *  
 **/
global class PassbookRestHelper {

    private static final Passbook_Config__mdt passbookConfig = [Select URI__c,X_API_Client__c,X_API_Secret__c  from Passbook_Config__mdt Limit 1];
    
	private static void initConfig(){        
        
	}    
    
    global PassbookRestHelper(){
        initConfig();
    }        
    
    global static string postToPassbook(passbookJSON passbookClass){
        
		//generate Passbook payload to submit
		string jsonToSend = json.serialize(passbookClass);
        system.debug('jsonToSend---' + jsonToSend);
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(passbookConfig.URI__c);
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json');
		//request.setHeader('passbook-key', passbookConfig.X_API_Client__c);
		request.setHeader('x-api-key', passbookConfig.X_API_Secret__c);        

		// Set the body as a JSON object
		request.setBody(jsonToSend);
        HttpResponse response;
        
        if (!System.Test.isRunningTest()){
            response = http.send(request);
        }else{
            response = PassbookRestMockImpl.respond(request);
        }
		  
        system.debug('request---' + request);
        system.debug('responsebody---' + response.getBody());
        
        CreateLogEntry(jsonToSend,response.getBody(),String.valueOf(response.getStatusCode()),response.getStatus());
        
        return response.getBody();
        
        
        
    }      
    
    global class passbookJSON{
        
        public integer Origination_Credit_Score {get;set;} // Median FICO score from Opportunity and related Personal Credit Report
        public integer num_borrowers {get;set;} // Is there a co-applicant?
        public decimal Income {get;set;}
        public decimal Origination_Front_End_DTI {get;set;}
        public decimal Original_Loan_Amount{get;set;}
        public string Property_State {get;set;}
        public string Occupancy_Status {get;set;}
        public string Product_Type {get;set;} //Homeowner -> HO, Homebuyer -> HB
        public decimal Origination_CLTV {get;set;} // LTV from Opportunity
        public Datetime Cut_Off_Date {get;set;}
        public decimal Total_Monthly_Debt_Payment {get;set;}
        
        //ld passbook values
        //public decimal dti {get;set;} // DTI from Opportunity
        //public string partner_id {get;set;} //the Contact Id       
        //public string mortgage_type {get;set;} // 
        //public Datetime Cut_Off_Date {get;set;}       
        //public string yodlee_report_id {get;set;} // The Yodlee report ID      
        
        
        
        public passbookJSON(){
            //hardcoded values for initial testing
            /*
            this.partner_id = '0064400000nfQQm';
            this.product_type = 'HO';
            this.mortgage_type = 'A';
            this.ltv = 67.21;
            this.fico = 712;
            this.dti = 43.12;
            this.has_co_app = false;
            this.yodlee_report_id = '4b0cb48e-f10a-46bd-4e2d-8f9cfed674b6';
			*/
        }                
    }
    
    global class passbookResponse{
        //{"id":"d1bf1580-344c-11e8-a212-f56282bb4517R","response":"Decline","yodlee_report":{"messages":["Resource not found"]},"comments":"None"
        public string id {get;set;}
        public string response {get;set;}
        public string comments {get;set;}   
        public string exception_reason {get;set;}
        public string loss_reason {get;set;}     
        public string grid_one_result {get;set;}     
        public string grid_two_result {get;set;}             
    }
    
    public static void CreateLogEntry(String request,String response,String statuscode,String status){
    	Passbook_Logs__c newLog = new Passbook_Logs__c();
        newLog.Request__c = request;
        newLog.Response__c= response;
        newLog.Status_Code__c=statuscode;
        newLog.Status__c= status;
        
        insert newLog;
    }
    
}