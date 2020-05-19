trigger MrdToAwsTrigger on Minimum_Required_Documents__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) { 
        for (Minimum_Required_Documents__c mrd : Trigger.new) {
            UnisonAPI.fSendMRDUpsert(mrd.id);
        }
    } 
}