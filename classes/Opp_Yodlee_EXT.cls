/**********************************************************
 * @className   : Opp_Yodlee_EXT.cls
 * @testClass   : Opp_Yodlee_EXT_TEST.cls
 * @date        : May 4, 2018
 *
 *
 **********************************************************/ 

public class Opp_Yodlee_EXT {

    private Opportunity opp;

    public Boolean displayError {get;set;}
    
    public Opp_Yodlee_EXT(ApexPages.StandardController sc){
        this.opp = (Opportunity)sc.getRecord();   
        this.displayError = false;
    }

    /******
    *
    * This method is used to send user to standard Opportunity page
    *
    ******/
    public PageReference BackToOppty(){
        return new PageReference('/' + this.opp.Id);
    }
    

    /******
    *
    * This method generate and submit a yodlee order record
    *
    ******/
    public PageReference generateYodleeOrder(){
        /* 4/2/2019 Sundar Subramaniam - Is_there_Co_App__c removed from query for Data Model Cleanup */
        Opportunity oppty = [Select Id, Applicant__r.FirstName, Applicant__r.LastName, Applicant__r.Email, 
                                Applicant__c, Co_Applicant__c, Co_Applicant__r.FirstName, Co_Applicant__r.LastName, 
                                Co_Applicant__r.Email FROM Opportunity Where Id =: this.opp.Id];
        Id yodleeOrderId = YodleeHelper.CreateOrder(oppty);
        if (yodleeOrderId != null){
            return new PageReference('/' + YodleeOrderId);
        }else{
            this.displayError = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that all required fields(First Name, Last Name, Email) are NOT NULL Or Empty.');
            ApexPages.addMessage(msg);

            return null;
        }
    }
    
}