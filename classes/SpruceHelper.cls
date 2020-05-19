/**********************************************************
*
* @className   : SpruceHelper.cls
* @testClass   : SpruceHelperTest.cls
* @author      : Omnivo Digital (www.omnivodigital.com)
* @date        : May 15, 2018
* @Description :
*
**********************************************************/ 

public with sharing class SpruceHelper 
{
    public static void CreateRefinanceTransactionQuote(Opportunity opp)
    { 
        SpruceAPI.CreateRefinanceTransactionQuoteRequest request = new SpruceAPI.CreateRefinanceTransactionQuoteRequest();
        /* 4/2/2019 Sundar Subramaniam - Replaced Proposed_Total_Mortgage_Debt__c with Post_Close_Mortgage_Debt__c for Data Model Cleanup */
        request.loan_amount = opp.Post_Close_Mortgage_Debt__c;
        request.estimated_property_value = opp.Home_Value__c;
        request.property_address.street_address = opp.Property_Street_Number_and_Name__c;
        //request.property_address.unit = 'unit';
        request.property_address.city = opp.Property_City__c;
        request.property_address.state = opp.Property_State__c;
        request.property_address.zip_code = opp.Property_Zip_Code__c;
        
        SpruceAPI.CreateRefinanceTransactionQuoteResponse response = SpruceAPI.CreateRefinanceTransactionQuote(request);
    }
    
    public static void CreatePurchaseTransactionQuote()
    {
        SpruceAPI.CreatePurchaseTransactionQuoteRequest request = new SpruceAPI.CreatePurchaseTransactionQuoteRequest();
        request.loan_amount = 100000;
        request.purchase_price = 150000;
        request.buyer_pays_transfer_taxes = false;
        request.property_address.street_address = '123 Main St.';
        request.property_address.unit = 'Ste. 001';
        request.property_address.city = 'New York';
        request.property_address.state = 'NY';
        request.property_address.zip_code = '10004';
        
        SpruceAPI.CreateRefinanceTransactionQuoteResponse response = SpruceAPI.CreatePurchaseTransactionQuote(request);
    }
    
    public static SpruceAPI.CreateRefinanceTransactionTitleOrderResponse CreateRefinanceTransactionTitleOrder(Opportunity opp)
    {
        SpruceAPI.CreateRefinanceTransactionTitleOrderRequest request = new SpruceAPI.CreateRefinanceTransactionTitleOrderRequest();
        request.loan_amount = opp.Post_Close_Mortgage_Debt__c;
        request.loan_id = opp.Encompass_Loan_Number__c;
        request.estimated_property_value = opp.Home_Value__c;
        request.property_address.street_address = opp.Property_Street_Number_and_Name__c;
        //request.property_address.unit = 'unit';
        request.property_address.city = opp.Property_City__c;
        request.property_address.state = opp.Property_State__c;
        request.property_address.zip_code = opp.Property_Zip_Code__c;
        
        SpruceAPI.Borrowers borrower = new SpruceAPI.Borrowers();
        borrower.email = opp.Applicant__r.Email;
        borrower.first_name = opp.Applicant__r.FirstName;
        borrower.last_name = opp.Applicant__r.LastName;
        //borrower.middle_name = 'testMiddleName';
        borrower.phone_number = opp.Applicant__r.Mercury_Phone__c;
        //borrower.ssn = '0004';
        
        request.borrowers.add(borrower);
        
        // If Is_there_Co_App__c == true, then add another borrower to the array
        /* 4/2/2019 Sundar Subramaniam - Condition Commented for Data Model Cleanup */
        if(opp.Is_there_Co_App__c == true)
        {
            SpruceAPI.Borrowers coAppBorrower = new SpruceAPI.Borrowers();
            coAppBorrower.email = opp.Co_Applicant__r.Email;
            coAppBorrower.first_name = opp.Co_Applicant__r.FirstName;
            coAppBorrower.last_name = opp.Co_Applicant__r.LastName;
            //coAppBorrower.middle_name = 'testMiddleName';
            coAppBorrower.phone_number = opp.Co_Applicant__r.Mercury_Phone__c;
            //coAppBorrower.ssn = '0004';
            
            request.borrowers.add(coAppBorrower);
        }
        
        // CK - As per BUS-155111237 , Adding TS information on order so spruce can email notifications to TS's
        
        SpruceAPI.Parties contact = new SpruceAPI.Parties();
         if(!System.Test.isRunningTest()){	
        	contact.purpose = 'order_contact';
        	contact.lender_user_id = opp.UnisonProcessor__r.Spruce_Portal_User_Id__c;
            request.parties.add(contact);
        }
        
        
        SpruceAPI.CreateRefinanceTransactionTitleOrderResponse response = SpruceAPI.CreateRefinanceTransactionTitleOrder(request);
        
        return response;
        //Note from Spruce
        //Need to grab 'TITLE - ATTORNEY' Fee item in addition to 'TITLE - CLOSING' if present, add together and 
        //merge into the settlement_closing_escrow_fee__c        
    }
    
    public static void CreatePurchaseMortgageTransactionTitleOrder()
    {
        SpruceAPI.CreatePurchaseMortgageTransactionTitleOrderRequest request = new SpruceAPI.CreatePurchaseMortgageTransactionTitleOrderRequest();
        request.loan_amount = 100000;
        request.purchase_price = 150000;
        request.property_address.street_address = '123 Main St.';
        request.property_address.unit = 'Ste. 001';
        request.property_address.city = 'New York';
        request.property_address.state = 'NY';
        request.property_address.zip_code = '10004';
        
        SpruceAPI.Borrowers borrower = new SpruceAPI.Borrowers();
        borrower.email = 'test@test.com';
        borrower.first_name = 'testFirstName';
        borrower.last_name = 'testLastName';
        borrower.middle_name = 'testMiddleName';
        borrower.phone_number = '0000 1111 2222';
        borrower.ssn = '0004';
        
        request.borrowers.add(borrower);
        
        SpruceAPI.CreateRefinanceTransactionTitleOrderResponse response = SpruceAPI.CreatePurchaseMortgageTransactionTitleOrder(request);
    }
    
    public static SpruceAPI.CreateRefinanceTransactionTitleOrderResponse RetrieveOrderInfo(String orderId)
    {
        SpruceAPI.CreateRefinanceTransactionTitleOrderResponse response = SpruceAPI.RetrieveOrderInfo(orderId);
        
        return response;
    }
    
    public static SpruceAPI.RetrieveAvailableDocumentTypesForOrderResponse RetrieveAvailableDocumentTypesForOrder(String orderId)
    {
        SpruceAPI.RetrieveAvailableDocumentTypesForOrderResponse response = SpruceAPI.RetrieveAvailableDocumentTypesForOrder(orderId);
        
        return response;
    }
    
    public static SpruceAPI.RetrieveAvailableDocumentOfGivenTypeResponse RetrieveAvailableDocumentOfGivenType(String orderId, String documentType)
    {
        SpruceAPI.RetrieveAvailableDocumentOfGivenTypeResponse response = SpruceAPI.RetrieveAvailableDocumentOfGivenType(orderId, documentType);
        
        return response;
    }
    
    public static void UploadDocument(String orderId, String documentType, Attachment file)
    {
        SpruceAPI.RetrieveAvailableDocumentOfGivenTypeResponse response = SpruceAPI.UploadDocument(orderId, documentType, file);
    }
    
    public static void RetrieveDocumentTypesThatCanBeUploaded()
    {
        SpruceAPI.RetrieveAvailableDocumentTypesForOrderResponse response = SpruceAPI.RetrieveDocumentTypesThatCanBeUploaded();
    }
    
    public static SpruceAPI.GetTitleReportDataResponse GetTitleReportData(String orderId)
    {
        SpruceAPI.GetTitleReportDataResponse response = SpruceAPI.GetTitleReportData(orderId);
        
        return response;
    }
    
    public static void SubmitSchedulingRequestForLoanClosing(String orderId)
    {
        SpruceAPI.SubmitSchedulingRequestForLoanClosingRequest request = new SpruceAPI.SubmitSchedulingRequestForLoanClosingRequest();
        request.closing_date = '2017-07-21';
        request.closing_time = '3:00 AM';
        request.closing_location.street_address = '123 Main St.';
        request.closing_location.unit = 'Ste. 001';
        request.closing_location.city = 'New York';
        request.closing_location.state = 'NY';
        request.closing_location.zip_code = '10004';
        
        SpruceAPI.SubmitSchedulingRequestForLoanClosingResponse response = SpruceAPI.SubmitSchedulingRequestForLoanClosing(request, orderId);
    }
    
    public static void RetrieveClosingInfo(String orderId)
    {
        SpruceAPI.RetrieveClosingInfoResponse response = SpruceAPI.RetrieveClosingInfo(orderId);
    }
}