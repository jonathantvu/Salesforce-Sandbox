/**
 * Created by Eliot Rojas on 5/1/2019.
 */

public with sharing class ProjectTasksDocumentNotification {
    // CONSTANTS
    private static final Set<String> TEMPLATE_NAMES = new Set<String>{ 'Pest_Inspection_Received', 'Certificate_of_Occupancy_Received',
            'Appraisal_1004D_Received', 'Natural_Hazard_Disclosure_Received', 'HOA_Questionnaire_Received', 'Vesting_Addendum_Received',
            'Hazard_Insurance_Received', 'Lender_Final_1003_Received', 'Lender_Final_1008_Received'};
    private static final List<EmailTemplate> EMAIL_TEMPLATES = [SELECT Id, DeveloperName, BrandTemplateId, IsActive, Body, Subject, HtmlValue
                                                                FROM EmailTemplate WHERE DeveloperName IN : TEMPLATE_NAMES];

    // Process Email alerts (ON INSERT)
    public static void notifyPS(List<Project_Task__c> newList) {
        Set<Id> ptIds = new Set<Id>();
        for(Project_Task__c opp : newList) {
            ptIds.add(opp.Id);
        }

        List<FeedItem> chatterPosts = new List<FeedItem>();
        List<ConnectApi.BatchInput> chatterPostsBatch = new List<ConnectApi.BatchInput>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, Project_Task__c> ptMap = new Map<Id, Project_Task__c>([SELECT Id, Name, Code__c, Completed__c, Requirement__c, Requirement__r.Requirement__c, Requirement__r.Name,
                                                                    Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                                                                    Requirement__r.Success_Factor__r.Lead__r.OwnerId, Requirement__r.Opportunity__c, Requirement__r.Opportunity__r.Name,
                                                                    Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId,
                                                                    Requirement__r.Opportunity__r.Investment_Analyst2__c,
                                                                    Requirement__r.Opportunity__r.UnisonProcessor__c
                                                                    FROM Project_Task__c WHERE Id IN : ptIds]);
        Map<String, Id> emailTemplates = new Map<String, Id>();
        for(EmailTemplate template : EMAIL_TEMPLATES) {
            emailTemplates.put(template.DeveloperName, template.Id);
        }

        for(string ptId : ptMap.keySet()) {
            if(ptMap.get(ptId).Requirement__r.Opportunity__r != null) {
                Id oppId = ptMap.get(ptId).Requirement__r.Opportunity__c;
                Id accountOwnerId = ptMap.get(ptId).Requirement__r.Opportunity__r.Account.OwnerId;
                Id investmentAnalystID = ptMap.get(ptId).Requirement__r.Opportunity__r.Investment_Analyst2__c;
                Id transactionSpecialistID = ptMap.get(ptId).Requirement__r.Opportunity__r.UnisonProcessor__c;
                string reqName = ptMap.get(ptId).Requirement__r.Name;
                string oppName = ptMap.get(ptId).Requirement__r.Opportunity__r.Name;
                Project_Task__c pt = ptMap.get(ptId);
                // RSI letter is PT is checked off
                if(pt.Code__c == 'T10182' && pt.Completed__c) {
                    // Post to Record
                    if(investmentAnalystID != null && transactionSpecialistID != null) {
                        ConnectApi.BatchInput postToRecord = chatterPost(oppId, investmentAnalystID, transactionSpecialistID);
                        chatterPostsBatch.add(postToRecord);
                    }
                }
                // Pest Inspection
                if(pt.Code__c == 'Task-258' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Pest_Inspection_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Certificate of Occupancy
                if(pt.Requirement__r.Requirement__c == 'Certificate of Occupancy' && pt.Requirement__r.Status__c == '') {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Certificate_of_Occupancy_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    email.setToAddresses(new List<String>{ pt.Requirement__r.Success_Factor__r.OwnerId, pt.Requirement__r.Success_Factor__r.Lead__r.OwnerId });
                    emailsToSend.add(email);
                }

                // Appraisal - 1004D
                if(pt.Code__c == 'Task-276' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Appraisal_1004D_Received'), accountOwnerId, ptId);
                    emailsToSend.add(email);
                }

                // Natural Hazard Disclosure
                if(pt.Code__c == 'Task-051' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Natural_Hazard_Disclosure_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // HOA Questionaire
                if(pt.Code__c == 'Task-255' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('HOA_Questionnaire_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Vesting Addendum
                if(pt.Code__c == 'Task-042' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Vesting_Addendum_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Hazard Insurance
                if(pt.Requirement__r.Requirement__c == 'Hazard Insurance' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Hazard_Insurance_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Lender Final 1003
                if(pt.Code__c == 'Task-248' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Lender_Final_1003_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Lender Final 1008
                if(pt.Code__c == 'Task-045' && pt.Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Lender_Final_1008_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }
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


    // Process Email alerts (ON UPDATE)
    public static void notifyPS(List<Project_Task__c> newList, Map<Id, Project_Task__c> oldMap) {
        Set<Id> ptIds = new Set<Id>();
        for(Project_Task__c opp : newList) {
            ptIds.add(opp.Id);
        }

        List<FeedItem> chatterPosts = new List<FeedItem>();
        List<ConnectApi.BatchInput> chatterPostsBatch = new List<ConnectApi.BatchInput>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, Project_Task__c> ptMap = new Map<Id, Project_Task__c>([SELECT Id, Name, Code__c, Completed__c, Requirement__c, Requirement__r.Requirement__c, Requirement__r.Name,
                                                                    Requirement__r.Success_Factor__c, Requirement__r.Success_Factor__r.OwnerId,
                                                                    Requirement__r.Success_Factor__r.Lead__r.OwnerId, Requirement__r.Opportunity__c, Requirement__r.Opportunity__r.Name,
                                                                    Requirement__r.Status__c, Requirement__r.Opportunity__r.Account.OwnerId,
                                                                    Requirement__r.Opportunity__r.Investment_Analyst2__c,
                                                                    Requirement__r.Opportunity__r.UnisonProcessor__c
                                                                    FROM Project_Task__c WHERE Id IN : ptIds]);
        Map<String, Id> emailTemplates = new Map<String, Id>();
        for(EmailTemplate template : EMAIL_TEMPLATES) {
            emailTemplates.put(template.DeveloperName, template.Id);
        }

        for(string ptId : ptMap.keySet()) {
            if(ptMap.get(ptId).Requirement__r.Opportunity__r != null) {
                Id oppId = ptMap.get(ptId).Requirement__r.Opportunity__c;
                Id accountOwnerId = ptMap.get(ptId).Requirement__r.Opportunity__r.Account.OwnerId;
                Id investmentAnalystID = ptMap.get(ptId).Requirement__r.Opportunity__r.Investment_Analyst2__c;
                Id transactionSpecialistID = ptMap.get(ptId).Requirement__r.Opportunity__r.UnisonProcessor__c;
                string reqName = ptMap.get(ptId).Requirement__r.Name;
                string oppName = ptMap.get(ptId).Requirement__r.Opportunity__r.Name;
                Project_Task__c pt = ptMap.get(ptId);
                // RSI letter is PT is checked off
                if(pt.Code__c == 'T10182' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    // Post to Record
                    if(investmentAnalystID != null && transactionSpecialistID != null) {
                        ConnectApi.BatchInput postToRecord = chatterPost(oppId, investmentAnalystID, transactionSpecialistID);
                        chatterPostsBatch.add(postToRecord);
                    }
                }
                // Pest Inspection
                if(pt.Code__c == 'Task-258' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Pest_Inspection_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Certificate of Occupancy
                if(pt.Requirement__r.Requirement__c == 'Certificate of Occupancy' && pt.Requirement__r.Status__c == '' && pt.Requirement__r.Status__c != oldMap.get(ptId).Requirement__r.Status__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Certificate_of_Occupancy_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    email.setToAddresses(new List<String>{ pt.Requirement__r.Success_Factor__r.OwnerId, pt.Requirement__r.Success_Factor__r.Lead__r.OwnerId });
                    emailsToSend.add(email);
                }

                // Appraisal - 1004D
                if(pt.Code__c == 'Task-276' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Appraisal_1004D_Received'), accountOwnerId, ptId);
                    emailsToSend.add(email);
                }

                // Natural Hazard Disclosure
                if(pt.Code__c == 'Task-051' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Natural_Hazard_Disclosure_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // HOA Questionaire
                if(pt.Code__c == 'Task-255' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('HOA_Questionnaire_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Vesting Addendum
                if(pt.Code__c == 'Task-042' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Vesting_Addendum_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Hazard Insurance
                if(pt.Requirement__r.Requirement__c == 'Hazard Insurance' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Hazard_Insurance_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Lender Final 1003
                if(pt.Code__c == 'Task-248' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Lender_Final_1003_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }

                // Lender Final 1008
                if(pt.Code__c == 'Task-045' && pt.Completed__c && pt.Completed__c != oldMap.get(ptId).Completed__c) {
                    Messaging.SingleEmailMessage email = sendEmail(emailTemplates.get('Lender_Final_1008_Received'), accountOwnerId, pt.Requirement__r.Opportunity__c);
                    emailsToSend.add(email);
                }
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

    // Generate Chatter post
    private static ConnectApi.BatchInput chatterPost(Id parentId, Id investmentAnalystID, Id transactionSpecialistID) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = 'Hi ';
        messageBodyInput.messageSegments.add(textSegmentInput);

        mentionSegmentInput.id = transactionSpecialistID;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        textSegmentInput2.text = ', \n\nThe RSI Letter has been populated by ';
        messageBodyInput.messageSegments.add(textSegmentInput2);

        mentionSegmentInput2.id = investmentAnalystID;
        messageBodyInput.messageSegments.add(mentionSegmentInput2);

        textSegmentInput3.text = ' and is now ready to be generated and sent to the customer.';
        messageBodyInput.messageSegments.add(textSegmentInput3);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentId;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }
}