trigger Personal_Credit_Report_Trigger on LASERCA__Personal_Credit_Report__c (before insert, before update, after insert, after update, after delete, after undelete) {

    if(trigger.isBefore){
        if(trigger.isInsert){
            //system.debug('PCRs before insert---' + trigger.new);
        }
        else if(trigger.isUpdate){
            //system.debug('PCRs before update---' + trigger.new);
			PCR_trigger_handler.bUpdate(trigger.newMap, trigger.oldMap);
        }        
    }
    else if(trigger.isAfter){
        if(trigger.isInsert){
            //system.debug('PCRs after insert---' + trigger.new);
            PCR_trigger_handler.aInsert(trigger.newMap);                        
        }
        else if(trigger.isUpdate){
            //system.debug('PCRs after update---' + trigger.new);    
            PCR_trigger_handler.aUpdate(trigger.newMap, trigger.oldMap);
        }
        else if(trigger.isDelete){
            PCR_trigger_handler.aDelete(trigger.oldMap);            
        }   
        else if(trigger.isUndelete){
            PCR_trigger_handler.aUndelete(trigger.newMap);                        
        }
    }    
    
}