/**********************************************************
 * @className   : YodleeHelper_TEST.cls
 * @date        : May 7, 2018
 * @description : This class provides test methods for YodleeHelper.cls and YodleeAPI.cls
 *
 *
 **********************************************************/ 

@isTest 
private class YodleeHelper_TEST {

	@isTest
	private static void testName() {

		Account acc = new Account(Name = 'New Account');
		insert acc; 

		Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
		                          AccountID = acc.Id);
		insert con;

		Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
		                          AccountID = acc.Id);
		insert con2;

		Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', 
									CloseDate = Date.today().addDays(20), Is_there_Co_App__c = true, Applicant__c = con.Id,
									Co_Applicant__c = con2.Id);
		insert oppty;

		Lead lead1 = new Lead(FirstName = 'FNAme', LastName = 'LName', Email = 'fName.LName.@test.com', Co_Applicant_Last_Name__c = 'CoLName',
								Co_Applicant_First_Name__c = 'CoName', Co_Applicant_Email__c = 'coLName.Co@test.com', Is_there_Co_App__c = true,
								Company = 'ABC', Converted_Opportunity__c = oppty.Id);
		insert lead1;

		System.test.startTest();

			YodleeHelper.authenticate();
			YodleeHelper.CreateOrder(lead1);

			YodleeAPI.CheckOrderStatusResponse sts = new YodleeAPI.CheckOrderStatusResponse();
			sts.statusCode = '200';
			sts.orderStatus = '3a0ce204-ba12-477e-56f3-19621f8eb02d';
			sts.description = 'Description test';
			sts.value = '2'; 

			YodleeAPI.Product yodleeProd = new YodleeAPI.Product();
			yodleeProd.code = 'MAV-C-EN';
			yodleeProd.description = 'Description test';
			yodleeProd.flow_type = 12;

			YodleeAPI.Requestor requestor = new YodleeAPI.Requestor();
			requestor.company_id = 'dsfsdf34rtwefgaw';
			requestor.company_name = 'ABC';
			requestor.broker = 'b1';
			requestor.reference_no = 'Sporran 0228A';
			requestor.phone = '(1)555-555-555';
			requestor.email = 'test@test.com';

			YodleeAPI.Accounts acct = new YodleeAPI.Accounts();
			acct.name = 'Billpay Account';
			acct.account_no = '5a96ebf05d017c000a391430';
			acct.account_type = 'bank';
			acct.name_on_account = 'test';
			acct.account_nickname = 'BA';

			YodleeAPI.Institutions inst = new YodleeAPI.Institutions();
			inst.name = 'Ally Bank (US)';
			inst.site_id = '1234534f5134f5d3t23f4';
			inst.routing_no = '1234';
			inst.accounts = new List<YodleeAPI.Accounts> {acct};

			YodleeAPI.Previous_employers prevEmps = new YodleeAPI.Previous_employers();
			prevEmps.name = 'ABC';
			prevEmps.position = 'tester';
			prevEmps.length_months = 5;
			prevEmps.pay_cycle = '14';
			prevEmps.type = 'IT';
			prevEmps.start_date = '2011-07-01T00:00:00Z';
			prevEmps.end_date = '2011-12-01T00:00:00Z';

			YodleeAPI.Employer empl = new YodleeAPI.Employer();
			empl.name = 'AVS';
			empl.position = 'tester';
			empl.length_months = 10;
			empl.pay_cycle = '14';
			empl.type = 'IT';
			empl.start_date = '2011-07-01T00:00:00Z';
			empl.end_date = '2011-12-01T00:00:00Z';


		System.Test.stopTest();

		System.assertEquals(YodleeHelper.yodleeAccessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwdWJsaWNfaWQiOiJiMjY1MDEzZS0wNjliLTQzMDUtNTY5Ni0wODcxZj'+
								'gwMzE5YWYiLCJleHAiOjE1MjU2OTg3MDQsImlhdCI6MTUyNTY5MTUwNCwiaXNzIjoiRmluYW5jaWFsQXBwcyIsIm5iZiI6MTUy'+
								'NTY5MTUwNH0.NzVdp7KJzB6Wd0DQu8UjvUlee3ucE6ReCQN-7uJyY0s');
		
		List<Yodlee_Order_Request__c> yodleeOrderRequests = [Select Id from Yodlee_Order_Request__c];

		System.assertEquals(yodleeOrderRequests.size() , 1);
	}

	@isTest
	private static void testName2() {
		Account acc = new Account(Name = 'New Account');
		insert acc; 

		Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
		                          AccountID = acc.Id);
		insert con;

		Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
		                          AccountID = acc.Id);
		insert con2;

		Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', 
									CloseDate = Date.today().addDays(20), Is_there_Co_App__c = true, Applicant__c = con.Id,
									Co_Applicant__c = con2.Id);
		insert oppty;

		System.test.startTest();
			
			Opportunity oppt = [Select Id, Applicant__r.FirstName, Applicant__r.LastName, Applicant__r.Email, Is_there_Co_App__c,
								Applicant__c, Co_Applicant__c, Co_Applicant__r.FirstName, Co_Applicant__r.LastName, 
								Co_Applicant__r.Email FROM Opportunity Where Id =: oppty.Id];
			YodleeHelper.CreateOrder(oppt);
			YodleeHelper.EmailReIssue('3a0ce204-ba12-477e-56f3-19621f8eb02d');
			YodleeHelper.CheckOrderStatus('3a0ce204-ba12-477e-56f3-19621f8eb02d');
			YodleeHelper.RetriveReportOrder('3a0ce204-ba12-477e-56f3-19621f8eb02d');
			YodleeHelper.RetriveOrder('3a0ce204-ba12-477e-56f3-19621f8eb02d');

		System.Test.stopTest();

		List<Yodlee_Order_Request__c> yodleeOrderRequests = [Select Id from Yodlee_Order_Request__c];

		System.assertEquals(yodleeOrderRequests.size() , 1);
	}
}