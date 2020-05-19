/************************************************************************************
 Apex Class Name     : RequirementsControllerTest
 Version             : 1.0
 Created Date        : 20th Jan 2019
 Function            : Test Class for RequirementsController class
 Author              : Neeraja Cherukuri
 
 Modification Log    :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Neeraja Cherukuri            01/20/2019                Original Version
* Jason Sun                    08/26/2019                Updated requirements name and opportunity names
*************************************************************************************
*/
@isTest
private class RequirementsControllerTest
{  
  @isTest static void test_method_one() 
    {
	//TO-DO: Find out if there is another proper HTTP mock to use.  Maybe this is calling out to Delighted?
	Test.setMock(HttpCalloutMock.class, new UnisonRequirementUpsertHttpCalloutMock());                 
    Opportunity opp = new Opportunity();
        opp.Name = 'Tiest opp 436342';
        opp.StageName = 'Introduction';
        opp.CloseDate = Date.today();
        opp.Qualifies_for_New_HomeOwner_Pricing__c = false;
        opp.Estimated_Funding_Amount__c = 1000;
                    opp.Estimated_Funding_Amount__c = 2;
            opp.Pricing_Ratio__c = 2;
            opp.Final_OAV_Calculation__c = 4;
        insert opp;
        
        /*opp.StageName = 'Investment Due Diligence';
       // opp.Loss_Type__c = 'Withdrawn';
      //  opp.Loss_Reason_Code__c   = 'Appraisal value is below customer expectation';
       // opp.Personal_Credit_Report__c = pcr.Id;
       // opp.FeeManagment__c = fmc.Id;
        update opp;
        */
        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Opportunity__c = opp.ID;
        sf1.Success_Factor__c = 'DTI';
        sf1.Program__c = 'HO';
        
        Insert sf1;
        
        /*Success_Factor__c sf2 = new Success_Factor__c();
        sf2.Opportunity__c = opp.ID;
        sf2.Success_Factor__c = 'Credit';
        Insert sf2;*/
        

        Current_Conditions__c req1 = new Current_Conditions__c();
        //req1.Success_Factor__c = sf1.Id;
        req1.Requirement__c = '1040';
        req1.Opportunity__c = opp.id;
            req1.Code__c            = 'R1111';
            req1.Category__c        = 'Credit';
        	req1.Internal_vs_External__c = 'Internal';
        try {
            Insert req1;
        }
        catch(exception e)
        {}
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req1);
        RequirementsController ext = new RequirementsController(sc);
        ext.getSuccessFactorValue();
        
       }
    @isTest static void test_method_two() 
    {
        //TO-DO: Find out if there is another proper HTTP mock to use for ConnectAPI/Chatter callouts
        Test.setMock(HttpCalloutMock.class, new UnisonRequirementUpsertHttpCalloutMock());         
        Opportunity opp = new Opportunity();
        opp.Name = 'Tiest Opp 49382';
        opp.StageName = 'Introduction';
        opp.CloseDate = Date.today();
        opp.Qualifies_for_New_HomeOwner_Pricing__c = false;
        opp.Estimated_Funding_Amount__c = 1000;
                            opp.Estimated_Funding_Amount__c = 2;
            opp.Pricing_Ratio__c = 2;
            opp.Final_OAV_Calculation__c = 4;
        insert opp;
        
       /* opp.StageName = 'Investment Due Diligence';
        update opp;*/
        
        Success_Factor__c sf1 = new Success_Factor__c();
       	//sf1.Opportunity__c = opp.ID;
        sf1.Success_Factor__c = 'OAV';
                sf1.Program__c = 'HO';
        Insert sf1;
       
        Current_Conditions__c req1 = new Current_Conditions__c();
        req1.Success_Factor__c = sf1.Id;
        req1.Requirement__c = '1065';
        req1.Opportunity__c = opp.id;
                    req1.Code__c            = 'R1111';
            req1.Category__c        = 'Credit';
        	req1.Internal_vs_External__c = 'Internal';

            Insert req1;


        ApexPages.StandardController sc = new ApexPages.StandardController(req1);
        RequirementsController ext = new RequirementsController(sc);
        ext.getSuccessFactorValue();
        
       }
}