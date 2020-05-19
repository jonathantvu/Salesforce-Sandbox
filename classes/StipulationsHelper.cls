/**
 * Created by Carolina Veliz on 12/2/2019.
 */

global with sharing class StipulationsHelper {

    webservice static String newStipulations(string opportunityID,
            string tradeAcc,
            string tradeAccName,
            string code,
            string stipulation,
            boolean isSubordination


    ) {
        UnisonMasterNotifications.postStipulations = false;

        system.debug('****new stipulations****');
        system.debug('opportunityID');
        system.debug(opportunityID);
        system.debug('tradeAcc');
        system.debug(tradeAcc);
        system.debug('stipulation');
        system.debug(stipulation);
        system.debug('isSubordination');
        system.debug(isSubordination);

        string result='';

        current_conditions__c req;
        list<current_conditions__c> reqs;

        if (isSubordination){
            reqs = [
                    select id, name, status__c, code__c
                    from current_conditions__c
                    where Trade_Account__c = :tradeAcc and code__c = 'R1107' and status__c <> 'Waived' limit 1];
        }
        else {
            reqs = [
                    select id, name, status__c, code__c
                    from current_conditions__c
                    where Trade_Account__c = :tradeAcc and code__c <> 'R1107' and status__c <> 'Waived' limit 1];
        }




        if (reqs.size()>0) {req = reqs[0];}
        else{
            reqs = [
                    select id, name, status__c
                    from current_conditions__c
                    where Trade_Account__c = :tradeAcc and status__c = 'Waived' limit 1];
            if (reqs.size()>0) {req = reqs[0];}
        }

        if (req == null) {
            EOS_Requirements__mdt reqMetadata =[Select MasterLabel, RequirementName__c
            from EOS_Requirements__mdt
            where type__c = 'Stipulation' and RequirementName__c = :stipulation];

            if (reqMetadata != null){
                AddNewStipulation( opportunityID, tradeAcc, stipulation);
                result = 'Stipulation ['+ stipulation + '] for trade account [' + tradeAccName +'] was created.';
            }

        }
        else {
            if (req.status__c == 'Waived'){
                AddNewStipulation( opportunityID, tradeAcc, stipulation);
                result = 'Stipulation ['+ stipulation + '] for trade account [' + tradeAccName +'] was created, prior Stipulation is waived.';
            }
            /*else if (toBePaidOff == false){
                req.status__c = 'Waived';
                update req;
                result = 'Stipulation ['+ stipulation + '] for trade account [' + tradeAccName +'] was changed to waived.';
            }*/
            else {
                code = getCode(stipulation);
                if (string.isNotEmpty(code) &&  req.code__c != code ) {
                    req.code__c = code;
                    req.requirement__c = stipulation;
                    update req;
                    result = 'Stipulation ['+ stipulation + '] for trade account [' + tradeAccName +'] was updated.';
                }
            }
        }

        return result;
    }


    webservice static String waiveStipulations( string stipulationID ) {
        UnisonMasterNotifications.postStipulations = false;
        system.debug('****new stipulations****');
        system.debug('stipulation');
        system.debug(stipulationID);


        string result='nothing happened';

        list<current_conditions__c> reqs = [
                select id, name, requirement__c, status__c,
                        trade_account__r.name
                from current_conditions__c
                where id = :stipulationID and status__c <> 'Waived'];


        for( current_conditions__c req : reqs){
            req.status__c = 'Waived';
            result = 'Stipulation ['+ req.requirement__c + '] for trade account [' + req.trade_account__r.name +'] was waived.';
        }

        update reqs;

        return result;
    }
    webservice static string postToChatter( string post ) {
        return 'posted to chatter';

    }

    private static string getCode(string stipulation){
        List<EOS_Requirements__mdt> reqMetadataList =[Select MasterLabel, RequirementName__c
        from EOS_Requirements__mdt
        where type__c = 'Stipulation' and RequirementName__c = :stipulation limit 1];

        string code;
        if (reqMetadataList.size()>0){
            if (reqMetadataList[0].MasterLabel != null){
                code = reqMetadataList[0].MasterLabel;
            }
        }
        return code;
    }

    private static void AddNewStipulation(string opportuniID,
                                            string tradeAcc,
                                            string stipulation
                                            ){

        current_conditions__c req = new current_conditions__c();
        string code = getCode(stipulation);

        if (string.isNotEmpty(code)){
            req.code__c = code;
            req.Trade_Account__c = tradeAcc;
            req.opportunity__c = opportuniID;
            system.debug(req);
            if (!Test.isRunningTest()) 
                insert req;
        }
    }
    /*
    private static List<Current_Conditions__c> processStipulations(List<Current_Conditions__c> reqlist) {

        Map<string, Current_Conditions__c> existingReqsMap = new Map<string, Current_Conditions__c>();
        List<Current_Conditions__c> reqsFromOpp = new List<Current_Conditions__c>();
        List<Current_Conditions__c> reqToProcess = new List<Current_Conditions__c>();
        Set<string> opps = new set<string>();

        for (Current_Conditions__c req : reqlist) {
            if (req.Opportunity__c != null) {
                reqsFromOpp.add(req);
                opps.add(req.Opportunity__c);
            }
        }

        List<Current_Conditions__c> existingReqs = [
                select createddate, id, requirement__c, code__c, Type__c, status__c, Trade_Account__c, opportunity__c
                from current_conditions__c
                where opportunity__c in :opps
                and type__c = 'Stipulation'
                order by createddate
        ];

//Find if there is a
        for (Current_Conditions__c req : existingReqs) {
            existingReqsMap.put(req.opportunity__c + '-' + req.Trade_Account__c, req);
        }



        for (Current_Conditions__c req : reqlist) {
            if ((req.code__c == '__skuid') ||
                    (req.code__c == '__skuidWaive')) {

//If the request comes from Skuid, we need to find out if the stipulation already exists
                Current_Conditions__c tempReq = existingReqsMap.get(req.opportunity__c + '-' + req.Trade_Account__c);
                if (tempReq != null) {
                    req.id = tempReq.id;
                }

                if (req.code__c == '__skuid') {
                    string code = resMap.get(req.Requirement__c);
                    system.debug(code);
                    if (code != null) {
                        req.code__c = code;
                        reqToProcess.add(req);
                    }
                } else {
//The trade accounts that are not to be paid off, should waived their stipulations,
//so the stipulations must exist
                    if (tempReq != null) {
                        req.status__c = 'Waived';
                    }
                    reqToProcess.add(req);
                }
            } else {
                reqToProcess.add(req);
            }
        }


        system.debug('*** reqToProcess ***');
        system.debug(reqToProcess.size());
        system.debug(reqToProcess);
        return reqToProcess;
    }


    @TestVisible private static List<EOS_Requirements__mdt> getStipulations() {
        return [
                Select MasterLabel, RequirementName__c
                from EOS_Requirements__mdt
                where type__c = 'Stipulation'
        ];
    }
    */

}