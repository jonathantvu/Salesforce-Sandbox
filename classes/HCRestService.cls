/**********************************************************
 * Class        : HCRestService.cls
 * Test Class   : HCRestService_TEST.cls
 * Created Date : February 20, 2018
 * Modified by  : -
 * Modified Date: -
 * Objective    : This class provide methods for CreateSubmitOrders.page
 *
 *
 **********************************************************/ 

@RestResource(urlMapping='/HouseCanary/*')
global with sharing class HCRestService  {

    /**********************************************************
     * @name        : updateOrder
     * @date        : February 20, 2018
     * @description : This method will receive asynchrous/webhook updates or callouts from HC for status updates
     * @param       : String jsonString
     * @return      : void
     *
     *
     **********************************************************/ 
    @HttpPost
    global static void OrderValidation() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = '';
        OrdersRestHelper.HC_Message orderMessage = new OrdersRestHelper.HC_Message();
        if (req != null && req.requestBody != null){
            jsonStr = req.requestBody.toString();
            System.debug('***req: ' + jsonStr);
        
        
            orderMessage = (OrdersRestHelper.HC_Message)JSON.deserializeStrict(jsonStr, OrdersRestHelper.HC_Message.class);
            System.debug(' HCRestService ----  orderValidationAndReview');
            System.debug('***orderMessage: ' + orderMessage);
        }

        Webhook_Log__c log = new Webhook_Log__c();
        if (RestContext.request != null && RestContext.request.requestBody != null)
            log.Request_Body__c = RestContext.request.requestBody.toString();
        if (orderMessage != null){
            log.Customer_Order_Id__c = orderMessage.customer_order_id;
            log.Order_Id__c = orderMessage.order_id;
            if (String.isBlank(log.Request_Body__c)){
                log.Request_Body__c = '{' +
                                     '"message_type": "' + orderMessage.message_type + '",'+
                                     '"message_id": "' + orderMessage.message_id + '",'+
                                     '"order_id": "' + orderMessage.order_id + '",'+
                                     '"customer_order_id": "' + orderMessage.customer_order_id + '",'+
                                     '"new_status": "' + orderMessage.new_status + '"'+
                                     '"order_item_id": "' + orderMessage.order_item_id + '"'+
                                     '"customer_item_id": "' + orderMessage.customer_order_id + '"'+
                                     '"comment": "' + orderMessage.comment + '"'+
                                    '}';
            }
        }

        OrdersRestHelper orderRest = new OrdersRestHelper();
        
        //get related item
        if (orderMessage != null && String.isNotBlank(orderMessage.order_id)){
            OrdersRestHelper.OrderItem item = new OrdersRestHelper.OrderItem ();
            if (!System.Test.isRunningTest())
                item =  orderRest.retriveOrderItem(orderMessage.order_id);
            else
                item = ((List<OrdersRestHelper.OrderItem>)JSON.deserializeStrict(HCCalloutMockImpl.orderItemsResponse(orderMessage.customer_item_id).getBody(), List<OrdersRestHelper.OrderItem>.class)).get(0);

            if (item != null){
                if (orderMessage.new_status == 'ClientReview'){
                    if (item.process_item == null || (item.process_item != null && item.process_item)){
                        if (!System.Test.isRunningTest())
                            orderRest.UpdateOrderItem(orderMessage.order_id, String.valueOf(item.Id));
                    }

                    if (!System.Test.isRunningTest()){
                        //validate order
                        Boolean orderValidated = orderRest.ValidateOrder(orderMessage.order_id);
                    }
                }
    
                //update Property_Due_Diligence_Reports__c.House_Canary_Order_Validation_Results__c  field
                String pddrId = item.customer_item_id;
                List<Property_Due_Diligence_Reports__c> pddrList = [Select Id, House_Canary_Order_Validation_Results__c FROM Property_Due_Diligence_Reports__c
                                                                                    WHERE Id= :pddrId];
                if (pddrList != null && pddrList.size() > 0){
                    String validationResult = '';
                    if (item.validation_results != null && item.validation_results.size() > 0){
                        for (OrdersRestHelper.Validation_results result: item.validation_results){
                            validationResult += ' message: ' + result.message + ' \n ';
                            validationResult += ' detail: ' + result.detail + ' \n ';
                            validationResult += ' level: ' + result.level + ' \n ';
                            validationResult += ' can override: ' + result.can_override + ' \n\n\n ';
                        }
                    }

                    if (String.isNotBlank(validationResult)){
                        pddrList.get(0).House_Canary_Order_Validation_Results__c = validationResult;
                        try{
                            update pddrList.get(0);
                        }catch(Exception ex){
                            System.debug('An error was caught when Update Pddr: ' + ex.getMessage());
                        }
                    }
                }
                if (log != null){
                    try{
                        insert log;
                    }catch(Exception ex){
                        System.debug('An error was caught when Insert Log: ' + ex.getMessage());
                    }
                }
            }
        }
    }
}