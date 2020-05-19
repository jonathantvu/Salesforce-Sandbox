public class TradeAccountTriggerHandler{
    // After an insert, be sure to update the Opportunity formulas, if Opportunity present
    public static void handleAfterInsert(List<LASERCA__Trade_Accounts__c> newlist) {
        set<Id> trdaccsids = new set<Id>();
        set<Id> trdaccspcrids = new set<Id>();
        set<Id> trdaccsifnull = new set<Id>();
        for(LASERCA__Trade_Accounts__c newtrdacc : newlist){
            System.debug('**** inside after insert***');
            trdaccsifnull.add(newtrdacc.Id);
            if(newtrdacc.LASERCA__Personal_Credit_Report__c != Null) {
                trdaccspcrids.add(newtrdacc.LASERCA__Personal_Credit_Report__c);
            }
        }
        if(trdaccspcrids.size() > 0){
            CountofTrdAccPay(trdaccspcrids);
        }
        LoanTypenull(trdaccsifnull);

        //if(!newlist.isEmpty()) {
        //    update newlist;
        //}

        FindTradeAccountChanges(newList);
    }

    // After an insert, be sure to update the Opportunity formulas, if Opportunity present
    public static void handleAfterUpdate(List<LASERCA__Trade_Accounts__c> newlist, Map<Id,LASERCA__Trade_Accounts__c> oldmap){
        set<Id> trdaccspcrids = new set<Id>();
        set<Id> trdaccsoppids = new set<Id>();

        for(LASERCA__Trade_Accounts__c newtrdacc : newlist){
            System.debug('*** inside after update****');
            if(newtrdacc.LASERCA__Personal_Credit_Report__c != Null){
                trdaccspcrids.add(newtrdacc.LASERCA__Personal_Credit_Report__c);
            }
        }

        if(trdaccspcrids.size() > 0){
            CountofTrdAccPay(trdaccspcrids);
        }

        FindTradeAccountChanges(newList);
        CopyChanges(newlist, oldMap);
    }
    public static void LoanTypenull(set<Id> tda_ids) {
        List<LASERCA__Trade_Accounts__c>traddeacc = [SELECT Credit_Loan_Type_pick__c,LASERCA__Credit_Loan_Type__c from LASERCA__Trade_Accounts__c WHERE Id IN: tda_ids];

        for(LASERCA__Trade_Accounts__c ta: traddeacc) {
            if (string.isEmpty(ta.Credit_Loan_Type_pick__c))
                ta.Credit_Loan_Type_pick__c = ta.LASERCA__Credit_Loan_Type__c;
        }
        update traddeacc;
    }

    // Handler function sets the amount to be paid off value, if marked to be paid off
    public static void handleBeforeInsert(List<LASERCA__Trade_Accounts__c> newlist){
        if(TriggrUtility.RunOnce){
            List<LASERCA__Trade_Accounts__c> finallist = new List<LASERCA__Trade_Accounts__c>();

            // BAL: Set the field values when To Pay Off is marked True, based on the Trade Account Type
            // If it is Mortgage or Other Lien:
            //  If the Target % home value is set, compute the amount to pay off
            // Amount to Pay off is set to outstanding balance by default for all Trade Account types
            for(LASERCA__Trade_Accounts__c newtrdacc : newlist){
                Boolean sub_lien_bool = is_subject_lien(newtrdacc.Credit_Loan_Type_pick__c); // temp variable for if this is a subject property lien

                // If it is marked to be paid off
                if (newtrdacc.To_Be_Paid_Off__c == true) {

                    // If it is a Mortgage or Other Lien
                    if(sub_lien_bool) {

                        // 2019-05-20: set to default to go-live. Will be a function of target % home value
                        // Handling setting this on the front end for now
                        // newtrdacc.Amount_To_Pay_Off2__c = 0;

                        // Future:
                        /*
                        Double curr_val_pct = newtrdacc.Current_Pct_Value_Of_Home__c;
                        Double tgt_val_pct = newtrdacc.Target_Pct_Value_Of_Home__c;
                        Double final_oav = newtrdacc.Opportunity__r.Final_OAV_Calculation__c;

                        newtrdacc.Amount_To_Pay_Off2__c = lien_payoff_amount(curr_val_pct, tgt_val_pct, final_oav);
                        */
                        // newtrdacc.Amount_To_Pay_Off2__c=(newtrdacc.Current_Pct_Value_Of_Home__c - newtrdacc.Target_Pct_Value_Of_Home__c) * newtrdacc.Opportunity__r.Final_OAV_Calculation__c;
                    } else { // All other trade line types
                        newtrdacc.Amount_To_Pay_Off2__c = newtrdacc.LASERCA__Account_Balance__c;
                    }
                } else { // If not marked to pay off, set payoff amount to zero
                    newtrdacc.Amount_To_Pay_Off2__c = 0;
                }
                TriggrUtility.RunOnce=false;
            }
        }
        //SetTheRightPCROnNewTradeAccounts(newList);
    }

    public static void handleBeforeUpdate(List<LASERCA__Trade_Accounts__c> newlist, Map<Id,LASERCA__Trade_Accounts__c> oldmap){
        if(TriggrUtility.RunOnce){
            // Loop through the trade accounts
            for(LASERCA__Trade_Accounts__c newtrdacc : newlist){
                Boolean tmp_payoff_new_flag = newtrdacc.To_Be_Paid_Off__c; // New "to be paid off" flag
                Boolean tmp_payoff_old_flag = oldmap.get(newtrdacc.Id).To_Be_Paid_Off__c; // New "to be paid off" flag
                Boolean sub_lien_bool = is_subject_lien(newtrdacc.Credit_Loan_Type_pick__c); // temp variable for if this is a subject property lien

                // If we are updating the payoff flag to false FROM true, we clear the amount to payoff
                if (tmp_payoff_new_flag == false && tmp_payoff_old_flag == true){
                    newtrdacc.Amount_To_Pay_Off2__c=0;
                }

                // If we are marking a trade account to be paid off
                if (tmp_payoff_new_flag == true && tmp_payoff_old_flag == false) {

                    // If it is not a subject-property lien, set value to the outstanding balance
                    if (!sub_lien_bool) {
                        if(newtrdacc.Amount_To_Pay_Off2__c == 0) {
                            newtrdacc.Amount_To_Pay_Off2__c = newtrdacc.LASERCA__Account_Balance__c;
                        }
                    }

                    // If it is a subject-property lie, set according to specified target OAV pct (future)
                    // For now we will set to zero
                    if (sub_lien_bool) {
                        // 2018-06-06: comment out now, handled via the front end.
                        // try {
                        //     newtrdacc.Amount_To_Pay_Off2__c=(newtrdacc.Current_Pct_Value_Of_Home__c - newtrdacc.Target_Pct_Value_Of_Home__c) * newtrdacc.LASERCA__Personal_Credit_Report__r.Opportunity__r.Final_OAV_Calculation__c;
                        //     // newtrdacc.Amount_To_Pay_Off2__c=(newtrdacc.Current_Pct_Value_Of_Home__c - newtrdacc.Target_Pct_Value_Of_Home__c) * 1000000;
                        // } catch (Exception e) {
                        //     newtrdacc.Amount_To_Pay_Off2__c = 0;
                        // }
                    }
                }
            }
            TriggrUtility.RunOnce=false;
        }
    }

    // Update formulas based on changes to Trade Accounts
    public static void CountofTrdAccPay(set<Id> pcr_ids) {
        ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ID IDHomeBuyerCanada = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer Canada').getRecordTypeId();
        ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

        // Query the Trade Accounts based on the PCR Ids and the appropriate conditions
        List<LASERCA__Trade_Accounts__c> newtrdacclist = [
                SELECT  Id,
                        LASERCA__Personal_Credit_Report__c,
                        LASERCA__Personal_Credit_Report__r.Opportunity__c,
                        LASERCA__Personal_Credit_Report__r.Opportunity__r.Personal_Credit_Report__c,
                        To_Be_Paid_Off__c,
                        LASERCA__Monthly_Payment__c,
                        Amount_To_Pay_Off2__c,
                        LASERCA__Account_Balance__c,
                        Credit_Loan_Type_pick__c,
                        Exclude__c,
                        Lien_Position__c,
                        Lien_Interest_Rate_Sub_Type__c,
                        LASERCA__Credit_Limit__c,
                        LASERCA__Personal_Credit_Report__r.Opportunity__r.RecordTypeId,
                        LASERCA__Personal_Credit_Report__r.Opportunity__r.Sum_of_Debt_Payments__c,
                        To_Close_Account__c,
                        In_Repayment__c
                FROM LASERCA__Trade_Accounts__c
                WHERE (LASERCA__Personal_Credit_Report__c IN: pcr_ids
                AND Exclude__c = FALSE
                AND Credit_Loan_Type_pick__c != null
                AND LASERCA__Monthly_Payment__c != null
                AND LASERCA__Account_Balance__c != null
                AND LASERCA__Account_Status_Type__c = 'Open')];

        // Variables for computation
        Double tmp_pre_close_other_liab = 0; // Sum_of_Debt_Payments__c
        Double tmp_post_close_other_liab = 0; // Post_Close_Sum_of_Debt_Payments__c
        Double tmp_lien_pay_off_sum = 0; // Lien_Pay_Off_Sum__c
        Double tmp_other_to_pay_off_sum = 0; // Sum_of_Debt_to_be_Paid_Off__c
        Double tmp_pre_close_mort_debt = 0; // Present_Total_Mortgage_Debt__c
        Double tmp_post_close_ltv_redux_sum = 0; // Post_Close_LTV_Redux_Sum__c
        Double tmp_post_close_other_liab_mnthly_pmt_redux = 0; // Amount to reduce post-close monthly liabiliites for HB

        // Loop through trade accounts
        // Assumes that the PCR Trade Accounts we are looping through are those of the PCR on the Opportunity
        for(LASERCA__Trade_Accounts__c newtrdacc: newtrdacclist) {
            Boolean sub_lien_bool = is_subject_lien(newtrdacc.Credit_Loan_Type_pick__c); // temp variable for if this is a subject property lien

            // Add to other liabilities totals
            if (!sub_lien_bool) {
                // pre-close
                tmp_pre_close_other_liab += newtrdacc.LASERCA__Monthly_Payment__c;

                // post-close (only if it is NOT being paid off)
                if (!newtrdacc.To_Be_Paid_Off__c) {
                    tmp_post_close_other_liab += newtrdacc.LASERCA__Monthly_Payment__c;
                } else {
                    // if it is being paid off, add balance the total being paid off
                    tmp_other_to_pay_off_sum += newtrdacc.Amount_To_Pay_Off2__c;
                    tmp_post_close_other_liab_mnthly_pmt_redux += newtrdacc.LASERCA__Monthly_Payment__c;
                }
            } else { // If it is a subject property lien
                // If it is a HELOC add the credit limit value to the balance
                // otherwise add the balance
                if (newtrdacc.Lien_Interest_Rate_Sub_Type__c == 'HELOC' && newtrdacc.In_Repayment__c == false) {
                    // System.System.debug('*** IN HERE for HELOC: ');
                    // null check the credit limit
                    if(newtrdacc.LASERCA__Account_Balance__c != null && newtrdacc.LASERCA__Credit_Limit__c != null) {
                        // System.System.debug('*** IN HERE for HELOC TOO: ');
                        if(newtrdacc.LASERCA__Account_Balance__c > newtrdacc.LASERCA__Credit_Limit__c) {
                            tmp_pre_close_mort_debt += newtrdacc.LASERCA__Account_Balance__c;
                        } else {
                            tmp_pre_close_mort_debt += newtrdacc.LASERCA__Credit_Limit__c;
                        }
                    } else if(newtrdacc.LASERCA__Account_Balance__c == null && newtrdacc.LASERCA__Credit_Limit__c != null) {
                        tmp_pre_close_mort_debt += newtrdacc.LASERCA__Credit_Limit__c;
                    } else if(newtrdacc.LASERCA__Account_Balance__c != null && newtrdacc.LASERCA__Credit_Limit__c == null) {
                        tmp_pre_close_mort_debt += newtrdacc.LASERCA__Account_Balance__c;
                    } else {
                        tmp_pre_close_mort_debt += 0;
                    }
                    system.System.debug('*** tmp_pre_close_mort_debt: ' + tmp_pre_close_mort_debt);
                } else if(newtrdacc.Lien_Interest_Rate_Sub_Type__c == 'HELOC' && newtrdacc.In_Repayment__c) {
                    tmp_pre_close_mort_debt += newtrdacc.LASERCA__Account_Balance__c;
                } else {
                    tmp_pre_close_mort_debt += newtrdacc.LASERCA__Account_Balance__c;
                }

                // Add amount to pay off to lien pay off sum and determine Post-Close LTV Redux
                if (newtrdacc.To_Be_Paid_Off__c) {
                    System.System.debug('*** Lien to pay off: ' + newtrdacc.Amount_To_Pay_Off2__c);
                    if (newtrdacc.Amount_To_Pay_Off2__c != null)
                        tmp_lien_pay_off_sum += newtrdacc.Amount_To_Pay_Off2__c;

                    // Post-Close LTV Redux
                    // If the mortgage is a HELOC and the credit line is still open
                    if(newtrdacc.Lien_Interest_Rate_Sub_Type__c == 'HELOC' && newtrdacc.In_Repayment__c == false) {
                        // If we are going to close the account, then the full credit limit amount should be
                        // removed from the Pre-Close total mortgage debt
                        if(newtrdacc.To_Close_Account__c == true) {
                            if(newtrdacc.LASERCA__Account_Balance__c != null && newtrdacc.LASERCA__Credit_Limit__c != null) {
                                if(newtrdacc.LASERCA__Account_Balance__c > newtrdacc.LASERCA__Credit_Limit__c) {
                                    tmp_post_close_ltv_redux_sum += newtrdacc.LASERCA__Account_Balance__c;
                                } else {
                                    tmp_post_close_ltv_redux_sum += newtrdacc.LASERCA__Credit_Limit__c;
                                }
                            } else if(newtrdacc.LASERCA__Account_Balance__c == null && newtrdacc.LASERCA__Credit_Limit__c != null) {
                                tmp_post_close_ltv_redux_sum += newtrdacc.LASERCA__Credit_Limit__c;
                            } else if(newtrdacc.LASERCA__Account_Balance__c != null && newtrdacc.LASERCA__Credit_Limit__c == null) {
                                tmp_post_close_ltv_redux_sum += newtrdacc.LASERCA__Account_Balance__c;
                            } else {
                                tmp_post_close_ltv_redux_sum += 0;
                            }
                            system.System.debug('*** tmp_post_close_ltv_redux_sum: ' + tmp_post_close_ltv_redux_sum);
                        } else {
                            // Otherwise, the account is still open and could be drawn on. The LTV should not be lowered.
                            // Showing that nothing should be added, even though it is not technically necessary.
                            tmp_post_close_ltv_redux_sum += 0;
                        }

                    // If it is not a HELOC or it is a HELOC in repayment, we simply reduce the mortgage amount by
                    // the amount to pay off
                    } else if(newtrdacc.Lien_Interest_Rate_Sub_Type__c == 'HELOC' && newtrdacc.In_Repayment__c) {
                        if(newtrdacc.To_Close_Account__c == true) {
                            tmp_post_close_ltv_redux_sum += newtrdacc.LASERCA__Account_Balance__c;
                        } else {
                            tmp_post_close_ltv_redux_sum += newtrdacc.Amount_To_Pay_Off2__c;
                        }
                    } else {
                        tmp_post_close_ltv_redux_sum += newtrdacc.Amount_To_Pay_Off2__c;
                    }
                }
            }
        } // end loop

        // Update values on the opportunity - should skip if we are in lead stage and there is no opportunity
        try {
            Opportunity tmp_opp = new Opportunity();
            tmp_opp.Id = newtrdacclist[0].LASERCA__Personal_Credit_Report__r.Opportunity__c;

            // Set values
            // If HB, sum of debts is not edited
            // HO pre and post close other liabilities computed straight from credit report / trade accounts
            if (newtrdacclist[0].LASERCA__Personal_Credit_Report__r.Opportunity__r.RecordTypeId == IDHomeOwner) {
                tmp_opp.Sum_of_Debt_Payments__c = tmp_pre_close_other_liab;
                tmp_opp.Post_Close_Sum_of_Debt_Payments__c = tmp_post_close_other_liab;
            }

            // If HB then we take the manually entered Pre-Close other liabilities and subtract the amount to pay off, if any
            if (newtrdacclist[0].LASERCA__Personal_Credit_Report__r.Opportunity__r.RecordTypeId == IDHomeBuyer || newtrdacclist[0].LASERCA__Personal_Credit_Report__r.Opportunity__r.RecordTypeId == IDHomeBuyerCanada) {
                tmp_opp.Post_Close_Sum_of_Debt_Payments__c = newtrdacclist[0].LASERCA__Personal_Credit_Report__r.Opportunity__r.Sum_of_Debt_Payments__c - tmp_post_close_other_liab_mnthly_pmt_redux;
            }

            tmp_opp.Lien_Pay_Off_Sum__c = tmp_lien_pay_off_sum;
            tmp_opp.Sum_of_Debt_to_be_Paid_Off__c = tmp_other_to_pay_off_sum;
            tmp_opp.Present_Total_Mortgage_Debt__c = tmp_pre_close_mort_debt;
            tmp_opp.Post_Close_LTV_Redux_Sum__c = tmp_post_close_ltv_redux_sum;

            // system.debug('Sum of Debts'+tmp_pre_close_other_liab);
            // system.debug('Post Close Other'+tmp_post_close_other_liab);
            // system.debug('Lien Pay off'+tmp_lien_pay_off_sum);
            // system.debug('Sum to be paid off'+tmp_other_to_pay_off_sum);
            // system.debug('total mortgage'+tmp_pre_close_mort_debt);

            // Update Opportunity data
            update tmp_opp;
        } catch (Exception e) {
            return;
        }
    }

    public static Boolean is_subject_lien(String credit_loan_type) {
        if ((credit_loan_type == 'Mortgage') || (credit_loan_type == 'Other Lien') || (credit_loan_type == 'Other_Lien')) {
            return true;
        } else {
            return false;
        }
    }
	
    //Copy changes to Trade Account Changes object
    public static void CopyChanges(List<LASERCA__Trade_Accounts__c> newList, Map<Id, LASERCA__Trade_Accounts__c> oldMap) {

        List<Trade_Account_Changes_Field__mdt> fieldsMdts = [SELECT Trade_Account_Field__c, Trade_Account_Changes_Field__c, Active__c FROM Trade_Account_Changes_Field__mdt WHERE Active__c = true];

        List<LASERCA__Trade_Accounts__c> tasToUpdate = new List<LASERCA__Trade_Accounts__c>();
        Map<Id, Trade_Account_Changes__c> tacsToUpdate = new Map<Id, Trade_Account_Changes__c>();
        List<Trade_Account_Changes__c> tacsToInsert = new List<Trade_Account_Changes__c>();
        
        Map<Id, LASERCA__Trade_Accounts__c> taMap = new Map<Id, LASERCA__Trade_Accounts__c>(
            [SELECT LASERCA__Personal_Credit_Report__r.Opportunity__c, LASERCA__Personal_Credit_Report__r.LASERCA__Lead__c FROM LASERCA__Trade_Accounts__c WHERE Id IN :newList]
        );

        for (LASERCA__Trade_Accounts__c newTA : newList) {
            if (taMap.get(newTA.Id).LASERCA__Personal_Credit_Report__r.Opportunity__c != null || 
                (taMap.get(newTA.Id).LASERCA__Personal_Credit_Report__r.Opportunity__c == null && taMap.get(newTA.Id).LASERCA__Personal_Credit_Report__r.LASERCA__Lead__c != null)
               )
            {
                LASERCA__Trade_Accounts__c oldTA = oldMap.get(newTA.Id);
    
                boolean somethingChanged = false;
                Trade_Account_Changes__c tac = new Trade_Account_Changes__c();
                tac.Account_Identifier__c = newTA.LASERCA__Account_Identifier__c;
		tac.Account_Balance__c = newTA.LASERCA__Account_Balance__c;
    
                for (Trade_Account_Changes_Field__mdt fieldMdt : fieldsMdts) {
                    if (newTA.get(fieldMdt.Trade_Account_Field__c) != oldTA.get(fieldMdt.Trade_Account_Field__c)) {
                        tac.put(fieldMdt.Trade_Account_Changes_Field__c, newTA.get(fieldMdt.Trade_Account_Field__c));
                        somethingChanged = true;
                    }
                }
    
                if (somethingChanged) {
                    if (newTA.Trade_Account_Changes__c != null)
                        tac.Id = newTA.Trade_Account_Changes__c;
                    else
                        tasToUpdate.add(new LASERCA__Trade_Accounts__c(Id = newTA.Id, Trade_Account_Changes__r = tac));
                    if (tac.Id == null)
                        tacsToInsert.add(tac);
                    else
                    	tacsToUpdate.put(tac.Id, tac);
                }
            }
        }

        if (tacsToUpdate.size() > 0)
            update tacsToUpdate.values();
        if (tacsToInsert.size() > 0)
            insert tacsToInsert;
        if (tasToUpdate.size() > 0) {
            for (LASERCA__Trade_Accounts__c ta : tasToUpdate)
                ta.Trade_Account_Changes__c = ta.Trade_Account_Changes__r.Id;
            update tasToUpdate;
        }
    }

    private static Set<Id> tasUpdated = new Set<Id>();
    //Find Trade Account Changes
    public static void FindTradeAccountChanges(List<LASERCA__Trade_Accounts__c> newList) {

        Set<String> accIdents = new Set<String>();
        Set<Id> pcrIds = new Set<Id>();

        Map<String, LASERCA__Trade_Accounts__c> latestByDate = new Map<String, LASERCA__Trade_Accounts__c>();
        Map<String, List<LASERCA__Trade_Accounts__c>> earliestByDate = new Map<String, List<LASERCA__Trade_Accounts__c>>();

        for (LASERCA__Trade_Accounts__c ta : newList) {
            if (ta.LASERCA__Account_Identifier__c != null && ta.Trade_Account_Changes__c == null) {
                accIdents.add(ta.LASERCA__Account_Identifier__c);
                pcrIds.add(ta.LASERCA__Personal_Credit_Report__c);
                String key = ta.LASERCA__Personal_Credit_Report__c + '~' + ta.LASERCA__Account_Identifier__c;
                if (!latestByDate.containsKey(key)) {
                    latestByDate.put(key, ta);
                    earliestByDate.put(key, new List<LASERCA__Trade_Accounts__c>());
                } else {
                    if (latestByDate.get(key).LASERCA__Account_Reported_Date__c < ta.LASERCA__Account_Reported_Date__c) {
                        earliestByDate.get(key).add(latestByDate.get(key));
                        //tasToUpdate.add(new LASERCA__Trade_Accounts__c(Id = latestByDate.get(key).Id, Exclude__c = true));
                        latestByDate.put(key, ta);
                    } else {
                        earliestByDate.get(key).add(ta);
                        //tasToUpdate.add(new LASERCA__Trade_Accounts__c(Id = ta.Id, Exclude__c = true));
                    }
                }
            }
        }

        if (accIdents.size() > 0) {
            Map<Id, Id> pcrToMainObjMap = new Map<Id, Id>();
            for (LASERCA__Personal_Credit_Report__c pcr : [SELECT Id, Opportunity__c, LASERCA__Lead__c FROM LASERCA__Personal_Credit_Report__c WHERE Id IN :pcrIds]) {
                if (pcr.Opportunity__c != null) {
                    pcrToMainObjMap.put(pcr.Id, pcr.Opportunity__c);
                } else if (pcr.LASERCA__Lead__c != null) {
                    pcrToMainObjMap.put(pcr.Id, pcr.LASERCA__Lead__c);
                }
            }

            List<Trade_Account_Changes_Field__mdt> fieldsMdts = [SELECT Trade_Account_Field__c, Trade_Account_Changes_Field__c, Active__c FROM Trade_Account_Changes_Field__mdt WHERE Active__c = true];

            string query = 'SELECT Id, LASERCA__Account_Reported_Date__c, Trade_Account_Changes__r.Account_Identifier__c';
            query += ', LASERCA__Personal_Credit_Report__r.Opportunity__c, LASERCA__Personal_Credit_Report__r.LASERCA__Lead__c';
            
            for (Trade_Account_Changes_Field__mdt fieldMdt : fieldsMdts) {
                query += ', Trade_Account_Changes__r.' + fieldMdt.Trade_Account_Changes_Field__c;
            }
            if (!query.contains('Trade_Account_Changes__r.Account_Balance__c')) {
                query += ', Trade_Account_Changes__r.Account_Balance__c';
            }
            List<Id> objIds = pcrToMainObjMap.values();
            query += ', (SELECT Id FROM Requirements__r)';
            query += ' FROM LASERCA__Trade_Accounts__c WHERE (LASERCA__Personal_Credit_Report__r.Opportunity__c IN :objIds OR LASERCA__Personal_Credit_Report__r.LASERCA__Lead__c IN :objIds)';
            query += ' AND Trade_Account_Changes__r.Account_Identifier__c IN :accIdents';
            Map<String, LASERCA__Trade_Accounts__c> tacMap = new Map<String, LASERCA__Trade_Accounts__c>();
            Map<String, List<Current_Conditions__c>> requirementsMap = new Map<String, List<Current_Conditions__c>>();
            for (LASERCA__Trade_Accounts__c ta : Database.query(query)) {
                string key = ta.LASERCA__Personal_Credit_Report__r.Opportunity__c + '~' + ta.Trade_Account_Changes__r.Account_Identifier__c;
                if (ta.LASERCA__Personal_Credit_Report__r.Opportunity__c == null && ta.LASERCA__Personal_Credit_Report__r.LASERCA__Lead__c != null) {
                    key = ta.LASERCA__Personal_Credit_Report__r.LASERCA__Lead__c + '~' + ta.Trade_Account_Changes__r.Account_Identifier__c;
                }

                if (!tacMap.containsKey(key)) {
                    tacMap.put(key, ta);
                } else {
                    if (tacMap.get(key).LASERCA__Account_Reported_Date__c < ta.LASERCA__Account_Reported_Date__c) {
                        tacMap.put(key, ta);
                    }
                }

                if (!requirementsMap.containsKey(key))
                    requirementsMap.put(key, new List<Current_Conditions__c>());
                requirementsMap.get(key).addAll(ta.Requirements__r);
            }
            
            List<LASERCA__Trade_Accounts__c> tasToUpdate = new List<LASERCA__Trade_Accounts__c>();
            Map<Id, Current_Conditions__c> reqsToUpdate = new Map<Id, Current_Conditions__c>();
            
            for (String pcrKey : latestByDate.keySet()) {
                LASERCA__Trade_Accounts__c ta = latestByDate.get(pcrKey);
                if (pcrToMainObjMap.containsKey(ta.LASERCA__Personal_Credit_Report__c)) {
                    Id objId = pcrToMainObjMap.get(ta.LASERCA__Personal_Credit_Report__c);
                    String accIdent = ta.LASERCA__Account_Identifier__c;
                    String key = objId + '~' + accIdent;
                    if (tacMap.containsKey(key)) {
                        Trade_Account_Changes__c tac = tacMap.get(key).Trade_Account_Changes__r;
                        if (!tac.Exclude__c || (ta.LASERCA__Account_Reported_Date__c == tacMap.get(key).LASERCA__Account_Reported_Date__c)) {
                            LASERCA__Trade_Accounts__c taToUpdate = new LASERCA__Trade_Accounts__c();
                            taToUpdate.Id = ta.Id;
                            taToUpdate.Trade_Account_Changes__c = tac.Id;

                            for (Trade_Account_Changes_Field__mdt fieldMdt : fieldsMdts) {
                                Object tacFieldVal = tac.get(fieldMdt.Trade_Account_Changes_Field__c);
                                if (tacFieldVal != null) {
                                    if (String.valueOf(tacFieldVal) != '') {
                                        taToUpdate.put(fieldMdt.Trade_Account_Field__c , tac.get(fieldMdt.Trade_Account_Changes_Field__c));
                                    }
                                }
                            }

                            // Custom code for Amount_To_Pay_Off2__c
                            if (tac.Amount_To_Pay_Off2__c == tac.Account_Balance__c)
                                taToUpdate.Amount_To_Pay_Off2__c = ta.LASERCA__Account_Balance__c;
                            if (tac.Amount_To_Pay_Off2__c > tac.Account_Balance__c)
                                taToUpdate.Amount_To_Pay_Off2__c = ta.LASERCA__Account_Balance__c;
                            if (tac.Amount_To_Pay_Off2__c < tac.Account_Balance__c && tac.Amount_To_Pay_Off2__c <= ta.LASERCA__Account_Balance__c)
                                taToUpdate.Amount_To_Pay_Off2__c = tac.Amount_To_Pay_Off2__c;
                            if (tac.Amount_To_Pay_Off2__c < tac.Account_Balance__c && tac.Amount_To_Pay_Off2__c > ta.LASERCA__Account_Balance__c)
                                taToUpdate.Amount_To_Pay_Off2__c = (tac.Amount_To_Pay_Off2__c / tac.Account_Balance__c) * ta.LASERCA__Account_Balance__c;
                            if (ta.LASERCA__Account_Balance__c == null || ta.LASERCA__Account_Balance__c == 0)
                                taToUpdate.To_Be_Paid_Off__c = false;

                            if (!tasUpdated.contains(taToUpdate.Id)) {
                                tasToUpdate.add(taToUpdate);
                                tasUpdated.add(taToUpdate.Id);
                            }
                        }

                    }
                        
                    if (earliestByDate.containsKey(pcrKey)) {
                        for (LASERCA__Trade_Accounts__c otherTA : earliestByDate.get(pcrKey)) {
                            if (otherTA.Exclude__c != true) {
                                if (!tasUpdated.contains(otherTA.Id)) {
                                    tasToUpdate.add(new LASERCA__Trade_Accounts__c(Id = otherTA.Id, Exclude__c = true));
                                    tasUpdated.add(otherTA.Id);
                                }
                            }
                        }
                    }

                    if (requirementsMap.containsKey(key)) {
                        for (Current_Conditions__c req : requirementsMap.get(key)) {
                            reqsToUpdate.put(req.Id, new Current_Conditions__c(Id = req.Id, Trade_Account__c = ta.Id));
                        }
                    }
                }
                
            }

            if (tasToUpdate.size() > 0) {
                System.debug(tasToUpdate);
                update tasToUpdate;
            }
            
            if (reqsToUpdate.size() > 0) {
                update reqsToUpdate.values();
            }
            
        }

    }
	
    //Set the right Personal Credit Report on the New Trade Account
    /*public static void SetTheRightPCROnNewTradeAccounts(List<LASERCA__Trade_Accounts__c> newList) {

        Set<Id> oppIds = new Set<Id>();
        for (LASERCA__Trade_Accounts__c newTA : newList) {
            if (String.isBlank(newTA.LASERCA__Account_Identifier__c) && newTA.Opportunity__c != null) {
                oppIds.add(newTA.Opportunity__c);
            }
        }

        if (oppIds.size() > 0) {
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Personal_Credit_Report__c FROM Opportunity WHERE Id IN :oppIds]);

            for (LASERCA__Trade_Accounts__c newTA : newList) {
                if (String.isBlank(newTA.LASERCA__Account_Identifier__c) && newTA.Opportunity__c != null) {
                    if (oppMap.containsKey(newTA.Opportunity__c)) {
                        if (oppMap.get(newTA.Opportunity__c).Personal_Credit_Report__c != null) {
                            newTA.LASERCA__Personal_Credit_Report__c = oppMap.get(newTA.Opportunity__c).Personal_Credit_Report__c;
                        }
                    }
                }
            }
        }
    }*/
}

// Helper function to indiciate whether a trade account is a subject property lien

// ######### OLD CODE ############

//createrequirementandtask used insteadon trigger
////code not being use on the actual trigger code commented out on triggertradeaccount
/*public static void createrequirementandtask(List<LASERCA__Trade_Accounts__c> newlist)
{
    set<String> tradeaccountidsforpayoff = new set<String>();
    set<String> tradeaccountidsforpaydown = new set<String>();
    map<String,String> tradetooppmap = new map<String,String>();
    set<String> opportunityids = new set<String>();
    for(LASERCA__Trade_Accounts__c obj: newlist)
    {
        if(obj.To_Be_Paid_Off__c == true && obj.Opportunity__c != null)
        {
            if(obj.Credit_Loan_Type_pick__c != 'Mortgage' && obj.Credit_Loan_Type_pick__c !=  'Other Lien' && (obj.Lien_Position__c == ''|| obj.Lien_Position__c == null))
            {
                tradeaccountidsforpayoff.add(obj.id);
                opportunityids.add(obj.Opportunity__c);
                tradetooppmap.put(obj.id,obj.Opportunity__c);
            }
            else if((obj.Credit_Loan_Type_pick__c == 'Mortgage' || obj.Credit_Loan_Type_pick__c ==  'Other Lien') && obj.Lien_Position__c != null){
                tradeaccountidsforpaydown.add(obj.id);
                opportunityids.add(obj.Opportunity__c);
                tradetooppmap.put(obj.id,obj.Opportunity__c);
            }
        }
    }
    map<String,String> mapofopportunitysuccess = new map<String,String>();
    for(Success_Factor__c obj:[select id,Opportunity__c from Success_Factor__c where Success_Factor__c = 'Closing' AND Opportunity__c in: opportunityids])
    {
        mapofopportunitysuccess.put(obj.Opportunity__c,obj.id);
    }
    Conditional_Project_Tasks__mdt payoff = [select Requirement__c, Required_Tasks__c FROM Conditional_Project_Tasks__mdt where MasterLabel = 'Pay off specific liability'];
    Conditional_Project_Tasks__mdt paydown = [select Requirement__c, Required_Tasks__c FROM Conditional_Project_Tasks__mdt where MasterLabel = 'Client must pay down mortgage'];
    system.debug('tradeaccountidsforpayoff==>'+tradeaccountidsforpayoff);
    system.debug('tradeaccountidsforpaydown==>'+tradeaccountidsforpaydown);
    if(tradeaccountidsforpayoff.size()>0)
    {
        List<Current_Conditions__c> listofcondition = new List<Current_Conditions__c>();
        List<Project_Task__c> projecttasks = new List<Project_Task__c>();
        for(String key: tradeaccountidsforpayoff)
        {
            Current_Conditions__c obj = new Current_Conditions__c();
            obj.Requirement__c = payoff.Requirement__c;
            obj.Code__c = 'test';
            obj.Trade_Account__c = key;
            obj.Status__c = 'In-progress';
            obj.Assigned_To__c = 'IA';
            obj.Type__c='Stipulation';
            String temp = tradetooppmap.get(key);
            temp = mapofopportunitysuccess.get(temp);
            obj.Success_Factor__c = temp;
            listofcondition.add(obj);
        }
        if(listofcondition.size()>0)
        {
            insert listofcondition;
            for(Current_Conditions__c obj:listofcondition)
            {
                for(String str:payoff.Required_Tasks__c.split(';'))
                {
                    Project_Task__c newtask = new  Project_Task__c();
                    newtask.Requirement__c = obj.id;
                    newtask.Name = str;
                    newtask.Completed__c = false;
                    projecttasks.add(newtask);
                }
            }
            insert projecttasks;
            system.debug('listofcondition==>'+listofcondition);
            system.debug('projecttasks==>'+projecttasks);
        }
    }
    if(tradeaccountidsforpaydown.size()>0)
    {
        List<Current_Conditions__c> listofcondition = new List<Current_Conditions__c>();
        List<Project_Task__c> projecttasks = new List<Project_Task__c>();
        for(String key: tradeaccountidsforpaydown)
        {
            Current_Conditions__c obj = new Current_Conditions__c();
            obj.Requirement__c = Paydown.Requirement__c;
            obj.Code__c = 'test';
            obj.Trade_Account__c = key;
            obj.Status__c = 'In-progress';
            obj.Assigned_To__c = 'IA';
            obj.Type__c='Stipulation';
            String temp = tradetooppmap.get(key);
            temp = mapofopportunitysuccess.get(temp);
            obj.Success_Factor__c = temp;
            listofcondition.add(obj);
        }
        if(listofcondition.size()>0)
        {
            insert listofcondition;
            for(Current_Conditions__c obj:listofcondition)
            {
                for(String str:paydown.Required_Tasks__c.split(';'))
                {
                    Project_Task__c newtask = new  Project_Task__c();
                    newtask.Requirement__c = obj.id;
                    newtask.Name = str;
                    newtask.Completed__c = false;
                    projecttasks.add(newtask);
                }
            }
            insert projecttasks;
            system.debug('listofcondition==>'+listofcondition);
            system.debug('projecttasks==>'+projecttasks);
        }
    }
}*/

/*
if(oldmap.get(newtrdacc.Id).Opportunity__c != Null){
    trdaccsoppids.add(oldmap.get(newtrdacc.Id).Opportunity__c);
}
if(newtrdacc.To_Be_Paid_Off__c == false)
{
    if(newtrdacc.Credit_Loan_Type_pick__c != 'Mortgage' && newtrdacc.Credit_Loan_Type_pick__c !=  'Other Lien' && (newtrdacc.Lien_Position__c == ''|| newtrdacc.Lien_Position__c == null))
    {
        tradeaccountids.add(newtrdacc.id);
    }
    else if((newtrdacc.Credit_Loan_Type_pick__c == 'Mortgage' || newtrdacc.Credit_Loan_Type_pick__c ==  'Other Lien') && newtrdacc.Lien_Position__c != null){
        tradeaccountidsforpaydown.add(newtrdacc.id);
    }
}
*/

/*
system.debug('tradeaccountids==>'+tradeaccountids);
system.debug('tradeaccountidsforpaydown==>'+tradeaccountidsforpaydown);
Set<String> projecttaskids = new Set<String>();
List<Current_Conditions__c> requirements = new List<Current_Conditions__c>();
if(tradeaccountids.size()>0)
{
    for(Current_Conditions__c obj:[select id, Status__c, Type__c from Current_Conditions__c where Trade_Account__c in: tradeaccountids AND Type__c='Stipulation'])
    {
        obj.Status__c = 'Waived';
        requirements.add(obj);
        projecttaskids.add(obj.id);
    }
}
if(tradeaccountidsforpaydown.size()>0)
{
    for(Current_Conditions__c obj:[select id, Status__c, Type__c from Current_Conditions__c where Trade_Account__c in: tradeaccountidsforpaydown AND Type__c='Stipulation'])
    {
        obj.Status__c = 'Waived';
        requirements.add(obj);
        projecttaskids.add(obj.id);
    }
}
List<Project_Task__c> toupdatetasks = new List<Project_Task__c>();
if(projecttaskids.size()>0)
{
    for(Project_Task__c obj: [select id,Completed__c from Project_Task__c where id in: projecttaskids])
    {
        obj.Completed__c = true;
        toupdatetasks.add(obj);
    }
}
update requirements;
update toupdatetasks;
*/

//system.debug('requirements==>'+requirements);
//system.debug('toupdatetasks==>'+toupdatetasks);
//system.debug('******trdaccsoppids*******'+trdaccsoppids);


//class commented out on the actual trigger
/*
public static void createrequirementandtask(List<LASERCA__Trade_Accounts__c> newlist, Map<Id,LASERCA__Trade_Accounts__c> oldmap)
{
    set<String> tradeaccountidsforpayoff = new set<String>();
    set<String> tradeaccountidsforpaydown = new set<String>();
    map<String,String> tradetooppmap = new map<String,String>();
    set<String> opportunityids = new set<String>();
    for(LASERCA__Trade_Accounts__c obj: newlist)
    {

        boolean paidOff = true;
        if (oldmap != null )
            paidOff = oldmap.get(obj.id).To_Be_Paid_Off__c == FALSE;

        if(obj.To_Be_Paid_Off__c == true && obj.Opportunity__c != null && paidOff)
        {
            if(obj.Credit_Loan_Type_pick__c != 'Mortgage' && obj.Credit_Loan_Type_pick__c !=  'Other Lien' && (obj.Lien_Position__c == ''|| obj.Lien_Position__c == null))
            {
                tradeaccountidsforpayoff.add(obj.id);
                opportunityids.add(obj.Opportunity__c);
                tradetooppmap.put(obj.id,obj.Opportunity__c);
            }
            else if((obj.Credit_Loan_Type_pick__c == 'Mortgage' || obj.Credit_Loan_Type_pick__c ==  'Other Lien') && obj.Lien_Position__c != null){
                tradeaccountidsforpaydown.add(obj.id);
                opportunityids.add(obj.Opportunity__c);
                tradetooppmap.put(obj.id,obj.Opportunity__c);
            }
        }
    }
    map<String,String> mapofopportunitysuccess = new map<String,String>();
    for(Success_Factor__c obj:[select id,Opportunity__c from Success_Factor__c where Success_Factor__c = 'Closing' AND Opportunity__c in: opportunityids])
    {
        mapofopportunitysuccess.put(obj.Opportunity__c,obj.id);
    }
    List<Conditional_Project_Tasks__mdt> payoff = [select Requirement__c, Required_Tasks__c FROM Conditional_Project_Tasks__mdt where MasterLabel = 'Pay off specific liability'];
    List<Conditional_Project_Tasks__mdt> paydown = [select Requirement__c, Required_Tasks__c FROM Conditional_Project_Tasks__mdt where MasterLabel = 'Client must pay down mortgage'];
    system.debug('tradeaccountidsforpayoff==>'+tradeaccountidsforpayoff);
    system.debug('tradeaccountidsforpaydown==>'+tradeaccountidsforpaydown);
    if(tradeaccountidsforpayoff.size()>0 && payoff.size()>0)
    {
        List<Current_Conditions__c> listofcondition = new List<Current_Conditions__c>();
        List<Project_Task__c> projecttasks = new List<Project_Task__c>();
        for(String key: tradeaccountidsforpayoff)
        {
            Current_Conditions__c obj = new Current_Conditions__c();
            obj.Requirement__c = payoff[0].Requirement__c;
            obj.Code__c = 'test';
            obj.Trade_Account__c = key;
            obj.Status__c = 'In-progress';
            obj.Assigned_To__c = 'IA';
            obj.Type__c='Stipulation';
            String temp = tradetooppmap.get(key);
            temp = mapofopportunitysuccess.get(temp);
            obj.Success_Factor__c = temp;
            listofcondition.add(obj);
        }
        if(listofcondition.size()>0)
        {
            insert listofcondition;
            for(Current_Conditions__c obj:listofcondition)
            {
                for(String str:payoff[0].Required_Tasks__c.split(';'))
                {
                    Project_Task__c newtask = new  Project_Task__c();
                    newtask.Requirement__c = obj.id;
                    newtask.Name = str;
                    newtask.Completed__c = false;
                    projecttasks.add(newtask);
                }
            }
            insert projecttasks;
            system.debug('listofcondition==>'+listofcondition);
            system.debug('projecttasks==>'+projecttasks);
        }
    }
    if(tradeaccountidsforpaydown.size()>0 && (paydown.size()>0))
    {
        List<Current_Conditions__c> listofcondition = new List<Current_Conditions__c>();
        List<Project_Task__c> projecttasks = new List<Project_Task__c>();
        for(String key: tradeaccountidsforpaydown)
        {
            Current_Conditions__c obj = new Current_Conditions__c();
            obj.Requirement__c = paydown[0].Requirement__c;
            obj.Code__c = 'test';
            obj.Trade_Account__c = key;
            obj.Status__c = 'In-progress';
            obj.Assigned_To__c = 'IA';
            obj.Type__c='Stipulation';
            String temp = tradetooppmap.get(key);
            temp = mapofopportunitysuccess.get(temp);
            obj.Success_Factor__c = temp;
            listofcondition.add(obj);
        }
        if(listofcondition.size()>0)
        {
            insert listofcondition;
            for(Current_Conditions__c obj:listofcondition)
            {
            for(String str:paydown[0].Required_Tasks__c.split(';'))
                {
                    Project_Task__c newtask = new  Project_Task__c();
                    newtask.Requirement__c = obj.id;
                    newtask.Name = str;
                    newtask.Completed__c = false;
                    projecttasks.add(newtask);
                }
            }
            //insert projecttasks;
            system.debug('listofcondition==>'+listofcondition);
            system.debug('projecttasks==>'+projecttasks);
        }
    }
}
*/