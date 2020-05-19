public class LeadTriggerHandlerPC {
    public static boolean createdRequirements  = false;
    
    //Contants
    private static final string HOUSEHOLD_RT_LABEL = 'Household';
    private static final string LENDER_LABEL = 'Lender';
    private static final string REAL_ESTATE_BROKER_LABEL = 'Real Estate Broker';
    private static final string HOME_OWNER = 'HomeOwner';
    private static final string HOME_BUYER = 'HomeBuyer';
    private static boolean LEAD_CONVUPDATE_FLAG = FALSE;
    private static boolean LEAD_STATUSUPDATE_FLAG = FALSE;
    private static boolean LEAD_QCSTATUUPDATE_FLAG = FALSE;
    private static boolean LEAD_REQ_FLAG = FALSE;
    
    public static Boolean LEADUPDATE_FLAG = false;
    //Collections
    private static Map<string, Contact> personalCodeContactMap = new Map<string, Contact>();
    private static Map<string, Contact> getPersonalCodeContactMap(){
        if(personalCodeContactMap.isEmpty() || personalCodeContactMap == NULL){
            for(Contact c: [SELECT Id, RecordTypeId, Name, Personalized_Referral_Code__c, Account.Name FROM Contact WHERE Personalized_Referral_Code__c != NULL]){
                personalCodeContactMap.put(c.Personalized_Referral_Code__c, c);
            }
        }
        return personalCodeContactMap;
    }
    private static final Map<Id,User> PSUsersMap = new Map<Id, User>([SELECT Id FROM User WHERE Profile.Name = 'LoanCraft Manager' OR Profile.Name = 'LoanCraft Program Specialist' OR Profile.Name = 'LoanCraft Quality Assurance Specialist']);
    
    private static Map<string, Contact> REAgentEmailMap = new Map<string, Contact>();
    private static Map<string, Contact> getREAgentEmailMap(set<string> emailSet){
        if(reAgentEmailMap.isEmpty() || reAgentEmailMap == NULL){
            for(Contact c: [SELECT Id, RecordTypeId, Name, Email, Account.Name FROM Contact WHERE RecordType.Name = :REAL_ESTATE_BROKER_LABEL AND Email IN: emailSet]){
                reAgentEmailMap.put(c.Email, c);
            }
        }
        return reAgentEmailMap;
    }
    
    private static final Schema.DescribeSObjectResult contDesc = Schema.SObjectType.Contact;
    private static final Map<Id, Schema.RecordTypeInfo> contactRTByIdMap = contDesc.getRecordTypeInfosById();
    
    private static final Schema.DescribeSObjectResult leadDesc = Schema.SObjectType.Lead;
    private static final Map<Id, Schema.RecordTypeInfo> LeadRTByIdMap = leadDesc.getRecordTypeInfosById();
	private static final Id HomeBuyerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
	private static final Id HomeOwnerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();    
    private static final Id HomeBuyerIdCAN = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer Canada').getRecordTypeId();    
    
    //Used to make sure converted leads are not processed twice due to workflow/PB updates after conversion
    //causing triggers to fire twice
    private static set<Id> alreadyConvertedLeadIDSet = new Set<Id>();
    
    //Used to make sure duplicate NPM records are not created twice due to workflow/PB updates
    //causing triggers to fire twice
    private static set<Id> alreadyCreatedNPMLeadIDSet = new Set<Id>();
    
	private static set<Id> leadsThatNeedSuccessFactorsSet = new Set<Id>();    
    /** 
* Method to Update lead Phone numbers to avoid Duplicates from TalkDesk
* @Param       contactList, list of contact records to process and sync.
* @Param       
* Author -- Neeraja Cherukuri
*/    
    
    public static void rewritePhoneOnLead (List<Lead> newList)
    { 
        for(Lead objLead : newList)
        {
            if(objLead.Phone != null && !(objLead.Phone).startsWith('+1'))
            {
                System.debug('=======updatePhone Format===');
                objLead.Phone = phoneNumberTransform.standardize(objLead.Phone);
            }
        }
    }
    
    
    /**
*  About
*  -----
*  Author: Cloud Nerd
*
*  Details
*  -----
*  Method to take care of all functionalities when BEFORE INSERT fires
**/
    public static void handleBeforeInsert(List<Lead> newList){
        
        List<Lead> leadsToAssignToCallNowQueue = new List<Lead> ();
        List<Lead> listLeadsWithLoanOfficer = new List<Lead> ();
        Set<String> setLoanOfficerEmails    = new Set<String>();
        Set<Id> referringLoanOfficerIds = new Set<Id>();
        List<Lead> LeadsWithReferringLoanOfficer = new List<Lead>();
        List<Lead> leadsWithRealEstateAgent = new List<Lead>();
        
        Map<String,Campaign_Code_Attribution__c> campaignCodeMap = Campaign_Code_Attribution__c.getAll();
        
        //send auto-decline leads logic
        LeadDeclineHelper.autoDeclineLeads(newList);
        invalidateEmail.invalidateEmail(newList);
        
        for (Lead newLead: newList) {

            
            //check formId field to populate loan officer from form assembly data
            if(newLead.FormID__c != null){
                listLeadsWithLoanOfficer.add(newLead);
                setLoanOfficerEmails.add(newLead.FormId__c);
            }
            
            //set Default Campaign Audience
            newLead.Campaign_Audience__c = 'Consumer';
            //set Default Spend Vintage Date/Time
            newLead.Spend_Vintage_Date_Time__c = datetime.now();
            
            //If not ignoring attribution flow
            if(!newLead.Ignore_Attribution_Flow__c){
                //Manually Created Lead Pathway
                if(newLead.Manually_Generated_Lead__c == 'Yes' ){
                    //Set Campaign Code Attribution values
                    newLead.Inbound_Response_Channel__c = 'Phone';
                    if(campaignCodeMap.get(newLead.Campaign_Content__c) != NULL ){
                        newLead.Campaign_Medium__c = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Campaign_Medium__c : '';
                        newLead.Campaign_Name__c = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Campaign_Name__c : '';
                        newLead.Campaign_Source__c = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Campaign_Source__c : '';
                        newLead.Campaign_Term__c = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Campaign_Term__c : '';
                        newLead.Branding_Type__c  = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Branding_Type__c : '';
                        newLead.Campaign_Media_Type__c  = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Campaign_Media_Type__c  : '';
                        newLead.LeadSource  = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Lead_Source__c  : '';
                        newLead.Outbound_Marketing_Channel__c  = (campaignCodeMap.get(newLead.Campaign_Content__c) != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Outbound_Marketing_Channel__c  : '';
                        newLead.Campaign_Audience__c = campaignCodeMap.get(newLead.Campaign_Content__c).Campaign_Audience__c;
                        //lead vintage spend date/time logic
                        //If Channel is Direct Mail, use campaign code drop date to set vintage spend datetime, otherwise leave as createdDate
                        if(newLead.Outbound_Marketing_Channel__c == 'Direct Mail')
                        {
                            newLead.Spend_Vintage_Date_Time__c = ( campaignCodeMap.get(newLead.Campaign_Content__c) != NULL && campaignCodeMap.get(newLead.Campaign_Content__c).Direct_Marketing_Drop_Date_Time__c != NULL) ? campaignCodeMap.get(newLead.Campaign_Content__c).Direct_Marketing_Drop_Date_Time__c : NULL;
                        }
                        
                    }
                    //Add Loan Officer Referral Contact Ids to Set
                    if(newLead.Referring_Contact__c != NULL && newLead.Manually_Generated_Lead__c == 'Yes'){
                        referringLoanOfficerIds.add(newLead.Referring_Contact__c);
                        LeadsWithReferringLoanOfficer.add(newLead);
                    }
                }
                //personalized referral code pathway
                else if(newLead.Campaign_Content__c != NULL && getPersonalCodeContactMap().get(newLead.Campaign_Content__c) != NULL){
                    personalReferralCodeAttribution(newLead);
                }
                //social campaign source pathway, OB marketing channel
                //else if(newLead.Campaign_Source__c == 'facebook' || newLead.Campaign_Source__c == 'twitter' || newLead.Campaign_Source__c == 'linkedin' || newLead.Campaign_Source__c == 'instagram'){
                //  newLead.Outbound_Marketing_Channel__c = 'Social';
                //}
                else { //non-manual lead pathway
                    newLead.Inbound_Response_Channel__c = 'Web';
                    //Campaign Term Refers to a ContactId
                    if( (newLead.Campaign_Source__c != NULL || newLead.Campaign_Medium__c != NULL || newLead.Campaign_Content__c != NULL) && newLead.Campaign_Term__c != NULL && newLead.Campaign_Term__c.left(3) == '003' ){
                        newLead.Referring_Contact__c = newLead.Campaign_Term__c;
                        LeadsWithReferringLoanOfficer.add(newLead);
                        referringLoanOfficerIds.add(newLead.Campaign_Term__c);
                        setCampaignSourceAttribution(newLead);
                    }
                    //Campaign Term does NOT Refer to a ContactId but campaign fields are not blank
                    else if (newLead.Campaign_Source__c != NULL || newLead.Campaign_Medium__c != NULL || newLead.Campaign_Content__c != NULL){
                        newLead.LeadSource = 'Direct Response';
                        newLead.Branding_Type__c = 'Open Market';
                        setCampaignSourceAttribution(newLead);
                    }
                    else{
                        newLead.LeadSource = 'Unattributed';
                        newLead.Branding_Type__c = 'Open Market';
                        newLead.Outbound_Marketing_Channel__c = 'Web';
                    }
                }
            }
            //collect leads with Real Estate Agent information for processing
            if(newLead.Real_Estate_Agent_Email__c != NULL && newLead.Real_Estate_Agent_Free_Response__c != NULL && newLead.Referring_Contact__c == NULL ){
                leadsWithRealEstateAgent.add(newLead);
            }
            
            //Sundar Subramaniam 04/30/2019: Check if the credit score is less than 650 make lead status closed lost
            if(newLead.Applicant_Credit_Score_Estimate__c != null){
                if(newLead.Applicant_Credit_Score_Estimate__c.trim() == '650' || newLead.Applicant_Credit_Score_Estimate__c.trim() == '< 650'){
                    newLead.Status = 'Closed Lost';
                }else if(newLead.Applicant_Credit_Score_Estimate__c.trim().isNumeric() && Integer.valueof(newLead.Applicant_Credit_Score_Estimate__c.trim()) <= 650){
                    newLead.Status = 'Closed Lost';
                }
            }
        }
        
        //Call method to Set Lead attribution Fields based on referring Loan Officer/Contact
        if(!LeadsWithReferringLoanOfficer.isEmpty() && !referringLoanOfficerIds.isEmpty()){
            assignLoanOfficerReferralFields(LeadsWithReferringLoanOfficer,referringLoanOfficerIds );
        }
        
        FindNulls.populateNulls('Lead', newList);
        
        //Call method to Set Referring Contact based on Real Estate Agent information
        if(!leadsWithRealEstateAgent.isEmpty()){
            handleRealEstateAgentReferrals_before(leadsWithRealEstateAgent);
        }
        
        //Call method to find loan officer contact based on form assembly data (Form ID field) and update on lead
        /*-----Deprecated by Omnivo Digital 7/11/17
if (!listLeadsWithLoanOfficer.isEmpty() && !setLoanOfficerEmails.isEmpty()){
assignLoanOfficer(listLeadsWithLoanOfficer, setLoanOfficerEmails);
}*/
        
        CopyRecordType(newList);
        //2019-04-24 --- Disabling RSM lookup automation per request of Johnny Trieu and Kevin Wu
        //LookupRegionalManager(newList, null);
        
        SetQualifiesforNewHOPricing(newList);        
    }
    
    /**
*  About
*  -----
*  Author: Cloud Nerd
*
*  Details
*  -----
*  Method to take care of all functionalities when AFTER INSERT fires
**/
    public static void handleAfterInsert(List<Lead> newList){
        CalculateNumberOfReferredLeads(true, false, false, newList, null);
	TuneIntegration(newList, null);
    }
    
 /**
*  About
*  -----
*  Author: Cloud Nerd
*
*  Details
*  -----
*  Method to take care of all functionalities when BEFORE UPDATE fires
*
*  Changes
*  -----
*  5/30/17 - Omnivo Digital- added method to check referring contact lookup and call method to populate dependent fields
**/
    public static void handleBeforeUpdate(Map<Id,Lead> mapNewLeads, Map<Id,Lead> mapOldLeads){
        
        List<Lead> listLeadsWithLoanOfficer = new List<Lead> ();
        Set<String> setLoanOfficerEmails    = new Set<String>();
        List<Lead> leadsToGenerateSignature = new List<Lead>();
        List<Lead> autoDeclineLeads = new List<Lead>();
        //Map to hold opportunity ids along with contact ids to create contact roles
        Map<id, id> mapOppIdContactId = new Map<id, id>();
        
        Set<Id> referringLoanOfficerIds = new Set<Id>();
        List<Lead> LeadsWithReferringLoanOfficer = new List<Lead>();
        invalidateEmail.invalidateEmail(mapNewLeads.values());
        
        for(Lead newLead: mapNewLeads.values()) {
            Lead oldLead = mapOldLeads.get(newLead.Id);
            
            //Check for TRACKING ID change
            if (newLead.Application_Tracking_ID__c != oldLead.Application_Tracking_ID__c){
                leadsToGenerateSignature.add(newLead);
            }
            
            //check formId field to populate loan oficer from form assembly data
            if(newLead.FormID__c != null && newLead.FormID__c != oldLead.FormID__c){
                listLeadsWithLoanOfficer.add(newLead);
                setLoanOfficerEmails.add(newLead.FormId__c);
            }
            
            //Check if the lead is converted and it has opportunity id then create Opportunity contact role for loan officer on the goven opportunity
            if(newLead.isConverted && !oldLead.isConverted && newLead.ConvertedOpportunityId != null && newLead.Loan_Officer__c != null){
                mapOppIdContactId.put(newLead.ConvertedOpportunityId, newLead.Loan_Officer__c);
            }
            
            //Check if referring contact field is changed
            if(newLead.Referring_Contact__c != mapOldLeads.get(newLead.Id).Referring_Contact__c && newLead.Manually_Generated_Lead__c == 'Yes'){
                referringLoanOfficerIds.add(newLead.Referring_Contact__c);
                LeadsWithReferringLoanOfficer.add(newLead);
            }
            
            //Check if campaign content is changed and go to that pathway
            if(newLead.Campaign_Content__c != NULL && getPersonalCodeContactMap().get(newLead.Campaign_Content__c) != NULL
               && newLead.Campaign_Content__c != mapOldLeads.get(newLead.Id).Campaign_Content__c){
                   personalReferralCodeAttribution(newLead);
               }
            
            //check if Run Property Pre Qualification and validate all required values
            if(newLead.Run_Property_Pre_Qualification__c == True && oldLead.Run_Property_Pre_Qualification__c == False) {
                if(newLead.Property_Street_Number_and_Name__c == NULL){
                    newLead.addError('Property Street Number and Name is required order to submit inquiry.');
                }
                if(newLead.Property_City__c == NULL){
                    newLead.addError('Property City is required order to submit inquiry.');
                }
                if(newLead.Property_State__c == NULL){
                    newLead.addError('Property State is required order to submit inquiry.');
                }
                if(newLead.Property_Zip_Code__c == NULL){
                    newLead.addError('Property Zip is required order to submit inquiry.');
                }
                if(newLead.New_Construction_Dropdown__c == NULL){
                    //newLead.addError('New Construction is required order to submit inquiry.');
                    newLead.New_Construction_Dropdown__c = 'No';
                }
                if(newLead.Occupancy_Statement_Dropdown__c == NULL){
                    //newLead.addError('Occupancy Statement is required order to submit inquiry.');
                    newLead.Occupancy_Statement_Dropdown__c = 'Principal Residence';
                }
                
                
            }
	    /*Add county field to SF and auto-decline NY counties*/			
	    /*Ticket: https://unison-technology.atlassian.net/browse/BUS-155110006 */	
            if( newLead.isConverted && string.isBlank( newLead.Property_County__c)) {
                newLead.addError('Property County is required before converting the Lead.');
            }
            if (( newLead.status != 'Closed Lost') &&
                    ((newLead.Property_State__c != oldLead.Property_State__c ) ||
                            (newLead.Property_County__c != oldLead.Property_County__c )) ){
                autoDeclineLeads.add(newLead);
            }
            /* * * */
            //Sundar Subramaniam 04/30/2019: Check if the credit score is less than 650 make lead status closed lost
            if(newLead.Applicant_Credit_Score_Estimate__c != null){
                if(newLead.Applicant_Credit_Score_Estimate__c != mapOldLeads.get(newLead.Id).Applicant_Credit_Score_Estimate__c && (newLead.Applicant_Credit_Score_Estimate__c.trim() == '650' || newLead.Applicant_Credit_Score_Estimate__c.trim() == '< 650')){
                    newLead.Status = 'Closed Lost';
                }else if(newLead.Applicant_Credit_Score_Estimate__c != mapOldLeads.get(newLead.Id).Applicant_Credit_Score_Estimate__c && newLead.Applicant_Credit_Score_Estimate__c.trim().isNumeric() && Integer.valueof(newLead.Applicant_Credit_Score_Estimate__c.trim()) <= 650){
                    newLead.Status = 'Closed Lost';
                }
            }
            /*Date of Birth / Marital Status / SSN = required fields in SF lead prior to conversion*/
            //https://unison-technology.atlassian.net/browse/BUS-155111309
            if( newLead.isConverted ){

                string errors='';
                string coErrors='';

                if (string.isBlank(newLead.Applicant_Social_Security_Number__c)){
                    errors = 'Social Security Number,';
                }
                if (string.isBlank(newLead.Marital_Status__c)){
                    errors = errors +'Marital Status,';
                }
                if (string.isBlank(newLead.Applicant_Birth_Date_Free_Response__c)){
                    errors = errors +'Birth Date' ;
                }
                if (string.isNotEmpty( errors )) {
                    if (errors.right(1) == ',' )
                        errors = errors.left(errors.length()-1);
                    errors = 'Applicant\'s ' + errors + '.';
                }

                if (newLead.Is_there_Co_App__c){
                    if (string.isBlank(newLead.Co_Applicant_Social_Security_Number__c)){
                        coErrors = coErrors +'Social Security Number,'  ;
                    }
                    if (string.isBlank(newLead.Marital_Status_co__c)){
                        coErrors = coErrors +'Marital Status,' ;
                    }
                    if (string.isBlank(newLead.Co_Applicant_Birth_Date_Free_Response__c)){
                        coErrors = coErrors + 'Birth Date' ;
                    }
                    if (string.isNotEmpty( coErrors )) {
                        if (coErrors.right(1) == ',' )
                            coErrors = coErrors.left(coErrors.length()-1);
                        coErrors = ' Co-applicant\'s ' +  coErrors;
                    }
                }

                if (string.isNotBlank(errors) || string.isNotBlank(coErrors))  {
                    newLead.addError(errors + coErrors + ' are required before converting the Lead.' );
                    system.debug(errors);
                }
            }
        }
        
        //Call method to Set Lead attribution Fields based on referring Loan Officer/Contact
        if(!LeadsWithReferringLoanOfficer.isEmpty() && !referringLoanOfficerIds.isEmpty()){
            assignLoanOfficerReferralFields(LeadsWithReferringLoanOfficer,referringLoanOfficerIds );
        }
        
        if (autoDeclineLeads.size()>0){
            leadDeclineHelper.autoDeclineLeads(autoDeclineLeads);
        }
        FindNulls.populateNulls('Lead', mapNewLeads);
        CopyRecordType(mapNewLeads.values());
        //2019-04-24 --- Disabling RSM lookup automation per request of Johnny Trieu and Kevin Wu
        //LookupRegionalManager(mapNewLeads.values(), mapOldLeads);
        
        SetQualifiesforNewHOPricing(mapNewLeads.values());
	
	TuneIdsCheck(mapNewLeads.values(), mapOldLeads);
        
    }
    
    /**
*  About
*  -----
*  Author: Cloud Nerd
*
*  Details
*  -----
*  Method to take care of all functionalities when AFTER UPDATE fires
*
**/
    public static void handleAfterUpdate(List<Lead> newList, Map<Id, Lead> oldMap) {
        Set<Id> leadPCRRollupSet = new Set<Id>();
        Set<Id> mrdleadids = new Set<Id>();
        Set<Id> creditleadids = new Set<Id>();
        Set<Id> applleadids = new Set<Id>();
        Set<Id> convleadids = new Set<Id>();
        Set<Id> leadids = new Set<Id>();
        Set<Id> leadWithReqsToComplete = new Set<Id>();
        Set<Id> leadWithApplicationReqs = new Set<Id>();
        
        List<Success_Factor__c> sfappl = new List<Success_Factor__c>();
        List<Success_Factor__c> sfcredit = new List<Success_Factor__c>();
        //Returning from Closed Lost Success Factor Processing
		//collect leads that moved out of Closed Lost
		List<Id> unClosedLost_leadIdList = new List<Id>();
        for(Lead obj: newList){

			system.debug('obj.Status--' + obj.Status);
			system.debug('oldMap.get(obj.Id).Status--' + oldMap.get(obj.Id).Status);                     
			if(!leadsThatNeedSuccessFactorsSet.contains(obj.Id) && obj.Status != 'Closed Lost' && oldMap.get(obj.Id).Status == 'Closed Lost' && (obj.RecordTypeId == HomeBuyerId || obj.RecordTypeId == HomeOwnerId) ){                       
				unClosedLost_leadIdList.add(obj.Id);
            	leadsThatNeedSuccessFactorsSet.add(obj.Id);                
			}              
        }      
		//send to Success Factor Processing
		if(!unClosedLost_leadIdList.isEmpty()){
			SuccessFactorsHelper.generateLeadSuccessFactors(unClosedLost_leadIdList);
		}

        if (newList != Null && newList.size() > 0 && oldMap != Null && oldMap.keyset().size() > 0) {
            system.debug('****** newList ******');
            system.debug(newList.size());
            system.debug(newList);
            
            LeadUtilityClass.CreateCurrentConditions(newList, oldMap);
			LeadUtilityClass.switchR1125Req(newList, oldMap);	
            
            for (Lead ld : newList) {
                system.debug('**** ld.isconverted ****');
                system.debug(ld.isconverted);
                //Caro Veliz: added the if(!ld.isconverted), to avoid error Too many SOQL queries.
                //This logic shouldn't be executed on Lead Conversion.
                //Ticket: https://unison-technology.atlassian.net/browse/BUS-155110270
                if(!ld.isconverted) {

                    //molinger - create requirements when stage changes
                    System.debug('ld.Status: ' + ld.Status);
                    System.debug('oldMap.get(ld.Id).Status: ' + oldMap.get(ld.Id).Status);
                    if (ld.Status != oldMap.get(ld.Id).Status && ld.status == 'Application Sent'
                            && (ld.RecordTypeId == HomeBuyerId || ld.RecordTypeId == HomeBuyerIdCAN|| ld.RecordTypeId == HomeOwnerId)) {
                        leadWithApplicationReqs.add(ld.Id);
                    }

                    
                    if (ld.Status != oldMap.get(ld.Id).Status && ld.Status == 'Application Received' && ld.RecordTypeId == HomeOwnerId) {
                        leadWithReqsToComplete.add(ld.Id);
                    }
                    
                    if (ld.Status != oldMap.get(ld.Id).Status && ld.Status == 'Pending Submission' && ld.RecordTypeId == HomeBuyerId) {
                        leadWithReqsToComplete.add(ld.Id);
                    }

                    if ((ld.SuccessFactor_Creation_TimeStamp__c != null) && (ld.Status == 'Pre-Discovery') && (ld.RecordTypeId == HomeBuyerIdCAN)) {
                        leadWithReqsToComplete.add(ld.Id);
                    }
                    
                }
                //Caro Veliz: added the if(!ld.isconverted), to avoid error Too many SOQL queries.
                //This logic shouldn't be executed on Lead Conversion.
                //Ticket: https://unison-technology.atlassian.net/browse/BUS-155110270
                /*Use only this list if the code should be executed when is lead conversion*/
                if (!ld.isconverted)
                    leadids.add(ld.id);
                
                //check leads for MAX PCR change
                if (ld.Max_Credit_Score_PCR__c != oldMap.get(ld.Id).Max_Credit_Score_PCR__c) {
                    leadPCRRollupSet.add(ld.Id);
                }
                
                //add MRD atachments after lead status change
                if (ld.Quality_Control_Status__c != Null && ld.Quality_Control_Status__c == 'Passed'
                    && oldMap.get(ld.Id).Quality_Control_Status__c != 'Passed') {
                        mrdleadids.add(ld.Id);
                    }
                system.debug('****old status******' + oldMap.get(ld.Id).Status);
                system.debug('****new status******' + ld.Status);
                
                system.debug('****QC status******' + ld.Quality_Control_Status__c);
                system.debug('****Old QC status******' + oldMap.get(ld.Id).Quality_Control_Status__c);
                
                system.debug('****ld.IsConverted*****' + ld.IsConverted);
                system.debug('***oldMap.get(ld.Id).IsConverted******' + oldMap.get(ld.Id).IsConverted);
                
                //create child records of lead after leadconversion
                if (ld.IsConverted && !oldMap.get(ld.Id).IsConverted) {
                    system.debug('******converted lead*******');
                    convleadids.add(ld.Id);
                }
                
            }
            if(!leadWithApplicationReqs.isEmpty()) {
                createApplicationRequirement(leadWithApplicationReqs);
            }
            
            if(!leadWithReqsToComplete.isEmpty()) {
                completeApplicationReq(leadWithReqsToComplete);
            }
            
            if (mrdleadids.size() > 0) {
                LeadUtilityClass.addMRDAttachments(mrdleadids);
            }
            
            if (convleadids.size() > 0 && !LEAD_CONVUPDATE_FLAG) {
                system.debug('*******createchildforconvLead is called*********');
                LeadConversionProcess.createchildforconvLead(convleadids);
                LEAD_CONVUPDATE_FLAG = TRUE;
            }
            
            if (!leadPCRRollupSet.isEmpty()) {
                PCR_trigger_handler.rollupPCRToLead(leadPCRRollupSet);
            }
            
            if(leadids.size()>0) {
                List<Success_Factor__c> sflist = [
                        Select Id, Success_Factor__c, Lead__c, Lead__r.Status, Lead__r.Property_State__c, Lead__r.Box_Folder_Id__c, Lead__r.New_Construction_Dropdown__c, Lead__r.RecordType.Name,
                                Lead__r.Declaration_Power_of_Attorney__c, Lead__r.Is_there_Co_App__c, Lead__r.Retired__c, Lead__r.Self_Employed__c, Lead__r.Assets_Bank_Acct__c, Lead__r.Assets_Brokerage_Acct__c, Lead__r.Assets_Retirement_Acct__c,
                                Lead__r.Assets_Other__c
                        from Success_Factor__c
                        where Lead__c = :leadids
                ];


                for (Success_Factor__c sf : sflist) {
                    if (sf.Success_Factor__c == 'DTI' && sf.Lead__r.Status != oldMap.get(sf.Lead__c).Status) {
                        if ((sf.Lead__r.Status == 'Documents In' && sf.Lead__r.RecordType.Name == 'HomeOwner') || (sf.Lead__r.Status == 'Pending Submission' && sf.Lead__r.RecordType.Name == 'HomeBuyer')) {
                            sfappl.add(sf);
                            applleadids.add(sf.Lead__c);
                        }
                    }


                    if (sf.Success_Factor__c == 'Credit' && sf.Lead__r.Status != oldMap.get(sf.Lead__c).Status) {
                        if ((sf.Lead__r.Status == 'Documents In' && sf.Lead__r.RecordType.Name == 'HomeOwner') || (sf.Lead__r.Status == 'Pending Submission' && sf.Lead__r.RecordType.Name == 'HomeBuyer')) {
                            sfcredit.add(sf);
                            creditleadids.add(sf.Lead__c);
                        }
                    }


                }
            }

            if (sfappl.size() > 0 && !LEAD_QCSTATUUPDATE_FLAG) {
                //LeadUtilityClass.applicationCreation(applleadids,sfappl);
                LEAD_QCSTATUUPDATE_FLAG = TRUE;
            }
            
            // WITH THIS IMPLEMENTATION CREDIT REPORT REQS CAN BE DUPLICATED
            // SHOULD REFACTOR
            if (sfcredit.size() > 0 && !LEAD_STATUSUPDATE_FLAG) {
                LeadUtilityClass.creditCreation(creditleadids, sfcredit);
                LEAD_STATUSUPDATE_FLAG = TRUE;
            }
            
        }
        // Automation of MRD to Requirements creation
        Map<Id, Lead> leadMRDRequirementsMap = new Map<Id, Lead>();
        for (Lead updatedLead : newList) {
            if (oldMap.get(updatedLead.Id).Convert_MRDs__c != updatedLead.Convert_MRDs__c && updatedLead.Convert_MRDs__c) {
                leadMRDRequirementsMap.put(updatedLead.Id, updatedLead);
            }
        }
        if (!leadMRDRequirementsMap.isEmpty()) {
            MRDRequirementsCreationHandler.handleMRDRequirements(leadMRDRequirementsMap);
        }
        
        unconvertCopyLeads(newList, oldMap);
        
        DelightedIntegration(newList, oldMap);
        
        CalculateNumberOfReferredLeads(false, true, false, newList, oldMap.values());
        // Leads for Encompass processing - Moved from OpportunityTriggerHandler to LeadTriggerHandlerPC
        Map<Id, Lead> leadsEncompass = new Map<Id, Lead>();
        for(Lead lead : newList) {
            if(oldMap.get(lead.Id).Quality_Control_Status__c != lead.Quality_Control_Status__c && lead.Quality_Control_Status__c == 'Passed') {
                leadsEncompass.put(lead.Id, lead);
            }
        }
        if(!leadsEncompass.isEmpty()) {
            System.enqueueJob(new BoxAttachmentRetrievalQueueable(leadsEncompass));
        }
        TriggrUtility.RunOnce=false;
        TuneIntegration(newList, oldMap);
    }
    
    
    public static void handleAfterDelete(List<Lead> oldList) {
        CalculateNumberOfReferredLeads(false, false, true, null, oldList);
    }
    
    private static void SetQualifiesforNewHOPricing(List<Lead> newList) {
        for (Lead lead : newList) {
            lead.Qualifies_for_New_HomeOwner_Pricing__c = false;
            if (lead.New_HomeOwner_Purchase_Date__c != null && lead.NHO_Expected_Close_Date__c != null) {
                if (Math.abs(lead.New_HomeOwner_Purchase_Date__c.DaysBetween(lead.NHO_Expected_Close_Date__c)) < 365) {
                    lead.Qualifies_for_New_HomeOwner_Pricing__c = true;
                }
            }
        }
    }
    
    @TestVisible
    private static Set<Id> tunedIds = new Set<Id>();
    private static void TuneIntegration(List<Lead> newList, Map<Id, Lead> oldMap) {
        
        Id ownerRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        Id buyerRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
        
        Map<Id, String> tuneMap = new Map<Id, String>();
        
        for (Lead newLead : newList) {
            if (oldMap == null) { // Insert
                if (!String.isBlank(newLead.Tune_Transaction_Id__c) && !String.isBlank(newLead.Tune_Offer_Id__c)) {
                    if (!tunedIds.contains(newLead.Id)) {
                        if (newLead.RecordTypeId == ownerRTId || newLead.RecordTypeId == buyerRTId) {
                            tuneMap.put(newLead.Id, '1');
                            tunedIds.add(newLead.Id);
                        }
                    }
                }
            } else { // Update
                Lead oldLead = oldMap.get(newLead.Id);
                if (!String.isBlank(newLead.Tune_Transaction_Id__c) && !String.isBlank(newLead.Tune_Offer_Id__c)) {
                    if (!tunedIds.contains(newLead.Id)) {
                        if (newLead.RecordTypeId == buyerRTId || newLead.RecordTypeId == ownerRTId) {
                            boolean isEligible = newLead.Credit_Pre_Qualification_Status__c == 'Approved' || 
                                newLead.Credit_Pre_Qualification_Status__c == 'Approved (single score)';
                            isEligible = isEligible && newLead.Property_Pre_Qualification_Status__c == 'Approved';
                            isEligible = isEligible && (newLead.Property_Pre_Qualification_Status__c != oldLead.Property_Pre_Qualification_Status__c || 
                                                        newLead.Credit_Pre_Qualification_Status__c != oldLead.Credit_Pre_Qualification_Status__c);
                            if (isEligible) {
                                tuneMap.put(newLead.Id, '2');
                                tunedIds.add(newLead.Id);
                            }
                        }
                        if (newLead.RecordTypeId == buyerRTId || newLead.RecordTypeId == ownerRTId) {
                            if (newLead.Status != oldLead.Status && newLead.Status == 'Submitted') {
                                tuneMap.put(newLead.Id, '3');
                                tunedIds.add(newLead.Id);
                            }
                        }
                    }
                }
            }
        }
        
        if (tuneMap.size() > 0) {
            TuneIntegration.SendLeadsToTune(tuneMap);
        }
    }

    private static void TuneIdsCheck(List<Lead> newList, Map<Id, Lead> oldMap) {

        for (Lead newLead : newList) {
            Lead oldLead = oldMap.get(newLead.Id);
            boolean somethingChanged = false;
            somethingChanged = somethingChanged || (newLead.Tune_Offer_Id__c != oldLead.Tune_Offer_Id__c && oldLead.Tune_Offer_Id__c != null);
            somethingChanged = somethingChanged || (newLead.Tune_Transaction_Id__c != oldLead.Tune_Transaction_Id__c && oldLead.Tune_Transaction_Id__c != null);
            if (somethingChanged) {
                newLead.addError(Label.Tune_Ids_Changed_Error);
            }
        }
    }
    
    private static void createApplicationRequirement(Set<Id> leadWithApplicationReqs) {
        system.debug('++ ENTER createApplicationRequirement');
        // Create Application Requirement if there aren't any created
        List<Current_Conditions__c> reqsToInsert = new List<Current_Conditions__c>();
        Map<Id, List<Current_Conditions__c>> leadReqsMap = new Map<Id, List<Current_Conditions__c>>();
        for(Current_Conditions__c req : [SELECT Id, Requirement__c, Status__c, Lead__c
                                         FROM Current_Conditions__c WHERE Lead__c IN : leadWithApplicationReqs AND Requirement__c = 'Application']) {
                                             if(leadReqsMap.containsKey(req.Lead__c)) {
                                                 List<Current_Conditions__c> reqs = leadReqsMap.get(req.Lead__c);
                                                 reqs.add(req);
                                                 leadReqsMap.put(req.Lead__c, reqs);
                                             } else {
                                                 leadReqsMap.put(req.Lead__c, new List<Current_Conditions__c> { req });
                                             }
                                         }
        system.debug('++ leadReqsMap? ' + leadReqsMap);
        for(Id leadId : leadWithApplicationReqs) {
            system.debug('++ leadId ? ' + leadReqsMap.get(leadId));
            if(!leadReqsMap.containsKey(leadId)) {
                reqsToInsert.add(new Current_Conditions__c(Lead__c = leadId, Code__c = 'R1120'));
            }
        }
        
        if(!reqsToInsert.isEmpty()) {
            insert reqsToInsert;
        }
    }
    
    private static void completeApplicationReq(Set<Id> leadWithReqsToComplete) {
        List<Current_Conditions__c> reqsToComplete = new List<Current_Conditions__c>();
        for(Current_Conditions__c req : [SELECT Id, Status__c, Lead__c, Code__c FROM Current_Conditions__c
                                         WHERE Lead__c IN : leadWithReqsToComplete AND Code__c = 'R1120']) {
                                             req.Status__c = 'Completed';
                                             reqsToComplete.add(req);
                                         }
        if(!reqsToComplete.isEmpty()) {
            update reqsToComplete;
        }
    }
    
    private static void DelightedIntegration(List<Lead> newList, Map<Id, Lead> oldMap) {
        
        List<Delighted_API_Key__mdt> delightedApiSettings = [Select Id, DeveloperName, Active_in_Trigger__c  from Delighted_API_Key__mdt];
        Map<String, Boolean> delightedApiSettingsMap = new Map<String, Boolean>();
        
        for(Delighted_API_Key__mdt apiKey: delightedApiSettings){
            delightedApiSettingsMap.put(apiKey.DeveloperName, apiKey.Active_in_Trigger__c);
        }
        
        if (!System.isFuture() && !System.isBatch()) {
            List<Id> lIds = new List<Id>();
            for (Lead newLead: newList) {
                if(!alreadyCreatedNPMLeadIDSet.contains(newLead.Id) && !newLead.Delighted_Survey_Sent__c && !newLead.Marketing_Opt_Out__c){
                    if(delightedApiSettingsMap.get('Standard')){
                        if(newLead.Delighted_Send_Status__c && oldMap.get(newLead.Id).Delighted_Send_Status__c != newLead.Delighted_Send_Status__c && newLead.Loss_Reason_Type__c != 'First contact - Asked to be removed') {
                            lIds.add(newlead.Id);
                            alreadyCreatedNPMLeadIDSet.add(newLead.Id);
                        }    
                    }
                    if(delightedApiSettingsMap.get('Project')){
                        if( ( newLead.Status == 'Closed Lost' && newLead.Loss_Type__c == 'No Sale' ) && ( oldMap.get(newLead.Id).Status != newLead.Status || oldMap.get(newLead.Id).Loss_Type__c != newLead.Loss_Type__c ) && newLead.Loss_Reason_Type__c != 'First contact - Asked to be removed') {
                            lIds.add(newlead.Id);
                            alreadyCreatedNPMLeadIDSet.add(newLead.Id);
                        }
                    }
                }
            }

            List<Net_Promoter_Measurement__c> toInsert = new List<Net_Promoter_Measurement__c>();
            for (integer i = 0; i < 50 && i < lIds.size(); i++) {
                Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
                npm.Status__c = 'Draft';
                npm.Lead__c = lIds[i];
                toInsert.add(npm);
            }
            if (toInsert.size() > 0)
                insert toInsert;
        }
    }
    
    /* public static void rewritePhoneOnLead (List<Lead> newList)
{ 
for(Lead objLead : newList)
{
if(objLead.Phone != null)
{
objLead.Phone = phoneNumberTransform.standardize(objLead.Phone);
}
}
}
*/
    
    /**
*  About
*  -----
*  Author: Omnivo Digital
*
*  Details: Method to process converted Leads.
*  Attaches Lead child records to converted Account
*  -----
*
**/
    
    private static void unconvertCopyLeads(List<Lead> newList, Map<Id, Lead> oldMap) {
        
        Set<Id> eligibleLeadIds = new Set<Id>();
        
        // Gather the related record ids
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        for (Lead newLead : newList) {
            Lead oldLead = oldMap.get(newLead.Id);
            system.debug('******newLead.Unconverted_Lead__c*******'+newLead.Unconverted_Lead__c);
            system.debug('*******newLead.Trigger_Unconvert_Copy__c******'+newLead.Trigger_Unconvert_Copy__c);
            system.debug('******oldLead.Trigger_Unconvert_Copy__c*******'+oldLead.Trigger_Unconvert_Copy__c);
            if (newLead.Unconverted_Lead__c == true && newLead.Trigger_Unconvert_Copy__c == true && oldLead.Trigger_Unconvert_Copy__c == false) {
                eligibleLeadIds.add(newLead.Id);
                if (newLead.Converted_Account__c != null) {
                    accountIds.add(newLead.Converted_Account__c);
                }
                if (newLead.Converted_Contact__c != null) {
                    contactIds.add(newLead.Converted_Contact__c);
                }
                if (newLead.Converted_Opportunity__c != null) {
                    opportunityIds.add(newLead.Converted_Opportunity__c);
                }
                if (newLead.Original_Lead__c != null) {
                    leadIds.add(newLead.Original_Lead__c);
                }
            }
        }
        
        if (eligibleLeadIds.size() > 0) {
            
            Map<String, String> statusMap = new Map<String, String>();
            //Sundar Subramaniam 03/27/2019 - change in the criteria with respect to HB Lead Status Update Project - CM-50
            
            statusMap.put('Running Credit', 'Application Received');
            statusMap.put('Pre-Qualifying Application', 'Application Received');
            statusMap.put('Requires Exception', 'Application Received');
            statusMap.put('On Hold', 'Application Received');
            statusMap.put('Application Pre-Qualified', 'Application Received');
            statusMap.put('Property in Contract', 'Application Received');
            
            // Build the queries to extract the data
            string accountQuery = 'SELECT Id';
            string contactQuery = 'SELECT Id';
            string opportunityQuery = 'SELECT Id';
            string leadQuery = 'SELECT Id';
            Set<String> selectedFields = new Set<String>();
            Map<String, Lead_Unconvert_Field_Mapping__c> mappings = Lead_Unconvert_Field_Mapping__c.getAll();
            for (Lead_Unconvert_Field_Mapping__c mapping : mappings.values()) {
                if (mapping.Active__c == true) {
                    string key = mapping.Object__c + '~' + mapping.Field__c;
                    if (!selectedFields.contains(key)) {
                        if (mapping.Object__c == 'Account') {
                            accountQuery += ', ' + mapping.Field__c;
                        }
                        if (mapping.Object__c == 'Contact') {
                            contactQuery += ', ' + mapping.Field__c;
                        }
                        if (mapping.Object__c == 'Opportunity') {
                            opportunityQuery += ', ' + mapping.Field__c;
                        }
                        if (mapping.Object__c == 'Lead') {
                            leadQuery += ', ' + mapping.Field__c;
                        }
                        selectedFields.add(key);
                    }
                }
            }
            if (!opportunityQuery.contains('StageName')) {
                opportunityQuery += ', StageName';
            }
            accountQuery += ', (SELECT Id FROM Events), (SELECT Id FROM Tasks), (SELECT Id, Body, IsPrivate, Title FROM Notes) FROM Account WHERE Id IN :accountIds';
            contactQuery += ' FROM Contact WHERE Id IN :contactIds';
            opportunityQuery += ', (SELECT Id FROM Opportunity_Cases__r), (SELECT Id FROM R00N80000002fD9vEAE__r), (SELECT Id, Body, IsPrivate, Title FROM Notes), ' +
                '(SELECT Id FROM Personal_Credit_Reports__r), (SELECT Id FROM Events), (SELECT Id FROM Tasks) FROM Opportunity WHERE Id IN :opportunityIds';
            leadQuery += ' FROM Lead WHERE Id IN :leadIds';
            
            System.debug(accountQuery);
            System.debug(contactQuery);
            System.debug(opportunityQuery);
            System.debug(leadQuery);
            
            // Extract necessary data
            Map<Id, Account> accountMap = new Map<Id, Account>((List<Account>)database.query(accountQuery));
            Map<Id, Contact> contactMap = new Map<Id, Contact>((List<Contact>)database.query(contactQuery));
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>((List<Opportunity>)database.query(opportunityQuery));
            Map<Id, Lead> leadMap = new Map<Id, Lead>((List<Lead>)database.query(leadQuery));
            
            Map<Id, List<Attachment>> attachmentMap = new Map<Id, List<Attachment>>();
            for (Attachment att : [SELECT Id, Body, ContentType, Description, IsPrivate, Name, OwnerId, ParentId FROM Attachment WHERE ParentId IN :accountMap.keySet() OR ParentId IN :opportunityMap.keySet()]) {
                if (!attachmentMap.containsKey(att.ParentId)) {
                    attachmentMap.put(att.ParentId, new List<Attachment>());
                }
                attachmentMap.get(att.ParentId).add(att);
            }
            
            List<Lead> eligibleLeads = [SELECT Id, Converted_Account__c, Converted_Contact__c, Converted_Opportunity__c, Original_Lead__c
                                        FROM Lead WHERE Id IN :eligibleLeadIds];
            List<Case> casesToUpdate = new List<Case>();
            List<dsfs__DocuSign_Status__c> docusignToUpdate = new List<dsfs__DocuSign_Status__c>();
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            List<LASERCA__Personal_Credit_Report__c> creditReportsToUpdate = new List<LASERCA__Personal_Credit_Report__c>();
            Map<Id, Event> eventsToUpdate = new Map<Id, Event>();
            Map<Id, Task> tasksToUpdate = new Map<Id, Task>();
            List<Note> notesToInsert = new List<Note>();
            
            // Start the copy process
            for (Lead eligibleLead : eligibleLeads) {
                // Find related records
                Account acc = null;
                if (eligibleLead.Converted_Account__c != null) {
                    acc = accountMap.get(eligibleLead.Converted_Account__c);
                }
                Contact cnt = null;
                if (eligibleLead.Converted_Contact__c != null) {
                    cnt = contactMap.get(eligibleLead.Converted_Contact__c);
                }
                Opportunity opp = null;
                if (eligibleLead.Converted_Opportunity__c != null) {
                    opp = opportunityMap.get(eligibleLead.Converted_Opportunity__c);
                }
                Lead lead = null;
                if (eligibleLead.Original_Lead__c != null) {
                    lead = leadMap.get(eligibleLead.Original_Lead__c);
                }
                
                // Copy fields
                for (Lead_Unconvert_Field_Mapping__c mapping : mappings.values()) {
                    if (mapping.Active__c == true) {
                        sObject refObj = null;
                        if (mapping.Object__c == 'Account' && acc != null) {
                            refObj = acc;
                        }
                        if (mapping.Object__c == 'Contact' && cnt != null) {
                            refObj = acc;
                        }
                        if (mapping.Object__c == 'Opportunity' && opp != null) {
                            refObj = opp;
                        }
                        if (mapping.Object__c == 'Lead' && lead != null) {
                            refObj = lead;
                        }
                        if (refObj != null) {
                            if (mapping.Field__c.contains('.')) {
                                System.debug(mapping.Field__c);
                                System.debug(mapping.Field__c.split('\\.'));
                                try {
                                    string relation = mapping.Field__c.split('\\.')[0];
                                    string ultField = mapping.Field__c.split('\\.')[1];
                                    eligibleLead.put(mapping.Lead_Field__c, refObj.getsObject(relation).get(ultField));
                                } catch (Exception ex) {}
                            } else {
                                try {
                                    eligibleLead.put(mapping.Lead_Field__c, refObj.get(mapping.Field__c));
                                } catch (Exception ex) {}
                            }
                        }
                    }
                }
                
                // Set Lead status
                if (opp != null) {
                    if (statusMap.containsKey(opp.StageName)) {
                        eligibleLead.Status = statusMap.get(opp.StageName);
                    }
                }
                
                // Link Opportunity Cases
                if (opp != null) {
                    for (Case c : opp.Opportunity_Cases__r) {
                        c.Lead__c = eligibleLead.Id;
                        casesToUpdate.add(c);
                    }
                }
                
                // Link Opportunity DocuSign Status
                if (opp != null) {
                    for (dsfs__DocuSign_Status__c ds : opp.R00N80000002fD9vEAE__r) {
                        ds.dsfs__Lead__c = eligibleLead.Id;
                        docusignToUpdate.add(ds);
                    }
                }
                
                // Link Attachments
                if (opp != null) {
                    if (attachmentMap.containsKey(opp.Id)) {
                        for (Attachment att : attachmentMap.get(opp.Id)) {
                            Attachment newAtt = new Attachment();
                            newAtt.ParentId = eligibleLead.Id;
                            newAtt.Body = att.Body;
                            newAtt.ContentType = att.ContentType;
                            newAtt.Description = att.Description;
                            newAtt.IsPrivate = att.IsPrivate;
                            newAtt.Name = att.Name;
                            newAtt.OwnerId = att.OwnerId;
                            attachmentsToInsert.add(newAtt);
                        }
                    }
                }
                if (acc != null) {
                    if (attachmentMap.containsKey(acc.Id)) {
                        for (Attachment att : attachmentMap.get(acc.Id)) {
                            Attachment newAtt = new Attachment();
                            newAtt.ParentId = eligibleLead.Id;
                            newAtt.Body = att.Body;
                            newAtt.ContentType = att.ContentType;
                            newAtt.Description = att.Description;
                            newAtt.IsPrivate = att.IsPrivate;
                            newAtt.Name = att.Name;
                            newAtt.OwnerId = att.OwnerId;
                            attachmentsToInsert.add(newAtt);
                        }
                    }
                }
                
                // Link Personal Credit Report
                if (opp != null) {
                    for (LASERCA__Personal_Credit_Report__c pcr : opp.Personal_Credit_Reports__r) {
                        pcr.LASERCA__Lead__c = eligibleLead.Id;
                        creditReportsToUpdate.add(pcr);
                    }
                }
                
                // Link Notes
                if (opp != null) {
                    for (Note nt : opp.Notes) {
                        Note nt2 = new Note();
                        nt2.Body = nt.Body;
                        nt2.IsPrivate = nt.IsPrivate;
                        nt2.Title = nt.Title;
                        nt2.ParentId = eligibleLead.Id;
                        notesToInsert.add(nt2);
                    }
                }
                if (acc != null) {
                    for (Note nt : acc.Notes) {
                        Note nt2 = new Note();
                        nt2.Body = nt.Body;
                        nt2.IsPrivate = nt.IsPrivate;
                        nt2.Title = nt.Title;
                        nt2.ParentId = eligibleLead.Id;
                        notesToInsert.add(nt2);
                    }
                }
                
                // Link Activities
                if (opp != null) {
                    for (Event evt : opp.Events) {
                        evt.WhoId = eligibleLead.Id;
                        evt.WhatId = null;
                        eventsToUpdate.put(evt.Id, evt);
                    }
                    for (Task tsk : opp.Tasks) {
                        tsk.WhoId = eligibleLead.Id;
                        tsk.WhatId = null;
                        tasksToUpdate.put(tsk.Id, tsk);
                    }
                }
                if (acc != null) {
                    for (Event evt : acc.Events) {
                        evt.WhoId = eligibleLead.Id;
                        evt.WhatId = null;
                        eventsToUpdate.put(evt.Id, evt);
                    }
                    for (Task tsk : acc.Tasks) {
                        tsk.WhoId = eligibleLead.Id;
                        tsk.WhatId = null;
                        tasksToUpdate.put(tsk.Id, tsk);
                    }
                }
            }
            update eligibleLeads;
            update casesToUpdate;
            update docusignToUpdate;
            insert attachmentsToInsert;
            update creditReportsToUpdate;
            delete [SELECT Id FROM EventRelation WHERE EventId IN :eventsToUpdate.keyset()];
            update eventsToUpdate.values();
            delete [SELECT Id FROM TaskRelation WHERE TaskId IN :tasksToUpdate.keyset()];
            update tasksToUpdate.values();
            insert notesToInsert;
        }
        
    }
    
    /**
*  About
*  -----
*  Author: Omnivo Digital
*
*  Details: Method to perform Opp updates after conversion from lead
*      -populate Opportunity Contact Loolups
*      -set Record Type
*  -----
*  Changes:
*      -5/1/2018 --- commented blocks of code to populate Opportunity lookups
**/
    
    public static void updateConvertedOpportunities(Set<Id> oppIdSet){
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity o: [SELECT AccountId FROM Opportunity WHERE ID in:oppIdSet]){
            accountIdSet.add(o.accountId);
        }
        
        //get the Contact map with opp lookup helpers
        Map<Id, contactLookupHelperClass> acctContactHelperMap = new Map<Id, contactLookupHelperClass>();
        for(Account a: [SELECT Id, (SELECT AccountId, Opp_Lookup_Helper__c FROM Contacts) FROM Account WHERE Id IN:accountIdSet]){
            Map<String, Contact> contactLookupHelperMap = new Map<String, Contact>();
            for(Contact c: a.Contacts){
                contactLookupHelperMap.put(c.Opp_Lookup_Helper__c, c);
            }
            contactLookupHelperClass clhpc = new contactLookupHelperClass(contactLookupHelperMap);
            acctContactHelperMap.put(a.Id, clhpc);
        }
        
        //Get Opp RT Map
        Schema.DescribeSObjectResult oppDesc = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRTMapByName = oppDesc.getRecordTypeInfosByName();
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        //Now go through Opportunities and assign lookups and populate RT
        for(Opportunity o: [SELECT Converted_Lead_RT__c, RecordTypeId, AccountId,Applicant__c, Co_Applicant__c, Applicant2__c, Co_Applicant2__c FROM Opportunity WHERE Id IN: oppIdSet ]){
            if(oppRTMapByName.get(o.Converted_Lead_RT__c) != NULL){
                o.RecordTypeId = oppRTMapByName.get(o.Converted_Lead_RT__c).getRecordTypeId();
            }
            if(acctContactHelperMap.get(o.AccountId) != NULL && acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('applicant1') != NULL){
                o.Applicant__c = acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('applicant1').Id;
            }
            if(acctContactHelperMap.get(o.AccountId) != NULL && acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('coapplicant1') != NULL){
                o.Co_Applicant__c = acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('coapplicant1').Id;
            }
            if(acctContactHelperMap.get(o.AccountId) != NULL && acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('applicant2') != NULL){
                o.Applicant2__c = acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('applicant2').Id;
            }
            if(acctContactHelperMap.get(o.AccountId) != NULL && acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('coapplicant2') != NULL){
                o.Co_Applicant2__c = acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('coapplicant2').Id;
            }
            if(acctContactHelperMap.get(o.AccountId) != NULL && acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('applicant3') != NULL){
                o.Applicant3__c = acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('applicant3').Id;
            }
            if(acctContactHelperMap.get(o.AccountId) != NULL && acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('coapplicant3') != NULL){
                o.Co_Applicant3__c = acctContactHelperMap.get(o.AccountId).contactLookupHelperMap.get('coapplicant3').Id;
            }
            oppsToUpdate.add(o);
        }
        
        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
        
    }
    
    /**
*  About
*  -----
*  Author: Omnivo Digital
*
*  Details: Helper Class for structuring Account->Contact maps with lookup helpers
*  -----
**/
    
    private Class contactLookupHelperClass{
        public Map<string, Contact> contactLookupHelperMap {get;set;}
        
        public contactLookupHelperClass(Map<string, Contact> contactMap){
            this.contactLookupHelperMap = contactMap;
        }
    }
    
    
    /**
*  About
*  -----
*  Author: Omnivo Digital
*
*  Details: Method to populate Lead attribution fields based on referring Loan Officer
*  -----
*
**/
    private static void assignLoanOfficerReferralFields(List<Lead> leadsToUpdate, Set<Id> setLoanOfficerContactIds){
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        //populate Contact Map
        for(Contact c :[SELECT Id,AccountId,Account.Name,Sales_Director__c, RecordType.Name FROM Contact WHERE Id IN: setLoanOfficerContactIds]){
            contactMap.put(c.Id,c);
        }
        
        //update lead records
        If(!contactMap.isEmpty()){
            for(Lead l: leadsToUpdate){
                if(contactMap.keySet().contains(l.Referring_Contact__c )){
                    l.Referring_Account__c = contactMap.get(l.Referring_Contact__c).AccountId;
                    l.LeadSource = contactMap.get(l.Referring_Contact__c).RecordType.Name;
                    l.Campaign_Name__c = contactMap.get(l.Referring_Contact__c).Account.Name;
                    l.Sales_Director_User__c = contactMap.get(l.Referring_Contact__c).Sales_Director__c;
                    l.Branding_Type__c = 'Co-Branded';
                    //If Contact RT is Lender, populate referring contact as loan officer also
                    if(contactMap.get(l.Referring_Contact__c).RecordType.Name == 'Lender'){
                        l.Loan_Officer__c = l.Referring_Contact__c;
                    }
                }
            }
        }
    }
    
    /**
*  About
*  -----
*  Author: Omnivo Digital
*  Date: 2019-03-11
*  Details: Method to populate Lead referring Contact based on Real Estate Agent fields
*  -----
*
**/
    @TestVisible private static void handleRealEstateAgentReferrals_before(List<Lead> leadsToUpdate){
        set<string> emailSet = new Set<string>();
        for(Lead l: leadsToUpdate){
            emailSet.add(l.Real_Estate_Agent_Email__c);
        }
        REAgentEmailMap = getREAgentEmailMap(emailSet);
        Map<string, Contact> newREAgentsToInsert = new Map<string, Contact>();
        for(Lead l: leadsToUpdate){
            if(REAgentEmailMap.get(l.Real_Estate_Agent_Email__c) == NULL){
                Contact newREAgent = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(REAL_ESTATE_BROKER_LABEL).getRecordTypeId());
                if(!test.isRunningTest()) newREAgent.AccountId = LABEL.AREAA_Account_Record_Id;
                newREAgent.LastName = l.Real_Estate_Agent_Free_Response__c;
                newREAgent.FirstName = l.Real_Estate_Agent_First_Name__c;
                newREAgent.Email = l.Real_Estate_Agent_Email__c;
                newREAgent.title = 'Agent';
                newREAgent.Contact_Role__c = 'Agent';
                newREAgentsToInsert.put(newREAgent.Email, newREAgent);
            }
        }
        if(!newREAgentsToInsert.isEmpty()){
            insert newREAgentsToInsert.values();
            REAgentEmailMap.putAll(newREAgentsToInsert);
        }
        system.debug('REAgentEmailMap---' + REAgentEmailMap);
        for(Lead l: leadsToUpdate){
            l.Referring_Contact__c = REAgentEmailMap.get(l.Real_Estate_Agent_Email__c).Id;
        }
        
    }
    
    
    /**
*  About
*  -----
*  Author: Omnivo Digital
*
*  Details: Method to populate Lead attribution fields based on Campaign Source and custom setting
*  -----
*
**/
    private static void setCampaignSourceAttribution(Lead newLead){
        
        if( newLead.Campaign_Source__c != NULL && newLead.Campaign_Source__c.length() < 38 && Digital_Campaign_Sources__c.getInstance(newLead.Campaign_Source__c) != NULL ){
            //Presets from custom setting
            newLead.Campaign_Audience__c = Digital_Campaign_Sources__c.getInstance(newLead.Campaign_Source__c).Campaign_Audience__c;
            newLead.Campaign_Media_Type__c = Digital_Campaign_Sources__c.getInstance(newLead.Campaign_Source__c).Campaign_Media_Type__c;
            newLead.Outbound_Marketing_Channel__c = Digital_Campaign_Sources__c.getInstance(newLead.Campaign_Source__c).Outbound_Marketing_Channel__c;
            
            //Exceptions and Overrides logic
            //Social OB Marketing channel
            if(newLead.Campaign_Source__c == 'facebook' || newLead.Campaign_Source__c == 'twitter' || newLead.Campaign_Source__c == 'instagram' || newLead.Campaign_Source__c == 'linkedin'){
                newLead.Outbound_Marketing_Channel__c = 'Social';
            }
            //Paid Search OB marketing channel
            else if(newLead.Campaign_Medium__c == 'search' || newLead.Campaign_Medium__c == 'cpc'){
                newLead.Outbound_Marketing_Channel__c = 'Paid Search';
            }
            //Display OB marketing channel
            else if(newLead.Campaign_Medium__c == 'placement' || newLead.Campaign_Medium__c == 'contextual' || newLead.Campaign_Medium__c == 'display'){
                newLead.Outbound_Marketing_Channel__c = 'Display';
            }
            //catchall if Outbound Marketing Channel is still blank
            else if(newLead.Outbound_Marketing_Channel__c == NULL){
                //Set Default Outbound Marketing Channel value to Web
                newLead.Outbound_Marketing_Channel__c = 'Web';
            }
        }
        else{ //Not found in Digital Campaign Sources custom setting
            newLead.Outbound_Marketing_Channel__c = 'Web';
            newLead.LeadSource = 'Unattributed';
        }
    }
    
    /**
*  About
*  -----
*  Author: Omnivo Digital
*
*  Details: Before trigger helper Method to populate Lead attribution fields
*              based on a Personalized Referral Code in the Campaign Content field
*  -----
*
**/
    
    private static void personalReferralCodeAttribution(Lead newLead){
        newLead.Branding_Type__c = 'Co-Branded';
        newLead.Campaign_Media_Type__c = 'Physical Media';
        newLead.Campaign_Source__c = getPersonalCodeContactMap().get(newLead.Campaign_Content__c).Account.Name;
        newLead.Campaign_Name__c = getPersonalCodeContactMap().get(newLead.Campaign_Content__c).Name;
        newLead.Referring_Contact__c = getPersonalCodeContactMap().get(newLead.Campaign_Content__c).Id;
        if(contactRTByIdMap.get(getPersonalCodeContactMap().get(newLead.Campaign_Content__c).RecordTypeId).getName() == REAL_ESTATE_BROKER_LABEL){
            newLead.Real_Estate_Agent__c = getPersonalCodeContactMap().get(newLead.Campaign_Content__c).Id;
            newLead.LeadSource = 'Real Estate Broker';
        }
        else if(contactRTByIdMap.get(getPersonalCodeContactMap().get(newLead.Campaign_Content__c).RecordTypeId).getName() == LENDER_LABEL){
            newLead.LeadSource = 'Lender';
            newLead.Loan_Officer__c = getPersonalCodeContactMap().get(newLead.Campaign_Content__c).Id;
        }
    }
    
    
    /**
*  About
*  -----
*  Author: Cloud Nerd
*
*  Details
*  -----
*  -----Deprecated by Omnivo Digital 7/11/17
**/
    /*
private static void checkExistingContactOrLeads(List<String> leadEmails, Map<Id, Lead> leadsToCheck){

Map<String, Contact> emailToContactMap = new Map<String, Contact>();
Map<String, Lead> emailToLeadMap = new Map<String, Lead>();

List<Contact> coApplicantsToCreate = new List<Contact>();
List<Lead> leadsToUpdate = new List<Lead>();
List<Lead> leadsToDelete = new List<Lead>();

List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();

List<Opportunity> opportunitiesToInsert = new List<Opportunity>();

Set<String> leadCreateableFields = new Set<String>();

LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];

Map<String, Schema.SObjectField> leadFieldsMap = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
for (Schema.SObjectField leadField : leadFieldsMap.values()){
Schema.DescribeFieldResult fieldResult = leadField.getDescribe();
if(fieldResult.isUpdateable()){
leadCreateableFields.add(fieldResult.getName());
}
}

List<Contact> contacts = [SELECT Id, Email, AccountId
FROM Contact
WHERE Email IN : leadEmails
AND AccountId != null];

for (Contact contactRec : contacts){
emailToContactMap.put(contactRec.Email, contactRec);
}

System.debug(leadEmails);

List<Lead> leads = [SELECT Id, Email
FROM Lead
WHERE Email in :leadEmails
AND Id NOT IN :leadsToCheck.keyset()
AND IsConverted = false];

for (Lead leadRec : leads){
emailToLeadMap.put(leadRec.Email, leadRec);
}

for (Id leadId : leadsToCheck.keyset()){
Lead leadRec = leadsToCheck.get(leadId);
if (emailToContactMap.containsKey(leadRec.Email)){

Contact associatedContact = emailToContactMap.get(leadRec.Email);

String opportunityName = '';
if (String.isNotBlank(leadRec.FirstName)){
opportunityName += leadRec.FirstName + ' ';
}
if (String.isNotBlank(leadRec.LastName)){
opportunityName += leadRec.LastName;
}

Database.LeadConvert lc = new Database.LeadConvert();
lc.setLeadId(leadRec.id);
lc.setAccountId(associatedContact.AccountId);
lc.setContactId(associatedContact.Id);
lc.setConvertedStatus(convertStatus.MasterLabel);
if (String.isNotBlank(opportunityName)){
lc.setOpportunityName(opportunityName);
}
leadsToConvert.add(lc);

} else if (emailToLeadMap.containsKey(leadRec.Email)){
//MERGE DATA WITH OLD LEAD
Lead oldLead = new Lead(Id = emailToLeadMap.get(leadRec.Email).Id);
for (String fieldName : leadCreateableFields){
try{
oldLead.put(fieldName, leadRec.get(fieldName));
}catch(Exception e){
System.debug('Error writing to field '+ fieldName + '. Error Message : ' + e.getMessage());
}
}
leadsToUpdate.add(oldLead);

//DELETE NEW LEAD
Lead leadToDelete = new Lead(Id = leadId);
leadsToDelete.add(leadToDelete);
} else {
String opportunityName = '';
if (String.isNotBlank(leadRec.FirstName)){
opportunityName += leadRec.FirstName + ' ';
}
if (String.isNotBlank(leadRec.LastName)){
opportunityName += leadRec.LastName;
}

Database.LeadConvert lc = new Database.LeadConvert();
lc.setLeadId(leadRec.id);
lc.setConvertedStatus(convertStatus.MasterLabel);
if (String.isNotBlank(opportunityName)){
lc.setOpportunityName(opportunityName);
}
leadsToConvert.add(lc);
}
}

if (!leadsToUpdate.isEmpty()){
update leadsToUpdate;
}
if (!leadsToDelete.isEmpty()){
delete leadsToDelete;
}

for (Lead leadRec : leadsToUpdate){
String opportunityName = '';
Database.LeadConvert lc = new Database.LeadConvert();
lc.setLeadId(leadRec.id);
lc.setConvertedStatus(convertStatus.MasterLabel);

if (String.isNotBlank(leadRec.FirstName)){
opportunityName += leadRec.FirstName + ' ';
}
if (String.isNotBlank(leadRec.LastName)){
opportunityName += leadRec.LastName;
}

if (String.isNotBlank(opportunityName)){
lc.setOpportunityName(opportunityName);
}

leadsToConvert.add(lc);
}

if (!leadsToConvert.isEmpty()){

Map<id, id> oppContactIdMap = new Map<id,Id> (); //map to store created opportunity and contact for contact role
Map<Id, Id> contactIdToAccountIdMap = new Map<Id, Id>();
Map<Id, Id> accountIdToOpportunityId = new Map<Id, Id>();

Set<Id> coApplicantContactIds = new Set<Id>();
Set<Id> convertedLeadIds = new Set<Id>();


List<Database.LeadConvertResult> convertResults = Database.convertLead(leadsToConvert, false);
for (Database.LeadConvertResult convertResult : convertResults){
if (!convertResult.isSuccess()){
System.debug(convertResult.getErrors().get(0).getMessage());
}else if(convertResult.isSuccess()){
oppContactIdMap.put(convertResult.OpportunityId, convertResult.ContactId);
contactIdToAccountIdMap.put(convertResult.ContactId, convertResult.AccountId);
convertedLeadIds.add(convertResult.LeadId);
accountIdToOpportunityId.put(convertResult.AccountId, convertResult.OpportunityId);
}
}
//Map of opportunity and contact - update contact created with contact roles
if(!oppContactIdMap.isEmpty()){
//Create Co-Applicant if needed
List<Lead> convertedLeadsInfo = [SELECT Id,
Name,
ConvertedAccountId,
Co_Applicant_Address__c,
Co_Applicant_BirthDate__c,
Co_Applicant_City__c,
Co_Applicant_Email__c,
Co_Applicant_First_Name__c,
Co_Applicant_Last_Name__c,
Co_Applicant_Phone__c,
Co_Applicant_Postal_Code__c,
Co_Applicant_Social_Security_Number__c,
Co_Applicant_State__c,
Bankrupcy_in_last_seven_years_co__c,
Employer_Name_co__c,
Estimated_Total_Monthly_Income_co__c,
Felonies_co__c,
Given_deed_for_foreclosure_in_7_years_co__c,
Highest_Degree_Earned_co__c,
Industry_co__c,
Marital_Status_co__c,
Occupation_co__c,
Previous_Foreclosure_co__c,
Reason_for_Background_History_co__c,
School_co__c,
Self_Employed_co__c,
Title_co__c,
Years_In_This_Profession_co__c,
Years_of_School_co__c,
Years_on_This_Job_co__c
FROM Lead
WHERE Id in :convertedLeadIds];

for (Lead convertedLeadInfo : convertedLeadsInfo){

Contact coApplicantToCreate= new Contact();
coApplicantToCreate.AccountId = convertedLeadInfo.ConvertedAccountId;
coApplicantToCreate.MailingStreet = convertedLeadInfo.Co_Applicant_Address__c;
coApplicantToCreate.Birthdate__c = convertedLeadInfo.Co_Applicant_BirthDate__c;
coApplicantToCreate.MailingCity = convertedLeadInfo.Co_Applicant_City__c;
coApplicantToCreate.Email = convertedLeadInfo.Co_Applicant_Email__c;
coApplicantToCreate.FirstName = convertedLeadInfo.Co_Applicant_First_Name__c;
coApplicantToCreate.LastName = convertedLeadInfo.Co_Applicant_Last_Name__c;
coApplicantToCreate.Phone = convertedLeadInfo.Co_Applicant_Phone__c;
coApplicantToCreate.MailingPostalCode = convertedLeadInfo.Co_Applicant_Postal_Code__c;
coApplicantToCreate.SSN__c = convertedLeadInfo.Co_Applicant_Social_Security_Number__c;
coApplicantToCreate.MailingState = convertedLeadInfo.Co_Applicant_State__c;
coApplicantToCreate.Bankrupcy_in_last_seven_years__c = convertedLeadInfo.Bankrupcy_in_last_seven_years_co__c;
coApplicantToCreate.Employer__c = convertedLeadInfo.Employer_Name_co__c;
coApplicantToCreate.Estimated_Monthly_Income__c = convertedLeadInfo.Estimated_Total_Monthly_Income_co__c;
coApplicantToCreate.Felonies__c = convertedLeadInfo.Felonies_co__c;
coApplicantToCreate.Given_deed_for_foreclosure_in_7_years__c = convertedLeadInfo.Given_deed_for_foreclosure_in_7_years_co__c;
coApplicantToCreate.Highest_Degree_Earned__c = convertedLeadInfo.Highest_Degree_Earned_co__c;
coApplicantToCreate.Industry__c = convertedLeadInfo.Industry_co__c;
coApplicantToCreate.Marital_Status__c = convertedLeadInfo.Marital_Status_co__c;
coApplicantToCreate.Profession__c = convertedLeadInfo.Occupation_co__c;
coApplicantToCreate.Previous_foreclosure__c = convertedLeadInfo.Previous_Foreclosure_co__c;
coApplicantToCreate.Reason_for_Background_History__c = convertedLeadInfo.Reason_for_Background_History_co__c;
coApplicantToCreate.School__c = convertedLeadInfo.School_co__c;
coApplicantToCreate.Self_Employed__c = convertedLeadInfo.Self_Employed_co__c;
coApplicantToCreate.Title = convertedLeadInfo.Title_co__c;
coApplicantToCreate.Years_in_Profession__c = convertedLeadInfo.Years_In_This_Profession_co__c;
coApplicantToCreate.Years_of_School__c = convertedLeadInfo.Years_of_School_co__c;
coApplicantToCreate.Years_in_Current_Job__c = convertedLeadInfo.Years_on_This_Job_co__c;
coApplicantsToCreate.add(coApplicantToCreate);
}

if (!coApplicantsToCreate.isEmpty()){
List<Database.SaveResult> contactResults = Database.Insert(coApplicantsToCreate, false);
for (Database.SaveResult contactResult : contactResults){
if (contactResult.isSuccess()){
coApplicantContactIds.add(contactResult.getId());
} else {
System.debug(contactResult.getErrors().get(0).getMessage());
}
}
}


List<OpportunityContactRole> contactRolesToUpdate = new List<OpportunityContactRole>();
List<OpportunityContactRole> contactRolesToInsert = new List<OpportunityContactRole>();

for(OpportunityContactRole contactRole : [SELECT id, Role , IsPrimary
FROM OpportunityContactRole
WHERE OpportunityId =: oppContactIdMap.keySet()
AND   ContactId  =: oppContactIdMap.values()]){
contactRole.Role = CN_Constants.CONTACT_ROLE_APPLICANT;
contactRole.IsPrimary = true;
contactRolesToUpdate.add(contactRole);
}

if(!contactRolesToUpdate.isEmpty()){
List<Database.SaveResult> contactRoleResults = Database.Update(contactRolesToUpdate, false);
for (Database.SaveResult contactRoleResult : contactRoleResults){
if (!contactRoleResult.isSuccess()){
System.debug(contactRoleResult.getErrors().get(0).getMessage());
}
}
}

List<Contact> coApplicants = [SELECT Id, AccountId FROM Contact WHERE ID in :coApplicantContactIds];

for (Contact coApplicant : coApplicants){
OpportunityContactRole contactRoleToInsert = new OpportunityContactRole();
contactRoleToInsert.OpportunityId = accountIdToOpportunityId.get(coApplicant.AccountId);
contactRoleToInsert.ContactId = coApplicant.Id;
contactRoleToInsert.Role = 'Co-Applicant';
contactRolesToInsert.add(contactRoleToInsert);
}

if (!contactRolesToInsert.isEmpty()){
List<Database.SaveResult> contactRoleResults = Database.Insert(contactRolesToInsert, false);
for (Database.SaveResult contactRoleResult : contactRoleResults){
if (!contactRoleResult.isSuccess()){
System.debug(contactRoleResult.getErrors().get(0).getMessage());
}
}
}
}
}
}*/
    
    public static void CalculateNumberOfReferredLeads(boolean isInsert, boolean isUpdate, boolean isDelete, List<Lead> newList, List<Lead> oldList) {
        
        Set<Id> contactIds = new Set<Id>();
        
        if (isInsert || isUpdate) {
            for (Lead l : newList) {
                if (l.Referring_Contact__c != null) {
                    contactIds.add(l.Referring_Contact__c);
                }
            }
        }
        if (isDelete || isUpdate) {
            for (Lead l : oldList) {
                if (l.Referring_Contact__c != null) {
                    contactIds.add(l.Referring_Contact__c);
                }
            }
        }
        
        if(TriggrUtility.RunOnce) { // ADDED by Brad, via Anas
            
            List<Contact> contacts = [SELECT Id, Number_of_Leads__c, RecordType.DeveloperName, Manually_Set_Contact_Status__c, Contact_Status__c FROM Contact WHERE Id IN :contactIds];
            List<Contact> toUpdate = new List<Contact>();
            
            Map<Id, AggregateResult> ars = new Map<Id, AggregateResult>([SELECT Referring_Contact__c Id, COUNT(Id) Number FROM Lead WHERE Referring_Contact__c IN :contactIds GROUP BY Referring_Contact__c]);
            
            for (Contact contact : contacts) {
                
                decimal NoLeads = 0;
                if (ars.containsKey(contact.Id)) {
                    NoLeads = (decimal) ars.get(contact.Id).get('Number');
                }
                
                string Status = '';
                if (NoLeads == 1)
                    Status = Label.Contact_Status_1st_Lead_Submitted;
                if (NoLeads == 2)
                    Status = Label.Contact_Status_2nd_Lead_Submitted;
                if (NoLeads >= 3)
                    Status = Label.Contact_Status_3rd_Lead_Submitted;
                
                boolean upd = false;
                if (contact.Number_of_Leads__c != NoLeads) {
                    contact.Number_of_Leads__c = NoLeads;
                    upd = true;
                }
                if (contact.RecordType.DeveloperName == 'Lender' && contact.Manually_Set_Contact_Status__c == false && contact.Contact_Status__c != Status) {
                    contact.Contact_Status__c = Status;
                    upd = true;
                }
                if (upd) {
                    toUpdate.add(contact);
                }
            }
            
            if (toUpdate.size() > 0) {
                update toUpdate;
            }
        }
        
    }
    
    public static void CopyRecordType(List<Lead> newList) {
        
        for (Lead l : newList) {
            l.RecordType_Product_Picklist__c = Schema.SObjectType.Lead.getRecordTypeInfosById().get(l.RecordTypeId).getName();
        }
    }
    
    public static void LookupRegionalManager(List<Lead> newList, Map<Id, Lead> oldMap) {
        
        Set<String> postalCodes = new Set<String>();
        List<Lead> eligibleLs = new List<Lead>();
        
        for (Lead newLead : newList) {
            if (oldmap == null) {
                if (newLead.Property_Zip_Code__c != null) {
                    postalCodes.add(newLead.Property_Zip_Code__c);
                    eligibleLs.add(newLead);
                }
            } else {
                Lead oldLead = oldMap.get(newLead.Id);
                if (newLead.Property_Zip_Code__c != null && newLead.Property_Zip_Code__c != oldLead.Property_Zip_Code__c) {
                    postalCodes.add(newLead.Property_Zip_Code__c);
                    eligibleLs.add(newLead);
                }
            }
        }
        
        Map<String, Zip_User_Mapping__c> mapping = new Map<String, Zip_User_Mapping__c>();
        for (Zip_User_Mapping__c zum : [SELECT Zip_Code__c, Regional_Manager__c, Regional_Manager__r.ManagerId FROM Zip_User_Mapping__c WHERE Zip_Code__c IN :postalCodes]) {
            mapping.put(zum.Zip_Code__c, zum);
        }
        
        for (Lead newLead : eligibleLs) {
            if (mapping.containsKey(newLead.Property_Zip_Code__c) && Schema.SObjectType.Lead.getRecordTypeInfosById().get(newLead.RecordTypeId).getName() == 'HomeBuyer') {
                newLead.Sales_Director_User__c = mapping.get(newLead.Property_Zip_Code__c).Regional_Manager__c;
                newLead.National_Manager__c = mapping.get(newLead.Property_Zip_Code__c).Regional_Manager__r.ManagerId;
            }
        }
    }

    private static boolean validateFieldsBeforeConversion(Lead ld){
        ld.addError('this is the error');
        return false;
    }
}
