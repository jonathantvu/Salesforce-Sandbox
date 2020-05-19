public class Opp_VantagePoint_EXT 
{
    private Opportunity opp;
    public Boolean displayError {get;set;}
    public VantagePointAPI.PlaceOrderResponse placeOrderResponse {get; set;}
    
    public Opp_VantagePoint_EXT(ApexPages.StandardController sc)
    {
        this.opp = (Opportunity)sc.getRecord();   
        this.displayError = false;
        placeOrderResponse = new VantagePointAPI.PlaceOrderResponse();
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
    
    public PageReference createVantagePointOrder()
    {

        Savepoint sp;

        try
        {

            Opportunity oppty = 
                [
                    SELECT Property_County__c,Lien_Second_Lender_Balance__c,Encompass_Loan_Number__c, Co_Applicant3__c, Applicant3__c, Co_Applicant2__c, Applicant2__c, Co_Applicant__c, Applicant__c, Co_Applicant3__r.HomePhone, Co_Applicant3__r.Email, Co_Applicant3__r.Marital_Status__c, Co_Applicant3__r.LastName, Co_Applicant3__r.MiddleName, Co_Applicant3__r.FirstName, Co_Applicant3__r.LASERCA__Social_Security_Number__c, Applicant3__r.HomePhone, Applicant3__r.Email, Applicant3__r.Marital_Status__c, Applicant3__r.LastName, Applicant3__r.MiddleName, Applicant3__r.FirstName, Applicant3__r.LASERCA__Social_Security_Number__c, Co_Applicant2__r.HomePhone, Co_Applicant2__r.Email, Co_Applicant2__r.Marital_Status__c, Co_Applicant2__r.LastName, Co_Applicant2__r.MiddleName, Co_Applicant2__r.FirstName, Id, Co_Applicant2__r.LASERCA__Social_Security_Number__c, Applicant2__r.HomePhone, Applicant2__r.Email, Applicant2__r.Marital_Status__c, Applicant2__r.LastName, Applicant2__r.MiddleName, Applicant2__r.FirstName, Applicant2__r.LASERCA__Social_Security_Number__c, Co_Applicant__r.HomePhone, Co_Applicant__r.Email, Co_Applicant__r.Marital_Status__c, Co_Applicant__r.LastName, Co_Applicant__r.MiddleName, Co_Applicant__r.FirstName, Co_Applicant__r.LASERCA__Social_Security_Number__c, Property_Zip_Code__c, Property_State__c, Property_City__c, Property_Street_Number_and_Name__c, Lien_First_Lender_Balance__c, Home_Value__c, CloseDate, Applicant__r.HomePhone, Applicant__r.Email, Applicant__r.Marital_Status__c, Applicant__r.LastName, Applicant__r.MiddleName, Applicant__r.FirstName, Applicant__r.LASERCA__Social_Security_Number__c,UnisonProcessor__r.FirstName,UnisonProcessor__r.LastName,UnisonProcessor__r.Email,Wire_Account_Number__c,Wire_Bank_Address__c,Wire_Bank_City__c,Wire_Bank_State__c,Wire_Bank_To_Credit__c,Wire_Bank_Zip__c,ABA_Number__c
                    FROM Opportunity
                    WHERE Id = :this.opp.Id
                ];

            Wiring_Information__c winfo =
                [
                    SELECT Id,Account_Number__c,Address__c,Bank_Name__c,Routing_Number__c,CustomerState__c,Title_Company__c,Wire_City__c,Wire_Credit_To__c,Wire_State__c,Wire_Zipcode__c
                    from Wiring_Information__c where CustomerState__c = :oppty.Property_State__c and Title_Company__c = 'Vantage Point'
                ];
    
            placeOrderResponse = VantagePointHelper.PlaceOrder(oppty);

            if(placeOrderResponse.hasErrors == true)
            {
                return null;
            }

            sp = Database.setSavepoint();

            Property_Due_Diligence_Reports__c vantagePointOrder = new Property_Due_Diligence_Reports__c();
            vantagePointOrder.Name = 'VantagePoint Order - ' + String.valueOf(placeOrderResponse.FileID);
            vantagePointOrder.RecordTypeId = Schema.SObjectType.Property_Due_Diligence_Reports__c.getRecordTypeInfosByName().get(Label.VantagePoint_RT).getRecordTypeId();
            vantagePointOrder.VantagePoint_Order_Id__c = String.valueOf(placeOrderResponse.FileID);
            vantagePointOrder.Opportunity__c = oppty.Id;
            if(Url.getOrgDomainUrl().toExternalForm().contains ( 'unison-eos.my.salesforce.com' ) )
                insert vantagePointOrder;

            if(winfo!=null){
                oppty.Wire_Bank_Name__c = winfo.Bank_Name__c;
                oppty.Wire_Account_Number__c = winfo.Account_Number__c;
                oppty.Wire_Bank_Address__c = winfo.Address__c;
                oppty.Wire_Bank_City__c = winfo.Wire_City__c;
                oppty.Wire_Bank_State__c = winfo.Wire_State__c;
                oppty.Wire_Bank_Zip__c = winfo.Wire_Zipcode__c;
                oppty.ABA_Number__c = winfo.Routing_Number__c;    
            }  
            
            update oppty;
            ContactRolesUtility.createEscrowOfficerForVantage(oppty);
            
            this.displayError = false;
            return new PageReference('/' + vantagePointOrder.Id);
        } 
        catch(Exception ex) 
        {            
            ApexPages.addMessages(ex);
            Database.rollback(sp);

            this.displayError = true;
            return null;
        }
        
    }    
}