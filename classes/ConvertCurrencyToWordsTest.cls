/**
 * Created by Ivan Garcia on 7/22/2019.
 */

@IsTest
public with sharing class ConvertCurrencyToWordsTest {
    @testSetup static void setup(){
        Account tmpAcc = new Account(Name = 'TestAcc');
        insert tmpAcc;
    }

    @IsTest private static void mainTest(){
        Account tmpAcc = [SELECT id FROM Account LIMIT 1];
        Opportunity tmpOpp = new Opportunity(Name = 'TestOpp', Estimated_Funding_Amount__c = 500, AccountId = tmpAcc.id, StageName = 'Ready for Ops', CloseDate = System.today());
        insert tmpOpp;
        test.startTest();
        tmpOpp.Estimated_Funding_Amount__c = 20000;
        update tmpOpp;
        Opportunity loadOpp = [SELECT id,OIP_Numbers_to_Words__c FROM Opportunity WHERE Id = :tmpOpp.id LIMIT 1];
        System.assertEquals('Twenty Thousand Dollars',loadOpp.OIP_Numbers_to_Words__c);
        test.stopTest();
    }

    @IsTest private static void SpecificOneHundred(){
        Account tmpAcc = [SELECT id FROM Account LIMIT 1];
        Opportunity tmpOpp = new Opportunity(Name = 'TestOpp', Estimated_Funding_Amount__c = 500, AccountId = tmpAcc.id, StageName = 'Ready for Ops', CloseDate = System.today());
        insert tmpOpp;
        test.startTest();
        tmpOpp.Estimated_Funding_Amount__c = 100;
        update tmpOpp;
        Opportunity loadOpp = [SELECT id,OIP_Numbers_to_Words__c FROM Opportunity WHERE Id = :tmpOpp.id LIMIT 1];
        System.assertEquals('One Hundred  Dollars',loadOpp.OIP_Numbers_to_Words__c);
        test.stopTest();
    }

    @IsTest private static void DirectClass(){
        Test.startTest();
        string returnedValue = ConvertCurrencyToWords.convert_nn(100);
        System.assertEquals('One Hundred',returnedValue);
        Test.stopTest();
    }
}