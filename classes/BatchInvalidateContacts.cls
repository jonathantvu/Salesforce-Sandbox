/**
 * Created by cveli on 1/21/2020.
 */

global class BatchInvalidateContacts implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {

    global Database.QueryLocator start(Database.BatchableContext context) {

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        //CV: this class won't update anything on production. The logic is exclusively to update sandboxes.
   if ((isSandbox) && (!test.isRunningTest())){ 
            return Database.getQueryLocator([
                    select id, name, email
                    from contact
                    where email <> '' and (NOT email like '%.invalid%')
                    order by id
            ]);
        } else
                return Database.getQueryLocator([
                        select id, name, email
                        from contact
                        where email <> '' and (NOT email like '%.invalid%')
                        order by id
                        limit 1
                ]);
    }

    global void execute(Database.BatchableContext context, List<Contact> scope) {
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        //CV: this class won't update anything on production. The logic is exclusively to update sandboxes.

        for (contact con : scope) {
            if (!(con.email.contains('.invalid')))
                con.email = con.email + '.invalid';

            if (isSandbox) {
                update scope;
            }
        }
    }

    global void finish(Database.BatchableContext context) {
    }
}