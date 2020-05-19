/**
 * Created by Eliot Rojas on 4/29/2019.
 */

public with sharing class OpportunityChatterUpdates {
    // CONSTANTS
    private static final Set<String> TEMPLATE_NAMES = new Set<String>{ 'IA_notification_for_completed_PKR', 'Appraisal_Received',
            'Home_Inspection_Received', 'Title_Report_Recceived', 'IA_OAV_Discount',
            'IA_Final_OAV', 'TS_Final_OAV', 'OIP_Changed', 'IA_Investor_Percentage'};


    private static final List<EmailTemplate> EMAIL_TEMPLATES = [SELECT Id, DeveloperName, BrandTemplateId, IsActive, Body, Subject, HtmlValue
    FROM EmailTemplate WHERE DeveloperName IN : TEMPLATE_NAMES];

    // Custom Recipient
    private static final User OIP_CHANGED_RECIPIENT = [SELECT Id, Name, Email, IsActive FROM User WHERE Name = 'Dan Eisenberg' AND IsActive = TRUE];
    private static final User MENTION_RAYAN = [SELECT Id, Name, Email, IsActive FROM User WHERE Name = 'Rayan Rafay' AND IsActive = TRUE];
    private static final String ORG_URL = system.URL.getSalesforceBaseUrl().toExternalForm();

    // Process Chatter posts and email alerts (ON INSERT)
    public static void doChatterUpdates(List<Opportunity> newList) {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : newList) {
            oppIds.add(opp.Id);
        }

        List<FeedItem> chatterPosts = new List<FeedItem>();
        List<ConnectApi.BatchInput> chatterPostsBatch = new List<ConnectApi.BatchInput>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, Name, CloseDate, StageName, LeadSource, HomeOwner_vs_Other_Options__c, Investor_Percentage_and_Repayment_Amo__c, Remodeling_Adjustment__c,
                Deferred_Maintenance__c, Selling_3_Years__c, Agreement_Requirements__c, Max_Auth_Debt__c, Unexpected_Circumstances__c,
                Ending_the_Agreement__c, Option_Contract_Structure__c, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Process_Program_Knowledge_Review__c, Appraisal_Ordered__c,
                Appraisal_Received__c, Investment_Analyst2__c, Second_Appraisal_Ordered__c, Property_Address__c, Second_Appraisal_Received__c,
                Home_Inspection_Ordered__c, Home_Inspection_Received__c, Property_Report_Ordered__c, Property_Report_Received__c,
                OAV_Discount_Amount_f__c, Final_OAV_Calculation__c, Wire_to_Agent_Date__c, DMA_Required_f_del__c, Estimated_Funding_Amount__c,
                Household_Down_Payment__c, Loan_Amount__c, Loan_Officer_Name__c, Investor_Percentage__c, Pricing_Ratio__c, Maximum_Authorized_DTI__c,
                Maximum_Authorized_LTV__c, UnisonProcessor__c, UnisonProcessor__r.FirstName, UnisonProcessor__r.LastName
        FROM Opportunity WHERE Id IN : oppIds]);
        Map<String, Id> emailTemplates = new Map<String, Id>();
        for(EmailTemplate template : EMAIL_TEMPLATES) {
            emailTemplates.put(template.DeveloperName, template.Id);
        }

        for(string oppId : opportunityMap.keySet()) {
            Opportunity opp = opportunityMap.get(oppId);
            // Post to PS - PKR Completed
            if(opp.Process_Program_Knowledge_Review__c) {
                String postBody = opp.Name + ' has completed their Program Knowledge Review.';
                postBody += '\n\nHere are the responses:';

                postBody += '\n\nHomeOwner vs. Other Options:';
                postBody += '\n' + (opp.HomeOwner_vs_Other_Options__c == '' ? 'Empty' : opp.HomeOwner_vs_Other_Options__c);

                postBody += '\n\nInvestor % and Repayment:';
                postBody += '\n' + opp.Investor_Percentage_and_Repayment_Amo__c;

                postBody += '\n\nRemodeling Adjustment:';
                postBody += '\n' + opp.Remodeling_Adjustment__c;

                postBody += '\n\nDeferred Maintenance:';
                postBody += '\n' + opp.Deferred_Maintenance__c;

                postBody += '\n\nSelling <3 Years:';
                postBody += '\n' + opp.Selling_3_Years__c;

                postBody += '\n\nAgreement Requirements:';
                postBody += '\n' + opp.Agreement_Requirements__c;

                postBody += '\n\nMax Auth Debt:';
                postBody += '\n' + opp.Max_Auth_Debt__c;

                postBody += '\n\nUnexpected Circumstances:';
                postBody += '\n' + opp.Unexpected_Circumstances__c;

                postBody += '\n\nEnding the Agreement:';
                postBody += '\n' + opp.Ending_the_Agreement__c;

                postBody += '\n\nOption Contract Structure:';
                postBody += '\n' + opp.Option_Contract_Structure__c;

                postBody += '\n\n' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // IA Email Notification
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('IA_notification_for_completed_PKR'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email);
            }

            // HO- Appraisal Ordered
            if(opp.Appraisal_Ordered__c) {
                String postBody = 'The Appraisal has been ordered by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- Appraisal received
            if(opp.Appraisal_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The Appraisal has been received by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // IA Email Notification
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Appraisal_Received'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // HO- 2nd Appraisal Ordered
            if(opp.Second_Appraisal_Ordered__c) {
                String postBody = 'The second Appraisal has been ordered by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- 2nd Appraisal Received
            if(opp.Second_Appraisal_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The second Appraisal has been received by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Appraisal_Received'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // HO- Home Inspection Ordered
            if(opp.Home_Inspection_Ordered__c) {
                String postBody = 'The Home Inspection has been ordered for the ' + opp.Name + ' file.';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- Home Inspection Received
            if(opp.Home_Inspection_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The Home Inspection has been received for the ' + opp.Name + ' file.';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Home_Inspection_Received'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // HO- Property Report Ordered
            if(opp.Property_Report_Ordered__c) {
                String postBody = 'The Property Report has been ordered by the Unison Processor, ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- Property Report Received
            if(opp.Property_Report_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The Property Report has been received by the Unison Processor, ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Title_Report_Recceived'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // OAV Discount
            if(opp.OAV_Discount_Amount_f__c != null && opp.Investment_Analyst2__c != null) {
                // Email alert to IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('IA_OAV_Discount'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email);
            }

            // FINAL OAV
            if(opp.Final_OAV_Calculation__c != null && opp.Investment_Analyst2__c != null && opp.UnisonProcessor__c != null) {
                String postBodyPS = 'A Final OAV ' + opp.Final_OAV_Calculation__c + ' has been set to the Original Agreed Value.';
                postBodyPS += '\n\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBodyPS, false);
                chatterPostsBatch.add(postToPS);

                String postBodyRecord = 'A Final OAV ' + opp.Final_OAV_Calculation__c + ' has been set to the Original Agreed Value for the ' + opp.Name + '.';
                postBodyRecord += '\n\nThe current OAV is ' + opp.Final_OAV_Calculation__c + ' now.';
                postBodyRecord += '\n\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBodyRecord, false);
                chatterPostsBatch.add(postToRecord);

                // Email to IA
                Messaging.SingleEmailMessage email_IA = sendEmail(emailTemplates.get('IA_Final_OAV'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email_IA);

                // Email TS Final OAV
                Messaging.SingleEmailMessage email_TS = sendEmail(emailTemplates.get('TS_Final_OAV'), opp.UnisonProcessor__c, oppId);
                emailsToSend.add(email_TS);
            }

            // Wire Date
            if(opp.Wire_to_Agent_Date__c != null && opp.Wire_to_Agent_Date__c >= system.today()) {
                String postBody = 'The Wire has been scheduled to send out today ' + opp.Name + ' file.';

                // Post to Record
                ConnectApi.BatchInput postToPS = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // DMA required
            if(opp.DMA_Required_f_del__c) {
                String postBody = 'It has been determined by Underwriting that a DMA is required for the ' + opp.Name + ' deal.';
                postBody += '\n\nThe estimated close of escrow is:';
                postBody += '\n' + opp.CloseDate;
                postBody += '\n\n' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                postBody += '\n\nDeal Details: ';
                postBody += '\n\nHome Value: ' + opp.Final_OAV_Calculation__c;
                postBody += '\nUnison Down Payment: ' + opp.Estimated_Funding_Amount__c;
                postBody += '\nCustomer Down Payment: ' + opp.Household_Down_Payment__c;
                postBody += '\nLoan Amount: ' + opp.Loan_Amount__c;
                postBody += '\nLoan Officer: ' + opp.Loan_Officer_Name__c;
                postBody += '\nLead Source: ' + opp.LeadSource;

                postBody += '\n\nProperty Address: ' + opp.Property_Address__c;

                postBody += '\n\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // OIP Updated TODO: figure out if we can set 'from' email
            if(opp.Estimated_Funding_Amount__c != null && opp.Investment_Analyst2__c != null) {
                String postBody = 'The OIP has been changed to ' + opp.Estimated_Funding_Amount__c + '. Please refer to the opportunities field history to see the previous value.';

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email alert to IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('OIP_Changed'), OIP_CHANGED_RECIPIENT.Id, oppId);
                email.setReplyTo('info@myunison.com');
                email.setSenderDisplayName('Unison');
                emailsToSend.add(email);
            }

            // Close date updated
            if(opp.CloseDate != null) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\nThe Close date for file ' + opp.Name + ' has been changed to ' + opp.CloseDate;
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: '  + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                /// Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Investor Percentage Change
            if(opp.Investor_Percentage__c != null && opp.Investment_Analyst2__c != null) {
                // Email alert to IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('IA_Investor_Percentage'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email);
            }

            // Price Ratio change
            if(opp.Pricing_Ratio__c != null && opp.Investment_Analyst2__c != null) {
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();

                String postBody = '';
                postBody += '\n\nThis is a notification that the Pricing Ratio has been changed to ' + opp.Pricing_Ratio__c + ' for the ' + opp.Name + ' file.';

                // Post to Rayan
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, true);
                chatterPostsBatch.add(postToRecord);
            }

            // Max DTI change
            if(opp.Maximum_Authorized_DTI__c != null) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\nA change has been made to a customer’s Maximum Authorized Debt. As such, the change will need to be reviewed with the Customer. Details are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBody += '\n\tName: ' + opp.Name;
                postBody += '\n\tNew Authorized Back-End DTI: ' + opp.Maximum_Authorized_DTI__c + '%';

                postBody += '\n\nRegards,';
                postBody += '\nSalesforce Admin';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Max Authorized LTV
            if(opp.Maximum_Authorized_LTV__c != null) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\nA change has been made to a customer’s Maximum Authorized Debt. As such, the change will need to be reviewed with the Customer. Details are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBody += '\n\tName: ' + opp.Name;
                postBody += '\n\tNew Max Authorized LTV: ' + opp.Maximum_Authorized_LTV__c + '%';

                postBody += '\n\nRegards,';
                postBody += '\nSalesforce Admin';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Wire to Agent date set
            if(opp.Wire_to_Agent_Date__c != null) {
                String postBodyPS = 'Dear ' + opp.Owner.FirstName + ',';
                postBodyPS += '\n\nThe wire to agent date has been set.';
                postBodyPS += '\n\nDetails are as follows:';
                postBodyPS += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBodyPS += '\n\tName: ' + opp.Name;
                postBodyPS += '\n\tWire to agent date: ' + opp.Wire_to_Agent_Date__c;

                postBodyPS += '\n\nRegards,';
                postBodyPS += '\nSalesforce Admin';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBodyPS, false);
                chatterPostsBatch.add(postToPS);

                String postBodyRecord = 'The wire to agent date has been set.';
                postBodyRecord += '\n\nDetails are as follows:';
                postBodyRecord += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBodyRecord += '\n\tName: ' + opp.Name;
                postBodyRecord += '\n\tWire to agent date: ' + opp.Wire_to_Agent_Date__c;

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBodyRecord, false);
                chatterPostsBatch.add(postToRecord);
            }

            /*// Final Approval [COMMENTED, WE CANNOT SKIP STAGES]
            if(opp.StageName == 'Final Approval') {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\n' + opp.Name + ' has been submitted for Final Approval.';
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }*/

            /*// Closing [COMMENTED, WE CANNOT SKIP STAGES]
            if(opp.StageName == 'Closing') {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\n' + opp.Name + ' is now in the Closing stage.';
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }*/

            /*// Post-Closing [COMMENTED, WE CANNOT SKIP STAGES]
            if(opp.StageName == 'Post-Closing') {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\n' + opp.Name + ' is funded won and now in the Post Closing stage.';
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }*/
        }
        // Finally send email messages
        if(!emailsToSend.isEmpty()) {
            if(!Test.isRunningTest()) {
                Messaging.sendEmail((List<Messaging.Email>) emailsToSend);
            }
        }
        // Finally post to chatter
        if(!chatterPostsBatch.isEmpty()) {
            if(!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostsBatch);
            }
        }
    }

    // Process Chatter posts and email alerts (ON UPDATE)
    public static void doChatterUpdates(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : newList) {
            oppIds.add(opp.Id);
        }

        List<FeedItem> chatterPosts = new List<FeedItem>();
        List<ConnectApi.BatchInput> chatterPostsBatch = new List<ConnectApi.BatchInput>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, Name, CloseDate, StageName, LeadSource, HomeOwner_vs_Other_Options__c, Investor_Percentage_and_Repayment_Amo__c, Remodeling_Adjustment__c,
                Deferred_Maintenance__c, Selling_3_Years__c, Agreement_Requirements__c, Max_Auth_Debt__c, Unexpected_Circumstances__c,
                Ending_the_Agreement__c, Option_Contract_Structure__c, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Process_Program_Knowledge_Review__c, Appraisal_Ordered__c,
                Appraisal_Received__c, Investment_Analyst2__c, Second_Appraisal_Ordered__c, Property_Address__c, Second_Appraisal_Received__c,
                Home_Inspection_Ordered__c, Home_Inspection_Received__c, Property_Report_Ordered__c, Property_Report_Received__c,
                OAV_Discount_Amount_f__c, Final_OAV_Calculation__c, Wire_to_Agent_Date__c, DMA_Required_f_del__c, Estimated_Funding_Amount__c,
                Household_Down_Payment__c, Loan_Amount__c, Loan_Officer_Name__c, Investor_Percentage__c, Pricing_Ratio__c, Maximum_Authorized_DTI__c,
                Maximum_Authorized_LTV__c, UnisonProcessor__c, UnisonProcessor__r.FirstName, UnisonProcessor__r.LastName
        FROM Opportunity WHERE Id IN : oppIds]);
        Map<String, Id> emailTemplates = new Map<String, Id>();
        for(EmailTemplate template : EMAIL_TEMPLATES) {
            emailTemplates.put(template.DeveloperName, template.Id);
        }

        for(string oppId : opportunityMap.keySet()) {
            Opportunity opp = opportunityMap.get(oppId);
            // Post to PS - PKR Completed
            if(opp.Process_Program_Knowledge_Review__c && opp.Process_Program_Knowledge_Review__c != oldMap.get(oppId).Process_Program_Knowledge_Review__c) {
                String postBody = opp.Name + ' has completed their Program Knowledge Review.';
                postBody += '\n\nHere are the responses:';

                postBody += '\n\nHomeOwner vs. Other Options:';
                postBody += '\n' + opp.HomeOwner_vs_Other_Options__c;

                postBody += '\n\nInvestor % and Repayment:';
                postBody += '\n' + opp.Investor_Percentage_and_Repayment_Amo__c;

                postBody += '\n\nRemodeling Adjustment:';
                postBody += '\n' + opp.Remodeling_Adjustment__c;

                postBody += '\n\nDeferred Maintenance:';
                postBody += '\n' + opp.Deferred_Maintenance__c;

                postBody += '\n\nSelling <3 Years:';
                postBody += '\n' + opp.Selling_3_Years__c;

                postBody += '\n\nAgreement Requirements:';
                postBody += '\n' + opp.Agreement_Requirements__c;

                postBody += '\n\nMax Auth Debt:';
                postBody += '\n' + opp.Max_Auth_Debt__c;

                postBody += '\n\nUnexpected Circumstances:';
                postBody += '\n' + opp.Unexpected_Circumstances__c;

                postBody += '\n\nEnding the Agreement:';
                postBody += '\n' + opp.Ending_the_Agreement__c;

                postBody += '\n\nOption Contract Structure:';
                postBody += '\n' + opp.Option_Contract_Structure__c;

                postBody += '\n\n' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // IA Email Notification
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('IA_notification_for_completed_PKR'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email);
            }

            // HO- Appraisal Ordered
            if(opp.Appraisal_Ordered__c && opp.Appraisal_Ordered__c != oldMap.get(oppId).Appraisal_Ordered__c) {
                String postBody = 'The Appraisal has been ordered by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- Appraisal received
            if(opp.Appraisal_Received__c && opp.Appraisal_Received__c != oldMap.get(oppId).Appraisal_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The Appraisal has been received by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // IA Email Notification
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Appraisal_Received'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // HO- 2nd Appraisal Ordered
            if(opp.Second_Appraisal_Ordered__c && opp.Second_Appraisal_Ordered__c != oldMap.get(oppId).Second_Appraisal_Ordered__c) {
                String postBody = 'The second Appraisal has been ordered by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- 2nd Appraisal Received
            if(opp.Second_Appraisal_Received__c && opp.Second_Appraisal_Received__c != oldMap.get(oppId).Second_Appraisal_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The second Appraisal has been received by the Unison Processor,  ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Appraisal_Received'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // HO- Home Inspection Ordered
            if(opp.Home_Inspection_Ordered__c && opp.Home_Inspection_Ordered__c != oldMap.get(oppId).Home_Inspection_Ordered__c) {
                String postBody = 'The Home Inspection has been ordered for the ' + opp.Name + ' file.';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- Home Inspection Received
            if(opp.Home_Inspection_Received__c && opp.Home_Inspection_Received__c != oldMap.get(oppId).Home_Inspection_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The Home Inspection has been received for the ' + opp.Name + ' file.';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Home_Inspection_Received'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // HO- Property Report Ordered
            if(opp.Property_Report_Ordered__c && opp.Property_Report_Ordered__c != oldMap.get(oppId).Property_Report_Ordered__c) {
                String postBody = 'The Property Report has been ordered by the Unison Processor, ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // HO- Property Report Received
            if(opp.Property_Report_Received__c && opp.Property_Report_Received__c != oldMap.get(oppId).Property_Report_Received__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The Property Report has been received by the Unison Processor, ';
                postBody += '\n' + opp.UnisonProcessor__r.FirstName + ' ' + opp.UnisonProcessor__r.LastName + '.';

                postBody += '\n\nFile: ' + opp.Name;
                postBody += '\nProperty Address: ' + opp.Property_Address__c;
                postBody += '\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Title_Report_Recceived'), opp.Investment_Analyst2__c, oppId);
                email.setToAddresses(new List<String>{ opp.Owner.Email });
                emailsToSend.add(email);
            }

            // OAV Discount
            if(opp.OAV_Discount_Amount_f__c != null && opp.OAV_Discount_Amount_f__c != oldMap.get(oppId).OAV_Discount_Amount_f__c && opp.Investment_Analyst2__c != null) {
                // Email alert to IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('IA_OAV_Discount'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email);
            }

            // FINAL OAV
            if(opp.Final_OAV_Calculation__c != oldMap.get(opp.Id).Final_OAV_Calculation__c && opp.Investment_Analyst2__c != null && opp.UnisonProcessor__c != null) {
                String postBodyPS = 'A Final OAV ' + opp.Final_OAV_Calculation__c + ' has been set to the Original Agreed Value.';
                postBodyPS += '\n\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBodyPS, false);
                chatterPostsBatch.add(postToPS);

                String postBodyRecord = 'A Final OAV ' + opp.Final_OAV_Calculation__c + ' has been set to the Original Agreed Value for the ' + opp.Name + '.';
                postBodyRecord += '\n\nThe current OAV is ' + opp.Final_OAV_Calculation__c + ' now.';
                postBodyRecord += '\n\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBodyRecord, false);
                chatterPostsBatch.add(postToRecord);

                // Email to IA
                Messaging.SingleEmailMessage email_IA = sendEmail(emailTemplates.get('IA_Final_OAV'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email_IA);

                // Email TS Final OAV
                Messaging.SingleEmailMessage email_TS = sendEmail(emailTemplates.get('TS_Final_OAV'), opp.UnisonProcessor__c, oppId);
                emailsToSend.add(email_TS);
            }

            // Wire Date
            if(opp.Wire_to_Agent_Date__c != null && opp.Wire_to_Agent_Date__c != oldMap.get(opp.Id).Wire_to_Agent_Date__c && opp.Wire_to_Agent_Date__c >= system.today()) {
                String postBody = 'The Wire has been scheduled to send out today ' + opp.Name + ' file.';

                // Post to Record
                ConnectApi.BatchInput postToPS = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // DMA required
            if(opp.DMA_Required_f_del__c && opp.DMA_Required_f_del__c != oldMap.get(oppId).DMA_Required_f_del__c) {
                String postBody = 'It has been determined by Underwriting that a DMA is required for the ' + opp.Name + ' deal.';
                postBody += '\n\nThe estimated close of escrow is:';
                postBody += '\n' + opp.CloseDate;
                postBody += '\n\n' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                postBody += '\n\nDeal Details: ';
                postBody += '\n\nHome Value: ' + opp.Final_OAV_Calculation__c;
                postBody += '\nUnison Down Payment: ' + opp.Estimated_Funding_Amount__c;
                postBody += '\nCustomer Down Payment: ' + opp.Household_Down_Payment__c;
                postBody += '\nLoan Amount: ' + opp.Loan_Amount__c;
                postBody += '\nLoan Officer: ' + opp.Loan_Officer_Name__c;
                postBody += '\nLead Source: ' + opp.LeadSource;

                postBody += '\n\nProperty Address: ' + opp.Property_Address__c;

                postBody += '\n\nLink: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);
            }

            // OIP Updated TODO: figure out if we can set 'from' email
            if(opp.Estimated_Funding_Amount__c != oldMap.get(opp.Id).Estimated_Funding_Amount__c && opp.Investment_Analyst2__c != null) {
                String postBody = 'The OIP has been changed to ' + opp.Estimated_Funding_Amount__c + '. Please refer to the opportunities field history to see the previous value.';

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, false);
                chatterPostsBatch.add(postToRecord);

                // Email alert to IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('OIP_Changed'), OIP_CHANGED_RECIPIENT.Id, oppId);
                email.setReplyTo('info@myunison.com');
                email.setSenderDisplayName('Unison');
                emailsToSend.add(email);
            }

            // Close date updated
            if(opp.CloseDate != oldMap.get(opp.Id).CloseDate) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\nThe Close date for file ' + opp.Name + ' has been changed to ' + opp.CloseDate;
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: '  + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                /// Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Investor Percentage Change
            if(opp.Investor_Percentage__c != oldMap.get(opp.Id).Investor_Percentage__c && opp.Investment_Analyst2__c != null) {
                // Email alert to IA
                Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('IA_Investor_Percentage'), opp.Investment_Analyst2__c, oppId);
                emailsToSend.add(email);
            }

            // Price Ratio change
            if(opp.Pricing_Ratio__c != oldMap.get(opp.Id).Pricing_Ratio__c && opp.Investment_Analyst2__c != null) {
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();

                String postBody = '';
                postBody += '\n\nThis is a notification that the Pricing Ratio has been changed to ' + opp.Pricing_Ratio__c + ' for the ' + opp.Name + ' file.';

                // Post to Rayan
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBody, true);
                chatterPostsBatch.add(postToRecord);
            }

            // Max DTI change
            if(opp.Maximum_Authorized_DTI__c != oldMap.get(opp.Id).Maximum_Authorized_DTI__c) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\nA change has been made to a customer’s Maximum Authorized Debt. As such, the change will need to be reviewed with the Customer. Details are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBody += '\n\tName: ' + opp.Name;
                postBody += '\n\tNew Authorized Back-End DTI: ' + opp.Maximum_Authorized_DTI__c + '%';

                postBody += '\n\nRegards,';
                postBody += '\nSalesforce Admin';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Max Authorized LTV
            if(opp.Maximum_Authorized_LTV__c != oldMap.get(opp.Id).Maximum_Authorized_LTV__c) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\nA change has been made to a customer’s Maximum Authorized Debt. As such, the change will need to be reviewed with the Customer. Details are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBody += '\n\tName: ' + opp.Name;
                postBody += '\n\tNew Max Authorized LTV: ' + opp.Maximum_Authorized_LTV__c + '%';

                postBody += '\n\nRegards,';
                postBody += '\nSalesforce Admin';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Wire to Agent date set
            if(opp.Wire_to_Agent_Date__c != null && opp.Wire_to_Agent_Date__c != oldMap.get(oppId).Wire_to_Agent_Date__c) {
                String postBodyPS = 'Dear ' + opp.Owner.FirstName + ',';
                postBodyPS += '\n\nThe wire to agent date has been set.';
                postBodyPS += '\n\nDetails are as follows:';
                postBodyPS += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBodyPS += '\n\tName: ' + opp.Name;
                postBodyPS += '\n\tWire to agent date: ' + opp.Wire_to_Agent_Date__c;

                postBodyPS += '\n\nRegards,';
                postBodyPS += '\nSalesforce Admin';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBodyPS, false);
                chatterPostsBatch.add(postToPS);

                String postBodyRecord = 'The wire to agent date has been set.';
                postBodyRecord += '\n\nDetails are as follows:';
                postBodyRecord += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';
                postBodyRecord += '\n\tName: ' + opp.Name;
                postBodyRecord += '\n\tWire to agent date: ' + opp.Wire_to_Agent_Date__c;

                // Post to Record
                ConnectApi.BatchInput postToRecord = chatterPost(opp.Id, postBodyRecord, false);
                chatterPostsBatch.add(postToRecord);
            }

            // Final Approval
            if(opp.StageName == 'Final Approval' && opp.StageName != oldMap.get(oppId).StageName) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\n' + opp.Name + ' has been submitted for Final Approval.';
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Closing
            if(opp.StageName == 'Closing' && opp.StageName != oldMap.get(oppId).StageName) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\n' + opp.Name + ' is now in the Closing stage.';
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }

            // Post-Closing
            if(opp.StageName == 'Post-Closing' && opp.StageName != oldMap.get(oppId).StageName) {
                String postBody = 'Dear ' + opp.Owner.FirstName + ',';
                postBody += '\n\n' + opp.Name + ' is funded won and now in the Post Closing stage.';
                postBody += '\n\nDetails are as follows:';
                postBody += '\n\n\tOpportunity #: ' + ORG_URL + '/lightning/r/Opportunity/' + opp.Id + '/view';

                // Post to PS
                ConnectApi.BatchInput postToPS = chatterPost(opp.OwnerId, postBody, false);
                chatterPostsBatch.add(postToPS);
            }
        }
        // Finally send email messages
        if(!emailsToSend.isEmpty()) {
            if(!Test.isRunningTest()) {
                Messaging.sendEmail((List<Messaging.Email>) emailsToSend);
            }
        }
        // Finally post to chatter
        if(!chatterPostsBatch.isEmpty()) {
            if(!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostsBatch);
            }
        }
    }

    // Generate Chatter post
    private static ConnectApi.BatchInput chatterPost(Id parentId, String body, Boolean hasMention) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        if(hasMention) {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            //  mentionSegmentInput.id = MENTION_RAYAN.Id;
            // messageBodyInput.messageSegments.add(mentionSegmentInput);

            textSegmentInput.text = ',\n\n' + body;
            messageBodyInput.messageSegments.add(textSegmentInput);
        } else {
            textSegmentInput.text = body;
            messageBodyInput.messageSegments.add(textSegmentInput);
        }

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentId;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }

    private static Messaging.SingleEmailMessage sendEmail(Id templateId, Id whoId, Id whatId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage renderedTemplate = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
        String emailSubject = renderedTemplate.getSubject();
        String emailTextBody = renderedTemplate.getHtmlBody();
        mail.setTargetObjectId(whoId);
        mail.setHtmlBody(emailTextBody);
        mail.setSubject(emailSubject);
        mail.setSaveAsActivity(false);
        return mail;
    }
}