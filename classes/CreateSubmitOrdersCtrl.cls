/**********************************************************
 * Class 	 	: CreateSubmitOrdersCtrl.cls
 * Test Class 	: CreateSubmitOrdersCtrl_TEST.cls
 * Created Date	: February 20, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: This class provide methods for CreateSubmitOrders.page
 *
 *
 **********************************************************/ 

public class CreateSubmitOrdersCtrl  {

	public Boolean insertionSucceed {get;set;}
	public Boolean haveErrors {get;set;}

	private final Opportunity oppty;
	@TestVisible private Property_Due_Diligence_Reports__c pddr {get;set;}

	@TestVisible
	Private String result {get;set;}
	
	public CreateSubmitOrdersCtrl(ApexPages.StandardController stdController){
		haveErrors = false;
		this.oppty = (Opportunity)stdController.getRecord();
		this.pddr = new Property_Due_Diligence_Reports__c();
		this.insertionSucceed = false;
		this.result = '';
	}


	/*****
	*
	*	This method is used to create a new Property_Due_Diligence_Reports__c
	*
	******/
	public void InsertPddrItem(){
		System.debug('Start -- CreateSubmitOrdersCtrl -- InsertPddrItem --');
		pddr = new Property_Due_Diligence_Reports__c();

		//get pddr mapping fields values
		List<HC_Pddr_Creation_Field_Mapping__mdt> fieldsVAlues = [Select Id, Pddr_Api_Field_Name__c, Pddr_Field_Value__c FROM HC_Pddr_Creation_Field_Mapping__mdt];
		System.debug('fieldsVAlues: ' + fieldsVAlues);

		//generate new pddr record
		Set<String> objectFields = Schema.SObjectType.Property_Due_Diligence_Reports__c.fields.getMap().keySet();
		for(HC_Pddr_Creation_Field_Mapping__mdt fieldVal: fieldsVAlues){
			if (objectFields.contains(String.valueOf(fieldVal.Pddr_Api_Field_Name__c).toLowerCase()))
				pddr.put(fieldVal.Pddr_Api_Field_Name__c, fieldVal.Pddr_Field_Value__c);
		}//end for
		pddr.Opportunity__c = oppty.Id;
		
		try{
			System.debug('pddr: ' + pddr);
			insert pddr;
			this.insertionSucceed = true;
			haveErrors = false;
			System.debug('CreateSubmitOrdersCtrl -- InsertPddrItem: ' + pddr);
		}catch(Exception ex){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'An error was caught when Insert a new Property Due Diligence Reports record: ' + ex.getMessage()));
			this.insertionSucceed = false;
			haveErrors = true;
		}
		
	}

	/*****
	*
	*	This method is used to submit a new order to HC
	*
	******/
	public PageReference createAndSubmitOrders(){
		
		//generate a new order for an exterior appraisal
		OrdersRestHelper orderRest = new OrdersRestHelper();
		OrdersRestHelper.Permission permission = new OrdersRestHelper.Permission();
		if (System.Test.isRunningTest()){
			permission = (OrdersRestHelper.Permission)JSON.deserializeStrict(HCCalloutMockImpl.permissionResponse().getBody(), OrdersRestHelper.Permission.class);
		}else
			permission = orderRest.CheckPermissions();
		System.debug('***permission: ' + permission);
		System.debug('***pddr: ' + pddr);
		if (permission.can_create_orders && pddr != null && pddr.Opportunity__c != null){
			String jsonToSend = orderRest.serializeOrder(pddr);
			//send json to send
			if (!System.Test.isRunningTest()){
				result = orderRest.SubmitOrders(jsonToSend);
			}
				
			if(result != ''){
				System.debug('****Result: ' + result);
				OrdersRestHelper.HC_Order orderResult = (OrdersRestHelper.HC_Order)System.JSON.deserializeStrict(result, OrdersRestHelper.HC_Order.class);
				pddr.House_Canary_Order_Id__c = orderResult.id;

				try{
					update pddr;
					return new PageReference('/' + pddr.Id);
				}catch(Exception ex){
					haveErrors = true;
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Property Due Diligence Reports record update has failed!'));
					return null;
				}
			}else{ 
				System.debug('result: ' + result);
				haveErrors = true;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,result));
				return null;
			}
		}else{
			haveErrors = true;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You do not have permissions to create orders!'));
		}	
		
		return null;	
	}
}