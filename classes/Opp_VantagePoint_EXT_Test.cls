@isTest
private class Opp_VantagePoint_EXT_Test 
{	
	@isTest static void test_method_one() 
    {
        // Data Setup
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
                                    Property_State__c = 'Vantage Point',Co_Applicant__c = con2.Id);
        insert oppty;

        Wiring_Information__c winfo = new Wiring_Information__c(Name='Test winfo',
                                                                Wire_Zipcode__c='92109',
                                                                CustomerState__c='Vantage Point',
                                                                Title_Company__c='Vantage Point');
        insert winfo;



        // Run Code
        System.Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
            Opp_VantagePoint_EXT ctrl = new Opp_VantagePoint_EXT(sc);
            ctrl.createVantagePointOrder();
            ctrl.BackToOppty();

        System.Test.stopTest();

        /*// Test Results
        List<Property_Due_Diligence_Reports__c> pddrList = 
            [
                SELECT Id 
                FROM Property_Due_Diligence_Reports__c
            ];
            
        System.assert(pddrList.size() == 0);
	    */
    }
}