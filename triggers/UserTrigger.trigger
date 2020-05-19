trigger UserTrigger on User (after insert, before update) {
    
    if(!System.IsBatch()) {
        if(Trigger.IsBefore) {
            
            List<User> userCreateList = new List<User>();            
            List<User> userUpdateList = new List<User>();
            List<User> userDeleteList = new List<User>();
            
            if(Trigger.IsUpdate) {
                for(User objUser : Trigger.new) {
                    if(!Trigger.oldMap.get(objUser.Id).Update_LOP_User__c && objUser.Update_LOP_User__c) {
                        userUpdateList.add(objUser);
                    } else if(!Trigger.oldMap.get(objUser.Id).Deactivate_LOP_User__c && objUser.Deactivate_LOP_User__c) {
                        userDeleteList.add(objUser);
                    } else if(!Trigger.oldMap.get(objUser.Id).Create_LOP_User__c && objUser.Create_LOP_User__c) {
                        userCreateList.add(objUser);
                    }                    
                }
				UserTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_CREATE, userCreateList);            
                UserTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_UPDATE, userUpdateList);
                UserTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_DELETE, userDeleteList);            
            }
        } else {
            if(Trigger.IsInsert) {
            	List<User> userCreateList = new List<User>();  
                for(User objUser : Trigger.new) {
                    if(objUser.Create_LOP_User__c) {
                        userCreateList.add(objUser);
                    }                   
                }                
                UserTriggerHandler.handleLOPUserOperations(SFUtilityClass.APIOperation.API_CREATE, userCreateList);
            }
        }
    }
}