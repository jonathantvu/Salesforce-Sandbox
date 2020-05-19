@isTest
public class NewTradeAccountOppTest {

    static testMethod void tradeTest(){
            Account acc = new Account();
            acc.Name = 'test acc';
            insert acc;

            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'test opp';
            opp.StageName = 'Investment Due Diligence';
            opp.CloseDate = System.today();
            opp.Estimated_Funding_Amount__c = 2;
            opp.Pricing_Ratio__c = 2;
            opp.Final_OAV_Calculation__c = 4;
            insert opp;

            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            NewTradeAccountOpp_EXT newtradeExt = new NewTradeAccountOpp_EXT(sc);
            //PageReference pageRef = Page.NewTradeAccount_VF;
            //Test.setCurrentPage(pageRef);
            newtradeExt.saveTradeAccount();
            newtradeExt.cancel();
            System.assertNotEquals(null, opp.Id);
    }
}