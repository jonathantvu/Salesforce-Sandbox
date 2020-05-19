/**********************************************************
 * @className   : YodleeWebhook.cls
 * @testClass   : YodleeWebhook_TEST.cls
 * @date        : May 4
 * @description : This class is used as an event listener that will receive HTTP POST notifications of order status changes when orders reach "Pending", "Completed" or "Canceled" statuses.
 *
 *
 **********************************************************/ 

@RestResource(urlMapping='/Yodlee/*')
global with sharing class YodleeWebhook  {

	@HttpPost
	global static void UpdateOrderStatus(){
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = '';

		YodleeAPI.Webhook_Order webhookOrder = new YodleeAPI.Webhook_Order();
		if (req != null && req.requestBody != null){
            jsonStr = req.requestBody.toString();
            System.debug('***req: ' + jsonStr);

			//Create Log 
			YodleeAPI.CreateLogEntry(req.requestURI, 'POST', '', req.requestBody.toString(), '', '');

			//deserialize response
			webhookOrder = (YodleeAPI.Webhook_Order)JSON.deserializeStrict(jsonStr, YodleeAPI.Webhook_Order.class);
			System.debug(' YodleeWebhook ----  UpdateOrderStatus(): ');
            System.debug('***webhookOrder: ' + webhookOrder);

			if (webhookOrder != null && String.isNotBlank(webhookOrder.order_id)){
				//TODO: update the corresponding record with the new status
				List<Yodlee_Order_Request__c> yodleeOrdReqs = [Select Id, Status__c, Yodlee_Public_Id__c FROM Yodlee_Order_Request__c Where Yodlee_Public_Id__c =: webhookOrder.order_id];
				
				if (yodleeOrdReqs != null && yodleeOrdReqs.size() > 0 ){
					Yodlee_Order_Request__c currentYdr = yodleeOrdReqs.get(0);
					currentYdr.Status__c = Decimal.valueOf(webhookOrder.status);
					 
					update currentYdr;
				}
			}
		}
	}
}