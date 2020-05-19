public class DealHistoryTriggerHandler {
    private static boolean LEAD_REQ_FLAG = FALSE;
    public static void handleAfterUpdate(List<Deal_History__c> newlist, Map<Id,Deal_History__c> oldmap) {
        Set<Id> oppids = new Set<Id>();
        Set<Id> dhids = new Set<Id>();
        for(Deal_History__c dl: newlist) {
            if(dl.Opportunity__c != Null)  {
                oppids.add(dl.Opportunity__c);
                dhids.add(dl.Id);
            }   
        }
        
        if(oppids.size() > 0 && dhids.size() > 0){
            
            List<Deal_History__c> dhlist = [Select Id, Post_Close_LTV__c, Opportunity__c, Opportunity__r.RecordType.Name, 
            Opportunity__r.StageName from Deal_History__c where id =: dhids];
            
            List<Success_Factor__c> sflist = [Select Id, Opportunity__c, Success_Factor__c from Success_Factor__c where Opportunity__c =: oppids];
            
            if(dhlist.size() > 0 && sflist.size() > 0){
                List<Current_Conditions__c> reqlist = new List<Current_Conditions__c>();
                for(Deal_History__c d: dhlist) {
                    for(Success_Factor__c sf: sflist) {
                         System.debug('inside  loop');
                         if(d.Post_Close_LTV__c != Null && d.Post_Close_LTV__c != oldmap.get(d.Id).Post_Close_LTV__c && d.Opportunity__r.RecordType.Name == 'HomeBuyer'
                             && d.Opportunity__r.StageName == 'Investment Due Diligence' && sf.Success_Factor__c == 'Final Approval' && !LEAD_REQ_FLAG) {
                                    Current_Conditions__c req = new Current_Conditions__c();
                                    req.Requirement__c         ='Revised CAP';
                                    req.Code__c                = 'CON-0142';
                                    req.Category__c            = 'Valuation';
                                    //req.Assigned_To__c         = 'TS'; /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
                                    req.Type__c                = 'Data Request';
                                    req.Internal_vs_External__c= 'External';
                                    req.Applicant_Type__c      = 'Applicant';
                                    req.Success_Factor__c      = sf.Id;
                                    req.Opportunity__c         = sf.Opportunity__c;
                                    reqlist.add(req);
                                    LEAD_REQ_FLAG = TRUE;    
                         }   
                    }
                }
                
                if(reqlist.size() > 0) {
                    insert reqlist;
                }
            }
        }
    }
}