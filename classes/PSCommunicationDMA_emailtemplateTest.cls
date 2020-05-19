@isTest
public class PSCommunicationDMA_emailtemplateTest {

    @isTest
    static void getDMAItemsTest()
    {
        Account acc          = new Account();
        acc.Name             = 'test acc';
        insert acc;

        Opportunity opp      = new Opportunity();
        opp.AccountId      = acc.Id;
        opp.Name         = 'test opp';
        opp.StageName    = 'Investment Due Diligence';
        opp.CloseDate    = System.today();
        opp.Estimated_Funding_Amount__c = 2;
        opp.Pricing_Ratio__c = 2;
        opp.Final_OAV_Calculation__c = 4;
        insert opp;

        //Begin Test
        PSCommunicationDMA_emailtemplate pdEt = new PSCommunicationDMA_emailtemplate();
        pdEt.oppId = opp.Id;
        List<DMA__c> dmas = pdEt.getDMAItems();
        System.assertNotEquals(null, dmas );

    }

}