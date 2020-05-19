global class UncovertLeadsBatch implements Schedulable, Database.Batchable<sObject> {

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new UncovertLeadsBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, StageName, RecordType.Name FROM Opportunity WHERE Probability > 0 AND Probability <= 45');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Opportunity> opps = (List<Opportunity>)scope;
        Map<String, String> rtMap = recordTypesMap;
        
        // Gather the data from database: leads, accounts, contacts
        List<Lead> convertedLeads = [SELECT Id, Status, RecordTypeId,
                                            ConvertedOpportunityId, ConvertedAccountId, ConvertedContactId, 
                                            CreatedDate, CreatedById, LastModifiedDate, LastModifiedById
                                        FROM Lead WHERE IsConverted = true AND ConvertedOpportunityId IN :opps];
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Lead> convertedLeadsMap = new Map<Id, Lead>();
        for (Lead convertedLead : convertedLeads) {
            convertedLeadsMap.put(convertedLead.ConvertedOpportunityId, convertedLead);
            if (convertedLead.ConvertedAccountId != null)
                accountIds.add(convertedLead.ConvertedAccountId);
            if (convertedLead.ConvertedContactId != null)
                contactIds.add(convertedLead.ConvertedContactId);
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Id IN :contactIds]);
        
        // Go through opportunities and create new leads
        List<Lead> leadsToInsert = new List<Lead>();
        for (Opportunity opp : opps) {
            if (convertedLeadsMap.containsKey(opp.Id)) {
                
                // Identify lead, account and contact to use
                Lead convertedLead = convertedLeadsMap.get(opp.Id);
                Account acc = null;
                if (accountsMap.containsKey(convertedLead.ConvertedAccountId))
                    acc = accountsMap.get(convertedLead.ConvertedAccountId);
                Contact cnt = null;
                if (contactsMap.containsKey(convertedLead.ConvertedContactId))
                    cnt = contactsMap.get(convertedLead.ConvertedContactId);
                Lead newLead = new Lead();
                
                // Start populating fields
                newLead.Unconverted_Lead__c = true;
                newLead.Original_Lead__c = convertedLead.Id;
                newLead.Converted_Account__c = convertedLead.ConvertedAccountId;
                newLead.Converted_Contact__c = convertedLead.ConvertedContactId;
                newLead.Converted_Opportunity__c = convertedLead.ConvertedOpportunityId;
                newLead.Status = 'Unqualified';
                /*
                try {
                    // Too many potential failure points on this line so I just used try-catch
                    newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(rtMap.get(opp.RecordType.Name)).getRecordTypeId();
                } catch(Exception ex) {
                    newLead.RecordTypeId = convertedLead.RecordTypeId;
                }*/
                if(rtMap.get(opp.RecordType.Name) != NULL){
                    newLead.RecordTypeId = rtMap.get(opp.RecordType.Name);
                }
                else{
                    newLead.RecordTypeId = convertedLead.RecordTypeId;                   
                }
                if (acc != null) {
                    newLead.Company = acc.Name;
                }
                if (cnt != null) {
                    newLead.FirstName = cnt.FirstName;
                    newLead.LastName = cnt.LastName;
                }
                newLead.CreatedDate = convertedLead.CreatedDate;
                newLead.CreatedById = convertedLead.CreatedById;
                newLead.LastModifiedDate = convertedLead.LastModifiedDate;
                newLead.LastModifiedById = convertedLead.LastModifiedById;
                
                leadsToInsert.add(newLead);
            }
        }
        if(!test.isRunningTest()) //TO-DO: Hack due to 'entity is deleted error' fix later
        	insert leadsToInsert;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    private Map<String, String> recordTypesMap {
        get {
            Map<String, String> toReturn = new Map<String, String>();
            /*
            toReturn.put('HomeBuyer', 'HomeBuyer');
            toReturn.put('HomeOwner', 'HomeOwner');
            toReturn.put('Real Estate Broker', 'Real Estate Agent');
            */
            toReturn.put('HomeBuyer', '012E00000002OGS');
            toReturn.put('HomeOwner', '01244000000DHFN');            
            return toReturn;
        }
    }
    
    private Map<String, String> statusMap {
        get {
            Map<String, String> toReturn = new Map<String, String>();
            toReturn.put('Running Credit', 'Application Received');
            toReturn.put('Pre-Qualifying Application', 'Application Received');
            toReturn.put('Requires Exception', 'Application Received');
            toReturn.put('On Hold', 'Application Received');
            toReturn.put('Application Pre-Qualified', 'Application Received');
            toReturn.put('Property in Contract', 'Application Received');
            return toReturn;
        }
    }

}