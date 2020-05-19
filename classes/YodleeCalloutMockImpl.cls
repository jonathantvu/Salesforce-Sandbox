/**********************************************************
 * @className   : YodleeCalloutMockImpl.cls
 * @date        : May 7, 2018
 * @description : This class provide methods to replace callouts for Opp_Yodlee_EXT_TEST, etc. test methods
 *
 *
 **********************************************************/ 

@isTest
global class YodleeCalloutMockImpl implements HttpCalloutMock {

	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();

		res.setStatusCode(201);
		return res;
	}

	global static HTTPResponse AuthenticateResp(){
		// Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
		res.setBody('{'+
						'"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwdWJsaWNfaWQiOiJiMjY1MDEzZS0wNjliLTQzMDUtNTY5Ni0wODcxZj'+
								'gwMzE5YWYiLCJleHAiOjE1MjU2OTg3MDQsImlhdCI6MTUyNTY5MTUwNCwiaXNzIjoiRmluYW5jaWFsQXBwcyIsIm5iZiI6MTUy'+
								'NTY5MTUwNH0.NzVdp7KJzB6Wd0DQu8UjvUlee3ucE6ReCQN-7uJyY0s"'+
					'}');
		res.setStatusCode(200);
        return res;
	}

	global static HTTPResponse OrderStatusResp(){
		// Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
		res.setBody('{'+
						'"status": 7'+
					'}');
		res.setStatusCode(200);
        return res;
	}

	global static HTTPResponse CreateOrderResp(){
		// Create a fake response
        HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{'+
						'"public_id": "3a0ce204-ba12-477e-56f3-19621f8eb02d",'+
						'"consumer_id": "41dc127e-e7e6-4433-49a2-533976166377",'+
						'"applicant": {'+
							 '"first_name": "Test",'+
							 '"middle_name": "Q",'+
							 '"last_name": "User",'+
							 '"suffix": "Sr",'+
							 '"ssn": "xxx-xx-xxxx",'+
							 '"dob": "01-01-1980",'+
							 '"email": "testuser@test.com",'+
							 '"mobile_phone": "954-555-1234",'+
							 '"work_phone": "954-444-1234",'+
							 '"home_phone": "954-777-1234",'+
							 '"address": "1234 NW 5th Way",'+
							 '"address2": "Suite 300",'+
							 '"city": "Fort Lauderdale",'+
							 '"state": "FL",'+
							 '"zip": "33146"'+
						'},'+
						'"co_applicants": [{'+
							 '"first_name":"Susan",'+
							 '"middle_name": "L",'+
							 '"last_name": "User",'+
							 '"suffix": "Jr",'+
							 '"email": "testuser2@test.com",'+
							 '"zip": "33309",'+
							 '"ssn": "xxx-xx-xxxx",'+
							 '"employer": {'+
								 '"name": "American Employer",'+
								 '"position": "Analyst",'+
								 '"length_months": 72,'+
								 '"pay_cycle": "Weekly",'+
								 '"type": "Salary",'+
								 '"start_date": "2011-08-01T00:00:00Z",'+
								 '"end_date": "2016-08-01T00:00:00Z",'+
								 '"pay_amt_gross": 5000,'+
								 '"pay_amt_net": 4200'+
							'},'+
							'"previous_employers": [{'+
								 '"name": "General Retail",'+
								 '"position": "Associate",'+
								 '"length_months": 8,'+
								 '"pay_cycle": "Weekly",'+
								 '"type": "Part-Time",'+
								 '"start_date": "2011-01-01T00:00:00Z",'+
								 '"end_date": "2011-08-01T00:00:00Z",'+
								 '"pay_amt_gross": 1500,'+
								 '"pay_amt_net": 1125'+
							'}],'+
							 '"dob": "01-01-1980",'+
							 '"mobile_phone": "954-555-1234",'+
							 '"work_phone": "954-444-1234",'+
							 '"home_phone": "954-777-1234",'+
							 '"address": "1234 NW 5th Way",'+
							 '"address2": "Suite 300",'+
							 '"city": "Fort Lauderdale",'+
							 '"state": "FL"'+
						 '}],'+
						 '"requestor": {'+
							 '"company_id": "55555",'+
							 '"company_name": "USA Lending Company",'+
							 '"broker": "Broker",'+
							 '"processor": "John Smith",'+
							 '"phone": "305-888-8888",'+
							 '"email": "Jsmithprocessor@gmail.com",'+
							 '"reference_no": "TestUser3940101"'+
						 '},'+
						 '"status": 7,' +
						 '"webhook": "http://ok.com",'+
						 '"skip_notification": false,'+
						 '"product": {'+
							 '"code": "MAV-C-EN",'+
							 '"description": "Test"}'+
					'}');
		res.setStatusCode(200);
		return res;
	}
}