/**
*  About
*  -----
*  Author: Cloud Mine Consulting
*  Create date: 8/31/2017
*
*  Details
*  -----
*  Handler Class for Personal Credit Report triggers
*
*  Update History
*  -----
*
*  Issues / TODOs
*  -----
*
**/

public class PCR_trigger_handler {
    
    public static void bUpdate(Map<Id, LASERCA__Personal_Credit_Report__c> newPCRMap, Map<Id, LASERCA__Personal_Credit_Report__c> oldPCRMap ){
        Set<Id> LeadIdSet = new Set<Id>();
        Map<Id, LASERCA__Personal_Credit_Report__c> PCRsToProcess = new Map<Id, LASERCA__Personal_Credit_Report__c>();
        Map<Id, Id> applicationToOppMap = setApplicationsToOppMap(newPCRMap);
        
        for(LASERCA__Personal_Credit_Report__c PCR :newPCRMap.values()){
            system.debug('++ bUpdate: ' + PCR.Opportunity__c);
            system.debug('++ bUpdate:Application__r.Opportunity__r.Id ' + PCR.Application__r.Opportunity__c);
            system.debug('++ bUpdate:Application__c ' + PCR.Application__c);
            
            if(PCR.Application__c != null) {
                PCR.Opportunity__c = applicationToOppMap.get(PCR.Application__c);
            }
            
            if(PCR.LASERCA__Lead__c != NULL && oldPCRMap.get(PCR.Id).LASERCA__Lead__c == NULL ){
                LeadIdSet.add(PCR.LASERCA__Lead__c);
                PCRsToProcess.put(PCR.Id, PCR);
            }
            if(PCR.LASERCA__Lead__c != NULL && PCR.Credit_Pre_Qualification_Status__c != oldPCRMap.get(PCR.Id).Credit_Pre_Qualification_Status__c ){
                LeadIdSet.add(PCR.LASERCA__Lead__c);
                PCRsToProcess.put(PCR.Id, PCR);
            }
            
        }
        if(!LeadIdSet.isEmpty()){
            setLeadRTFieldOnPCR(PCRsToProcess, LeadIdSet);
        }
    }
    
    public static void aInsert(Map<Id, LASERCA__Personal_Credit_Report__c> newPCRMap)
    {
        Set<Id> LeadIdSet = new Set<Id>();
        Set<Id> OppIdSet = new Set<Id>();
        
        for(LASERCA__Personal_Credit_Report__c PCR: newPCRMap.values())
        {system.debug('++ aInsert: ' + PCR.Opportunity__c);
         system.debug('++ aInsert:Application__r.Opportunity__r.Id ' + PCR.Application__r.Opportunity__c);
         system.debug('++ aInsert:Application__c ' + PCR.Application__c);
         if(PCR.LASERCA__Lead__c != NULL)
         {
             LeadIdSet.add(PCR.LASERCA__Lead__c);
             
         }
         
         if(PCR.Opportunity__c != NULL)
         {
             OppIdSet.add(PCR.Opportunity__c);
         }
         /*
if(PCR.Application__c!=null && PCR.Application__r.Opportunity__r.Id!=null){
PCR.Opportunity__c=PCR.Application__r.Opportunity__r.Id;
}

*/
         
        }
        
        if(!LeadIdSet.isEmpty() && OppIdSet.isEmpty())
        {
            rollupPCRToLead(LeadIdSet);
        }
        if(!OppIdSet.isEmpty())
        {
            rollupPCRToOpp(OppIdSet);
            MoveTradeAccountToPCR(newPCRMap,OppIdSet);
        }
    }
    
    public static void aUpdate(Map<Id, LASERCA__Personal_Credit_Report__c> newPCRMap, Map<Id, LASERCA__Personal_Credit_Report__c> oldPCRMap)
    {
        Set<Id> LeadIdSet = new Set<Id>();
        Set<Id> OppIdSet = new Set<Id>();
        Set<Id> oppsToProcess = new Set<Id>();
        Set<Id> pcrIds = new Set<Id>();
        Set<Id> pcrIds2 = new Set<Id>();
        system.debug('++ aUpdate:newPCRMap ' + newPCRMap);
        system.debug('++ aUpdate:oldPCRMap ' + oldPCRMap);
        Map<Id, LASERCA__Personal_Credit_Report__c> newPCRMapForTAs = new Map<Id, LASERCA__Personal_Credit_Report__c>();
        for(LASERCA__Personal_Credit_Report__c PCR: newPCRMap.values())
        {system.debug('++ aUpdate: ' + PCR.Opportunity__c);
         
         system.debug('++ aUpdate:Application__c ' + PCR.Application__c);
         system.debug('++ aUpdate:Application__r.Opportunity__c ' + PCR.Application__r.Opportunity__c);
         
         
         if((PCR.LASERCA__Lead__c != NULL && PCR.Sum_of_Debt_Payments__c != oldPCRMap.get(PCR.Id).Sum_of_Debt_Payments__c)
            || (PCR.LASERCA__Lead__c != NULL && PCR.Sum_of_Debt_to_be_Paid_Off__c != oldPCRMap.get(PCR.Id).Sum_of_Debt_to_be_Paid_Off__c)
            || (PCR.LASERCA__Lead__c != NULL && oldPCRMap.get(PCR.Id).LASERCA__Lead__c == NULL) )
         {
             LeadIdSet.add(PCR.LASERCA__Lead__c);
             OppIdSet.add(PCR.Opportunity__c);
         }
         
         if((PCR.Opportunity__c != NULL && PCR.Sum_of_Debt_Payments__c != oldPCRMap.get(PCR.Id).Sum_of_Debt_Payments__c)
            || (PCR.Opportunity__c != NULL && oldPCRMap.get(PCR.Id).Opportunity__c == NULL))
         {
             // OppIdSet.add(PCR.Opportunity__c);
         }
         
         if(PCR.Opportunity__c != Null && oldPCRMap.get(PCR.Id).Opportunity__c == Null){
             pcrIds.add(PCR.Id);
             newPCRMapForTAs.put(PCR.Id, PCR);
         }
         if(PCR.Opportunity__c == Null && PCR.LASERCA__Lead__c != Null && oldPCRMap.get(PCR.Id).LASERCA__Lead__c == Null){
             pcrIds2.add(PCR.Id);
         }
         
         if(PCR.Opportunity__c != null) {
             oppsToProcess.add(PCR.Opportunity__c);
             OppIdSet.add(PCR.Opportunity__c);
         }
         /*
if(PCR.Application__c!=null && PCR.Application__r.Opportunity__r.Id!=null){
PCR.Opportunity__c=PCR.Application__r.Opportunity__r.Id;
}*/
        }
        
        // Brad: Added condition to only do Lead roll-up if on Lead
        if(!LeadIdSet.isEmpty() && OppIdSet.isEmpty())
        {
            rollupPCRToLead(LeadIdSet);
        }
        
        // added for Opportunity updates: https://unison-technology.atlassian.net/browse/BUS-155109328
        if(!oppsToProcess.isEmpty()) {
            updateOpportunityWithLatestPCR(oppsToProcess);
        }
        
        if(!OppIdSet.isEmpty())
        {
            rollupPCRToOpp(OppIdSet);
        }
        
        // Uncommented for ticket: https://unison-technology.atlassian.net/browse/BUS-155109548
        if(pcrIds.size() > 0){
            TradeAccountTriggerHandler.CountofTrdAccPay(pcrIds);
            if (!LeadConversionProcess.conversionProcess) {
                TradeAccountTriggerHandler.FindTradeAccountChanges(
                    [SELECT Id, LASERCA__Account_Identifier__c, LASERCA__Personal_Credit_Report__c, Trade_Account_Changes__c, LASERCA__Account_Balance__c, 
                     Amount_To_Pay_Off2__c, LASERCA__Account_Reported_Date__c, Exclude__c
                     FROM LASERCA__Trade_Accounts__c WHERE LASERCA__Personal_Credit_Report__c IN :pcrIds]
                );
            }
        }
        if(pcrIds2.size() > 0){
            TradeAccountTriggerHandler.FindTradeAccountChanges(
                [SELECT Id, LASERCA__Account_Identifier__c, LASERCA__Personal_Credit_Report__c, Trade_Account_Changes__c, LASERCA__Account_Balance__c, 
                 Amount_To_Pay_Off2__c, LASERCA__Account_Reported_Date__c, Exclude__c
                 FROM LASERCA__Trade_Accounts__c WHERE LASERCA__Personal_Credit_Report__c IN :pcrIds2]
            );
        }
        
        if (newPCRMapForTAs.size() > 0) {
            if (!LeadConversionProcess.conversionProcess)
                MoveTradeAccountToPCR(newPCRMapForTAs, OppIdSet);
        }
    }
    
    public static void aDelete(Map<Id, LASERCA__Personal_Credit_Report__c> oldPCRMap)
    {
        Set<Id> LeadIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        
        for(LASERCA__Personal_Credit_Report__c PCR: oldPCRMap.values())
        {
            if(PCR.LASERCA__Lead__c != NULL)
            {
                LeadIdSet.add(PCR.LASERCA__Lead__c);
                
            }
            
            if(PCR.Opportunity__c != NULL)
            {
                oppIdSet.add(PCR.Opportunity__c);
            }
        }
        
        if(!LeadIdSet.isEmpty() && OppIdSet.isEmpty())
        {
            rollupPCRToLead(LeadIdSet);
        }
        
        // Brad commented out
        // if(!oppIdSet.isEmpty())
        // {
        //     rollupPCRToOpp(oppIdSet);
        // }
    }
    
    public static void aUndelete(Map<Id, LASERCA__Personal_Credit_Report__c> newPCRMap)
    {
        Set<Id> LeadIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        
        
        for(LASERCA__Personal_Credit_Report__c PCR: newPCRMap.values())
        {
            if(PCR.LASERCA__Lead__c != NULL)
            {
                LeadIdSet.add(PCR.LASERCA__Lead__c);
                
            }
            
            if(PCR.Opportunity__c != NULL)
            {
                oppIdSet.add(PCR.Opportunity__c);
            }
        }
        
        if(!LeadIdSet.isEmpty() && OppIdSet.isEmpty())
        {
            rollupPCRToLead(LeadIdSet);
        }
        // Brad commented out
        // if(!oppIdSet.isEmpty())
        // {
        //     rollupPCRToOpp(oppIdSet);
        // }
    }
    
    public static void setLeadRTFieldOnPCR(Map<Id, LASERCA__Personal_Credit_Report__c> PCRsToProcess, Set<Id> LeadIdSet){
        Map<Id,Lead> leadMap = new Map<Id, Lead>();
        boolean singlepull=false;
        boolean coapp;
        string status;
        string tier2CreditEval;
        for(Lead l: [SELECT RecordType.Name,Credit_Pre_Qualification_Status__c,Is_there_Co_App__c FROM Lead WHERE Id IN: LeadIdSet]){
            leadMap.put(l.Id,l);
        }
        for(LASERCA__Personal_Credit_Report__c PCR: PCRsToProcess.values()){
            PCR.Lead_Record_Type__c = leadMap.get(PCR.LASERCA__Lead__c).RecordType.Name;
            if(PCR.LASERCA__Credit_Score_Experian__c == null && PCR.LASERCA__Credit_Score_Equifax__c== null && PCR.LASERCA__Credit_Score_TransUnion__c!= null){
                singlepull = true;
            }
            coapp = leadMap.get(PCR.LASERCA__Lead__c).Is_there_Co_App__c;
            system.debug('tier1CreditLogic Result---' + tier1CreditLogic(PCR,singlepull));
            if(singlepull){
                status = creditPreQual(PCR,coapp);                    
            }           
            if(singlepull & status == 'Declined (Single score)'){             
                leadMap.get(PCR.LASERCA__Lead__c).Credit_Pre_Qualification_Status__c = 'Declined (Single score)';
                PCR.Credit_Pre_Qualification_Status__c = 'Declined (Single score)';      
            }else{
                if(tier1CreditLogic(PCR,singlepull) != 'Escalate to Tier 2'){
                    PCR.Credit_Pre_Qualification_Status__c = tier1CreditLogic(PCR,singlepull);
                    leadMap.get(PCR.LASERCA__Lead__c).Credit_Pre_Qualification_Status__c = tier1CreditLogic(PCR,singlepull);
                }
                else{
                    System.debug('This is singlepull$123' +singlepull);
                    tier2CreditEval = ProcessTradeLines.tier2CreditEval(PCR.Id,singlepull)[0];
                    PCR.Credit_Decision_Result_1__c = ProcessTradeLines.tier2CreditEval(PCR.Id,singlepull)[1];
                    PCR.Credit_Decision_Result_2__c = ProcessTradeLines.tier2CreditEval(PCR.Id,singlepull)[2];
                    PCR.Credit_Decision_Result_3__c = ProcessTradeLines.tier2CreditEval(PCR.Id,singlepull)[3];
                    PCR.Credit_Decision_Result_4__c = ProcessTradeLines.tier2CreditEval(PCR.Id,singlepull)[4];
                    PCR.Credit_Decision_Result_5__c = ProcessTradeLines.tier2CreditEval(PCR.Id,singlepull)[5];
                    System.debug('This is tier2CreditEval$123' +ProcessTradeLines.tier2CreditEval(PCR.Id,singlepull)[0]);
                    
                    if(tier2CreditEval == 'Approved' || tier2CreditEval =='Approved (Single score)'){
                        PCR.Credit_Pre_Qualification_Status__c = 'Escalated';
                    	leadMap.get(PCR.LASERCA__Lead__c).Credit_Pre_Qualification_Status__c = 'Escalated';    
                    }else{
						leadMap.get(PCR.LASERCA__Lead__c).Credit_Pre_Qualification_Status__c = tier2CreditEval;                       
                    }
                    PCR.Tier_2_Credit_Decision__c = tier2CreditEval;
                    
                }
            }
            //leadMap.get(PCR.LASERCA__Lead__c).Credit_Pre_Qualification_Status__c = PCR.Credit_Pre_Qualification_Status__c;
            leadMap.get(PCR.LASERCA__Lead__c).LASERCA__File_Number__c = PCR.LASERCA__File_Number__c;
            leadMap.get(PCR.LASERCA__Lead__c).Latest_PCR_SSN__c = PCR.LASERCA__Confirming_Social_Security_Number__c;
            
        }
        update leadMap.values();
    }
    
    public static string tier1CreditLogic(LASERCA__Personal_Credit_Report__c PCR,boolean singlepull)
    {
        if(PCR.LASERCA__Credit_Score_Median__c < 300 ||(PCR.LASERCA__Co_Applicant_Credit_Score_Median__c != 0 && PCR.LASERCA__Co_Applicant_Credit_Score_Median__c <300)){
            return 'No Match';
        }
        else if(PCR.LASERCA__Credit_Score_Median__c  >=700
                && (PCR.LASERCA__Co_Applicant_Credit_Score_Median__c == 0 || PCR.LASERCA__Co_Applicant_Credit_Score_Median__c >= 700)
                && PCR.LASERCA__Bankruptcy__c == FALSE
                && PCR.LASERCA__Prior_Bankruptcy__c == FALSE
                && PCR.HO_Disqualifying_Public_Record__c == FALSE
                && (PCR.Number_of_5_Yr_Disqualifying_Mortgages__c == 0
                    || PCR.Number_of_5_Yr_Disqualifying_Mortgages__c == NULL)
                && (PCR.LASERCA__TotalLiabilityPastDue__c == NULL
                    || PCR.LASERCA__TotalLiabilityPastDue__c==0 ))
        {
            system.debug('Im heretier$123');
            if(PCR.LASERCA__Co_Applicant_Credit_Score_Median__c == 0 || PCR.LASERCA__Co_Applicant_Credit_Score_Median__c >= 700){
                if(!singlepull){
                    system.debug('Im here1$123');
                    return 'Approved';
                }else{
                    system.debug('Im here2$123');
                    return 'Approved (Single score)';
                }
            }else{
                if(PCR.LASERCA__Co_Applicant_Credit_Score_Median__c <= 700){
                    if(PCR.Lead_Record_Type__c == 'HomeOwner'){
                        if(!singlepull){
                            return 'Declined';
                        }else{
                            return 'Declined (Single score)';
                        }  
                    }
                    if(PCR.Lead_Record_Type__c == 'HomeBuyer' && PCR.LASERCA__Co_Applicant_Credit_Score_Median__c < 620){
                        if(!singlepull){
                            return 'Declined';
                        }else{
                            return 'Declined (Single score)';
                        }        
                    }else{
                        return 'Escalate to Tier 2';   
                    }
                }else{
                    system.debug('Im here4$123');                    
                    return 'Escalate to Tier 2';
                }
            }              
        }   
        else{
            if(PCR.Lead_Record_Type__c == 'HomeBuyer' && PCR.HB_Disqualifying_Public_Record__c == FALSE
               && PCR.Number_of_2_Yr_Disqualifying_Mortgages__c == 0 && PCR.LASERCA__Bankruptcy__c == FALSE
               && PCR.LASERCA__Prior_Bankruptcy__c == FALSE && PCR.LASERCA__Credit_Score_Median__c >= 680 &&(PCR.LASERCA__Co_Applicant_Credit_Score_Median__c == 0 ||PCR.LASERCA__Co_Applicant_Credit_Score_Median__c >= 680)){
                   if(!singlepull){
                       return 'Approved';
                   }else{
                       return 'Approved (Single score)';
                   }             
               }else{
                   if(PCR.Lead_Record_Type__c == 'HomeBuyer' && PCR.LASERCA__Credit_Score_Median__c < 620 || (PCR.LASERCA__Co_Applicant_Credit_Score_Median__c < 620
                                                                                                              && PCR.LASERCA__Co_Applicant_Credit_Score_Median__c != 0) || PCR.HB_Disqualifying_Public_Record__c
                      || PCR.Number_of_2_Yr_Disqualifying_Mortgages__c > 0){
                          if(!singlepull){
                              return 'Declined';
                          }else{
                              return 'Declined (Single score)';
                          }  
                      }
               }
            if(PCR.Lead_Record_Type__c == 'HomeOwner' &&
               (PCR.LASERCA__Credit_Score_Median__c < 700
                || (PCR.LASERCA__Co_Applicant_Credit_Score_Median__c < 700
                    && PCR.LASERCA__Co_Applicant_Credit_Score_Median__c == 0)
                || PCR.HO_Disqualifying_Public_Record__c
                || PCR.Number_of_5_Yr_Disqualifying_Mortgages__c > 0))
            {
                if(!singlepull){
                    return 'Declined';
                }else{
                    return 'Declined (Single score)';
                }  
            }
            else{
                return 'Escalate to Tier 2';
            }
        }
        return NULL;      
    }
    
    //This class looks for new credit prequalification 
    public static string creditPreQual(LASERCA__Personal_Credit_Report__c PCR,boolean coapp)
    {
        string status;
        if(!coapp){
            if(PCR.LASERCA__Credit_Score_Median__c > 635){
                status = 'Approved (Single score)';     
            }else{
                status = 'Declined (Single score)';
            }
        }
        else{
            //check for lower credit score between co-app and applicant
            decimal lowerscore = Math.min(PCR.LASERCA__Credit_Score_Median__c, PCR.LASERCA__Co_Applicant_Credit_Score_Median__c);
            if(lowerscore > 635){
                status = 'Approved (single score)';     
            }else{
                status = 'Declined (Single score)';
            }       
        }       
        return status;
    }
    
    public static void rollupPCRToLead(Set<Id> LeadIdSet)
    {
        List<Lead> leadsToUpdate = new List<Lead>();
        /*4/2/2019 Sundar Subramaniam - Max_Credit_Score_PCR__c deleted from query for Data Model Cleanup*/
        List<Lead> leadList =
            [
                SELECT Sum_of_Debt_Payments__c,Personal_Credit_Report__c ,Sum_of_Debt_to_be_Paid_Off__c,
                (
                    SELECT Sum_of_Debt_Payments__c,Sum_of_Debt_to_be_Paid_Off__c
                    FROM LASERCA__Personal_Credit_Reports__r
                )
                FROM Lead
                WHERE Id IN:LeadIdSet
            ];
        
        for(Lead l: leadList)
        {
            decimal sumOfDebts = 0;
            decimal sumOfDebtPayoff = 0;
            
            for(LASERCA__Personal_Credit_Report__c PCR: l.LASERCA__Personal_Credit_Reports__r)
            {
                if(PCR.Id == l.Personal_Credit_Report__c )
                {
                    //We only consider the PCR whose ID matches the Lead's Max_Credit_Score_PCR__c field
                    sumOfDebts += (PCR.Sum_of_Debt_Payments__c != NULL) ? PCR.Sum_of_Debt_Payments__c :0;
                    sumOfDebtPayoff += (PCR.Sum_of_Debt_to_be_Paid_Off__c != NULL) ? PCR.Sum_of_Debt_to_be_Paid_Off__c :0;
                }
            }
            
            leadsToUpdate.add( new Lead(Id = l.Id, Sum_of_Debt_Payments__c = sumOfDebts, Sum_of_Debt_to_be_Paid_Off__c = sumOfDebtPayoff ) );
        }
        
        if(!leadsToUpdate.isEmpty())
        {
            update leadsToUpdate;
        }
    }
    
    public static void rollupPCRToOpp(Set<Id> oppIdSet)
    {   system.debug('++ rollupPCRToOpp ');
     List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
     /*4/2/2019 Sundar Subramaniam - Max_Credit_Score_PCR__c deleted from query for Data Model Cleanup*/
     List<Opportunity> oppList =
         [
             SELECT Sum_of_Debt_Payments__c, Personal_Credit_Report__c,
             (
                 SELECT Sum_of_Debt_Payments__c,LASERCA__Co_Applicant_Credit_Score_Median__c,LASERCA__Credit_Score_Median__c,CreatedDate
                 FROM Personal_Credit_Reports__r ORDER BY CreatedDate DESC
             )
             FROM Opportunity
             WHERE Id IN :oppIdSet
         ];
     
     for(Opportunity opp : oppList)
     {
         Decimal fico = 0;
         //for(LASERCA__Personal_Credit_Report__c pcr : opp.Personal_Credit_Reports__r)
         //{
         //if(pcr.LASERCA__Co_Applicant_Credit_Score_Median__c == NULL ||pcr.LASERCA__Co_Applicant_Credit_Score_Median__c == 0 || (pcr.LASERCA__Credit_Score_Median__c < pcr.LASERCA__Co_Applicant_Credit_Score_Median__c) ){
         //Got latest PCR in query above and set FICO score based on latest PCR. May rethink this later.
         if(!opp.Personal_Credit_Reports__r.isEmpty()) { 
             if(opp.Personal_Credit_Reports__r[0].LASERCA__Co_Applicant_Credit_Score_Median__c == NULL ||opp.Personal_Credit_Reports__r[0].LASERCA__Co_Applicant_Credit_Score_Median__c == 0 || (opp.Personal_Credit_Reports__r[0].LASERCA__Credit_Score_Median__c < opp.Personal_Credit_Reports__r[0].LASERCA__Co_Applicant_Credit_Score_Median__c) ){
                 fico = opp.Personal_Credit_Reports__r[0].LASERCA__Credit_Score_Median__c;
             }else{
                 fico = opp.Personal_Credit_Reports__r[0].LASERCA__Co_Applicant_Credit_Score_Median__c;
             }
         }
         //}
         opportunitiesToUpdate.add( new Opportunity(Id = opp.Id, FICO__c = fico));
     }
     
     if(!opportunitiesToUpdate.isEmpty())
     {
         update opportunitiesToUpdate;
     }
    }
    
    public static void updateOpportunityWithLatestPCR(Set<Id> oppIdSet) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Opportunity> oppList =
            [
                SELECT Sum_of_Debt_Payments__c, Personal_Credit_Report__c,
                (
                    SELECT Sum_of_Debt_Payments__c,LASERCA__Co_Applicant_Credit_Score_Median__c,LASERCA__Credit_Score_Median__c,CreatedDate
                    FROM Personal_Credit_Reports__r ORDER BY CreatedDate DESC
                )
                FROM Opportunity
                WHERE Id IN :oppIdSet
            ];
        
        for(Opportunity opp : oppList)
        {
            system.debug('++ related list: ' + opp.Personal_Credit_Reports__r);
            if(!opp.Personal_Credit_Reports__r.isEmpty()) {
                Id latestPCR = opp.Personal_Credit_Reports__r[0].Id;
                system.debug('++ related list: ' + opp.Personal_Credit_Reports__r);
                opportunitiesToUpdate.add( new Opportunity(Id = opp.Id, Personal_Credit_Report__c = latestPCR) );
            }
        }
        
        if(!opportunitiesToUpdate.isEmpty())
        {
            update opportunitiesToUpdate;
        }
    }
    
    private static Map<Id, Id> setApplicationsToOppMap(Map<Id, LASERCA__Personal_Credit_Report__c> pcrMap)
    {
        Map<Id, Id> appOppMap = new Map<Id, Id>();
        Set<Id> applicationIds = new Set<Id>();
        for(String pcrId : pcrMap.keySet()) {
            if(pcrMap.get(pcrId).Application__c != null)
            {
                applicationIds.add(pcrMap.get(pcrId).Application__c);
            }
        }
        for(Application__c app : [SELECT Id, Opportunity__c FROM Application__c
                                  WHERE Id IN : applicationIds])
        {
            if(app.Opportunity__c != null)
            {
                appOppMap.put(app.Id, app.Opportunity__c);
            }
        }
        return appOppMap;
    }
    
    //Set the right Personal Credit Report on the New Trade Account
    public static void MoveTradeAccountToPCR(Map<Id, LASERCA__Personal_Credit_Report__c> pcrMap, Set<Id> oppIdSet) {
        
        string query = 'SELECT LASERCA__Personal_Credit_Report__r.Opportunity__c';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('LASERCA__Trade_Accounts__c').getDescribe().Fields.getMap();
        for (Schema.SObjectField ft : fMap.values()){
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if (fd.isCreateable()) {
                query += ', ' + fd.getName();
            }
        }
        query += ', (SELECT Id, Trade_Account__c FROM Requirements__r)';
        query += ' FROM LASERCA__Trade_Accounts__c' +
            ' WHERE LASERCA__Account_Identifier__c = null AND Manual_TA_Copied__c != true AND LASERCA__Personal_Credit_Report__r.Opportunity__c IN :oppIdSet';
        System.debug(query);
        
        List<LASERCA__Trade_Accounts__c> manualTAs = Database.query(query);
        List<LASERCA__Trade_Accounts__c> cloneTAs = new List<LASERCA__Trade_Accounts__c>();
        List<Current_Conditions__c> reqsToUpdate = new List<Current_Conditions__c>();
        for (LASERCA__Trade_Accounts__c manualTA : manualTAs) {
            LASERCA__Trade_Accounts__c cloneTA = manualTA.clone();
            for (LASERCA__Personal_Credit_Report__c pcr : pcrMap.values()) {
                if (pcr.Opportunity__c == manualTA.LASERCA__Personal_Credit_Report__r.Opportunity__c) {
                    cloneTA.LASERCA__Personal_Credit_Report__c = pcr.Id;
                }
            }
            cloneTAs.add(cloneTA);
            manualTA.Manual_TA_Copied__c = true;
            for (Current_Conditions__c req : manualTA.Requirements__r) {
                req.Trade_Account__r = cloneTA;
                reqsToUpdate.add(req);
            }
        }
        
        update manualTAs;
        insert cloneTAs;
        for (Current_Conditions__c req : reqsToUpdate) {
            req.Trade_Account__c = req.Trade_Account__r.Id;
        }
        update reqsToUpdate;
    }
    
}