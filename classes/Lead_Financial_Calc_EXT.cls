/**
 *  About
 *  -----
 *  Author: Cloud Mine Consulting
 *  Create date: 9/1/2017
 *
 *  Details
 *  -----
 *  Controller Extension for Lead Financial Calculator Controller
 *  Test Class: Lead_Financial_Calc_Test
 *
 *  Update History
 *  -----
 *
 *  Issues / TODOs
 *  -----
 *
**/
public class Lead_Financial_Calc_EXT {

    private final Id leadId;
    public Lead theLead {get; set;}
    public List<LASERCA__Trade_Accounts__c> tradeAccounts {get;set;}

    public Lead_Financial_Calc_EXT(ApexPages.StandardController sc){
        this.leadId = sc.getId();
        init();
    }

    private void init(){
        List<Schema.FieldSetMember> leadFields = SObjectType.Lead.FieldSets.Lead_Financial_Calc_Fields.getFields();

        String query = 'SELECT ';
        for(Schema.FieldSetMember f : leadFields) {
            query += f.getFieldPath() + ', ';
        }
        query += ' Id, Max_Credit_Score_PCR__c, Personal_Credit_Report__c FROM Lead WHERE Id=\'' + this.LeadId + '\'LIMIT 1';

        this.theLead = Database.query(query);
        tradeAccounts = new List<LASERCA__Trade_Accounts__c>();
        for(LASERCA__Trade_Accounts__c tradeAcct: [SELECT To_Be_Paid_Off__c, Name, LASERCA__Account_Balance__c, LASERCA__Credit_Loan_Type__c, LASERCA__Monthly_Payment__c,LASERCA__Account_Type__c,Unison_Calculated_Monthly_Payment__c, Exclude__c, Lien_Position__c, LASERCA__Personal_Credit_Report__r.Sum_of_Debt_Payments__c
                                                   FROM LASERCA__Trade_Accounts__c
                                                   WHERE LASERCA__Account_Status_Type__c = 'Open'
                                                   AND (LASERCA__Account_Balance__c > 0  OR LASERCA__Account_Balance__c = NULL)
                                                   //Filters originally defined by Paul Tucker
                                                   //removed on 4/2/2019 per Tutt, Director of Sales
                                                   //"Our needs are changing so it's important to get all trade lines"
                                                   /*AND (NOT (Remaining_Term__c <= 10
                                                             AND Remaining_Term__c > 0
                                                             AND Remaining_Term__c != NULL
                                                             AND LASERCA__Account_Type__c = 'Installment'
                                                             AND (NOT (LASERCA__Credit_Text__c LIKE '%lease%' AND LASERCA__Credit_Loan_Type__c = 'Automobile'))
                                                            )
                                                       )*/
                                                   AND LASERCA__Personal_Credit_Report__r.LASERCA__Lead__c =:this.leadId AND LASERCA__Personal_Credit_Report__c = :theLead.Personal_Credit_Report__c
                                                   ORDER BY LASERCA__Account_Balance__c DESC NULLS LAST]){
            tradeAccounts.add(tradeAcct);
        }
    }

    public void updateCalcs(){
        if(validateLienPositions()){
            system.savePoint sp = database.setSavepoint();
            update tradeAccounts;

            System.System.debug('*** in update CALC: ');
            theLead.First_Lender_Name__c = NULL;
            theLead.Second_Lender_Name__c = NULL;

            // Brad: Updated conditionals on "First"/"Second" to "1" and "2"
            // Uncommented assignment and NULL assigments below
            for(LASERCA__Trade_Accounts__c acct: this.tradeAccounts){
                if(acct.Lien_Position__c == '1'){
                  // system.System.debug('*** HERE FIRST: ');
                  theLead.First_Lender_Name__c = acct.Id;
                }
                if(acct.Lien_Position__c == '2'){
                  // System.System.debug('*** HERE IN 2: ');
                    theLead.Second_Lender_Name__c = acct.Id;
                }
            }

            //clear 1st & 2nd lender associated fields if they're still null by this point
            if(theLead.First_Lender_Name__c == NULL){
                theLead.Lien_First_Lender_Name__c = NULL;
                theLead.Lien_First_Lender_Balance__c = NULL;
                theLead.First_Lender_Open_Date__c = NULL;
                theLead.First_Lender_Original_Amount__c = NULL;
                theLead.Payment_Monthly_First_Mortgage__c = NULL;
            }
            if(theLead.Second_Lender_Name__c == NULL){
                theLead.Lien_Second_Lender_Name__c = NULL;
                theLead.Lien_Second_Lender_Balance__c = NULL;
                theLead.Payment_Monthly_Second_Mortgage__c = NULL;
            }

            List<LASERCA__Personal_Credit_Report__c> pcr = [SELECT Sum_of_Debt_Payments__c, Sum_of_Debt_to_be_Paid_Off__c FROM LASERCA__Personal_Credit_Report__c WHERE Id =: theLead.Personal_Credit_Report__c];
            if(pcr.size() > 0)
            {
                theLead.Sum_of_Debt_Payments__c = pcr[0].Sum_of_Debt_Payments__c;
                theLead.Sum_of_Debt_to_be_Paid_Off__c = pcr[0].Sum_of_Debt_to_be_Paid_Off__c;
            }
            try{
                update theLead;
            }
            catch(DmlException e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'An error occurred trying to save.  ' + e.getMessage()) );
                database.rollback(sp);
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You cannot assign more than one lien position of each type') );
        }
        init();
    }

    private boolean validateLienPositions(){
        integer first_count = 0;
        integer second_count = 0;
        integer third_count = 0;
        for(LASERCA__Trade_Accounts__c acct: this.tradeAccounts){
            if(acct.Lien_Position__c == 'First'){
                first_count++;
            }
            if(acct.Lien_Position__c == 'Second'){
                second_count++;
            }
            if(acct.Lien_Position__c == 'Third'){
                third_count++;
            }

            if(first_count > 1 || second_count > 1 || third_count > 1){
                return false;
            }
        }
        return true;
    }

}