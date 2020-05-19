public with sharing class OppQualification extends QualificationBase {
    
    public Id oppId { get; set; }
    public Opportunity theOpp { get; set; }
    public Boolean IA_Passbook_Override {get; set;}
    public String passbookResultValue {get; set;}
    public string IA_Passbook_Override_Reasons {get; set;}
    public OppQualification(ApexPages.StandardController ctrl) {
        
        oppId = ctrl.getId();

        /* 4/2/2019 Sundar Subramaniam - LTV__c and Expected_Back_End_DTI__c removed from query for Data Model Cleanup */
       /*  4/5/2019 Neeraja Cherukuri- Replaced Expected_Back_End_DTI__c  with new fields  for Data Model Cleanup */

        Opportunity opp = [SELECT Id,Applicant__c,Co_Applicant__c,  Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c, 
                            Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c,Post_Close_BE_Ratio__c , Qualifies_for_New_HomeOwner_Pricing__c,
                            /*LTV_Denominator__c, LTV_Numerator__c,*/ Estimated_Funding_Amount__c,Post_Close_LTV2__c ,
                           IA_Passbook_Override__c,IA_Passbook_Override_Reasons__c,Passbook_Status__c,
                           (SELECT Yodlee_Public_Id__c FROM Yodlee_Order_Requests__r ORDER BY CreatedDate DESC LIMIT 1)
                        FROM Opportunity WHERE Id = :oppId];
        theOpp = opp;
        system.debug('+++ yoodlee orders' + opp.Yodlee_Order_Requests__r);
       IA_Passbook_Override    = theOpp.IA_Passbook_Override__c;
        IA_Passbook_Override_Reasons = theOpp.IA_Passbook_Override_Reasons__c;
        passbookResultValue = theOpp.Passbook_Status__c;
        
        // Product
        Product = 'HomeOwner';
        if (opp.Qualifies_for_New_HomeOwner_Pricing__c == true)
            Product = 'New HomeOwner';
        system.debug('+++ b4 LTV ' + LTV);
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        // LTV
        LTV = opp.Post_Close_LTV2__c == null ? 0 : opp.Post_Close_LTV2__c ;
        LTV = Math.Round(LTV * 100) / 100;
        system.debug('++LASERCA__Co_Applicant_Credit_Score_Median__c ' + opp.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c);
        system.debug('++LASERCA__Co_Applicant_Credit_Score_Median__c ' + opp.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c);

        // FICO
        FICO = 0;
        if (opp.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c != null && opp.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c > 300) {
            FICO = opp.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c;
        }
        if (opp.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c != null && opp.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c > 300) {
            FICO = Math.Min(FICO, opp.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c);
        }
        FICO = Math.Round(FICO * 100) / 100;
        /* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        /* 4/5/2019 Neeraja Cherukuri- Replaced with new fields  for Data Model Cleanup */
        system.debug('+++ FICO ' + FICO);
        // DTI
        DTI = opp.Post_Close_BE_Ratio__c ;
        DTI = DTI == null ? 0 : Math.Round(DTI * 100) / 100;
        
        calculated = false;
        CreateException = false;
        showOptyButton = false;
    }
    

    //new method for passbook qualification    
    public void passbookCalculate(){  
        System.debug('====IA_Passbook_Override==='+IA_Passbook_Override);  
        PassbookRestHelper passbookHelper = new PassbookRestHelper();
        PassbookRestHelper.passbookJSON passbookJSON = new PassbookRestHelper.passbookJSON();
        passbookJSON.partner_id = theOpp.Applicant__c;
        passbookJSON.product_type = (Product == 'HomeOwner') ? 'HO' : 'HB';
        passbookJSON.mortgage_type = (MortgageType == 'Amortizing') ? 'A' : 'NA';
        passbookJSON.ltv = LTV;
        passbookJSON.fico = integer.valueOf(FICO);
        passbookJSON.dti = DTI;
        passbookJSON.has_co_app = (theOpp.Co_Applicant__c != NULL) ? true : false;
        if(!theOpp.Yodlee_Order_Requests__r.isEmpty()) {
            passbookJSON.yodlee_report_id = theOpp.Yodlee_Order_Requests__r[0].Yodlee_Public_Id__c == null ? 'None' : theOpp.Yodlee_Order_Requests__r[0].Yodlee_Public_Id__c;
        } else {
            passbookJSON.yodlee_report_id = 'None';
        }

        system.debug('+++ passbookJSON ' + JSON.serialize(passbookJSON));
        passbookResponse = (PassbookRestHelper.passbookResponse)json.deserialize(PassbookRestHelper.postToPassbook(passbookJSON), PassbookRestHelper.passbookResponse.class);
        calculated = true; 
        passbookUsed = true;
        passBookResults = true;
        system.debug('+++ passbookResponse ' + JSON.serialize(passbookResponse));

        passbookResult = passbookResponse.response;
        resultT1 = passbookResponse.grid_one_result;
        resultT2 = passbookResponse.grid_two_result;
        if(passbookResult == 'Exception')
        {
            theOpp.Passbook_Status__c = 'Exception';
            CreateException = true; 
            theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
         update theOpp;           
        } 
    }
    
    public pageReference passbookContinueOpp()
    { 
        //Added by Neeraja Cherukuri For Passbook ovveride Functionality
        if(passbookResponse.response == 'Approve')
        {
            
            if(IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c == null 
            || !IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c != null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'IA Passbook override reason is required if IA Override checkbox is checked.'));  
                return new PageReference('/apex/OppQualification?scontrolCaching=1&id=' + theOpp.Id);     
            }
            theOpp.Passbook_Status__c = 'Approve';
            //theOpp.IA_Passbook_Override_Reasons__c = IA_Passbook_Override_Reasons;
            theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
            update theOpp;
            return new PageReference('/' + theOpp.Id);
        }
        
        else if(passbookResponse.response == 'Decline')
        
        {
        
             //Added by Neeraja Cherukuri For Passbook ovveride Functionality
            if(IA_Passbook_Override || theOpp.IA_Passbook_Override_Reasons__c != null)
            {
                if( IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c == null 
                || !IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c != null)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'IA Passbook override reason is required if IA Override checkbox is checked.')); 
                    return new PageReference('/apex/OppQualification?scontrolCaching=1&id=' + theOpp.Id);     
                }
                 theOpp.Passbook_Status__c = 'Decline';
                theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
              // theOpp.IA_Passbook_Override_Reasons__c = IA_Passbook_Override_Reasons;
                update theOpp;
                return new PageReference('/' + theOpp.Id);    
            }  
            
            theOpp.Passbook_Status__c = 'Decline';
            theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
            update theOpp;
            return new PageReference('/' + theOpp.Id);
        }  
        
        
        if(passbookResponse.response == null)
        {
             //Added by Neeraja Cherukuri For Passbook ovveride Functionality
            if(IA_Passbook_Override || theOpp.IA_Passbook_Override_Reasons__c != null)
            {
                if( (IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c == null)  || (!IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c != null))
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'IA Passbook override reason is required if IA Override checkbox is checked.')); 
                    return new PageReference('/apex/OppQualification?scontrolCaching=1&id=' + theOpp.Id);     
                }
                 theOpp.Passbook_Status__c = 'Exception';
                 theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
              // theOpp.IA_Passbook_Override_Reasons__c = IA_Passbook_Override_Reasons;
                update theOpp;
                return new PageReference('/' + theOpp.Id);    
            } 
            theOpp.Passbook_Status__c = 'Exception'; 
            theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
            update theOpp;
            return new PageReference('/' + theOpp.Id); 
        }

        if(passbookResponse.response == 'Exception')
        {
            //Added by Neeraja Cherukuri For Passbook ovveride Functionality
            if(IA_Passbook_Override || theOpp.IA_Passbook_Override_Reasons__c != null)
            {
                if( (IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c == null)  || (!IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c != null))
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'IA Passbook override reason is required if IA Override checkbox is checked.'));
                    return new PageReference('/apex/OppQualification?scontrolCaching=1&id=' + theOpp.Id);
                }
                theOpp.Passbook_Status__c = 'Exception';
                theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
                // theOpp.IA_Passbook_Override_Reasons__c = IA_Passbook_Override_Reasons;
                update theOpp;
                return new PageReference('/' + theOpp.Id);
            }
            system.debug('++ theOpp ' + theOpp.IA_Passbook_Override_Reasons__c);
            theOpp.Passbook_Status__c = 'Exception';
            theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
            update theOpp;
            return new PageReference('/' + theOpp.Id);
        }

        System.debug('====response is null === ');
        System.debug('====IA_Passbook_Override==='+IA_Passbook_Override);
        System.debug('====theOpp.IA_Passbook_Override__c==='+theOpp.IA_Passbook_Override__c);
        system.debug('++ IA_Passbook_Override_Reasons__c ' + theOpp.IA_Passbook_Override_Reasons__c);
        
        
        
    /*    if(IA_Passbook_Override || theOpp.IA_Passbook_Override_Reasons__c != null)
        {
            if(IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c == null
             || !IA_Passbook_Override && theOpp.IA_Passbook_Override_Reasons__c != null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'IA Passbook override reason is required if IA Override checkbox is checked.'));  
                return new PageReference('/apex/OppQualification?scontrolCaching=1&id=' + theOpp.Id);   
            }
            
            theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
            theOpp.IA_Passbook_Override_Reasons__c = IA_Passbook_Override_Reasons;
          // theOpp.Passbook_Status__c = 'Declined';
            update theOpp;
            return new PageReference('/' + theOpp.Id);    
        }
        
        theOpp.IA_Passbook_Override__c = IA_Passbook_Override;
        theOpp.IA_Passbook_Override_Reasons__c = IA_Passbook_Override_Reasons;
       
        update theOpp;  */
        
        return new PageReference('/' + theOpp.Id);
    }  
    
  //Added by Neeraja Cherukuri For Passbook ovveride Functionality
 
    
    public PageReference ContinueOpp() {
        Opportunity opp = [SELECT Id, Passbook_Status__c, IA_Passbook_Override__c, Loss_Type__c, StageName, Loss_Reason_Code__c  FROM Opportunity WHERE Id = :oppId];
        if (ResultT1 == 'Yes' && ResultT2 == 'Yes') {
            //opp.Guideline_Prequalification_Date_Time__c = DateTime.now();
            update opp;
            return new PageReference('/' + opp.Id);
        }
        
        if (ResultT1 == 'Yes' && ResultT2 == 'No') {
            opp.StageName = 'Closed Lost';
            opp.Loss_Type__c = 'Declined';
            opp.Loss_Reason_Code__c = 'Excessive obligations in relation to income';
            update opp;
            return new PageReference('/' + opp.Id);
        }
        
        if (ResultT1 == 'Yes' && ResultT2 == 'Exception') {
            // Should not get to this point
        }
        
        if (ResultT1 == 'No' && ResultT2 == 'Yes') {
            opp.StageName = 'Closed Lost';
            opp.Loss_Type__c = 'Declined';
            opp.Loss_Reason_Code__c = 'Reported credit below our minimum requirement';
            update opp;
            return new PageReference('/' + opp.Id);
        }
        
        if (ResultT1 == 'No' && ResultT2 == 'No') {
            opp.StageName = 'Closed Lost';
            opp.Loss_Type__c = 'Declined';
            opp.Loss_Reason_Code__c = 'Reported credit below our minimum requirement;Excessive obligations in relation to income';
            update opp;
            return new PageReference('/' + opp.Id);
        }
        
        if (ResultT1 == 'No' && ResultT2 == 'Exception') {
            opp.StageName = 'Closed Lost';
            opp.Loss_Type__c = 'Declined';
            opp.Loss_Reason_Code__c = 'Reported credit below our minimum requirement;Excessive obligations in relation to income';
            update opp;
            return new PageReference('/' + opp.Id);
        }
        
        if (ResultT1 == 'Exception' && ResultT2 == 'Yes') {
            // Should not get to this point
        }
        
        if (ResultT1 == 'Exception' && ResultT2 == 'No') {
            opp.StageName = 'Closed Lost';
            opp.Loss_Type__c = 'Declined';
            opp.Loss_Reason_Code__c = 'Reported credit below our minimum requirement;Excessive obligations in relation to income';
            update opp;
            return new PageReference('/' + opp.Id);
        }
        
        if (ResultT1 == 'Exception' && ResultT2 == 'Exception') {
            // Should not get to this point
        }
        if(passbookResult == null)
        {
            opp.Passbook_Status__c = 'Exception';
            
            update opp;  
            return new PageReference('/' + opp.Id);  
        }
        if(passbookResult == 'Exception') {
            system.debug('++ theOpp ' + theOpp);
            system.debug('++ opp to be updated ' + opp);
            opp.Passbook_Status__c = 'Exception';
            opp.IA_Passbook_Override__c = IA_Passbook_Override;
            opp.IA_Passbook_Override_Reasons__c = theOpp.IA_Passbook_Override_Reasons__c;
            update opp;
            return new PageReference('/' + opp.Id);
        }
        return null;
    }
    
    // ******** Exception page elements below ********
   
    /*public PageReference RaiseException() {
        List<String> componentNameList = new List<String>{ 'Case-Exception' };
        List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        
        caseLayout = new LayoutWrapper((Metadata.Layout)components.get(0));
        
        List<Opp_to_Case_Mapping__c> mapFields = [SELECT Case_field_API_Name__c, Opp_Field_API_Name__c, Default_Value__c FROM Opp_to_Case_Mapping__c];
        string query = 'SELECT Id';
        for (Opp_to_Case_Mapping__c mapField : mapFields) {
            if (mapFIeld.Opp_Field_API_Name__c != null && mapField.Opp_Field_API_Name__c != '') {
                    query += ', ' + mapFIeld.Opp_Field_API_Name__c;
            }
        }
        query += ' FROM Opportunity WHERE Id = :oppId';
        System.debug(query);
        
        Opportunity fullOpp = Database.query(query);
        
        newCase = new Case();
        for (Opp_to_Case_Mapping__c mapField : mapFields) {
            if (mapField.Opp_Field_API_Name__c != null && mapField.Opp_Field_API_Name__c != '') {
                if (mapField.Opp_Field_API_Name__c.contains('.')) {
                    if (fullOpp.getSObject(mapField.Opp_Field_API_Name__c.split('\\.')[0]) != null) {
                        newCase.put(mapField.Case_field_API_Name__c, fullOpp.getSObject(mapField.Opp_Field_API_Name__c.split('\\.')[0]).get(mapField.Opp_Field_API_Name__c.split('\\.')[1]));
                    }
                } else {
                    if(fullOpp.get(mapField.Opp_Field_API_Name__c) != null)
                        newCase.put(mapField.Case_field_API_Name__c, fullOpp.get(mapField.Opp_Field_API_Name__c));
                }
            } else if (mapField.Default_Value__c != null && mapField.Default_Value__c != '') {
                newCase.put(mapField.Case_field_API_Name__c, mapField.Default_Value__c);
            }
        }
        newCase.Opportunity__c = fullOpp.Id;
        newCase.Description = MitigatingCircumstances;
        if (ResultT1 == 'Exception' && ResultT2 == 'Exception') {
            newCase.Subject = 'Back-End DTI Post-Funding;Mid FICO' + (MortgageType == 'Reverse Mortgage' ? ';Mortgage Type' : '');
            newCase.Exception_Reason__c = 'Back-End DTI Post-Funding;Mid FICO' + (MortgageType == 'Reverse Mortgage' ? ';Mortgage Type' : '');
        }
        if (ResultT1 == 'Yes' && ResultT2 == 'Exception') {
            newCase.Subject = 'Back-End DTI Post-Funding' + (MortgageType == 'Reverse Mortgage' ? ';Mortgage Type' : '');
            newCase.Exception_Reason__c = 'Back-End DTI Post-Funding' + (MortgageType == 'Reverse Mortgage' ? ';Mortgage Type' : '');
        }
        if (ResultT1 == 'Exception' && ResultT2 == 'Yes') {
            newCase.Subject = 'Mid FICO' + (MortgageType == 'Reverse Mortgage' ? ';Mortgage Type' : '');
            newCase.Exception_Reason__c = 'Mid FICO' + (MortgageType == 'Reverse Mortgage' ? ';Mortgage Type' : '');
        }
        newCase.Mortgage_Type__c = MortgageType == 'Amortizing' ? 'Amortizing' : 'Non-amortizing';
        
        PageReference pr = Page.OppQualificationException;
        pr.setRedirect(false);
        return pr;
    }*/
  
}