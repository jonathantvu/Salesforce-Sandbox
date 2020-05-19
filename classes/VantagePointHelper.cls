public with sharing class VantagePointHelper 
{
	public static VantagePointAPI.PlaceOrderResponse PlaceOrder(Opportunity opp)
    {
        VantagePointAPI.PlaceOrderRequest request = new VantagePointAPI.PlaceOrderRequest();

        //Seller is always Unison and Transaction Sepecialist details need to be provided 
        VantagePointAPI.sellers seller = new VantagePointAPI.sellers();
        seller.EntityType = 'INDIVIDUAL';
        seller.Primary.First = opp.UnisonProcessor__r.FirstName;        
        seller.Primary.Last = opp.UnisonProcessor__r.LastName;
        seller.UsePropertyAddress = false;
        seller.Company = 'Unison Home Ownership Investors';
        seller.Address.Address1 = '650 California St';
        seller.Address.City = 'San Francisco';
        seller.Address.State = 'CA';
        seller.Address.Zip = '94108';
        seller.Email = opp.UnisonProcessor__r.Email;
        seller.HomePhone = '4159924200'; 
        

        /*
        * buyer info is the client details that needed to be sent to Vantage Point
        * buyer Array --- There could be up to 6 Sellers on an opportunity as defined by the following lookups: Applicant__c, Co_Applicant__c, Applicant2__c, Co_Applicant2__c, Applicant3__c, Co_Applicant3__c. 
        * Logic should check whether each of these Contact lookups is present and if so, add the contact to the Sellers array in the JSON
        * Applicant should always be the set is IsPrimaryTransactee=true, all others false
        */
    if(opp.Applicant__c != null)
        { 
            VantagePointAPI.buyers buyer = new VantagePointAPI.buyers();        
            buyer.EntityType = 'INDIVIDUAL';
            buyer.IsPrimaryTransactee = true;
            buyer.Primary.TaxID = opp.Applicant__r.LASERCA__Social_Security_Number__c;
            buyer.Primary.First = opp.Applicant__r.FirstName;
            buyer.Primary.Middle = opp.Applicant__r.MiddleName;        
            buyer.Primary.Last = opp.Applicant__r.LastName;
            buyer.UsePropertyAddress = true;
            buyer.Address.Address1 = opp.Property_Street_Number_and_Name__c;
            buyer.Address.City = opp.Property_City__c;
            buyer.Address.State = opp.Property_State__c;
            buyer.Address.Zip = opp.Property_Zip_Code__c;
            buyer.MaritalStatus = opp.Applicant__r.Marital_Status__c;
            buyer.Email = opp.Applicant__r.Email;
            buyer.HomePhone = opp.Applicant__r.HomePhone;
            request.buyers.add(buyer);
        }

        if(opp.Applicant2__c != null)
        { 
            VantagePointAPI.buyers buyer = new VantagePointAPI.buyers();        
            buyer.EntityType = 'INDIVIDUAL';
            buyer.IsPrimaryTransactee = false;
            buyer.Primary.TaxID = opp.Applicant2__r.LASERCA__Social_Security_Number__c;
            buyer.Primary.First = opp.Applicant2__r.FirstName;
            buyer.Primary.Middle = opp.Applicant2__r.MiddleName;        
            buyer.Primary.Last = opp.Applicant2__r.LastName;
            buyer.UsePropertyAddress = true;
            buyer.Address.Address1 = opp.Property_Street_Number_and_Name__c;
            buyer.Address.City = opp.Property_City__c;
            buyer.Address.State = opp.Property_State__c;
            buyer.Address.Zip = opp.Property_Zip_Code__c;
            buyer.MaritalStatus = opp.Applicant2__r.Marital_Status__c;
            buyer.Email = opp.Applicant2__r.Email;
            buyer.HomePhone = opp.Applicant2__r.HomePhone;
            request.buyers.add(buyer);
        }

        if(opp.Applicant3__c != null)
        { 
            VantagePointAPI.buyers buyer = new VantagePointAPI.buyers();        
            buyer.EntityType = 'INDIVIDUAL';
            buyer.IsPrimaryTransactee = false;
            buyer.Primary.TaxID = opp.Applicant3__r.LASERCA__Social_Security_Number__c;
            buyer.Primary.First = opp.Applicant3__r.FirstName;
            buyer.Primary.Middle = opp.Applicant3__r.MiddleName;        
            buyer.Primary.Last = opp.Applicant3__r.LastName;
            buyer.UsePropertyAddress = true;
            buyer.Address.Address1 = opp.Property_Street_Number_and_Name__c;
            buyer.Address.City = opp.Property_City__c;
            buyer.Address.State = opp.Property_State__c;
            buyer.Address.Zip = opp.Property_Zip_Code__c;
            buyer.MaritalStatus = opp.Applicant3__r.Marital_Status__c;
            buyer.Email = opp.Applicant3__r.Email;
            buyer.HomePhone = opp.Applicant3__r.HomePhone;
            request.buyers.add(buyer);
        }

        if(opp.Co_Applicant__c != null)
        { 
            VantagePointAPI.buyers buyer = new VantagePointAPI.buyers();        
            buyer.EntityType = 'INDIVIDUAL';
            buyer.IsPrimaryTransactee = false;
            buyer.Primary.TaxID = opp.Co_Applicant__r.LASERCA__Social_Security_Number__c;
            buyer.Primary.First = opp.Co_Applicant__r.FirstName;
            buyer.Primary.Middle = opp.Co_Applicant__r.MiddleName;        
            buyer.Primary.Last = opp.Co_Applicant__r.LastName;
            buyer.UsePropertyAddress = true;
            buyer.Address.Address1 = opp.Property_Street_Number_and_Name__c;
            buyer.Address.City = opp.Property_City__c;
            buyer.Address.State = opp.Property_State__c;
            buyer.Address.Zip = opp.Property_Zip_Code__c;
            buyer.MaritalStatus = opp.Co_Applicant__r.Marital_Status__c;
            buyer.Email = opp.Co_Applicant__r.Email;
            buyer.HomePhone = opp.Co_Applicant__r.HomePhone;
            request.buyers.add(buyer);
        }

        if(opp.Co_Applicant2__c != null)
        { 
            VantagePointAPI.buyers buyer = new VantagePointAPI.buyers();        
            buyer.EntityType = 'INDIVIDUAL';
            buyer.IsPrimaryTransactee = false;
            buyer.Primary.TaxID = opp.Co_Applicant2__r.LASERCA__Social_Security_Number__c;
            buyer.Primary.First = opp.Co_Applicant2__r.FirstName;
            buyer.Primary.Middle = opp.Co_Applicant2__r.MiddleName;        
            buyer.Primary.Last = opp.Co_Applicant2__r.LastName;
            buyer.UsePropertyAddress = true;
            buyer.Address.Address1 = opp.Property_Street_Number_and_Name__c;
            buyer.Address.City = opp.Property_City__c;
            buyer.Address.State = opp.Property_State__c;
            buyer.Address.Zip = opp.Property_Zip_Code__c;
            buyer.MaritalStatus = opp.Co_Applicant2__r.Marital_Status__c;
            buyer.Email = opp.Co_Applicant2__r.Email;
            buyer.HomePhone = opp.Co_Applicant2__r.HomePhone;
            request.buyers.add(buyer);
        }

        if(opp.Co_Applicant3__c != null)
        { 
            VantagePointAPI.buyers buyer = new VantagePointAPI.buyers();        
            buyer.EntityType = 'INDIVIDUAL';
            buyer.IsPrimaryTransactee = false;
            buyer.Primary.TaxID = opp.Co_Applicant3__r.LASERCA__Social_Security_Number__c;
            buyer.Primary.First = opp.Co_Applicant3__r.FirstName;
            buyer.Primary.Middle = opp.Co_Applicant3__r.MiddleName;        
            buyer.Primary.Last = opp.Co_Applicant3__r.LastName;
            buyer.UsePropertyAddress = true;
            buyer.Address.Address1 = opp.Property_Street_Number_and_Name__c;
            buyer.Address.City = opp.Property_City__c;
            buyer.Address.State = opp.Property_State__c;
            buyer.Address.Zip = opp.Property_Zip_Code__c;
            buyer.MaritalStatus = opp.Co_Applicant3__r.Marital_Status__c;
            buyer.Email = opp.Co_Applicant3__r.Email;
            buyer.HomePhone = opp.Co_Applicant3__r.HomePhone;
            request.buyers.add(buyer);
        }
        
        string streetNumber = '';
        string streetName = opp.Property_Street_Number_and_Name__c;
        if (streetName != null) {
            streetName = streetName.trim();
            List<String> streetNameItems = streetname.split(' ', 2);
            if (streetNameItems.size() > 1) {
                if (streetNameItems[0].isNumeric()) {
                    streetNumber = streetNameItems[0];
                    streetName = streetNameItems[1];
                }
            }
        }
            
        VantagePointAPI.Property property = new VantagePointAPI.Property();
        property.IsPrimary = true;
        property.StreetName = streetName;
        property.StreetNumber = streetNumber;
        property.City = opp.Property_City__c;
        property.State = opp.Property_State__c;
        property.Zip = opp.Property_Zip_Code__c;    
        property.County = opp.Property_County__c;
        request.Properties.add(Property);

        /*
        * Loans Array ---- There could be 0, 1 or 2 loans here. Check the Lien First Lender Balance and Lien Second Lender Balance. If both are null, there should be no loans. If only Lien First Lender Balance is present, then there will only be one loan. If Lien First Lender Balance AND Lien Second Lender Balance are present, then there will be 2 loans.
        * Lien Position for Lien First Lender Balance is 0, Lien Position for Lien Second Lender Balance is 1.
        * Loan amount should be mapped from Lien First Lender Balance or Lien Second Lender Balance depending on which loan it is
        * LoanType is “FIRST MORTGAGE” for First Lender and “SECOND MORTGAGE” for Second Lender
        */

        if(opp.Lien_First_Lender_Balance__c != null)
        { 
            VantagePointAPI.Loans loan = new VantagePointAPI.Loans();
            loan.LienPosition = 0;
            loan.LoanAmount = opp.Lien_First_Lender_Balance__c;
            loan.LoanType = 'FIRST MORTGAGE';
            request.Loans.add(loan);
        }

        if(opp.Lien_First_Lender_Balance__c != null && opp.Lien_Second_Lender_Balance__c != null)
        { 
            VantagePointAPI.Loans loan = new VantagePointAPI.Loans();
            loan.LienPosition = 1;
            loan.LoanAmount = opp.Lien_Second_Lender_Balance__c;
            loan.LoanType = 'SECOND MORTGAGE';
            request.Loans.add(loan);
        }
        
        request.Sellers.add(seller);        
        request.EstimatedSettlementDate = String.valueOf(opp.CloseDate);
        request.ClientFileNumber = opp.Encompass_Loan_Number__c;
        request.TransactionProductType.TransactionTypeID = 5;
        request.TransactionProductType.ProductTypeID = 8;
        request.SettlementStatementVersion = 'CD';
        request.SalesPrice = opp.Home_Value__c;
        request.EncompassLoanNumber = opp.Encompass_Loan_Number__c;

        VantagePointAPI.PlaceOrderResponse response = VantagePointAPI.PlaceOrder(request);

        return response;
    }
}