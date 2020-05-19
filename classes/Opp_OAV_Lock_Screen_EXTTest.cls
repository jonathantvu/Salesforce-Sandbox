@isTest
public class Opp_OAV_Lock_Screen_EXTTest {

    static testMethod void OAVTest(){
             Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());
             Account acc = new Account();
             acc.Name = 'test';
             insert acc;
             Opportunity opp = new Opportunity();
             opp.Name = 'test';
             opp.AccountId = acc.Id;
             opp.StageName = 'Submit to Ops';
             opp.CloseDate = system.today();
             insert opp;
             Success_Factor__c sf = new Success_Factor__c();
             sf.Status__c = 'In Progress';             
             insert sf;
             Current_Conditions__c requirement = new Current_Conditions__c();
             requirement.Opportunity__c = opp.Id;
             requirement.Code__c = 'R1008';
             requirement.Requirement__c = 'Appraisal - 1st';
             //requirement.Success_Factor_Type__c 'OAV';
             requirement.Success_Factor__c = sf.Id;
             insert requirement;
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            Opp_OAV_Lock_Screen_EXT lockExt = new Opp_OAV_Lock_Screen_EXT(sc);
            PageReference pageRef = Page.OAVLOCKScreen_VF;
            Test.setCurrentPage(pageRef);
            lockExt.Save();
            lockExt.UpdateClass();
            lockExt.doAction();
            System.assertNotEquals(null, opp);
    }
}