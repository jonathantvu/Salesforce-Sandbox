trigger AccountTrigger on Account (before update, before delete, after update, after delete, after undelete) {
    
    if(!System.IsBatch()) {
        if(Trigger.IsBefore) {
            If (!Trigger.isDelete) InvalidateEmail.invalidateEmail(Trigger.new);
            List<Account> accountCreateList = new List<Account>();
            List<Account> accountUpdateList = new List<Account>();
            List<Account> accountDeleteList = new List<Account>();
            
            if(Trigger.IsUpdate) {
                for(Account objAccount : Trigger.new) {
                    if(!Trigger.oldMap.get(objAccount.Id).Create_LOP_Lender__c && objAccount.Create_LOP_Lender__c) {
                        accountCreateList.add(objAccount);
                    } else if(!Trigger.oldMap.get(objAccount.Id).Update_LOP_Lender__c && objAccount.Update_LOP_Lender__c) {
                        accountUpdateList.add(objAccount);
                    } else if(!Trigger.oldMap.get(objAccount.Id).Deactivate_LOP_Lender__c && objAccount.Deactivate_LOP_Lender__c) {
                        accountDeleteList.add(objAccount);
                    }
                }
                AccountTriggerHandler.handleLOPLenderOperations(SFUtilityClass.APIOperation.API_CREATE, accountCreateList);
                AccountTriggerHandler.handleLOPLenderOperations(SFUtilityClass.APIOperation.API_UPDATE, accountUpdateList);
                AccountTriggerHandler.handleLOPLenderOperations(SFUtilityClass.APIOperation.API_DELETE, accountDeleteList);            
            } else if(Trigger.IsDelete) {
                for(Account objAccount : Trigger.old) {
                    if(objAccount.LOP_Lender__c) {
                           
                        accountDeleteList.add(objAccount);
                    }
                }
                AccountTriggerHandler.handleLOPLenderOperations(SFUtilityClass.APIOperation.API_DELETE, accountDeleteList);            
            }          
        } else {
            // Trigger : IsAfter Code Here
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        AccountTriggerHandler.onAfterUpdate(Trigger.new,Trigger.OldMap);
    }
    
    if(Trigger.isAfter && Trigger.isdelete){
    
    }
    
    if(Trigger.isAfter && Trigger.isundelete){
    
    }
}