public with sharing class AWS_OutboundMessageHelper
{
    public static void SendOutboundMessage(Set<String> recordIdSet, String mtdRecordName)
    {
        String errorMessage = '';

        List<AWS_Outbound_Message__mdt> outboundMessageInfoList =
        [
                SELECT Id, URL__c
                FROM AWS_Outbound_Message__mdt
                WHERE DeveloperName = :mtdRecordName
        ];
        system.debug('-outboundMessageInfoList ' +outboundMessageInfoList);
        system.debug('-running? ' + Test.isRunningTest());
        if (outboundMessageInfoList.size() > 0) {
            for (String recordId : recordIdSet) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(outboundMessageInfoList[0].URL__c);
                req.setMethod('POST');
                req.setBody('{"Id": "' + recordId + '"}');

                Httpresponse apiResponse;
                Http http = new Http();
                if(!Test.isRunningTest()) {
                    apiResponse = http.send(req);
                }
                //SpruceApi.CreateLogEntry(outboundMessageInfoList[0].URL__c, 'POST', '{"Id": "' + recordId + '"}', apiResponse.getBody(), String.valueOf(apiResponse.getStatusCode()), apiResponse.getStatus());
            }
        }
    }
}