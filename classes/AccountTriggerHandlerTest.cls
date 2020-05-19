@isTest
private class AccountTriggerHandlerTest{

    @IsTest
    private static void testDelete(){
        Account newacc = new Account();
        newacc.Name = 'Test Account';
        newacc.Ready_for_IM__c = false;
        newacc.LOP_Lender__c = true;
        insert newacc;

        Test.setMock(HttpCalloutMock.class, new SFDC2SFDCAPIMock());
        Test.starttest();
        delete newacc;
        Test.stoptest();
    }


}