public class SuccessFactorsHelper {

	@InvocableMethod(label='Generate Lead Success Factors' description='Generates Lead Success Factors from Custom Metadata settings and updates success factor generation timestamp')
	public static void generateLeadSuccessFactors(List<Id> leadIds) {
        List<Success_Factor__c> sfList = new List<Success_Factor__c>();
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead l: [SELECT Id, (SELECT Id FROM Risk_Factors__r) FROM Lead WHERE Id IN: leadIds]){
            if(l.Risk_Factors__r.isEmpty()){
        		for(Lead_Success_Factor__mdt lsfMeta: [SELECT Status__c ,Success_Factor__c FROM Lead_Success_Factor__mdt ]){
            		sfList.add(new Success_Factor__c(Lead__c = l.Id, Status__c =lsfMeta.Status__c, Success_Factor__c=lsfMeta.Success_Factor__c) );                
        		}            
				leadsToUpdate.add(new Lead(Id=l.Id,SuccessFactor_Creation_TimeStamp__c =datetime.now() ));                             
            }
        }
        insert sfList;
        update leadsToUpdate;
    }      
    
}