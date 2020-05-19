@isTest
private class ProjectTaskStatusUpdateTest {
    @testSetup 
    static void setup() {
        Account newAcc = new Account (Name='Test Account');
        insert newAcc;
        Id homeOwnerRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

        Opportunity newOppty = new Opportunity();
        newOppty.Name = 'Test Opportunity';
        newOppty.AccountId = newAcc.Id;
        newOppty.StageName = 'Submit to Ops';
        newOppty.CloseDate = System.today();
        newOppty.UnisonProcessor__c = UserInfo.getUserId();
        newOppty.Investment_Analyst2__c = UserInfo.getUserId();
        newOppty.Process_Program_Knowledge_Review__c = true;
        newOppty.RecordTypeId = homeOwnerRT;
        newOppty.Process_Program_Knowledge_Review__c = true;
        newOppty.Appraisal_Received__c = true;
        newOppty.Appraisal_Ordered__c = true;
        newOppty.Second_Appraisal_Ordered__c = true;
        newOppty.Second_Appraisal_Received__c = true;
        newOppty.Home_Inspection_Ordered__c = true;
        newOppty.Home_Inspection_Received__c = true;
        newOppty.Property_Report_Ordered__c = true;
        newOppty.Property_Report_Received__c = true;
        newOppty.DMA_Count__c = 3;
        newOppty.CloseDate = system.today() + 5;
        newOppty.Summary_Appraised_Value__c = 120;
        newOppty.OAV_Discount_Pct__c = 20;
        newOppty.Wire_to_Agent_Date__c = system.today();
        newOppty.Pricing_Ratio__c = 15.0;
        newOppty.Maximum_Authorized_DTI__c = 15.0;
        newOppty.Maximum_Authorized_LTV__c = 16.0;
        newOppty.Final_OAV_Calculation__c = 10.0;
        newOppty.Wire_to_Agent_Date__c = system.today();
        newOppty.Estimated_Funding_Amount__c = 110.0;
        newOppty.Maximum_Authorized_DTI__c = 15.0;
        newOppty.Maximum_Authorized_LTV__c = 16.0;
        insert newOppty;

        Success_Factor__c SF = new Success_Factor__c();
        SF.Success_Factor__c = 'LTV';
        SF.Program__c = 'HO';
        SF.Opportunity__c = newOppty.Id;
        //SF.Lead__c = newLead.Id;
        SF.Status__c = 'In Progress';
        insert SF;

        Current_Conditions__c newReq = new Current_Conditions__c();
        newReq.Opportunity__c = newOppty.Id;
        newReq.Requirement__c = '1040';
        newReq.Success_Factor__c = SF.Id;
        newReq.Status__c = 'Ready to Review';
        insert newReq;

        Project_Task__c PT = new Project_Task__c();
        PT.Name = 'TestPT2';
        PT.Code__c = 'T10156';
        PT.Completed__c = true;
        PT.Status__c = null;
        PT.Requirement__c = newReq.Id;
        PT.Opportunity__c = newOppty.Id;
        insert PT;
    }
    
    static testmethod void test() {        
        Test.startTest();
        ProjectTaskStatusUpdate t1 = new ProjectTaskStatusUpdate();
		database.executeBatch(t1);
        Test.stopTest();
    }
    
}