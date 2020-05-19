/************************************************************************************
 Apex Class Name     : leadDeclineHelper
 Version             : 1.0
 Created Date        : 27th August 2019
 Function            : Helper APEX class for Lead Before trigger context to process cases
						where leads should be auto-declined
 Author              : Jason Sun
 
 Modification Log    :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Jason Sun           	08/27/2019                Original Version
*************************************************************************************
* Caro Veliz :
* To implement ticket:
* https://unison-technology.atlassian.net/browse/BUS-155110006
*/
public class leadDeclineHelper {

    private static Map<string,Invalid_State_County__mdt> invalidList;
    public static void autoDeclineLeads(List<Lead> beforeTriggerLeads){
        for(Lead l: beforeTriggerLeads){
            declineTestLead(l);
            declineCounty(l);
        }
    }
    
    //Logic to auto-decline test leads.  Replaces TestLead Process Builder
    private static void declineTestLead(Lead theLead){
        if((theLead.FirstName != NULL &&theLead.FirstName.containsIgnoreCase('test')) || theLead.LastName.containsIgnoreCase('test')){
            theLead.Autopilot_Sync__c = false;
            theLead.Loss_Reason_Type__c = LABEL.CustomerInformationFake;
            theLead.Status = LABEL.Closed_Lost;
            theLead.Loss_Type__c = LABEL.Invalid;
        }
    }
    
    private static string getStateCountyKey(string state, string county){
        return state + '-' + county;
    }
    private static void getInvalidStateCounty(){
        invalidList = new Map<string,Invalid_State_County__mdt>();
        for( Invalid_State_County__mdt invalidStateCounty: [ select
                                                        MasterLabel,
                                                        DeveloperName,
                                                        County__c,
                                                        State__c,
                                                        Loss_Type__c,
                                                        Loss_Reason_Type__c,
                                                        Decline_Error_Message__c
                                                        from Invalid_State_County__mdt
                                                        where active__c = true]){
            invalidList.put( getStateCountyKey(invalidStateCounty.State__c, invalidStateCounty.County__c ),  invalidStateCounty);
        }
    }
    private static void declineCounty(Lead theLead){
        getInvalidStateCounty();

        string key = getStateCountyKey(theLead.Property_State__c, theLead.Property_County__c);
        Invalid_State_County__mdt invalidStateCounty = invalidList.get(key);
        system.debug(invalidStateCounty);
        if (invalidStateCounty != null) {
            theLead.Status = 'Closed Lost';
            theLead.Loss_Type__c = invalidStateCounty.Loss_Type__c;
            theLead.Loss_Reason_Type__c = invalidStateCounty.Loss_Reason_Type__c;
            system.debug(theLead.Status);
            system.debug(theLead.Loss_Type__c);
            system.debug(theLead.Loss_Reason_Type__c);
        }
    }
    
}