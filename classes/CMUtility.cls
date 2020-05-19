/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Utility Class of helpful functions
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Initial implementation
* @author       Cloud Mine Consulting (www.cloudmineconsulting.com)
* @created      
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* Changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class CMUtility {

    public static string getCreatableFieldsSOQL(String objectName, String whereClause) {
        String selects = '';
        if (whereClause == null || whereClause == '') {
            return null;
        }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()) { // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()) {
            for (string s:selectFields) {
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }

    
}