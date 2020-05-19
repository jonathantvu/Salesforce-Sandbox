/**
 *  About
 *  -----
 *  Author: Sundar Subramaniam
 *  Create date: Tue Apr 16 2019
 *
  *  Details
 *  -----
 *  Apex class to handle all the events raised by PropertyTrigger
 *
 *  Update History
 *  -----
 *
 *
 *  -----
 *
 **/
public class PropertyTriggerHandler{
    /**
     *  About
     *  -----
     *  Author: Sundar Subramaniam
     *
     *  Details
     *  -----
     *  Method to take care of all functionalities when AFTER INSERT fires
    **/
    // Dictionary added for: https://unison-technology.atlassian.net/browse/BUS-155110785
    private static final Set<String> floodZoneCodes = new Set<String> {'A','AE','AH','AO','AR','A1','A2','A3','A4','A5','A6','A7','A8','A9','A10',
            'A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30',
            'A99','V','VE','V1','V2','V3','V4','V5','V6','V7','V8','V9','V10','V11','V12','V13','V14','V15','V16','V17','V18', 'V19','V20',
            'V21','V22','V23','V24','V25','V26','V27','V28','V29','V30'};
    public static void handleAfterInsert(List<Property__c> newList){
        Set<Id> oppId = new Set<Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        Set<Id> opportunityIds = new Set<Id>();
        List<Property__c> propertiesForFloodZone = new List<Property__c>();

        for(Property__c rec: newList){
            if(rec.Opportunity__c != null)
            oppId.add(rec.Opportunity__c);

            if(rec.Is_NOO__c == true) {
                if(rec.Opportunity__c != null) {
                    opportunityIds.add(rec.Opportunity__c);
                }
            }

            if(rec.Property_Flood_Zone__c != null && rec.Opportunity__c != null && floodZoneCodes.contains(rec.Property_Flood_Zone__c)) {
                propertiesForFloodZone.add(rec);
            }
        }

        if(!propertiesForFloodZone.isEmpty()) {
            createFloorInsuranceRequirement(propertiesForFloodZone);
        }

        if(!opportunityIds.isEmpty()) {
            checkIsNOO(opportunityIds);
        }

        if(oppId.size() > 0){
            oppMap = new Map<Id,Opportunity>([SELECT Id, Name, Property_Street_Number_and_Name__c, Property_City__c, Property_State__c,Property_Zip_Code__c,Property_County__c,Property_Type__c, Probability, Property__c FROM Opportunity WHERE Id IN: oppId]);
        }

        for(Property__c rec: newList){
            if(rec.Opportunity__c != null){
                Opportunity opp = new Opportunity();
                opp.Id = rec.Opportunity__c;
                boolean flag = false;
                if(oppMap.containsKey(rec.Opportunity__c) && rec.Property_Type__c == oppMap.get(rec.Opportunity__c).Property_Type__c && oppMap.get(rec.Opportunity__c).Probability > 0 && oppMap.get(rec.Opportunity__c).Probability < 100){
                    if(rec.Opportunity__c != NULL && oppMap.get(rec.Opportunity__c).Property__c == NULL){
                        opp.Property__c = rec.Id;
                        flag = true;
                    }
                    if(rec.Property_Street_Number_and_Name__c != null ){
                        opp.Property_Street_Number_and_Name__c = rec.Property_Street_Number_and_Name__c;
                        flag = true;
                    }
                    if(rec.Property_City__c != null ){
                        opp.Property_City__c = rec.Property_City__c;
                        flag = true;
                    }
                    if(rec.Property_State__c != null ){
                        opp.Property_State__c = rec.Property_State__c;
                        flag = true;
                    }
                    if(rec.Property_Zip_Code__c != null){
                        opp.Property_Zip_Code__c = rec.Property_Zip_Code__c;
                        flag = true;
                    }
                    if(rec.Property_County__c != null){
                        opp.Property_County__c = rec.Property_County__c;
                        flag = true;
                    }

                    if(flag){
                        updateOppList.add(opp);
                    }
                }
            }
        }

        if(updateOppList.size() > 0){
            update updateOppList;
        }
    }

     /**
     *  About
     *  -----
     *  Author: Sundar Subramaniam
     *
     *  Details
     *  -----
     *  Method to take care of all functionalities when AFTER UPDATE fires
     *
    **/
    public static void handleAfterUpdate(List<Property__c> newList, Map<Id, Property__c> oldMap) {
        Set<Id> oppId = new Set<Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<Recorded_Information__c> updateRecInfList = new List<Recorded_Information__c>();
        Set<Id> opportunityIds = new Set<Id>();
        List<Property__c> propertiesForFloodZone = new List<Property__c>();

        for(Property__c rec: newList){
            if(rec.Opportunity__c != null)
            oppId.add(rec.Opportunity__c);

            if(rec.Property_Number_of_Units__c != null && rec.Property_Number_of_Units__c != oldMap.get(rec.Id).Property_Number_of_Units__c
                    && rec.Property_Number_of_Units__c > 2) {
                if(rec.Opportunity__c != null) {
                    opportunityIds.add(rec.Opportunity__c);
                }
            }

            if(rec.Property_Flood_Zone__c != null && oldMap.get(rec.Id).Property_Flood_Zone__c != rec.Property_Flood_Zone__c
                    && rec.Opportunity__c != null && floodZoneCodes.contains(rec.Property_Flood_Zone__c)) {
                propertiesForFloodZone.add(rec);
            }
        }

        if(!propertiesForFloodZone.isEmpty()) {
            createFloorInsuranceRequirement(propertiesForFloodZone);
        }

        if(!opportunityIds.isEmpty()) {
            checkIsNOO(opportunityIds);
        }

        if(oppId.size() > 0){
            oppMap = new Map<Id,Opportunity>([SELECT Id, Name, Property_Street_Number_and_Name__c, Recorded_Information__c, Property_City__c, Property_State__c,Property_Zip_Code__c,Property_County__c,Property_Type__c, Probability FROM Opportunity WHERE Id IN: oppId]);
        }

        for(Property__c rec: newList){
            if(rec.Opportunity__c != null){
                Opportunity opp = new Opportunity();
                opp.Id = rec.Opportunity__c;
                SYSTEM.debug('- - opp - -');
                SYSTEM.debug(opp);
                boolean flag = false;
                if(oppMap.containsKey(rec.Opportunity__c) && rec.Property_Type__c == oppMap.get(rec.Opportunity__c).Property_Type__c && oppMap.get(rec.Opportunity__c).Probability > 0 && oppMap.get(rec.Opportunity__c).Probability < 100){
                    if(rec.Property_Street_Number_and_Name__c != null && rec.Property_Street_Number_and_Name__c != oldMap.get(rec.Id).Property_Street_Number_and_Name__c){
                        opp.Property_Street_Number_and_Name__c = rec.Property_Street_Number_and_Name__c;
                        flag = true;
                    }
                    if(rec.Property_City__c != null && rec.Property_City__c != oldMap.get(rec.Id).Property_City__c){
                        opp.Property_City__c = rec.Property_City__c;
                        flag = true;
                    }
                    system.debug('- before update -');
                    system.debug( rec );
                    if(rec.Property_State__c != null && rec.Property_State__c != oldMap.get(rec.Id).Property_State__c){
                        system.debug( '-- state --' );
                        system.debug( opp.Property_State__c );
                        system.debug( rec.Property_State__c );
                        system.debug( oldMap.get(rec.Id).Property_State__c );



                        opp.Property_State__c = rec.Property_State__c;

                        Id riID  = oppMap.get(rec.Opportunity__c).Recorded_Information__c;

                        system.debug( 'riID' );
                        system.debug( riID );

                        if ( riID != null) {
                            Recorded_Information__c recInf = new Recorded_Information__c( id=riID, Property_State__c = rec.Property_State__c);
                            system.debug( 'recInf' );
                            system.debug( recInf );
                            updateRecInfList.add(recInf);
                        }

                        flag = true;
                    }
                    if(rec.Property_Zip_Code__c != null && rec.Property_Zip_Code__c != oldMap.get(rec.Id).Property_Zip_Code__c){
                        opp.Property_Zip_Code__c = rec.Property_Zip_Code__c;
                        flag = true;
                    }
                    if(rec.Property_County__c != null && rec.Property_County__c != oldMap.get(rec.Id).Property_County__c){
                        opp.Property_County__c = rec.Property_County__c;
                        flag = true;
                    }
                    if(flag){
                        updateOppList.add(opp);
                    }
                }
            }
        }

        if(updateOppList.size() > 0){
            update updateOppList;

            system.debug( 'updateOppList');
            system.debug( updateOppList);
            system.debug( 'updateRecInfList');
            system.debug( updateRecInfList);
            if(updateOppList.size() > 0) {
                update updateRecInfList;
            }
            /*
            system.debug( 'recs');
            system.debug( recs );

            if ( recs.size()>0 ) {
                for (Recorded_Information__c ri : recs) {
                    ri.Property_State__c = oppMap.get(ri.Opportunity__c).Property_State__c;
                }
                system.debug( 'recs');
                system.debug( recs );
                update recs;
            }*/
        }
    }

    // Added for: https://unison-technology.atlassian.net/browse/BUS-155110473
    private static void checkIsNOO (Set<Id> oppIds) {
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, Is_NOO__c FROM Opportunity WHERE Id IN : oppIds]);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity currentOpportunity : opportunityMap.values()) {
            currentOpportunity.Is_NOO__c = true;
            oppsToUpdate.add(currentOpportunity);
        }

        if(!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    // Added for: https://unison-technology.atlassian.net/browse/BUS-155110785
    private static void createFloorInsuranceRequirement(List<Property__c> properties) {
        Set<Id> oppIds = new Set<Id>();
        for(Property__c prop : properties) {
            oppIds.add(prop.Opportunity__c);
        }

        // Create Flood Insurance Requirement if there aren't any created
        List<Current_Conditions__c> reqsToInsert = new List<Current_Conditions__c>();
        Map<Id, List<Current_Conditions__c>> opptyReqsMap = new Map<Id, List<Current_Conditions__c>>();
        for(Current_Conditions__c req : [SELECT Id, Requirement__c, Status__c, Opportunity__c
        FROM Current_Conditions__c WHERE Opportunity__c IN : oppIds AND Requirement__c = 'Flood Insurance']) {
            if(opptyReqsMap.containsKey(req.Opportunity__c)) {
                List<Current_Conditions__c> reqs = opptyReqsMap.get(req.Opportunity__c);
                reqs.add(req);
                opptyReqsMap.put(req.Opportunity__c, reqs);
            } else {
                opptyReqsMap.put(req.Opportunity__c, new List<Current_Conditions__c> { req });
            }
        }
        for(Id oppId : oppIds) {
            if(!opptyReqsMap.containsKey(oppId)) {
                reqsToInsert.add(new Current_Conditions__c(Opportunity__c = oppId, Code__c = 'R1031'));
            }
        }

        if(!reqsToInsert.isEmpty()) {
            insert reqsToInsert;
        }
    }
}