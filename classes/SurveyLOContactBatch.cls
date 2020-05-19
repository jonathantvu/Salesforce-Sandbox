/*************************************************************************************************
 * @className   : SurveyLOContactBatch.cls
 * @testClass   : SurveyLOContactSched_Test.cls
 * @author      : Omnivo Digital (omnivodigital.com)
 * @date        : May 16, 2019
 * @description : This class is used to get all lender Contact with Trained_Date_Time__c field value in the last 24 hours
 *				and send lo survey
 *
*************************************************************************************************/

global class SurveyLOContactBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
	
	global SurveyLOContactBatch(){

	}

	global Database.QueryLocator start(Database.BatchableContext context) {
		Datetime yDt = Datetime.now().addDays(-1);
		String queryStr = 'SELECT Id, Email, Name, Phone, OwnerId, RecordTypeId, RecordType.Name, '+
									'tdc_tsw__SMS_Opt_out__c, Loss_Reason__c, '+
									'Owner.Name, AccountId, Account.Name, Contact_Status__c, LOP_Contact_Type__c '+
									' FROM Contact ' +
										'Where Trained_Date_Time__c >= :yDt AND LO_Survey_Sent__c = false ' +
            							'AND Marketing_Opt_Out__c = false ' +
										'AND RecordType.DeveloperName = \'Lender\' ';
		return Database.getQueryLocator(queryStr);
	}

   	global void execute(Database.BatchableContext context, List<Contact> scope) {
		System.debug('***scope: ' + scope.size());
		if(scope != null && scope.size() > 0){
			for(Contact con: scope){
				DelightedHelper.SendSurveyLOContact(con);
			}//end for
		}
	}
	 
	global void finish(Database.BatchableContext context) {
		
	}
}