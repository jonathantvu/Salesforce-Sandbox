/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Neeraja Cherukuri
 *  Create date:  June 06 2019
 *   Details
 *  -------------------------------------------------------------------------
 *  Have re written the Test Class to optimize Code Coverage and cleaned up unused Code.
 *  ----------------------------------------------------------------------------
 *  
 * ---------------------------------------------------------------------------
 ************************************************************************************/


@isTest
private class OpportunityUtilityClassTest
{
    @IsTest static void  sfgating()
    {
        
        Test.startTest();
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;

        Opportunity opp = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Investment Due Diligence',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = 'PUD',
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,
                                          IA_OAV_Override__c =100,Lien_First_Lender_Balance__c = 100,DMA_Count__c = 100,
                                          Title_Held__c = 'In Trust',Passbook_Status__c = 'Approved');
        insert opp;
        
        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = opp.Id;
        sf1.Success_Factor__c  = 'DTI';
        insert sf1; 
        
        sf1.Status__c = 'Completed';
        Update sf1;

        Recorded_Information__c rec= new Recorded_Information__c();
        rec.Fund_Number__c = 1;
        rec.Opportunity__c = opp.id;
        rec.Opportunity2__c = opp.id;
        insert rec;

       
        List<Opportunity> lstOpty = new List<Opportunity>();
        lstOpty.add(opp);
        
        opp.Final_Title_Held__c = 'Individually';
        opp.StageName = 'Final Approval';
        opp.Recorded_Information__c = rec.id;
        update opp;
        
        
        Test.stopTest();
        
        
       
    }

    
     @IsTest static void  sfgating_negative()
    {
        
        Test.startTest();
        Account acc = new Account(Name = 'New Account1');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstNam3e', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam4e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;

        Opportunity opp = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Investment Due Diligence',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = 'PUD',
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,
                                          IA_OAV_Override__c =100,Lien_First_Lender_Balance__c = 100,DMA_Count__c = 100,
                                          Title_Held__c = 'In Trust');
        insert opp;
        
        Success_Factor__c sf1  = new Success_Factor__c();
        sf1.Opportunity__c     = opp.Id;
        sf1.Success_Factor__c  = 'DTI';
        insert sf1; 
        
        sf1.Status__c = 'Completed';
        Update sf1;

        Recorded_Information__c rec= new Recorded_Information__c();
        rec.Fund_Number__c = 1;
        rec.Opportunity__c = opp.id;
        rec.Opportunity2__c = opp.id;
        insert rec;
       
        List<Opportunity> lstOpty = new List<Opportunity>();
        lstOpty.add(opp);
        
        opp.Final_Title_Held__c = 'Individually';        
        opp.StageName = 'Final Approval';
        opp.IA_Passbook_Override_Reasons__c = 'Decline';
        opp.IA_Passbook_Override__c  = false;
        opp.Recorded_Information__c = rec.id;
 
        update opp;
        
        
        Test.stopTest();
        
        
       
    }
 
    @isTest
	public static void Test_switchAppraisalReqs() {
		
		// Data setup
        Opportunity opp = new Opportunity();
        opp.Name = 'Test836532';
        opp.CloseDate = Date.today();
        opp.StageName = LABEL.Ready_for_Ops;
        opp.New_HomeOwner_Purchase_Date__c = Date.today().addDays(-100);
        opp.NHO_Expected_Close_Date__c = Date.today().addDays(400);
        // should set opp.Qualifies_for_New_HomeOwner_Pricing__c = false;
        insert opp;

        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Opportunity__c = opp.Id;
        sf1.Success_Factor__c = 'OAV';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        insert sf1;
        
        opp.StageName = LABEL.Investment_Due_Diligence;
        update opp;

        List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();
        reqsForInsert.add(new Current_Conditions__c(Opportunity__c = opp.Id, Code__c = 'R1008'));
        reqsForInsert.add(new Current_Conditions__c(Opportunity__c = opp.Id, Code__c = 'R1040'));
        insert reqsForInsert;
		
		// Run the code
        Test.startTest();
        
        opp.NHO_Expected_Close_Date__c = Date.today().addDays(200);
        // should set opp.Qualifies_for_New_HomeOwner_Pricing__c = true;
        update opp;

        integer reqs2 = [SELECT COUNT() FROM Current_Conditions__c WHERE Opportunity__c = :opp.Id AND Code__c = 'R1125'];
        
        opp.NHO_Expected_Close_Date__c = Date.today().addDays(400);
        // should set opp.Qualifies_for_New_HomeOwner_Pricing__c = false;
        update opp;
		
		Test.stopTest();
		
        // Verify Results
        System.assertEquals(1, reqs2);
    }
    
    @isTest
	public static void Test_waivingR1125() {
		
		// Data setup
        Opportunity opp = new Opportunity();
        opp.Name = 'Test836533';
        opp.CloseDate = Date.today();
        opp.StageName = LABEL.Ready_for_Ops;
        opp.New_HomeOwner_Purchase_Date__c = Date.today().addDays(-100);
        opp.NHO_Expected_Close_Date__c = Date.today().addDays(400);
        // should set opp.Qualifies_for_New_HomeOwner_Pricing__c = false;
        insert opp;

        Success_Factor__c sf1 = new Success_Factor__c();
        sf1.Opportunity__c = opp.Id;
        sf1.Success_Factor__c = 'OAV';
        sf1.Status__c = 'In Progress';
        sf1.Program__c = 'HO';
        insert sf1;

        List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();
        reqsForInsert.add(new Current_Conditions__c(Opportunity__c = opp.Id, Code__c = 'R1125'));
        insert reqsForInsert;
		
		// Run the code
        Test.startTest();
        
        opp.StageName = LABEL.Investment_Due_Diligence;
        update opp;
		
		Test.stopTest();
		
	}

}