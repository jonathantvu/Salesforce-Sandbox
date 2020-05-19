public class NewTradeAccountOpp_EXT {

    public LASERCA__Trade_Accounts__c tradeAcct {get;set;}
    private final Opportunity theOpportunity;
    private final Id oppId;
    
    public NewTradeAccountOpp_EXT(ApexPages.StandardController sc){
        oppId = sc.getId();
        /*4/2/2019 Sundar Subramaniam - Removed Max_Credit_Score_PCR__c from query for Data Model Cleanup*/
        theOpportunity = [SELECT ID FROM Opportunity WHERE Id=:oppId ];
        tradeAcct = new LASERCA__Trade_Accounts__c();
    }
    
    public pageReference saveTradeAccount(){        
        /*4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup*/
        //tradeAcct.LASERCA__Personal_Credit_Report__c = theOpportunity.Max_Credit_Score_PCR__c;
        tradeAcct.LASERCA__Account_Type__c = tradeAcct.Account_Type_pick__c;
        tradeAcct.LASERCA__Account_Type__c = tradeAcct.Account_Type_pick__c;
        tradeAcct.LASERCA__Account_Ownership_Type__c = tradeAcct.Account_Ownership_Type_pick__c;
        tradeAcct.LASERCA__Account_Status_Type__c = 'Open';
        
        try{
            insert tradeAcct;
        }
        catch(Exception e){
            system.debug('Error saving new Trade Account---' + e.getMessage());
            system.debug('Stack trace---' + e.getStackTraceString() );
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error saving new Trade Account:' + e.getMessage() ));
        }
        
        return new PageReference('/apex/Opp_Financial_Calculator?id=' + theOpportunity.Id);
    }
    
    public pageReference Cancel(){
       return new PageReference('/apex/Opp_Financial_Calculator?id=' + theOpportunity.Id);
    }
    
}