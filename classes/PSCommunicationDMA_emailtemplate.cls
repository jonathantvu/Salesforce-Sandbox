/**
 * Created by Ivan Garcia on 5/1/2019.
 */

public with sharing class PSCommunicationDMA_emailtemplate {
    public Id oppId {get;set;}
    public List<DMA__c> getDMAItems()
    {
        List<DMA__c> DMAItems;
        DMAItems = [SELECT Name, Deferred_Maintenance_Item__c
        FROM DMA__c WHERE Opportunity__c =: oppId];
        return DMAItems;

    }
}