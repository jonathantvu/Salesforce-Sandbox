@isTest(seeAllData=false)
public class testCMUtility {
    @testSetup
    public static void testSetup(){
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';        
        insert newAccount;
        
    }
    @isTest
    public static void testCMUtilityfunction(){
        String result='';
        Test.startTest();
			result = CMUtility.getCreatableFieldsSOQL('Account','Name = Test Account');
        	system.debug('******result*******'+result);  
        	System.assert(result!=null,'Expected query');
        	System.assert(result!='','Expected query');
        Test.stopTest();
    }
}