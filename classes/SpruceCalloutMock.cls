/**********************************************************
 *
 * @className   : SpruceCalloutMock.cls
 * @date        : May 15, 2018
 * @description : This class provide methods to replace callouts for SpruceHelperTest
 *
 **********************************************************/ 

@isTest
global class SpruceCalloutMock implements HttpCalloutMock
{
    global static HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();

        if(req.getEndpoint().contains('/quotes/v3/refinance'))
        {
            res = CreateRefinanceTransactionQuote();
        }
        else if(req.getEndpoint().contains('/quotes/v3/purchase'))
        {
            res = CreateRefinanceTransactionQuote();
        }
        else if(req.getEndpoint().contains('/orders/v3/refinance'))
        {
            res = CreateRefinanceTransactionTitleOrder();
        }
        else if(req.getEndpoint().contains('/orders/v3/purchase'))
        {
            res = CreateRefinanceTransactionTitleOrder();
        }
        else if(req.getEndpoint().contains('/orders/v3/testOrderInfo'))
        {
            res = CreateRefinanceTransactionTitleOrder();
        }
        else if(req.getEndpoint().contains('/public_documents/v1/'))
        {
            res = RetrieveAvailableDocumentTypesForOrder();
        }
        else if(req.getEndpoint().contains('/public_documents/v1/testOrderInfo/testDocumentType'))
        {
            res = RetrieveAvailableDocumentOfGivenType();
        }
        else if(req.getEndpoint().contains('/public_documents/v1/testOrderId/TitleSearchReport'))
        {
            res = RetrieveAvailableDocumentOfGivenType();
        }
        else if(req.getEndpoint().contains('/orders/v3/document_types'))
        {
            res = RetrieveAvailableDocumentTypesForOrder();
        }
        else if(req.getEndpoint().contains('/title_reports/v1/'))
        {
            res = GetTitleReportData();
        }
        else if(req.getEndpoint().contains('/orders/v3/testOrderInfo/closing/schedule'))
        {
            res = RetrieveClosingInfo();
        }
        else if(req.getEndpoint().contains('/orders/v3/testOrderInfo/closing'))
        {
            res = RetrieveClosingInfo();
        }
        else if(req.getEndpoint().contains('/orders/v3/testOrderInfo/documents/testDocumentType'))
        {
            res = UploadDocument();
        }
        else if(req.getEndpoint().contains('/orders/v3/testOrderInfo2/closing'))
        {
            res = RetrieveClosingInfoError();
        }
        else if(req.getEndpoint().contains('/PlaceAppraisalOrderEx'))
        {
        res = PlaceAppraisalOrderEx();
        }

        else if(req.getEndpoint().contains('/GetCurrentStatusXSiteClientEx'))
        {
            res = GetCurrentStatusXSiteClientEx();
        }

        else if(req.getEndpoint().contains('/GetVMPOrderFormFields'))
        {
            res = GetTypesOfAppraisal();
        }
        
        else if(req.getEndpoint().contains('/Login'))
        {
            res = GetLogin();
        }

        return res;
    }

    global static HttpResponse RetrieveClosingInfoError()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();  
        res.setStatusCode(404);
        return res;
    }
    global static HttpResponse GetLogin()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><root xmlns="http://alamode.com/"><to>Tove</to><bResult>true</bResult><IsAuthenticated>true</IsAuthenticated><body><bResult>true</bResult><SessionKey>SessionKeyweqeqwe</SessionKey></body></root>');
        return res;
    }

    global static HttpResponse PlaceAppraisalOrderEx()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><root xmlns="http://alamode.com/"><to>Tove</to><bResult>true</bResult><TrackingID>Reminder</TrackingID><body><bResult>true</bResult><TrackingID>Reminder</TrackingID></body></root>');
        return res;
    }

    global static HttpResponse GetTypesOfAppraisal()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><root><FIELD><TYPE_OF_APPRAISAL>FHA Appraisal (FNMA 1004)</TYPE_OF_APPRAISAL><VALUES>Reminder</VALUES></FIELD><FIELD><Name>TYPE_OF_APPRAISAL</Name><VALUES>Reminder</VALUES></FIELD></root>');
        return res;
    }



    global static HttpResponse GetCurrentStatusXSiteClientEx()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<root xmlns="http://alamode.com/"><to>Tove</to><Success>true</Success><TrackingID>Reminder</TrackingID><body><Success>true</Success><StatusName>Reminder</StatusName></body></root>');
        return res;
    }

    global static HttpResponse UploadDocument()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();  
        res.setStatusCode(200);
        return res;
    }

    global static HttpResponse RetrieveAvailableDocumentOfGivenType()
    {
        Blob blobBody = Blob.valueOf('testBobBody');

        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setBodyAsBlob(blobBody);
        res.setStatusCode(200);
        return res;
    }

    global static HttpResponse CreateRefinanceTransactionQuote()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ '+
                        '"fees": '+
                        '[' +
                            '{' +
                                '"type": "title",' +
                                '"label": "Lender Policy",' +
                                '"amount": 1500.75,' +
                                '"section": "C"' +
                            '}' +
                        '],' +
                        '"Settlement_Agent":' +
                        '{'+
                            '"name": "The Settlement Agent",' +
                            '"contact": {"first_name" : "Marcia Smith", "last_name" : "test", "formatted_contact" : "test"},' +
                            '"address": {"street_address" : "test", "unit" : "test", "city" : "testCity", "state" : "test", "zip_code" : "test", "formatted_address" : "test"},' +
                            '"email": "settlement-agent@example.com",' +
                            '"phone_number": "(000) 000-0000",' +
                            '"state_license_id": "TLA-1234567",' +
                            '"contact_license_id": "TLA-7654321"' +
                        '}' +   
                    '}');
        res.setStatusCode(200);
        return res;
    }

    global static HttpResponse CreateRefinanceTransactionTitleOrder()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ '+
                        '"id": "114350000000",' +
                        '"order_status": "new",' +
                        '"fees": '+
                        '[' +
                            '{' +
                                '"type": "title",' +
                                '"label": "Lenders Policy",' +
                                '"amount": 1500.75,' +
                                '"section": "C"' +
                            '}' +
                        '],' +
                        '"settlement_agent":' +
                        '{'+
                            '"name": "The Settlement Agent",' +
                            '"contact": {"first_name" : "Marcia Smith", "last_name" : "test", "formatted_contact" : "test"},' +
                            '"address": {"street_address" : "123 Main St, Suite 001, Anywhere, NY 10023", "unit" : "test", "city" : "testCity", "state" : "test", "zip_code" : "test", "formatted_address" : "test"},' +
                            '"email": "settlement-agent@example.com",' +
                            '"phone_number": "(000) 000-0000",' +
                            '"license_info": {"state_license_id" : "TLA-1234567", "contact_license_id" : "test"},' +
                            '"wiring_instructions": ' +
                            '{' +
                                '"account_number": "1234567890",' +
                                '"routing_number": "0110000010",' +
                                '"obi": "114350000000"' +
                            '}' +
                        '}' +   
                    '}');
        res.setStatusCode(200);
        return res;
    }

    global static HttpResponse RetrieveAvailableDocumentTypesForOrder()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[' +
                        '"PreliminaryClosingDisclosure",' +
                        '"WiringInstructions",' +
                        '"CPL"' +
                    ']');
        res.setStatusCode(200);
        return res;
    }

    global static HttpResponse GetTitleReportData()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
                        '"effective_date": "2017-07-21",' +
                        '"vesting_info": "Betty Smith, a married woman as her sole and separate property",' +
                        '"legal_description": "Lots 6, 7",' +
                        '"apn": "230-110-023",' +
                        '"num_of_open_mortgages": 0,' +
                        '"num_of_bankruptcies": 0,' +
                        '"num_of_judgements": 1,' +
                        '"num_of_other_liens": 1' +
                    '}');
        res.setStatusCode(200);
        return res;
    }

    global static HttpResponse RetrieveClosingInfo()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                        '"closing_date": "2017-07-21",' +
                        '"closing_time": "3:00 AM",' +
                        '"closing_location": '+
                        '{' +
                            '"street_address": "123 Main St.",' +
                            '"unit": "Ste. 001",' +
                            '"city": "Anywhere",' +
                            '"state": "NY",' +
                            '"zip_code": "10004"' +
                        '},' +
                        '"notary": '+
                        '{' +
                            '"name": "Kate McKinnon",' +
                            '"phone_number": "(000) 000-0000"' +
                        '}' +
                    '}');
        res.setStatusCode(200);
        return res;
    }
}