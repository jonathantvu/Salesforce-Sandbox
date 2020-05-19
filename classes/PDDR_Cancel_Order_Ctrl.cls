/**********************************************************
 * Class 	 	: PDDR_Cancel_Order_Ctrl.cls
 * Test Class 	: PDDR_Cancel_Order_Ctrl_TEST.cls
 * Created Date	: April 10, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: This class provide methods for PDDR_Cancel_Order.page
 *
 *
 **********************************************************/ 

public class PDDR_Cancel_Order_Ctrl  {

	private Property_Due_Diligence_Reports__c pddr{get;set;}
	@TestVisible
	private Boolean isCancelled {get;set;}

	public Boolean haveErrors {get;set;}

	public PDDR_Cancel_Order_Ctrl(ApexPages.StandardController stdController){
		this.pddr = (Property_Due_Diligence_Reports__c) stdController.getRecord();
		this.pddr = [Select Id, House_Canary_Status__c, House_Canary_Order_Id__c FROM Property_Due_Diligence_Reports__c Where Id =: this.pddr.Id];
		this.haveErrors = false;
		this.isCancelled = false;
	}

	public PageReference CancelOrder(){
		OrdersRestHelper helper = new OrdersRestHelper();
		if (!System.Test.isRunningTest()){
			isCancelled = helper.CancelOrder(String.valueOf(this.pddr.House_Canary_Order_Id__c));
		}

		if (!isCancelled){
			this.haveErrors = true;
			return null;
		}else{
			this.pddr.House_Canary_Status__c = 'Canceled';

			try{
				update this.pddr;
				this.haveErrors = false;
				return new PageReference('/' + pddr.Id);
			}catch(Exception ex){
				this.haveErrors = true;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'An error was caught when current record was updated: ' + ex.getMessage()));
			}

			return null;
		}
	}
}