/**********************************************************
 * @className   : Opp_Mercury_EXT.cls
 * @testClass   : Opp_Mercury_EXT_TEST.cls
 * @date        : May 31, 2018
 *
 *
 **********************************************************/ 

public class Opp_Mercury_EXT {

    private Opportunity opp;
    public Boolean displayError {get; set;}
    public List<SelectOption> propertyType {get; set;}
    public String selectedAmcCompany {get; set;}
    public String selectedProduct {get; set;}
    public String selectedPropertyType {get; set;}
    public String selectedRequirement {get; set;}
    public Opportunity dummyOpp {get; set;}
    public List<SelectOption> availableRequirementList {get; set;}
    
    public Boolean needConfirmation { get; set; }
    public Boolean showConfirmation { get; set; }
    public Boolean confirmationReceived { get; set; }
    
    private List<SelectOption> amcCompaniesP;
    public List<SelectOption> amcCompanies {
        get {
            if (amcCompaniesP == null) {
                amcCompaniesP = new List<SelectOption>();
                amcCompaniesP.add(new SelectOption('--None--', '-- Please select --'));
                amcCompaniesP.addAll(MercuryHelper.GetAMCCompanies());
            }
            return amcCompaniesP;
        }
    }
    private List<SelectOption> productListP;
    public List<SelectOption> productList {
        get {
            if (productListP == null) {
                productListP = new List<SelectOption>();
                productListP.add(new SelectOption('--None--', '-- Please select --'));
                productListP.addAll(MercuryHelper.GetTypesOfAppraisal());
            }
            return productListP;
        }
    }
    
    public final List<String> dmdCodes =  new List<String> { 'R1008', 'R1009', 'R1010' };
    public final List<String> reqTypes =  new List<String> { 'Appraisal - 1st', 'Appraisal - 2nd', 'Appraisal - 3rd' };

    public Opp_Mercury_EXT(ApexPages.StandardController sc)
    {
        confirmationReceived = false;
        needConfirmation = false;
        this.opp = (Opportunity)sc.getRecord();   
        this.displayError = false;
        selectedAmcCompany = '--None--';
        selectedProduct = '';
        selectedPropertyType = '';
        dummyOpp = new Opportunity();
        dummyOpp.Converted_Close_Date__c= Date.today().addDays(5);

        Schema.DescribeFieldResult fieldResult1 = Appraisal__c.Source__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();

        /*productList = new List<SelectOption>();
        productList.add(new SelectOption('FNMA 1004 Single Family Interior', 'FNMA 1004 Single Family Interior', false));
        productList.add(new SelectOption('FNMA 2055 Exterior', 'FNMA 2055 Exterior', false));
        productList.add(new SelectOption('FNMA 1025 Duplex', 'FNMA 1025 Duplex', false));
        productList.add(new SelectOption('FNMA 1073 Condo Interior', 'FNMA 1073 Condo Interior', false));*/

        // set property type dropdown values
        propertyType = new List<SelectOption>(); 

        Schema.DescribeFieldResult fieldResult2 = Opportunity.Property_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();

        for(Schema.PicklistEntry f : ple2)
        {
            propertyType.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        // get available requirements
        availableRequirementList = new List<SelectOption>();
        availableRequirementList.add(new SelectOption('', '-- Select Appraisal Requirement --'));
        boolean found = false;
        needConfirmation = true;
        selectedRequirement = '';
        for (Current_Conditions__c requirement : [SELECT Id, Code__c,Requirement__c, (SELECT Id FROM Appraisals__r) FROM Current_Conditions__c WHERE Opportunity__c = :this.opp.Id AND Code__c IN :dmdCodes AND Requirement__c IN :reqTypes]) {
            if (requirement.Appraisals__r.size() == 0) {
                if (requirement.Code__c == dmdCodes[0]) {
                    availableRequirementList = new List<SelectOption>();
                    availableRequirementList.add(new SelectOption(requirement.Id, requirement.Requirement__c));
                    found = true;
                    needConfirmation = false;
                    selectedRequirement = requirement.Id;
                }
                if (requirement.Code__c == dmdCodes[1]) {
                        availableRequirementList.add(new SelectOption(requirement.Id, requirement.Requirement__c));
                        found = true;
                        needConfirmation = false;
                        selectedRequirement = requirement.Id;
                }
                if (requirement.Code__c == dmdCodes[2]){
                        availableRequirementList.add(new SelectOption(requirement.Id, requirement.Requirement__c));
                        found = true;
                        needConfirmation = false;
                        selectedRequirement = requirement.Id;   
                }
            }
        }
        if (availableRequirementList.size() == 1 && !found)
        {
            // throw error message
            this.displayError = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No outstanding appraisal requirements could be found for this file.');
            ApexPages.addMessage(msg);
        }
        showConfirmation = false;
        confirmationReceived = false;

        generateStep = 0;
    }

    public void checkConfirmation()
    {
        showConfirmation = false;
        confirmationReceived = false;

        if(availableRequirementList.size() > 1 && selectedRequirement != null && selectedRequirement != '')
        {
            showConfirmation = true;
        }
    }

    public void confirmationProvided()
    {
        showConfirmation = false;
        confirmationReceived = true;
    }

    public void confirmationRefused()
    {
        showConfirmation = false;
        confirmationReceived = false;
        selectedRequirement = '';
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
    * This method generate and submit a mercury order appraisal
    *
    ******/
    public integer generateStep { get; set; }
    public Appraisal__c newAppraisal { get; set; }
    public PageReference generateOrderAppraisal()
    {
        // Modifying the Fields API Original_Agreed_Value__c
        Opportunity oppty = 
            [
                Select Property_Type__c, Encompass_Loan_Number__c, Owner.Name, Loan_Amount__c, Lien_First_Loan_Type__c, Id, Lien_First_Lender_Balance__c,
                Applicant__r.Name, Co_Applicant__r.Name,Applicant__r.Mercury_Phone__c,Applicant__r.Email,Final_OAV_Calculation__c,
                Property_Street_Number_and_Name__c, Property_City__c,Property_State__c,Property_Zip_Code__c,Property_County__c,UnisonProcessor__r.Name,UnisonProcessor__r.Phone,UnisonProcessor__r.Email
                FROM Opportunity 
                Where Id = :opp.Id
            ];

        oppty.Property_Type__c = selectedPropertyType;       

        if(selectedProduct == 'FNMA 2055 Exterior')
        { 
            newAppraisal = new Appraisal__c();
            newAppraisal.Appraisal_Ordered_Date__c = Date.today();
            newAppraisal.Source__c = selectedAmcCompany;
            newAppraisal.Opportunity__c = opp.Id;

            insert newAppraisal;

            return new PageReference('/' + newAppraisal.Id);
        }
        else
        {   
            Date dueDate = dummyOpp.Converted_Close_Date__c;
            String trackingId;
            if(Test.isRunningTest()){
                trackingId='true';
            }else{
                trackingId = MercuryHelper.GenerateOrderAppraisal(oppty, selectedProduct, dueDate, selectedAmcCompany);
            }
            if(trackingId != null)
            {   
                newAppraisal = new Appraisal__c();
                newAppraisal.Appraisal_Ordered_Date__c = Date.today();
                newAppraisal.Source__c = selectedAmcCompany;
                newAppraisal.Opportunity__c = opp.Id;
                newAppraisal.MercuryTrackingId__c = trackingId;
                if (selectedRequirement != '') {
                    newAppraisal.Requirement__c = selectedRequirement;
                }

                insert newAppraisal;

                generateStep = 1;
                return null;
            }
            else
            {
                this.displayError = true;
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to send appraisal order to Mercury service. Please contact an administrator if this error persists.');
                ApexPages.addMessage(msg);

                return null;
            }
        }
    }
    
    public PageReference generateOrderAppraisalStep2()
    {
        // Call AWS
        generateStep = 0;
        
        boolean awsSuccess; 
        if(Test.isRunningTest()){
            awsSuccess=false;
        }else{
            awsSuccess = MercuryAWSHelper.CallAWS(newAppraisal.Id);
        }
        if (awsSuccess) {  return new PageReference('/' + newAppraisal.Id);
        } else {
            this.displayError = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to send appraisal data to Unison appraisal receiving service. Please contact an administrator if this error persists.');
            ApexPages.addMessage(msg);
            
            return null;
        }
    }
}