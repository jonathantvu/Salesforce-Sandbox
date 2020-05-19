public class AccountTriggerHandler {
    public static boolean SFDC2SFDC_FLAG = FALSE;    
    /** 
     * Method to initiates Process of LOP sync functionality.
     * @Param       accountList, list of account records to process and sync.
     * @Param       IsToBeDelete, boolean for identify record is for delete or not.
     * @Returns     -
     */
    public static void handleLOPLenderOperations(SFUtilityClass.APIOperation apiOperation, List<Account> accountList) {
        if(!accountList.isEmpty()) {
            Database.executeBatch(new LOPBatchProcess(apiOperation, SFUtilityClass.LOP_SFResourceName.ACCOUNT, accountList), Limits.getLimitCallouts());
        }
    }
    
    public static void onAfterUpdate(List<Account> acclist, Map<Id,Account> oldMap){
        Set<Id> imreadyaccids = new Set<Id>();
                   
        for(Account acc: acclist) {                
            //capturinf accounts ids when Ready_for_IM__c is changed 
            if(acc.Ready_for_IM__c == True && oldMap.get(acc.Id).Ready_for_IM__c == False) { 
                imreadyaccids.add(acc.Id); 
            }
        }
        
        system.debug('****imreadyaccids******'+imreadyaccids);
        if(imreadyaccids.size() > 0 && !SFDC2SFDC_FLAG){
            AccountUtilityClass.createAccount(imreadyaccids);
            SFDC2SFDC_FLAG = TRUE;                           
        }
    }
        
}