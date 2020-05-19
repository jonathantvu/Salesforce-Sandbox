public class TuneIntegration {

    private static Map<string, string> urlSettingsP;
    public static Map<string, string> urlSettings {
        get {
            if (urlSettingsP == null) {
                urlSettingsP = new Map<string, string>();
                for (Tune_Integration_URL__mdt stg : [SELECT Tune_Goal_Name__c, Tune_Offer_Id__c, URL__c FROM Tune_Integration_URL__mdt]) {
                    urlSettingsP.put(stg.Tune_Goal_Name__c + '~' + stg.Tune_Offer_Id__c, stg.URL__c);
                }
            }
            return urlSettingsP;
        }
    }
    
    private static List<Tune_Integration_Log__c> logList;
    
    @future(callout=true)
    public static void SendLeadsToTune(Map<Id, String> leadIds) {
        
        for (Lead l : [SELECT Tune_Transaction_Id__c, Tune_Offer_Id__c FROM Lead WHERE Id IN :leadIds.keyset()]) {
            MakeCall(l.Id, leadIds.get(l.Id), l.Tune_Offer_Id__c, l.Tune_Transaction_Id__c, '', '');
        }
        
        if (logList != null && logList.size() > 0) {
            insert logList;
            logList = new List<Tune_Integration_Log__c>();
        }
        
    }
    
    @future(callout=true)
    public static void SendOppsToTune(Map<Id, String> oppIds) {
        
        for (Opportunity o : [SELECT Tune_Transaction_Id__c, Tune_Offer_Id__c, Estimated_Funding_Amount__c, Wire_to_Agent_Date__c FROM Opportunity WHERE Id IN :oppIds.keyset()]) {
            MakeCall(o.Id, oppIds.get(o.Id), o.Tune_Offer_Id__c, o.Tune_Transaction_Id__c, 
                     		o.Estimated_Funding_Amount__c == null ? '' : string.valueOf(o.Estimated_Funding_Amount__c), 
                     		o.Wire_to_Agent_Date__c == null ? '' : string.valueOf(o.Wire_to_Agent_Date__c));
        }
        
        if (logList != null && logList.size() > 0) {
            insert logList;
            logList = new List<Tune_Integration_Log__c>();
        }
        
    }
    
    public static void MakeCall(Id recordId, string goalName, string offerId, string transactionId, string amount, string agentDate) {
        
        if (!urlSettings.containsKey(goalName + '~' + offerId))
            return;
        
        string url = urlSettings.get(goalName + '~' + offerId).replace('{{recordId}}', recordId)
            												  .replace('{{transactionId}}', transactionId)
            												  .replace('{{amount}}', amount)
            												  .replace('{{agentDate}}', agentDate);
        
        Http h = new Http();
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
    
        HttpResponse res = h.send(req);
        
        if (logList == null) {
            logList = new List<Tune_Integration_Log__c>();
        }
        Tune_Integration_Log__c log = new Tune_Integration_Log__c();
        log.URL__c = url;
        if (log.URL__c != null && log.URL__c.length() > 254)
            log.URL__c = log.URL__c.substring(0, 250) + '...';
        log.Response_Code__c = res.getStatusCode();
        log.Response_Body__c = res.getBody();
        if (log.Response_Body__c != null && log.Response_Body__c.length() > 32767)
            log.Response_Body__c = log.Response_Body__c.substring(0, 32760) + '...';
        logList.add(log);
        
    }
    
}