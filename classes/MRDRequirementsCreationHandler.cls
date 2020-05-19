/**
 * Created by Eliot Rojas on 5/23/2019.
 */

public with sharing class MRDRequirementsCreationHandler {
    public static Map<Id, List<Minimum_Required_Documents__c>> leadMRDsMap = new  Map<Id, List<Minimum_Required_Documents__c>>();
    public static Map<String, EOS_Requirements__mdt> eosRequirementsMap = new Map<String, EOS_Requirements__mdt>();
    public static Map<String, String> mrdToRequirementsMap = new Map<String, String>();
    public static Set<Id> mrdIds = new Set<Id>();
    public static Map<Id, List<ContentDocumentLink>> mapMRDId_lstCDL = new Map<Id, List<ContentDocumentLink>>();

    public static void handleMRDRequirements(Map<Id, Lead> leadMap) {
        Set<Id> leadIds = leadMap.keySet();
        leadMRDsMap = setLeadMRDsMap(leadIds);
        mrdToRequirementsMap = setMrdToRequirementsMap();
        Map<Id, List<ContentDocumentLink>> mapMRDId_lstCDL = new Map<Id, List<ContentDocumentLink>>(); //***
        List<Id> listMRDId = new List<Id>();//***
        //Map<Current_Conditions__c, Id> mapReq_MRDId = new Map<Current_Conditions__c, Id>(); //***
        List<Id> listReqMRDId = new List<Id>();

        Current_Conditions__c currentRequirement;
        List<Current_Conditions__c> requirementsToInsert = new List<Current_Conditions__c>();
        // populate a map of all ContentDocumentLinks that are linked to any MRD attached to the current lead
        for (ContentDocumentLink objCDL : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :mrdIds]) {
            System.debug('====objCDL===='+objCDL);

            // check if any CDLs have been added for this MRD
            if (!mapMRDId_lstCDL.containsKey(objCDL.LinkedEntityId)) {
                // if not, create the map entry with the first CDL
                mapMRDId_lstCDL.put(objCDL.LinkedEntityId, new List<ContentDocumentLink> {objCDL});
            }
            else {
                // otherwise pull the current list,
                List<ContentDocumentLink> lstCDL = mapMRDId_lstCDL.get(objCDL.LinkedEntityId);
                // add this CDL,
                lstCDL.add(objCDL);
                // and put the list back
                mapMRDId_lstCDL.put(objCDL.LinkedEntityId, lstCDL);
            }

            System.debug('====mapMRDId_lstCDL===='+mapMRDId_lstCDL);
        }


        for(String leadId : leadMap.keySet()) {
            if(leadMRDsMap.containsKey(leadId)) {
                for(Minimum_Required_Documents__c objMRD : leadMRDsMap.get(leadId)) {
                    listReqMRDId.add(objMRD.Id);
                    String eosRequirement;
                    if(mrdToRequirementsMap.containsKey(objMRD.Category__c)) {
                        eosRequirement = mrdToRequirementsMap.get(objMRD.Category__c);
                    }

                    if(eosRequirement != null) {
                        currentRequirement = new Current_Conditions__c();
                        currentRequirement.Lead__c = leadId;
                        currentRequirement.Code__c = eosRequirement;
                        requirementsToInsert.add(currentRequirement);
                    }
                }
            }
        }
        if(!requirementsToInsert.isEmpty()) {
            insert requirementsToInsert;

            List<Document_MetaData__c> listDMD = new List<Document_MetaData__c>();
            List<ContentDocumentLink> listOldCDL = new List<ContentDocumentLink>();
            List<ContentDocumentLink> listCDLtoInsert = new List<ContentDocumentLink>();
            Set<ContentDocumentLink> setCDLtoDelete = new Set<ContentDocumentLink>();
            Document_MetaData__c objDMD;
            Id idMRD;
            ContentDocumentLink newCDL;
            ContentDocumentLink objCDL;

            // Create DMDs
            for (Integer i = 0; i < requirementsToInsert.size(); i++) {
                currentRequirement = requirementsToInsert[i];
                idMRD = listReqMRDId[i];
                if (mapMRDId_lstCDL.containsKey(idMRD) && mapMRDId_lstCDL.get(idMRD).size() > 0) {
                    for (ContentDocumentLink oldCDL : mapMRDId_lstCDL.get(idMRD)) {

                        objDMD = new Document_MetaData__c();
                        objDMD.Requirement__c = currentRequirement.Id;

                        listDMD.add(objDMD);
                        listOldCDL.add(oldCDL);
                    }
                }
            }

            if (listDMD.size() > 0) {
                insert listDMD;
            }

            // Create CDLs
            for (Integer i = 0; i < listDMD.size(); i++) {
                // objReq = requirementsToInsert[i];
                objCDL = listOldCDL[i];
                objDMD = listDMD[i];

                newCDL = objCDL.clone(false, false, false, false);
                newCDL.LinkedEntityId = objDMD.Id;
                newCDL.ContentDocumentId = objCDL.ContentDocumentId;
                newCDL.ShareType = 'V';

                listCDLtoInsert.add(newCDL);
                setCDLtoDelete.add(objCDL);
            }

            if (listCDLtoInsert.size() > 0) {
                insert listCDLtoInsert;
                delete new List<ContentDocumentLink>(setCDLtoDelete);
            }
        }
    }

    private static Map<Id, List<Minimum_Required_Documents__c>> setLeadMRDsMap(Set<Id> leadIds) {
        Map<Id, List<Minimum_Required_Documents__c>> tempLeadMRDsMap = new Map<Id, List<Minimum_Required_Documents__c>>();
        for(Minimum_Required_Documents__c objMRD : [SELECT Id, Applicant_Type__c, Lead__c,Category__c, Uploaded__c, Customer_Description__c, Reupload_Comments__c
                                                    FROM Minimum_Required_Documents__c WHERE Lead__c =: leadIds]) {
            mrdIds.add(objMRD.Id);
            if(!tempLeadMRDsMap.containsKey(objMRD.Lead__c)) {
                tempLeadMRDsMap.put(objMRD.Lead__c, new List<Minimum_Required_Documents__c> {objMRD});
            } else {
                List<Minimum_Required_Documents__c> lstMRD = tempLeadMRDsMap.get(objMRD.Lead__c);
                lstMRD.add(objMRD);
                tempLeadMRDsMap.put(objMRD.Lead__c,lstMRD);
            }
        }
        return tempLeadMRDsMap;
    }

    private static Map<String, String> setMrdToRequirementsMap() {
        Map<String, String> tempMrdToRequirementsMap = new Map<String, String>();
        for(MRD_to_EOS_Requirement__mdt objMDT : getMRDtoEOSRequirements()) {
            if(!tempMrdToRequirementsMap.containsKey(objMDT.MRD__c)) {
                tempMrdToRequirementsMap.put(objMDT.MRD__c, objMDT.EOS_Requirement__c);
            }
        }
        return tempMrdToRequirementsMap;
    }

    @TestVisible private static List<MRD_to_EOS_Requirement__mdt> getMRDtoEOSRequirements(){
        return [SELECT DeveloperName, MasterLabel, EOS_Requirement__c, MRD__c
        FROM MRD_to_EOS_Requirement__mdt];
    }
}