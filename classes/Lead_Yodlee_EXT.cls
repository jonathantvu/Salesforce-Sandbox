/**********************************************************
 * @className   : Lead_Yodlee_EXT.cls
 * @testClass   : Lead_Yodlee_EXT_TEST.cls
 * @date        : May 2, 2018
 * @description : This class provides extension methods for Lead_Yodlee_VF.page
 *
 *
 **********************************************************/ 

public class Lead_Yodlee_EXT {

	private Lead leadRec;
	public Boolean displayError {get;set;}
    
    public Lead_Yodlee_EXT(ApexPages.StandardController sc){
        this.leadRec = (Lead)sc.getRecord();   
		this.displayError = false;
    }

	/*****
	*
	*
	*
	******/
	public PageReference BackToLead(){
		return new PageReference('/' + this.leadRec.Id);
	}

	/******
	*
	* This method generate and submit a yodlee order record
	*
	******/
    public PageReference generateYodleeOrder(){
		Lead leadRecInfo = [Select ID, FirstName, LastName, Email, Co_Applicant_First_Name__c, Converted_Opportunity__c,
							 Co_Applicant_Last_Name__c, Is_there_Co_App__c, Co_Applicant_Email__c from Lead Where Id =: leadRec.Id];

        Id yodleeOrderId = YodleeHelper.CreateOrder(leadRecInfo);
		if (yodleeOrderId != null){
			return new PageReference('/' + YodleeOrderId);
		}else{
			this.displayError = true;
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that all required fields(First Name (Co), Last Name (Co), Email (Co)) are NOT NULL Or Empty.');
			ApexPages.addMessage(msg);

			return null;
		}
    }
}