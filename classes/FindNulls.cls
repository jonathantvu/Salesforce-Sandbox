/*Author: Carolina Veliz & Eliot Rojas
        * Finds all currency fields on Lead Record and set it to Zero.*/
public class FindNulls {
    public static void populateNulls(String sObjectName, Map<Id, SObject> newRecords) {
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        List<String> myList = new List<String>();
        
        for(Schema.SObjectField field : r.fields.getMap().values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            if((fieldResult.getType() == Schema.DisplayType.CURRENCY || fieldResult.getType() == Schema.DisplayType.PERCENT) && fieldResult.isUpdateable()) {
                myList.add(fieldResult.getName());
            }
        }

        for(String fieldName : myList) {
            if(fieldName != 'Post_Close_BE_Ratio__c' && fieldName != 'Pre_Close_BE_Ratio__c'
                    && fieldName != 'Post_Close_FE_Ratio2__c' && fieldName != 'Pre_Close_FE_Ratio2__c') {
                for (sObject record : newRecords.values()) {
                    if (record.get(fieldName) == null) {
                        record.put(fieldName, 0);
                    }
                }
            }
        }
    }

    public static void populateNulls(String sObjectName, list<sObject> newRecords) {
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        List<String> myList = new List<String>();

        for(Schema.SObjectField field : r.fields.getMap().values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            if((fieldResult.getType() == Schema.DisplayType.CURRENCY || fieldResult.getType() == Schema.DisplayType.PERCENT) && fieldResult.isUpdateable()) {
                myList.add(fieldResult.getName());
            }
        }

        for(String fieldName : myList) {
            if(fieldName != 'Post_Close_BE_Ratio__c' && fieldName != 'Pre_Close_BE_Ratio__c'
                    && fieldName != 'Post_Close_FE_Ratio2__c' && fieldName != 'Pre_Close_FE_Ratio2__c') {
                for (sObject record : newRecords) {
                    if (record.get(fieldName) == null) {
                        record.put(fieldName, 0);
                    }
                }
            }
        }
    }
}