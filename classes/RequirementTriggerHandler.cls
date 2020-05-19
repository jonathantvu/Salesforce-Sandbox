/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Raga Sindhu
 *  Create date:  Dec 17 2018
 *  Details
 *  -------------------------------------------------------------------------
 *  Apex class to handle all creating Requirements +Project Tasks 
 *  Update History
 *  ----------------------------------------------------------------------------
 *  Neeraja Cherukuri 4/12/2019--> Added handleBeforeInsert + createProjectTasks Methods.
 *   molinger  5/15/2019 -->Modifed handleBeforeInsert + handleBeforeInsert Methods .
 * ---------------------------------------------------------------------------
 ************************************************************************************/


public class RequirementTriggerHandler {

    public static void handleBeforeInsert(List<Current_Conditions__c> reqlist) {

        //Success Factor shoudl not be set on the Requirement, query the Success Factor based on the linked Opp on the Requirement
        System.debug('****');

        Map<Id, Success_Factor__c> mapSuccessFactor = new Map<Id, Success_Factor__c>();
        Set<Id> successFactoryIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        Set<String> reqCodes = new Set<String>();
        for (Current_Conditions__c objReq : reqlist) {
            if (objReq.Opportunity__c != null) {
                oppIds.add(objReq.Opportunity__c);
            } else if (objReq.Lead__c != null) {
                leadIds.add(objReq.Lead__c);
            }

            if (objReq.Code__c != null) {
                reqCodes.add(objREq.code__c);
            }
        }
        mapSuccessFactor = new Map<Id, Success_Factor__c>([
                Select Id, Opportunity__c, Lead__c, Success_Factor__c, Status__c
                FROM Success_Factor__c
                WHERE Opportunity__c IN:oppIds or Lead__C IN:leadIds
        ]);

        //map of Opp id to Success Factor
        Map<String, List<Success_Factor__c>> mapOppToSuccessFactor = new Map<String, List<Success_Factor__c>>();
        for (Success_Factor__c s : mapSuccessFactor.values()) {
            String keyIndex = '';
            //we need to check whether this Success Factor is linked to an Opp or a Lead - Assume if it is linked to an Opp
            //  then we wont use the Lead
            //  Need this because sometimes a Requirement or Success Factor is linked to both
            if (s.Opportunity__c != null) {
                keyIndex = s.Opportunity__c + '';
            } else keyIndex = s.Lead__c + '';
            if (mapOppToSuccessFactor.get(keyIndex) != null) {
                List<Success_Factor__c> ss = mapOppToSuccessFactor.get(keyIndex);
                ss.add(s);
                System.debug('****Adding success factor: ' + keyIndex);
                mapOppToSuccessFactor.put(keyIndex, ss);
            } else {
                List<Success_Factor__c> ss = new List<Success_Factor__c>();
                ss.add(s);
                System.debug('****Adding success factor: ' + keyIndex);
                mapOppToSuccessFactor.put(keyIndex, ss);
            }
        }

        //Lookup Custom Metadata Type for Requirements
        Map<String, EOS_Requirements__mdt> reqMdtMap = new Map<String, EOS_Requirements__mdt>();
        system.debug('++ reqCodes ' + reqCodes);
        for (EOS_Requirements__mdt m : getEOSRequirements(reqCodes)) {
            reqMdtMap.put(m.MasterLabel, m);
        }

        // If Success Factor is already Completed, we shouldnt be able to add new Requirements to it
        // Otherwise, set the Success Factor on the Requirement
        // Also set the Requirement field to be the Name from the Custom Metadata Type
        for (Current_Conditions__c objReq : reqlist) {
            if (objReq.Opportunity__c != Null || objReq.lead__c != null) {
                EOS_Requirements__mdt mrMDT = reqMdtMap.get(objReq.code__c);
                if (mrMDT != null) objReq.Requirement__c = mrMDT.RequirementName__c;
                System.debug('****objReq.Opportunity__c: ' + objReq.Opportunity__c);
                System.debug('****objReq.Lead__c: ' + objReq.Lead__c);
                System.debug('****MDT Obj: ' + mrMDT);
                String keyIndex = '';
                if (objReq.Opportunity__c != null) {
                    keyIndex = objReq.Opportunity__c + '';
                } else keyIndex = objReq.Lead__c + '';
                System.debug('***looking for success factor key: ' + keyIndex);

                if (mrMDT != null && mapOppToSuccessFactor.containsKey(keyIndex)) {
                    for (Success_Factor__c s : mapOppToSuccessFactor.get(keyIndex)) {
                        if (s.Success_Factor__c == mrMDT.Success_Factor__c) {
                            if (s.status__c == 'Completed') {
                                objReq.addError(Label.Success_Factor_Satge_Change_Error);
                            } else {
                                System.debug('**** setting success factor to: ' + s.Id);
                                objReq.success_factor__c = s.Id;
                            }
                        }
                    }
                    if (objReq.success_factor__c == null) System.debug('***no success factor match for : ' + mrMDT.Success_Factor__c);
                }
            }
        }

        //set Requirement fields based on Custom Metadata Type 
        //  (only if Requirements doesnt already exist for this Opportunity) - NOT DOING THIS NOW
        //  and only for Opp stages Investment Due Diligence, Closing, Post-Closing - NOT DOING THIS NOW
        Map<Id, Opportunity> existingReqOppMap = new Map<Id, Opportunity>([Select Id, StageName,RecordType.Name, (select id,Requirement__c,Code__c, Success_Factor__c from Current_Conditions__r) from Opportunity where id IN:oppids]);

        for (Current_Conditions__c objReq : reqlist) {
            EOS_Requirements__mdt mrMDT = reqMdtMap.get(objReq.code__c);
            System.debug('using config record: ' + mrMDT);
            if (objReq.success_factor__c == null) {
                objReq.addError('Could not find any Success Factor for that Opportunity/Lead and Code.  Could not create the record');
            }

            if (objReq.opportunity__c != null || objReq.lead__c != null) {
                String applicantType = objReq.Applicant_Type__c != null ? objReq.Applicant_Type__c : '';
                if (mrMDT != null)
                    //set default values on Requirement
                    setDefaultRequirement(objReq, mrMDT.MasterLabel, mrMDT.Category__c, mrMDT.Type__c, mrMDT.Internal_vs_External__c,
                            mrMDT.RSI_Eligible__c,mrMDT.Applicant_Type__c,Null,Null,False,Null,Null, mrMDT.reason__c);

                //molinger - comnmenting out validation so we can add in later if needed
                /*
                //validate that requirement doesnt already exist for this Opp
                Opportunity opp = existingReqOppMap.get(objReq.opportunity__c);
                
                if ( mrMDT!=null && opp != null && opp.Current_Conditions__r!=null && opp.Current_Conditions__r.size()==0) {
                    //validate stage for the Opp - NOT doing this now
                    if (opp.stagename== 'Investment Due Diligence' || opp.StageName == 'Closing' || opp.StageName == 'Post-Closing') {
                        
                    }
                }
                */
            }
        }

    }

// VK : BUS-155110164    
    public static void validateAppraisalStatus(Map<Id, Current_Conditions__c> oldMap, Map<Id, Current_Conditions__c> newMap){
		
        List<ID> reqIdstovalidate = new List<ID>();
        for(Current_Conditions__c req : newMap.values()) {
            if(req.Status__c != oldMap.get(req.Id).Status__c && (req.Status__c == System.Label.Completed) && req.Requirement__c.Contains(System.Label.Appraisal)) {
                reqIdstovalidate.add(req.Id);
            }
        }

        List<String> appraisalStatusFilter = New String[]{System.Label.Reviewed,System.Label.Cancelled};

        if(!reqIdstovalidate.isEmpty()) {
                List<Appraisal__c> appraisals = [SELECT ID,Appraisal_Status__c,Requirement__c FROM Appraisal__c where Requirement__c IN :reqIdstovalidate AND Appraisal_Status__c NOT IN :appraisalStatusFilter ];
                for(Appraisal__c eachappraisal : appraisals){
              
                    Current_Conditions__c actualRecord = (Current_Conditions__c)Trigger.newMap.get(eachappraisal.Requirement__c);
                    actualRecord.addError(System.Label.Cannot_close_Requirement_Error_Message);
                }
        }
    }


    public static void setDefaultRequirement(Current_Conditions__c req, string code,
            string category, string type, string intvsext,
            Boolean rsi, string app, string assignedto,
            string custdesc, Boolean custresp, string aggr, string doccode, string reason)
    {
        req.Code__c = code;
        req.Category__c = category;
        req.Type__c = type;
        req.Internal_vs_External__c = intvsext;
        req.Applicant_Type__c = app;
        req.RSI_Eligible__c = rsi;
        req.Customer_Description__c = custdesc;
        req.Aggregate__c = aggr;
        req.Document_Code__c = doccode;
        if (string.isNotBlank(reason))
            req.Reason__c = reason;
    }

    public static void createProjectTasks(Map<Id, Current_Conditions__c> mapRequirements) {
        system.debug(mapRequirements);
        Set<String> lstRequirementCode = new Set<String>();
        List<Id> optyIds = new List<Id>();
        List<Id> tradeAcctIds = new List<Id>();
        Map<Id, Id> mapOptyId_assignToId = new Map<Id, Id>();


        for (Current_Conditions__c objRequirement : mapRequirements.values()) {
            if (objRequirement.code__c != null) {
                lstRequirementCode.add(objRequirement.code__c);

                if (objRequirement.Opportunity__c != null) {
                    optyIds.add(objRequirement.Opportunity__c);
                }

                if ((objRequirement.code__c == 'R1083') && (objRequirement.Trade_Account__c != null)) {
                    tradeAcctIds.add(objRequirement.Trade_Account__c);
                }
            }
        }

        List<LASERCA__Trade_Accounts__c> req1083 = [SELECT Id, name, Credit_Loan_Type_pick__c
                                                    FROM LASERCA__Trade_Accounts__c
                                                    WHERE id IN:tradeAcctIds
                                                    AND  ( Credit_Loan_Type_pick__c = 'Automobile' OR
                                                            Credit_Loan_Type_pick__c ='Mortgage' OR
                                                            Credit_Loan_Type_pick__c ='InstallmentLoan')];

        //Added by Neeraja :  to hold AssignToId for each Opportunity.
        for (Current_Conditions__c objReq : [SELECT Id,Code__c,Requirement__c,Opportunity__c, Opportunity__r.UnisonProcessor__c,
                                                    Trade_Account__c,
                                                    Trade_Account__r.LASERCA__Credit_Loan_Type__c
                                                FROM Current_Conditions__c WHERE Opportunity__c IN:optyIds]) {
            if (objReq.Opportunity__r.UnisonProcessor__c != null) {
                    mapOptyId_assignToId.put(objReq.Opportunity__c, objReq.Opportunity__r.UnisonProcessor__c);
            }

        }

        Map<String, List<EOS_Project_Tasks__mdt>> reqCodeTaskMap = new Map<String, List<EOS_Project_Tasks__mdt>>();
        system.debug('++ lstRequirementCode ' + lstRequirementCode);
        for (EOS_Project_Tasks__mdt objMDT : getEOS_ProjectTasksRequirements(lstRequirementCode)) {
            if (reqCodeTaskMap.get(objMDT.Requirement_Code__c) == null) {
                List<EOS_Project_Tasks__mdt> ptList = new List<EOS_Project_Tasks__mdt>();
                ptList.add(objMDT);
                reqCodeTaskMap.put(objMDT.Requirement_Code__c, ptList);
            } else {
                List<EOS_Project_Tasks__mdt> ptList = reqCodeTaskMap.get(objMDT.Requirement_Code__c);
                ptList.add(objMDT);
                reqCodeTaskMap.put(objMDT.Requirement_Code__c, ptList);
            }

        }
        System.debug('****reqCodeTaskMap: ' + reqCodeTaskMap);

        List<Project_Task__c> lstProjectTasksForInsert = new List<Project_Task__c>();
        for (Current_Conditions__c obj : mapRequirements.values()) {

            if (addTasks(obj,req1083)) {

                List<EOS_Project_Tasks__mdt> ptList = reqCodeTaskMap.get(obj.code__c);
                //Added by Neeraja - To hold the AssignToId value.
                Id assignToId = mapOptyId_assignToId.containsKey(obj.Opportunity__c) ? mapOptyId_assignToId.get(obj.Opportunity__c) : null;

                if (ptList != null) {
                    for (EOS_Project_Tasks__mdt pt : ptList) {
                        lstProjectTasksForInsert.add(ProjectTasksUtil.createProjectTasks(
                                pt.Project_Task_Name__c,
                                pt.MasterLabel,
                                obj.Opportunity__c,
                                obj.Id,
                                assignToId,
                                pt.Prevent_Rollback_from_Complete__c /*Caro Veliz: BUS-155110073*/
                        ));
                    }
                }
            }
        }
        if (lstProjectTasksForInsert.size() > 0) insert lstProjectTasksForInsert;

    }

    private static boolean addTasks(Current_Conditions__c obj, list<LASERCA__Trade_Accounts__c> req1083){
        //Caro Veliz: https://unison-technology.atlassian.net/browse/BUS-155110222
        //This validation only applies to this REQ
        system.debug('BUS-155110222');
        system.debug(obj);
        system.debug(req1083);

        boolean result = false;
        if ( obj.code__c == 'R1083'){

            for ( LASERCA__Trade_Accounts__c ta: req1083 ){
                if (obj.Trade_Account__c == ta.id ){
                    result = true;
                    break;
                }
            }
        }
        else
                result = true;
        return result;
    }






    public static void handleAfterUpdateNotifications(List<Current_Conditions__c> reqlist, Map<Id, Current_Conditions__c> oldMap) {
        system.debug('+++ handleAfterUpdateNotifications notify ');
        List<Current_Conditions__c> reqsToProcess = new List<Current_Conditions__c>();
        for(Current_Conditions__c req : reqlist) {
            if(req.Status__c != oldMap.get(req.Id).Status__c && (req.Status__c == 'Waived' || req.Status__c == 'Completed')) {
                reqsToProcess.add(req);
            }
        }
        if(!reqsToProcess.isEmpty()) {
            UnisonMasterNotifications.ManageNotificationsForRequirements(reqsToProcess, oldMap, true, 'updated');
        }
        /*Caro Veliz: BUS-155110073*/
        UpdateTasksStatus(reqlist,oldMap);
        /* * */
    }

    public static void handleAfterInsertNotifications(List<Current_Conditions__c> reqlist) {
        system.debug('+++ handleAfterInsertNotifications notify ');
        UnisonMasterNotifications.ManageNotificationsForRequirements(reqlist, null, false, 'created');
    }

    //The below function is used to update Opportunity field RSI Count
    public static void updateopportunity(List<Current_Conditions__c> reqlist) {
        System.debug('&&&& updateopportunity for : ' + reqlist);

        Set<String> reqids = new Set<String>();
        //Retrieve all the Opportunity IDs
        for (Current_Conditions__c obj : reqlist) {
            if (obj.Opportunity__c != null) reqids.add(obj.Opportunity__c);
        }
        // Add all the Reuirements in a list which is added to a map with key as Opportunity
        Map<String, List<Current_Conditions__c>> mapofopptoreqlist = new Map<String, List<Current_Conditions__c>>();
        for (Current_Conditions__c obj : [select id,Opportunity__c from Current_Conditions__c where Status__c = 'Document Received, In progress' AND RSI_Eligible__c = TRUE AND Opportunity__c in:reqids]) {
            if (mapofopptoreqlist.containskey(obj.Opportunity__c) == FALSE) {
                List<Current_Conditions__c> toadd = new List<Current_Conditions__c>();
                toadd.add(obj);
                mapofopptoreqlist.put(obj.Opportunity__c, toadd);
            } else if (mapofopptoreqlist.containskey(obj.Opportunity__c) == true) {
                List<Current_Conditions__c> toadd = mapofopptoreqlist.get(obj.Opportunity__c);
                toadd.add(obj);
                mapofopptoreqlist.put(obj.Opportunity__c, toadd);
            }
        }
        //This is to handle in case Opportunity Field is nullified from the Requirement on Update
        for (String ids : reqids) {
            if (mapofopptoreqlist.containskey(ids) == FALSE) {
                mapofopptoreqlist.put(ids, null);
            }
        }
        //The Opportunity is updated.
        List<Opportunity> toupdate = new List<Opportunity>();
        for (String keystring : mapofopptoreqlist.keyset()) {
            if (keystring != null) {
                Opportunity obj = new Opportunity(Id = keystring);
                if (mapofopptoreqlist.get(keystring) == null)
                    obj.RSI_Count__c = 0; else obj.RSI_Count__c = mapofopptoreqlist.get(keystring).size();
                toupdate.add(obj);
            }
        }
        //Check the size of the list before updating
        if (toupdate.size() > 0) {
            update toupdate;
        }

    }

    /*Caro Veliz: BUS-155110073*/
    private static void UpdateTasksStatus(List<Current_Conditions__c> reqlist, Map<Id, Current_Conditions__c> oldMap) {
        List<Current_Conditions__c> reqChanged = new List<Current_Conditions__c>();
        for (Current_Conditions__c req : reqlist) {
            if ((req.Status__c != oldMap.get(req.Id).Status__c) && (req.Status__c == 'Document Received, In progress' || req.Status__c == 'Waived')) {
                reqChanged.add(req);
            }
        }
        List<Project_Task__c> lstProjectTasks = [select id, name,Status__c, Requirement__r.name, Requirement__r.status__c, Requirement__c, Prevent_Rollback_from_Complete__c from Project_Task__c where Requirement__c in :reqChanged];
        for (Project_Task__c task : lstProjectTasks){
            if (!task.Prevent_Rollback_from_Complete__c) {
                if (task.Requirement__r.Status__c == 'Document Received, In progress')
                    task.status__c = 'In Progress'; else
                        task.status__c = task.Requirement__r.status__c;
            }
        }
        Update lstProjectTasks;
    }
    @TestVisible private static List<EOS_Requirements__mdt> getEOSRequirements(Set<String> reqCodes) {
        return [
                Select MasterLabel,Category__c,Type__c,Internal_vs_External__c,
                        Applicant_Type__c,Success_Factor__c,
                RequirementName__c,RSI_Eligible__c, Reason__c 
                from EOS_Requirements__mdt
                where MasterLabel IN:reqCodes
        ];
    }

    @TestVisible private static List<EOS_Project_Tasks__mdt> getEOS_ProjectTasksRequirements(Set<String> lstRequirementCode) {
        return [
                SELECT MasterLabel, DeveloperName,
                        Project_Task_Name__c, Requirement_Code__c, Prevent_Rollback_from_Complete__c
                FROM EOS_Project_Tasks__mdt
                where Requirement_Code__c IN:lstRequirementCode
        ];
    }
}