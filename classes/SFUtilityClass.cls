/**
 * Utility class for reguler SF operations.
 * @Created Date : 03-04-2017
 * @Authors      : StarrData
 */
global with sharing class SFUtilityClass {
    
    global enum APIOperation { API_CREATE, API_UPDATE, API_DELETE }
    global enum LOP_SFResourceName { CONTACT, ACCOUNT, USER }
    public enum ApexDMLOptions { APEX_INSERT, APEX_UPDATE, APEX_DELETE, APEX_UNDELETE, APEX_MERGE }
    
    private static SFUtilityResult SFUtilityResultInstance;
        
    /** 
     * Method to handle apex DML operations.(bulkify)
     * @Param       sObjectList, sObject list for DML operation
     * @Param       SFobjectName, API name of base Object.
     * @Param       dmlOperation, contains specific DML operation to be done.
     * @Returns     Boolean for DML success.
     */
    public static SFUtilityResult apexDMLHandler(List<sObject> sObjectList, String SFobjectName, ApexDMLOptions dmlOperation) {
        SFUtilityResultInstance = new SFUtilityResult();
        List<sObject> records = getTypeCastedSObjectList(SFobjectName);
        if(records != null) {
            records.addAll(sObjectList);        
            try {
                if(dmlOperation.name().equalsIgnoreCase(ApexDMLOptions.APEX_UPDATE.name())) {
                    update records;
                    SFUtilityResultInstance.isSuccess = true;
                    SFUtilityResultInstance.displayMessage = 'Data ' + dmlOperation.name() + ' Successful!';
                    SFUtilityResultInstance.result = records;
                }
            } catch(Exception exp) {
                logMessageFromException(exp);
                SFUtilityResultInstance.displayMessage = 'Data ' + dmlOperation.name() + ' Failuer!';
            }
            return SFUtilityResultInstance;
        }
        SFUtilityResultInstance.displayMessage = 'Object Not Found --> ' + SFobjectName;
        return SFUtilityResultInstance;
    }
    
    /** 
     * Method returns Type Casted SObject list.
     * @Param       SFobjectName, SF Object API name.
     * @Returns     List Of Type Casted sObject List.
     */
    public static List<SObject> getTypeCastedSObjectList(String SFobjectName) {
        SFUtilityResultInstance = new SFUtilityResult();
        SFUtilityResultInstance = checkSObjectAvailability(SFobjectName);
        if(SFUtilityResultInstance.isSuccess) {
            Type sObjectListType = Type.ForName('List<' + SFobjectName + '>');             
            return (List<SObject>) sObjectListType.newInstance();
        }
        return null;
    }
    
    /**
     * Method for check sObject Availability.
     * @Param       objName, API name of SF object(standard/custom)
     * @Returns     Boolean is assure presence of object in SF.
     */
    public static SFUtilityResult checkSObjectAvailability(String objName) {
        SFUtilityResultInstance = new SFUtilityResult();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        SFUtilityResultInstance.isSuccess = Schema.getGlobalDescribe().containsKey(objName);
        SFUtilityResultInstance.displayMessage = (SFUtilityResultInstance.isSuccess) ? 
                                                  'sObject Available In Org' :
                                                  'sObject Not Available In Org';
        return SFUtilityResultInstance;
    }
        
    /** 
     * Combines All SFUtility Results in single SFUtility Result. for LOP Integration use only.
     * @Param       SFUtilityResultList, List of SFUtilityResult.
     * @Returns     instance of SFUtilityResult.
     */
    public static SFUtilityResult combineSFUtilityResults(List<SFUtilityResult> SFUtilityResultList) {
        SFUtilityResult SFUtilityResultObj = new SFUtilityResult();
        if(!SFUtilityResultList.isEmpty()){
            SFUtilityResultObj.isSuccess = true;
            for(Integer index = 0; index < SFUtilityResultList.size(); index++) {
                SFUtilityResultObj.isSuccess &= SFUtilityResultList[index].isSuccess;
                SFUtilityResultObj.displayMessage += 'Result '+String.valueOf(index+1)+': ' + SFUtilityResultList[index].displayMessage + '#;#';            
                SFUtilityResultObj.result.add(SFUtilityResultList[index].result[0]);
            }
            SFUtilityResultObj.displayMessage = SFUtilityResultObj.displayMessage.removeEnd('#;#');
        }        
        return SFUtilityResultObj;
    }
    
    /** 
     * Display the exception message.
     * @Param       exp, Instance of Exception class.
     * @Returns     -
     */
    public static void logMessageFromException(Exception exp) {       
        String strErrorMessage;
        if(exp != Null) {        
            strErrorMessage = '\n Error Message:-{0} \n Error LineNumber:-{1}';
            List<String> listOfMessageTokens = new List<String>{exp.getMessage(), String.valueOf(exp.getLineNumber())};
            strErrorMessage = String.format(strErrorMessage, listOfMessageTokens);
        }
        System.debug(strErrorMessage);
    }
}