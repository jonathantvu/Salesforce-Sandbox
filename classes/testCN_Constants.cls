@isTest(seeAllData=false)
public class testCN_Constants {
    @isTest
    public static void testCNConstants(){
        Test.startTest();
            System.assertEquals('Loan Officer',CN_Constants.CONTACT_ROLE_LOAN_OFFICER);
        	CN_Constants.test();
        Test.stopTest();
    }
}