/**
 *  About
 *  -----
 *  Author: Cloud Nerd
 *  Create date: Tue Jun 21 2016
 *  
 *  Details
 *  -----
 *  Apex class to handle all the events raised by LeadTrigger
 *
 *  Update History
 *  -----
 *  -Omnivo Digital 7/11/17---deprecated several Cloud Nerd methods no longer relevant
 *  
 *  -Sundar Subramaniam 03/24/19---add new method on after insert and update to make LeadQaul (LQ) API Callout 
 *  -if the lead status is "Pending Qualification" and Lead Record type is "HomeBuyer" or "HomeOwner"
 *  
 * -Sundar Subramaniam 03/24/19 -- Changed the status with respect to Ticket CM -50 HB Project
 *
 *  Issues / TODOs
 *  -----
 *  
 **/
public class LeadTriggerHandler {

    //Contants
    private static final string HOUSEHOLD_RT_LABEL = 'Household';
    private static final string LENDER_LABEL = 'Lender';
    private static final string REAL_ESTATE_BROKER_LABEL = 'Real Estate Broker';
    
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
    
    //Used to make sure converted leads are not processed twice due to workflow/PB updates after conversion
    //causing triggers to fire twice
    private static set<Id> alreadyConvertedLeadIDSet = new Set<Id>();
    
    //Used to make sure duplicate NPM records are not created twice due to workflow/PB updates
    //causing triggers to fire twice
    private static set<Id> alreadyCreatedNPMLeadIDSet = new Set<Id>();
    
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
        
        //Run this at the end of method
        //-----Deprecated by Omnivo Digital 7/11/17        
        //populateSignature(newList, 'insert');


        //Add By Sundar Subramaniam
        //This below code will call the Utility class to make a API Callout to LeadQual(LQ)
        //Leads on insert if the lead status is "Pending Qualification" and Lead Records type is "HomeBuyer" or "HomeOwner"
        if(!System.isFuture()){
            Id HomeBuyerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
            Id HomeOwnerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
            List<Group> lqQueueList = new List<Group>();
            Id lqQueueId ;
            lqQueueList = [select Id from Group where Name = 'LQ Queue' and Type = 'Queue' LIMIT 1];
            if(lqQueueList.size() > 0){
                lqQueueId = lqQueueList[0].id;
            }
            
            List<Id> leadIdList = new List<Id>();
            for(Lead obj: newList){
                //Sundar Subramaniam 03/27/2019 - change in the criteria with respect to HB Lead Status Update Project - CM-50
                //if(obj.Status == 'Pending Qualification' && (obj.RecordTypeId == HomeBuyerId || obj.RecordTypeId == HomeOwnerId)){
                if( ( lqQueueId != null && obj.OwnerId == lqQueueId ) && ( obj.LQ_Status__c == null && obj.LeadQual_LQ_Response__c == null ) && (obj.Status == 'Pre Discovery' || obj.Status == 'Pending Qualification') && (obj.RecordTypeId == HomeBuyerId || obj.RecordTypeId == HomeOwnerId)){
                    LeadUtilityClass.LQ_CallWebService(obj.Id);
                }
            }
        }
        //Code Ends - Sundar Subramaniam

        CalculateNumberOfReferredLeads(true, false, false, newList, null);

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
     *  5/30/17 - Omnivo Digital - added method to check referring contact lookup and call method to populate dependent fields
    **/
    public static void handleBeforeUpdate(Map<Id,Lead> mapNewLeads, Map<Id,Lead> mapOldLeads){
        
        List<Lead> listLeadsWithLoanOfficer = new List<Lead> ();
        Set<String> setLoanOfficerEmails    = new Set<String>();
        List<Lead> leadsToGenerateSignature = new List<Lead>();
        //Map to hold opportunity ids along with contact ids to create contact roles
        Map<id, id> mapOppIdContactId = new Map<id, id>();

        Set<Id> referringLoanOfficerIds = new Set<Id>();
        List<Lead> LeadsWithReferringLoanOfficer = new List<Lead>();
            
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
                
                if(newLead.Property_Street_Number_and_Name__c != NULL && newLead.Property_City__c != NULL && 
                   newLead.Property_State__c != NULL && newLead.Property_Zip_Code__c != Null && 
                   newLead.New_Construction_Dropdown__c != NULL && newLead.Occupancy_Statement_Dropdown__c != NULL){
                   system.debug('******newLead.Id*******'+newLead.Id);
                   if(system.isBatch()){
                       system.debug('*****batch********');
                       SubmittoBillBoard.makebatchcall(newLead.Id);
                   }else{ 
                       SubmittoBillBoard.makecall(newLead.Id);
                   }               
                }                           
            }     

            //Sundar Subramaniam 04/30/2019: Check if the credit score is less than 650 make lead status closed lost
            if(newLead.Applicant_Credit_Score_Estimate__c != null){
                if(newLead.Applicant_Credit_Score_Estimate__c != mapOldLeads.get(newLead.Id).Applicant_Credit_Score_Estimate__c && (newLead.Applicant_Credit_Score_Estimate__c.trim() == '650' || newLead.Applicant_Credit_Score_Estimate__c.trim() == '< 650')){
                    newLead.Status = 'Closed Lost';
                }else if(newLead.Applicant_Credit_Score_Estimate__c != mapOldLeads.get(newLead.Id).Applicant_Credit_Score_Estimate__c && newLead.Applicant_Credit_Score_Estimate__c.trim().isNumeric() && Integer.valueof(newLead.Applicant_Credit_Score_Estimate__c.trim()) <= 650){
                    newLead.Status = 'Closed Lost';
                }
            }
        }       
        
        //Call method to Set Lead attribution Fields based on referring Loan Officer/Contact
        if(!LeadsWithReferringLoanOfficer.isEmpty() && !referringLoanOfficerIds.isEmpty()){
            assignLoanOfficerReferralFields(LeadsWithReferringLoanOfficer,referringLoanOfficerIds );
        }
        
        CopyRecordType(mapNewLeads.values());
        //2019-04-24 --- Disabling RSM lookup automation per request of Johnny Trieu and Kevin Wu
        //LookupRegionalManager(mapNewLeads.values(), mapOldLeads);        
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

        List<String> leadEmails = new List<String> ();
        Map<Id, Lead> leadsToCheck = new Map<Id, Lead> ();
        Map<Id,Lead> convertedLeadMap = new Map<Id,Lead>();
        Set<Id> leadPCRRollupSet = new Set<Id>();
        Set<Id> leadids = new Set<Id>();

        //Add By Sundar Subramaniam
        //This below code will call the Utility class to make a API Callout to LeadQual(LQ)
        //Leads on update if the lead status is "Pre Discovery" or "Pending Qualification" and Lead Records type is "HomeBuyer" or "HomeOwner"
        if(!System.isFuture()){
            Id HomeBuyerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer').getRecordTypeId();
            Id HomeOwnerId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
            List<Group> lqQueueList = new List<Group>();
            Id lqQueueId ;
            lqQueueList = [select Id from Group where Name = 'LQ Queue' and Type = 'Queue' LIMIT 1];
            if(lqQueueList.size() > 0){
                lqQueueId = lqQueueList[0].id;
            }
            List<Id> leadIdList = new List<Id>();
            for(Lead obj: newList){
                //Sundar Subramaniam 03/27/2019 - change in the criteria with respect to HB Lead Status Update Project - CM-50
                //if(obj.Status == 'Pending Qualification' && (obj.RecordTypeId == HomeBuyerId || obj.RecordTypeId == HomeOwnerId)){
                if(( lqQueueId != null && obj.OwnerId == lqQueueId ) && ( obj.LQ_Status__c != null && obj.LeadQual_LQ_Response__c == null ) && (obj.Status == 'Pre-Discovery' || obj.Status == 'Pending Qualification') && (obj.RecordTypeId == HomeBuyerId || obj.RecordTypeId == HomeOwnerId)){
                    system.debug('condition mate==>API');
                    LeadUtilityClass.LQ_CallWebService(obj.Id);
                }
            }
        }
        //Code Ends - Sundar Subramaniam
        
        for (Lead newLead: newList) {
            if (newLead.Status != oldMap.get(newLead.Id).Status){
                if (newLead.Status == 'Application Reviewed' && String.isNotBlank(newLead.Email)){
                    leadEmails.add(newLead.Email);
                    leadsToCheck.put(newLead.Id, newLead);
                }
            }
            //added Converted Leads
            if(newLead.IsConverted && !oldMap.get(newLead.Id).isConverted && !alreadyConvertedLeadIDSet.contains(newLead.Id)){
                convertedLeadMap.put(newLead.Id, newLead);
                alreadyConvertedLeadIDSet.add(newLead.Id);
            }
            //check leads for MAX PCR change
            if(newLead.Max_Credit_Score_PCR__c != oldMap.get(newLead.Id).Max_Credit_Score_PCR__c){
                leadPCRRollupSet.add(newLead.Id);
            }
            
            if(newLead.Quality_Control_Status__c != Null && newLead.Quality_Control_Status__c == 'Passed'
                && oldMap.get(newLead.Id).Quality_Control_Status__c != 'Passed'){
                leadids.add(newLead.Id);                
            }            
        }
        
        
        //Process converted Leads
        if(!convertedLeadMap.isEmpty()){
            processConvertedLeads(convertedLeadMap);
        }
        
        //-----Deprecated by Omnivo Digital 7/11/17
        //checkExistingContactOrLeads(leadEmails, leadsToCheck);
        
        if(!leadPCRRollupSet.isEmpty()){
            PCR_trigger_handler.rollupPCRToLead(leadPCRRollupSet);
        }
        
        unconvertCopyLeads(newList, oldMap);               
        if(leadids.size() > 0){
            LeadUtilityClass.addMRDAttachments(leadids);
        }

        DelightedIntegration(newList, oldMap);

        CalculateNumberOfReferredLeads(false, true, false, newList, oldMap.values());
    }
    
    public static void handleAfterDelete(List<Lead> oldList) {
        CalculateNumberOfReferredLeads(false, false, true, null, oldList);
    }
    
    private static void DelightedIntegration(List<Lead> newList, Map<Id, Lead> oldMap) {

        if (!System.isFuture() && !System.isBatch()) {
            List<Id> lIds = new List<Id>();
            for (Lead newLead: newList) {
                if(!alreadyCreatedNPMLeadIDSet.contains(newLead.Id) && !newLead.Delighted_Survey_Sent__c && !newLead.Marketing_Opt_Out__c){
                    if(newLead.Delighted_Send_Status__c && oldMap.get(newLead.Id).Delighted_Send_Status__c != newLead.Delighted_Send_Status__c) {
                        lIds.add(newlead.Id);
                        alreadyCreatedNPMLeadIDSet.add(newLead.Id);
                    }
                    else if( ( newLead.Status == 'Closed Lost' && newLead.Loss_Type__c == 'No Sale' ) && ( oldMap.get(newLead.Id).Status != newLead.Status || oldMap.get(newLead.Id).Loss_Type__c != newLead.Loss_Type__c ) && newLead.Loss_Reason_Type__c != 'First contact - Asked to be removed') {
                        lIds.add(newlead.Id);
                        alreadyCreatedNPMLeadIDSet.add(newLead.Id);
                    }
                }
            }

            // limit of 50 future calls
            for (integer i = 0; i < 50 && i < lIds.size(); i++) {
                if(!System.isFuture()){
                    DelightedHelper.SendSurveyLead(lIds[i]);
                }
            }
        }
    }

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
    
    private static void processConvertedLeads(Map<Id, Lead> convertedLeads){
        List<LASERCA__Personal_Credit_Report__c> PCRsToUpdate = new List<LASERCA__Personal_Credit_Report__c>();
        List<dsfs__DocuSign_Status__c> docSignsToUpdate = new List<dsfs__DocuSign_Status__c>();
        List<Case> casesToUpdate = new List<Case>();
        
        //Get Contact RT Map
        Schema.DescribeSObjectResult conDesc = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContRTMapByName = conDesc.getRecordTypeInfosByName();        
        
        //process Personal Credit Reports
        for(LASERCA__Personal_Credit_Report__c pcr: [SELECT LASERCA__Lead__c, LASERCA__Contact__c,Opportunity__c
                                                     FROM LASERCA__Personal_Credit_Report__c 
                                                     WHERE LASERCA__Lead__c IN: convertedLeads.keySet()]){
            pcr.LASERCA__Contact__c = convertedLeads.get(pcr.LASERCA__Lead__c).ConvertedContactId;
            pcr.Opportunity__c =  convertedLeads.get(pcr.LASERCA__Lead__c).ConvertedOpportunityId;
            PCRsToUpdate.add(pcr);                                                 
        }
            
        //process Docusign Statuses
        for(dsfs__DocuSign_Status__c docsign: [SELECT dsfs__Lead__c, dsfs__Company__c,dsfs__Opportunity__c
                                              FROM dsfs__DocuSign_Status__c
                                               WHERE dsfs__Lead__c IN: convertedLeads.keySet()]){
            docsign.dsfs__Company__c =  convertedLeads.get(docsign.dsfs__Lead__c).ConvertedAccountId;
            docsign.dsfs__Opportunity__c =  convertedLeads.get(docsign.dsfs__Lead__c).ConvertedOpportunityId;                                                   
            docSignsToUpdate.add(docsign);
        }
        
        //process Cases
        for(Case c: [SELECT Lead__c, Opportunity__c, AccountId
                                              FROM Case
                                               WHERE Lead__c IN: convertedLeads.keySet()]){
            c.Opportunity__c = convertedLeads.get(c.Lead__c).ConvertedOpportunityId;
            c.AccountId =  convertedLeads.get(c.Lead__c).ConvertedAccountId;                                                   
            casesToUpdate.add(c);
        }

        //get all yodleeOrders
        List<Yodlee_Order_Request__c> yodleeOrders = [Select Id, Opportunity__c, Lead__c from Yodlee_Order_Request__c Where Lead__c IN: convertedLeads.keySet()];
        Map<Id, Yodlee_Order_Request__c> yodleeOrderLeadMap = new Map<Id, Yodlee_Order_Request__c>();
        for(Yodlee_Order_Request__c yodleeOrder: yodleeOrders){
            yodleeOrderLeadMap.put(yodleeOrder.Lead__c, yodleeOrder);
        }//end for
        
        //process co-applicant on Lead into Contact
        Set<Id> convertedLeadIdSet = convertedLeads.keySet();
        string applicationQuery = CMUtility.getCreatableFieldsSOQL('Application__c', 'Lead__c IN:convertedLeadIdSet');        
        system.debug('applicationQuery---' + applicationQuery);
        List<Application__c> appList = database.query(applicationQuery);
        List<Contact> contactsToInsert = new List<Contact>(); 
        List<Yodlee_Order_Request__c> yodleeOrdersToUpdate = new List<Yodlee_Order_Request__c>();
        Set<Id> convertedOpportunityIdSet = new Set<Id>();               
            
        for(Lead l: convertedLeads.values()){
            convertedOpportunityIdSet.add(l.ConvertedOpportunityId);
            if(l.Is_there_Co_App__c && l.Co_Applicant_Last_Name__c != NULL){
                Contact coAppContact = new Contact();
                if(ContRTMapByName.get(HOUSEHOLD_RT_LABEL) != NULL){
                    coAppContact.RecordTypeId = ContRTMapByName.get(HOUSEHOLD_RT_LABEL).getRecordTypeId();
                } 
                coAppContact.Opp_Lookup_Helper__c = 'coapplicant1';
                coAppContact.AccountId = l.ConvertedAccountId;
                coAppContact.LastName = l.Co_Applicant_Last_Name__c;
                coAppContact.FirstName = l.Co_Applicant_First_Name__c;
                coAppContact.MailingStreet = l.Co_Applicant_Address__c;
                coAppContact.MailingCity = l.Co_Applicant_City__c;
                coAppContact.MailingState = l.Co_Applicant_State__c;
                coAppContact.MailingPostalCode = l.Co_Applicant_Postal_Code__c;
                coAppContact.Social_Security_Number__c = l.Co_Applicant_Social_Security_Number__c;
                coAppContact.Birthdate = l.Co_Applicant_Birthdate__c;
                coAppContact.Marital_Status__c = l.Marital_Status_Co__c;
                coAppContact.Years_of_School__c = l.Years_of_School_Co__c;
                coAppContact.Highest_Degree_Earned__c = l.Highest_Degree_Earned_Co__c;
                coAppContact.School__c = l.School_Co__c;
                coAppContact.Industry__c = l.Industry_Co__c;
                coAppContact.Profession__c = l.Occupation_co__c ;
                coAppContact.Years_in_Profession__c = l.Years_In_This_Profession_co__c;
                coAppContact.Self_Employed__c = l.Self_Employed_Co__c;
                coAppContact.Employer__c = l.Employer_Name_Co__c;
                coAppContact.Employer_Phone__c = l.Employer_Phone_Co__c;
                coAppContact.Employer_Address__c = l.Employer_Address_Co__c;
                coAppContact.Title = l.Title_Co__c;
                coAppContact.Years_in_Current_Job__c = l.Years_On_This_Job_Co__c;
                coAppContact.Estimated_Monthly_Income__c = l.Estimated_Total_Monthly_Income_Co__c;
                coAppContact.Income_Monthly_Base__c = l.Income_Monthly_Base_Co__c;
                coAppcontact.Income_Monthly__c = l.Income_Monthly_Bonuses_Co__c; 
                coAppContact.Income_Monthly_Commissions__c = l.Income_Monthly_Commissions_Co__c;
                coAppContact.Income_Monthly_Div_Interest__c = l.Income_Monthly_Div_Interest_Co__c;
                coAppContact.Income_Monthly_Other__c = l.Income_Monthly_Other_Co__c;
                coAppContact.Income_Monthly_Overtime__c = l.Income_Monthly_Overtime_Co__c;
                coAppContact.Income_Monthly_Social_Security__c = l.Income_Monthly_Social_Security_Co__c;
                coAppContact.Declaration_Felony__c = l.Co_Applicant_Felony__c;
                coAppContact.Declaration_Bankruptcy__c = l.Co_Applicant_Bankruptcy_Dropdown__c;
                coAppContact.Declaration_Foreclosure__c = l.Co_Applicant_Foreclosure_Dropdown__c;
                coAppContact.Declaration_Deed_in_Lieu__c = l.Co_Applicant_Deed_of_Foreclosure__c ;
                coAppContact.Declaration_Explanation__c = l.Reason_for_Background_History_co__c;
                coAppContact.Declaration_Delinquency__c = l.Declaration_Deliquency_Co__c ;                
                coAppContact.Declaration_Intend_to_Occupy__c = l.Declaration_Intend_to_Occupy_Co__c;                
                coAppContact.Declaration_Lawsuit__c = l.Declaration_Lawsuit_Co__c;
                coAppContact.Declaration_Outstanding_Judgments__c = l.Declaration_Outstanding_Judgments_Co__c;
                coAppContact.Declaration_Permanent_Resident__c = l.Declaration_Permanent_Resident_Co__c;
                coAppContact.Declaration_Power_of_Attorney__c = l.Declaration_Power_of_Attorney_Co__c;
                coAppContact.Declaration_US_Citizen__c = l.Declaration_US_Citizen_Co__c;
                
                coAppContact.Do_Not_Let_Affiliates_Market__c = l.Privacy_No_Affiliates_Market_Co__c;
                coAppContact.Do_Not_Share_with_Non_Affiliates__c = l.Privacy_Do_not_share_Non_Affiliates_Co__c;
                coAppContact.DontShareCreditworthinessInformation__c = l.Privacy_Do_not_share_Creditworthiness_Co__c;
                
                coAppContact.Phone = l.Co_Applicant_Phone__c;
                coAppContact.MobilePhone = l.Mobile_Phone_Co__c;
                coAppContact.Work_Phone__c = l.Work_Phone_Co__c;
                coAppContact.Email = l.Co_Applicant_Email__c;
    
                contactsToInsert.add(coAppContact);                
            }

            if (yodleeOrderLeadMap != null && yodleeOrderLeadMap.size() > 0 && yodleeOrderLeadMap.get(l.Id) != null){
                Yodlee_Order_Request__c yodlee = yodleeOrderLeadMap.get(l.Id);
                yodlee.Opportunity__c = l.Converted_Opportunity__c;
                
                yodleeOrdersToUpdate.add(yodlee);
            }
        }//end for
        
        //process Applications into Contacts
        integer i = 2;
        for(Application__c app: appList){
            //add converted Opp ID lookup to application
            app.Opportunity__c = convertedLeads.get(app.Lead__c).ConvertedOpportunityId;
            
            //Applicant
            if(app.Last_Name__c != NULL){
                Contact appContact = new Contact();
                if(ContRTMapByName.get(HOUSEHOLD_RT_LABEL) != NULL){
                    appContact.RecordTypeId = ContRTMapByName.get(HOUSEHOLD_RT_LABEL).getRecordTypeId();
                }     
                appContact.Opp_Lookup_Helper__c = 'applicant' + string.valueOf(i);
                appContact.AccountId = convertedLeads.get(app.Lead__c).ConvertedAccountId;
                appContact.LastName = app.Last_Name__c;
                appContact.FirstName = app.First_Name__c;
                appContact.MailingStreet = app.Applicant_Address__c;
                appContact.MailingCity = app.Applicant_City__c;
                appContact.MailingState = app.Applicant_State__c;
                appContact.MailingPostalCode = app.Applicant_Postal_Code__c;
                appContact.Social_Security_Number__c = app.Applicant_Social_Security_Number__c;
                appContact.Birthdate = app.Birthdate__c;
                appContact.Marital_Status__c = app.Marital_Status__c;
                appContact.Years_of_School__c = app.Years_of_School__c;
                appContact.Highest_Degree_Earned__c = app.Highest_Degree_Earned__c;
                appContact.School__c = app.School__c;
                appContact.Industry__c = app.Industry__c;
                appContact.Profession__c = app.Profession__c;
                appContact.Years_in_Profession__c = app.Years_In_This_Profession__c;
                appContact.Self_Employed__c = app.Self_Employed__c;
                appContact.Employer__c = app.Employer_Name__c;
                appContact.Employer_Address__c = app.Employer_Address__c;
                appContact.Employer_Phone__c = app.Employer_Phone__c;
                appContact.Title = app.Title__c;
                appContact.Years_in_Current_Job__c = app.Years_On_This_Job__c;
                appContact.Estimated_Monthly_Income__c = app.Estimated_Total_Monthly_Income__c;
                appContact.Income_Monthly_Base__c = app.Income_Monthly_Base__c;
                appContact.Income_Monthly__c = app.Income_Monthly_Bonuses__c;
                appContact.Income_Monthly_Commissions__c = app.Income_Monthly_Commissions__c;
                appContact.Income_Monthly_Div_Interest__c = app.Income_Monthly_Div_Interest__c;
                appContact.Income_Monthly_Other__c = app.Income_Monthly_Other__c;
                appContact.Income_Monthly_Overtime__c = app.Income_Monthly_Overtime__c;
                appContact.Income_Monthly_Social_Security__c = app.Income_Monthly_Social_Security__c;
                appContact.Declaration_Felony__c = app.Declaration_Felony__c;
                appContact.Declaration_Bankruptcy__c = app.Declaration_Bankruptcy__c;
                appContact.Declaration_Foreclosure__c = app.Declaration_Foreclosure__c;
                appContact.Declaration_Deed_in_Lieu__c = app.Declaration_Deed_in_Lieu__c;
                appContact.Declaration_Explanation__c = app.Declaration_Explanation__c;
                appContact.Declaration_Delinquency__c = app.Declaration_Delinquency__c;
                appContact.Declaration_Lawsuit__c = app.Declaration_Foreclosure__c;
                appContact.Declaration_Outstanding_Judgments__c = app.Declaration_Outstanding_Judgments__c;
                appContact.Declaration_Permanent_Resident__c = app.Declaration_Permanent_Resident__c;
                appContact.Declaration_Power_of_Attorney__c = app.Declaration_Power_of_Attorney__c;
                appContact.Declaration_Intend_to_Occupy__c = app.Declaration_Intend_to_Occupy__c;
                appContact.Declaration_US_Citizen__c = app.Declaration_US_Citizen__c;
                //Put Asset fields on primary Contact only
                appContact.Assets_Bank_Acct__c = app.Assets_Bank_Acct__c;
                appContact.Assets_Brokerage_Acct__c = app.Assets_Brokerage_Acct__c;
                appContact.Assets_Other_Real_Estate__c = app.Assets_Other_Real_Estate__c;
                appContact.Assets_Retirement_Acct__c = app.Assets_Retirement_Acct__c;
                appContact.Assets_Other__c = app.Assets_Other__c;
                
                contactsToInsert.add(appContact);
            }
            //Co-Applicant
            if(app.Last_Name_Co__c != NULL){
                Contact coAppContact = new Contact();
                if(ContRTMapByName.get(HOUSEHOLD_RT_LABEL) != NULL){
                    coAppContact.RecordTypeId = ContRTMapByName.get(HOUSEHOLD_RT_LABEL).getRecordTypeId();
                }                
                coAppContact.Opp_Lookup_Helper__c = 'coapplicant' + string.valueOf(i);
                coAppContact.AccountId = convertedLeads.get(app.Lead__c).ConvertedAccountId;                
                coAppContact.LastName = app.Last_Name_Co__c;
                coAppContact.FirstName = app.First_Name_Co__c;
                coAppContact.MailingStreet = app.Co_Applicant_Address__c;
                coAppContact.MailingCity = app.Co_Applicant_City__c;
                coAppContact.MailingState = app.Co_Applicant_State__c;
                coAppContact.MailingPostalCode = app.Co_Applicant_Postal_Code__c;
                coAppContact.Social_Security_Number__c = app.Co_Applicant_Social_Security_Number__c;
                coAppContact.Birthdate = app.Co_Applicant_Birthdate__c;
                coAppContact.Marital_Status__c = app.Marital_Status_Co__c;
                coAppContact.Years_of_School__c = app.Years_of_School_Co__c;
                coAppContact.Highest_Degree_Earned__c = app.Highest_Degree_Earned_Co__c;
                coAppContact.School__c = app.School_Co__c;
                coAppContact.Industry__c = app.Industry_Co__c;
                coAppContact.Profession__c = app.Profession_Co__c;
                coAppContact.Years_in_Profession__c = app.Years_In_This_Profession_Co__c;
                coAppContact.Self_Employed__c = app.Self_Employed_Co__c;
                coAppContact.Employer__c = app.Employer_Name_Co__c;
                coAppContact.Employer_Address__c = app.Employer_Address_Co__c;
                coAppContact.Employer_Phone__c = app.Employer_Phone_Co__c;                
                coAppContact.Title = app.Title_Co__c;
                coAppContact.Years_in_Current_Job__c = app.Years_On_This_Job_Co__c;
                coAppContact.Estimated_Monthly_Income__c = app.Estimated_Total_Monthly_Income_Co__c;
                coAppContact.Income_Monthly_Base__c = app.Income_Monthly_Base_Co__c;
                coAppContact.Income_Monthly__c = app.Income_Monthly_Bonuses_Co__c;
                coAppContact.Income_Monthly_Commissions__c = app.Income_Monthly_Commissions_Co__c;
                coAppContact.Income_Monthly_Div_Interest__c = app.Income_Monthly_Div_Interest_Co__c;
                coAppContact.Income_Monthly_Other__c = app.Income_Monthly_Other_Co__c;
                coAppContact.Income_Monthly_Overtime__c = app.Income_Monthly_Overtime_Co__c;
                coAppContact.Income_Monthly_Social_Security__c = app.Income_Monthly_Social_Security_Co__c;                
                coAppContact.Declaration_Felony__c = app.Declaration_Felony_Co__c;
                coAppContact.Declaration_Bankruptcy__c = app.Declaration_Bankruptcy_Co__c;
                coAppContact.Declaration_Foreclosure__c = app.Declaration_Foreclosure_Co__c;
                coAppContact.Declaration_Deed_in_Lieu__c = app.Declaration_Deed_in_Lieu_Co__c;
                coAppContact.Declaration_Explanation__c = app.Declaration_Explanation_Co__c;
                coAppContact.Declaration_Lawsuit__c = app.Declaration_Lawsuit_Co__c;
                coAppContact.Declaration_Delinquency__c = app.Declaration_Delinquency_Co__c;
                coAppContact.Declaration_Outstanding_Judgments__c = app.Declaration_Outstanding_Judgments_Co__c;
                coAppContact.Declaration_Permanent_Resident__c = app.Declaration_Permanent_Resident_Co__c;
                coAppContact.Declaration_Power_of_Attorney__c = app.Declaration_Power_of_Attorney_Co__c;
                coAppContact.Declaration_Intend_to_Occupy__c = app.Declaration_Intend_to_Occupy_Co__c;
                coAppContact.Declaration_US_Citizen__c = app.Declaration_US_Citizen_Co__c;                
                contactsToInsert.add(coAppContact);                                
            }
        }
        
        if(!PCRsToUpdate.isEmpty()){
            update PCRsToUpdate;
        }
        if(!docSignsToUpdate.isEmpty()){
            update docSignsToUpdate;
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
        if(!appList.isEmpty()){
            update appList;
        }
        if(!contactsToInsert.isEmpty()){
            insert contactsToInsert;
        }        
        if(!convertedOpportunityIdSet.isEmpty()){
            updateConvertedOpportunities(convertedOpportunityIdSet);
        }

        if (!yodleeOrdersToUpdate.isEmpty()){
            update yodleeOrdersToUpdate;
        }
    }
    
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
            /*statusMap.put('Running Credit', 'Pending Submission');
            statusMap.put('Pre-Qualifying Application', 'Pending Submission');
            statusMap.put('Requires Exception', 'Pending Submission');
            statusMap.put('On Hold', 'Pending Submission');
            statusMap.put('Application Pre-Qualified', 'Pending Submission');
            statusMap.put('Property in Contract', 'Pending Submission');*/
            
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
    private static void handleRealEstateAgentReferrals_before(List<Lead> leadsToUpdate){
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
        
        List<Contact> contacts = [SELECT Id, Number_of_Leads__c, RecordType.DeveloperName, Manually_Set_Contact_Status__c, Contact_Status__c FROM Contact WHERE Id IN :contactIds];
        List<Contact> toUpdate = new List<Contact>();
        
        Map<Id, AggregateResult> ars = new Map<Id, AggregateResult>([SELECT Referring_Contact__c Id, COUNT(Id) Number FROM Lead WHERE Referring_Contact__c IN :contactIds GROUP BY Referring_Contact__c]);
        
        for (Contact contact : contacts) {
            
            decimal NoLeads = 0;
            if (ars.containsKey(contact.Id)) {
                NoLeads = (decimal)ars.get(contact.Id).get('Number');
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
    
}