/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Neeraja Cherukuri
 *  Create date:  March 17 2019
 *   Details
 *  -------------------------------------------------------------------------
 *  Apex class to handle all the Reusable Methods to add additional functionality for Creating Requirements,
 *  Custom Validation Messages,Passbook Functionality .
 *   
 *  Update History
 *  ----------------------------------------------------------------------------
 *  Neeraja Cherukuri 4/12/2019--> Modified the OpportunityUtilityClass by adding new Methods for Closing+PostClosing+Passbook+SFGating.
 * ---------------------------------------------------------------------------
 ************************************************************************************/

public class OpportunityUtilityClass
{
    
    private static final ID IDHomeBuyer = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
    private static final ID IDHomeOwner = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();    

    public static void opportunitySFGating(List<Opportunity> opplist, Map<Id,Opportunity> oldMap)
    {
        List<Id> lstOptyIds =  new List<Id>();

        for(Opportunity objOpty :  opplist)
        {
            if(objOpty.StageName != oldMap.get(objOpty.Id).StageName )


            {
                lstOptyIds.add(objOpty.Id);
            }
        }


        Map<String, String> mapOpty_SucessFactors = new Map<String, String>();
        List<String> lstSuccessFactors =  new List<String>();
        Map<Id, Id> mapOptyId_SFId = new Map<Id, Id>();

        for(Opportunity_Stage_Vs_SuccessFactor__mdt objOptyStage : [SELECT MasterLabel, Success_Factor__c
        FROM Opportunity_Stage_Vs_SuccessFactor__mdt])
        {
            mapOpty_SucessFactors.put(objOptyStage.MasterLabel, objOptyStage.Success_Factor__c);
        }

        System.debug('====mapOpty_SucessFactors==='+mapOpty_SucessFactors);

        for(Opportunity objOpty :  opplist)
        {
            if(objOpty.StageName != oldMap.get(objOpty.Id).StageName )
            {
                if(mapOpty_SucessFactors.containsKey(objOpty.StageName))
                {
                    for(String str : mapOpty_SucessFactors.get(objOpty.StageName).split(';'))
                    {
                        lstSuccessFactors.add(str);
                    }
                }
            }
        }


        if(lstSuccessFactors.size() > 0)
        {
            for(Success_Factor__c objSF : [SELECT Id, Opportunity__c, Status__c, Success_Factor__c
            FROM Success_Factor__c
            WHERE Opportunity__c IN:lstOptyIds
            AND Success_Factor__c IN : lstSuccessFactors
            ])
            {
                if(objSF.Status__c != 'Completed')
                {
                    mapOptyId_SFId.put(objSF.Opportunity__c, objSF.Id);
                }
            }
        }

        for(Opportunity objOpty : opplist)
        {
            if(mapOptyId_SFId.containsKey(objOpty.Id) )
            {
              //  if(objOpty.Passbook_Status__c != 'Approve'||(!objOpty.IA_Passbook_Override__c && objOpty.IA_Passbook_Override_Reasons__c == Null))

               
                    objOpty.addError(Label.Opty_Stage_Change_Error);
                
            }
        }

    }
    
    public static void createIDDOppRequirements(List<Opportunity> newOppList){
        Set<Id> oppids = new Set<Id>();
        Map<Id,Set<String>> existingreqsatopp = new map<Id,set<String>>();
        List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();
        List<Current_Conditions__c> reqsForUpdate = new List<Current_Conditions__c>();
        List<Project_Task__c> tasksForUpdate = new List<Project_Task__c>();
        for(Opportunity opp: newOppList){
            if(opp.Id != Null){
                oppids.add(opp.id);
            }
        }
        // Opportunity list
        List<Opportunity> opplist = [
                SELECT Id,StageName,RecordTypeId,Title_Held__c,Post_Close_Home_Inspection_Check__c,
                Greenlight_Requires_Second_Appraisal__c,Final_Title_Held__c,SEND_TO_ENCOMPASS__c,Payment_Monthly_HOA__c,
                New_HomeOwner_Purchase_Date__c,NHO_Expected_Close_Date__c,Qualifies_for_New_HomeOwner_Pricing__c,
                (SELECT Id, Declaration_Power_of_Attorney__c FROM Applications__r),
                (SELECT Id, Property_Type__c, Property_State__c, Property_New_Construction_Flag__c FROM Properties__r),
                (SELECT Id,Code__c, Opportunity__c FROM Current_Conditions__r),
                (SELECT Id, Success_Factor__c from Risk_Factors__r)
                FROM Opportunity
                WHERE Id =: oppids];

        Map<Id, Id> r1008PerOpp = new Map<Id, Id>();
        Map<Id, Id> r1040PerOpp = new Map<Id, Id>();
        Map<Id, Id> r1125PerOpp = new Map<Id, Id>();
        Set<Id> rReqIds = new Set<Id>();
        for(Opportunity oppobj: opplist){
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
                        if (reqscreated.Code__c == 'R1008') {
                            r1008PerOpp.put(oppobj.Id, reqscreated.Id);
                            rReqIds.add(reqscreated.Id);
                        }
                        if (reqscreated.Code__c == 'R1040') {
                            r1040PerOpp.put(oppobj.Id, reqscreated.Id);
                            rReqIds.add(reqscreated.Id);
                        }
                        if (reqscreated.Code__c == 'R1125') {
                            r1125PerOpp.put(oppobj.Id, reqscreated.Id);
                            rReqIds.add(reqscreated.Id);
                        }
                    }
                }
            }
        }
        
        Map<Id, List<Project_Task__c>> tasksmap = new Map<Id, List<Project_Task__c>>();
        for (Project_Task__c task : [SELECT Id, Requirement__c FROM Project_Task__c WHERE Requirement__c IN :rReqIds]) {
            if (!tasksmap.containsKey(task.Requirement__c)) {
                tasksmap.put(task.Requirement__c, new List<Project_Task__c>());
            }
            tasksmap.get(task.Requirement__c).add(task);
        }
        
        for(Opportunity oppobj: opplist)
        {            
            for(EOS_Requirements__mdt eosMDT: [Select MasterLabel,Dupallowed__c from EOS_Requirements__mdt]){
                if(oppobj.StageName == 'Investment Due Diligence' && oppobj.Id != Null){
                    if (!existingreqsatopp.containsKey(oppobj.Id)) {
                        existingreqsatopp.put(oppobj.Id, new Set<String>());
                    }
                    system.debug('****oppobj.Id*****'+oppobj.Id);
                    system.debug('****existingreqsatopp*****'+existingreqsatopp);
                    system.debug('****eosMDT*****'+eosMDT);
                    // R1008, R1040, R1125
                    if (eosMDT.MasterLabel == 'R1008' && oppobj.Id != Null) {
                        if (eosMDT.Dupallowed__c == True || !existingreqsatopp.containsKey(oppobj.Id) || !existingreqsatopp.get(oppobj.Id).contains('R1008')) {
                            Current_Conditions__c cc = new Current_Conditions__c(Opportunity__c = oppobj.Id, Code__c = 'R1008');
                            if (oppobj.Qualifies_for_New_HomeOwner_Pricing__c == true) {
                                cc.Status__c = 'Waived';
                            }
                            reqsForInsert.add(cc);
                        } else {
                            if (oppobj.Qualifies_for_New_HomeOwner_Pricing__c == true && r1008PerOpp.containsKey(oppobj.Id)) {
                                reqsForUpdate.add(new Current_Conditions__c(Id = r1008PerOpp.get(oppobj.Id), Status__c = 'Waived'));
                                // tasks
                                if (tasksmap.containsKey(r1008PerOpp.get(oppobj.Id))) {
                                    for (Project_Task__c task : tasksmap.get(r1008PerOpp.get(oppobj.Id))) {
                                        task.Status__c = 'Waived';
                                        tasksForUpdate.add(task);
                                    }
                                }
                            }
                        }
                    }
                    if (eosMDT.MasterLabel == 'R1040' && oppobj.Id != Null) {
                        if (eosMDT.Dupallowed__c == True || !existingreqsatopp.containsKey(oppobj.Id) || !existingreqsatopp.get(oppobj.Id).contains('R1040')) {
                            Current_Conditions__c cc = new Current_Conditions__c(Opportunity__c = oppobj.Id, Code__c = 'R1040');
                            if (oppobj.Qualifies_for_New_HomeOwner_Pricing__c == true) {
                                cc.Status__c = 'Waived';
                            }
                            reqsForInsert.add(cc);
                        } else {
                            if (oppobj.Qualifies_for_New_HomeOwner_Pricing__c == true && r1040PerOpp.containsKey(oppobj.Id)) {
                                reqsForUpdate.add(new Current_Conditions__c(Id = r1040PerOpp.get(oppobj.Id), Status__c = 'Waived'));
                                // tasks
                                if (tasksmap.containsKey(r1040PerOpp.get(oppobj.Id))) {
                                    for (Project_Task__c task : tasksmap.get(r1040PerOpp.get(oppobj.Id))) {
                                        task.Status__c = 'Waived';
                                        tasksForUpdate.add(task);
                                    }
                                }
                            }
                        }
                    }
                    if (eosMDT.MasterLabel == 'R1125' && oppobj.Id != Null) {
                        if (eosMDT.Dupallowed__c == True || !existingreqsatopp.containsKey(oppobj.Id) || !existingreqsatopp.get(oppobj.Id).contains('R1125')) {
                            if (oppobj.Qualifies_for_New_HomeOwner_Pricing__c == true) {
                                Current_Conditions__c cc = new Current_Conditions__c(Opportunity__c = oppobj.Id, Code__c = 'R1125');
                                reqsForInsert.add(cc);
                            }
                        } else {
                            if (oppobj.Qualifies_for_New_HomeOwner_Pricing__c == false && r1125PerOpp.containsKey(oppobj.Id)) {
                                reqsForUpdate.add(new Current_Conditions__c(Id = r1125PerOpp.get(oppobj.Id), Status__c = 'Waived'));
                                // tasks
                                if (tasksmap.containsKey(r1125PerOpp.get(oppobj.Id))) {
                                    for (Project_Task__c task : tasksmap.get(r1125PerOpp.get(oppobj.Id))) {
                                        task.Status__c = 'Waived';
                                        tasksForUpdate.add(task);
                                    }
                                }
                            }
                        }
                    }
                    /*if (oppobj.Qualifies_for_New_HomeOwner_Pricing__c == true) {
                        if (!existingreqsatopp.containsKey(oppobj.Id) || (!existingreqsatopp.get(oppobj.Id).contains('R1008') && eosMDT.MasterLabel == 'R1008' && oppobj.Id != Null && eosMDT.MasterLabel != Null) || (existingreqsatopp.get(oppobj.Id).contains('R1008') && eosMDT.MasterLabel == 'R1008' && eosMDT.Dupallowed__c == True))
                        {
                            reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1008', Status__c='Waived'));
                        }
                        if (!existingreqsatopp.containsKey(oppobj.Id) || (!existingreqsatopp.get(oppobj.Id).contains('R1040') && eosMDT.MasterLabel == 'R1040' && oppobj.Id != Null && eosMDT.MasterLabel != Null) || (existingreqsatopp.get(oppobj.Id).contains('R1040') && eosMDT.MasterLabel == 'R1040' && eosMDT.Dupallowed__c == True))
                        {
                            reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1040', Status__c='Waived'));
                        }
                        if (!existingreqsatopp.containsKey(oppobj.Id) || (!existingreqsatopp.get(oppobj.Id).contains('R1125') && eosMDT.MasterLabel == 'R1125' && oppobj.Id != Null && eosMDT.MasterLabel != Null) || (existingreqsatopp.get(oppobj.Id).contains('R1125') && eosMDT.MasterLabel == 'R1125' && eosMDT.Dupallowed__c == True))
                        {
                            reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1125'));
                        }
                    } else {
                        if (!existingreqsatopp.containsKey(oppobj.Id) || (!existingreqsatopp.get(oppobj.Id).contains('R1008') && eosMDT.MasterLabel == 'R1008' && oppobj.Id != Null && eosMDT.MasterLabel != Null) || (existingreqsatopp.get(oppobj.Id).contains('R1008') && eosMDT.MasterLabel == 'R1008' && eosMDT.Dupallowed__c == True))
                        {
                            reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1008'));
                        }
                        if (!existingreqsatopp.containsKey(oppobj.Id) || (!existingreqsatopp.get(oppobj.Id).contains('R1040') && eosMDT.MasterLabel == 'R1040' && oppobj.Id != Null && eosMDT.MasterLabel != Null) || (existingreqsatopp.get(oppobj.Id).contains('R1040') && eosMDT.MasterLabel == 'R1040' && eosMDT.Dupallowed__c == True))
                        {
                            reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1040'));
                        }
                    }*/

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
					
                    //Homeowner and Homebuyer Reqs
                    if(oppobj.RecordTypeId == IDHomeOwner || oppobj.RecordTypeId == IDHomeBuyer){
                    	if(!existingreqsatopp.get(oppobj.Id).contains('R1126') && eosMDT.MasterLabel == 'R1126' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1126') && eosMDT.MasterLabel == 'R1126')){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1126'));}
                    }
                    //HomeOwner Only Reqs
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
                    //Homebuyer Only Reqs
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

                                system.debug(prop);
                                if ((oppobj.StageName == 'Investment Due Diligence') && (prop.Property_New_Construction_Flag__c == TRUE)) {
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
            }
        }
        if(reqsForInsert.size()>0) {
            if (!test.isRunningTest()) {
                system.debug('reqsForInsert ' + reqsForInsert);
                insert reqsForInsert;
            }
        }
        if(reqsForUpdate.size()>0) {
            if (!test.isRunningTest()) {
                system.debug('reqsForUpdate ' + reqsForUpdate);
                update reqsForUpdate;
            }
        }
        if(tasksForUpdate.size()>0) {
            if (!test.isRunningTest()) {
                system.debug('tasksForUpdate ' + tasksForUpdate);
                update tasksForUpdate;
            }
        }
        
    }

    public static void switchAppraisalReqs(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        // This method switches the R1008 / R1040 & R1125 statuses when the Qualifies_for_New_HomeOwner_Pricing__c changes

        // First, which opportunities do we need to work with?
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity newOpp : newList) {
            if (newOpp.StageName == 'Investment Due Diligence') {
                Opportunity oldOpp = oldMap.get(newOpp.Id);
                if (newOpp.Qualifies_for_New_HomeOwner_Pricing__c == true && oldOpp.Qualifies_for_New_HomeOwner_Pricing__c != true) {
                    oppIds.add(newOpp.Id);
                }
                if (newOpp.Qualifies_for_New_HomeOwner_Pricing__c != true && oldOpp.Qualifies_for_New_HomeOwner_Pricing__c == true) {
                    oppIds.add(newOpp.Id);
                }
            }
        }

        if (oppIds.size() > 0) {
            Set<String> reqCodes = new Set<String> { 'R1008', 'R1040', 'R1125' };

            // Let's obtain existing Requirements to update if needed
            Map<Id, List<Current_Conditions__c>> oppReqs = new Map<Id, List<Current_Conditions__c>>();
            for (Current_Conditions__c req : [SELECT Id, Opportunity__c, Code__c, Status__c,
                                                        (SELECT Id, Status__c FROM Project_Tasks__r)
                                                FROM Current_Conditions__c 
                                                WHERE Opportunity__c IN :oppIds AND Code__c IN :reqCodes])
            {
                if (!oppReqs.containsKey(req.Opportunity__c)) {
                    oppReqs.put(req.Opportunity__c, new List<Current_Conditions__c>());
                }
                oppReqs.get(req.Opportunity__c).add(req);
            }

            List<Current_Conditions__c> reqsToUpsert = new List<Current_Conditions__c>();
            List<Project_Task__c> tasksToUpdate = new List<Project_Task__c>();

            for (Opportunity newOpp : newList) {
                if (newOpp.StageName == 'Investment Due Diligence') { // Only on this stage
                    Opportunity oldOpp = oldMap.get(newOpp.Id);
                    // If we switch from false to true, we waive existing R1008 & R1040 and we create R1125 (if it exists, we just update them to 'In Progress')
                    if (newOpp.Qualifies_for_New_HomeOwner_Pricing__c == true && oldOpp.Qualifies_for_New_HomeOwner_Pricing__c != true) {
                        if (oppReqs.containsKey(newOpp.Id)) {
                            boolean R1125Found = false;
                            for (Current_Conditions__c req : oppReqs.get(newOpp.Id)) {
                                if (req.Code__c == 'R1008' || req.Code__c == 'R1040') {
                                    if (req.Status__c == 'Document Received, In progress') {
                                        req.Status__c = 'Waived';
                                        reqsToUpsert.add(req);
                                        for (Project_Task__c pt : req.Project_Tasks__r) {
                                            if (pt.Status__c != 'Completed' && pt.Status__c != 'Waived') {
                                                pt.Status__c = 'Waived';
                                                tasksToUpdate.add(pt);
                                            }
                                        }
                                    }
                                }
                                if (req.Code__c == 'R1125') {
                                    if (req.Status__c == 'Waived') {
                                        req.Status__c = 'Document Received, In progress';
                                        reqsToUpsert.add(req);
                                        for (Project_Task__c pt : req.Project_Tasks__r) {
                                            if (pt.Status__c != 'Completed' && pt.Status__c != 'In Progress') {
                                                pt.Status__c = 'In Progress';
                                                tasksToUpdate.add(pt);
                                            }
                                        }
                                    }
                                    R1125Found = true;
                                }
                            }
                            if (!R1125Found) {
                                reqsToUpsert.add(new Current_Conditions__c(Opportunity__c = newOpp.Id, Code__c = 'R1125'));
                            }
                        }
                    }
                    // If we switch from true to false, we waive existing R1125 and we create R1008 & R1040 (if it exists, we just update them to 'In Progress')
                    if (newOpp.Qualifies_for_New_HomeOwner_Pricing__c != true && oldOpp.Qualifies_for_New_HomeOwner_Pricing__c == true) {
                        if (oppReqs.containsKey(newOpp.Id)) {
                            boolean R1008Found = false;
                            boolean R1040Found = false;
                            for (Current_Conditions__c req : oppReqs.get(newOpp.Id)) {
                                if (req.Code__c == 'R1008') {
                                    if (req.Status__c == 'Waived') {
                                        req.Status__c = 'Document Received, In progress';
                                        reqsToUpsert.add(req);
                                        for (Project_Task__c pt : req.Project_Tasks__r) {
                                            if (pt.Status__c != 'Completed' && pt.Status__c != 'In Progress') {
                                                pt.Status__c = 'In Progress';
                                                tasksToUpdate.add(pt);
                                            }
                                        }
                                    }
                                    R1008Found = true;
                                }
                                if (req.Code__c == 'R1040') {
                                    if (req.Status__c == 'Waived') {
                                        req.Status__c = 'Document Received, In progress';
                                        reqsToUpsert.add(req);
                                        for (Project_Task__c pt : req.Project_Tasks__r) {
                                            if (pt.Status__c != 'Completed' && pt.Status__c != 'In Progress') {
                                                pt.Status__c = 'In Progress';
                                                tasksToUpdate.add(pt);
                                            }
                                        }
                                    }
                                    R1040Found = true;
                                }
                                if (req.Code__c == 'R1125') {
                                    if (req.Status__c == 'Document Received, In progress') {
                                        req.Status__c = 'Waived';
                                        reqsToUpsert.add(req);
                                        for (Project_Task__c pt : req.Project_Tasks__r) {
                                            if (pt.Status__c != 'Completed' && pt.Status__c != 'Waived') {
                                                pt.Status__c = 'Waived';
                                                tasksToUpdate.add(pt);
                                            }
                                        }
                                    }
                                }
                            }
                            if (!R1008Found) {
                                reqsToUpsert.add(new Current_Conditions__c(Opportunity__c = newOpp.Id, Code__c = 'R1008'));
                            }
                            if (!R1040Found) {
                                reqsToUpsert.add(new Current_Conditions__c(Opportunity__c = newOpp.Id, Code__c = 'R1040'));
                            }
                        }
                    }
                }
            }

            if (reqsToUpsert.size() > 0) {
                upsert reqsToUpsert;
            }

            if (tasksToUpdate.size() > 0) {
                update tasksToUpdate;
            }
        }

    }
    
    public static void createClosingOppRequirements(List<Opportunity> newOppList){
        Set<Id> oppids = new Set<Id>();
        Map<Id,Set<String>> existingreqsatopp = new map<Id,set<String>>();
        List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();
        for(Opportunity opp: newOppList){
            if(opp.Id != Null){
                oppids.add(opp.id);
            }
        }
        // Opportunity list
        List<Opportunity> opplist = [
                SELECT Id,StageName,RecordTypeId,Title_Held__c,Post_Close_Home_Inspection_Check__c,
                Greenlight_Requires_Second_Appraisal__c,Final_Title_Held__c,SEND_TO_ENCOMPASS__c,Payment_Monthly_HOA__c,
                (SELECT Id, Declaration_Power_of_Attorney__c FROM Applications__r),
                (SELECT Id, Property_Type__c, Property_State__c FROM Properties__r),
                (SELECT Id,Code__c, Opportunity__c FROM Current_Conditions__r),
                (SELECT Id, Success_Factor__c from Risk_Factors__r)
                FROM Opportunity
                WHERE Id =: oppids];

        for(Opportunity oppobj: opplist){

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
            for(EOS_Requirements__mdt eosMDT: [Select MasterLabel,Dupallowed__c from EOS_Requirements__mdt]){                
                if(oppobj.StageName == 'Closing'){
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1018') && eosMDT.MasterLabel == 'R1018' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1018') && eosMDT.MasterLabel == 'R1018' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1018'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1032') && eosMDT.MasterLabel == 'R1032' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1032') && eosMDT.MasterLabel == 'R1032' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1032'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1030') && eosMDT.MasterLabel == 'R1030' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1030') && eosMDT.MasterLabel == 'R1030' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1030'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1124') && eosMDT.MasterLabel == 'R1124' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1124') && eosMDT.MasterLabel == 'R1124' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1124'));}
					if(!existingreqsatopp.get(oppobj.Id).contains('R1127') && eosMDT.MasterLabel == 'R1127' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1127') && eosMDT.MasterLabel == 'R1127')){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1127'));}
                    
                    if(oppobj.Final_Title_Held__c == 'In Trust'){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1116') && eosMDT.MasterLabel == 'R1116' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1116') && eosMDT.MasterLabel == 'R1116' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1116'));}
                    }

                    if(oppobj.Post_Close_Home_Inspection_Check__c == True){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1089') && eosMDT.MasterLabel == 'R1089' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1089') && eosMDT.MasterLabel == 'R1089' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1089'));}
                    }

                    /* Moved to the Offer stage
                    if(oppobj.RecordTypeId == IDHomeOwner){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1072') && eosMDT.MasterLabel == 'R1072' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1072') && eosMDT.MasterLabel == 'R1072' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1072'));}
                    } */

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
            }
        }
        if(reqsForInsert.size()>0) {
            if (!test.isRunningTest()) {
                system.debug('reqsForInsert ' + reqsForInsert);
                insert reqsForInsert;
            }
        }
    }

    public static void createOfferOppRequirements(List<Opportunity> newOppList){
        Set<Id> oppids = new Set<Id>();
        Map<Id,Set<String>> existingreqsatopp = new map<Id,set<String>>();
        List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();
        for(Opportunity opp: newOppList){
            if(opp.Id != Null){
                oppids.add(opp.id);
            }
        }
        // Opportunity list
        List<Opportunity> opplist = [
                SELECT Id,StageName,RecordTypeId,Title_Held__c,Post_Close_Home_Inspection_Check__c,
                Greenlight_Requires_Second_Appraisal__c,Final_Title_Held__c,SEND_TO_ENCOMPASS__c,Payment_Monthly_HOA__c,
                (SELECT Id, Declaration_Power_of_Attorney__c FROM Applications__r),
                (SELECT Id, Property_Type__c, Property_State__c FROM Properties__r),
                (SELECT Id,Code__c, Opportunity__c FROM Current_Conditions__r),
                (SELECT Id, Success_Factor__c from Risk_Factors__r)
                FROM Opportunity
                WHERE Id =: oppids];

        for(Opportunity oppobj: opplist){

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
            for(EOS_Requirements__mdt eosMDT: [Select MasterLabel,Dupallowed__c from EOS_Requirements__mdt]){                
                if(oppobj.StageName == 'Offer'){
                    if(oppobj.RecordTypeId == IDHomeOwner){
                        if(!existingreqsatopp.get(oppobj.Id).contains('R1072') && eosMDT.MasterLabel == 'R1072' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1072') && eosMDT.MasterLabel == 'R1072' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1072'));}
                    }
                }
            }
        }
        if(reqsForInsert.size()>0) {
            if (!test.isRunningTest()) {
                system.debug('reqsForInsert ' + reqsForInsert);
                insert reqsForInsert;
            }
        }
    }

    public static void createPostClosingOppRequirements(List<Opportunity> newOppList){
        Set<Id> oppids = new Set<Id>();
        Map<Id,Set<String>> existingreqsatopp = new map<Id,set<String>>();
        List<Current_Conditions__c> reqsForInsert = new List<Current_Conditions__c>();
        for(Opportunity opp: newOppList){
            if(opp.Id != Null){
                oppids.add(opp.id);
            }
        }
        // Opportunity list
        List<Opportunity> opplist = [
                SELECT Id,StageName,RecordTypeId,Title_Held__c,Post_Close_Home_Inspection_Check__c,
                Greenlight_Requires_Second_Appraisal__c,Final_Title_Held__c,SEND_TO_ENCOMPASS__c,Payment_Monthly_HOA__c,
                (SELECT Id, Declaration_Power_of_Attorney__c FROM Applications__r),
                (SELECT Id, Property_Type__c, Property_State__c FROM Properties__r),
                (SELECT Id,Code__c, Opportunity__c FROM Current_Conditions__r),
                (SELECT Id, Success_Factor__c from Risk_Factors__r)
                FROM Opportunity
                WHERE Id =: oppids];

        for(Opportunity oppobj: opplist){

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
            for(EOS_Requirements__mdt eosMDT: [Select MasterLabel,Dupallowed__c from EOS_Requirements__mdt]){                
                if(oppobj.StageName == 'Post-Closing'){
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1017') && eosMDT.MasterLabel == 'R1017' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null || (existingreqsatopp.get(oppobj.Id).contains('R1017') && eosMDT.MasterLabel == 'R1017' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1017'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1019') && eosMDT.MasterLabel == 'R1019' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1019') && eosMDT.MasterLabel == 'R1019' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1019'));}
                    if(!existingreqsatopp.get(oppobj.Id).contains('R1090') && eosMDT.MasterLabel == 'R1090' && oppobj.Id != Null && existingreqsatopp.keyset().contains(oppobj.Id) && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1090') && eosMDT.MasterLabel == 'R1090' && eosMDT.Dupallowed__c == True)){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1090'));}
					if(!existingreqsatopp.get(oppobj.Id).contains('R1128') && eosMDT.MasterLabel == 'R1128' && oppobj.Id != Null && existingreqsatopp.get(oppobj.Id) != Null && eosMDT.MasterLabel != Null|| (existingreqsatopp.get(oppobj.Id).contains('R1128') && eosMDT.MasterLabel == 'R1128')){reqsForInsert.add(new Current_Conditions__c(Opportunity__c=oppobj.Id, Code__c='R1128'));}                    
                }
            }
        }
        if(reqsForInsert.size()>0) {
            if (!test.isRunningTest()) {
                system.debug('reqsForInsert ' + reqsForInsert);
                insert reqsForInsert;
            }
        }
        
    }    
        
}