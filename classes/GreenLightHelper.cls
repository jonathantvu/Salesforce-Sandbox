public class GreenLightHelper {
    
    // For test class purposes, just set this to true
    public static boolean skipCall = false;

    public static InquiryResponse SendInquiry(Id leadId) {

        Lead lead = [SELECT Id, Home_Value__c,RecordType.Name,Credit_Score_Median__c, Greenlight_Id__c,Pricing_Ratio__c, Inquiry_Sequence_ID__c, Occupancy_Statement_Dropdown__c, 
                            New_Construction_Dropdown__c, Application_Tracking_ID__c, Qualifies_for_New_HomeOwner_Pricing__c, 
                            Property_Street_Number_and_Name__c, Property_City__c, Property_State__c, Property_Zip_Code__c, Property_Type__c
                        FROM Lead WHERE Id = :leadId];

        InquiryResponse toReturn = SendInquiry(lead);

        if (toReturn.success) {
            try {
                update lead;
            } catch (Exception ex) {
                toReturn.success = false;
                toReturn.error = new InquiryResponseError();
                toReturn.error.statusCode = 200;
                toReturn.error.error = 'Callout succeded but the lead update failed';
                toReturn.error.message = ex.getMessage();
            }
        }

        return toReturn;
    }

    public static InquiryResponse SendInquiry(Lead lead) {

        if (skipCall)
            return new InquiryResponse(false, 'GreenLightHelper.skipCall is true');

        GreenLightAPI.AutoSaveLogs = true;

        if (lead.Greenlight_Id__c == null || lead.Greenlight_Id__c.trim() == '' || lead.Inquiry_Sequence_ID__c == null || lead.Inquiry_Sequence_ID__c.trim() == '') {
            // POST
            GreenLightAPI.PostInquiryRequest req = new GreenLightAPI.PostInquiryRequest();
            req.tracking_id = lead.Application_Tracking_ID__c;
            req.program_type = lead.RecordType.Name.toLowerCase();
            req.lead_id = lead.Id;
            req.property.property_type = lead.Property_Type__c;
            req.property.input_address.delivery_line = lead.Property_Street_Number_and_Name__c;
            req.property.input_address.city = lead.Property_City__c;
            req.property.input_address.state_abbreviation = lead.Property_State__c;
            req.property.input_address.postal_code = lead.Property_Zip_Code__c;
            req.property.occupancy_status = lead.Occupancy_Statement_Dropdown__c;
            req.property.is_new_construction = (lead.New_Construction_Dropdown__c == 'Yes') ? true : false;
            req.program.Qualifies_for_New_HomeOwner_Pricing_c_c = lead.Qualifies_for_New_HomeOwner_Pricing__c;
            req.financial.origination_credit_score = lead.Credit_Score_Median__c;

            GreenLightAPI.InquiryResponse res = GreenLightAPI.PostInquiry(req);

            System.debug(res);

            if (res.success) {
                lead.Greenlight_Id__c = res.inquiry_id;
                lead.Inquiry_Sequence_ID__c = res.inquiry_sequence_id;
                lead.Property_Pre_Qualification_Status__c = TransformStatus(res.decision);
                lead.Core_Logic_Property_Id__c = res.property.cl_property_id;
                lead.Pricing_Ratio__c = res.program.Pricing_Ratio_c_c;
                lead.Greenlight_Decision_Notes__c = res.notes.greenlight.finalNotes;
                lead.Home_Value__c = res.estimated_valuation;
                return new InquiryResponse(true, null);
            } else {
                return new InquiryResponse(false, res.error);
            }
        } else {
            // PUT
            GreenLightAPI.PutInquiryRequest req = new GreenLightAPI.PutInquiryRequest();
            req.inquiry_id = lead.Greenlight_Id__c;
            req.inquiry_sequence_id = lead.Inquiry_Sequence_ID__c;
            req.tracking_id = lead.Application_Tracking_ID__c;
            req.lead_id = lead.Id;
            req.property.property_type = lead.Property_Type__c;
            req.property.input_address.delivery_line = lead.Property_Street_Number_and_Name__c;
            req.property.input_address.city = lead.Property_City__c;
            req.property.input_address.state_abbreviation = lead.Property_State__c;
            req.property.input_address.postal_code = lead.Property_Zip_Code__c;
            req.property.occupancy_status = lead.Occupancy_Statement_Dropdown__c;
            req.property.is_new_construction = (lead.New_Construction_Dropdown__c == 'Yes') ? true : false;
            req.program.Qualifies_for_New_HomeOwner_Pricing_c_c = lead.Qualifies_for_New_HomeOwner_Pricing__c;
            req.financial.origination_credit_score = lead.Credit_Score_Median__c;            

            GreenLightAPI.InquiryResponse res = GreenLightAPI.PutInquiry(req);

            System.debug(res);

            if (res.success) {
                lead.Property_Pre_Qualification_Status__c = TransformStatus(res.decision);
                lead.Core_Logic_Property_Id__c = res.property.cl_property_id;
                lead.Pricing_Ratio__c = res.program.Pricing_Ratio_c_c; 
                lead.Greenlight_Decision_Notes__c = res.notes.greenlight.finalNotes;
                lead.Home_Value__c = res.estimated_valuation;
                return new InquiryResponse(true, null);
            } else {
                return new InquiryResponse(false, res.error);
            }
        }
    }

    private static Map<String, String> decisionMapping;
    private static string TransformStatus(string decision) {
        if (decisionMapping == null) {
            decisionMapping = new Map<String, String>();
            for (GreenLight_Decision_Mapping__mdt mdt : [SELECT GreenLight_Decision__c, Qualification_Status__c FROM GreenLight_Decision_Mapping__mdt]) {
                decisionMapping.put(mdt.GreenLight_Decision__c, mdt.Qualification_Status__c);
            }
        }
        if (decisionMapping.containsKey(decision))
            return decisionMapping.get(decision);
        return 'Not Enough Information';
    }

    public class InquiryResponse {
        public boolean success { get; set; }
        public InquiryResponseError error { get; set; }
        public InquiryResponse(boolean success, string response) {
            this.success = success;
            if (!success)
                this.error = (InquiryResponseError)JSON.deserialize(response, InquiryResponseError.class);
        }
    }
    public class InquiryResponseError {
        public integer statusCode { get; set; }
        public string error { get; set; }
        public string message { get; set; }
    }

}