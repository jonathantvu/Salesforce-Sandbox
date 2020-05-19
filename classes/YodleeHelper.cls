/**********************************************************
 * @className   : YodleeHelper.cls
 * @testClass   : YodleeHelper_TEST.cls
 * @author      : Omnivo Digital (www.omnivodigital.com)
 * @date        : May 7, 2018
 *
 *
 **********************************************************/ 

public with sharing class YodleeHelper 
{
    public static String yodleeAccessToken {get; set;}

    public static void authenticate()
    {
        yodleeAccessToken = YodleeAPI.authenticate();
    }

    public static Id CreateOrder(Opportunity opp)
    {
        if(yodleeAccessToken == null)
        {
            yodleeAccessToken = YodleeAPI.authenticate();
        }

        YodleeAPI.CreateOrderCallServerRequest request = new YodleeAPI.CreateOrderCallServerRequest();
        request.applicant.first_name = opp.Applicant__r.FirstName;
        request.applicant.last_name = opp.Applicant__r.LastName;
        request.applicant.email = opp.Applicant__r.Email;
        request.product = YodleeAPI.SETTINGS.Product_Code__c; //'1003-o-en' is old value, '1003-uni-o-en' is new value;

        /* 4/2/2019 Sundar Subramaniam - Condition Commented for Data Model Cleanup */
        //if(opp.Is_there_Co_App__c == true)
        {
            YodleeAPI.Co_applicants newCoApplicant = new YodleeAPI.Co_applicants();
            newCoApplicant.first_name = opp.Co_Applicant__r.FirstName;
            newCoApplicant.last_name = opp.Co_Applicant__r.LastName;
            newCoApplicant.email = opp.Co_Applicant__r.Email;

            request.co_applicants.add(newCoApplicant); // add co-applicants
        }

        if (isRequestValid(request)){
            YodleeAPI.CreateOrderResponseWrapper response = YodleeAPI.CreateOrder(request);

            system.debug(response);

            Yodlee_Order_Request__c newYodleeOrderRequest = new Yodlee_Order_Request__c();
            newYodleeOrderRequest.Name = 'Request on ' + Datetime.now();
            newYodleeOrderRequest.Opportunity__c = opp.Id;
            newYodleeOrderRequest.Yodlee_Public_Id__c = response.serverResponse.public_id;
            newYodleeOrderRequest.Error_Message__c = response.errorMessage;
            insert newYodleeOrderRequest;

            return newYodleeOrderRequest.Id;
        }

        return null;
    }

    public static Id CreateOrder(Lead leadRecord)
    {
        if(yodleeAccessToken == null)
        {
            yodleeAccessToken = YodleeAPI.authenticate();
        }

        YodleeAPI.CreateOrderCallServerRequest request = new YodleeAPI.CreateOrderCallServerRequest();
        request.applicant.first_name = leadRecord.FirstName;
        request.applicant.last_name = leadRecord.LastName;
        request.applicant.email = leadRecord.Email;
        request.product = YodleeAPI.SETTINGS.Product_Code__c; //'1003-o-en' is old value, '1003-uni-o-en' is new value;
        
        if(leadRecord.Is_there_Co_App__c)
        {
            YodleeAPI.Co_applicants newCoApplicant = new YodleeAPI.Co_applicants();
            newCoApplicant.first_name = leadRecord.Co_Applicant_First_Name__c;
            newCoApplicant.last_name = leadRecord.Co_Applicant_Last_Name__c;
            newCoApplicant.email = leadRecord.Co_Applicant_Email__c;

            request.co_applicants.add(newCoApplicant);// add co-applicants
        }

        if (isRequestValid(request)){
            YodleeAPI.CreateOrderResponseWrapper response = YodleeAPI.CreateOrder(request);
            system.debug(response);

            Yodlee_Order_Request__c newYodleeOrderRequest = new Yodlee_Order_Request__c();
            newYodleeOrderRequest.Name = 'Request on ' + Datetime.now();
            newYodleeOrderRequest.Lead__c = leadRecord.Id;
            newYodleeOrderRequest.Opportunity__c = leadRecord.Converted_Opportunity__c;
            newYodleeOrderRequest.Yodlee_Public_Id__c = response.serverResponse.public_id;
            newYodleeOrderRequest.Error_Message__c = response.errorMessage;
            insert newYodleeOrderRequest;

            return newYodleeOrderRequest.Id;
        }

        return null;
    }


    /******
    *
    * This method check if a request contains all necesarry informations before submite it.
    *
    ******/
    public static Boolean isRequestValid(YodleeAPI.CreateOrderCallServerRequest request)
    {
        System.debug(' ****YodleeHelper --- isRequestValid(): ');
        System.debug(' ****request: ' + request);
        Boolean isOK = false;
        if (String.isNotBlank(request.applicant.first_name) && String.isNotBlank(request.applicant.last_name)
            && String.isNotBlank(request.applicant.email)){
                isOK = true;
        }

        return isOK;
    }

    public static YodleeAPI.EmailReIssueResponse EmailReIssue(String orderId)
    {
        if(yodleeAccessToken == null)
        {
            yodleeAccessToken = YodleeAPI.authenticate();
        }

        return YodleeAPI.EmailReIssue(orderId);
    }

    public static YodleeAPI.CheckOrderStatusResponse CheckOrderStatus(String orderId)
    {
        if(yodleeAccessToken == null)
        {
            yodleeAccessToken = YodleeAPI.authenticate();
        }

        YodleeAPI.CheckOrderStatusResponse response = YodleeAPI.CheckOrderStatus(orderId, true);
        System.debug('*** YodleeHelper -- CheckOrderStatus:');
        System.debug('***response: ' + response);

        return response;
    }

    public static YodleeAPI.CreateOrderResponseWrapper RetriveOrder(String orderId)
    {
        if(yodleeAccessToken == null)
        {
            yodleeAccessToken = YodleeAPI.authenticate();
        }

        YodleeAPI.CreateOrderResponseWrapper response = YodleeAPI.RetriveOrder(orderId);
        system.debug(response);

        return response;
    }

    public static Blob RetriveReportOrder(String orderId){
        Blob retrivedPdf;

        if(yodleeAccessToken == null)
        {
            yodleeAccessToken = YodleeAPI.authenticate();
        }

        //check order status
        YodleeAPI.CheckOrderStatusResponse orderRespSts = YodleeAPI.CheckOrderStatus(orderId, false);
        System.debug('***orderRespSts: ' + orderRespSts);

        if (orderRespSts != null && orderRespSts.value == '7'){ //The order must be submitted and COMPLETED - 7
            retrivedPdf = YodleeAPI.RetriveReport(orderId);
        }

        return retrivedPdf;
    }
}