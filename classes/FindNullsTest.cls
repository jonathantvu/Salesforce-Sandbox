@isTest
private class FindNullsTest {
    @isTest
    static void findNullsForLeads() {
        Lead newLead = new Lead();
        newLead.FirstName = 'John';
        newLead.LastName = 'Doe';
        newLead.Email = 'doe@example.com';
        newLead.Phone = '1234567890';
        newLead.Company = 'Test Inc';
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Test Street';
        newLead.City = 'Test City';
        newLead.State = 'Test State';
        newLead.PostalCode = 'Test ZipCode';
        newLead.Income_Monthly_Base__c = 100;

        Test.startTest();
        insert newLead;
        Test.stopTest();

    }
    
    @isTest
    static void findNullsForOpportunities() {
        Account newAcc = new Account (Name='Test Account');
        insert newAcc;

        Opportunity newOppty = new Opportunity();
        newOppty.Name = 'Test Opportunity';
        newOppty.AccountId = newAcc.Id;
        newOppty.StageName = 'Property in Contract';
        newOppty.CloseDate = System.today();
        newOppty.UnisonProcessor__c = UserInfo.getUserId();
        newOppty.Investment_Analyst2__c = UserInfo.getUserId();

        Test.startTest();
        insert newOppty;
        Test.stopTest();
    }

}