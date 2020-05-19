public class GreenLightInquiry {
    
    public Id leadId { get; set; }
    public Lead theLead;
    public boolean submitted { get; set; }
    public string preQualResult {get; set; }
    
    public GreenLightInquiry(ApexPages.StandardController ctrl) {
        leadId = ctrl.getId();
        theLead = [SELECT Id, Name,Credit_Score_Median__c, Property_State__c, Property_Zip_Code__c, Property_Street_Number_and_Name__c, Application_Tracking_ID__c, Property_Type__c,
                  			Home_Value__c, Property_City__c, RecordType.Name, Owner.Name, Owner.Email, Qualifies_for_New_HomeOwner_Pricing__c,
                   			New_Construction_Dropdown__c, Occupancy_Statement_Dropdown__c, Greenlight_Id__c, Inquiry_Sequence_ID__c, Property_Pre_Qualification_Status__c
                 	FROM Lead WHERE Id = :leadId];
        submitted = false;
    }
    
    public void MakeCall() {
		//validate all required values are present
        List<ApexPages.Message> errorMessages = new List<ApexPages.Message>();
        if (theLead.Property_Street_Number_and_Name__c == NULL) {
            errorMessages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Property Street Number and Name is required order to submit inquiry.'));            
        }
        if (theLead.Property_City__c == NULL) {
            errorMessages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Property City is required order to submit inquiry.'));            
        }  
        if (theLead.Property_State__c == NULL) {
            errorMessages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Property State is required order to submit inquiry.'));            
        } 
        if (theLead.Property_Zip_Code__c == NULL) {
            errorMessages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Property Zip is required order to submit inquiry.'));            
        }   
        if (theLead.New_Construction_Dropdown__c == NULL) {
            errorMessages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'New Construction is required order to submit inquiry.'));            
        }
        if (theLead.Occupancy_Statement_Dropdown__c == NULL) {
            errorMessages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Occupancy Statement is required order to submit inquiry.'));            
        }
        if (theLead.Property_Type__c == NULL) {
            errorMessages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Property Type is required order to submit inquiry.'));            
        }
 
        if (!errorMessages.isEmpty()) {
            for (ApexPages.Message msg: errorMessages) {
            	ApexPages.addMessage(msg);   
            }	   
        } else {                    
            GreenLightHelper.InquiryResponse result = GreenLightHelper.SendInquiry(theLead);
            if (result.success) {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Inquiry submitted successfully'));
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Property Pre-Qual Result:' + theLead.Property_Pre_Qualification_Status__c));
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Inquiry Id:' + theLead.Greenlight_Id__c));
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Inquiry Sequence Id:' + theLead.Inquiry_Sequence_ID__c));

                try {
                    update theLead;
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating lead:' + ex.getMessage()));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error from GreenLight Server: ' + result.error.message));
            }
        }
        submitted = true;        
    }

}