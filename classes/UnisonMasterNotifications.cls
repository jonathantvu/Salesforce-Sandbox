/**
 * Created by Eliot Rojas on 6/26/2019.
 */

global with sharing class UnisonMasterNotifications {
    public static boolean postStipulations=true;
    private static List<ConnectApi.BatchInput> chatterPostsBatch = new List<ConnectApi.BatchInput>();

    private static void PostItToChatter()
    {
        if (!chatterPostsBatch.isEmpty()) {
            if (!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostsBatch);
                chatterPostsBatch.clear();
            }
        }
    }
    public static void ManageNotificationsForSuccessFactorStatusChanges(List<Success_Factor__c> newList, Map<Id, Success_Factor__c> oldMap) {
        Set<Id> successFactorIds = new Set<Id>();
        for (Success_Factor__c sf : newList) {
            successFactorIds.add(sf.Id);
        }
        for (Success_Factor__c sf : [
                SELECT Id, Name, Success_Factor__c, Status__c,
                        Opportunity__c, Opportunity__r.Id, Opportunity__r.OwnerId,
                        Opportunity__r.UnisonProcessor__c, Opportunity__r.Investment_Analyst2__c,
                        Opportunity__r.Post_Close_Specialist__c, Opportunity__r.Sales_Director__c, Opportunity__r.Final_OAV_Calculation__c
                FROM Success_Factor__c
                WHERE Id IN :successFactorIds
        ]) {
            // Success Factor Status Changes
            if (sf.Status__c != oldMap.get(sf.Id).Status__c && sf.Opportunity__c != null) {
                String newValue = sf.Status__c;
                String oldValue = oldMap.get(sf.Id).Status__c;
                if(oldValue == 'Requirement Blocked') { oldValue = 'Blocked'; }
                if(newValue == 'Requirement Blocked') { newValue = 'Blocked'; }
                if (oldValue == '' || oldValue == null) { oldValue = '--None--'; }
                if (newValue == '' || newValue == null) { newValue = '--None--'; }
                ChatterPost(sf.Opportunity__c, 'The ' + sf.Success_Factor__c + ' status has changed from ' + oldValue + ' to ' + newValue,
                        getUserIds(sf.Opportunity__r, false, false, false, false, false, false, false));
            }

            /*// Final OAV Determined, commented for: https://unison-technology.atlassian.net/browse/BUS-155110025
            if (sf.Success_Factor__c == 'OAV' && sf.Status__c != oldMap.get(sf.Id).Status__c && sf.Status__c == 'Completed') {
                ChatterPost(sf.Opportunity__c, 'The Final OAV has been set by the Investment Analyst at $' + sf.Opportunity__r.Final_OAV_Calculation__c.format() + ' (automated message).',
                        getUserIds(sf.Opportunity__r, true, true, false, true, false, false, false));
            }*/
        }

        // Finally post to chatter
        PostItToChatter();
    }

    public static void ManageNotificationsForProjectTasks(List<Project_Task__c> lstReqs) {
        Set<Id> userIds = new Set<Id>();
        List<ConnectApi.BatchInput> chatterPostsBatch = new List<ConnectApi.BatchInput>();
        system.debug('Start for ManageNotificationsForProjectTasks');
        system.debug(lstReqs);
        Map<String, EOS_Project_Tasks__mdt> pTaskMap = new Map<String, EOS_Project_Tasks__mdt>();
        Set<String> taskCodes = new Set<String>();
        Set<Id> projectTaskIds = new Set<Id>();
        for (Project_Task__c pTask : lstReqs) {
            projectTaskIds.add(pTask.Id);
            if (pTask.Code__c != null) {
                taskCodes.add(pTask.Code__c);
            }
        }

        for (EOS_Project_Tasks__mdt eosRequirement : getEOSTasks(taskCodes)) {
            pTaskMap.put(eosRequirement.MasterLabel, eosRequirement);
        }

        for (Project_Task__c pTask : [
                SELECT Id, Name, Code__c, Opportunity__c, Opportunity__r.OwnerId,
                        Opportunity__r.Investment_Analyst2__c, Opportunity__r.UnisonProcessor__c, Opportunity__r.Post_Close_Specialist__c,
                        Opportunity__r.Sales_Director__c, Requirement__c, /*Completed__c*/ status__c
                FROM Project_Task__c
                WHERE Id IN :projectTaskIds
        ]) {
            /*Caro Veliz: BUS-155110073*/
            //if (pTask.Opportunity__c != null && pTask.Code__c != null && pTask.Completed__c) {
            if (pTask.Opportunity__c != null && pTask.Code__c != null && pTask.Status__c == 'Completed'){
                EOS_Project_Tasks__mdt projectTaskMDT = pTaskMap.get(pTask.Code__c);
                if(projectTaskMDT != null) {
                    if (projectTaskMDT.Chatter_Post__c) {
                        userIds = getUserIds(pTask.Opportunity__r,
                                projectTaskMDT.PS_Mention__c,
                                projectTaskMDT.TS_Mention__c,
                                projectTaskMDT.IA_Mention__c,
                                projectTaskMDT.RM_Mention__c,
                                projectTaskMDT.PCS_Mention__c,
                                false, false);
                        /* TODO: To be confirmed
                        if(projectTaskMDT.QC_Mention__c) {}
                        if(projectTaskMDT.Client_Mention__c) {}*/
                        ChatterPost(pTask.Opportunity__c, projectTaskMDT.Notification_Message__c, userIds);
                    }
                }
            }
        }

        // Finally post to chatter
        PostItToChatter();
    }

    public static void ManageNotificationsForRequirements(List<Current_Conditions__c> lstReqs, Map<Id, Current_Conditions__c> oldMap, Boolean forceNotification, String messageAction) {
        Set<Id> userIds = new Set<Id>();
        List<ConnectApi.BatchInput> chatterPostsBatch = new List<ConnectApi.BatchInput>();
        system.debug('Start for ManageNotificationsForRequirements');
        system.debug(lstReqs);
        Map<String, Opportunity> requirementOpportunityMap = new Map<String, Opportunity>();
        Map<String, EOS_Requirements__mdt> eosRequirementsMap = new Map<String, EOS_Requirements__mdt>();
        Set<String> reqCodes = new Set<String>();
        Set<Id> requirementIds = new Set<Id>();
        for (Current_Conditions__c req : lstReqs) {
            requirementIds.add(req.Id);
            if (req.Code__c != null) {
                reqCodes.add(req.Code__c);
            }
        }

        for (EOS_Requirements__mdt eosRequirement : getEOSRequirements(reqCodes)) {
            eosRequirementsMap.put(eosRequirement.MasterLabel, eosRequirement);
        }

        for (Current_Conditions__c req : [SELECT Id, Name, Code__c, Opportunity__c, Opportunity__r.OwnerId,
                Opportunity__r.Investment_Analyst2__c, Opportunity__r.UnisonProcessor__c, Opportunity__r.Post_Close_Specialist__c,
                Opportunity__r.Sales_Director__c, Requirement__c, Status__c, Type__c, Reason__c
        FROM Current_Conditions__c
        WHERE Id IN :requirementIds]) {
            if (req.Code__c != null && req.Opportunity__c != null) {
                EOS_Requirements__mdt currentRequirement = eosRequirementsMap.get(req.Code__c);
                String requirementType;
                if(currentRequirement != null) {
                    requirementType = currentRequirement.Type__c;
                    if (!forceNotification && currentRequirement.Chatter_Post__c) {
                        userIds = getUserIds(req.Opportunity__r,
                                currentRequirement.PS_Mention__c,
                                currentRequirement.TS_Mention__c,
                                currentRequirement.IA_Mention__c,
                                currentRequirement.RM_Mention__c,
                                currentRequirement.PCS_Mention__c,
                                false, false);
                        /* TODO: To be confirmed
                        if(currentRequirement.QC_Mention__c) {}
                        if(currentRequirement.Client_Mention__c) {}*/
                        forceNotification = true;
                    }
                    if (forceNotification) {
                        if(messageAction == 'updated') {
                            String newValue = req.Status__c;
                            String oldValue = oldMap.get(req.Id).Status__c;
                            if(oldValue == 'Document Received, In progress') { oldValue = 'In Progress'; }
                            if(oldValue == 'Document Ready for Review') { oldValue = 'Ready for Review'; }
                            if(oldValue == '' || oldValue == null) { oldValue = '--None--'; }
                            if(newValue == '' || newValue == null) { newValue = '--None--'; }
                            system.debug(req);
                            system.debug(postStipulations);
                            if ((requirementType != 'Stipulation') || ( postStipulations && requirementType == 'Stipulation')) {
                                ChatterPost(req.Opportunity__c, 'The ' + req.Requirement__c + ' status has been ' + messageAction + ' from ' + oldValue + ' to ' + newValue, userIds);
                            }
                        } else {
                            // https://unison-technology.atlassian.net/browse/BUS-155110143
                            if(req.Reason__c != null && (requirementType == 'Data Request' || ( postStipulations && requirementType == 'Stipulation' ))) {
                                ChatterPost(req.Opportunity__c, ' A new ' + requirementType + ' for ' + req.Requirement__c + ' has been created due to ' + req.Reason__c + ' (automated message)', userIds);
                            } else {
                                if ( requirementType != 'Stipulation' || postStipulations && requirementType == 'Stipulation') {
                                    ChatterPost(req.Opportunity__c, req.Type__c + ' ' + req.Requirement__c + ' has been ' + messageAction + '. (automated message)', userIds);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Finally post to chatter
        PostItToChatter();
    }


    webservice static string ManageNotificationsForStipulations( string OppID,
                                                            string message) {
        system.debug(OppID);
        system.debug(message);
        ChatterPost(OppID, message,  new Set<Id>());
        PostItToChatter();
        return 'Posted to chatter';
    }

    public static void ManageNotificationsForOpportunityFundedDeal(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        system.debug('Start for ManageNotificationsForOpportunityFundedDeal');
        system.debug(newList);

        for (Opportunity opp : newList) {
            if ((opp.Wire_to_Agent_Date__c != oldMap.get(opp.Id).Wire_to_Agent_Date__c) && (opp.Wire_to_Agent_Date__c >= Date.today())) {
                ChatterPost(opp.Id, 'Wire date has been set  ' + opp.Wire_to_Agent_Date__c +  '  (automated message).',
                        getUserIds(opp, true, false, false, true, false, false, false));
            }

            // Finally post to chatter
            PostItToChatter();
        }
    }

    public static void ManageNotificationsForOpportunityStage(List<Opportunity> newList) {
        system.debug('Start for ManageNotificationsForOpportunityStage');
        system.debug(newList);

        for (Opportunity opp : newList) {
            ChatterPost(opp.Id, 'The investment has moved from Submitted to Investment Due Diligence (automated message).',
                    getUserIds(opp, true, true, true, true, false, false, false));
            // Finally post to chatter
            PostItToChatter();
        }
    }

    public static void ManageNotificationsForOpportunityMad(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        for (Opportunity opp : newList) {
            system.debug('++ oldMap MAD ' + oldMap.get(opp.Id).MAD__c);
            system.debug('++ newList MAD ' + opp.MAD__c);

            //TriggrUtility.RunTwice = (oldMap.get(opp.Id).Maximum_Authorized_LTV__c != opp.Maximum_Authorized_LTV__c);


            //Caro Veliz: To implement:
            // https://unison-technology.atlassian.net/browse/BUS-155110400
            //End user doesn't want to see MAD notifications
            /*
            if
                            (oldMap.get(opp.Id).MAD__c != opp.MAD__c) {
                ChatterPost(opp.Id, 'The MAD Percentage has been updated from ' + oldMap.get(opp.Id).MAD__c + ' to ' + opp.MAD__c + ' (automated message)',
                        getUserIds(opp, true, true, true, true, false, false, false));
            }*/

            if (oldMap.get(opp.Id).Program_Floor__c != opp.Program_Floor__c) {
                ChatterPost(opp.Id, 'The Program Floor has been updated from ' + oldMap.get(opp.Id).Program_Floor__c + ' to ' + opp.Program_Floor__c  + ' (automated message)',
                        getUserIds(opp, true, true, true, true, false, false, false));
            }

        }
        PostItToChatter();

    }



    public static void ManageNotificationsForOpportunityFieldChanges(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        system.debug('Start for ManageNotificationsForFieldChanges');
        system.debug(newList);
        Id HomeOwnerRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        ManageNotificationsForOpportunityMad( newList, oldMap);
        ManageNotificationsForOpportunityFundedDeal(newList, oldMap);
        system.debug('++ TriggrUtility.RunOnce? UnisonMasterNotifications ' + TriggrUtility.RunOnce);
        if (Test.isRunningTest()) (TriggrUtility.RunOnce=true);

        if(TriggrUtility.RunOnce) {
            for (Opportunity opp : newList) {
                // PKR Completed
                if (opp.Process_Program_Knowledge_Review__c != oldMap.get(opp.Id).Process_Program_Knowledge_Review__c && opp.Process_Program_Knowledge_Review__c) {
                    ChatterPost(opp.Id, 'The Program Knowledge Review has been marked complete (automated message).',
                            getUserIds(opp, true, true, false, true, false, false, false));
                }

                // Close Date Changes
                if (opp.CloseDate != oldMap.get(opp.Id).CloseDate) {
                    ChatterPost(opp.Id, 'The Estimated Close Date has been updated to ' +  opp.CloseDate.format(),
                            getUserIds(opp, false, false, false, false, false, false, false));
                }

                // IA Assignment
                if (opp.Investment_Analyst2__c != oldMap.get(opp.Id).Investment_Analyst2__c && opp.Investment_Analyst2__c != null) {
                    ChatterPostCustom(opp.Id, 'Deal Team Update: ',
                            getUserIds(opp, true, true, false, true, false, false, false),
                            getUserIds(opp, false, false, true, false, false, false, false), 'has been assigned as the Investment Analyst (automated message).');
                }

                // PCS Assignment
                if (opp.Post_Close_Specialist__c != oldMap.get(opp.Id).Post_Close_Specialist__c && opp.Post_Close_Specialist__c != null) {
                    ChatterPostCustom(opp.Id, 'Deal Team Update: ',
                            getUserIds(opp, false, true, false, false, false, false, false),
                            getUserIds(opp, false, false, false, false, true, false, false), 'has been assigned as the Post-Close Specialist (automated message).');
                }

                // PS Assignment
                if (opp.OwnerId != oldMap.get(opp.Id).OwnerId && opp.OwnerId != null) {
                    ChatterPostCustom(opp.Id, 'Deal Team Update: ',
                            getUserIds(opp, false, true, true, true, false, false, false),
                            getUserIds(opp, true, false, false, false, false, false, false), 'has been assigned as the Program Specialist (automated message).');
                }

                // RM Assignment
                if (opp.Sales_Director__c != oldMap.get(opp.Id).Sales_Director__c && opp.Sales_Director__c != null) {
                    ChatterPostCustom(opp.Id, 'Deal Team Update: ',
                            getUserIds(opp, true, true, true, false, false, false, false),
                            getUserIds(opp, false, false, false, true, false, false, false), 'has been assigned as the Regional Manager (automated message).');
                }

                // TS Assignment
                if (opp.UnisonProcessor__c != oldMap.get(opp.Id).UnisonProcessor__c && opp.UnisonProcessor__c != null) {
                    ChatterPostCustom(opp.Id, 'Deal Team Update: ',
                            getUserIds(opp, true, false, true, true, false, false, false),
                            getUserIds(opp, false, true, false, false, false, false, false), 'has been assigned as the Transaction Specialist (automated message).');
                }

                // OIP Confirmed
                if (opp.OIP_Confirmed__c != oldMap.get(opp.Id).OIP_Confirmed__c && opp.OIP_Confirmed__c) {
                    ChatterPost(opp.Id, '- The OIP has been confirmed by the customer (automated message)', getUserIds(opp, true, true, true, false, false, false, false));
                }

                // Wire Date Update, commented due to having another notification already in place: https://unison-technology.atlassian.net/browse/BUS-155110426
                /*if (opp.Wire_to_Agent_Date__c != oldMap.get(opp.Id).Wire_to_Agent_Date__c) {
                    string message = '';
                    if (opp.Wire_to_Agent_Date__c == null )
                        message = '- empty date -';
                    else message = opp.Wire_to_Agent_Date__c.format();
                    ChatterPost(opp.Id, 'The Wire to Agent Date has been updated to ' + message ,
                            getUserIds(opp, false, false, false, false, false, false, false));
                }*/

                //https://unison-technology.atlassian.net/browse/BUS-155110142
                if (oldMap.get(opp.Id).Approval_Status__c != opp.Approval_Status__c && opp.Approval_Status__c == 'Approved') {
                    Decimal pricingRatio = opp.Pricing_Ratio__c != null ? opp.Pricing_Ratio__c : 0;
                    Decimal MIN_OIP = opp.OIP_Minimum__c != null ? opp.OIP_Minimum__c : 0;
                    Decimal MAX_OIP = opp.OIP_Maximum__c != null ? opp.OIP_Maximum__c : 0;
                    Decimal finalOAV = opp.Final_OAV_Calculation__c != null ? opp.Final_OAV_Calculation__c : 0;
                    Decimal madPercentage = opp.MAD__c != null ? opp.MAD__c : 0;
                    Decimal madAmount = opp.Maximum_Authorized_Debt_Final__c != null ? opp.Maximum_Authorized_Debt_Final__c : 0;
                    Decimal dmaCount = opp.DMA_Count__c != null ? opp.DMA_Count__c : 0;
                    String programFloor = opp.Program_Floor__c;
                    String postBody = 'The ' + opp.Name + ' opportunity has been approved by Investment Management.';
                    postBody += '\n\nProgram: ' + opp.Record_Type_Name__c;
                    postBody += '\n\nPricing Ratio: ' + pricingRatio.format();
                    if(opp.RecordTypeId == HomeOwnerRTId) {
                        postBody += '\n\nApproved OIP Range: $' + MIN_OIP.format() + ' to $' + MAX_OIP.format();
                    }
                    postBody += '\n\nFinal OAV: $' + finalOAV.format();
                    postBody += '\n\nMAD Percentage: ' + madPercentage.format() + '%';
                    postBody += '\n\nMAD Amount: $' + madAmount.format();
                    postBody += '\n\nDMA Count: ' + dmaCount;
                    postBody += '\n\nProgram Floor: ' + programFloor;
                    ChatterPost(opp.Id, postBody,
                            getUserIds(opp, true, true, true, true, false, false, false));
                }

                if (oldMap.get(opp.Id).Approval_Status__c != opp.Approval_Status__c && opp.Approval_Status__c == 'Denied') {
                    ChatterPost(opp.Id, 'The deal has been rejected by Investment Management and needs further review (automated message).',
                            getUserIds(opp, true, true, true, true, false, false, false));
                }

                // https://unison-technology.atlassian.net/browse/BUS-155110789
                if (oldMap.get(opp.Id).IA_Decline_Status__c != opp.IA_Decline_Status__c && opp.IA_Decline_Status__c == 'Approved - Continue to Closed Lost') {
                    if(opp.PS_Decline_Reasons__c != null) {
                        String postBody = 'This deal has been deemed insufficient by the Investment Analysis team for the following reasons:';
                        postBody += '\n\n' + opp.PS_Decline_Reasons__c;
                        ChatterPost(opp.Id, postBody,
                                getUserIds(opp, true, true, false, false, false, false, false));
                    }
                }

                if (oldMap.get(opp.Id).StageName == 'Closing' && opp.StageName == 'Post-Closing') {
                    ChatterPost(opp.Id, 'The investment has moved from Closing to Post-Closing (automated message).',
                            getUserIds(opp, true, true, true, true, true, false, false));
                }

                if (oldMap.get(opp.Id).StageName == 'Final Approval' && opp.StageName == 'Closing') {
                    ChatterPost(opp.Id, 'The investment has moved from Final Approval to Closing (automated message).',
                            getUserIds(opp, false, true, false, false, false, false, false));
                }

                if (oldMap.get(opp.Id).StageName == 'Investment Due Diligence' && opp.StageName == 'Final Approval') {
                    ChatterPost(opp.Id, 'The investment has moved from Investment Due Diligence to Final Approval.',
                            getUserIds(opp, false, false, false, false, false, false, false));
                }

                if (oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Lost') {
                    ChatterPost(opp.Id, 'The investment has moved to Closed Lost (automated message).',
                            getUserIds(opp, true, true, true, true, true, false, false));
                }

                if (oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Investment Due Diligence' && oldMap.get(opp.Id).StageName != 'Ready for Ops') {
                    ChatterPost(opp.Id, 'The investment has moved to Investment Due Diligence (automated message).',
                            getUserIds(opp, false, true, true, false, false, false, false));
                }

                if (oldMap.get(opp.Id).Estimated_Funding_Amount__c != opp.Estimated_Funding_Amount__c) {
                    ChatterPost(opp.Id, 'The Gross OIP has been updated from $' + oldMap.get(opp.Id).Estimated_Funding_Amount__c.format() + ' to $' + opp.Estimated_Funding_Amount__c.format() + ' (automated message)',
                            getUserIds(opp, true, true, true, true, false, false, false));
                }


                if (oldMap.get(opp.Id).Pricing_Ratio__c != opp.Pricing_Ratio__c) {
                    ChatterPost(opp.Id, 'The Pricing Ratio has been updated from ' + oldMap.get(opp.Id).Pricing_Ratio__c.format() + ' to ' + opp.Pricing_Ratio__c.format() + ' (automated message)',
                            getUserIds(opp, true, true, true, true, false, false, false));
                }


                // TODO: confirm if this is the right approach or if we'll need time based automation to notify when Wire To Agent Date arrives.
                /* if(oldMap.get(opp.Id).Wire_to_Agent_Date__c != opp.Wire_to_Agent_Date__c && opp.Wire_to_Agent_Date__c == Date.today() ) {
                    ChatterPost(opp.Id, 'Wire Data to Agent funded today [' + Date.today().toString() + ']' , getUserIds( opp, true, true,  false, true, false, false, false) );
                }*/
            }
            system.debug('++ CHATTERS TO POST ' + chatterPostsBatch);
            // Finally post to chatter
            PostItToChatter();
            TriggrUtility.RunOnce = false;
        }
    }


    private static void ChatterPost(Id parentId, String message, Set<Id> userIds) {
        ConnectApi.BatchInput postToPS = makeChatterPost(parentId, message, userIds);
        chatterPostsBatch.add(postToPS);
    }

    private static void ChatterPostCustom(Id parentId, String message, Set<Id> userIds, Set<Id> secondMentionIds, String secondMessage) {
        ConnectApi.BatchInput postToPS = chatterPostCustomMentions(parentId, message, userIds, secondMentionIds, secondMessage);
        chatterPostsBatch.add(postToPS);
    }

    private static ConnectApi.BatchInput chatterPostCustomMentions(Id parentId, String message, Set<Id> userIds, Set<Id> secondMentionIds, String secondMessage) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput;

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        for (Id userId : userIds) {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            textSegmentInput = new ConnectApi.TextSegmentInput();
            mentionSegmentInput.Id = userId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            textSegmentInput.text = ' ';
            messageBodyInput.messageSegments.add(textSegmentInput);
        }

        textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = ' ' + message;
        messageBodyInput.messageSegments.add(textSegmentInput);

        for (Id userId : secondMentionIds) {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            textSegmentInput = new ConnectApi.TextSegmentInput();
            mentionSegmentInput.Id = userId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        }

        ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
        textSegmentInput2.text = ' ' + secondMessage;
        messageBodyInput.messageSegments.add(textSegmentInput2);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentId;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }

    private static ConnectApi.BatchInput makeChatterPost(Id parentId, String message, Set<Id> userIds) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput;

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        for (Id userId : userIds) {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            textSegmentInput = new ConnectApi.TextSegmentInput();
            mentionSegmentInput.Id = userId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            textSegmentInput.text = ' ';
            messageBodyInput.messageSegments.add(textSegmentInput);
        }

        textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = ' ' + message;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentId;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }

    private static Set<Id> getUserIds(Opportunity opp, boolean PS_mention, boolean TS_mention, boolean IA_mention, boolean RM_mention, boolean PCS_mention, boolean QC_mention, boolean Client_mention) {
        Set<Id> userIds = new Set<Id>();

        if (PS_Mention) {
            userIds.add(opp.OwnerId);
        }
        if (TS_Mention) {
            if (opp.UnisonProcessor__c != null) {
                userIds.add(opp.UnisonProcessor__c);
            }
        }
        if (IA_Mention) {
            if (opp.Investment_Analyst2__c != null) {
                userIds.add(opp.Investment_Analyst2__c);
            }
        }
        if (PCS_Mention) {
            if (opp.Post_Close_Specialist__c != null) {
                userIds.add(opp.Post_Close_Specialist__c);
            }
        }
        if (RM_Mention) {
            if (opp.Sales_Director__c != null) {
                userIds.add(opp.Sales_Director__c);
            }
        }
        return userIds;
    }



/*
    // Generate Chatter post that does not need a mention
    private static ConnectApi.BatchInput chatterPostWithoutMention(Id parentId, String body, Boolean hasMention) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = body;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentId;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }

    // Generate Chatter post that has a mention
    private static ConnectApi.BatchInput chatterPostWithMention(Id parentId, Id investmentAnalystID, Id transactionSpecialistID) {
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

    // Send Email message without having an email template, just include the email body, subject and recipients.
    private static Messaging.SingleEmailMessage sendEmailWithoutTemplate(String subject, string body, List<String> recipients) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailSubject = subject;
        String emailTextBody = body;
        mail.setSubject(emailSubject);
        mail.setHtmlBody(emailTextBody);
        mail.setToAddresses(recipients);
        return mail;
    }

    // Send Email message when having an email template
    private static Messaging.SingleEmailMessage sendEmailWithTemplate(Id templateId, Id whoId, Id whatId) {
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
*/
    @TestVisible private static List<EOS_Requirements__mdt> getEOSRequirements(Set<String> reqCodes) {
        return [
                Select MasterLabel,Category__c,Type__c,Internal_vs_External__c,
                        Applicant_Type__c,Success_Factor__c,
                        RequirementName__c,RSI_Eligible__c, Chatter_Email__c, Custom_Email__c,
                        Chatter_Post__c, Client_Mention__c, Email_Template__c, IA_Mention__c, PCS_Mention__c,
                        PS_Mention__c, QC_Mention__c, RM_Mention__c, TS_Mention__c
                from EOS_Requirements__mdt
                where MasterLabel IN:reqCodes
        ];
    }

    @TestVisible private static List<EOS_Project_Tasks__mdt> getEOSTasks(Set<String> taskCodes) {
        return [
                Select MasterLabel, Requirement_Code__c, Project_Task_Name__c, Role__c, Chatter_Email__c, Custom_Email__c,
                        Chatter_Post__c, Client_Mention__c, Email_Template__c, IA_Mention__c, PCS_Mention__c,
                        PS_Mention__c, QC_Mention__c, RM_Mention__c, TS_Mention__c, Notification_Message__c
                from EOS_Project_Tasks__mdt
                where MasterLabel IN :taskCodes
        ];
    }
}