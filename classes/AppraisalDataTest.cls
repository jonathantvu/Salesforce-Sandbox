@isTest 
public class AppraisalDataTest {
    @testSetup
    private static void createmethod(){
        Test.setMock(HttpCalloutMock.class, new AppraisalAWSHttpCalloutMock());
        Account acc  = new Account(Name = 'acc test');
        insert acc;
        
        Opportunity opp  = new opportunity(Name = 'opp test', AccountId = acc.Id, StageName= 'Closed Won', CloseDate = System.today());
        insert opp;
        
        List<Appraisal__c> applist = new List<Appraisal__c>();
        Appraisal__c app1     = new Appraisal__c();
        app1.Appraisal_External_Id__c= '123456';
        app1.Appraisal_Ordered_Date__c=System.today();
        app1.Appraisal_Order_Number__c='1';
        //app1.Mercury_Status__c='String';/* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        app1.Appraisal_Status__c='Ordered';
        app1.MercuryTrackingId__c='123214';
        app1.Opportunity__c=opp.Id;
        //app1.Code__c='CON‌-0122';
        
        applist.add(app1);                
        
        Appraisal__c app2     = new Appraisal__c();
        app2.Appraisal_External_Id__c= '123456';
        app2.Appraisal_Ordered_Date__c=System.today();
        app2.Appraisal_Order_Number__c='2';
        //app2.Mercury_Status__c='String';/* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        app2.Appraisal_Status__c='Ordered';
        app2.MercuryTrackingId__c='123214';
        app2.Opportunity__c=opp.Id;
        //app2.Code__c='CON‌-0122';        
        
        applist.add(app2);
        
        insert applist;
    }
    
    
    
    @isTest static void testDataUpdate() {
        Test.setMock(HttpCalloutMock.class, new AppraisalAWSHttpCalloutMock()); 
        
        List<Appraisal__c> applist = [select Id  from Appraisal__c limit 2];/* 4/2/2019 Sundar Subramaniam - Removed "Mercury_Status__c" field from query for Data Model Cleanup */
        
        //applist[0].Mercury_Status__c = 'String1';/* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        //applist[1].Mercury_Status__c = 'String1';/* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        
        update applist;       
        
    }
    
    @isTest static void testDataDelete() {
        Test.setMock(HttpCalloutMock.class, new AppraisalAWSHttpCalloutMock()); 
        
        List<Appraisal__c> applist = [select Id  from Appraisal__c limit 2];  /* 4/2/2019 Sundar Subramaniam - Removed "Mercury_Status__c" field from query for Data Model Cleanup */              
        
        delete applist;
    }
}