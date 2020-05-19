/**
 * Created by cveli on 1/27/2020.
 */

public class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
    //CV: REFERENCE: https://www.sfdcpanther.com/create-update-custom-metadata-using-apex/

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);
        } else {
            System.debug(' fail : '+ result);
        }
    }

    public static void createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap){
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullName+'.'+label;
        customMetadata.label = label;


        for(String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key);
            customMetadata.values.add(customField);
        }

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        if (!test.isRunningTest()) {
            CreateUpdateMetadataUtils callback = new CreateUpdateMetadataUtils();
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
}


/*
Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
if (isSandbox) {

    string sandboxName = URL.getSalesforceBaseUrl().toExternalForm() ;
    system.debug(sandboxName);

    if (sandboxName.contains('EOSDEV'))
        sandboxName = 'EOSDEV';



    List<EndpointsPerSandBox__mdt> endpoints = [select label, Configuration__c, Record_Label__c, Sanbox__c from EndpointsPerSandBox__mdt where Sanbox__c = :sandboxName];

    for ( EndpointsPerSandBox__mdt endpoint: endpoints) {
        Map<String, Object> mapEndpoints = new Map<String, Object>();

        system.debug(endpoint.Configuration__c);

        List<string> configs = endpoint.Configuration__c.split('\n');
        system.debug(configs.size());

       for( string config : configs ) {

           List<string> values =  config.split('=');
           system.debug(values);
           if(values.size()==2) {
               mapEndpoints.put(values[0], values[1].left( values[1].length()-1) );
           }

       }
        system.debug(endpoint);
        system.debug(mapEndpoints);
        CreateUpdateMetadataUtils.createUpdateMetadata(endpoint.label,  endpoint.Record_Label__c, mapEndpoints);

    }
}
 */