@isTest(seeAllData=false)
public class testCheckbox {
    @testSetup
    public static void testSetup(){
        
        LASERCA__Personal_Credit_Report__c personalAccount = new LASERCA__Personal_Credit_Report__c();
        personalAccount.Name = 'TestingP';        
        insert personalAccount;

        List<LASERCA__Personal_Credit_Report__c> pAccount = [select id from LASERCA__Personal_Credit_Report__c where Name='TestingP'];
        
        LASERCA__Trade_Accounts__c tradeAccount = new LASERCA__Trade_Accounts__c();
        tradeAccount.Name = 'TestingTradeAccount';  
        tradeAccount.LASERCA__Personal_Credit_Report__c=pAccount[0].Id; 
        insert tradeAccount;

        
    }
    @isTest
    public static void testCheckboxfunction(){
 
        Test.startTest();
            // Create the Case Record.
            Id recordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LOET').getRecordTypeId();
            Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', RecordtypeId=recordType); 
            insert cas;
        
            CaseComment Comment = new CaseComment();
            Comment.ParentId = cas.Id;
            Comment.CommentBody = 'Some Comment';
            Comment.IsPublished = TRUE;
            
            INSERT Comment;
        
        	PageReference pageRef = Page.CaseCommentCheckbox;
             Test.setCurrentPage(pageRef);
             ApexPages.StandardController sc = new ApexPages.StandardController(cas);
            // Instantiate the Controller Class.
            checkbox cec = new checkbox(sc);

            // If needed set some of the variable values before calling certain methods.
            cec.CustomSave();
        Test.stopTest();
    }
}