public with sharing class LeadQualification extends QualificationBase {
    
    public Id leadId { get; set; }
    public Lead theLead { get; set; }
    public decimal HEPF { get; set; }
    public boolean passbookUsed {get; set; }      
    public List<DecisionBounderyWrapper> decisionBounderyWrapperObjectList {get;set;}
    public String pdRate{get;set;}
    public String passbookScore{get;set;} 
    public String passbookDecision{get;set;} 
    public String decisionExplanation{get;set;} 
    public String errorIssue{get;set;} 
    public boolean errorOccure{get;set;} 
    public Set<String> nonSuccessStringSet = new Set<String>{'Escalate','Decline','Failed'};
    public String dealID{get;set;}
    public String applicantName{get;set;}
    public decimal currentLTV{get;set;}
    public decimal currentDTI{get;set;}
    
        
        public LeadQualification(ApexPages.StandardController ctrl) {
            errorOccure = false;
            string Occupancy_Status;
            Decimal Total_Monthly_Debt_Payment;
            
            leadId = ctrl.getId();
            
            Lead lead = [SELECT Id,Is_there_Co_App__c, LTV__c, Back_End_Ratio__c, Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c,Property_State__c,Application_Tracking_ID__c,Name,
                         Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c,Personal_Credit_Report__r.CreateDateTime__c,Occupancy_Statement_Dropdown__c,Proposed_Total_Mortgage_Debt__c, Qualifies_for_New_HomeOwner_Pricing__c,
                         LTV_Denominator__c,Record_Type_Name__c, Sum_of_Debt_Payments__c,Payment_Monthly_Total_Housing__c,LTV_Numerator__c, Estimated_Funding_Amount__c,Total_Monthly_Income__c,Income_Monthy_Total_Co__c,
                         (SELECT Yodlee_Public_Id__c FROM Yodlee_Order_Requests__r ORDER BY CreatedDate DESC LIMIT 1)
                         FROM Lead WHERE Id = :leadId];
            theLead = lead;
            
            dealID = lead.Application_Tracking_ID__c;
    		applicantName = lead.Name;
    		currentLTV = lead.LTV__c;
    		currentDTI = lead.Back_End_Ratio__c;
            
            // Product
            Product = 'HomeOwner';
            if (lead.Record_Type_Name__c == 'HomeBuyer'){
                Product = 'HomeBuyer';  
            }
            
            // LTV
            LTV = lead.LTV__c;
            
            // FICO
            FICO = 0;
            if (lead.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c != null && lead.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c > 300) {
                FICO = lead.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c;
            }
            if (lead.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c != null && lead.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c > 300) {
                FICO = Math.Min(FICO, lead.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c);
            }
            FICO = Math.Round(FICO * 100) / 100;
            
            
            // DTI
            DTI = lead.Back_End_Ratio__c;
            
            //Income
            Decimal TotalIncome = lead.Total_Monthly_Income__c+lead.Income_Monthy_Total_Co__c ;
            
            calculated = false;
            CreateException = false;
            
        }
    
    //new method for passbook qualification    
    public void passbookCalculate(){
        pdRate = '';
        passbookScore = '';
        passbookDecision = '';
        decisionExplanation = '';
        PassbookRestHelper passbookHelper = new PassbookRestHelper();
        PassbookRestHelper.passbookJSON passbookJSON = new PassbookRestHelper.passbookJSON();
        PassbookJSON.Origination_Credit_Score = integer.valueOf(FICO);
        PassbookJSON.num_borrowers = (theLead.Is_there_Co_App__c == false) ? 1 : 2;
        PassbookJSON.Income = thelead.Total_Monthly_Income__c + thelead.Income_Monthy_Total_Co__c ;
        PassbookJSON.Origination_Front_End_DTI = DTI;
        PassbookJSON.Original_Loan_Amount = theLead.Proposed_Total_Mortgage_Debt__c;
        PassbookJSON.Property_State = theLead.Property_State__c;
        PassbookJSON.Product_Type = (Product == 'HomeOwner') ? 'C' : 'P';
        PassbookJSON.Origination_CLTV = LTV;
        if(theLead.Occupancy_Statement_Dropdown__c == 'Principal Residence'){
            PassbookJSON.Occupancy_Status = 'P';        
        }else{
            if(theLead.Occupancy_Statement_Dropdown__c == ' Second Vacation Home'){
                PassbookJSON.Occupancy_Status = 'S';        
            }else{
                PassbookJSON.Occupancy_Status = 'I';   
            }
        }
        if(theLead.Personal_Credit_Report__c!=null)
        { 
            PassbookJSON.Cut_Off_Date = theLead.Personal_Credit_Report__r.CreateDateTime__c.date();
        }
        PassbookJSON.Total_Monthly_Debt_Payment = theLead.Payment_Monthly_Total_Housing__c + theLead.Sum_of_Debt_Payments__c;
        
        //restREsponse
        calculated = true;
        String passbookResult = PassbookRestHelper.postToPassbook(passbookJSON);
       	
        System.debug('This is passbookJSON' +passbookJSON);
        System.debug('This is passbookResult' +passbookResult);
        decisionBounderyWrapperObjectList = new List<DecisionBounderyWrapper>();
        Map<String, Object> mapOfObj = (Map<String, Object>) JSON.deserializeUntyped(passbookResult);
        errorIssue = (String)mapOfObj.get('Error_Issues');
        
        //Check whether there is as Error Issue in response 
        if(errorIssue=='None'){
            
            //Get PD Rate, Passbook Score, Passbook Decision, Decision Explanation, Data from response
            pdRate = String.valueOf(mapOfObj.get('PD_Rate'));
            passbookScore = String.valueOf(mapOfObj.get('Passbook_Score'));
            passbookDecision = (String)mapOfObj.get('Passbook_Decision');
            decisionExplanation = (String)mapOfObj.get('Decision_Explanation');
            Object objTemp = mapOfObj.get('Decision_Boundary');
            Map<String, Object> bounderyObjMap =   (Map<String, Object>) JSON.deserializeUntyped(JSON.Serialize(objTemp));
            
            //Iterate through Response to read Decision Boundary 
            for(String boundryVal : bounderyObjMap.keySet()){
                DecisionBounderyWrapper wrapperObj = new DecisionBounderyWrapper();
                wrapperObj.DecisionBounderyValue = boundryVal;
                Map<String, Object> mapOfObjInner = (Map<String, Object>) JSON.deserializeUntyped(JSON.Serialize(bounderyObjMap.get(boundryVal)));
                for(String boundryValInner : mapOfObjInner.keySet()){
                    if(boundryValInner=='Approval DTI Boundary'){
						wrapperObj.ApprovalDTIBoundaryValue= String.ValueOf(mapOfObjInner.get(boundryValInner));
					}else if(boundryValInner=='Escalate DTI Boundary'){
						 wrapperObj.EscalateDTIBoundaryValue= String.valueOf(mapOfObjInner.get(boundryValInner));
					}
                }
                
                decisionBounderyWrapperObjectList.add(wrapperObj);
            }
            if(nonSuccessStringSet.contains(passbookDecision)){
                //exception to handle case creation
                CreateException = true;    
            }
            
            //update to lead
            theLead.Passbook_Status__c = passbookDecision;
            theLead.Passbook_Decision_Explanation__c = decisionExplanation;
            theLead.Approval_Escalation_Boundary__c= JSON.Serialize(objTemp);
            passbookUsed = true;
            calculated = true;
            update theLead;
        }else {
            errorOccure = true;
            theLead.Passbook_Error_Log__c = errorIssue;
            update theLead;
        }      
    }

    
    // ******** Exception page elements below ********
    
    public PageReference RaiseException() {
        List<String> componentNameList = new List<String>{ 'Case-Exception' };
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        
        caseLayout = new LayoutWrapper((Metadata.Layout)components.get(0));
        
        List<Lead_to_Case_Mapping__c> mapFields = [SELECT Case_field_API_Name__c, Lead_Field_API_Name__c, Default_Value__c FROM Lead_to_Case_Mapping__c];
        string query = 'SELECT Id';
        for (Lead_to_Case_Mapping__c mapField : mapFields) {
            if (mapFIeld.Lead_Field_API_Name__c != null && mapField.Lead_Field_API_Name__c != '') {
                query += ', ' + mapFIeld.Lead_Field_API_Name__c;
            }
        }
        query += ' FROM Lead WHERE Id = :leadId';
        System.debug(query);
        Lead fullLead = Database.query(query);
        
        newCase = new Case();
        for (Lead_to_Case_Mapping__c mapField : mapFields) {
            if (mapField.Lead_Field_API_Name__c != null && mapField.Lead_Field_API_Name__c != '') {
                if (mapField.Lead_Field_API_Name__c.contains('.')) {
                    if (fullLead.getSObject(mapField.Lead_Field_API_Name__c.split('\\.')[0]) != null) {
                        newCase.put(mapField.Case_field_API_Name__c, fullLead.getSObject(mapField.Lead_Field_API_Name__c.split('\\.')[0]).get(mapField.Lead_Field_API_Name__c.split('\\.')[1]));
                    }
                } else {
                    newCase.put(mapField.Case_field_API_Name__c, fullLead.get(mapField.Lead_Field_API_Name__c));
                }
            } else if (mapField.Default_Value__c != null && mapField.Default_Value__c != '') {
                newCase.put(mapField.Case_field_API_Name__c, mapField.Default_Value__c);
            }
        }
        newCase.Lead__c = fullLead.Id;
        newCase.Description = MitigatingCircumstances;
        if(nonSuccessStringSet.contains(passbookDecision)){
            newCase.Subject = 'Escalation from Passbook';
            newCase.Exception_Reason__c = passbookDecision;
        }
        newCase.Homeowner_Equity_Post_Funding__c = HEPF;
        newCase.Mortgage_Type__c = MortgageType == 'Amortizing' ? 'Amortizing' : 'Non-amortizing';
        
        PageReference pr = Page.LeadQualificationException;
        pr.setRedirect(false);
        return pr;
    }
    
    //class to handle boundary decision matrix return from passbook    
    public class DecisionBounderyWrapper{
        public string DecisionBounderyValue{get;set;}
        public string ApprovalDTIBoundaryValue{get;set;}
        public string EscalateDTIBoundaryValue{get;set;}
        
    }    
}