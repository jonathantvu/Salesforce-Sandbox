//Controller extension to upgrade contact fields on opportunity when a new contact role is added
//As triggers are not allowed on OpportunityContactRole
//7/13/17 --- DEPRECATED BY CLOUD MINE CONSULTING
public with sharing class OppContactRoleHelper {
    /*
    public Opportunity opp;
    public static final String APPLICANT = 'Applicant';
    public static final String CO_APPLICANT = 'Co-Applicant';
    
    public OppContactRoleHelper(ApexPages.StandardController sc) {
        opp = (Opportunity) sc.getRecord();        
    }
    
    public void populateContactLookups(){
        OppContactRoleHelper.populateContactLookupsAsync( opp.Id );    
    }
    
    //Do processing in future method so that performace is not affected
    @future 
    public static void populateContactLookupsAsync( Id oppId ) {
        List<OpportunityContactRole> contactRoleList = [SELECT ContactId, Role
                                                        FROM OpportunityContactRole 
                                                        WHERE OpportunityId = :oppId 
                                                        AND (Role =: APPLICANT OR Role =: CO_APPLICANT OR Role=: CN_Constants.CONTACT_ROLE_LOAN_OFFICER) 
                                                        ORDER BY LastModifiedDate ASC];
		
		
        Opportunity opp = [ SELECT Id, Applicant__c, Co_Applicant__c, Sales_Director__c FROM Opportunity WHERE Id = :oppId ];
        //nullify previous values to get latest values from contact roles
        opp.Applicant__c = null;
        opp.Co_Applicant__c = null;
        opp.Sales_Director__c = null;
        for( OpportunityContactRole contactRole : contactRoleList ) {
			//update applicant
			if(contactRole.Role.equalsIgnoreCase(APPLICANT) && opp.Applicant__c != contactRole.ContactId){
				opp.Applicant__c = contactRole.ContactId;
			}
			//update co-applicant
			if(contactRole.Role.equalsIgnoreCase(CO_APPLICANT) && opp.Co_Applicant__c != contactRole.ContactId){
				opp.Co_Applicant__c = contactRole.ContactId;
			}
			//update Sales director field from loan-officer
			if(contactRole.Role.equalsIgnoreCase(CN_Constants.CONTACT_ROLE_LOAN_OFFICER)){
				List<Contact> contactList = [Select Id, Sales_Director__c FROM Contact WHERE Id =: contactRole.ContactId];
				if(contactList != null && !contactList.isEmpty()){
				    opp.Sales_Director__c = contactList[0].Sales_Director__c;
				}
			}
            
        }
		//update opportunity
		try{
			update opp;
		}catch (Exception ex){
			System.Debug('## An exception occured while update opportunity contact fields' + ex.getMessage());
		}
    }
*/
}