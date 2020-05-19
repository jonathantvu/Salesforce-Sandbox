global class OpportunitySyncBatch implements Schedulable, Database.Stateful, Database.AllowsCallouts, Database.Batchable<sObject> {

	private integer successCount = 0;
	private integer errorCount = 0;
	private List<String> errors = new List<String>();

	global void execute(SchedulableContext SC) {
		Database.executeBatch(new OpportunitySyncBatch(), 10);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, AccountId FROM Opportunity WHERE Wire_Reference_Number__c != null AND Orissa_Wire_Sync__c != true');
	}

	global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>((List<Opportunity>)Database.query(AccountUtilityClass.BuildQuery('Id IN :scope')));

		Set<Id> accIds = new Set<Id>();
		for (Opportunity opp : scope) {
			accIds.add(opp.AccountId);
		}
		for (Account acc : [SELECT Id, Name, (SELECT Id FROM Opportunities WHERE Id IN :scope) FROM Account WHERE Id IN :accIds]) {
			accMap.put(acc.Id, acc);
		}
        for (Opportunity opp : scope) {
            accMap.get(opp.AccountId).Opportunities.add(opp);
        }

		Map<Id, List<Document_Metadata__c>> dmdMap = AccountUtilityClass.BuildDocumentMetadataMap(oppMap.keyset());
		Map<Id, List<LASERCA__Trade_Accounts__c>> tasMap = AccountUtilityClass.BuildTradeAccountMap(oppMap.keyset());
		Map<Id, List<ContentNote>> cnMap = AccountUtilityClass.BuildContentNoteMap(oppMap.keyset());

        String result = AccountUtilityClass.SendCallout(accMap.values(), oppMap, dmdMap, tasMap, cnMap);
		if (result == 'OK') {
			successCount += scope.size();
		} else {
			errorCount += scope.size();
			errors.add(result);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		if (errors != null && errors.size() > 0) {

			string body = 'Errors occured during opportunity sync. <br />';
			body += 'Successfully synced : ' + successCount + ' opportunities <br />';
			body += 'Errors syncing: ' + errorCount + ' opportunities <br />';
			body += '<br />';
			for (String error : errors) {
				body += error;
				body += '<br /><br />';
			}

			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] { UserInfo.getUserEmail() });
			mail.setSenderDisplayName('Salesforce');
			mail.setSubject('Opportunity Sync Batch Errors');
			mail.setUseSignature(false);
			mail.setHtmlBody(body);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		}
	}
}