/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Cloud Nerd
 *  Create date: Sun Jul 17 2016
 *   Details
 *  -------------------------------------------------------------------------
 *  Apex class to handle all the events raised by OpportunityTrigger
 *   Update History
 *
 *  -Cloud Mine Consulting 7/11/17 --- deprecated Validation methods
 *  Issues / TODOs
 *  ----------------------------------------------------------------------------
 *  Neeraja Cherukuri 3/6/2019
 *      -> Modified the OpportunityTriggerHandler+OpportunityUtilityClass+OpportunityFormulasCalculations
 *  Sundar 04/26/2019 
 *      -> added new method createOpportunityProducts()
 *      -> modified handleAfterInsert method to call createOpportunityProducts for lead converted Opportunities
 *  Adam Zuckerman 5/22/2019
 *      -> Added CopyRecordType() method from production to handleBeforeInsert and handleBeforeUpdate
 *      -> Added DelightedIntegration() method from production. Added to handleAfterUpdate.
        -> Test Automation-CK2
 * ---------------------------------------------------------------------------
 ************************************************************************************/
public class OpportunityTriggerHandler
{

    public static boolean createdReqDMDflag = false;
    public static boolean createdReqflag = false;
    public static boolean createdReqInflag = false;
    public static boolean createdRequirements  = false;
    public static boolean emailSentPsCommunicationDMACriterias  = false;


    //Used to make sure duplicate NPM records are not created twice due to workflow/PB updates
    //causing triggers to fire twice
    private static set<Id> alreadyCreatedNPMOppIDSet = new Set<Id>();
    
    //keep track of Opportunities that already had IDD requirements added
    private static set<Id> alreadyCreatedIDDReqsSet = new Set<Id>();
    
    //keep track of Opportunities that already had Offer requirements added
    private static set<Id> alreadyCreatedOfferReqsSet = new Set<Id>();
    
    //keep track of Opportunities that already had Closing requirements added
    private static set<Id> alreadyCreatedClosingReqsSet = new Set<Id>();    

    //keep track of Opportunities that already had Post-Closing requirements added
    private static set<Id> alreadyCreatedPostClosingReqsSet = new Set<Id>();   
    
    public static void handleBeforeInsert(List<Opportunity> newList)
    {
        if (TriggrUtility.needsToCalculateFormulas) {
        assignRecordTypeOnCreation(newList); // added for: https://unison-technology.atlassian.net/browse/BUS-155110114
        OpportunityService.ltvformulas(newList);
        OpportunityService.oipFormulas(newList); // Update OIP Maximum
        OpportunityService.roundOIP(newList, null);
        OpportunityService.roundTransFee(newList);
        FindNulls.populateNulls('Opportunity', newList);
        CopyRecordType(newList);
        TriggrUtility.needsToCalculateFormulas = false;
        }
        List<Opportunity> declineReasonOpps = new List<Opportunity>(); // https://unison-technology.atlassian.net/browse/BUS-155110786
        {//Currency to words BUS-155109631 Edson Garcia
            for (Opportunity c : newList) {
                if (c.Estimated_Funding_Amount__c != null && c.Estimated_Funding_Amount__c >= 0) {
                    Long n = c.Estimated_Funding_Amount__c.longValue();
                    String cleanVal = String.valueOf(c.Estimated_Funding_Amount__c);
                    String cents = '';
                    if(cleanVal.contains('.')){
                        cleanVal = cleanVal.right(2);
                        cents = ConvertCurrencyToWords.english_number(Integer.valueOf(cleanVal));
                    }
                    string amo = ConvertCurrencyToWords.english_number(n);
                    string amo1 = amo.remove(',');
                    String lastWord = amo1.substringAfterLast(' ');
                    if(cents != ''){
                        if(cents == 'One' || cents == 'one'){
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollars' + ' and ' + cents + ' Cent';
                        }else{
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollars' + ' and ' + cents + ' Cents';
                        }
                    }else{
                        if(amo1 == 'One' || amo1 == 'one'){
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollar';
                        }else{
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollars';
                        }
                    }
                } else {
                    c.OIP_Numbers_to_Words__c = null;
                }

                // https://unison-technology.atlassian.net/browse/BUS-155110786
                if(c.IA_Decline_Reason__c != null) {
                    declineReasonOpps.add(c);
                }
            }
            // https://unison-technology.atlassian.net/browse/BUS-155110786
            if(!declineReasonOpps.isEmpty()) {
                OpportunityService.assignDeclineReasons(declineReasonOpps);
            }
        }//Currency to words

        SetQualifiesforNewHOPricing(newList);
    }

    public static void handleAfterInsert(List<Opportunity> newList)
    {

        /*if(!createdReqInflag)
        {
         OpportunityUtilityClass.createRequirements(newlist);
         createdReqInflag = True;
        }*/
        List<Opportunity> leadConvertedOpportunities = new List<Opportunity>();
        for(Opportunity oppObj : newList) {
            if(oppObj.Opportunity_Created_From_Lead__c == true) {
                leadConvertedOpportunities.add(oppObj);
            }
        }
        System.debug('leadConvertedOpportunities==>'+leadConvertedOpportunities);
        createOpportunityProducts(leadConvertedOpportunities);
        // OpportunityChatterUpdates.doChatterUpdates(newList);


    }

    public static void handleBeforeUpdate(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap)
    {
        if (TriggrUtility.needsToCalculateFormulas) {
        OpportunityService.validateClosingToIDD(newMap,oldMap); //prevent moving back to IDD or Final Approval from Closing when Closing Success Factor is Completed
        OpportunityService.finaloavFormulas(newMap.values()); // Update final OAV
        OpportunityService.dtiFormulas(newMap.values()); // Update DTI
        OpportunityUtilityClass.opportunitySFGating(newMap.values(), oldMap);
        OpportunityService.ltvformulas(newMap.values()); // Update LTV
        OpportunityService.oipFormulas(newMap.values()); // Update OIP Maximum
        OpportunityService.determineProgramFloor(newMap.values());
        OpportunityService.roundOIP(newMap.values(), oldMap);
        OpportunityService.roundTransFee(newMap.values());
        FindNulls.populateNulls('Opportunity', newMap);
        CopyRecordType(newMap.values());
        OpportunityService.updateMADPercent(newMap.values(), oldMap);    
        OpportunityService.enforceIADeclineRequired(newMap, oldMap); // https://unison-technology.atlassian.net/browse/BUS-155110586
        OpportunityService.validateOIPConfirmed(newMap, oldMap); // https://unison-technology.atlassian.net/browse/BUS-155111228
        OpportunityService.undoOIPConfirmed(newMap, oldMap); // https://unison-technology.atlassian.net/browse/BUS-155111228
        TriggrUtility.needsToCalculateFormulas = false;
        }
        List<Opportunity> declineReasonOpps = new List<Opportunity>(); // https://unison-technology.atlassian.net/browse/BUS-155110786
        {//Currency to words BUS-155109631 Edson Garcia
            for (Opportunity c : newMap.values()) {
                if (c.Estimated_Funding_Amount__c != null && c.Estimated_Funding_Amount__c >= 0) {
                    Long n = c.Estimated_Funding_Amount__c.longValue();
                    String cleanVal = String.valueOf(c.Estimated_Funding_Amount__c);
                    String cents = '';
                    if(cleanVal.contains('.')){
                        cleanVal = cleanVal.right(2);
                        cents = ConvertCurrencyToWords.english_number(Integer.valueOf(cleanVal));
                    }
                    string amo = ConvertCurrencyToWords.english_number(n);
                    string amo1 = amo.remove(',');
                    String lastWord = amo1.substringAfterLast(' ');
                    if(cents != ''){
                        if(cents == 'One' || cents == 'one'){
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollars' + ' and ' + cents + ' Cent';
                        }else{
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollars' + ' and ' + cents + ' Cents';
                        }
                    }else{
                        if(amo1 == 'One' || amo1 == 'one'){
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollar';
                        }else{
                            c.OIP_Numbers_to_Words__c = amo1 + ' Dollars';
                        }
                    }
                } else {
                    c.OIP_Numbers_to_Words__c = null;
                }
                // https://unison-technology.atlassian.net/browse/BUS-155110786
                if(c.IA_Decline_Reason__c != oldMap.get(c.Id).IA_Decline_Reason__c) {
                    declineReasonOpps.add(c);
                }
            }
            // https://unison-technology.atlassian.net/browse/BUS-155110786
            if(!declineReasonOpps.isEmpty()) {
                OpportunityService.assignDeclineReasons(declineReasonOpps);
            }
        }//Currency to words
        
        SetQualifiesforNewHOPricing(newMap.values());
        preventOfferToClosing(newMap.values(), oldMap);
        preventFundedWon(newMap.values(), oldMap);
    }


    public static void handleAfterUpdate(List<Opportunity> newList, Map<Id,Opportunity> oldMap)
    {
        
        system.debug('++ NEW OpportunityTriggerHandler ' + newList);
        system.debug('++ OLD OpportunityTriggerHandler ' + oldMap);
        system.debug('++ TriggrUtility.RunOnce? OpportunityTriggerHandler ' + TriggrUtility.RunOnce);
        UnisonMasterNotifications.ManageNotificationsForOpportunityFieldChanges(newList, oldMap);

        DelightedIntegration(newList, oldMap);

        List<Opportunity> lstOpty = new List<Opportunity>();
        List<Opportunity> lstOptyForContactRoles = new List<Opportunity>();
        Set<Id> opplistforOIPupdate = new Set<Id>();
        
        //Lists of Opps for Reqs processing at each stage
        List<Opportunity> oppListForIDDReqs = new List<Opportunity>();
        List<Opportunity> oppListForOfferReqs = new List<Opportunity>();
        List<Opportunity> oppListForClosingReqs = new List<Opportunity>();
        List<Opportunity> oppListForPostClosingReqs = new List<Opportunity>();         

        for(Opportunity objOpty : newList)
        {
            // added in order to resolve this ticket: https://unison-technology.atlassian.net/browse/BUS-155109918
            // 2019-09-24 Replaced by this ticket: https://unison-technology.atlassian.net/browse/BUS-155110451
            /*if(needsRequirementsCreated(objOpty, oldMap.get(objOpty.Id)))
            {
                lstOpty.add(objOpty);
            }*/
            //START new logic for https://unison-technology.atlassian.net/browse/BUS-155110451
            if(objOpty.StageName == LABEL.Investment_Due_Diligence && oldMap.get(objOpty.Id).StageName == LABEL.Ready_for_Ops && !objOpty.SEND_TO_ENCOMPASS__c && !alreadyCreatedIDDReqsSet.contains(objOpty.Id) ){
                oppListForIDDReqs.add(objOpty);
                alreadyCreatedIDDReqsSet.add(objOpty.Id);
            }
            if(objOpty.StageName == LABEL.Closing && oldMap.get(objOpty.Id).StageName == LABEL.Final_Approval && !objOpty.SEND_TO_ENCOMPASS__c && !alreadyCreatedClosingReqsSet.contains(objOpty.Id) ){
                oppListForClosingReqs.add(objOpty);
                alreadyCreatedClosingReqsSet.add(objOpty.Id);
            } 
            if(objOpty.StageName == LABEL.Offer && oldMap.get(objOpty.Id).StageName == LABEL.Final_Approval && !objOpty.SEND_TO_ENCOMPASS__c && !alreadyCreatedOfferReqsSet.contains(objOpty.Id) ){
                oppListForOfferReqs.add(objOpty);
                alreadyCreatedOfferReqsSet.add(objOpty.Id);
            }            
            if(objOpty.StageName == LABEL.Closing && oldMap.get(objOpty.Id).StageName == LABEL.Offer && !objOpty.SEND_TO_ENCOMPASS__c && !alreadyCreatedClosingReqsSet.contains(objOpty.Id) ){
                oppListForClosingReqs.add(objOpty);
                alreadyCreatedClosingReqsSet.add(objOpty.Id);
            }
            if(objOpty.StageName == LABEL.Post_Closing && oldMap.get(objOpty.Id).StageName == LABEL.Closing && !objOpty.SEND_TO_ENCOMPASS__c && !alreadyCreatedPostClosingReqsSet.contains(objOpty.Id) ){
                oppListForPostClosingReqs.add(objOpty);
                alreadyCreatedPostClosingReqsSet.add(objOpty.Id);
            }                                    
            //END new logic for https://unison-technology.atlassian.net/browse/BUS-155110451
            
            system.debug('OpportunityTriggerHandler');
            system.debug(objOpty.StageName);

            if ( objOpty.StageName == 'Closing')
                lstOptyForContactRoles.add(objOpty);

            if(objOpty.Estimated_Funding_Amount__c != oldMap.get(objOpty.Id).Estimated_Funding_Amount__c
                    || objOpty.Unison_Transaction_Fee__c != oldMap.get(objOpty.Id).Unison_Transaction_Fee__c){
                opplistforOIPupdate.add(objopty.Id);
            }
        }
        // Replaced by https://unison-technology.atlassian.net/browse/BUS-155110451
        /* 
        if(lstOpty.size() > 0){
            if(!createdRequirements) {
                System.debug('&&&&&& creating reqs from opp after udpate');
                createRequirementsatStages(lstOpty);
                createdRequirements = true;
            }
        }*/        
        //New Logic for https://unison-technology.atlassian.net/browse/BUS-155110451
        //Send off Opps in respective stages for requirements creation
        if(oppListForIDDReqs.size() > 0){
            OpportunityUtilityClass.createIDDOppRequirements(oppListForIDDReqs);
        }    
        if(oppListForOfferReqs.size() > 0){
            OpportunityUtilityClass.createOfferOppRequirements(oppListForOfferReqs);        
        }
        if(oppListForClosingReqs.size() > 0){
            OpportunityUtilityClass.createClosingOppRequirements(oppListForClosingReqs);        
        }
        if(oppListForPostClosingReqs.size() > 0){
            OpportunityUtilityClass.createPostClosingOppRequirements(oppListForPostClosingReqs);        
        }        
        //End New Logic for https://unison-technology.atlassian.net/browse/BUS-155110451

        if(opplistforOIPupdate.size() > 0){
            updateFinalAmount(opplistforOIPupdate);
        }

        if(lstOptyForContactRoles.size() > 0){
            ContactRolesUtility.createContactRoles(lstOptyForContactRoles);
        }


        if(!createdReqflag)
        {
            //OpportunityUtilityClass.OpportunityPassbook(newList,OldMap);
            OpportunityUtilityClass.opportunitySFGating(newList, oldMap);

            createdReqflag = True;
        }

        
        id emailTemplate;
        if (!emailSentPsCommunicationDMACriterias) {
            emailTemplate = [select id from EmailTemplate where developername = 'PS_Communication_DMAs'].id;
            emailSentPsCommunicationDMACriterias = true;
        }
        PsCommunicationDMACriterias.sendEmailToPs(newList, OldMap, emailTemplate);

        //OpportunityChatterUpdates.doChatterUpdates(newList, oldMap);

        // Opportunities for Encompass processing
        /* COMMENTED BECAUSE WE'RE MOVING THIS FUNCTIONALITY FROM Opportunity to Lead, look for LeadTriggerHandlerPC.
        // https://unison-technology.atlassian.net/browse/BUS-155109425
        Map<Id, Opportunity> opportunityEncompass = new Map<Id, Opportunity>();
         for(Opportunity opp : newList) {
             if(oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Post-Closing' && opp.SEND_TO_ENCOMPASS__c) {
                 opportunityEncompass.put(opp.Id, opp);
             }
         }
         if(!opportunityEncompass.isEmpty()) {
            System.enqueueJob(new BoxAttachmentRetrievalQueueable(opportunityEncompass));
         }*/
        List<Opportunity> oppsToProcess = new List<Opportunity>();
        List<Opportunity> oppsToProcessDMA = new List<Opportunity>();
        for(Opportunity opp : newList) {
            if(opp.Payment_Monthly_HOA__c != oldMap.get(opp.Id).Payment_Monthly_HOA__c && opp.Payment_Monthly_HOA__c > 0) {
                oppsToProcess.add(opp);
            }
            if (opp.DMA_Count__c != oldMap.get(opp.Id).DMA_Count__c) {
                oppsToProcessDMA.add(opp);
            }
        }
        if(!oppsToProcess.isEmpty()) {
            createHOAQuestionnaireRequirement(oppsToProcess);
        }

        if(!oppsToProcessDMA.isEmpty()) {
            createRequirementsForDMA(oppsToProcessDMA);
        }
        TuneIntegration(newList, oldMap);
        
		OpportunityUtilityClass.switchAppraisalReqs(newList, oldMap);
    }

    private static void SetQualifiesforNewHOPricing(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            opp.Qualifies_for_New_HomeOwner_Pricing__c = false;		
            if (opp.New_HomeOwner_Purchase_Date__c != null && opp.NHO_Expected_Close_Date__c != null) {
                if (Math.abs(opp.New_HomeOwner_Purchase_Date__c.DaysBetween(opp.NHO_Expected_Close_Date__c)) < 365) {
                    opp.Qualifies_for_New_HomeOwner_Pricing__c = true;
                }
            }
        }
    }
    
    private static void TuneIntegration(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        
        Id ownerRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        Id buyerRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        
        Map<Id, String> tuneMap = new Map<Id, String>();
        
        for (Opportunity newOpportunity : newList) {
            Opportunity oldOpportunity = oldMap.get(newOpportunity.Id);
            if (!String.isBlank(newOpportunity.Tune_Transaction_Id__c) && !String.isBlank(newOpportunity.Tune_Offer_Id__c)) {
                if (newOpportunity.Wire_to_Agent_Date__c != null && oldOpportunity.Wire_to_Agent_Date__c == null) {
                    if (newOpportunity.RecordTypeId == buyerRTId || newOpportunity.RecordTypeId == ownerRTId) {
                        tuneMap.put(newOpportunity.Id, '4');
                    }
                }
            }
        }
        
        if (tuneMap.size() > 0) {
            TuneIntegration.SendOppsToTune(tuneMap);
        }
        
    }


    private static void DelightedIntegration(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        system.debug('DelightedIntegration call');
        
        List<Delighted_API_Key__mdt> delightedApiSettings = [Select Id, DeveloperName, Active_in_Trigger__c  from Delighted_API_Key__mdt];
        Map<String, Boolean> delightedApiSettingsMap = new Map<String, Boolean>();
        
        for(Delighted_API_Key__mdt apiKey: delightedApiSettings){
            delightedApiSettingsMap.put(apiKey.DeveloperName, apiKey.Active_in_Trigger__c);
        }
        
        if (!System.isFuture() && !System.isBatch()) {
            List<Id> oIds = new List<Id>();
            for (Opportunity newOpp: newList) {
                if(!alreadyCreatedNPMOppIDSet.contains(newOpp.Id) && !newOpp.Delighted_Survey_Sent__c){
                    if(delightedApiSettingsMap.get('Standard')){
                        if (newOpp.Delighted_Send_Status__c && oldMap.get(newOpp.Id).Delighted_Send_Status__c != newOpp.Delighted_Send_Status__c ) {
                            oIds.add(newOpp.Id);
                            alreadyCreatedNPMOppIDSet.add(newOpp.Id);
                        }
                    }
                    if(delightedApiSettingsMap.get('Project')){
                        if( ( newOpp.StageName == 'Closed Lost' && newOpp.Loss_Type__c == 'Withdrawn' ) && ( oldMap.get(newOpp.Id).StageName != newOpp.StageName || oldMap.get(newOpp.Id).Loss_Type__c != newOpp.Loss_Type__c ) && !newOpp.Loss_Reason_Code__c.contains('Remove from all Marketing Communication') ) {
                            oIds.add(newOpp.Id);
                            alreadyCreatedNPMOppIDSet.add(newOpp.Id);
                        }
                    } 
                }
            }

            if (oIds.size() > 0) {

                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Applicant__r.Marketing_Opt_Out__c FROM Opportunity WHERE Id IN :oIds]);
            
                List<Net_Promoter_Measurement__c> toInsert = new List<Net_Promoter_Measurement__c>();
                for (integer i = 0; i < 50 && i < oIds.size(); i++) {
                    if (oppMap.get(oIds[i]).Applicant__r.Marketing_Opt_Out__c != true) {
                        Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
                        npm.Status__c = 'Draft';
                        npm.Opportunity__c = oIds[i];
                        toInsert.add(npm);
                    }
                }
                if (toInsert.size() > 0)
                    insert toInsert;
            }
        }
    }


    public static void createRequirementsForDMA(List<Opportunity> oppList)
    {
            List<Current_Conditions__c> ccToInsert = new List<Current_Conditions__c>();

            Map<string, Current_Conditions__c> mapCC = new Map<string, Current_Conditions__c>();
            for (Current_Conditions__c req : [
                    select id, Opportunity__c, Code__c, status__c
                    from Current_Conditions__c
                    where Opportunity__c in :oppList and Code__c = 'R1026'
            ]) {
                mapCC.put(req.Opportunity__c, req);
            }

            for (Opportunity opp : oppList) {
                    Current_Conditions__c existingReq = mapCC.get(opp.id);
                    System.debug('DMA Req@@1'+opp.DMA_Count__c);
                    if (opp.DMA_Count__c == 0) {
                        if (existingReq != null) {
                            existingReq.Status__c = 'Waived';
                            ccToInsert.add(existingReq);
                        }
                    } else {
                        System.debug('DMA Req@@2'+existingReq );
                        if (existingReq == null)
                            ccToInsert.add(new Current_Conditions__c(Opportunity__c = opp.Id, Code__c = 'R1026')); else {

                            existingReq.Status__c = 'Document Received, In progress';
                            ccToInsert.add(existingReq);
                            System.debug('DMA Req@@3'+existingReq );
                            List<Project_Task__c> tasks = [
                        /*Caro Veliz: BUS-155110073*/
                                    select id, name, /*Completed__c*/ status__c
                                    from Project_Task__c
                                    where
                                            Requirement__c = :existingReq.id
                            ];
                            for (Project_Task__c task : tasks)
                    /*Caro Veliz: BUS-155110073*/
                                //task.Completed__c = false;
                                task.Status__c = 'In Progress';
                            if (tasks.size() > 0)
                                update tasks;
                        }
                    }


            }
            if (ccToInsert.size() > 0 && !Test.isRunningTest()) {
                System.debug('DMA Req@@4'+ccToInsert );
                upsert ccToInsert;
            }
    }
    /*
    public static Current_Conditions__c getRequirement(String requirementType,Opportunity opp) {
         Current_Conditions__c cc = new Current_Conditions__c();
         cc.Opportunity__c = opp.Id;
         cc.Requirement__c  = requirementType;
         cc.Success_Factor__c = 'a4i0x0000009hRI';
        return cc;
    } */

    private static void preventOfferToClosing(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Opportunity> eligibleOpps = new List<Opportunity>();
        for (Opportunity newOpp : newList) {
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            if (newOpp.StageName == Label.Closing && oldOpp.StageName == Label.Offer) {
                eligibleOpps.add(newOpp);
            }
        }
        
        if (eligibleOpps.size() > 0) {
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, (SELECT Status__c FROM Current_Conditions__r WHERE Code__c = 'R1072') FROM Opportunity WHERE Id IN :eligibleOpps]);
            
            for (Opportunity newOpp : eligibleOpps) {
                Opportunity dbOpp = oppMap.get(newOpp.Id);
                if (dbOpp.Current_Conditions__r.size() > 0) {
                    if (dbOpp.Current_Conditions__r[0].Status__c != 'Completed')
                        newOpp.addError(Label.Offer_Package_Error);
                }
            }
        }
    }

    private static void preventFundedWon(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Opportunity> eligibleOpps = new List<Opportunity>();
        for (Opportunity newOpp : newList) {
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            if (newOpp.StageName == Label.Funded_Won && oldOpp.StageName != Label.Funded_Won) {
                eligibleOpps.add(newOpp);
            }
        }
        
        if (eligibleOpps.size() > 0) {
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, (SELECT Status__c FROM Risk_Factors__r WHERE Success_Factor__c = 'Post-Closing') FROM Opportunity WHERE Id IN :eligibleOpps]);
            
            for (Opportunity newOpp : eligibleOpps) {
                newOpp.Orissa_Wire_Sync__c = false;
                Opportunity dbOpp = oppMap.get(newOpp.Id);
                if (dbOpp.Risk_Factors__r.size() > 0) {
                    if (dbOpp.Risk_Factors__r[0].Status__c != 'Completed')
                        newOpp.addError(Label.Post_Closing_Error);
                }
            }
        }
    }
    
    // Added for: https://unison-technology.atlassian.net/browse/BUS-155110114
    private static void assignRecordTypeOnCreation(List<Opportunity> opportunities) {
        Schema.DescribeSObjectResult oppDesc = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRTMapByName = oppDesc.getRecordTypeInfosByName();

        for(Opportunity opp : opportunities) {
            system.debug('BEFORE assignRecordTypeOnCreation');
            system.debug('Opportunity Record Type: ' + opp.RecordTypeId);
            system.debug('Opportunity Program_Floor__c: ' + opp.Program_Floor__c);
            if(opp.Converted_Lead_RT__c != null && (opp.Converted_Lead_RT__c == 'HomeOwner' || opp.Converted_Lead_RT__c == 'HomeBuyer')) {
                if(oppRTMapByName.get(opp.Converted_Lead_RT__c) != null) {
                    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(opp.Converted_Lead_RT__c).getRecordTypeId();
                }
            }
            system.debug('AFTER assignRecordTypeOnCreation');
            system.debug('Opportunity Record Type: ' + opp.RecordTypeId);
            system.debug('Opportunity Program_Floor__c: ' + opp.Program_Floor__c);
            //added for BUS-155110002 to consider passbook only for homeowner
            if(opp.Converted_Lead_RT__c == Label.HomeOwner) {
                opp.Passbook_Status__c = Label.Pending;
            }
        }
    }


    private static void createOpportunityProducts(List<Opportunity> opportunitiesList) {
        List<OpportunityLineItem> opportunityProductsList = new List<OpportunityLineItem>();
        /* Adding 'Transaction Fee Waiver' Product
        https://unison-technology.atlassian.net/browse/BUS-155111326
        */

        List<String> prodNames = new List<String>{'Acquisition Fee','Transaction Fee', 'Transaction Fee Waiver'};
        List<Product2> productList = new List<Product2>([SELECT Id, Name, ProductCode, Group__c,
                Type__c FROM Product2 where Name IN: prodNames]);
        Map<Id,PricebookEntry> pbEntryMap = new Map<Id,PricebookEntry>();

        /*Caro Veliz:  To implement: https://unison-technology.atlassian.net/browse/BUS-155110391
         Create New Pricebook for CAD Product.
         When creating Opportunity Products, system needs to retrieve the product with the Opp.Currency.
         */
        List<PricebookEntry> pbeList = [SELECT Id, Name,CurrencyIsoCode, Pricebook2Id, Product2Id,Product2.name,  UnitPrice, IsActive,
                Pricebook2.Name
        FROM PricebookEntry where Pricebook2.Name  = 'Fee' and IsActive = TRUE and Product2Id in :productList];
        System.debug('productList==>'+productList);
        System.debug('opportunitiesList==>'+opportunitiesList);
        System.debug('entryMap==>'+pbEntryMap);
        for(Opportunity oppObj : opportunitiesList) {
            for(Product2 prodObj : productList) {

                if ((prodObj.Name != 'Transaction Fee Waiver') ||
                   ((prodObj.Name == 'Transaction Fee Waiver') && oppObj.campaignSource__c == 'Opendoor' )) {

                    OpportunityLineItem obj = new OpportunityLineItem();
                    obj.OpportunityId = oppObj.Id;
                    obj.Product2Id = prodObj.Id;

                    for (PricebookEntry pbe : pbeList) {
                        if ((pbe.Product2Id == prodObj.Id) && (pbe.CurrencyIsoCode == oppObj.CurrencyIsoCode)) {
                            obj.PricebookEntryId = pbe.id;
                            break;
                        }
                    }
                    obj.Quantity = 1;
                    if (prodObj.Name != 'Transaction Fee Waiver')
                        obj.UnitPrice = 20;
                    if (obj.PricebookEntryId == null)
                        obj.addError('Product [' + prodObj.name + '] does not have a valid entry in Pricebook [FEE] for currency [' + oppObj.CurrencyIsoCode + ']');
                    opportunityProductsList.add(obj);
                    System.debug('one oli: ' + obj);
                    System.debug('one product: ' + prodObj);
                }
            }
        }
        System.debug('opportunityProductsList: '+opportunityProductsList);
        if(opportunityProductsList.size() > 0) {
            insert opportunityProductsList;
        }
    }

    //RagaSindhu Adapala- Create Requirements at Opportunity Stages
    //Replaced by https://unison-technology.atlassian.net/browse/BUS-155110451
    /*
    public static void createRequirementsatStages(List<Opportunity> oppstagelist){
        Set<Id> oppids = new Set<Id>();
        Map<Id,Set<String>> existingreqsatopp = new map<Id,set<String>>();
        List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();
        for(Opportunity opp: oppstageList){
            if(opp.Id != Null){
                oppids.add(opp.id);
            }
        }
        // Opportunity list
        List<Opportunity> opplist = [
                SELECT Id,
                        StageName,
                        RecordTypeId,
                        Title_Held__c,
                        Post_Close_Home_Inspection_Check__c,
                        Greenlight_Requires_Second_Appraisal__c,
                        Final_Title_Held__c,
                        SEND_TO_ENCOMPASS__c,
                        Payment_Monthly_HOA__c,
                (SELECT Id, Declaration_Power_of_Attorney__c FROM Applications__r),
                (SELECT Id, Property_Type__c, Property_State__c FROM Properties__r),
                (SELECT Id,Code__c, Opportunity__c FROM Current_Conditions__r),
                (SELECT Id, Success_Factor__c from Risk_Factors__r)
                FROM Opportunity
                WHERE Id =: oppids];

        ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        for(Opportunity oppobj: opplist){

            // If this was sent to Encompass, do not proceed
            if (oppobj.SEND_TO_ENCOMPASS__c) {
                continue;
            }

            if(oppobj.Current_Conditions__r != Null){
                system.debug('*****oppobj.Current_Conditions__r******'+oppobj.Current_Conditions__r);
                for(Current_Conditions__c reqscreated: oppobj.Current_Conditions__r){
                    if(reqscreated.Code__c != Null){
                        if(existingreqsatopp.keyset().contains(oppobj.Id)){
                            set<string> reqcode = new set<string>();
                            reqcode = existingreqsatopp.get(oppobj.Id);
                            reqcode.add(reqscreated.Code__c);
                            existingreqsatopp.put(oppobj.Id,reqcode);
                        }else{
                            set<string> reqcode = new set<string>();
                            reqcode.add(reqscreated.Code__c);
                            existingreqsatopp.put(oppobj.Id,reqcode);
                        }
                    }
                }
            }
        }


        for(Opportunity oppobj: opplist)
        {            
            // If this was sent to Encompass, do not proceed
            if (oppobj.SEND_TO_ENCOMPASS__c) {
                continue;
            }

            for(EOS_Requirements__mdt eosMDT: [Select MasterLabel,Dupallowed__c from EOS_Requirements__mdt]){
                if(oppobj.StageName == 'Investment Due Diligence' && oppobj.Id != Null){
                    system.debug('****oppobj.Id*****'+oppobj.Id);
                    system.debug('****existingreqsatopp*****'+existingreqsatopp);
                    system.debug('****eosMDT*****'+eosMDT);
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1008') && eosMDT.MasterLabel == 'R1008' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1008') && eosMDT.MasterLabel == 'R1008' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1008'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1040') && eosMDT.MasterLabel == 'R1040' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1040') && eosMDT.MasterLabel == 'R1040' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1040'));}

                    if(oppobj.Title_Held__c == 'In Trust'){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1115') && eosMDT.MasterLabel == 'R1115' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1115') && eosMDT.MasterLabel == 'R1115' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1115'));}
                    }
                    if(oppobj.Applications__r != Null) {
                        for(Application__c appl: oppobj.Applications__r) {
                            if(appl.Declaration_Power_of_Attorney__c == 'Yes'){
                                if(!existingreqsatopp.get(oppobj.Id).contains('R1091') && eosMDT.MasterLabel == 'R1091' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1091') && eosMDT.MasterLabel == 'R1091' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1091'));}
                            }
                        }
                    }

                    if(oppobj.RecordTypeId == IDHomeOwner){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1114') && eosMDT.MasterLabel == 'R1114' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1114') && eosMDT.MasterLabel == 'R1114' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1114'));}
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1104') && eosMDT.MasterLabel == 'R1104' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1104') && eosMDT.MasterLabel == 'R1104' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1104'));}
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1037') && eosMDT.MasterLabel == 'R1037' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1037') && eosMDT.MasterLabel == 'R1037' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1037'));}

                        if(oppobj.Greenlight_Requires_Second_Appraisal__c == True){
                            if(!existingreqsatopp.get(oppobj.Id).contains('R1009') && eosMDT.MasterLabel == 'R1009' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1009') && eosMDT.MasterLabel == 'R1009' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1009'));}
                        }
                    }
                    system.debug('oppobj.RecordTypeId');
                    system.debug(oppobj.RecordTypeId);
                    system.debug(IDHomeBuyer);
                    if(oppobj.RecordTypeId == IDHomeBuyer){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1041') && eosMDT.MasterLabel == 'R1041' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1041') && eosMDT.MasterLabel == 'R1041' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1041'));}
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1042') && eosMDT.MasterLabel == 'R1042' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1042') && eosMDT.MasterLabel == 'R1042' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1042'));}
                        //if(!existingreqsatopp.get(oppobj.Id).contains('R1036') && eosMDT.MasterLabel == 'R1036' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1036') && eosMDT.MasterLabel == 'R1036' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1036'));}
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1015') && eosMDT.MasterLabel == 'R1015' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1015') && eosMDT.MasterLabel == 'R1015' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1015'));}
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1035') && eosMDT.MasterLabel == 'R1035' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1035') && eosMDT.MasterLabel == 'R1035' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1035'));}
                        //if(!existingreqsatopp.get(oppobj.Id).contains('' +'R1012') && eosMDT.MasterLabel == 'R1012' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1012') && eosMDT.MasterLabel == 'R1012' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1012'));}
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1029') && eosMDT.MasterLabel == 'R1029' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1029') && eosMDT.MasterLabel == 'R1029' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1029'));}

                        if(!existingreqsatopp.get(oppobj.Id).contains('R1113') && eosMDT.MasterLabel == 'R1113' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1113') && eosMDT.MasterLabel == 'R1113' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1113'));}
                    }

                    if(oppobj.Properties__r != Null){
                        for(Property__c prop: oppobj.Properties__r){
                            if(oppobj.RecordTypeId == IDHomeOwner){
                                if(oppobj.Payment_Monthly_HOA__c > 0.0 && prop.Property_Type__c == 'Condominium') {
                                    if(!existingreqsatopp.get(oppobj.Id).contains('R1039') && eosMDT.MasterLabel == 'R1039' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1039') && eosMDT.MasterLabel == 'R1039' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1039'));}

                                } else if(oppobj.Payment_Monthly_HOA__c >= 150.0 &&
                                        (prop.Property_Type__c == 'Single-family detached' || prop.Property_Type__c == 'Townhouse' || prop.Property_Type__c == 'PUD')) {
                                    if(!existingreqsatopp.get(oppobj.Id).contains('R1039') && eosMDT.MasterLabel == 'R1039' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1039') && eosMDT.MasterLabel == 'R1039' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1039'));}
                                }
                            }
                            if(oppobj.RecordTypeId == IDHomeBuyer){
                                if(prop.Property_Type__c == 'Condominium' || prop.Property_Type__c == 'PUD'){
                                    if(!existingreqsatopp.get(oppobj.Id).contains('R1038') && eosMDT.MasterLabel == 'R1038' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1038') && eosMDT.MasterLabel == 'R1038' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1038'));}
                                }
                                if(prop.Property_State__c == 'CA'){
                                    if(!existingreqsatopp.get(oppobj.Id).contains('R1049') && eosMDT.MasterLabel == 'R1049' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1049') && eosMDT.MasterLabel == 'R1049' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1049'));}
                                }
                                if ((oppobj.StageName == 'Investment Due Diligence') && (prop.New_Construction_Flag__c = TRUE)) {
                                    if (!existingreqsatopp.get(oppobj.Id).contains('R1016') && eosMDT.MasterLabel == 'R1016' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1016') && eosMDT.MasterLabel == 'R1016' && eosMDT.Dupallowed__c == True)) {
                                        reqsForInsert.add(new Current_Conditions__c(Opportunity__c = oppobj.Id, Code__c = 'R1016'));
                                    }
                                }
                            }
                            system.debug('***Property ***');
                            system.debug(prop.Property_Type__c);
                            if(prop.Property_Type__c == 'Condominium' || prop.Property_Type__c == 'PUD'){
                                
                                if(!existingreqsatopp.get(oppobj.Id).contains('R1122') && eosMDT.MasterLabel == 'R1122' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1122') && eosMDT.MasterLabel == 'R1122' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1122'));}
                            }
                        }
                    }
                }
                if(oppobj.StageName == 'Closing'){
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1018') && eosMDT.MasterLabel == 'R1018' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1018') && eosMDT.MasterLabel == 'R1018' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1018'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1032') && eosMDT.MasterLabel == 'R1032' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1032') && eosMDT.MasterLabel == 'R1032' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1032'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1019') && eosMDT.MasterLabel == 'R1019' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1019') && eosMDT.MasterLabel == 'R1019' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1019'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1090') && eosMDT.MasterLabel == 'R1090' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1090') && eosMDT.MasterLabel == 'R1090' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1090'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1030') && eosMDT.MasterLabel == 'R1030' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1030') && eosMDT.MasterLabel == 'R1030' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1030'));}

                    if(oppobj.Final_Title_Held__c == 'In Trust'){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1116') && eosMDT.MasterLabel == 'R1116' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1116') && eosMDT.MasterLabel == 'R1116' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1116'));}
                    }

                    if(oppobj.Post_Close_Home_Inspection_Check__c == True){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1089') && eosMDT.MasterLabel == 'R1089' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1089') && eosMDT.MasterLabel == 'R1089' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1089'));}
                    }

                    if(oppobj.RecordTypeId == IDHomeOwner){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1072') && eosMDT.MasterLabel == 'R1072' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1072') && eosMDT.MasterLabel == 'R1072' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1072'));}
                    }

                    if(oppobj.Properties__r != Null){
                        for(Property__c prop: oppobj.Properties__r){
                            if(prop.Property_Type__c == 'PUD'){
                                if(!existingreqsatopp.get(oppobj.Id).contains('R1094') && eosMDT.MasterLabel == 'R1094' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1094') && eosMDT.MasterLabel == 'R1094' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1094'));}
                            }
                            if(prop.Property_Type__c == 'Condominium'){
                                if(!existingreqsatopp.get(oppobj.Id).contains('R1020') && eosMDT.MasterLabel == 'R1020' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1020') && eosMDT.MasterLabel == 'R1020' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1020'));}
                            }
                        }
                    }
                }

                if(oppobj.StageName == 'Post-Closing'){
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1017') && eosMDT.MasterLabel == 'R1017' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1017') && eosMDT.MasterLabel == 'R1017' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1017'));}
                }
            }
        }
        if(reqsForInsert.size()>0  && !createdRequirements) {
            if (!test.isRunningTest()) {
                system.debug('reqsForInsert ' + reqsForInsert);
                insert reqsForInsert; createdRequirements = true;
            }
        }
    }
    */

    //RagaSindhu Adapala - as per BUS-155109492
    public static void updateFinalAmount(Set<Id> oipids) {
        List<OpportunityLineItem> opplineitemlist = new List<OpportunityLineItem>();
        for(Opportunity opplist: [Select Id, Unison_Transaction_Fee__c, Estimated_Funding_Amount__c,
        (Select Id, UnitPrice, OpportunityId from OpportunityLineItems where Product2.Name = 'Transaction Fee')
        from Opportunity where Id =: oipids]){
            //for(Product2 prod2: [Select Id, Name FROM Product2 where Name = 'Transaction Fee' limit 1]){
            if(opplist.OpportunityLineItems != Null){
                for(OpportunityLineItem lineitem: opplist.OpportunityLineItems){
                    OpportunityLineItem templineitem = new OpportunityLineItem();
                    //if(opplist.Id == lineitem.OpportunityId){
                    templineitem.Id = lineitem.Id;
                    if(opplist.Estimated_Funding_Amount__c >= 360000){
                        templineitem.UnitPrice = 14000;
                    }else {
                        templineitem.UnitPrice = (opplist.Unison_Transaction_Fee__c * opplist.Estimated_Funding_Amount__c)/100;
                    }
                    //}
                    opplineitemlist.add(templineitem);
                }
            }
            //}
        }
        if(opplineitemlist.size() > 0){
            update opplineitemlist;
        }
    }
    // added in order to resolve this ticket: https://unison-technology.atlassian.net/browse/BUS-155109918
    // Replaced by https://unison-technology.atlassian.net/browse/BUS-155110451
    /*    
    private static Boolean needsRequirementsCreated(Opportunity newOpp, Opportunity oldOpp) {
        Boolean isTrue = true;
        String newValue = newOpp.StageName;
        String oldValue = oldOpp.StageName;
        system.debug('OpportunityTriggerHandler new Value: ' + newValue);
        system.debug('OpportunityTriggerHandler old Value: ' + oldValue);
        if(newValue == oldValue){
            isTrue = false;
        }
        switch on oldValue {
            // Investment Due Diligence can't go back
            when 'Investment Due Diligence' {
                if(newValue == 'Ready for Ops') {
                    isTrue = false;
                }
            }
            // Final Approval can't go back
            when 'Final Approval' {
                if(newValue == 'Ready for Ops' || newValue == 'Investment Due Diligence') {
                    isTrue = false;
                }
            }
            // Closing can't go back
            when 'Closing' {
                if(newValue == 'Ready for Ops' || newValue == 'Investment Due Diligence' || newValue == 'Final Approval') {
                    isTrue = false;
                }
            }
            // Post-Closing can't go back
            when 'Post-Closing' {
                if(newValue == 'Ready for Ops' || newValue == 'Investment Due Diligence' || newValue == 'Final Approval' || newValue == 'Closing') {
                    isTrue = false;
                }
            }
        }
        system.debug('OpportunityTriggerHandler need to create requirements? ' + isTrue);
        return isTrue;
    }
    */
    
    public static void CopyRecordType(List<Opportunity> newList) {

        for (Opportunity o : newList) {
            o.RecordType_Product_Picklist__c = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(o.RecordTypeId).getName();
        }
    }

    private static void createHOAQuestionnaireRequirement(List<Opportunity> opportunities) {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : opportunities) {
            oppIds.add(opp.Id);
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Name, StageName, Estimated_Funding_Amount__c, Unison_Transaction_Fee__c,
                Property__c, Property__r.Property_Type__c, RecordTypeId, Payment_Monthly_HOA__c,
        (SELECT Id, Code__c, Opportunity__c FROM Current_Conditions__r),
        (SELECT Id, Property_Type__c, Property_State__c FROM Properties__r)
        FROM Opportunity WHERE Id IN : oppIds]);
        Map<Id,Set<String>> existingReqOppMap = new map<Id,set<String>>();
        for(String key : oppMap.keySet()){
            Opportunity tempOpp = oppMap.get(key);
            if(tempOpp != null) {
                if(tempOpp.Current_Conditions__r != null){
                    for(Current_Conditions__c existingReqs : tempOpp.Current_Conditions__r){
                        if(existingReqs.Code__c != null){
                            if(existingReqOppMap.keyset().contains(tempOpp.Id)){
                                Set<String> req_codes = new Set<String>();
                                req_codes = existingReqOppMap.get(tempOpp.Id);
                                req_codes.add(existingReqs.Code__c);
                                existingReqOppMap.put(tempOpp.Id,req_codes);
                            }else{
                                Set<String> req_codes = new Set<String>();
                                req_codes.add(existingReqs.Code__c);
                                existingReqOppMap.put(tempOpp.Id,req_codes);
                            }
                        }
                    }
                }
            }
        }
        Map<String, EOS_Requirements__mdt> eosRequirementsMap = getEOSRequirements();
        List<Current_Conditions__c> reqsToInsert = new List<Current_Conditions__c>();
        ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        for(String oppId : oppMap.keySet()) {
            Opportunity parentOpp = oppMap.get(oppId);
            if(parentOpp != null) {
                if(parentOpp.RecordTypeId == IDHomeOwner) {
                    // Only done for Opportunities on IDD
                    if(parentOpp.StageName == 'Investment Due Diligence') {
                        for(Property__c prop : parentOpp.Properties__r) {
                            if(prop.Property_Type__c != null) {
                                String propType = prop.Property_Type__c;
                                if(parentOpp.Payment_Monthly_HOA__c > 0.0 && propType == 'Condominium') {
                                    if(!existingReqOppMap.get(parentOpp.Id).contains('R1039') && eosRequirementsMap.get('R1039').MasterLabel == 'R1039' && parentOpp.Id != null && existingReqOppMap.get(parentOpp.Id) != null && eosRequirementsMap.get('R1039').MasterLabel != null|| (existingReqOppMap.get(parentOpp.Id).contains('R1039') && eosRequirementsMap.get('R1039').MasterLabel == 'R1039' && eosRequirementsMap.get('R1039').Dupallowed__c == true)) {
                                        reqsToInsert.add(new Current_Conditions__c(Opportunity__c=parentOpp.Id, Code__c='R1039'));
                                    }
                                } else if(parentOpp.Payment_Monthly_HOA__c >= 150.0 &&
                                        (propType == 'Single-family detached' || propType == 'Townhouse' || propType == 'PUD')) {
                                    if(!existingReqOppMap.get(parentOpp.Id).contains('R1039') && eosRequirementsMap.get('R1039').MasterLabel == 'R1039' && parentOpp.Id != null && existingReqOppMap.get(parentOpp.Id) != null && eosRequirementsMap.get('R1039').MasterLabel != null|| (existingReqOppMap.get(parentOpp.Id).contains('R1039') && eosRequirementsMap.get('R1039').MasterLabel == 'R1039' && eosRequirementsMap.get('R1039').Dupallowed__c == true)) {
                                        reqsToInsert.add(new Current_Conditions__c(Opportunity__c=parentOpp.Id, Code__c='R1039'));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('OpportunityTriggerHandler.reqsToInsert ' + reqsToInsert);
        if(!reqsToInsert.isEmpty()) {
            insert reqsToInsert;
        }
    }

    @TestVisible private static Map<String, EOS_Requirements__mdt> getEOSRequirements(){
        List<EOS_Requirements__mdt> eosMDT = [SELECT MasterLabel, Category__c, Type__c, Internal_vs_External__c, Applicant_Type__c,
                Success_Factor__c, RequirementName__c, RSI_Eligible__c, Dupallowed__c
        FROM EOS_Requirements__mdt WHERE MasterLabel = 'R1039'];
        Map<String, EOS_Requirements__mdt> eosRequirementsMap = new Map<String, EOS_Requirements__mdt>();
        for(EOS_Requirements__mdt req : eosMDT) {
            eosRequirementsMap.put(req.MasterLabel, req);
        }
        return eosRequirementsMap;
    }
}