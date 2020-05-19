/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Neeraja Cherukuri
 *  Create date:  March 17 2019
 *   Details
 *  -------------------------------------------------------------------------
 *  Apex Extension Class to accomodate Final OAV values.
 *   
 *  Update History
 *  ----------------------------------------------------------------------------
 *  Neeraja Cherukuri 4/12/2019--> Modified the OpportunityUtilityClass by addind new Methods for Closing+PostClosing+Passbook+SFGating.
 * ---------------------------------------------------------------------------
 ************************************************************************************/

public with sharing class Opp_OAV_Lock_Screen_EXT
{
    private final Id oppId;
    public Opportunity theOpp {get; set;} 
    public ApexPages.StandardController sc;
    public Opp_OAV_Lock_Screen_EXT(ApexPages.StandardController sc)
    {
        this.oppId = sc.getId(); 
        this.sc = sc;
            
        init();    
    }
    private void init()
    //Original_Agreed_Value__c,Appraised_Home_Value_f__c
    {      
        String query = 'SELECT Id,Additional_Applicant_Income__c,Purchase_Price__c,Final_OAV_Calculation__c,OAV_Discount_Pct__c, OAV_Discount_Amount_f__c, IA_OAV_Override__c FROM Opportunity WHERE Id=\'' + this.oppId + '\'LIMIT 1';
        this.theOpp = Database.query(query);
    }    
    public PageReference Save()
    {
        System.debug('===theOpp.IA_OAV_Override__c==='+theOpp.IA_OAV_Override__c);
        upsert theOpp;
        return sc.view();
    }
    
    public void updateclass(){
        
        //Start : Updating 'Final OAV' value with 'IA OAV Override' value
        //Jason Sun - 2019-09-06 - Commented this out because validRecordTypeIds is never even used again
        /*
        Set<Id> validRecordTypeIds = new Set<Id>();
        for(RecordType objRec : [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND (Name=:'HomeBuyer' OR Name =: 'HomeOwner')])
        {
            validRecordTypeIds.add(objRec.Id);
        }
        System.debug('===validRecordTypeIds=='+validRecordTypeIds);
        */       
    }
    public void doAction()
    {
        List<Current_Conditions__c>  lstReqWithOAV = new List<Current_Conditions__c>();
        lstReqWithOAV = [SELECT Id, Status__c from Current_Conditions__c WHERE Opportunity__c =: theOpp.Id 
                         AND Success_Factor_Type__c='OAV' AND (Status__c != 'Completed')];
        if(lstReqWithOAV.size() > 0)
        {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The OAV Success Factors Related Requirements needs to be Completed before calculating FINAL OAV .'));
        }
    }
}