global class DelightedFundedOppBatch implements Schedulable, Database.Stateful, Database.AllowsCallouts, Database.Batchable<sObject> {

	global void execute(SchedulableContext SC) {
		Database.executeBatch(new DelightedFundedOppBatch(), 1);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
        Date sevenDaysAgo = Date.today().addDays(-7);
		return Database.getQueryLocator('SELECT Id, Applicant__r.Email, Applicant__r.Phone, Applicant__r.Name, RecordTypeId, RecordType.Name, OwnerId, ' +
                                        		'StageName, SMS_Opt_out__c, Loss_Reason_Code__c, Delighted_Trigger_Status__c, Owner.Name ' +
                                        	'FROM Opportunity WHERE Wire_to_Agent_Date__c = :sevenDaysAgo AND Applicant__r.Marketing_Opt_Out__c = false');
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        DelightedHelper.SendSurveyFundedOpp((Opportunity)scope[0]);
	}
	
	global void finish(Database.BatchableContext BC) {
	}
}