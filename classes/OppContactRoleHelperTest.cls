/**
 *  About
 *  -----
 *  Author: ???
 *  Create date: ???
 *  
 *  Details
 *  -----
 *	Test Class For OppContactRole Helper
 * 
 *  Update History
 *  -----
 *  4/19/17 - Jason Sun (Cloud Mine Consulting)
 * 			- Made sure all Contacts have a parent account for
 * 			- Process builder dependency
 *  7/13/17 - Jason Sun (Cloud Mine Consulting) DEPRECATED
 * 
 *  Issues / TODOs
 *  ----- 
 *
**/
//@isTest
public class OppContactRoleHelperTest {
  /* 
    @testsetup
	private static void createTestData() {
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.Today().addMonths(3);
        opp.StageName = 'New';
        insert opp;
        
        Contact con1 = new Contact();
        con1.Email = 'test1@test.com';
        con1.LastName  = 'COntact1 ';
        con1.FirstName  = 'Test ';
        con1.MailingStreet = 'Street';
        con1.MailingCity = 'City';
        con1.MailingState = 'State';
        con1.MailingPostalCode = 'Code';
        con1.accountId = newAccount.Id;
        insert con1;
        
        Contact con2 = new Contact();
        con2.LastName  = 'COntact2 ';
        con2.FirstName  = 'Test ';
        con2.MailingStreet = 'Street';
        con2.MailingCity = 'City';
        con2.MailingState = 'State';
        con2.MailingPostalCode = 'Code';
        con2.accountId = newAccount.Id;        
        insert con2;
        
        Contact con3 = new Contact();
        con3.LastName  = 'COntact2 ';
        con3.FirstName  = 'Test ';
        con3.Sales_Director__c  = Userinfo.getUserId();
        con3.MailingStreet = 'Street';
        con3.MailingCity = 'City';
        con3.MailingState = 'State';
        con3.MailingPostalCode = 'Code';
        con3.accountId = newAccount.Id;        
        insert con3;
        
        //create contact roles
        OpportunityContactRole oppConRole1 = new OpportunityContactRole();
        oppConRole1.contactId = con1.id;
        oppConRole1.OpportunityId = opp.id;
        oppConRole1.Role = 'Applicant';
        insert oppConRole1;
        
        OpportunityContactRole oppConRole2 = new OpportunityContactRole();
        oppConRole2.contactId = con2.id;
        oppConRole2.OpportunityId = opp.id;
        oppConRole2.Role = 'Co-Applicant';
        insert oppConRole2;
        
        OpportunityContactRole oppConRole3 = new OpportunityContactRole();
        oppConRole3.contactId = con2.id;
        oppConRole3.OpportunityId = opp.id;
        oppConRole3.Role = CN_Constants.CONTACT_ROLE_LOAN_OFFICER;
        insert oppConRole3;
	}
    
    //Test extension
    public static testmethod void testExtension(){
        Opportunity opp = [Select Id from Opportunity LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OppContactRoleHelper extnObj = new OppContactRoleHelper(sc);
        
        PageReference pageRef = Page.OpportunityContactRoleHelper;
        Test.setCurrentPage(pageRef);
        
        extnObj.populateContactLookups();
    }
*/
}