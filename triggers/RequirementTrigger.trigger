trigger RequirementTrigger on Current_Conditions__c (before insert, after insert, before update, after update, after delete)
{
   if(trigger.isBefore && trigger.isInsert ) {
        RequirementTriggerHandler.handleBeforeInsert(Trigger.New);
    } else if(trigger.isAfter && trigger.isInsert) {
        //RequirementTriggerHandler.handleAfterInsert(Trigger.New);
        RequirementTriggerHandler.createProjectTasks(Trigger.newMap); 
        RequirementTriggerHandler.updateopportunity(Trigger.New);
        RequirementTriggerHandler.handleAfterInsertNotifications(Trigger.New);
    } else if (Trigger.isAfter && Trigger.isUpdate){
        RequirementTriggerHandler.updateopportunity(Trigger.New);
        RequirementTriggerHandler.handleAfterUpdateNotifications(Trigger.New, Trigger.oldMap);
            
       /*for(Current_Conditions__c objReq :  trigger.new)
          {
           if(objReq.Requirement__c != trigger.oldMap.get(objReq.Id).Requirement__c)
           {
               mapRequirements.put(objReq.Id, objReq);
           }
        
       }//RequirementTriggerHandler.createProjectTasks(mapRequirements);
       // RequirementTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.OldMap);
       */
    }
    
    if(trigger.isAfter && (trigger.isInsert || Trigger.isUpdate)) {
        // Send to AWS
        system.debug('*******req upd*******');
        UnisonAPI.SendRequirementUpsert(Trigger.new);
    }
    if(Trigger.isAfter&& Trigger.isDelete){
       RequirementTriggerHandler.updateopportunity(Trigger.Old);
    }
    
   //VK for BUS-155110164    
    if(trigger.isBefore && trigger.isUpdate){      
       RequirementTriggerHandler.validateAppraisalStatus(Trigger.oldMap,Trigger.newMap);
    }
   
    
}