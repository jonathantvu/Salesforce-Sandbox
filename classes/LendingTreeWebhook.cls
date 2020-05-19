@RestResource(urlMapping='/LendingTree/*')
global with sharing class LendingTreeWebhook  
{
    @HttpPost
    global static void CreateLead()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = '';


        if (req != null && req.requestBody != null)
        {
            jsonStr = req.requestBody.toString();
            Id homeOwnerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();

            Dom.Document doc = new Dom.Document();
            doc.load(jsonStr);

            Dom.XMLNode rootXml = doc.getRootElement();
			 
            try 
            { 
                Lead newLead = new Lead();            
     
                newLead.Street = GetAttributeValue('ContactAddress', rootXml, 'ConsumerContactInformation', ''); 
                newLead.City = GetAttributeValue('ContactCity', rootXml, 'ConsumerContactInformation', ''); 
                newLead.State = GetAttributeValue('ContactState', rootXml, 'ConsumerContactInformation', ''); 
                newLead.PostalCode = GetAttributeValue('ContactZip', rootXml, 'ConsumerContactInformation', ''); 
                newLead.Email = GetAttributeValue('EmailAddress', rootXml, 'ConsumerContactInformation', ''); 
                newLead.Phone = GetAttributeValue('ContactPhone', rootXml, 'ConsumerContactInformation', ''); 
                newLead.FirstName = GetAttributeValue('FirstName', rootXml, 'ConsumerContactInformation', ''); 
                newLead.LastName = GetAttributeValue('LastName', rootXml, 'ConsumerContactInformation', ''); 
                newLead.Applicant_Birth_Date_Free_Response__c = GetAttributeValue('DateOfBirth', rootXml, 'ConsumerProfileInformation', ''); 
                newLead.LASERCA__SSN__c = GetAttributeValue('SSN', rootXml, 'ConsumerProfileInformation', ''); 
                newLead.Applicant_Credit_Score_Estimate__c = GetAttributeValue('AssignedCreditValue', rootXml, 'ConsumerProfileInformation', 'Credit'); 
                newLead.Purchase_Price__c = Decimal.valueOf(GetAttributeValue('PropertyPurchasePrice', rootXml, 'ConsumerProfileInformation', 'ProductProfileInformation')); 
                newLead.Home_Value__c = Decimal.valueOf(GetAttributeValue('PropertyValue', rootXml, 'ProductInformation', 'PropertyInformation')); 
                newLead.Property_City__c = GetAttributeValue('PropertyCity', rootXml, 'ProductInformation', 'PropertyInformation'); 
                newLead.Property_State__c = GetAttributeValue('PropertyState', rootXml, 'ProductInformation', 'PropertyInformation'); 
                newLead.Property_Zip_Code__c = GetAttributeValue('PropertyZip', rootXml, 'ProductInformation', 'PropertyInformation');
                if(!String.isBlank(GetAttributeValue('LoanAmount', rootXml, 'LoanInformation', ''))){
                	newLead.Loan_Amount__c = Decimal.valueOf(GetAttributeValue('LoanAmount', rootXml, 'LoanInformation', ''));    
                }
                if(!String.isBlank(GetAttributeValue('FirstMortgageBalance', rootXml, 'LoanInformation', ''))){
                	newLead.Lien_First_Lender_Balance__c = Decimal.valueOf(GetAttributeValue('FirstMortgageBalance', rootXml, 'LoanInformation', ''));    
                }
                if(!String.isBlank(GetAttributeValue('SecondMortgageBalance', rootXml, 'LoanInformation', ''))){
                	newLead.Lien_Second_Lender_Balance__c = Decimal.valueOf(GetAttributeValue('SecondMortgageBalance', rootXml, 'LoanInformation', ''));    
                }
                newLead.RecordTypeId = homeOwnerRecordTypeId;
                newLead.Company = newLead.FirstName + ' ' + newLead.LastName;

                Database.SaveResult[] srList = Database.insert(new Lead[]{newLead}, false);
				
                //res.responseBody = Blob.valueOf('The following record was successfully created: ' + srList[0].getId());
                res.addHeader('Content-Type', 'application/xml');
                res.responseBody = Blob.valueOf('<LTACK><ERRSTATUS><QFNAME>' + GetAttributeValue('TrackingNumber', rootXml, '', '') + '</QFNAME><ERRORNUM>0</ERRORNUM><ERRORDESCRIPTION>The following record was successfully created: ' + srList[0].getId() + '</ERRORDESCRIPTION></ERRSTATUS></LTACK>');
                //insert newLead;
            }
            catch(Exception e)
            {
                //res.responseBody = Blob.valueOf(e.getMessage() + '. Please contact your Salesforce Administrator.');
                res.addHeader('Content-Type', 'application/xml');
                res.responseBody = Blob.valueOf('<LTACK><ERRSTATUS><QFNAME>' + GetAttributeValue('TrackingNumber', rootXml, '', '') + '</QFNAME><ERRORNUM>0</ERRORNUM><ERRORDESCRIPTION>' + e.getMessage() + '. Please contact your Salesforce Administrator.</ERRORDESCRIPTION></ERRSTATUS></LTACK>'); 
            }
        }
    }

    global static String GetAttributeValue(String attributeName, Dom.XMLNode rootXml, String rootSubnode, String rootSubnodeChildren)
    {
        String attributeValue = '';

        if(rootSubnodeChildren == '' && rootSubnode == '')
        {
        	attributeValue = rootXml.getChildElement(attributeName, null).getText();    
        }
        else if(rootSubnodeChildren == '')
        { 
            attributeValue = rootXml.getChildElement(rootSubnode, null).getChildElement(attributeName, null).getText();
        }
        else
        {
            attributeValue = rootXml.getChildElement(rootSubnode, null).getChildElement(rootSubnodeChildren, null).getChildElement(attributeName, null).getText();
        }

        return attributeValue;
    }
}