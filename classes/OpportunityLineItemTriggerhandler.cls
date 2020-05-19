/*

* Modified by: Sundar 04/27/2019 
*   - added Code to copy the Group and Type from Product 
*   and calculation of Amount based on Opportunity in beforeInsert     

*/
public class OpportunityLineItemTriggerhandler {
    public static void handleBeforeInsert(List<OpportunityLineItem> newList){
        Set<Id> productIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem item : newList) {
            if(item.Product2Id != null) {
                productIds.add(item.Product2Id);
            }
            if(item.OpportunityId != null) {
                oppIds.add(item.OpportunityId); 
            }           
        }

        Map<Id,Product2> productMap = new Map<Id,Product2>();
        if(productIds.size() > 0) {
            for(Product2 prodItem : [SELECT Id, Name, ProductCode, Group__c, Type__c FROM Product2 where Id IN: productIds]) {
                productMap.put(prodItem.Id,prodItem);
            }
        }
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        if(oppIds.size() > 0) {
            for(Opportunity oppItem : [SELECT Id, Name,Estimated_Funding_Amount__c,Unison_Transaction_Fee__c FROM Opportunity where Id IN: oppIds]) {
                oppMap.put(oppItem.Id,oppItem);
            }           
        }
        

        for(OpportunityLineItem item : newList) {
            item.Amount__c = item.UnitPrice;
            if(productMap.containsKey(item.Product2Id)) {
                item.Group__c = productMap.get(item.Product2Id).Group__c;
                item.Type__c = productMap.get(item.Product2Id).Type__c;
                if(productMap.get(item.Product2Id).Name == 'Acquisition Fee' && oppMap.containsKey(item.OpportunityId) && oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c != null) {
                    item.Amount__c = 0.1 * oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c;
                    item.UnitPrice = item.Amount__c;
                }
                if((productMap.get(item.Product2Id).Name == 'Transaction Fee' || productMap.get(item.Product2Id).Name == 'Transaction Fee Waiver' )
                    && oppMap.containsKey(item.OpportunityId) && oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c != null
                    && oppMap.get(item.OpportunityId).Unison_Transaction_Fee__c != null) {
                    
                    if(oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c >= 360000) {
                        item.Amount__c = 14000;
                    } else if(oppMap.get(item.OpportunityId).Unison_Transaction_Fee__c != null) {
                        item.Amount__c = (oppMap.get(item.OpportunityId).Unison_Transaction_Fee__c/100) * oppMap.get(item.OpportunityId).Estimated_Funding_Amount__c;
                    }
                    item.UnitPrice = item.Amount__c;
                }
                
            }           
        }
    }
    public static void handleBeforeUpdate(List<OpportunityLineItem> newList,Map<Id,OpportunityLineItem> oldMap){
                    
    }
    public static void handleAfterInsert(List<OpportunityLineItem> listNewOli){  
        UpdateCustomerTransactionFee(listNewOli);
    }
    public static void handleAfterUpdate(List<OpportunityLineItem> listNewOli,Map<Id,OpportunityLineItem> oldMap)
    {
        UpdateCustomerTransactionFee(listNewOli);              
    }
    public static void handleAfterDelete(List<OpportunityLineItem> listNewOli,Map<Id,OpportunityLineItem> oldMap){
        UpdateCustomerTransactionFee(listNewOli);                      
    }

    /***
     * @Description This method calcualtes the customer transaction fee on Opp based OLI(Fee)
     * 
     * @Param List<OpportunityLineItem>
     * 
     * @Return Void
     * */     
    public static void UpdateCustomerTransactionFee(List<OpportunityLineItem> listUpdatedOli){
          
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> OppToUpdate = new List<Opportunity>();
        for(OpportunityLineItem Oli : listUpdatedOli){
            oppIds.add(Oli.OpportunityId);
        }
        Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>([SELECT Id,(SELECT Id,Final_Amount__c,Product2.Name from OpportunityLineItems where Product2.Name IN ('Transaction Fee','Transaction Fee Waiver')) from Opportunity where Id IN: oppIds]);
        if(!OppMap.isEmpty()){
            for(Opportunity Opp : OppMap.values()){
                Opp.Customer_Transaction_Fee__c = 0;
                for(OpportunityLineItem Oli : Opp.OpportunityLineItems){
                    if(Oli.Product2.Name == 'Transaction Fee'){
                        Opp.Customer_Transaction_Fee__c += Oli.Final_Amount__c;
                    }
                    if(Oli.Product2.Name == 'Transaction Fee Waiver'){
                        Opp.Customer_Transaction_Fee__c -= Oli.Final_Amount__c;
                    }   
                }
                OppToUpdate.add(Opp);   
            }
        }
        if(!OppToUpdate.isEmpty()){
            if (!test.isRunningTest())
                update OppToUpdate;
        }
    }
}