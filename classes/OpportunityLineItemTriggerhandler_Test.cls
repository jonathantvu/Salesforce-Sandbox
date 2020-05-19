@isTest
public class OpportunityLineItemTriggerhandler_Test {

    @testSetup
    static void createTestData() {

        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Account objAcc = new Account (Name='Test Account');
        insert objAcc;
        Opportunity objOpty = new Opportunity(Name = 'Test Opportunity', AccountId = objAcc.Id,
                                                            StageName = 'Property in Contract', CloseDate = System.today(),UnisonProcessor__c=u.id,Investment_Analyst2__c=u.id);
        insert objOpty;
        
        List<PriceBook2> pbLst = [select Id,Name from Pricebook2 where isStandard=true limit 1];
        
        Product2 prod = new Product2(Name= 'Transaction Fee');
        insert prod;   

        Product2 prod1 = new Product2(Name= 'Transaction Fee Waiver');
        insert prod1;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 100, IsActive = true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 50, IsActive = true);
        insert pbe1;
        
        
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=objOpty.Id, PricebookEntryId=pbe.Id,UnitPrice=100, Quantity=1);
        insert oli1;

        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=objOpty.Id, PricebookEntryId=pbe1.Id,UnitPrice=50, Quantity=1);
        insert oli2;  

    }


    @isTest static void testUpdateCustomerTransactionFee(){
        test.startTest();

        OpportunityLineItem oli = [SELECT Id from OpportunityLineItem LIMIT 1];

        //OpportunityLineItemTriggerhandler.UpdateCustomerTransactionFee(new Set<Id>{oli.Id});

        test.stopTest();
    }

    @istest static void updateOppLineItem(){
        test.startTest();
        OpportunityLineItem oli =  [SELECT Id, OpportunityId, Quantity from OpportunityLineItem LIMIT 1];
        oli.quantity = 2;
        update oli;
        test.stopTest();
    }

    @istest static void deleteOppLineItem(){
        test.startTest();
        OpportunityLineItem oli =  [SELECT Id, OpportunityId, Quantity from OpportunityLineItem LIMIT 1];
        delete oli;
        test.stopTest();
    }
    
}