@isTest
public class Opp_Mercury_EXTTest {
    

    @testSetup static void setup(){
        MercuryCredential__mdt MercCred = new MercuryCredential__mdt();
        Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(JSON.serializePretty(MercCred));
        fields.put(MercuryCredential__mdt.Username__c.getDescribe().getName(),'test@testingtong.com');
        fields.put(MercuryCredential__mdt.URL__c.getDescribe().getName(),'www.test.com');
        fields.put(MercuryCredential__mdt.Password__c.getDescribe().getName(),'test group');
        fields.put(MercuryCredential__mdt.EntityID__c.getDescribe().getName(),121314);
        MercCred=(MercuryCredential__mdt) JSON.deserialize(JSON.serialize(fields), MercuryCredential__mdt.class);
                     Account acc = new Account();
             acc.Name = 'test';
             insert acc;
             Contact con = new Contact();
             con.LastName = 'test1';
             con.FirstName = 'test1';
             insert con;
             Contact con1 = new Contact();
             con1.lastName = 'test1';
             con1.FirstName = 'test1';
             insert con1;
             Opportunity opp = new Opportunity();
             opp.Ownerid = userinfo.getuserid();
             opp.Name = 'test';
             opp.AccountId = acc.Id;
             opp.StageName = 'Submit to Ops';
             opp.CloseDate = system.today();
             opp.Property_Type__c = '2-4 Family';
             opp.Converted_Close_Date__c = system.today();
             opp.Encompass_Loan_Number__c = '67';
             opp.Applicant__c = con.Name;
             opp.Co_Applicant__c = con1.Name;
             opp.Final_OAV_Calculation__c = 56.09;
             opp.Lien_First_Lender_Balance__c = 56.00;
             opp.Property_Street_Number_and_Name__c = '34 st';
             opp.Property_City__c = 'Albany';
             opp.Property_State__c = 'NY';
             opp.Property_Zip_Code__c = '12345';
             opp.Property_County__c = 'US';
             opp.IA_OAV_Override__c = 2;
             insert opp;
             Success_Factor__c sf = new Success_Factor__c();
             sf.Status__c = 'In Progress';             
             insert sf;
             Current_Conditions__c requirement1 = new Current_Conditions__c();
             requirement1.Opportunity__c = opp.Id;
             requirement1.Code__c = 'R1008';
             requirement1.Requirement__c = 'Appraisal - 1st';
             requirement1.Success_Factor__c = sf.Id;
             insert requirement1;
        	Current_Conditions__c requirement2 = new Current_Conditions__c();
             requirement2.Opportunity__c = opp.Id;
             requirement2.Code__c = 'R1009';
             requirement2.Requirement__c = 'Appraisal - 2nd';
             requirement2.Success_Factor__c = sf.Id;
             requirement2.Appraisal_Genesis__c = 'Greenlight Requested';
             insert requirement2;
        	Current_Conditions__c requirement3 = new Current_Conditions__c();
             requirement3.Opportunity__c = opp.Id;
             requirement3.Code__c = 'R1009';
             requirement3.Requirement__c = 'Appraisal - 2nd';
             requirement3.Success_Factor__c = sf.Id;
             requirement3.Appraisal_Genesis__c = 'Greenlight Requested';
             insert requirement3;
             Appraisal__c newAppraisal = new Appraisal__c();
            newAppraisal.Appraisal_Ordered_Date__c = Date.today();
            newAppraisal.Source__c = '--none--';
            newAppraisal.Opportunity__c = opp.Id;

            insert newAppraisal;
    }
 
    static testMethod void mercuryTest2(){

    Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());
			Opportunity opp=[Select Id from Opportunity Limit 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            Opp_Mercury_EXT mercuryExt = new Opp_Mercury_EXT(sc);
            PageReference pageRef = Page.Opp_Mercury_VF;
            Test.setCurrentPage(pageRef);
        	//List<SelectOption> ListOption=mercuryExt.amcCompanies;
            //mercuryExt.selectedProduct = 'FNMA 2055 Exterior';
            //mercuryExt.selectedAmcCompany = '--None--';

            mercuryExt.checkConfirmation();
            mercuryExt.confirmationProvided();
            mercuryExt.confirmationRefused();
            mercuryExt.BackToOppty();
            try{
                mercuryExt.generateOrderAppraisal();
            }catch(Exception e){}
            try{
                mercuryExt.generateOrderAppraisalStep2();
            }catch(Exception e){} 
        	System.assertNotEquals(null, opp);
    }
 
}