global class LOPBatchProcess implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {
    
    // Global Stateful variable declaration.
    global SFUtilityClass.APIOperation apiOperation;
    global SFUtilityClass.LOP_SFResourceName SFObject;
    global List<sObject> sObjectList;    
    global List<SFUtilityResult> SFUtilityResultList;
	    
    global LOPBatchProcess(SFUtilityClass.APIOperation apiOperation, SFUtilityClass.LOP_SFResourceName SFObject, List<sObject> sObjectList) {
        this.sObjectList = sObjectList;
        this.apiOperation = apiOperation;
        this.SFObject = SFObject;
        SFUtilityResultList = new List<SFUtilityResult>();
    }

    global Iterable<sObject> start(Database.BatchableContext bc) {
        return sObjectList;
    }
    
    global void execute(Database.BatchableContext Info,List<sObject> sObjectList) {
        if(SFObject == SFUtilityClass.LOP_SFResourceName.CONTACT) {
            if(apiOperation == SFUtilityClass.APIOperation.API_CREATE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.createLOPUsers(SFObject, sObjectList));                   
            } else if(apiOperation == SFUtilityClass.APIOperation.API_UPDATE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.updateLOPUsers(SFObject, sObjectList));     
            } else if(apiOperation == SFUtilityClass.APIOperation.API_DELETE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.deleteLOPUsers(SFObject, sObjectList));
            }
        } else if(SFObject == SFUtilityClass.LOP_SFResourceName.ACCOUNT) {
            if(apiOperation == SFUtilityClass.APIOperation.API_CREATE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.createLOPLenders(SFObject, sObjectList));
            } else if(apiOperation == SFUtilityClass.APIOperation.API_UPDATE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.updateLOPLenders(SFObject, sObjectList));
            } else if(apiOperation == SFUtilityClass.APIOperation.API_DELETE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.deleteLOPLenders(SFObject, sObjectList));
            }
        } else if(SFObject == SFUtilityClass.LOP_SFResourceName.USER) {
            if(apiOperation == SFUtilityClass.APIOperation.API_CREATE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.createLOPUsers(SFObject, sObjectList));
                SFUtilityResultList.addAll(LOPConnectorUtility.createLOPSalesDirectors(SFObject, sObjectList));
            } else if(apiOperation == SFUtilityClass.APIOperation.API_UPDATE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.updateLOPUsers(SFObject, sObjectList));
                SFUtilityResultList.addAll(LOPConnectorUtility.updateLOPSalesDirectors(SFObject, sObjectList));
            } else if(apiOperation == SFUtilityClass.APIOperation.API_DELETE) {
                SFUtilityResultList.addAll(LOPConnectorUtility.deleteLOPUsers(SFObject, sObjectList));
                SFUtilityResultList.addAll(LOPConnectorUtility.deleteLOPSalesDirectors(SFObject, sObjectList));
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        List<sObject> finalSObjectRecords = SFUtilityClass.getTypeCastedSObjectList(SFObject.name());
        List<SFUtilityResult> sfResultsForError = new List<SFUtilityResult>();
		List<sObject> sObjectsForUpdate = new List<sObject>();
        Map<String, String> APICallToSFContactFieldMap = new Map<String, String> {
			SFUtilityClass.APIOperation.API_CREATE.name() => 'Create_LOP_User__c',
			SFUtilityClass.APIOperation.API_UPDATE.name() => 'Update_LOP_User__c',
			SFUtilityClass.APIOperation.API_DELETE.name() => 'Deactivate_LOP_User__c'
		};
		Map<String, String> APICallToSFAccountFieldMap = new Map<String, String> {
			SFUtilityClass.APIOperation.API_CREATE.name() => 'Create_LOP_Lender__c',
			SFUtilityClass.APIOperation.API_UPDATE.name() => 'Update_LOP_Lender__c',
			SFUtilityClass.APIOperation.API_DELETE.name() => 'Deactivate_LOP_Lender__c'
		};
		
		Map<String, String> fieldMap = new Map<String, String>();
		if(SFObject == SFUtilityClass.LOP_SFResourceName.CONTACT) {            
			fieldMap = APICallToSFContactFieldMap;
        } else if(SFObject == SFUtilityClass.LOP_SFResourceName.ACCOUNT) {
            fieldMap = APICallToSFAccountFieldMap;
        } else if(SFObject == SFUtilityClass.LOP_SFResourceName.USER) {
			fieldMap = APICallToSFContactFieldMap;
            Integer LOPRecordCountPerRequest = 2;
            List<SFUtilityResult> tempSFResults = new List<SFUtilityResult>();
			for(Integer index1 = 0; index1 < SFUtilityResultList.size(); index1 += LOPRecordCountPerRequest) {
                List<SFUtilityResult> sfResultTempList = new List<SFUtilityResult>();
                for(Integer index2 = index1; index2 < (index1+LOPRecordCountPerRequest); index2++) {
                    sfResultTempList.add(SFUtilityResultList[index2]);
                }
                tempSFResults.add(SFUtilityClass.combineSFUtilityResults(sfResultTempList));
            }
			SFUtilityResultList.clear();
			SFUtilityResultList.addAll(tempSFResults);
        }		
		
		for(SFUtilityResult sfResultObj : SFUtilityResultList) {                
			sObject sObj = (sObject)sfResultObj.result[0];
			if(sfResultObj.isSuccess) {                    
				if(Boolean.ValueOf(sObj.get(fieldMap.get(apiOperation.name())))) {
					sObj.put(fieldMap.get(apiOperation.name()), false);
				}
			} else {
                if(Boolean.ValueOf(sObj.get(fieldMap.get(apiOperation.name())))) {
                    sObj.put('LOP_Error_Message__c', sfResultObj.displayMessage.replaceAll('#;#', '\n'));
                }
				sfResultsForError.add(sfResultObj);
			}
			finalSObjectRecords.add(sObj);
		}
		sendEmailNotification(sfResultsForError);
        System.debug('finalSObjectRecords : ' + finalSObjectRecords);
		SFUtilityClass.apexDMLHandler(finalSObjectRecords, SFObject.name(), SFUtilityClass.ApexDMLOptions.APEX_UPDATE);
    }
    
    /** 
     * Prepare Email Notification with prefill values.
     * @Param       sfResultsForError, List of SFUtilityResult.
     * @Returns     -
     */
    private void sendEmailNotification(List<SFUtilityResult> sfResultsForError) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setSaveAsActivity(false);
        
        Set<Id> tagetObjectIds = new Set<Id>();
        Set<String> emailAddressList = new Set<String>();
        
		if(!sfResultsForError.isEmpty()) {
			for(LOP_Error_Handling_Emails__c EHandlerObj : [SELECT Email__c 
                                                        FROM LOP_Error_Handling_Emails__c]) {
				emailAddressList.add(EHandlerObj.Email__c);
			}
			if(!emailAddressList.isEmpty()) {
				for(Contact contactObj : [SELECT Id 
										  FROM Contact 
										  WHERE Email IN :emailAddressList LIMIT :LIMITS.getLimitEmailInvocations()]) {
					
					tagetObjectIds.add(contactObj.Id);
				}
				
				if(!tagetObjectIds.isEmpty()) {
					String htmlBody = '<br/><br/>' + createEmailBody(sfResultsForError);
					for(Id targetId : tagetObjectIds) {
						mail.setTargetObjectId(targetId);
						sendLOPErrorEmail(htmlBody, mail);
					}                
				}
			}
		}
    }
    
    /** 
     * Create Email Notification body respective of LOP integration.
     * @Param       sfResultsForError, List of SFUtilityResult.
     * @Returns     String Email Body.
     */
    private string createEmailBody(List<SFUtilityResult> sfResultsForError){
        String body = '<table cellpadding="5px" colspan="3px" border="1px solid black" style="border-collapse: collapse">'+
                      '<thead><th>Index</th>'+
            		  '<th>API Operation</th>'+
            		  '<th>SF Object affected</th>'+
            		  '<th>Error Message</th>'+
            		  '<th>SF Record Id</th></thead>';
        String tableRow = '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>'+
                          '<a href="'+ system.Url.getSalesforceBaseUrl().toExternalForm() +'/{4}">{5}</a>'+
                          '</td></tr>';        
        Integer index = 1;
        for(SFUtilityResult sfResultObj : sfResultsForError) {
            if(!sfResultObj.isSuccess) {
                sObject sObj = (sObject)sfResultObj.result[0]; 
                // prepare HTML body.
                body += String.format(tableRow, new List<String>{String.valueOf(index++), 
                    											 apiOperation.name(), 
                    											 SFObject.name(), 
                                                                 sfResultObj.displayMessage.replaceAll('#;#', '<br/>'),
                                                                 String.valueOf(sObj.get('Id')),
                                                                 String.valueOf(sObj.get('Id'))});
            }
        }
        body += '</table>';
        return body;
    }    
    
    /** 
     * Send Email by using SF Email Temlpate.
     * @Param       emailBody, Email Body in String HTML.
     * @Param       mail, SingleEmailMessage instance with predefilled values.
     * @Returns     -
     */
    private void sendLOPErrorEmail(String emailBody, Messaging.SingleEmailMessage mail) {
        try {
            EmailTemplate emailTemplate = [SELECT id, HtmlValue, Subject 
                                           FROM EmailTemplate 
                                           WHERE DeveloperName = 'LOP_Error_Notification'];
            
            mail.setTemplateId(emailTemplate.id);
            mail.setSubject(emailTemplate.subject);
            mail.setHtmlBody(emailTemplate.HtmlValue + emailBody);
            Messaging.SendEmailResult[] sendEmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        } catch(Exception exp) {
            SFUtilityClass.logMessageFromException(exp);
        }        
    }
}