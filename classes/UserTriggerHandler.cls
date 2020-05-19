public class UserTriggerHandler {
    
    private static final String BASE_OBJECT_APINAME = 'User';
    
    /*public static void handleLOPOperations(List<User> UserList, Boolean IsInsert) {
        Database.executeBatch(new LOPBatchProcess(IsInsert, 'User', UserList), 50);
    }*/
    
    /** 
     * Method to initiates Process of LOP sync functionality.
     * @Param       UserList, list of user records to process and sync.
     * @Param       IsToBeDelete, boolean for identify record is for delete or not.
     * @Returns		-
     */
    public static void handleLOPUserOperations(SFUtilityClass.APIOperation apiOperation, List<User> userList) {
        if(!userList.isEmpty()) { 
            Database.executeBatch(new LOPBatchProcess(apiOperation, SFUtilityClass.LOP_SFResourceName.USER, userList), (Limits.getLimitCallouts()/2));
        }
    }
}