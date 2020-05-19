/**
 * Created by cveli on 1/30/2020.
 */


global class BatchInvalidateLeads implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {

    global Database.QueryLocator start(Database.BatchableContext context) {

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        //CV: this class won't update anything on production. The logic is exclusively to update sandboxes.
        if ((isSandbox) && (!test.isRunningTest())){ 
            return Database.getQueryLocator([
                    select id, name, email
                    from lead
                    where email <> '' and (NOT email like '%.invalid%')
                    order by id
            ]);
        }
        else
        {
            return Database.getQueryLocator([
                    select id, name, email
                    from lead
                    where email <> '' and (NOT email like '%.invalid%')
                    order by id limit 1
            ]);
        }
    }

    global void execute(Database.BatchableContext context, List<Lead> scope) {
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        //CV: this class won't update anything on production. The logic is exclusively to update sandboxes.

            for (Lead thelead : scope) {
                if (!(thelead.email.contains('.invalid')))
                    thelead.email = thelead.email + '.invalid';
            }
        if (isSandbox) {
            update scope;
        }

    }

    global void finish(Database.BatchableContext context) {
    }
}