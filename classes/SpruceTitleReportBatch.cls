global class SpruceTitleReportBatch implements Database.Batchable<Property_Due_Diligence_Reports__c>, Database.AllowsCallouts
{	
	// Start Method
    global List<Property_Due_Diligence_Reports__c> start(Database.BatchableContext BC)
    {
    	system.debug('Start SpruceTitleReportBatch');

    	List<Property_Due_Diligence_Reports__c> propertyDueDiligenceReportList = 
    		[
    			SELECT Id, Opportunity__r.Name, Spruce_Title_Report_Downloaded__c, Opportunity__c, Status__c, Opportunity__r.Owner.Id, Opportunity__r.Owner.Email, Spruce_Order_Id__c, Opportunity__r.UnisonProcessor__r.Email, Opportunity__r.UnisonProcessor__c
    			FROM Property_Due_Diligence_Reports__c
    			WHERE Spruce_Title_Report_Downloaded__c = false
    			AND Status__c = 'title_report_available'
    			AND Opportunity__c != null
    			AND Opportunity__r.UnisonProcessor__c != null
    		];

    	return propertyDueDiligenceReportList;
	}

   	global void execute(Database.BatchableContext BC, List<Property_Due_Diligence_Reports__c> propertyDueDiligenceReportList) 
   	{
   		system.debug('Execute SpruceTitleReportBatch');

   		List<Attachment> attachmentList = new List<Attachment>();
   		List<FeedItem> feedItemList = new List<FeedItem>();
   		List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

		for(Property_Due_Diligence_Reports__c propertyDueDiligenceReport : propertyDueDiligenceReportList)
		{
			SpruceAPI.RetrieveAvailableDocumentOfGivenTypeResponse response = SpruceHelper.RetrieveAvailableDocumentOfGivenType(propertyDueDiligenceReport.Spruce_Order_Id__c, 'TitleSearchReport');
                
            Blob file = response.file;

            if(file != null)
            { 
                Attachment attachment = new Attachment();
                attachment.ParentId = propertyDueDiligenceReport.Opportunity__c;
                attachment.Name = 'TitleSearchReport.pdf';
                attachment.ContentType = 'application/pdf';
                attachment.Body = file;                
                attachmentList.add(attachment);

                propertyDueDiligenceReport.Spruce_Title_Report_Downloaded__c = true;

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();	         
		        email.setToAddresses(new List<String>{propertyDueDiligenceReport.Opportunity__r.Owner.Email, propertyDueDiligenceReport.Opportunity__r.UnisonProcessor__r.Email});	         
		        email.setSubject('Title Search Report');	         
		        email.setHtmlBody('Your title order has been fulfilled for <a href="' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + propertyDueDiligenceReport.Opportunity__c + '">' + propertyDueDiligenceReport.Opportunity__r.Name + ' </a> and is ready to download.');
            	emailList.add(email);

            	// Chatter Post for Opportunity Owner
            	FeedItem post = new FeedItem();
				post.ParentId = propertyDueDiligenceReport.Opportunity__r.Owner.Id;
				post.Body = 'Your title order has been fulfilled for ' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + propertyDueDiligenceReport.Opportunity__c + ' and is ready to download.';
				feedItemList.add(post);

				// Chatter Post for Transaction Specialist
				FeedItem post2 = new FeedItem();
				post2.ParentId = propertyDueDiligenceReport.Opportunity__r.UnisonProcessor__c;
				post2.Body = 'Your title order has been fulfilled for ' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + propertyDueDiligenceReport.Opportunity__c + ' and is ready to download.';
				feedItemList.add(post2);
            }
		}

		if(attachmentList.size() > 0)
		{
			insert attachmentList;
			update propertyDueDiligenceReportList;				
			insert feedItemList;

			Messaging.sendEmail(emailList);
		}  
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		system.debug('Finish SpruceTitleReportBatch');
        // Logic to be Executed at finish
	}
	
}