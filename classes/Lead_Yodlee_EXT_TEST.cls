/**********************************************************
 * @className   : Lead_Yodlee_EXT_TEST.cls
 * @date        : May 7, 2018
 * @description : This class provide test methods for Lead_Yodlee_EXT.cls
 *
 *
 **********************************************************/ 

@isTest 
private class Lead_Yodlee_EXT_TEST {

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
									CloseDate = Date.today().addDays(20));
		insert oppty;

		Lead lead1 = new Lead(FirstName = 'FNAme', LastName = 'LName', Email = 'fName.LName.@test.com', Co_Applicant_Last_Name__c = 'CoLName',
								Co_Applicant_First_Name__c = 'CoName', Co_Applicant_Email__c = 'coLName.Co@test.com', Is_there_Co_App__c = true,
								Company = 'ABC', Converted_Opportunity__c = oppty.Id);
		insert lead1;
		
		System.Test.startTest();

			ApexPages.StandardController sc = new ApexPages.StandardController(lead1);
			Lead_Yodlee_EXT ctrl = new Lead_Yodlee_EXT(sc);
			ctrl.BackToLead();
			ctrl.generateYodleeOrder();

		System.Test.stopTest();

		List<Yodlee_Order_Request__c> yodleeOrderRequests = [Select Id from Yodlee_Order_Request__c];

		System.assert(yodleeOrderRequests.size() > 0);
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
									CloseDate = Date.today().addDays(20));
		insert oppty;

		Lead lead1 = new Lead(FirstName = null, LastName = 'LName', Email = 'fName.LName.@test.com', Co_Applicant_Last_Name__c = 'CoLName',
								Co_Applicant_First_Name__c = 'CoName', Co_Applicant_Email__c = 'coLName.Co@test.com', Is_there_Co_App__c = false,
								Company = 'ABC', Converted_Opportunity__c = oppty.Id);
		insert lead1;
		
		System.Test.startTest();

			ApexPages.StandardController sc = new ApexPages.StandardController(lead1);
			Lead_Yodlee_EXT ctrl = new Lead_Yodlee_EXT(sc);
			ctrl.BackToLead();
			ctrl.generateYodleeOrder();

		System.Test.stopTest();

		List<Yodlee_Order_Request__c> yodleeOrderRequests = [Select Id from Yodlee_Order_Request__c];

		System.assert(yodleeOrderRequests.size() == 0);
	}
}