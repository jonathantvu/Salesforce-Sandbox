/**********************************************************
 * @className   : PassbookRestMockImpl.cls
 * @date        : May 8, 2018
 * @description : -
 *
 *
 **********************************************************/ 

@isTest
global class PassbookRestMockImpl implements HttpCalloutMock {

	global static HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"PD_Rate": 0.037536893538494986, "Passbook_Score": "1", "Passbook_Decision": "Decline", "Decision_Explanation": "Default rate is too high due to a number of factors", "Decision_Boundary": {"40.0": {"Approval DTI Boundary": 65.0, "Escalate DTI Boundary": 65.0}, "50.0": {"Approval DTI Boundary": 55.0, "Escalate DTI Boundary": 55.0}, "55.0": {"Approval DTI Boundary": 50.0, "Escalate DTI Boundary": 55.0}, "60.0": {"Approval DTI Boundary": 40.0, "Escalate DTI Boundary": 50.0}, "65.0": {"Approval DTI Boundary": 35.0, "Escalate DTI Boundary": 50.0}, "72.5": {"Approval DTI Boundary": 25.0, "Escalate DTI Boundary": 42.5}, "75.0": {"Approval DTI Boundary": 25.0, "Escalate DTI Boundary": 35.0}, "85.0": {"Approval DTI Boundary": 0.0, "Escalate DTI Boundary": 25.0}, "90.0": {"Approval DTI Boundary": 0.0, "Escalate DTI Boundary": 0.0}}, "Error_Issues": "None"}');
        res.setStatusCode(200);
        return res;
    }

}