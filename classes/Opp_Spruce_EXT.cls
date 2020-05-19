/**********************************************************
 * @className   : Opp_Spruce_EXT.cls
 * @testClass   : Opp_Spruce_EXT_TEST.cls
 * @author      : Omnivo Digital (www.omnivodigital.com)
 * @date        : May 31, 2018
 *
 *
 **********************************************************/ 

public class Opp_Spruce_EXT {

    private Opportunity opp;

    public Boolean displayError {get;set;}
    
    public Opp_Spruce_EXT(ApexPages.StandardController sc)
    {
        this.opp = (Opportunity)sc.getRecord();   
        this.displayError = false;
    }

    /******
    *
    * This method is used to send user to standard Opportunity page
    *
    ******/
    public PageReference BackToOppty()
    {
        return new PageReference('/' + this.opp.Id);
    }
    

    /******
    *
    * This method is to generate and submit a Spruce Refinance Title Order
    *
    ******/
    public PageReference createSpruceOrder()
    {
        Savepoint sp;
        
        try 
        {
            /* 4/2/2019 Sundar Subramaniam - Replaced Proposed_Total_Mortgage_Debt__c with Post_Close_Mortgage_Debt__c for Data Model Cleanup */
            Opportunity oppty = 
                [
                    Select Applicant__c, Post_Close_Mortgage_Debt__c,Home_Value__c,Property_Street_Number_and_Name__c,Property_City__c,
                    Property_State__c,Property_Zip_Code__c,Applicant__r.Email,Applicant__r.FirstName,Applicant__r.LastName,Applicant__r.Mercury_Phone__c,
                    Is_there_Co_App__c,Co_Applicant__r.Email, Co_Applicant__r.FirstName,Co_Applicant__r.LastName,Co_Applicant__r.Mercury_Phone__c,Encompass_Loan_Number__c,Wire_Bank_Name__c,
                    Wire_Account_Number__c,Wire_Bank_Address__c,Wire_Bank_City__c,Wire_Bank_State__c,Wire_Bank_To_Credit__c,Wire_Bank_Zip__c,Title_Company_Name__c,UnisonProcessor__r.Spruce_Portal_User_Id__c
                    FROM Opportunity 
                    Where Id = :this.opp.Id
                ];

            List<Wiring_Information__c> winfo = [
                    SELECT Id,Account_Number__c,Address__c,Bank_Name__c,Routing_Number__c,CustomerState__c,Title_Company__c,Wire_City__c,Wire_Credit_To__c,Wire_State__c,Wire_Zipcode__c
                    from Wiring_Information__c where CustomerState__c = :oppty.Property_State__c and Title_Company__c = 'Spruce' LIMIT 1
                ];

            Property__c property = [
                SELECT Id,Property_Parcel_Number__c,Property_Legal_Description__c from Property__c where Opportunity__c = :this.opp.Id
            ];

            Recorded_Information__c recInfo = [
                SELECT Id,Effective_Date__c from Recorded_Information__c where Opportunity__c =: this.opp.Id
            ];
            
            // if no error, the function will return an empty string (ex: '')
            String errorMessage = CheckRequiredFields(oppty);
            
            if(errorMessage != '')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please fill the following opportunity fields: ' + errorMessage + '.'));
                this.displayError = true;
                return null;                
            }

            SpruceAPI.CreateRefinanceTransactionTitleOrderResponse RTTOrderResponse = SpruceHelper.CreateRefinanceTransactionTitleOrder(oppty);
            System.debug('This is Spruceresponse'+RTTOrderResponse);

            if(RTTOrderResponse.errorMessage != null && RTTOrderResponse.errorMessage != '' && !Test.isRunningTest())
            {
                if(RTTOrderResponse.errorMessage == 'Response error message : Invalid Address - Response status code: 400')
                {
                    RTTOrderResponse.errorMessage = Label.InvalidAddress;
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, RTTOrderResponse.errorMessage));
                this.displayError = true;
                return null;                
            }

            sp = Database.setSavepoint();

            //'TITLE - CLOSING'
            Property_Due_Diligence_Reports__c spruceOrder = new Property_Due_Diligence_Reports__c();
            spruceOrder.Name = 'Spruce Order - ' + RTTOrderResponse.Id;
            spruceOrder.RecordTypeId = Schema.SObjectType.Property_Due_Diligence_Reports__c.getRecordTypeInfosByName().get(Label.Property_Due_Diligence_Rep_RT_Spruce).getRecordTypeId();
            spruceOrder.Spruce_Order_Id__c = RTTOrderResponse.Id;
            spruceOrder.Status__c = RTTOrderResponse.order_status;
            spruceOrder.Property_Legal_Description__c = property.Property_Legal_Description__c;
            spruceOrder.Effective_Date__c = recInfo.Effective_Date__c;
            spruceOrder.Property_Parcel_Number__c = property.Property_Parcel_Number__c;
            spruceOrder.Opportunity__c = oppty.Id;
            
            //calculate fees
            List<String> feesList = Label.Spruce_Integration_Fees.split(',');
            decimal fees = 0;
            //Fee_Management__c objFM = new Fee_Management__c(Id=oppty.FeeManagment__c);

            Product2 settlementfee = [SELECT Id from Product2 where name = 'Settlement Fee' LIMIT 1];
            PricebookEntry pricebookentryrec= [select id, name, Pricebook2Id, Pricebook2.name from pricebookentry where name='Settlement Fee' and Pricebook2.name='Fee' LIMIT 1];
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppty.Id,Product2=settlementfee,Quantity=1,PricebookEntryId =pricebookentryrec.Id);
            
            for(SpruceAPI.Fees fee :RTTOrderResponse.fees )
            {
                // Using a comma-separated custom label to match all the fees labels we need to include (Spruce Integration Fees custom label)
                if (feesList.contains(fee.label)) 
                { 
                    fees += double.valueOf(fee.amount);
                }
            }

            //objFM.Settlement_Closing_Escrow_Fee__c = fees;
            oli.UnitPrice = fees;
            oppty.Property_Report_Ordered_Date_Time__c = datetime.now();
            
            //Create or Connect Settlement Agent/Title Company Account
            Account titleCoAccount = new Account();     
            List<Account> existingTitleAccounts = new List<Account>();
            Boolean hasLicenseInfo = false;

            if(RTTOrderResponse.settlement_agent != null && RTTOrderResponse.settlement_agent.license_info != null && RTTOrderResponse.settlement_agent.license_info.state_license_id != null)
            {
                hasLicenseInfo = true;

                existingTitleAccounts = 
                    [
                        SELECT Id 
                        FROM Account 
                        WHERE Spruce_State_License_ID__c = :RTTOrderResponse.settlement_agent.license_info.state_license_id LIMIT 1
                    ];
            }
            else
            {
                hasLicenseInfo = false;
            }
            
            if( existingTitleAccounts.isEmpty() )
            {           
                titleCoAccount.Name = RTTOrderResponse.settlement_agent.name;  
                titleCoAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Account_RT_Title_Company).getRecordTypeId();
                
                if(hasLicenseInfo == true)
                {
                    titleCoAccount.Spruce_State_License_ID__c = RTTOrderResponse.settlement_agent.license_info.state_license_id;
                }
                else
                {
                    titleCoAccount.Spruce_State_License_ID__c = null;
                }

                titleCoAccount.BillingStreet = RTTOrderResponse.settlement_agent.address.street_address + ' ' + RTTOrderResponse.settlement_agent.address.unit;
                titleCoAccount.BillingCity = RTTOrderResponse.settlement_agent.address.city;
                titleCoAccount.BillingState = RTTOrderResponse.settlement_agent.address.state;
                titleCoAccount.BillingPostalCode = RTTOrderResponse.settlement_agent.address.zip_code; 
                titleCoAccount.Phone = RTTOrderResponse.settlement_agent.phone;
                upsert titleCoAccount;
            }
            else
            {
                titleCoAccount = existingTitleAccounts[0];
            }
                            
            //Create or Connect Settlement Agent/Title Company Contact        
            Contact titleCoContact = new Contact();        
            //Contact License IDs seem to be coming back null, so we will match on First/Last Name + email
            //List<Contact> existingTitleContacts = [SELECT Id FROM Contact WHERE AccountId=:titleCoAccount AND Spruce_Contact_License_ID__c=:RTTOrderResponse.settlement_agent.license_info.contact_license_id LIMIT 1];
            List<Contact> existingTitleContacts = 
                [
                    SELECT Id 
                    FROM Contact 
                    WHERE AccountId=:titleCoAccount.Id 
                    AND FirstName = :RTTOrderResponse.settlement_agent.contact.first_name 
                    AND LastName = :RTTOrderResponse.settlement_agent.contact.last_name 
                    AND Email = :RTTOrderResponse.settlement_agent.email LIMIT 1
                ];
            
            if( existingTitleContacts.isEmpty() )
            {           
                titleCoContact.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.Contact_RT_Title_Company).getRecordTypeId();
                titleCoContact.AccountId = titleCoAccount.Id;
                titleCoContact.Spruce_Contact_License_ID__c = RTTOrderResponse.settlement_agent.license_info.contact_license_id;
                titleCoContact.FirstName = RTTOrderResponse.settlement_agent.contact.first_name;
                titleCoContact.LastName = RTTOrderResponse.settlement_agent.contact.last_name;
                titleCoContact.Email = RTTOrderResponse.settlement_agent.email;        
                titleCoContact.Spruce_Account_Number__c = RTTOrderResponse.settlement_agent.wiring_instructions.account_number;
                titleCoContact.Spruce_Routing_Number__c = RTTOrderResponse.settlement_agent.wiring_instructions.routing_number;
                titleCoContact.Spruce_OBI__c = RTTOrderResponse.settlement_agent.wiring_instructions.obi;
                    
                upsert titleCoContact;
            }
            else
            {
                titleCoContact = existingTitleContacts[0];
            }

            oppty.Settlement_Agent__c = titleCoContact.Id;
            
            if(!winfo.isEmpty()){
                oppty.Wire_Bank_Name__c = winfo[0].Bank_Name__c;
                oppty.Wire_Account_Number__c = winfo[0].Account_Number__c;
                oppty.Wire_Bank_Address__c = winfo[0].Address__c;
                oppty.Wire_Bank_City__c = winfo[0].Wire_City__c;
                oppty.Wire_Bank_State__c = winfo[0].Wire_State__c;
                oppty.Wire_Bank_Zip__c = winfo[0].Wire_Zipcode__c;
                oppty.ABA_Number__c = winfo[0].Routing_Number__c;
                oppty.Title_Company_Name__c = winfo[0].Title_Company__c;    
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There is no wiring information found for the state and title company' ));
                this.displayError = true;
                return null; 
            }
       
            update oppty;
            ContactRolesUtility.createEscrowOfficerForSpruce(oppty);
            insert oli;
            //update objFM;


            //if (Url.getOrgDomainUrl().toExternalForm().contains ( 'unison-eos.my.salesforce.com' ))
                insert spruceOrder;
            
            this.displayError = false;
            return new PageReference('/' + spruceOrder.Id);
        } 
        catch(Exception ex) 
        {                       
            string errorString = ex.getMessage() + '|' + ex.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, errorString));            
            if (sp != null)
                Database.rollback(sp);
            this.displayError = true;
            return null;
        }
        
    }    

    public String CheckRequiredFields(Opportunity oppty)
    {
        String missingFieldInfo = '';

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Opportunity');
        Map<String, Schema.SObjectField> opportunityFieldMap = leadSchema.getDescribe().fields.getMap();
        /* 4/2/2019 Sundar Subramaniam - Replaced Proposed_Total_Mortgage_Debt__c with Post_Close_Mortgage_Debt__c for Data Model Cleanup */
        if(oppty.Post_Close_Mortgage_Debt__c == null)
        {
            /* 4/2/2019 Sundar Subramaniam - Replaced Proposed_Total_Mortgage_Debt__c with Post_Close_Mortgage_Debt__c for Data Model Cleanup */
            missingFieldInfo += opportunityFieldMap.get('Post_Close_Mortgage_Debt__c').getDescribe().getLabel() + ', ';
        } 

        if(oppty.Home_Value__c == null)
        {
            missingFieldInfo += opportunityFieldMap.get('Home_Value__c').getDescribe().getLabel() + ', ';
        }

        if(oppty.Encompass_Loan_Number__c == null)
        {
            missingFieldInfo += opportunityFieldMap.get('Encompass_Loan_Number__c').getDescribe().getLabel() + ', ';
        }

        if(oppty.Property_Street_Number_and_Name__c == null)
        {
            missingFieldInfo += opportunityFieldMap.get('Property_Street_Number_and_Name__c').getDescribe().getLabel() + ', ';
        }

        if(oppty.Property_City__c == null)
        {
            missingFieldInfo += opportunityFieldMap.get('Property_City__c').getDescribe().getLabel() + ', ';
        }

        if(oppty.Property_State__c == null)
        {
            missingFieldInfo += opportunityFieldMap.get('Property_State__c').getDescribe().getLabel() + ', ';
        }

        if(oppty.Property_Zip_Code__c == null)
        {
            missingFieldInfo += opportunityFieldMap.get('Property_Zip_Code__c').getDescribe().getLabel() + ', ';
        }

        if(oppty.Applicant__c == null)
        {
            missingFieldInfo += 'Applicant, ';
        }

        if(oppty.Applicant__c != null && oppty.Applicant__r.Email == null)
        {
            missingFieldInfo += 'Applicant\'s Email, ';
        }

        if(oppty.Applicant__c != null && oppty.Applicant__r.FirstName == null)
        {
            missingFieldInfo += 'Applicant\'s First Name, ';
        }

        if(oppty.Applicant__c != null && oppty.Applicant__r.LastName == null)
        {
            missingFieldInfo += 'Applicant\'s Last Name, ';
        }
        /*if(oppty.FeeManagment__c == null)
        {
            missingFieldInfo += 'Fee Management, ';
        }*/       
        

        missingFieldInfo = missingFieldInfo.removeEnd(', ');

        return missingFieldInfo;
    }
}