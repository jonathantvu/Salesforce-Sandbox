/**
 * Created by cveli on 1/28/2020.
 */

//https://unison-technology.atlassian.net/browse/BUS-155111183
public with sharing class UpdateSandboxIntegrationsEndpoints {

    public static void UpdateIntegrationsEndPoints() {

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        integer i= URL.getSalesforceBaseUrl().getHost().IndexOf('.');
        string sandboxName =  URL.getSalesforceBaseUrl().getHost().left(i);
        system.debug(sandboxName);

        //CV: this class won't update anything on production. The logic is exclusively to update sandboxes.


            List<EndpointsPerSandBox__mdt> endpoints = [select label, Configuration__c, Record_Label__c, Sanbox__c
                                                        from EndpointsPerSandBox__mdt where
                                                        Sanbox__c = 'anySandbox' or Sanbox__c = :sandboxName];

            for (EndpointsPerSandBox__mdt endpoint : endpoints) {

                if (endpoint.Sanbox__c != '') {

                    Map<String, Object> mapEndpoints = new Map<String, Object>();
                    system.debug(endpoint.Configuration__c);

                    List<string> configs = endpoint.Configuration__c.split('\n');
                    system.debug(configs.size());

                    for (string config : configs) {

                        List<string> values = config.split('=',2);
                        system.debug(values);
                        if (values.size() == 2) {
                            //mapEndpoints.put(values[0], values[1].left(values[1].length() - 1));
                            mapEndpoints.put(values[0], string.valueOf(values[1]).trim());
                        }

                    }
                    system.debug(endpoint);
                    system.debug(mapEndpoints);
                    if ((isSandbox) || (test.isRunningTest())) {
                        CreateUpdateMetadataUtils.createUpdateMetadata(endpoint.label, endpoint.Record_Label__c, mapEndpoints);
                    }
                }
        }
    }
}