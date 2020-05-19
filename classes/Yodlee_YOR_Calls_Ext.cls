/**********************************************************
 * @className   : Yodlee_YOR_Calls_Ext.cls
 * @testClass   : Yodlee_YOR_Calls_Ext_TEST.cls
 * @date        : May 11, 2018
 * @description : This class provide methods for Yodlee_YOR_Calls_VF.page. Page used as a bridge 
 *					between custom buttons() and Yodlee calls  										
 *
 *
 **********************************************************/ 

public class Yodlee_YOR_Calls_Ext  {

	private String callName {get;set;}
	private String yorId {get;set;}
	public Boolean displayError {get;set;}

	public Yodlee_YOR_Calls_Ext(){
		this.displayError = false;
		this.yorId = ApexPages.currentPage().getParameters().get('id');
		this.callName = ApexPages.currentPage().getParameters().get('action');
		System.debug('***callName: ' + callName);
		System.debug('***yorId: ' + yorId);
	}

	/******
	*
	* This method is used to check the action call type and run the right method
	*
	******/
	public PageReference init(){
		String returnedValue = '';
		String errorMessage = '';
		String yorIDPRefix = Yodlee_Order_Request__c.sobjecttype.getDescribe().getKeyPrefix();
		System.debug('***callName: ' + callName);
		
		Yodlee_Order_Request__c currentYor = [Select Id, Yodlee_Public_Id__c, Status__c from Yodlee_Order_Request__c Where Id = :this.yorId];

		if (currentYor != null && String.isNotBlank(currentYor.Yodlee_Public_Id__c)){
			if (callName == 'CheckOrderStatus')
				returnedValue = CheckOrderStatus(currentYor);
			else if (callName == 'RetriveOrder')
				returnedValue = RetriveOrder(currentYor);
			else if (callName == 'SendEmailReissue')
				returnedValue = SendEmailReissue(currentYor);

			System.debug('****returnedValue: ' + returnedValue);
			if (returnedValue.startsWith(yorIDPRefix) && (returnedValue.length() == 15 || returnedValue.length() == 18)){
				return new PageReference('/' + returnedValue);
			}else{
				errorMessage = returnedValue;
			}
		}else{
			errorMessage = 'The "Yodlee Public Id" field is empty.';
		}

		if (String.isNotBlank(errorMessage)){
			this.displayError = true;
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
			ApexPages.addMessage(msg);
		}
		return null;
	}

	/******
	*
	* This method is used to send user to standard Yodlee_Order_Request__c page
	*
	******/
	public PageReference BackToYOR(){
		return new PageReference('/' + this.yorId);
	}

	/******
	*
	* This method make a call to retrive the order status
	*
	******/
    public String CheckOrderStatus(Yodlee_Order_Request__c currentYor){
		YodleeAPI.CheckOrderStatusResponse response = YodleeHelper.CheckOrderStatus(currentYor.Yodlee_Public_Id__c);
			
		if (response != null && String.isNotBlank(response.value)){
			currentYor.Status__c = Decimal.valueOf(response.value);
			update currentYor;

			return String.valueOf(currentYor.Id);
		}else{
			return 'The response received is not valid.';
		}   
    }

	/******
	*
	* This method make a call to retrive the order status
	*
	******/
    public String RetriveOrder(Yodlee_Order_Request__c currentYor){
		YodleeAPI.CreateOrderResponseWrapper response = YodleeHelper.RetriveOrder(currentYor.Yodlee_Public_Id__c);
			
		System.debug('****RetriveOrder - response: ' + response);
		if (response != null && response.serverResponse != null && String.isNotBlank(response.serverResponse.status)){
			currentYor.Status__c = Decimal.valueOf(response.serverResponse.status); //update status
			update currentYor;

			return String.valueOf(currentYor.Id);
		}else{
			return 'The response received is not valid.';   
		}
	}

	/******
	*
	* This method make a call that allows the notification to be reissued without the need to restart the order process.
	*
	******/
	public String SendEmailReissue(Yodlee_Order_Request__c currentYor){
		YodleeAPI.EmailReIssueResponse response =  YodleeHelper.EmailReIssue(currentYor.Yodlee_Public_Id__c);

		if (response != null && String.isNotBlank(response.statusCode) != null)
			return String.valueOf(currentYor.Id);
		else
			return 'The response received is not valid.'; 
	}
}