/************************************************************************************
 Apex Class Name     : OpportunityService
 Version             : 1.0
 Created Date        : 5th March 2019
 Function            : Logic Delegated From OpportunityTriggerHandler to OpportunityFormulasCalculations ,
                       To Calculate Final OAV ,DTI Formulas.
 Author              : Neeraja Cherukuri

 Modification Log    :

* Developer                   Date                    Description
* ----------------------------------------------------------------------------------
* Neeraja Cherukuri            03/05/2019               Original Version
*************************************************************************************
2019-05-22: Reviewed, edited, and commented by Brad
*/
public class OpportunityService {
    private static final ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
    private static final ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();        
    private static final ID IDHomeBuyerCanada = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer Canada').getRecordTypeId();    
    
    // Function to compute OAV for an Opportunity
    public static void finaloavFormulas(List<Opportunity> opplist){
        // Loop through Opportunities provided
        for(Opportunity opty :  opplist) {
            // If an IA has overriden the value, that should be the final OAV
            if(opty.IA_OAV_Override__c != null && opty.IA_OAV_Override__c > 0) {
                opty.Final_OAV_Calculation__c = opty.IA_OAV_Override__c;
            } else {
                // #### Set up storage
                Double OAV_pre_discount = 0; // for the value, pre OAV discount reduction

                // Boolean flags for whether the opportunity has a "valid" PP or Summary appraised value, meaning
                // the values are not NULL and are greater than zero (these values should default as zero, null
                // checker is for good measure)
                Boolean has_purchase_price = opty.Purchase_Price__c != null && opty.Purchase_Price__c > 0 ? true : false;
                Boolean has_summary_appraised = opty.Summary_Appraised_Value__c != null && opty.Summary_Appraised_Value__c > 0 ? true : false;

                // If this opportunity has a valid Purchase Price or Summary Appraised Value, we evaluate based on
                // those values. Otherwise, we just take the Est Home Value.
                if(has_purchase_price || has_summary_appraised) {
                    Decimal resultForOAV = 0; // https://unison-technology.atlassian.net/browse/BUS-155110696
                    // If they are both valid, we take the MIN of the two
                    if(has_purchase_price && has_summary_appraised) {
                        if(opty.Seller_s_Concession__c != null && opty.Seller_s_Concession__c >= 5000) {
                            resultForOAV = opty.Purchase_Price__c - opty.Seller_s_Concession__c;
                        } else {
                            resultForOAV = opty.Purchase_Price__c;
                        }
                        OAV_pre_discount = math.min(resultForOAV, opty.Summary_Appraised_Value__c);
                    }

                    // If just purchase price, use that
                    if(has_purchase_price && !has_summary_appraised) {
                        if(opty.Seller_s_Concession__c != null && opty.Seller_s_Concession__c >= 5000) {
                            resultForOAV = opty.Purchase_Price__c - opty.Seller_s_Concession__c;
                        } else {
                            resultForOAV = opty.Purchase_Price__c;
                        }
                        OAV_pre_discount = resultForOAV;
                    }

                    // If just summary price, use that
                    if(!has_purchase_price && has_summary_appraised) {
                        OAV_pre_discount = opty.Summary_Appraised_Value__c;
                    }

                    // Compute and set OAV discount
                    if (opty.OAV_Discount_Pct__c != null && opty.OAV_Discount_Pct__c > 0) {
                        opty.OAV_Discount_Amount__c = (opty.OAV_Discount_Pct__c / 100) * OAV_pre_discount;
                    } else {
                        opty.OAV_Discount_Amount__c = 0;
                    }

                    // Compute Final OAV
                    opty.Final_OAV_Calculation__c = OAV_pre_discount - opty.OAV_Discount_Amount__c;
                } else {
                    // Otherwise we just use the estimated home value. This is usually at the beginning of a file
                    opty.Final_OAV_Calculation__c = opty.Home_Value__c;
                }
            }
        }
    }

    // Function to compute DTI for an Opportunity
    public static void dtiFormulas(List<Opportunity> opplist) {
        // Loop through Opportunities provided
        for(Opportunity opty :  opplist) {

            // Update Post Close other liabilities if HB and has no debts to pay off
            if ((opty.Record_Type_Name__c == 'HomeBuyer' || opty.Record_Type_Name__c == 'HomeBuyer Canada') && opty.Sum_of_Debt_to_be_Paid_Off__c == 0) {
                opty.Post_Close_Sum_of_Debt_Payments__c = opty.Sum_of_Debt_Payments__c;
            }

            // Check if income is populated
            if (opty.Income_Total_2__c != null && opty.Income_Total_2__c > 0) {

                // Post Close Back-End DTI = Post-Close Total Lia. / Income
                if(opty.Post_Close_Liabilities_Total__c != null) {
                    opty.Post_Close_BE_Ratio__c = (opty.Post_Close_Liabilities_Total__c / opty.Income_Total_2__c) * 100;
                }

                // Pre-Close Back-End DTI = Pre-Close Total Lia. / Income
                if(opty.Pre_Close_Liabilities_Total__c != null) {
                    opty.Pre_Close_BE_Ratio__c = (opty.Pre_Close_Liabilities_Total__c / opty.Income_Total_2__c) * 100;
                }

                // Post-Close Front-End DTI = Post-Close Housing Expenses / Income
                if(opty.Post_Close_Monthly_Total_Housing__c != null) {
                    opty.Post_Close_FE_Ratio2__c = (opty.Post_Close_Monthly_Total_Housing__c / opty.Income_Total_2__c) * 100;
                }

                // Pre-Close Front-End DTI = Pre-Close Housing Expenses / Income
                if(opty.Pre_Close_Housing_Total__c != null) {
                    opty.Pre_Close_FE_Ratio2__c = (opty.Pre_Close_Housing_Total__c / opty.Income_Total_2__c) * 100;
                }
            } else if(opty.Income_Total_2__c == 0) {
                opty.Post_Close_BE_Ratio__c = null;
                opty.Pre_Close_BE_Ratio__c = null;
                opty.Post_Close_FE_Ratio2__c = null;
                opty.Pre_Close_FE_Ratio2__c = null;
            }
        }
    }

    // Function to compute the LTV for an Opportunity
    public static void ltvformulas(List<Opportunity> opplist) {

        for(Opportunity opp: opplist) {
            //system.debug('***********opp.Present_Total_Mortgage_Debt__c***********'+opp.Present_Total_Mortgage_Debt__c);
            //system.debug('************opp.Post_Close_Mortgage_Debt__c**********'+opp.Post_Close_Mortgage_Debt__c);
            //system.debug('**********opp.Final_OAV_Calculation__c************'+opp.Final_OAV_Calculation__c);
            //system.debug('***********Present_Total_Mortgage_Debt__c***********'+opp.Present_Total_Mortgage_Debt__c);

            // Compute Post-Close total mortgage debt = Pre-Close total debt - Lien Pay off Sum
            // Those two fields are updated from the TradeAccountTriggerHandler
            // Reduce the Mortgage debt for post-close by the computed redux amount
            if(opp.Present_Total_Mortgage_Debt__c != null && opp.Lien_Pay_Off_Sum__c != null) {
                // this is a new field and will be null for in flight opportunities. If that is the case, just use the old
                // field. It will be correct for most in flight deals, otherwise users will just need to save on
                // the Trade Account object to fire the calculation for Post_Close_LTV_Redux_Sum__c. This null check can be
                // removed in the future once the current opportunities in flight have been seasoned.
                if(opp.Post_Close_LTV_Redux_Sum__c == null) {
                    opp.Post_Close_Mortgage_Debt__c = opp.Present_Total_Mortgage_Debt__c - opp.Lien_Pay_Off_Sum__c;
                } else {
                    opp.Post_Close_Mortgage_Debt__c = opp.Present_Total_Mortgage_Debt__c - opp.Post_Close_LTV_Redux_Sum__c;
                }
            } else {
                opp.Post_Close_Mortgage_Debt__c = 0;
            }

            // Compute LTV Formulas
            // Pre/Post Close Mortgage Debt / Final OAV
            if(opp.Final_OAV_Calculation__c != null && opp.Final_OAV_Calculation__c != 0){
                if(opp.Post_Close_Mortgage_Debt__c != null) {
                    // Rounded to 2 decimals
                    opp.Post_Close_LTV2__c = ((opp.Post_Close_Mortgage_Debt__c / opp.Final_OAV_Calculation__c)*100).setScale(2);
                }
                if(opp.Present_Total_Mortgage_Debt__c != null) {
                    // Rounded to 2 decimals
                    opp.Pre_Close_LTV2__c = ((opp.Present_Total_Mortgage_Debt__c /opp.Final_OAV_Calculation__c)*100).setScale(2);
                }
            }
        }
    }

    // Function to compute the OIP Maximum and OIP Minimum for an Opportunity
    // 2nd version of OIP Maximum: https://unison-technology.atlassian.net/browse/BUS-155110466
    public static void oipFormulas(List<Opportunity> opplist) {
        system.debug('oip formulas');
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : opplist) {
            oppIds.add(opp.Id);
        }
        // Opportunity list
        List<Opportunity> opportunities = [
                SELECT Id,
                        StageName,
                        RecordTypeId,
                        Pricing_Ratio__c,
                        Final_OAV_Calculation__c,
                        Post_Close_LTV2__c,
                        Qualifies_for_New_HomeOwner_Pricing__c,
                        Is_NOO__c,
                        OIP_Maximum__c,
                        Max_OIP_Override__c,
                (SELECT Id, Property_Number_of_Units__c FROM Properties__r)
                FROM Opportunity
                WHERE Id =: oppids];
        Map<Id, Property__c> propertyMap = new Map<Id, Property__c>();
        for(Opportunity opp : opportunities) {
            for(Property__c prop : opp.Properties__r) {
                if(propertyMap.get(opp.Id) == null) {
                    propertyMap.put(opp.Id, prop);
                }
            }
        }

        ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ID IDHomeBuyerCanada = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer Canada').getRecordTypeId();
        for(Opportunity opp: opplist) {
            if (opp.Max_OIP_Override__c != null && opp.Max_OIP_Override__c > 0) {
                opp.OIP_Maximum__c = opp.Max_OIP_Override__c;
            } else {
                Decimal pricingRatio = opp.Pricing_Ratio__c != null ? opp.Pricing_Ratio__c : 0;
                Decimal finalOAV = opp.Final_OAV_Calculation__c != null ? opp.Final_OAV_Calculation__c : 0;
                Decimal postCloseLTV2 = opp.Post_Close_LTV2__c != null ? opp.Post_Close_LTV2__c : 0;
                Boolean qualifiesForNewHO = opp.Qualifies_for_New_HomeOwner_Pricing__c;
                Boolean isNOO = opp.Is_NOO__c;
                Decimal C1 = 0;
                Decimal C2 = 0;
                if (pricingRatio != 0) {
                    C1 = 0.70 / pricingRatio * finalOAV;
                }

                Decimal value_A = 0;
                Decimal value_B = 0;
                Decimal value_C = 0;
                Decimal value_XX = 0;
                // HomeOwner
                if (opp.RecordTypeId == IDHomeOwner) {
                    if (!qualifiesForNewHO && !isNOO && propertyMap.get(opp.Id) != null
                            && (propertyMap.get(opp.Id).Property_Number_of_Units__c == null || propertyMap.get(opp.Id).Property_Number_of_Units__c <= 2)) {
                        value_A = 500000; // $500,000
                        value_XX = 0.175; // 17.5%
                    } else if (!qualifiesForNewHO && !isNOO && propertyMap.get(opp.Id) != null && propertyMap.get(opp.Id).Property_Number_of_Units__c > 2) {
                        value_A = 500000; // $500,000
                        value_XX = 0.14; // 14%
                    } else if (!qualifiesForNewHO && isNOO) {
                        value_A = 500000; // $500,000
                        value_XX = 0.14; // 14%
                    } else if (qualifiesForNewHO && !isNOO && propertyMap.get(opp.Id) != null
                            && (propertyMap.get(opp.Id).Property_Number_of_Units__c == null || propertyMap.get(opp.Id).Property_Number_of_Units__c <= 2)) {
                        value_A = 1000000; // $1,000,000
                        value_XX = 0.20; // 20%
                    } else if (qualifiesForNewHO && !isNOO && propertyMap.get(opp.Id) != null && propertyMap.get(opp.Id).Property_Number_of_Units__c > 2) {
                        value_A = 1000000; // $1,000,000
                        value_XX = 0.155; // 15.5%
                    } else if (qualifiesForNewHO && isNOO) {
                        value_A = 1000000; // $1,000,000
                        value_XX = 0.155; // 15.5%
                    }
                } // HomeBuyer
                else if (opp.RecordTypeId == IDHomeBuyer || opp.RecordTypeId == IDHomeBuyerCanada) {
                    if (!isNOO && propertyMap.get(opp.Id) != null && (propertyMap.get(opp.Id).Property_Number_of_Units__c == null || propertyMap.get(opp.Id).Property_Number_of_Units__c <= 2)) {
                        value_A = 1000000; // $1,000,000
                        value_XX = 0.20; // 20%
                    } else if (!isNOO && propertyMap.get(opp.Id) != null && propertyMap.get(opp.Id).Property_Number_of_Units__c > 2) {
                        value_A = 1000000; // $1,000,000
                        value_XX = 0.155; // 15.5%
                    } else if (isNOO) {
                        value_A = 1000000; // $1,000,000
                        value_XX = 0.155; // 15.5%
                    }
                }

                // B
                value_B = C1;
                // C
                value_C = value_XX * finalOAV;

                List<Decimal> myValues = new List<Decimal>();
                myValues.add(value_A);
                myValues.add(value_B);
                myValues.add(value_C);
                myValues.sort();

                // Assign lowest value to C1
                Decimal finalC1 = 0;
                Decimal finalC1Result = 0;
                finalC1 = myValues[0].round();

                // C2
                if (opp.RecordTypeId == IDHomeOwner) {
                    if (opp.Qualifies_for_New_HomeOwner_Pricing__c == false && opp.Is_NOO__c == false && propertyMap.get(opp.Id) != null
                            && (propertyMap.get(opp.Id).Property_Number_of_Units__c == null || propertyMap.get(opp.Id).Property_Number_of_Units__c <= 2)) {
                        C2 = finalOAV * ((90 - postCloseLTV2) / 100);
                    } else if (opp.Qualifies_for_New_HomeOwner_Pricing__c == false && opp.Is_NOO__c == false && propertyMap.get(opp.Id) != null
                            && propertyMap.get(opp.Id).Property_Number_of_Units__c > 2) {
                        C2 = finalOAV * ((80 - postCloseLTV2) / 100);
                    } else if (opp.Qualifies_for_New_HomeOwner_Pricing__c == true && opp.Is_NOO__c == false && propertyMap.get(opp.Id) != null
                            && (propertyMap.get(opp.Id).Property_Number_of_Units__c == null || propertyMap.get(opp.Id).Property_Number_of_Units__c <= 2)) {
                        C2 = finalOAV * ((95 - postCloseLTV2) / 100);
                    } else if (opp.Qualifies_for_New_HomeOwner_Pricing__c == true && opp.Is_NOO__c == false && propertyMap.get(opp.Id) != null
                            && propertyMap.get(opp.Id).Property_Number_of_Units__c > 2) {
                        C2 = finalOAV * ((80 - postCloseLTV2) / 100);
                    } else if (opp.Qualifies_for_New_HomeOwner_Pricing__c == false && opp.Is_NOO__c == true) {
                        C2 = finalOAV * ((80 - postCloseLTV2) / 100);
                    } else if (opp.Qualifies_for_New_HomeOwner_Pricing__c == true && opp.Is_NOO__c == true) {
                        C2 = finalOAV * ((87.5 - postCloseLTV2) / 100);
                    }
                    finalC1Result = Math.min(500000, finalC1);
                } // HomeBuyer
                else if (opp.RecordTypeId == IDHomeBuyer || opp.RecordTypeId == IDHomeBuyerCanada) {
                    if (opp.Is_NOO__c == false) {
                        C2 = finalOAV * ((95 - postCloseLTV2) / 100);
                    } else if (opp.Is_NOO__c == true) {
                        C2 = finalOAV * ((87.5 - postCloseLTV2) / 100);
                    }
                    finalC1Result = Math.min(1000000, finalC1);
                }
                opp.OIP_Maximum__c = Math.min(finalC1Result, C2).round();
            }
        }
    }

    // Added to always round OIP: https://unison-technology.atlassian.net/browse/BUS-155110221
    public static void roundOIP(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        system.debug('starting to roundOIP');
        Decimal tempDecimal;
        if(oldMap == null) {
            for(Opportunity opp: opplist) {
                // OIP is greater than zero
                if(opp.Estimated_Funding_Amount__c != null && opp.Estimated_Funding_Amount__c > 0) {
                    system.debug('unrounded OIP: ' + opp.Estimated_Funding_Amount__c);
                    tempDecimal = opp.Estimated_Funding_Amount__c.round();
                    opp.Estimated_Funding_Amount__c = tempDecimal;
                    system.debug('rounded OIP: ' + opp.Estimated_Funding_Amount__c);
                }
            }
        } else {
            for(Opportunity opp: opplist) {
                // OIP changed and is greater than zero
                if(opp.Estimated_Funding_Amount__c != oldMap.get(opp.Id).Estimated_Funding_Amount__c
                        && opp.Estimated_Funding_Amount__c != null && opp.Estimated_Funding_Amount__c > 0) {
                    system.debug('unrounded OIP: ' + opp.Estimated_Funding_Amount__c);
                    tempDecimal = opp.Estimated_Funding_Amount__c.round();
                    opp.Estimated_Funding_Amount__c = tempDecimal;
                    system.debug('rounded OIP: ' + opp.Estimated_Funding_Amount__c);
                }
            }
        }
    } 
    
    // Added to always round Customer Transaction Fee: BUS-155109994
    public static void roundTransFee(List<Opportunity> newList){
        for(Opportunity opp: newList){
            opp.Customer_Transaction_Fee__c = (opp.Customer_Transaction_Fee__c != NULL) ? opp.Customer_Transaction_Fee__c.round(RoundingMode.HALF_UP) : null;
        }
    }    
    
    // https://unison-technology.atlassian.net/browse/BUS-155110475
    // Updated for: https://unison-technology.atlassian.net/browse/BUS-155111270
    public static void determineProgramFloor(List<Opportunity> oppList) {
        ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        for(Opportunity opp : oppList) {
            // Override Program Floor if not null
            if(opp.Program_Floor_Override__c != null) {
                opp.Program_Floor__c = opp.Program_Floor_Override__c;
            } else {
                // Proceed with the usual flow if there is no override
                // If Is_NOO = true, then 5 Year
                if(opp.Is_NOO__c && opp.Opportunity_Created_From_Lead__c) {
                    opp.Program_Floor__c = '5 Year';
                }
                // If HB and Is_NOO = false, then 3 Year
                else if(opp.RecordTypeId == IDHomeBuyer && !opp.Is_NOO__c && opp.Opportunity_Created_From_Lead__c) {
                    opp.Program_Floor__c = '3 Year';
                }
                // If HO and Is_NOO = true and Qualifies for New HomeOwner Pricing = true, then 3 Year
                else if(opp.RecordTypeId == IDHomeOwner && !opp.Is_NOO__c && opp.Opportunity_Created_From_Lead__c
                        && opp.Qualifies_for_New_HomeOwner_Pricing__c) {
                    opp.Program_Floor__c = '3 Year';
                }
                // If HO and Is_NOO = false and Qualifies for New HomeOwner Pricing = false and Equity less than origination = true, then 5 Year
                else if(opp.RecordTypeId == IDHomeOwner && !opp.Is_NOO__c && opp.Opportunity_Created_From_Lead__c
                        && !opp.Qualifies_for_New_HomeOwner_Pricing__c && opp.Equity_less_than_origination__c) {
                    opp.Program_Floor__c = '5 Year';
                }
                // If HO and Is_NOO = false and Qualifies for New HomeOwner Pricing = false and Equity less than origination = false, then 3 Year
                else if(opp.RecordTypeId == IDHomeOwner && !opp.Is_NOO__c && opp.Opportunity_Created_From_Lead__c
                        && !opp.Qualifies_for_New_HomeOwner_Pricing__c && !opp.Equity_less_than_origination__c) {
                    opp.Program_Floor__c = '3 Year';
                }
            }
        }
    }

    public static void validateClosingToIDD(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        Set<Id> oppIdstoValidate = new Set<Id>();  
        Set<Id> oppPostClosingIdstoValidate = new Set<Id>();         
        for(Opportunity o: newMap.values()){
            if(( (o.StageName == LABEL.Investment_Due_Diligence || o.StageName == LABEL.Final_Approval || o.StageName == LABEL.Offer) && oldMap.get(o.Id).StageName == LABEL.Closing)){oppIdstoValidate.add(o.Id);}
            if(  (o.StageName == LABEL.Closing || o.StageName == LABEL.Offer || o.StageName == LABEL.Final_Approval || o.StageName == LABEL.Investment_Due_Diligence ) && oldMap.get(o.Id).StageName == LABEL.Post_Closing ){ oppPostClosingIdstoValidate.add (o.Id); }
        }
        if(!oppIdstoValidate.isEmpty()){
            for(Opportunity o: [SELECT Id, (SELECT Id FROM Risk_Factors__r WHERE Status__c ='Completed' AND (Success_Factor__c = :LABEL.Closing OR Success_Factor__c = :LABEL.Post_Closing) )FROM Opportunity WHERE Id IN:oppIdstoValidate]){
                 if(o.Risk_Factors__r.size()>0){newMap.get(o.Id).addError(LABEL.Closing_Success_Factor_Error);}
            }
        }        
        if(!oppPostClosingIdstoValidate.isEmpty()){
            for(Opportunity o: [SELECT Id, (SELECT Id FROM Risk_Factors__r WHERE Status__c ='Completed' AND Success_Factor__c = :LABEL.Post_Closing )FROM Opportunity WHERE Id IN:oppPostClosingIdstoValidate]){
                if(o.Risk_Factors__r.size()>0){newMap.get(o.Id).addError(LABEL.Post_Closing_Success_Factor_Error);}
            }
        }
                
    }
        
    //MAD % logic.  Replaces Opportunity: MAD % Process Builder
    //This value defaults to the value in Maximum Authorized LTV. 
    //If Maximum Authorized LTV does not exist, for HO it is the larger % between 
    //Post-Close LTV and 70% with a cap at 75%, and for HB, it is Post-Close LTV.
    //ComputedMAD is included as an override but MAX Authorized LTV should still be the ultimate override.
    public static void updateMADPercent(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        for(Opportunity o: newOppList){
            if(o.StageName == LABEL.Investment_Due_Diligence || o.StageName == LABEL.Final_Approval || o.StageName == LABEL.Offer || o.StageName == LABEL.Closing ){
                decimal unroundedPostCloseLTV = (o.Final_OAV_Calculation__c != NULL && o.Final_OAV_Calculation__c != 0) ? (o.Post_Close_Mortgage_Debt__c / o.Final_OAV_Calculation__c)*100 : 0;
                //Max Authorized LTV is top level override for MAD
                if(o.Maximum_Authorized_LTV__c != NULL && o.Maximum_Authorized_LTV__c >0 ){ o.Mad__c = o.Maximum_Authorized_LTV__c; }
                //Computed MAD is secondary override for MAD
                else if(o.ComputedMAD__c != NULL && o.ComputedMAD__c > 0){ o.Mad__c = o.ComputedMAD__c; }
                //Otherwise, perform general calculations for MAD
                else{
                	//HB MAD %
                	if(o.RecordTypeId == IDHomeBuyer){
                      o.MAD__c = (o.Maximum_Authorized_LTV__c > 0 && o.Maximum_Authorized_LTV__c != NULL) ? o.Maximum_Authorized_LTV__c : unroundedPostCloseLTV;                      
                	}
                	//HO MAD %
                	if(o.RecordTypeId == IDHomeOwner){
                    	if(o.Qualifies_for_New_HomeOwner_Pricing__c == FALSE ){
                        	o.MAD__c = (o.Maximum_Authorized_LTV__c > 0 && o.Maximum_Authorized_LTV__c != NULL) ? o.Maximum_Authorized_LTV__c : Math.min(Math.max(unroundedPostCloseLTV, 70),75);                                                
                    	} 
                    	else if(o.Qualifies_for_New_HomeOwner_Pricing__c == TRUE ){
                        	o.MAD__c = (o.Maximum_Authorized_LTV__c > 0 && o.Maximum_Authorized_LTV__c < 85 && o.Maximum_Authorized_LTV__c != NULL) ? o.Maximum_Authorized_LTV__c : Math.min(Math.max(unroundedPostCloseLTV, 80),85);                                                
                    	}                      
                	}                    
                }                                
            }
            //Round MAD% to nearest .01
            o.MAD__c = o.MAD__c.setScale(2,System.RoundingMode.HALF_UP);            
        }
    }

    // https://unison-technology.atlassian.net/browse/BUS-155110786
    public static void assignDeclineReasons(List<Opportunity> opportunities) {
        Map<String, IA_Decline_Reasons__mdt> declineReasonsMap = getIADeclineReasonMap();
        for(Opportunity opp : opportunities) {
            List<String> reasonList = new List<String>();
            Set<String> uniquePSDeclineReasons = new Set<String>();
            Set<String> uniqueAALetterDeclineReasons = new Set<String>();
            if(opp.IA_Decline_Reason__c != null) {
                String declineReasonPS = '';
                String declineReasonAALetter = '';
                reasonList = opp.IA_Decline_Reason__c.split(';');
                for(String reason : reasonList) {
                    if(declineReasonsMap.get(reason) != null && declineReasonsMap.get(reason).PS_Decline_Reason__c != null) {
                        uniquePSDeclineReasons.add(declineReasonsMap.get(reason).PS_Decline_Reason__c);
                    }
                }
                uniqueAALetterDeclineReasons = prioritizeAALetterReasons(reasonList);

                for(String reason : uniquePSDeclineReasons) {
                    declineReasonPS += '\u2022 ' + reason + '\n';
                }

                for(String reason : uniqueAALetterDeclineReasons) {
                    declineReasonAALetter += '\u2022 ' + reason + '\n';
                }

                opp.PS_Decline_Reasons__c = declineReasonPS;
                opp.AA_Letter_Decline_Reasons__c = declineReasonAALetter;
            } else {
                opp.PS_Decline_Reasons__c = null;
                opp.AA_Letter_Decline_Reasons__c = null;
            }
        }
    }

    private static Set<String> prioritizeAALetterReasons(List<String> reasonList) {
        Map<String, IA_Decline_Reasons__mdt> declineReasonsMap = getIADeclineReasonMap();
        Set<String> finalAALetterReasons = new Set<String>();

        for(String reason : reasonList) {
            // Exit if we already have 4 reasons
            if(finalAALetterReasons.size() == 4)
                break;
            IA_Decline_Reasons__mdt currentReason = declineReasonsMap.get(reason);
            if(currentReason != null && currentReason.AA_Letter__c != null) {
                if(currentReason.AA_Letter_Priority__c == 1) {
                    finalAALetterReasons.add(currentReason.AA_Letter__c);
                }
            }
        }
        if(finalAALetterReasons.size() < 4) {
            for(String reason : reasonList) {
                // Exit if we already have 4 reasons
                if(finalAALetterReasons.size() == 4)
                    break;
                IA_Decline_Reasons__mdt currentReason = declineReasonsMap.get(reason);
                if(currentReason != null && currentReason.AA_Letter__c != null) {
                    if(currentReason.AA_Letter_Priority__c == 2) {
                        finalAALetterReasons.add(currentReason.AA_Letter__c);
                    }
                }
            }
        }
        return finalAALetterReasons;
    }

    @TestVisible private static Map<String, IA_Decline_Reasons__mdt> getIADeclineReasonMap() {
        Map<String, IA_Decline_Reasons__mdt> IADeclineReasonMap = new Map<String, IA_Decline_Reasons__mdt>();
        List<IA_Decline_Reasons__mdt> declineReasonsList = [SELECT MasterLabel, AA_Letter__c,
                Category__c, IA_Decline_Reasons__c, PS_Decline_Reason__c, AA_Letter_Priority__c FROM IA_Decline_Reasons__mdt];
        for(IA_Decline_Reasons__mdt metadata : declineReasonsList) {
            if(metadata.IA_Decline_Reasons__c != null) {
                IADeclineReasonMap.put(metadata.IA_Decline_Reasons__c, metadata);
            }
        }
        return IADeclineReasonMap;
    }

    // https://unison-technology.atlassian.net/browse/BUS-155110586
    public static void enforceIADeclineRequired(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Map<Id, Opportunity> rejectedOpportunities = new Map<Id, Opportunity>();
        for(Opportunity opp: newMap.values()) {
            Opportunity oldOpportunity = oldMap.get(opp.Id);
            if (oldOpportunity.IA_Decline_Status__c != opp.IA_Decline_Status__c && opp.IA_Decline_Status__c == 'Denied - Continue to IDD') {
                rejectedOpportunities.put(opp.Id, opp);
            }
        }

        if (!rejectedOpportunities.isEmpty()) {
            List<Id> processInstanceIds = new List<Id>{};

            for (Opportunity opp : [SELECT
                                (SELECT ID  FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1)
                                FROM Opportunity WHERE ID IN : rejectedOpportunities.keySet()]) {
                processInstanceIds.add(opp.ProcessInstances[0].Id);
            }

            for (ProcessInstance pi : [SELECT TargetObjectId,
            (SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 )
            FROM ProcessInstance WHERE Id IN :processInstanceIds
            ORDER BY CreatedDate DESC]) {
                if ((pi.Steps[0].Comments == null || pi.Steps[0].Comments.trim().length() == 0)) {
                    rejectedOpportunities.get(pi.TargetObjectId).addError(
                            'Please provide a rejection reason');
                }
            }
        }
    }

    // https://unison-technology.atlassian.net/browse/BUS-155111228
    public static void validateOIPConfirmed(Map<Id, Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ID IDHomeBuyerCanada = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer Canada').getRecordTypeId();

        for(Opportunity opp : oppList.values()) {
            // Validate that OIP Confirmed is being checked at the proper stage
            if(opp.OIP_Confirmed__c && opp.OIP_Confirmed__c != oldMap.get(opp.Id).OIP_Confirmed__c) {
                if(opp.RecordTypeId == IDHomeOwner) {
                    if(opp.StageName != 'Offer') {
                        opp.addError('OIP cannot be confirmed outside Offer stage');
                    }
                } else if(opp.RecordTypeId == IDHomeBuyer || opp.RecordTypeId == IDHomeBuyerCanada) {
                    if(opp.StageName != 'Closing') {
                        opp.addError('OIP cannot be confirmed outside Closing stage');
                    }
                }
            }
        }
    }

    // https://unison-technology.atlassian.net/browse/BUS-155111228
    public static void undoOIPConfirmed(Map<Id, Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ID IDHomeBuyerCanada = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer Canada').getRecordTypeId();

        for(Opportunity opp : oppList.values()) {
            String newStage = opp.StageName;
            String oldStage = oldMap.get(opp.Id).StageName;
            // Undo/Uncheck OIP Confirmed when going back to IDD from Offer, Closing or Post-Closing
            if((oldStage == 'Offer' || oldStage == 'Closing' || oldStage == 'Post-Closing') && opp.StageName == 'Investment Due Diligence') {
                opp.OIP_Confirmed__c = false;
            }
        }
    }
 
}