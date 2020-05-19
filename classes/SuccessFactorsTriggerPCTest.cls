/**
 * Created by Mind on 5/23/2019.
 */

@isTest
public class SuccessFactorsTriggerPCTest {

    @isTest
    private static void SFTest1() {

        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;
        
        Recorded_Information__c rec = new Recorded_Information__c();
        rec.Fund_Number__c = 45;
        insert rec;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'test opp';
        opp.StageName = 'Investment Due Diligence';
        opp.CloseDate = System.today();
        opp.Estimated_Funding_Amount__c = 2;
        opp.Pricing_Ratio__c = 2;
        opp.Final_OAV_Calculation__c = 4;
        opp.IA_OAV_Override__c =2; 
        opp.Recorded_Information__c = rec.Id;
        insert opp;
        
            
        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Opportunity__c = opp.Id;
        sf1.Success_Factor__c = 'Cash to Consumer';
        sf1.Status__c = 'Completed';
        sf1.Program__c = 'HO';
        insert sf1;

        sf1.Success_Factor__c = 'Credit';
        sf1.Status__c = 'In Progress';
        update sf1;

        List<Success_Factor__c> sfList = new List<Success_Factor__c>();
        sfList.add(sf1);
        SuccessFactorsTriggerPC.handleAfterInsert(sfList);

    }
}