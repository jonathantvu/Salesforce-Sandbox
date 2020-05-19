/**
 *  
 * @Created Date : 03-04-2017
 * @Authors      : StarrData
 */
public class APIConfigurationWrapper {
    
    // Public variable Declaration
    public String API_BASE_URL;
    public String API_ENDPOINT;
    public Map<String, String> defaultHeaders;
    public String apiOperation                  { 
        get;
        set {
            if(apiOperationEndpointMap.containsKey(value)) {
                API_ENDPOINT = apiOperationEndpointMap.get(value);
            }
        } 
    }
    
    Private Static Map<String, String> apiOperationEndpointMap  = 
        new Map<String, String>{SFUtilityClass.APIOperation.API_CREATE.name() => '/api/v1/{0}/salesforce_create',
                                SFUtilityClass.APIOperation.API_UPDATE.name() => '/api/v1/{0}/salesforce_create',
                                SFUtilityClass.APIOperation.API_DELETE.name() => '/api/v1/{0}/salesforce_delete/{1}'};
}