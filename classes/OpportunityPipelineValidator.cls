public class OpportunityPipelineValidator {
    
    private static List<Opp_Pipeline_Validation_Field__mdt> validationFieldsPrivate;
    public static List<Opp_Pipeline_Validation_Field__mdt> validationFields {
        get {
            if (validationFieldsPrivate == null) {
                validationFieldsPrivate = [SELECT Conditions__c, Description__c, Field_API_Name__c, Locked_By_Stage__c, 
                                           		Object__c, Populated_By_Stage__c, Validation__c, Additional_Fields__c
                                           FROM Opp_Pipeline_Validation_Field__mdt WHERE Active__c = true];
            }
            return validationFieldsPrivate;
        }
    }

    public static ValidationResult ValidateOpportunity(Id oppId) {
        
        Opportunity opp = LoadOpportunity(oppId);
        List<LASERCA__Trade_Accounts__c> tas = LoadTAs(oppId);
        
        ValidationResult toReturn = new ValidationResult();
        toReturn.opportunityValidation.recordId = opp.Id;
        toReturn.opportunityValidation.record = opp;
        if (opp.Applications__r != null && opp.Applications__r.size() > 0) {
        	toReturn.applicationValidation.recordId = opp.Applications__r[0].Id;
        	toReturn.applicationValidation.record = opp.Applications__r[0];
        }
        if (opp.Properties__r != null && opp.Properties__r.size() > 0) {
        	toReturn.propertyValidation.recordId = opp.Properties__r[0].Id;
        	toReturn.propertyValidation.record = opp.Properties__r[0];
        }
        if (opp.Recorded_Informations__r != null && opp.Recorded_Informations__r.size() > 0) {
        	toReturn.recInfoValidation.recordId = opp.Recorded_Informations__r[0].Id;
        	toReturn.recInfoValidation.record = opp.Recorded_Informations__r[0];
        }
        
        for (Opp_Pipeline_Validation_Field__mdt field : validationFields) {
            if (opp.StageName == field.Populated_By_Stage__c) {
                if (field.Object__c == 'Opportunity') {
                    if (!validateField(opp, field)) {
                        toReturn.opportunityValidation.fieldErrors.put(field.Field_API_Name__c, field.Description__c);
                    }
                }
                if (field.Object__c == 'Application' && opp.Applications__r != null && opp.Applications__r.size() > 0) {
                    if (!validateField(opp.Applications__r[0], field)) {
                        toReturn.applicationValidation.fieldErrors.put(field.Field_API_Name__c, field.Description__c);
                    }
                }
                if (field.Object__c == 'Property' && opp.Properties__r != null && opp.Properties__r.size() > 0) {
                    if (!validateField(opp.Properties__r[0], field)) {
                        toReturn.propertyValidation.fieldErrors.put(field.Field_API_Name__c, field.Description__c);
                    }
                }
                if (field.Object__c == 'Recorded Information' && opp.Recorded_Informations__r != null && opp.Recorded_Informations__r.size() > 0) {
                    if (!validateField(opp.Recorded_Informations__r[0], field)) {
                        toReturn.recInfoValidation.fieldErrors.put(field.Field_API_Name__c, field.Description__c);
                    }
                }
            }
        }
        
        for (LASERCA__Trade_Accounts__c ta : tas) {
            ObjectValidationResult ovr = new ObjectValidationResult();
            ovr.recordId = ta.Id;
            ovr.record = ta;
            for (Opp_Pipeline_Validation_Field__mdt field : validationFields) {
                if (opp.StageName == field.Populated_By_Stage__c) {
                    if (field.Object__c == 'Trade Account') {
                        if (!validateField(ta, field)) {
                            ovr.fieldErrors.put(field.Field_API_Name__c, field.Description__c);
                        }
                    }
                }
            }
            toReturn.taValidation.add(ovr);
        }
        
        return toReturn;
        
    }
    
    public static Opportunity LoadOpportunity(Id oppId) {
        
        STRING query = 'SELECT Id, StageName, RecordType.Name, RecordType.DeveloperName';

        // Opportunity fields
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.add('StageName');
        for (Opp_Pipeline_Validation_Field__mdt field : validationFields) {
            if (field.Object__c == 'Opportunity') {
                if (field.Field_API_Name__c != null && !fieldsSet.contains(field.Field_API_Name__c)) {
                	query += ', ' + field.Field_API_Name__c;
                    fieldsSet.add(field.Field_API_Name__c);
                }
                if (field.Additional_Fields__c != null && !fieldsSet.contains(field.Additional_Fields__c)) {
                	query += ', ' + field.Additional_Fields__c;
                    fieldsSet.add(field.Additional_Fields__c);
                }
            }
        }

        // Application fields
        query += ', ( SELECT Id';
        fieldsSet = new Set<String>();
        for (Opp_Pipeline_Validation_Field__mdt field : validationFields) {
            if (field.Object__c == 'Application') {
                if (field.Field_API_Name__c != null && !fieldsSet.contains(field.Field_API_Name__c)) {
                	query += ', ' + field.Field_API_Name__c;
                    fieldsSet.add(field.Field_API_Name__c);
                }
                if (field.Additional_Fields__c != null && !fieldsSet.contains(field.Additional_Fields__c)) {
                	query += ', ' + field.Additional_Fields__c;
                    fieldsSet.add(field.Additional_Fields__c);
                }
            }
        }
        query += ' FROM Applications__r LIMIT 1)';

        // Property fields
        query += ', ( SELECT Id';
        fieldsSet = new Set<String>();
        for (Opp_Pipeline_Validation_Field__mdt field : validationFields) {
            if (field.Object__c == 'Property') {
                if (field.Field_API_Name__c != null && !fieldsSet.contains(field.Field_API_Name__c)) {
                	query += ', ' + field.Field_API_Name__c;
                    fieldsSet.add(field.Field_API_Name__c);
                }
                if (field.Additional_Fields__c != null && !fieldsSet.contains(field.Additional_Fields__c)) {
                	query += ', ' + field.Additional_Fields__c;
                    fieldsSet.add(field.Additional_Fields__c);
                }
            }
        }
        query += ' FROM Properties__r LIMIT 1)';
        
        // Recorded Information fields
        query += ', ( SELECT Id';
        fieldsSet = new Set<String>();
        for (Opp_Pipeline_Validation_Field__mdt field : validationFields) {
            if (field.Object__c == 'Recorded Information') {
                if (field.Field_API_Name__c != null && !fieldsSet.contains(field.Field_API_Name__c)) {
                	query += ', ' + field.Field_API_Name__c;
                    fieldsSet.add(field.Field_API_Name__c);
                }
                if (field.Additional_Fields__c != null && !fieldsSet.contains(field.Additional_Fields__c)) {
                	query += ', ' + field.Additional_Fields__c;
                    fieldsSet.add(field.Additional_Fields__c);
                }
            }
        }
        query += ' FROM Recorded_Informations__r LIMIT 1)';
        
        query += ' FROM Opportunity WHERE Id = :oppId';
        
        return Database.query(query);

    }
    
    public static List<LASERCA__Trade_Accounts__c> LoadTAs(Id oppId) {
        
        List<LASERCA__Trade_Accounts__c> toReturn = new List<LASERCA__Trade_Accounts__c>();
       
        string query = 'SELECT Id, Name, Exclude__c';
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.add('Name');
        for (Opp_Pipeline_Validation_Field__mdt field : validationFields) {
            if (field.Object__c == 'Trade Account') {
                if (field.Field_API_Name__c != null && !fieldsSet.contains(field.Field_API_Name__c)) {
                	query += ', ' + field.Field_API_Name__c;
                    fieldsSet.add(field.Field_API_Name__c);
                }
                if (field.Additional_Fields__c != null && !fieldsSet.contains(field.Additional_Fields__c)) {
                	query += ', ' + field.Additional_Fields__c;
                    fieldsSet.add(field.Additional_Fields__c);
                }
            }
        }
        query += ' FROM LASERCA__Trade_Accounts__c WHERE LASERCA__Personal_Credit_Report__r.Opportunity__c = :oppId AND (Account_Status_Type__c = \'Open\' OR LASERCA__Account_Status_Type__c = \'Open\')';

        for (LASERCA__Trade_Accounts__c ta : Database.query(query)) {
            toReturn.add(ta);
        }

        return toReturn;
        
    }
    
    public static boolean validateField(sObject obj, Opp_Pipeline_Validation_Field__mdt field) {
        
        if (field.Conditions__c != null && field.Conditions__c.trim() != '') {
            if (!checkConditions(obj, field.Conditions__c)) {
                return true;
            }
        }
        
        if (!checkConditions(obj, field.Validation__c))
            return false;
        else
        	return true;
        
    }
    
    public static boolean checkConditions(sObject obj, String condition) {
        if (condition.contains('OR')) {
            List<String> conditions = condition.split('OR', 2);
            string condition1 = conditions[0].trim();
            string condition2 = conditions[1].trim();
            return checkConditions(obj, condition1) || checkConditions(obj, condition2);
        }
        if (condition.contains('AND')) {
            List<String> conditions = condition.split('AND', 2);
            string condition1 = conditions[0].trim();
            string condition2 = conditions[1].trim();
            return checkConditions(obj, condition1) && checkConditions(obj, condition2);
        }
        string operator;
        if (condition.contains('==')) {
            operator = '==';
        }
        if (condition.contains('!=')) {
            operator = '!=';
        }
        if (condition.contains('>')) {
            operator = '>';
        }
        if (condition.contains('<')) {
            operator = '<';
        }
        if (condition.contains('<=')) {
            operator = '<=';
        }
        if (condition.contains('>=')) {
            operator = '>=';
        }
        if (condition.contains('CONTAINS')) {
            operator = 'CONTAINS';
        }
        if (condition.contains('NOTCONTAINS')) {
            operator = 'NOTCONTAINS';
        }
        if (operator != null) {
            List<String> parts = condition.split(operator, 2);
            string field = parts[0].trim();
            string valueStr = parts[1].trim();

            object fieldVal;
            if (field.toLowerCase() == 'recordtype')
                fieldVal = obj.getSObject('RecordType').get('DeveloperName');
            else
            	fieldVal = obj.get(field);

            if (valueStr.toLowerCase() == 'null') { // Handle nulls
                if (operator == '==') {
                    return (fieldVal == null);
                }
                if (operator == '!=') {
                    return (fieldVal != null);
                }
                return false;
            }

            if (valueStr.toLowerCase() == 'true' || valueStr.toLowerCase() == 'false') { // Handle booleans
                boolean value = Boolean.valueOf(valueStr.toLowerCase());
                if (operator == '==') {
                    return (fieldVal == value);
                }
                if (operator == '!=') {
                    return (fieldVal != value);
                }
                return false;
            }

            if (valueStr.startsWith('\'') && valueStr.endsWith('\'')) { // Handle strings
                string value = valueStr.substring(1, valueStr.length() - 1);
                if (operator == '==') {
                    return (fieldVal == value);
                }
                if (operator == '!=') {
                    return (fieldVal != value);
                }
                if (operator == '>') {
                    return ((String)fieldVal > value);
                }
                if (operator == '<') {
                    return ((String)fieldVal < value);
                }
                if (operator == '>=') {
                    return ((String)fieldVal >= value);
                }
                if (operator == '<=') {
                    return ((String)fieldVal <= value);
                }
                if (operator == 'CONTAINS') {
                    return (((String)fieldVal).toLowerCase().contains(value.toLowerCase()));
                }
                if (operator == 'NOTCONTAINS') {
                    return !(((String)fieldVal).toLowerCase().contains(value.toLowerCase()));
                }
                return false;
            }

            boolean isDecimal = false; // Handle numbers
            try {
                Decimal.valueOf(valueStr);
                isDecimal = true;
            } catch (Exception ex) {}
            if (isDecimal) {
                decimal value = Decimal.valueOf(valueStr);
                if (operator == '==') {
                    return (fieldVal == value);
                }
                if (operator == '!=') {
                    return (fieldVal != value);
                }
                if (operator == '>') {
                    return ((decimal)fieldVal > value);
                }
                if (operator == '<') {
                    return ((decimal)fieldVal < value);
                }
                if (operator == '>=') {
                    return ((decimal)fieldVal >= value);
                }
                if (operator == '<=') {
                    return ((decimal)fieldVal <= value);
                }
                return false;
            }
        }
        return false;
    }
    
    public class ValidationResult {
        public ObjectValidationResult opportunityValidation { get; set; }
        public ObjectValidationResult applicationValidation { get; set; }
        public ObjectValidationResult propertyValidation { get; set; }
        public ObjectValidationResult recInfoValidation { get; set; }
        public List<ObjectValidationResult> taValidation { get; set; }
        public boolean hasTas {
            get {
                return taValidation != null && taValidation.size() > 0;
            }
        }
        public boolean taValidationHasErrors {
            get {
                if (!hasTas) {
                    return false;
                }
                boolean toReturn = false;
                for (ObjectValidationResult taV : taValidation) {
                    toReturn = toReturn || taV.hasErrors;
                }
                return toReturn;
            }
        }

        public boolean isAllValid {
            get {
                boolean toReturn = true;
                toReturn = toReturn && (applicationValidation.recordId == null || !applicationValidation.hasErrors);
                toReturn = toReturn && (propertyValidation.recordId == null || !propertyValidation.hasErrors);
                toReturn = toReturn && (recInfoValidation.recordId == null || !recInfoValidation.hasErrors);
                if (hasTAs) {
                    for (ObjectValidationResult taV : taValidation) {
                        toReturn = toReturn && !taV.hasErrors;
                    }
                }
                return toReturn;
            }
        }
        
        public ValidationResult() {
            opportunityValidation = new ObjectValidationResult();
            applicationValidation = new ObjectValidationResult();
            propertyValidation = new ObjectValidationResult();
            recInfoValidation = new ObjectValidationResult();
            taValidation = new List<ObjectValidationResult>();
        }
    }
    
    public class ObjectValidationResult {
        public Id recordId { get; set; }
        public sObject record { get; set; }
        public Map<String, String> fieldErrors { get; set; }
        public boolean hasErrors {
            get {
                return fieldErrors != null && fieldErrors.size() > 0;
            }
        }
        
        public ObjectValidationResult() {
            fieldErrors = new Map<String, String>();
        }
    }
    
}