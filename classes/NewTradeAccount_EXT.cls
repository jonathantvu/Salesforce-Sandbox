public class NewTradeAccount_EXT {

    public LASERCA__Trade_Accounts__c tradeAcct {get;set;}
    private final Lead theLead;
    private final Id leadId;
    
    public NewTradeAccount_EXT(ApexPages.StandardController sc){
        leadId = sc.getId();
        theLead = [SELECT Max_Credit_Score_PCR__c FROM Lead WHERE Id=:leadId ];
        tradeAcct = new LASERCA__Trade_Accounts__c();
    }
    
    public pageReference saveTradeAccount(){        
        tradeAcct.LASERCA__Personal_Credit_Report__c = theLead.Max_Credit_Score_PCR__c;
        tradeAcct.LASERCA__Account_Ownership_Type__c = tradeAcct.Account_Ownership_Type_pick__c;
        tradeAcct.LASERCA__Account_Type__c = tradeAcct.Account_Type_pick__c;
        tradeAcct.LASERCA__Credit_Loan_Type__c = tradeAcct.Credit_Loan_Type_pick__c;
        tradeAcct.LASERCA__Account_Status_Type__c = 'Open';
        
        try{
            insert tradeAcct;
        }
        catch(Exception e){
            system.debug('Error saving new Trade Account---' + e.getMessage());
            system.debug('Stack trace---' + e.getStackTraceString() );
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error saving new Trade Account:' + e.getMessage() ));
        }
        
        return new PageReference('/apex/Lead_Financial_Calculator?id=' + theLead.Id);
    }
    
    public pageReference Cancel(){
       return new PageReference('/apex/Lead_Financial_Calculator?id=' + theLead.Id);
    }
    
}