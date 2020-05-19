public with sharing class MercuryHelper 
{

    public static List<SelectOption> GetAMCCompanies()
    {
        Map<String, String> amcCompanyList = MercuryAPICustom.GetAMCCompanies();

        MercuryAPICustom.InsertAllLogs();

        List<SelectOption> toReturn = new List<SelectOption>();
        for (String key : amcCompanyList.keySet()) {
            toReturn.add(new SelectOption(key, amcCompanyList.get(key)));
        }
        return toReturn;
    }
    
    public static List<SelectOption> GetTypesOfAppraisal()
    {
        Map<String, String> appTypes = MercuryAPICustom.GetTypesOfAppraisal();

        MercuryAPICustom.InsertAllLogs();

        List<SelectOption> toReturn = new List<SelectOption>();
        for (String key : appTypes.keySet()) {
            toReturn.add(new SelectOption(key, appTypes.get(key)));
        }
        return toReturn;
    }

    public static String GenerateOrderAppraisal(Opportunity opp, String selectedProduct, Date dueDate, String selectedAmc)
    {
        String XMLPost = GenerateXMLPost(opp, selectedProduct, dueDate, selectedAmc);

        String trackingId = MercuryAPICustom.PlaceAppraisalOrderEx(XMLPost);

        MercuryAPICustom.InsertAllLogs();

        return trackingId;
    }

    public static MercuryAPICustom.GetCurrentStatusResponse GetCurrentStatus(String trackingId)
    {
        MercuryAPICustom.GetCurrentStatusResponse serverResponse = MercuryAPICustom.GetCurrentStatusXSiteClientEx(trackingId);

        return serverResponse;
    }

    public static String GenerateXMLPost(Opportunity opp, String selectedProduct, Date dueDate, String selectedAmc)
    {
        String mercuryPropertyType = '';

        if(opp.Property_Type__c == '2-4 Family')
        {
            mercuryPropertyType = '2 to 4 Unit Building';
        }
        else if(opp.Property_Type__c == 'Condominium')
        {
            mercuryPropertyType = 'Condominium';
        }
        else if(opp.Property_Type__c == 'PUD')
        {
            mercuryPropertyType = 'PUD';
        }
        else if(opp.Property_Type__c == 'Other')
        {
            mercuryPropertyType = 'Other';
        }
        else if(opp.Property_Type__c == 'Single-family detached')
        {
            mercuryPropertyType = 'SingleFamily';
        }
        else if(opp.Property_Type__c == 'Townhouse')
        {
            mercuryPropertyType = 'Townhouse';
        }

        String XMLPost = '' +
            '<REPORT FILENUM="" DESCRIPTION="Order">' +
                '<TRACKING>' +
                    '<APPRAISERID>' + MercuryAPICustom.SETTINGS.EntityID__c +'</APPRAISERID>' +
                    '<CLIENTGROUPID>28778</CLIENTGROUPID>' +
                    '<PAYMENTMETHOD>INVOICE</PAYMENTMETHOD>' +
                    '<ADDITIONAL_NOTIFICATION_RECIPIENTS>' + opp.Owner.Name + '</ADDITIONAL_NOTIFICATION_RECIPIENTS>' +
                    '<PLUGINREQUIRED>true</PLUGINREQUIRED>' +
                    '<ENVREQUIRED>false</ENVREQUIRED>' +
                    '<SUBMITTINGPARTYNAME>Unison</SUBMITTINGPARTYNAME>' +
                '</TRACKING>' +
                '<FORMS>' +
                    '<FORM FORMCODE="UA2" DESC="OrderForm">' +
                        '<FIELDS>' +
                            '<LOAN_TYPE ReadOnly="true">Conventional</LOAN_TYPE>' +
                            '<RUSH_ORDER>false</RUSH_ORDER>' +
                            '<LOAN_PURPOSE>Refinance</LOAN_PURPOSE>' +
                            '<LENDERCASENUMBER ReadOnly="true">' + opp.Encompass_Loan_Number__c + '</LENDERCASENUMBER>' +
                            '<CLIENT_FILE_NO/>' +
                            '<SUBLENCLIENT ReadOnly="true">Unison Home Ownership Investors</SUBLENCLIENT>' +
                            '<LENDERADDRESS1 ReadOnly="true">650 California St. Suite 1800</LENDERADDRESS1>' +
                            '<LENDERADDRESS2/>' +
                            '<LENDERCITY ReadOnly="true">San Francisco</LENDERCITY>' +
                            '<LENDERSTATE ReadOnly="true">CA</LENDERSTATE>' +
                            '<LENDERZIP ReadOnly="true">94568</LENDERZIP>' +
                            '<SUBBORROWER ReadOnly="true">'+ opp.Applicant__r.Name +'</SUBBORROWER>' +
                            '<BORROWERCONTACTTYPE1>Email</BORROWERCONTACTTYPE1>' +
                            '<BORROWERCONTACT1>'+ opp.Applicant__r.Email +'</BORROWERCONTACT1>'+
                            '<BORROWERCONTACTTYPE2>Mobile</BORROWERCONTACTTYPE2>' +
                            '<BORROWERCONTACT2>'+ opp.Applicant__r.Mercury_Phone__c +'</BORROWERCONTACT2>' +
                            '<COBORROWER ReadOnly="true">'+ opp.Co_Applicant__r.Name +'</COBORROWER>' +
                            '<COBORROWERCONTACTTYPE1>EMAIL</COBORROWERCONTACTTYPE1>' +
                            '<COBORROWERCONTACT1/>' +
                           '<SUBSALEPRICE ReadOnly="true">' +opp.Final_OAV_Calculation__c+'</SUBSALEPRICE>' +
                            '<LOAN_AMOUNT ReadOnly="true">' + opp.Lien_First_Lender_Balance__c + '</LOAN_AMOUNT>' +
                            '<SUBPROPADDRESS ReadOnly="true">'+ opp.Property_Street_Number_and_Name__c +'</SUBPROPADDRESS>' +
                            '<SUBCITY ReadOnly="true">'+ opp.Property_City__c +'</SUBCITY>' +
                            '<SUBSTATE ReadOnly="true">' + opp.Property_State__c + '</SUBSTATE>' +
                            '<SUBZIP ReadOnly="true">'+ opp.Property_Zip_Code__c +'</SUBZIP>' +
                            '<SUBCOUNTY ReadOnly="true">'+ opp.Property_County__c +'</SUBCOUNTY>' +
                            '<GDSTYPE>' + mercuryPropertyType + '</GDSTYPE>' +
                            '<RIGHTSAPPRAISED>Fee Simple</RIGHTSAPPRAISED>' +
                            '<PJYRBUILT/>' +
                            '<OCCUPANTTYPE>Owner</OCCUPANTTYPE>' +
                            '<DUE_DATE>' + dueDate + '</DUE_DATE>' +
                            '<SELECTED_AMC>' + selectedAmc +'</SELECTED_AMC>' +
                            '<TYPE_OF_APPRAISAL>' + selectedProduct + '</TYPE_OF_APPRAISAL>' +
            				'<CLIENTREVISED_NOTES>' +opp.UnisonProcessor__r.Name+    +opp.UnisonProcessor__r.Email+    +opp.UnisonProcessor__r.Phone+  '</CLIENTREVISED_NOTES>' +
                        '</FIELDS>' +
                    '</FORM>' +
                '</FORMS>' +
            '</REPORT>';
        
        return XMLPost;
    }
}