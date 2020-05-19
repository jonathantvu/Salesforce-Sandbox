/**
 * Created by cveli on 1/22/2020.
 */

@IsTest (seealldata=true) 
private class SandboxRefreshTest {
    @IsTest
    static void test1() {
        SandboxRefresh.UpdateIntegrationsEndPoints();
        /*
        contact con = new contact(firstname='John', lastname='Foo',email='jfooContact@foo.com');
        insert con;

        lead thelead = new lead(firstname='John', lastname='Foo',email='jfooLead@foo.com', company='ACME');
        //insert thelead;
/*
        LASERCA__Personal_Credit_Report__c PCR = new LASERCA__Personal_Credit_Report__c(Name = 'Test PCR');
        PCR.LASERCA__Credit_Score_Equifax__c = null;
        PCR.LASERCA__Credit_Score_Experian__c = null;
        PCR.LASERCA__Credit_Score_TransUnion__c = '705';
        //PCR.LASERCA__Co_Applicant_Credit_Score_Equifax__c  = '705';
        //PCR.LASERCA__Co_Applicant_Credit_Score_Experian__c  = '705';
        PCR.LASERCA__Co_Applicant_Credit_Score_TransUnion__c  = '705';
        PCR.LASERCA__Lead__c = thelead.Id;
        insert PCR;*/
    }
    @IsTest
    static void test2() {
        SandboxRefresh.InvalidateLeads();
    }

    @IsTest
    static void test3() {
        SandboxRefresh.InvalidateContacts();
    }

    @IsTest
    static void test4() {
        SandboxRefresh.InvalidateApplicants();
    }

    @IsTest
    static void test5() {
        SandboxRefresh.RefreshSanbox();
    }
}