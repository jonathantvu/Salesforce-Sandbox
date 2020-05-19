/**
 * LOP Connector Helper class handels all LOP Portal related operations.
 * @Created Date : 03-04-2017
 * @Authors      : StarrData
 */
global with sharing class LOPConnectorUtility {
    
    private enum LOPResourceName { USERS, LENDERS, SALES_DIRECTORS }
    
    private Static APIConfigurationWrapper config = new APIConfigurationWrapper();  
    
    private static SFUtilityResult resultObj;
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> createLOPUsers(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {            
            String jsonBody = prepareJSON(true, SFObjectName, sObj);
            HttpResponse responce;
            //Temp work around for Testing
            if(!System.Test.isRunningTest()) {
                responce = createLOPRecord(jsonBody, LOPResourceName.USERS);
            }
            else{
                responce = new HttpResponse();
            }
            SFUtilityResultList.add(prepareLOPResponseResult(false, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> updateLOPUsers(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {            
            String jsonBody = prepareJSON(false, SFObjectName, sObj);
            HttpResponse responce;
            //Temp work around for Testing
            if(!System.Test.isRunningTest()) {
                responce = updateLOPRecord(jsonBody, LOPResourceName.USERS);
            }
            else{
                responce = new HttpResponse();
            }
            SFUtilityResultList.add(prepareLOPResponseResult(false, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> deleteLOPUsers(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {
            HttpResponse responce;
            //Temp work around for Testing
            if(!System.Test.isRunningTest()) {
                responce = deleteLOPRecord((String) sObj.get('Id'), LOPResourceName.USERS);
            }
            else{
                responce = new HttpResponse();
            }
            SFUtilityResultList.add(prepareLOPResponseResult(true, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> createLOPLenders(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) { 
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {             
            String jsonBody = prepareJSON(true, SFObjectName, SFRecords[0]);
            HttpResponse responce = createLOPRecord(jsonBody, LOPResourceName.LENDERS);
            SFUtilityResultList.add(prepareLOPResponseResult(false, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> updateLOPLenders(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {             
            String jsonBody = prepareJSON(false, SFObjectName, SFRecords[0]);
            HttpResponse responce = updateLOPRecord(jsonBody, LOPResourceName.LENDERS);                
            SFUtilityResultList.add(prepareLOPResponseResult(false, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> deleteLOPLenders(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {             
            HttpResponse responce = deleteLOPRecord((String)sObj.get('Id'), LOPResourceName.LENDERS);                
            SFUtilityResultList.add(prepareLOPResponseResult(true, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> createLOPSalesDirectors(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {             
            String jsonBody = prepareJSON(true, SFObjectName, SFRecords[0]);
            HttpResponse responce;
            //Temp work around for Testing
            if(!System.Test.isRunningTest()) {
                responce = createLOPRecord(jsonBody, LOPResourceName.SALES_DIRECTORS);
            }
            else{
                responce = new HttpResponse();
            }
            SFUtilityResultList.add(prepareLOPResponseResult(false, sObj, responce));
        }
        return SFUtilityResultList;
    }    
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> updateLOPSalesDirectors(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {             
            String jsonBody = prepareJSON(false, SFObjectName, SFRecords[0]);
            HttpResponse responce;
            //Temp work around for Testing
            if(!System.Test.isRunningTest()) {
                responce = updateLOPRecord(jsonBody, LOPResourceName.SALES_DIRECTORS);
            }
            else{
                responce = new HttpResponse();
            }
            SFUtilityResultList.add(prepareLOPResponseResult(false, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * 
     * @Param       -
     * @Returns     -
     */
    public Static List<SFUtilityResult> deleteLOPSalesDirectors(SFUtilityClass.LOP_SFResourceName SFObjectName, List<sObject> SFRecords) {
        
        List<SFUtilityResult> SFUtilityResultList = new List<SFUtilityResult>();
        for(sObject sObj : SFRecords) {
            HttpResponse responce;
            //Temp work around for Testing
            if(!System.Test.isRunningTest()) {
                responce = deleteLOPRecord((String) sObj.get('Id'), LOPResourceName.SALES_DIRECTORS);
            }
            else{
                responce = new HttpResponse();
            }
            SFUtilityResultList.add(prepareLOPResponseResult(true, sObj, responce));
        }
        return SFUtilityResultList;
    }
    
    /** 
     * Method is used to prepare SFUtilityResult instance.
     * @Param       isDelete, specifies operation isDelete or not.
     * @Param       sObj, to prepare SFUtilityResult instance.
     * @Param       responce, to prepare SFUtilityResult instance.
     * @Returns     SFUtilityResult
     */
    public static SFUtilityResult prepareLOPResponseResult(Boolean isDelete, sObject sObj, HttpResponse responce) {
        resultObj = new SFUtilityResult();
        resultObj.isSuccess = (responce.getStatusCode() == 200);
        resultObj.displayMessage = responce.getStatus();
        resultObj.result = new List<Object>{sObj};
            
        if(!resultObj.isSuccess) {
            resultObj.displayMessage += ' : ';
            String responseBody = responce.getBody();
            String strMessage = 'No Details From LOP';
            if(!String.isEmpty(responseBody)) {
                try {
                    Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    if(responseBodyMap.containsKey('error') || responseBodyMap.containsKey('message')) {
                        strMessage = String.valueOf((isDelete) ? responseBodyMap.get('error') : responseBodyMap.get('message'));
                    }
                } catch(Exception exp) {
                    SFUtilityClass.logMessageFromException(exp);
                }
            }
            resultObj.displayMessage += strMessage;
        }
        return resultObj;
    }
    
    /** 
     * Method for prepare JSON string used while creating or updating LOP records.
     * @Param       isCreate, specifies the operation is create or update.
     * @Param       SFObjectName, contains SF onject API name.
     * @Param       SFsObject, sObject for bind Field values while preparing JSON.
     * @Returns     JSON String.
     */
    public static string prepareJSON(Boolean isCreate, SFUtilityClass.LOP_SFResourceName SFObjectName, sObject SFsObject) {   
        Map<string, string> RemoteObjectFieldMap = new Map<string, string>();
        List<LOP_Field_Map__c> fieldMappingsBySFObject = 
            new List<LOP_Field_Map__c>([SELECT SF_Field_API_Name__c, LOP_Field_API_Name__c, 
                                               Static_Value__c, SF_Object__c, LOP_Object__c 
                                        FROM LOP_Field_Map__c 
                                        WHERE SF_Object__c = :SFObjectName.name()
                                        ORDER BY Static_Value__c]);
        
        for(LOP_Field_Map__c field : fieldMappingsBySFObject) {
            
            if(String.isEmpty(field.Static_Value__c)) {
                if(!String.isEmpty(field.SF_Field_API_Name__c) ) {
                    if(field.LOP_Field_API_Name__c.equalsIgnoreCase('first_time')) {
                    	RemoteObjectFieldMap.put(field.LOP_Field_API_Name__c, String.valueOf(!Boolean.valueOf(SFsObject.get(field.SF_Field_API_Name__c))));
                    } else {
                        RemoteObjectFieldMap.put(field.LOP_Field_API_Name__c, String.valueOf(SFsObject.get(field.SF_Field_API_Name__c)));
                    }
                }           
            } else {
                if(!(!isCreate && field.LOP_Field_API_Name__c.equalsIgnoreCase('Password'))) {
                    RemoteObjectFieldMap.put(field.LOP_Field_API_Name__c, field.Static_Value__c);
                }
            }
        }        
        return JSON.serialize(RemoteObjectFieldMap);
    }
    
    /** 
     * method for create LOP record.
     * @Param       jsonBody, salesforce Record in form of JSON to update LOP record.
     * @Param       resourceName, contains LOP resource name.
     * @Returns     HttpResponse
     */
    private static string getLOPEndPoint(){
        string result = '';
        List<LOPEndpointURL__mdt> endpoint = [select value__c
        from LOPEndpointURL__mdt where label = 'LOPEndpointURL'];
        if (endpoint.size()>0)
            result = endpoint[0].value__c;
        return result;
    }
    public Static HttpResponse createLOPRecord(string jsonBody, LOPResourceName resourceName) {
        
        config.API_BASE_URL = getLOPEndPoint();
        config.apiOperation = SFUtilityClass.APIOperation.API_CREATE.name();
        config.API_ENDPOINT = string.format(config.API_ENDPOINT, new List<String>{resourceName.name().toLowerCase()});
        config.defaultHeaders = new Map<String, String>{'Accept' => 'application/json',
                                                        'Content-Type' => 'application/json'};
        LOPGateway gateway = new LOPGateway(config);   
        return gateway.apiPost(jsonBody);
    }
    
    /** 
     * Method for update LOP record.
     * @Param       jsonBody, salesforce Record in form of JSON to update LOP record.
     * @Param       resourceName, contains LOP resource name.
     * @Returns     HttpResponse
     */
    public Static HttpResponse updateLOPRecord(string jsonBody, LOPResourceName resourceName) {
        
        config.API_BASE_URL = getLOPEndPoint();
        config.apiOperation = SFUtilityClass.APIOperation.API_UPDATE.name();
        config.API_ENDPOINT = string.format(config.API_ENDPOINT, new List<String>{resourceName.name().toLowerCase()});
        config.defaultHeaders = new Map<String, String>{'Accept' => 'application/json',
                                                        'Content-Type' => 'application/json'};
        LOPGateway gateway = new LOPGateway(config);
            
        return gateway.apiPost(jsonBody);
    }
    
    /** 
     * Method For Delete LOP Record.
     * @Param       SFRecordId, salesforce Record Id for Deletete related LOP record.
     * @Param       resourceName, contains LOP resource name.
     * @Returns     HttpResponse
     */
    public Static HttpResponse deleteLOPRecord(string SFRecordId, LOPResourceName resourceName) {
        
        config.API_BASE_URL = getLOPEndPoint();
        config.apiOperation = SFUtilityClass.APIOperation.API_DELETE.name();
        config.API_ENDPOINT = string.format(config.API_ENDPOINT, new List<String>
                                            { resourceName.name().toLowerCase(), SFRecordId });
        config.defaultHeaders = new Map<String, String>{'Accept' => 'application/json',
                                                        'Content-Type' => 'application/json'};
        LOPGateway gateway = new LOPGateway(config);
            
        return gateway.apiDelete();
    }
    
    
    //OLD DEPRECATED CLOUD NERD METHODS START HERE
    //
    //
    //
    //
    /*
    public static void getAccessToken(string pstrEmailid, string pstrPassword,integer pintFailureCount)
    {
        List<LOPtoken__c> lstLOPtoken=LOPtoken__c.getall().values();
        HttpRequest objHttpReq = new HttpRequest();
        objHttpReq.setHeader('Content-Type','application/x-www-form-urlencoded');
        objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/authorize/signin');
        objHttpReq.settimeout(120000);
        objHttpReq.setMethod('POST');
        objHttpReq.setbody('email='+pstrEmailid+'&password='+pstrPassword+'');
        Http http = new Http(); 
        HTTPResponse objHttpResp = http.send(objHttpReq);  
        system.debug('>>>>>>>objHttpResp.getBody()'+objHttpResp.getBody());   
                        
        if(objHttpResp.getstatuscode()==200 && objHttpResp.getstatus()=='OK')
        {
            system.debug('>>>>>>>objHttpResp.getBody()'+objHttpResp.getBody());  
            
            if(lstLOPtoken.size()!=0)
            {                           
                lstLOPtoken[0].Token__c=objHttpResp.getBody().replace('"','');              
                Update lstLOPtoken;
            }
            else
            {
                LOPtoken__c objLOPtoken= new LOPtoken__c();
                objLOPtoken.name='Token';
                objLOPtoken.Token__c=objHttpResp.getBody().replace('"','');
                lstLOPtoken.add(objLOPtoken);
                insert lstLOPtoken;
            }
        }
        else
        {
            if(pintFailureCount<50)
            {
                pintFailureCount++;
                getAccessToken(pstrEmailid,pstrPassword,pintFailureCount);
            }
            else
            {
                    
            }
        }       
    }

    public static string getAccessToken(string pstrEmailid, string pstrPassword)
    {
        List<LOPtoken__c> lstLOPtoken=LOPtoken__c.getall().values();
        HttpRequest objHttpReq = new HttpRequest();
        objHttpReq.setHeader('Content-Type','application/x-www-form-urlencoded');
        objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/authorize/signin');
        objHttpReq.settimeout(120000);
        objHttpReq.setMethod('POST');
        objHttpReq.setHeader('Content-Type','application/x-www-form-urlencoded');
        objHttpReq.setbody('email='+pstrEmailid+'&password='+pstrPassword+'');
        Http http = new Http(); 
        HTTPResponse objHttpResp = http.send(objHttpReq);  
        system.debug('>>>>>>>objHttpResp.getBody()'+objHttpResp.getBody());   
                        
        if(objHttpResp.getstatuscode()==200 && objHttpResp.getstatus()=='OK')
        {
            system.debug('>>>>>>>objHttpResp.getBody()'+objHttpResp.getBody());  
            return  string.valueof(objHttpResp.getBody()).replace('"','');
        }
        else
        {
          return null;
        }       
    }

    public static string createJSONFromRecord(Contact pobjContact,map<Id,User> pmapUserIdWithUser,map<Id,Account> pmapIdWithAccount)
    {   
        try
        {
            string strSalesDirector=pmapUserIdWithUser.containsKey(pobjContact.Sales_Director__c) && pmapUserIdWithUser.get(pobjContact.Sales_Director__c)!=null ? pmapUserIdWithUser.get(pobjContact.Sales_Director__c).Name : null;
            Integer intNMLS=pobjContact.NMLS__c!=null?Integer.valueOf(pobjContact.NMLS__c):null;
            string strMobilePhone=pobjContact.MobilePhone!=null?string.valueof(pobjContact.MobilePhone):null;
            string strPhone=pobjContact.Phone!=null?string.valueof(pobjContact.Phone):null;

            System.debug('>>>>>>strSalesDirector'+strSalesDirector);
            System.debug('>>>>>>pobjContact'+pobjContact);          
            string strPOSTBody ='user[last_name]='+pobjContact.Lastname;
            if(pobjContact.Active_PMP__c==true) strPOSTBody+='&user[deleted]=0';
            else strPOSTBody+='&user[deleted]=1';
            if(pObjContact.Gender__c!=null) strPOSTBody+='&user[gender]='+pObjContact.Gender__c;
            if(pObjContact.Avatar__c!=null) strPOSTBody+='&user[picture]='+pObjContact.Avatar__c;     
            if(pobjContact.MailingStreet !=null) strPOSTBody+='&user[address][street_address]='+pobjContact.MailingStreet;
            if(pobjContact.MailingState!=null) strPOSTBody+='&user[address][state]='+pobjContact.MailingState;
            if(pobjContact.MailingCity!=null) strPOSTBody+='&user[address][city]='+pobjContact.MailingCity;
            if(pobjContact.MailingPostalCode!=null) strPOSTBody+='&user[address][postal_code]='+pobjContact.MailingPostalCode;        
            if(pObjContact.ApartmentNo__c!=null) strPOSTBody+='&user[address][apartment]='+pobjContact.ApartmentNo__c; 
            if(pObjContact.Portal_Password__c!=null)
            {
                strPOSTBody+='&user[password][password]='+pobjContact.Portal_Password__c;
                strPOSTBody+='&user[password][password_confirm]='+pobjContact.Portal_Password__c;
            }
            if(pObjContact.accountid!=null && pmapIdWithAccount.containsKey(pObjContact.accountid) 
                && pmapIdWithAccount.get(pObjContact.accountid).Base_CRM_ID__c!=null )
            {               
                Account objAccount=pmapIdWithAccount.get(pObjContact.accountid);
                strPOSTBody+= '&user[lender][id]='+objAccount.Base_CRM_ID__c+'';
                strPOSTBody+= '&user[lender][name]='+objAccount.Name+'';
            }
            if(pobjContact.Email!=null) strPOSTBody+='&user[email]='+pobjContact.Email;
            if(pobjContact.firstname!=null) strPOSTBody+='&user[first_name]='+pobjContact.firstname;
            if(strMobilePhone!=null) strPOSTBody+='&user[mobile]='+strMobilePhone;
            if(intNMLS!=null) strPOSTBody+='&user[nmls]='+intNMLS;
            if(strPhone!=null) strPOSTBody+= '&user[phone]='+strPhone;
            if(pobjContact.Title!=null) strPOSTBody+='&user[title]='+pobjContact.Title;
            if(strSalesDirector!=null) strPOSTBody+='&user[sales_director]='+strSalesDirector;
            if(pobjContact.Sales_Director_Email__c!=null) strPOSTBody+='&user[sales_director_email]='+pobjContact.Sales_Director_Email__c;
            if(pobjContact.Sales_Director_Phone__c!=null) strPOSTBody+='&user[sales_director_phone]='+pobjContact.Sales_Director_Phone__c;
            if(pobjContact.MailingCountry!=null)
                strPOSTBody+='&user[address][formatted_address]='+pobjContact.MailingStreet+','
                                                                +pobjContact.MailingCity+','
                                                                +pobjContact.MailingPostalCode+','
                                                                +pobjContact.MailingState+','
                                                                +pobjContact.MailingCountry;
            else
                strPOSTBody+='&user[address][formatted_address]='+pobjContact.MailingStreet+','
                                                                +pobjContact.MailingCity+','
                                                                +pobjContact.MailingState+','
                                                                +pobjContact.MailingPostalCode;
            string strFirstTime=pobjContact.Signed_PMP__c==true?'1':'0';
            strPOSTBody+='&user[first_time]='+strFirstTime;
            if(pobjContact.LOP_Role__c!=null)
            strPOSTBody+='&user[roles][]='+pobjContact.LOP_Role__c; 
            else
            strPOSTBody+='&user[roles][]=ROLE_USER';    
            strPOSTBody+='&user[salesforce_id]='+pobjContact.Id;
            System.debug('>>>>>>strPOSTBody'+strPOSTBody);         
            return strPOSTBody;
        }
        catch(Exception ex)
        {
            System.debug('>>>>>>>>>>exJSONFormation'+ex.getMessage()+'\n'+ex.getLineNumber());
            return null;
        }
    }  

    public static string createJSONFromRecord(Account pobjAccount)
    {   
        try
        {                   
            string strPOSTBody ='lender[name]='+pobjAccount.Name;
            strPOSTBody+='&lender[salesforce_id]='+pobjAccount.Id;
            if(pobjAccount.Picture__c!=null) strPOSTBody+='&lender[picture]='+pobjAccount.Picture__c;
            System.debug('>>>>>>strPOSTBody'+strPOSTBody);         
            return strPOSTBody;
        }
        Catch(Exception ex)
        {
        System.debug('>>>>>>>>>>exJSONFormation'+ex.getMessage()+'\n'+ex.getLineNumber());
        return null;
        }
    }  

    public static List<object> getAllUsers(string pstrToken,Integer pintFailureCount)
    {
        string strBatchRunTime=String.valueOf(System.now());
        system.debug('>>>>>>>>pstrToken'+pstrToken);
        try
        {       
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/json');
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/user/all');        
            objHttpReq.settimeout(120000);
            objHttpReq.setMethod('GET');
            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);             
            if (objHttpResp.getStatus() == 'OK')
            {
                List<object> lstObject = (List<object>)JSON.deserializeUntyped(objHttpResp.getBody());    
                system.debug('>>>>>>>lstObject'+lstObject); 
                return lstObject;
            }
            else 
            {
                if(pintFailureCount<99)
                {
                    pintFailureCount++;
                    return GetAllUsers(pstrToken,pintFailureCount);
                }
                else
                {                 
                    LOPConnectorUtility.insertErrorLog(new List<ErrorLog__c> 
                                                        {LOPConnectorUtility.getErrorLogObject('Error From getAllUsers\n'
                                                        +objHttpResp.getBody()+'\n Token:'+pstrToken+'',null,null,strBatchRunTime)});
                    return  null;
                }
            }
        }
        catch(Exception ex)
        {                         
            LOPConnectorUtility.insertErrorLog(new List<ErrorLog__c> 
                                                        {LOPConnectorUtility.getErrorLogObject('Exception From getAllUsers\n'+ex.getmessage(),
                                                        null,null,strBatchRunTime)});
            return  null;
        }
        
        
    }

    public static List<object> getAllLenders(string pstrToken,Integer pintFailureCount)
    {
        system.debug('>>>>>>>>pstrToken'+pstrToken);
        string strBatchRunTime=String.valueOf(System.now());
        try
        {       
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/json');
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/admin/lender/all');        
            objHttpReq.settimeout(120000);
            objHttpReq.setMethod('GET');
            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);              
            if (objHttpResp.getStatus() == 'OK')
            {
                List<object> lstObject = (List<object>)JSON.deserializeUntyped(objHttpResp.getBody());    
                system.debug('>>>>>>>lstObject'+lstObject); 
                return lstObject;
            }
            else 
            {
                if(pintFailureCount<99)
                {

                    pintFailureCount++;
                    return getAllLenders(pstrToken,pintFailureCount);
                }
                else
                {             
                    LOPConnectorUtility.insertErrorLog(new List<ErrorLog__c> 
                                                        {LOPConnectorUtility.getErrorLogObject('Error From getAllLenders\n'
                                                        +objHttpResp.getBody()+'\n Token:'+pstrToken+'',null,null,strBatchRunTime)});
                    return  null;
                }
            }
        }
        catch(Exception ex)
        {            
            LOPConnectorUtility.insertErrorLog(new List<ErrorLog__c> 
                                                        {LOPConnectorUtility.getErrorLogObject('Exception From getAllLenders\n'+ex.getmessage(),
                                                        null,null,strBatchRunTime)});           
            return  null;
        }                
    }

    public Static HttpresponseExceptionWrapper createLOPUser(string pstrJson,string pstrToken)
    {
        try
        {
            System.debug('>>>>Token From Create'+pstrToken);
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/admin/user');      
            objHttpReq.settimeout(120000);
            objHttpReq.setbody(pstrJson);
            objHttpReq.setMethod('POST');
            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);  
            system.debug('>>>>>>>>.objHttpResp'+objHttpResp.getBody());    
            return new HttpresponseExceptionWrapper(objHttpResp,null);
        }
        catch(Exception ex)
        {           
             return new HttpresponseExceptionWrapper(null,ex.getMessage());
        }            
    }

    public Static HttpresponseExceptionWrapper updateLOPUser(string pstrJson,string pstrId,string pstrToken)
    {
        try
        {
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
              
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/user/'+pstrId+'');   
            objHttpReq.settimeout(120000);
            objHttpReq.setbody('api=true&'+pstrJson);
            objHttpReq.setMethod('PUT');
            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);     
            if(objHttpResp.getBody()!='')
                return new HttpresponseExceptionWrapper(objHttpResp,null);  
            else
                 return new HttpresponseExceptionWrapper(null,'Null HTTP Response');     
        }
        catch(Exception EX)
        {            
            return new HttpresponseExceptionWrapper(null,ex.getMessage());
        }           
    }

    public Static HttpresponseExceptionWrapper createLOPLender(string pstrJson,string pstrToken)
    {
        try
        {
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/admin/lender');   
               
            objHttpReq.settimeout(120000);
            objHttpReq.setbody(pstrJson);
            objHttpReq.setMethod('POST');
            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);
                   
            if(objHttpResp.getBody()!='') return new HttpresponseExceptionWrapper(objHttpResp,null);  
            else return new HttpresponseExceptionWrapper(null,'Null HTTP Response');       
        }
        Catch(Exception ex)
        {          
            return new HttpresponseExceptionWrapper(null,ex.getMessage());
        }           
    }

    public Static HttpresponseExceptionWrapper updateLOPLender(string pstrJson,string pstrId,string pstrToken)
    {
        try
        {
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/admin/lender/'+pstrId+'');
            objHttpReq.settimeout(120000);
            objHttpReq.setbody('api=true&'+pstrJson);
            objHttpReq.setMethod('PUT');
            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);  
            return new HttpresponseExceptionWrapper(objHttpResp,null);
        }
        catch(Exception EX)
        {            
             return new HttpresponseExceptionWrapper(null,ex.getMessage());
        }            
    }

    public static HttpresponseExceptionWrapper updateUserSFId(string pstrLOPId,string pstrSFId, string pstrToken)
    {       
        try
        {
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/user/'+pstrLOPId+'');
            objHttpReq.setbody('api=true&user[salesforce_id]='+pstrSFId+'');
            objHttpReq.settimeout(120000);
            objHttpReq.setMethod('PUT');

            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);           
            if(objHttpResp.getBody()!='') 
                return new HttpresponseExceptionWrapper(objHttpResp,null);   
            else
                return new HttpresponseExceptionWrapper(null,'Null HTTP Response');                                    
        }
        catch(Exception EX)
        {           
            return new HttpresponseExceptionWrapper(null,ex.getMessage());
        }
    }

    public static HttpresponseExceptionWrapper updateLenderSFId(string pstrLOPId,string pstrSFId, string pstrToken)
    {       
        try
        {
            HttpRequest objHttpReq = new HttpRequest();
            objHttpReq.setHeader('x-session-token',pstrToken);
            objHttpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            objHttpReq.setEndpoint(System.label.LOPEndpointURL+'/admin/lender/'+pstrLOPId+'');
            System.debug('>>>>>>>>>Body api=true&lender[salesforce_id]='+pstrSFId+'');
            objHttpReq.setbody('api=true&lender[salesforce_id]='+pstrSFId+'');
            objHttpReq.settimeout(120000);
            objHttpReq.setMethod('PUT');

            Http http = new Http();
            HTTPResponse objHttpResp = http.send(objHttpReq);   
            if(objHttpResp.getBody()!='')
                return new HttpresponseExceptionWrapper(objHttpResp,null);   
            else
                 return new HttpresponseExceptionWrapper(null,'Null HTTP Response');                         
        }
        catch(Exception EX)
        {            
            return new HttpresponseExceptionWrapper(null,ex.getMessage());
        }
    }

    public static void sendErrorNotification(string pEmailbody,string psubject)
    {       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {System.label.UserEmails});
        mail.setReplyTo(System.label.UserEmails);
        mail.setSenderDisplayName(psubject);
        mail.setSubject(psubject);
        mail.setPlainTextBody(pEmailbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static ErrorLog__c getErrorLogObject(string pErrorMessage,string psalesforceId,string pBase_CRM_ID,string pBatchRunTime)
    {
        ErrorLog__c objErrorLog=new ErrorLog__c();
        objErrorLog.ErrorMessage__c=pErrorMessage;
        if(pBase_CRM_ID!=null) objErrorLog.Base_CRM_Id__c=pBase_CRM_ID;
        if(psalesforceId!=null) objErrorLog.SFID__c=psalesforceId;
        objErrorlog.Batch_run_time__c=pBatchRunTime;
        return objErrorLog;
    }

    public static void insertErrorLog(List<ErrorLog__c> plstErrorLog)
    {
        if(plstErrorLog!=null && plstErrorLog.size()!=0)
        {           
            List<Database.SaveResult> srList = Database.insert(plstErrorLog, false);
            Integer intRecCount=0;
            String strErrorBody='';
            for (Database.SaveResult objSaveRes : srList)
            {
                if (!objSaveRes.isSuccess())
                {
                    strErrorBody=strErrorBody+'Name:'+plstErrorLog[intRecCount].Name+' Error: /n';
                    for (Database.Error objErr : objSaveRes.getErrors())
                        strErrorBody=strErrorBody+' '+objErr.getStatusCode() + ': ' + objErr.getMessage()+'/n';
                }
                intRecCount++;
            }   
            if (strErrorBody!='')
            {                                  
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {'ajay@cloudnerd.com'});
                mail.setReplyTo('ajay@cloudnerd.com');
                mail.setSenderDisplayName('Failed to Insert Error Logs');
                mail.setSubject('Failed to Insert Error Logs.');
                mail.setPlainTextBody(strErrorBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    public class HttpresponseExceptionWrapper
    {
        public HttpResponse objHttpResp;
        public string strException;
        

        public HttpresponseExceptionWrapper(HttpResponse pobjHttpResp,string pstrException)
        {
            objHttpResp=pobjHttpResp;
            strException=pstrException;
        }
    }
*/
}