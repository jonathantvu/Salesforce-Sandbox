/************************************************************************************
 Apex Class Name     : RequirementsController
 Version             : 1.0
 Created Date        : 8th Jan 2019
 Function            : Controller class for VF page (RequirementPredefault). 
                       This Class has business logic and executes it.
 Author              : Neeraja Cherukuri
 
 Modification Log    :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Neeraja Chekuri            01/8/2018                Original Version
* Jason Sun            		08/29/2018                Fixed out-of-control queries returning > 50k records
*************************************************************************************
*/

public without sharing class RequirementsController{
    public Current_Conditions__c req{get;set;}
    public RequirementsController(ApexPages.StandardController controller)
    {
       req = new Current_Conditions__c();
       this.req = (Current_Conditions__c)controller.getRecord();
       String successFactorName = 'DTI'; //TO-DO:  Why is this hard coded???
       List<Success_Factor__c> lstSF = new List<Success_Factor__c>();
    
		if(req.Opportunity__c != null || req.Lead__c != null)
		{
            if(req.Opportunity__c != NULL){
				lstSF = [SELECT Id FROM Success_Factor__c WHERE Opportunity__c =: req.Opportunity__c
                                       AND Success_Factor__c =: successFactorName LIMIT 1];
            }
            else if(req.Lead__c != NULL){
				lstSF = [SELECT Id FROM Success_Factor__c WHERE Lead__c =: req.Lead__c
                                       AND Success_Factor__c =: successFactorName LIMIT 1];                
            }
		}
		if(lstSF.size() > 0)
		{
			req.Success_Factor__c = lstSF[0].Id;     
		}        
    }
    public void getSuccessFactorValue()
    {
        String successFactorName = 'DTI'; //TO-DO:  Why is this hard coded???
        Map<String, String> mapPicklistValues = new Map<String, String>();
        Map<String, EOS_Requirements__mdt> mapEOSReq = new Map<String, EOS_Requirements__mdt>();
        
        //fetching label and API names for Requirement__c picklist field. 
        for( Schema.PicklistEntry v : Current_Conditions__c.Requirement__c.getDescribe().getPicklistValues()) 
        { 
            mapPicklistValues.put(v.getValue(),v.getLabel());
        }
        //fetching details from EOS Custom Metadata
        for(EOS_Requirements__mdt objMDT : [SELECT MasterLabel, DeveloperName, RequirementName__c, Success_Factor__c FROM EOS_Requirements__mdt WHERE RequirementName__c=: mapPicklistValues.get(req.Requirement__c)])
        {
            mapEOSReq.put(objMDT.RequirementName__c, objMDT);
        }
        
       List<Success_Factor__c> lstSF = new List<Success_Factor__c>();
       if(req.Opportunity__c != null || req.Lead__c != null)
       {
           system.debug('*******req.Requirement__c*******'+req.Requirement__c);
           if(mapEOSReq.containsKey(mapPicklistValues.get(req.Requirement__c)))
           {
                if(req.Opportunity__c != NULL){
                	lstSF = [SELECT Id FROM Success_Factor__c WHERE Opportunity__c =: req.Opportunity__c
                                       AND Success_Factor__c =: mapEOSReq.get(mapPicklistValues.get(req.Requirement__c)).Success_Factor__c LIMIT 1];    
                }    
                else if(req.Lead__c != NULL){
                	lstSF = [SELECT Id FROM Success_Factor__c WHERE Lead__c=: req.Lead__c
                                       AND Success_Factor__c =: mapEOSReq.get(mapPicklistValues.get(req.Requirement__c)).Success_Factor__c LIMIT 1];                   
                }                
           }
           System.debug('*******lstSF*******'+lstSF);
           //Checking if the List size is greater than zero
           if(lstSF.size() > 0)
           {
               req.Success_Factor__c = lstSF[0].Id;
               req.Code__c = mapEOSReq.containsKey(mapPicklistValues.get(req.Requirement__c))? mapEOSReq.get(mapPicklistValues.get(req.Requirement__c)).DeveloperName :null;
           }
           else
           {	
               if(req.Opportunity__c != NULL){
					lstSF = [SELECT Id FROM Success_Factor__c WHERE Opportunity__c =: req.Opportunity__c AND Success_Factor__c =: successFactorName LIMIT 1];                   
               }
               else if(req.Lead__c != NULL){
                   lstSF = [SELECT Id FROM Success_Factor__c WHERE Lead__c =: req.Lead__c AND Success_Factor__c =: successFactorName LIMIT 1];                   
               }
               if(lstSF.size() > 0)
               {
                   req.Success_Factor__c = lstSF[0].Id;   
                   req.Code__c = mapEOSReq.containsKey(mapPicklistValues.get(req.Requirement__c))? mapEOSReq.get(mapPicklistValues.get(req.Requirement__c)).DeveloperName :null;
               }                        
           }
        }
    }

}