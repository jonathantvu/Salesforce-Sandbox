@isTest
global class VantagePointCalloutMock implements HttpCalloutMock 
{
    global static HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();

        if(req.getEndpoint().contains('/api/orders'))
        {
            res = PlaceOrder();
        }

        return res;
    }

    global static HttpResponse PlaceOrder()
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'string');

        String bodyString = '{"FileID" : 12, "FileNumber" : "testFileNumber", ' +
        '"ResponseStatus":' +
       '{' +
            '"ErrorCode":"NotEmpty",' +
            '"Message":"\'County\' should not be empty.",' +
            '"Errors":' +
            '[' +
                '{' +
                    '"ErrorCode":"NotEmpty",' +
                    '"FieldName":"Properties[0].County",' +
                    '"Message":"\'County\' should not be empty."' +
                '},' +
                '{' +
                    '"ErrorCode":"NotEqual",' +
                    '"FieldName":"Sellers[0].MaritalStatus",' +
                    '"Message":"A secondary contact is required when Marital Status is Married"' +
                '},' +
                '{' +
                    '"ErrorCode":"NotNull",' +
                    '"FieldName":"Properties[0].County",' +
                    '"Message":"\'County\' must not be empty."' +
                '},' +
                '{' +
                    '"ErrorCode":"Length",' +
                    '"FieldName":"Properties[0].County",' +
                    '"Message":"\'County\' must be between 1 and 40 characters. You entered 0 characters."' +
                '}' +
            ']' +
        '}}';

        res.setBody(bodyString);
        res.setStatusCode(200);
        return res;
    }
}