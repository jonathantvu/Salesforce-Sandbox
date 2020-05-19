public class DelightedHelper {
    
    public static boolean skipCall = false;
    
    public static void SendSurveyLead(Id npmId, Id lId) {

        if (skipCall) return;
        
        Lead l = [SELECT Id, Email, Phone, Applicant_Full_Name__c, RecordTypeId, RecordType.Name, OwnerId, Status, tdc_tsw__SMS_Opt_out__c, Loss_Reason_Type__c, Delighted_Trigger_Status__c, Owner.Name FROM Lead WHERE Id = :lId];

        DelightedAPI.SendSurveyResponse resp = DelightedAPI.SendSurvey(l.Status == 'Closed Lost' ? 'Project' : 'Standard', l.Email, l.Applicant_Full_Name__c, l.Phone, l.OwnerId, l.RecordTypeId, l.RecordType.Name, 'lead', lId, l.Status, l.tdc_tsw__SMS_Opt_out__c, l.Loss_Reason_Type__c, l.Delighted_Trigger_Status__c, l.Owner.Name);

        if (resp.success) {
            l.Delighted_Survey_Sent__c = true;
            l.Delighted_Error__c = '';
            update l;
            
            Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
            npm.Id = npmId;
            npm.Delighted_Id__c = resp.id;
            npm.Status__c = 'Success';
            update npm;
        } else {
            if (resp.error.length() > 32767)
                resp.error = resp.error.substring(0, 32767);
            l.Delighted_Error__c = resp.error;
            update l;
            
            Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
            npm.Id = npmId;
            npm.Status__c = 'Error';
            update npm;
        }
    }

    public static void SendSurveyOpportunity(Id npmId, Id oId) {

        if (skipCall) return;
        
        Opportunity o = [SELECT Id, Applicant__r.Email, Applicant__r.Phone, Applicant__r.Name, RecordTypeId, RecordType.Name, OwnerId, StageName, SMS_Opt_out__c, Loss_Reason_Code__c, Delighted_Trigger_Status__c, Owner.Name FROM Opportunity WHERE Id = :oId];

        DelightedAPI.SendSurveyResponse resp = DelightedAPI.SendSurvey(o.StageName == 'Closed Lost' ? 'Project' : 'Standard', o.Applicant__r.Email, o.Applicant__r.Name, o.Applicant__r.Phone, o.OwnerId, o.RecordTypeId, o.RecordType.Name, 'opportunity', oId, o.StageName, o.SMS_Opt_out__c, o.Loss_Reason_Code__c, o.Delighted_Trigger_Status__c, o.Owner.Name);

        if (resp.success) {
            o.Delighted_Survey_Sent__c = true;
            o.Delighted_Error__c = '';
            update o;
            
            Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
            npm.Id = npmId;
            npm.Delighted_Id__c = resp.id;
            npm.Status__c = 'Success';
            update npm;
        } else {
            if (resp.error.length() > 32767)
                resp.error = resp.error.substring(0, 32767);
            o.Delighted_Error__c = resp.error;
            update o;
            
            Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
            npm.Id = npmId;
            npm.Status__c = 'Error';
            update npm;
        }

    }

    public static void SendSurveyFundedOpp(Opportunity o) {
        
        if (skipCall) return;

        DelightedAPI.SendSurveyResponse resp = DelightedAPI.SendSurvey('Funded_Opp', o.Applicant__r.Email, o.Applicant__r.Name, o.Applicant__r.Phone, o.OwnerId, o.RecordTypeId, o.RecordType.Name, 'opportunity', o.Id, o.StageName, o.SMS_Opt_out__c, o.Loss_Reason_Code__c, o.Delighted_Trigger_Status__c, o.Owner.Name);

        if (resp.success) {
            o.Delighted_Post_Closing_Sent__c = true;
            o.Delighted_Error__c = '';
            update o;
            
            Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
            npm.Opportunity__c = o.Id;
            npm.Delighted_Id__c = resp.id;
            insert npm;
        } else {
            if (resp.error.length() > 32767)
                resp.error = resp.error.substring(0, 32767);
            o.Delighted_Error__c = resp.error;
            update o;
        }
        
    }
    
	public static void SendSurveyLOContact(Contact con){

		DelightedAPI.SendSurveyResponse resp = DelightedAPI.SendLOSurvey(con.Email, con.Name, con.Phone, con.OwnerId, con.Account.Name, con.Contact_Status__c,
													 con.RecordTypeId, con.RecordType.Name, 'contact', con.Id, '', con.tdc_tsw__SMS_Opt_out__c, 
													 con.Loss_Reason__c, 'LO Trained', con.Owner.Name, con.LOP_Contact_Type__c, 'LO_Contact');

        if (resp.success) {
            con.LO_Survey_Sent__c = true;
			con.Delighted_Error__c = '';
            update con;
            
            Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
            npm.Contact__c = con.Id;
            npm.Delighted_Id__c = resp.id;
            insert npm;
        } else {
            if (resp.error.length() > 32767)
                resp.error = resp.error.substring(0, 32767);
            con.Delighted_Error__c = resp.error;
            update con;
        }
	}
    
    public static void HandleWebhook(String webhookBody) {
        System.debug(webhookBody);
        DelightedAPI.SurveyWebhookBody body = (DelightedAPI.SurveyWebhookBody)JSON.deserialize(webhookBody, DelightedAPI.SurveyWebhookBody.class);
        if (body.event_data != null && body.event_data.person_properties != null) {
            Net_Promoter_Measurement__c npm;
            if (body.event_data.person_properties.lead != null && body.event_data.person_properties.lead != '')
                npm = [SELECT Id FROM Net_Promoter_Measurement__c WHERE Lead__c = :body.event_data.person_properties.lead LIMIT 1];
            if (body.event_data.person_properties.opportunity != null && body.event_data.person_properties.opportunity != '')
                npm = [SELECT Id FROM Net_Promoter_Measurement__c WHERE Opportunity__c = :body.event_data.person_properties.opportunity LIMIT 1];
			if (body.event_data.person_properties.contact != null && body.event_data.person_properties.contact != '')
                npm = [SELECT Id FROM Net_Promoter_Measurement__c WHERE Contact__c = :body.event_data.person_properties.contact LIMIT 1];
            if (npm != null) {
                npm.Comment__c = body.event_data.comment;
                npm.Permalink__c = body.event_data.permalink;
                npm.Score__c = body.event_data.score;
                npm.Survey_Type__c = body.event_data.survey_type;
                string additionalAnswers = '';
                if (body.event_data.additional_answers != null) {
                    for (DelightedAPI.SurveyWebhookBodyAnswer aa : body.event_data.additional_answers) {
                        if (aa.question != null && aa.value != null) {
                            if (additionalAnswers != '')
                                additionalAnswers += '\n';
                            additionalAnswers += aa.question.text + ' : ';
                            if (aa.question.type == 'free_response')
                                additionalAnswers += aa.value.free_response;
                            if (aa.question.type == 'scale')
                                additionalAnswers += aa.value.scale;
                            if (aa.question.type == 'select_one' && aa.value.select_one != null)
                                additionalAnswers += aa.value.select_one.text;
                            if (aa.question.type == 'select_many' && aa.value.select_many != null) {
                                string answerCh = '';
                                for (DelightedAPI.SurveyWebhookBodyAnswerChoice ch : aa.value.select_many) {
                                    if (answerCh != '')
                                        answerCh += ', ';
                                    answerCh += ch.text;
                                }
                                additionalAnswers += answerCh;
                            }
                        }
                    }
                }
                npm.Additional_Answers__c = additionalAnswers;
                update npm;
            }
        }
    }

}