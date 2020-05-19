/**
 * Created by cveli on 1/30/2020.
 */

global class BatchInvalidateApplicants implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {
    global Database.QueryLocator start(Database.BatchableContext context) {

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        //CV: this class won't update anything on production. The logic is exclusively to update sandboxes.
   if ((isSandbox) && (!test.isRunningTest())){ 
            return Database.getQueryLocator([
                    select id, name, Email__c, Email_Co__c
                    from Application__c
                    where (Email__c <> '' and (NOT Email__c like '%.invalid%'))
                    or (Email_Co__c <> '' and (NOT Email_Co__c like '%.invalid%'))
                    order by id
            ]);
        }
        else
        {
                return Database.getQueryLocator([
                        select id, name, Email__c, Email_Co__c
                        from Application__c
                        where (Email__c <> '' and (NOT Email__c like '%.invalid%'))
                        or (Email_Co__c <> '' and (NOT Email_Co__c like '%.invalid%'))
                        order by id limit 1]);
        }
    }

    global void execute(Database.BatchableContext context, List<Application__c> scope) {
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        //CV: this class won't update anything on production. The logic is exclusively to update sandboxes.

            for (Application__c theApp : scope) {
                if ( string.isNotBlank(theApp.Email__c) && !(theApp.Email__c.contains('.invalid')))
                    theApp.Email__c = theApp.Email__c + '.invalid';
                if ( string.isNotBlank(theApp.Email_Co__c) && !(theApp.Email_Co__c.contains('.invalid')))
                    theApp.Email_Co__c = theApp.Email_Co__c + '.invalid';
            }
            if (!test.isRunningTest())
                if (isSandbox) {
                    update scope;
                }

    }

    global void finish(Database.BatchableContext context) {
    }
}