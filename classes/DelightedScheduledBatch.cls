global class DelightedScheduledBatch implements Schedulable, Database.Stateful, Database.AllowsCallouts, Database.Batchable<sObject> {

	global void execute(SchedulableContext SC) {
		Database.executeBatch(new DelightedScheduledBatch(), 1);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Lead__c, Opportunity__c FROM Net_Promoter_Measurement__c WHERE Status__c = \'Draft\'');
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Net_Promoter_Measurement__c npm = (Net_Promoter_Measurement__c)scope[0];
        
        if (npm.Lead__c != null)
            DelightedHelper.SendSurveyLead(npm.Id, npm.Lead__c);
        
        if (npm.Opportunity__c != null)
            DelightedHelper.SendSurveyOpportunity(npm.Id, npm.Opportunity__c);
	}
	
	global void finish(Database.BatchableContext BC) {
	}
}