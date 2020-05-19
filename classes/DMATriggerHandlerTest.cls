@isTest
public class DMATriggerHandlerTest {
    @testSetup
    private static void testData() {
        Account acc            = new Account();
        acc.Name           = 'acctest';
        insert acc;
        
        Opportunity opp        = new Opportunity();
        opp.Name           = 'opptest';
        opp.StageName      = 'final approval';
        opp.Passbook_Status__c  = 'Approve';
        opp.CloseDate      = System.today();
        opp.Estimated_Funding_Amount__c = 0.6;
        opp.Final_OAV_Calculation__c = 1;
        opp.Pricing_Ratio__c = 1;
                //opp.Account        = acc.Id;
        insert opp;


        Success_Factor__c Sft   = new Success_Factor__c();
        sft.opportunity__c      = opp.Id;
        sft.Success_Factor__c   = 'Post-Closing';
        insert sft;

       /* Current_Conditions__c req = new Current_Conditions__c();
        req.Opportunity__c = opp.Id;
        req.Requirement__c = 'Urgent Property Fix';
        req.Code__c = 'R1046';
        req.Category__c = 'Mortgage';
        req.Internal_vs_External__c = 'Internal';
        //req.Assigned_To__c = 'PS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup 
        req.Success_Factor__c = sft.Id;
        insert req;*/

        /*Project_Task__c tmpPJ = new Project_Task__c(Name='Request documentation of completion and/or payment confirmation', Requirement__c =req.id , Opportunity__c = opp.id);
        Project_Task__c tmpPJ1 = new Project_Task__c(Name='Receive documentation of completion and/or payment confirmation', Requirement__c =req.id, Opportunity__c = opp.id);
        Project_Task__c tmpPJ2 = new Project_Task__c(Name='Request contractor bid for escrow holdback', Requirement__c =req.id, Opportunity__c = opp.id);
        Project_Task__c tmpPJ3 = new Project_Task__c(Name='Upload contractor bid for escrow holdback', Requirement__c =req.id, Opportunity__c = opp.id);
        List<Project_Task__c> tmpPJList = new List<Project_Task__c>();
        tmpPJList.add(tmpPJ);
        tmpPJList.add(tmpPJ1);
        tmpPJList.add(tmpPJ2);
        tmpPJList.add(tmpPJ3);
        insert tmpPJList;*/
        
    }
    
    @isTest
    private static void dmaCreation() {
        Opportunity opp = [Select Id, (Select Id,Total_Number_of_Pages__c,Inspection_Date__c, Urgent_Fix_Type__c from DMAs__r) from Opportunity LIMIT 1];
        DMA__c dma1    = new DMA__c();
        dma1.Inspection_Date__c          = System.today();
        dma1.Total_Number_of_Pages__c    = 50;
        dma1.Opportunity__c              = opp.Id;
        
        insert dma1;
       
    }
    
    @isTest
    private static void dmaUpdate() {
        Opportunity opp = [Select Id, (Select Id,Total_Number_of_Pages__c,Inspection_Date__c, Urgent_Fix_Type__c from DMAs__r) from Opportunity LIMIT 1];
        DMA__c dma2    = new DMA__c();
        dma2.Inspection_Date__c          = System.today();
        dma2.Total_Number_of_Pages__c    = 50;
        dma2.Opportunity__c              = opp.Id;
        dma2.Urgent_Fix_Type__c          = 'Pre-Close'; 
        insert dma2;
        
        dma2.Total_Number_of_Pages__c = 51;
        dma2.Urgent_Fix_Type__c = 'Escrow Holdback';
        update dma2;
    }
    @isTest
    private static void multipleinsert(){
        Opportunity opp = [Select Id, (Select Id,Total_Number_of_Pages__c,Inspection_Date__c, Urgent_Fix_Type__c from DMAs__r) from Opportunity LIMIT 1];
        DMA__c dma1    = new DMA__c();
        dma1.Inspection_Date__c          = System.today();
        dma1.Total_Number_of_Pages__c    = 50;
        dma1.Opportunity__c              = opp.Id;
        insert dma1; 
        
        DMA__c dma2    = new DMA__c();
        dma2.Inspection_Date__c          = System.today();
        dma2.Total_Number_of_Pages__c    = 50;
        dma2.Opportunity__c              = opp.Id;
        //dma2.Urgent_Fix_Type__c        = 'Pre-Close';
        insert dma2;
    }

    @isTest
    private static void ElseLine42(){
        Opportunity opp = [Select Id, (Select Id,Total_Number_of_Pages__c,Inspection_Date__c, Urgent_Fix_Type__c from DMAs__r) from Opportunity LIMIT 1];
        DMA__c dma1    = new DMA__c();
        dma1.Inspection_Date__c          = System.today();
        dma1.Total_Number_of_Pages__c    = 50;
        dma1.Opportunity__c              = opp.Id;
        insert dma1;
        Test.setCreatedDate(dma1.id, system.today()-60);
        DMA__c dma2    = new DMA__c();
        dma2.Inspection_Date__c          = System.today();
        dma2.Total_Number_of_Pages__c    = 20;
        dma2.Opportunity__c              = opp.Id;
        insert dma2;
        Test.setCreatedDate(dma2.id, system.today()+10);
        DMA__c dma3    = new DMA__c();
        dma3.Inspection_Date__c          = System.today();
        dma3.Total_Number_of_Pages__c    = 10;
        dma3.Opportunity__c              = opp.Id;
        insert dma3;
        Test.setCreatedDate(dma3.id, system.today()+60);
        DMA__c dma4    = new DMA__c();
        dma4.Inspection_Date__c          = System.today();
        dma4.Total_Number_of_Pages__c    = 1;
        dma4.Opportunity__c              = opp.Id;
        insert dma4;
        Test.setCreatedDate(dma4.id, system.today()-10);
    }

  
    
}