@isTest
public class NewTradeAccTest {

    static testMethod void tradeTest(){
             Lead l = new Lead();
             l.LastName = 'test';
             l.Company = 'test1';
             insert l;
            ApexPages.StandardController sc = new ApexPages.StandardController(l);
            NewTradeAccount_EXT newtradeExt = new NewTradeAccount_EXT(sc);
            PageReference pageRef = Page.NewTradeAccount_VF;
            Test.setCurrentPage(pageRef);
            newtradeExt.saveTradeAccount();
            newtradeExt.cancel();
            System.assertNotEquals(null, l.Id);
    }
}