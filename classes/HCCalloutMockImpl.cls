/**********************************************************
 * Class 	 	: HCCalloutMockImpl.cls
 * Created Date	: February 19, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: This class provide methods to replace callouts for OrdersRestHelper_TEST, HCRestService_TEST and CreateSubmitOrdersCtrl_TEST test methods
 *
 *
 **********************************************************/ 
 
 @isTest
global class HCCalloutMockImpl implements HttpCalloutMock {
    
	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
       res.setBody('{'+
			'"id": 107,' +
			'"customer_order_id": "a1P2F000000QuivUAC",'+
			'"name": "Property Test1",'+
			'"order_type": "devFakeInspectAndEvaluate",'+
			'"intended_use": "test",'+
			'"inspection_partner": 4,'+
			'"valuation_partner": 5,'+
			'"special_comments": null,'+
			'"client_name": "Unison Home Ownership Investments",'+
			'"client_address": "650 California St",'+
			'"client_city": "San Francisco",'+
			'"client_state": "CA",'+
			'"client_zipcode": "94108",'+
			'"client_phone": "(415) 992-4200",'+
			'"lender_name": null,'+
			'"lender_address": null,'+
			'"lender_city": null,'+
			'"lender_state": null,'+
			'"lender_zipcode": null,'+
			'"lender_phone": null,'+
			'"desired_delivery_date": "2018-02-21",'+
			'"label": "Appraisal",'+
			'"items": ['+
				'{'+
					'"id": 135,'+
					'"customer_item_id": "a1P2F000000QuivUAC",'+
					'"address": "741 Venice Way Apt 7",'+
					'"unit": null,'+
					'"city": "Inglewood",'+
					'"state": "CA",'+
					'"zipcode": "90302",'+
					'"property_type": "condo"'+
				'}'+
			']'+
		'}');
        res.setStatusCode(201);
        return res;
    }

	global static HTTPResponse permissionResponse(){
		// Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
		res.setBody('{'+
						'"can_view_all_orders": true,'+
						'"can_create_orders": true'+
					'}');
		res.setStatusCode(200);
        return res;
	}

	global static HTTPResponse SubmitOrderResponse(){
		// Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
		res.setBody('{'+
			'"id": 107,' +
			'"customer_order_id": "a1P2F000000QuivUAC",'+
			'"name": "Property Test1",'+
			'"order_type": "devFakeInspectAndEvaluate",'+
			'"intended_use": "test",'+
			'"inspection_partner": 4,'+
			'"valuation_partner": 5,'+
			'"special_comments": null,'+
			'"client_name": "Unison Home Ownership Investments",'+
			'"client_address": "650 California St",'+
			'"client_city": "San Francisco",'+
			'"client_state": "CA",'+
			'"client_zipcode": "94108",'+
			'"client_phone": "(415) 992-4200",'+
			'"lender_name": null,'+
			'"lender_address": null,'+
			'"lender_city": null,'+
			'"lender_state": null,'+
			'"lender_zipcode": null,'+
			'"lender_phone": null,'+
			'"desired_delivery_date": "2018-02-21",'+
			'"label": "Appraisal",'+
			'"items": ['+
				'{'+
					'"id": 135,'+
					'"customer_item_id": "a1P2F000000QuivUAC",'+
					'"address": "741 Venice Way Apt 7",'+
					'"unit": null,'+
					'"city": "Inglewood",'+
					'"state": "CA",'+
					'"zipcode": "90302",'+
					'"property_type": "condo"'+
				'}'+
			']'+
		'}');

		res.setStatusCode(201);
        return res;
	}

	global static HTTPResponse orderItemsResponse(String customer_item_id){
		// Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
		res.setBody('['+
						'{'+
							'"id": 71,'+
							'"customer_item_id": "' + customer_item_id + '",'+
							'"address": "string",'+
							'"unit": "string",'+
							'"city": "string",'+
							'"state": "string",'+
							'"zipcode": "string",'+
							'"status": "",'+
							'"address_validation_status": null,'+
							'"process_item": null,'+
							'"property_type": "singlefamily",'+
							'"incoming_comments_count": 0,'+
							'"can_cancel": true,'+
							'"can_request_revision": false,'+
							'"validation_results": [{'+
									'"message": "string",'+
									'"detail": "string",'+
									'"level": "error",'+
									'"can_override": true'+
									'}],'+
							'"available_downloadables": [],'+
							'"evaluation_completion_date": null,'+
							'"inspection_completion_date": null,'+
							'"cancelled": null,'+
							'"property_value": null,'+
							'"block_histogram": null'+
						'}'+
					']');

		res.setStatusCode(201);
        return res;
	}
}