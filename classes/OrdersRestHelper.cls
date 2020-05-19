/**********************************************************
 * Class 	 	: OrdersRestHelper.cls
 * Test Class 	: OrdersRestHelper_TEST.cls
 * Created Date	: February 19, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: This class provide methods to submit orders, verify orders and re-submit orders 
 *
 *
 **********************************************************/ 

global class OrdersRestHelper  {
	
	global HCConfig__mdt hcConfig {get;set;}
	
	global OrdersRestHelper(){
		//get config values
		hcConfig = getConfigItems();
	}

	/*********************************************** global Methods ***********************************************/

	/******
	*
	* This method is used to create a json string based
	*
	*******/
	global String serializeOrder(Property_Due_Diligence_Reports__c pddr){
		String jsonString = '{';

		//get mapping fields and generate map from them
		List<HC_Mapping_Field__mdt> mappingfields = [Select Id, Api_SF_Field_Name__c, Api_SF_Object_Name__c, Ext_Api_Field_Name__c, 
																Pddr_Lookup_API_Name__c, Default_Value__c FROM HC_Mapping_Field__mdt];
		
		Map<String, String> extFieldDefaultValue = new Map<String, String>(); //map for default values
		Map<String, List<String>> sfObjFieldsMap = new Map<String, List<String>>();	//map for pddr lookup relations and rel object api_field_name
		Map<String, Map<String, String>>  objectFieldsMap = new Map<String, Map<String, String>>(); //map external field to sf api object.field_Name
		for(HC_Mapping_Field__mdt mappingField: mappingfields){
			Map<String, String> objFieldmap = new Map<String, String>(); 
			objFieldmap.put(mappingField.Api_SF_Object_Name__c, mappingField.Api_SF_Field_Name__c);			
			
			objectFieldsMap.put(mappingField.Ext_Api_Field_Name__c, objFieldmap);

			//add default values in a separate map
			if ((mappingField.Api_SF_Field_Name__c == null || (mappingField.Api_SF_Field_Name__c != null && String.isBlank(mappingField.Api_SF_Field_Name__c))) 
																	&& mappingField.Default_Value__c != null && String.isNotBlank(mappingField.Default_Value__c)){
				String defaultValue = '';
				if (mappingField.Default_Value__c.toUpperCase() == 'TODAY()'){
					defaultValue = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
				}else{
					defaultValue = mappingField.Default_Value__c;
				}
				extFieldDefaultValue.put(mappingField.Ext_Api_Field_Name__c, mappingField.Default_Value__c);
			}

			//generate a map for all Property_Due_Diligence_Reports__c related objects and there fields
			if (String.isNotBlank(mappingField.Api_SF_Object_Name__c) 
									&& mappingField.Api_SF_Object_Name__c != 'Property_Due_Diligence_Reports__c'){
				String key = mappingField.Api_SF_Object_Name__c + '---' + mappingField.Pddr_Lookup_API_Name__c;
				if (sfObjFieldsMap.get(key) != null){
					sfObjFieldsMap.get(key).add(mappingField.Api_SF_Field_Name__c);
				}else
					sfObjFieldsMap.put(key, new List<String>{ mappingField.Api_SF_Field_Name__c });
			}
		}//end for

		//get all pddr related records
		Map<String, SObject> relRecordsMap = new Map<String, SObject>();
		for (String key: sfObjFieldsMap.keySet()){
			String apiObjName = key.split('---').get(0);
			String pddrLookup = '';
			if (key.split('---').size() > 1)
				pddrLookup = key.split('---').get(1);
			if (apiObjName != 'Property_Due_Diligence_Reports__c' && String.isNotBlank(pddrLookup)){

				String queryStr = 'Select Id, ';
				for (String objField: sfObjFieldsMap.get(key)){
					queryStr += objField + ', ';
				}//end for

				queryStr = queryStr.removeEnd(', ') + ' from ' + apiObjName + ' Where Id = \'' + pddr.get(pddrLookup) + '\' Limit 1';
				System.debug('****' + apiObjName + ' query str: ' + queryStr);
				relRecordsMap.put(apiObjName, Database.query(queryStr));
			}
		}//end for

		//generate json value
		Map<String, List<String>> extParentFieldsMap = new Map<String, List<String>>();
		Map<String, String> extFieldValueMap = new Map<String, String>();
		for(String extApiName: objectFieldsMap.keySet()){
			Map<String, String> sfObjFieldmap = objectFieldsMap.get(extApiName);
			String objApiName = (new List<String>(sfObjFieldmap.keySet())[0]); // SF obj Api Name
			String fieldApiName = sfObjFieldmap.get(objApiName);// SF field api name

			String extFieldValue = '';
			if (extFieldDefaultValue.get(extApiName) != null){ //get default value
				extFieldValue = extFieldDefaultValue.get(extApiName);
			}else{
				if (objApiName == 'Property_Due_Diligence_Reports__c'){
					extFieldValue = String.valueOf(pddr.get(fieldApiName));
				}else if(relRecordsMap.get(objApiName) != null){
					extFieldValue = String.valueOf(relRecordsMap.get(objApiName).get(fieldApiName));
				}
			}

			System.debug('***extApiName: ' + extApiName);
			if (extApiName.contains('.')){// add list of object {element : value} pair to json
				List<String> extNames = extApiName.split('\\.');
				System.debug('***extNames: ' + extNames);
				String parentFieldName = extNames.get(0);
				String childFieldName = '';
				if (extNames.size() > 1){
					childFieldName = extNames.get(1);

					if (extParentFieldsMap.get(parentFieldName) != null){
						extParentFieldsMap.get(parentFieldName).add(childFieldName);
					}else{
						extParentFieldsMap.put(parentFieldName, new List<String> {childFieldName});
					}

					//make field value relation;
					extFieldValueMap.put(extApiName, extFieldValue);
				}
			}else{ //add single element - value pair
				jsonString += '"' + extApiName + '" : "' + extFieldValue + '", ';
			}
		}//end for

		//get property HC mapping values
		List<HC_Property_Mapping_Value__mdt> propertyValues = [Select Id, Ext_Hc_Value__c, SF_Value__c FROM HC_Property_Mapping_Value__mdt];
		Map<String, String> propertyValuesMap = new Map<String, String>(); 
		for(HC_Property_Mapping_Value__mdt propVal: propertyValues){
			propertyValuesMap.put(propVal.SF_Value__c, propVal.Ext_Hc_Value__c);
		}// end for

		//add list of objects to json 
		for(String parentField: extParentFieldsMap.keySet()){
			jsonString += '"' + parentField + '": [{';
			for(String childField: extParentFieldsMap.get(parentField)){
				String key = parentField + '.' + childField;
				if (extFieldValueMap.get(key) != null){
					String sfValue = extFieldValueMap.get(key);
					if(childField == 'property_type'){
						sfValue = propertyValuesMap.get(extFieldValueMap.get(key));
					}

					jsonString += '"' + childField + '" : "' + sfValue + '", ';
				}
			}//end for

			jsonString = jsonString.removeEnd(', ') + '}], ';
		}//end for
	
		jsonString = jsonString.removeEnd(', ') + '}';

		System.debug('****jsonString: ' + jsonString);
		return jsonString;
	} 

	/******
	*
	* This method is used to Submit already created Orders to HC
	*
	*******/
	global String SubmitOrders(String jsonToSend){
		String result = '';
		//get config values
		String createOrderUrl = 'client-api/v1/orders/json/';

		//generate authorization header
		Blob headerValue = Blob.valueOf(hcConfig.Auth_User_Name__c + ':' + hcConfig.Auth_Password__c);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

		//generate Order to submit
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(hcConfig.End_Point__c + createOrderUrl);
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept','application/json');
		request.setHeader('Authorization', authorizationHeader);

		// Set the body as a JSON object
		request.setBody(jsonToSend);
		HttpResponse response = http.send(request);
		// Parse the JSON response
		if (response.getStatusCode() != 201) {
			System.debug('The status code returned was not expected: ' +
				response.getStatusCode() + ' ' + response.getStatus());
			result = 'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus();
		} else {
			System.debug(response.getBody());
			//result = 'ok';
			result = response.getBody();
		}

		return result;
	}

	/******
	*
	* This method is used to Validate
	*
	*******/
	global Boolean ValidateOrder(String orderId){
		Boolean isValidated = false;

		//get config values
		String orderItemUrl = 'client-api/v1/orders/' + orderId + '/accept';

		//generate authorization header
		Blob headerValue = Blob.valueOf(hcConfig.Auth_User_Name__c + ':' + hcConfig.Auth_Password__c);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		req.setEndpoint(hcConfig.End_Point__c + orderItemUrl);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Authorization', authorizationHeader);
		res = http.send(req);
		if(res.getstatusCode() == 204 && res.getbody() != null){
			System.debug('res.getBody(): ' + res.getBody());
			isValidated = true;
		}else{
			isValidated = false;
			System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
		}

		return isValidated;
	}

	/******
	*
	* This method is used to Cancel Order
	*
	*******/
	global Boolean CancelOrder(String orderId){
		Boolean isCancelled = false;

		//get config values
		String orderItemUrl = 'client-api/v1/orders/' + orderId + '/cancel ';

		//generate authorization header
		Blob headerValue = Blob.valueOf(hcConfig.Auth_User_Name__c + ':' + hcConfig.Auth_Password__c);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		req.setEndpoint(hcConfig.End_Point__c + orderItemUrl);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Authorization', authorizationHeader);
		res = http.send(req);
		if(res.getstatusCode() == 200 && res.getbody() != null){
			System.debug('res.getBody(): ' + res.getBody());
			isCancelled = true;
		}else{
			isCancelled = false;
			System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus()));
		}

		return isCancelled;
	}

	/******
	*
	* This method is used to Reject Order
	*
	*******/
	global Boolean RejectOrder(String orderId){
		Boolean isRejected = false;

		//get config values
		String orderItemUrl = 'client-api/v1/orders/' + orderId + '/reject ';

		//generate authorization header
		Blob headerValue = Blob.valueOf(hcConfig.Auth_User_Name__c + ':' + hcConfig.Auth_Password__c);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		req.setEndpoint(hcConfig.End_Point__c + orderItemUrl);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Authorization', authorizationHeader);
		res = http.send(req);
		if(res.getstatusCode() == 204 && res.getbody() != null){
			System.debug('res.getBody(): ' + res.getBody());
			isRejected = true;
		}else{
			isRejected = false;
			System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus()));
		}

		return isRejected;
	}

	/******
	*
	* This method is used to Submit already created Orders to HC
	*
	*******/
	global Boolean UpdateOrderItem(String orderId, String itemId){
		Boolean isUpdated = false;
		//get config values
		String orderItemUrl = 'client-api/v1/orders/' + orderId + '/items/bulk/';

		//generate authorization header
		Blob headerValue = Blob.valueOf(hcConfig.Auth_User_Name__c + ':' + hcConfig.Auth_Password__c);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		String jsonBody = '[{"id": "' + itemId + '", "process_item" : "true"}]';


		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		req.setEndpoint(hcConfig.End_Point__c + orderItemUrl);
		req.setMethod('PUT');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Authorization', authorizationHeader);
		req.setBody(jsonBody);
		res = http.send(req);
		if(res.getstatusCode() == 200 && res.getbody() != null){
			System.debug('res.getBody(): ' + res.getBody());
			isUpdated = true;
		}else{
			isUpdated = false;
			System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
		}

		return isUpdated;
	}


	/******
	*
	* This method is used to Get Orders Information
	*
	*******/
	global Permission CheckPermissions(){
		//get config values
		String createOrderUrl = 'client-api/v1/user/permissions';

		//generate authorization header
		Blob headerValue = Blob.valueOf(hcConfig.Auth_User_Name__c + ':' + hcConfig.Auth_Password__c);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);


		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Permission permissionToReturn = new Permission();
		Http http = new Http();
		req.setEndpoint(hcConfig.End_Point__c + createOrderUrl);
		req.setMethod('GET');
		req.setHeader('Accept','application/json');
		req.setHeader('Authorization', authorizationHeader);
		res = http.send(req);
		if(res.getstatusCode() == 200 && res.getbody() != null){
			System.debug('res.getBody(): ' + res.getBody());
			permissionToReturn = (Permission)JSON.deserializeStrict(res.getBody(), Permission.class);
		}else{
			System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus()));
		}
		return permissionToReturn;
	}

	/******
	*
	* This method is used to Get Order Item Information based on order id
	*
	*******/
	global OrderItem retriveOrderItem(String orderId){
		//get config values
		String orderItemUrl = 'client-api/v1/orders/' + orderId + '/items/';

		//generate authorization header
		Blob headerValue = Blob.valueOf(hcConfig.Auth_User_Name__c + ':' + hcConfig.Auth_Password__c);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);


		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		List<OrderItem> itemsToReturn = new List<OrderItem>();
		Http http = new Http();
		req.setEndpoint(hcConfig.End_Point__c + orderItemUrl);
		req.setMethod('GET');
		req.setHeader('Accept','application/json');
		req.setHeader('Authorization', authorizationHeader);
		req.setTimeout(12000);
		res = http.send(req);

		if(res.getstatusCode() == 200 && res.getbody() != null){
			System.debug('res.getBody(): ' + res.getBody());
			itemsToReturn = (List<OrderItem>)JSON.deserializeStrict(res.getBody(), List<OrderItem>.class);
		}else{
			System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
		}

		if (itemsToReturn != null && itemsToReturn.size() > 0)
			return itemsToReturn.get(0);

		return null;
	}

	/*********************************************** Private Methods ***********************************************/
	
	/*****
	*
	* This method is used to get HcConfig values
	*
	******/
	private HCConfig__mdt getConfigItems(){
		HCConfig__mdt hcConfig = [Select Id, End_Point__c, Auth_User_Name__c, Auth_Password__c from HCConfig__mdt Limit 1];
		return hcConfig;
	}

	/*********************************************** Wrappers ***********************************************/

	global class Permission{
		global Boolean can_view_all_orders {get;set;}
		global Boolean can_create_orders {get;set;}

		global Permission(){
			can_view_all_orders = false;
			can_create_orders = false;
		}
	}

	global class ClientReview{
		global String process_item {get;set;}
		global String validation_results {get;set;}

		global ClientReview(){
			this.process_item = '';
			this.validation_results = '';
		}
	}

	global class HC_Order{
		global String id {get;set;}
		global String customer_order_id {get;set;}
		global String name {get;set;}
		global String order_type {get;set;}
		global String intended_use {get;set;}
		global String inspection_partner {get;set;}
		global String valuation_partner {get;set;}
		global String status {get;set;}
		global String desired_delivery_date {get;set;}
		global String label {get;set;}
		global String created_at {get;set;}
		global String expected_delivery_date {get;set;}
		global String actual_delivery_date {get;set;}
		global String incoming_comments_count {get;set;}
		global String order_items_count {get;set;}
		global String order_items_to_process_count {get;set;}
		global String complete_order_items_count {get;set;}
		global String max_item_status {get;set;}
		global String can_cancel {get;set;}
		global String cancelled {get;set;}
		global String special_comments {get;set;}
		global String client_name {get;set;}
		global String client_address {get;set;}
		global String client_city {get;set;}
		global String client_state {get;set;}
		global String client_zipcode {get;set;}
		global String client_phone {get;set;}
		global String lender_name {get;set;}
		global String lender_address {get;set;}
		global String lender_city {get;set;}
		global String lender_state {get;set;}
		global String lender_zipcode {get;set;}
		global String lender_phone {get;set;}
		global List<OrderItem> items {get;set;}


		global HC_Order(){
			id= '';
			customer_order_id = '';
			name = '';
			order_type = '';
			intended_use = '';
			inspection_partner = '';
			valuation_partner = '';
			desired_delivery_date = '';
			label = '';
			created_at = '';
			expected_delivery_date = '';
			actual_delivery_date = '';
			incoming_comments_count = '';
			order_items_count = '';
			order_items_to_process_count = '';
			complete_order_items_count = '';
			max_item_status = '';
			can_cancel = '';
			cancelled = '';
			special_comments = '';
			client_name = '';
		}
	}

	global class OrderItem {
		public Integer id;
		public String customer_item_id;
		public String address;
		public String unit;
		public String city;
		public String state;
		public String zipcode;
		public String status;
		public String address_validation_status;
		public Boolean process_item;
		public String property_type;
		public Integer incoming_comments_count;
		public Boolean can_cancel;
		public Boolean can_request_revision;
		public List<Validation_results> validation_results;
		public List<Available_Downloadables> available_downloadables;
		public String evaluation_completion_date;
		public String inspection_completion_date;
		public String inspection_date;
		public Boolean cancelled;
		public Property_value property_value;
		public Block_histogram block_histogram;
	}

	public class Block_histogram {
		public List<Beds> beds;
		public List<Beds> gla;
		public List<Beds> price;
		public List<Beds> price_per_sqft_gla;
		public List<Baths> baths;
	}

	public class Property_value {
		public Integer price_lwr;
		public Integer price_upr;
		public Integer price_mean;
		public Double fsd;
	}

	public class Beds {
		public Integer bin_end;
		public Integer bin_count;
		public Integer bin_start;
	}

	public class Baths {
		public Double bin_end;
		public Integer bin_count;
		public Double bin_start;
	}

	public class Validation_results {
		public String message;
		public String detail;
		public String level;
		public Boolean can_override;
	}

	public class Available_Downloadables {
		public String key;
		public String display_name;
		public String output_file_name;
	}

	global class HC_Message{
		global String message_type {get;set;}
		global String message_id {get;set;}
		global String order_id {get;set;}
		global String customer_order_id {get;set;}
		global String new_status {get;set;}
		global String order_item_id {get;set;}
		global String customer_item_id {get;set;}
		global String comment {get;set;}
		global String comment_received {get;set;}

		public HC_Message(){
			message_type = '';
			message_id = '';
			order_id = '';
			customer_order_id = '';
			new_status = '';
			order_item_id = '';
			customer_item_id = '';
			comment = '';
			comment_received = '';
		}
	}
}