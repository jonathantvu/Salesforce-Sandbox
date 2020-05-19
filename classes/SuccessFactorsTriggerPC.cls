public class SuccessFactorsTriggerPC {

    //Constants 
 
    public static void handleBeforeInsert(List<Success_Factor__c> newList){
        
       
    }
    
    public static void handleAfterInsert(List<Success_Factor__c> lstDMDs)
    {
        
       List<Current_Conditions__c> lstReqForUpdate  = new List<Current_Conditions__c> ();
        Current_Conditions__c  objNewRequirement;
        
        Map<String, String> cmdMap = new Map<String, String>();
        
        for(Requirements_Vs_SuccessFactor__mdt objMDT : getMetadata())
        {
            cmdMap.put(objMDT.MasterLabel, objMDT.Success_Factor__c);
        }
        
        System.debug('****objNewRequirement****'+objNewRequirement);
         System.debug('****lstReqForUpdate****'+lstReqForUpdate);
        System.debug('****cmdMap****'+cmdMap);     
    }
    
    public static void handleAfterUpdate(List<Success_Factor__c> newList, Map<Id, Success_Factor__c> oldMap)
    {
        Set<Id> sfoppids = new Set<Id>();
        List<Deal_History__c> deallist = new List<Deal_History__c>();
        for(Success_Factor__c sf: newList) {
            if(sf.Status__c != Null 
                && sf.Opportunity__c != Null 
                && oldMap.get(sf.Id).Status__c != Null 
                && oldMap.get(sf.Id).Status__c != sf.Status__c){
                sfoppids.add(sf.Opportunity__c);    
            }
        }  
        for(Opportunity opp: [Select Id,Home_Value__c,FICO__c,Final_OAV_Calculation__c,Investor_Percentage__c,
            Maximum_Authorized_Debt_Final__c,MAD__c,Maximum_Authorized_DTI__c,Maximum_Authorized_LTV__c,Opportunity_Tracking_ID__c,
            Estimated_Cash_to_Homeowner__c,OAV_Discount_Pct__c,Estimated_Funding_Amount__c,Process_Program_Knowledge_Review__c,
            Passbook_Status__c,Post_Close_BE_Ratio__c,Post_Close_LTV2__c,Pre_Close_BE_Ratio__c,Pre_Close_LTV2__c,Pricing_Ratio__c,
            Purchase_Price__c,StageName from Opportunity where Id =: sfoppids]) {
            
            Deal_History__c dealh = new Deal_History__c();
            dealh.Name                         = 'Deal History'+'-'+opp.Opportunity_Tracking_ID__c;
            dealh.Opportunity__c               = opp.Id;
            dealh.Estimated_OAV__c             = opp.Home_Value__c;
            dealh.FICO__c                      = opp.FICO__c;
            dealh.Final_OAV__c                 = opp.Final_OAV_Calculation__c;
            dealh.Investor_Percentage__c       = opp.Investor_Percentage__c;
            dealh.MAD_Amount__c                = opp.Maximum_Authorized_Debt_Final__c;
            dealh.MAD_Pct__c                   = opp.MAD__c;
            dealh.Maximum_Authorized_DTI__c    = opp.Maximum_Authorized_DTI__c;
            dealh.Maximum_Authorized_LTV__c    = opp.Maximum_Authorized_LTV__c;
            dealh.Net_Cash_to_Homeowner__c     = opp.Estimated_Cash_to_Homeowner__c;
            dealh.OAV_Discount_Pct__c          = opp.OAV_Discount_Pct__c;
            dealh.OIP__c                       = opp.Estimated_Funding_Amount__c;
            dealh.PKR_Done__c                  = opp.Process_Program_Knowledge_Review__c;
            dealh.Passbook_Status__c           = opp.Passbook_Status__c;
            dealh.Post_Close_DTI__c            = opp.Post_Close_BE_Ratio__c;
            dealh.Post_Close_LTV__c            = opp.Post_Close_LTV2__c;
            dealh.Pre_Close_DTI__c             = opp.Pre_Close_BE_Ratio__c;
            dealh.Pre_Close_LTV__c             = opp.Pre_Close_LTV2__c;
            dealh.Pricing_Ratio__c             = opp.Pricing_Ratio__c;
            dealh.Purchase_Price__c            = opp.Purchase_Price__c;
            dealh.Stage__c                     = opp.StageName;
            deallist.add(dealh);
        }
        
        if(deallist.size() > 0){
            insert deallist;
        }

        opportunityPassbook(newList, oldMap);
        UnisonMasterNotifications.ManageNotificationsForSuccessFactorStatusChanges(newList, oldMap);
    }  
    
    public static void handlebeforeUpdate(Map<Id, Success_Factor__c> newMap, Map<Id, Success_Factor__c> oldMap){
        
    }

    private static void opportunityPassbook(List<Success_Factor__c> newList, Map<Id, Success_Factor__c> oldMap) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();

        for(Success_Factor__c sF : newList){
            if(sF.Success_Factor__c == 'Credit' || sF.Success_Factor__c == 'DTI' || sF.Success_Factor__c == 'LTV') {
                if(oldMap.get(sF.Id).Status__c == 'Completed' && (sF.Status__c != 'Blocked' || sF.Status__c != 'In Progress')){
                    if(sF.Opportunity__c != null) {
                        oppIds.add(sF.Opportunity__c);
                    }
                }
            }
        }

        for(Id optyId : oppIds) {
            Opportunity opp = new Opportunity(Id = optyId);
            opp.IA_Passbook_Override_Reasons__c = '';
            opp.IA_Passbook_Override__c = false;
            opp.Passbook_Status__c = 'Pending';
            oppsToUpdate.add(opp);
        }

        if(!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    @TestVisible private static List<Requirements_Vs_SuccessFactor__mdt> getMetadata(){
        return [SELECT MasterLabel, Success_Factor__c FROM Requirements_Vs_SuccessFactor__mdt];
    }
}