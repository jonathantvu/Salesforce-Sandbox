trigger NintextoDMD on ContentDocumentLink (before insert, after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        ContentDocumentLinkTriggerHandler.onAfterInsert(Trigger.New);   
    }
}