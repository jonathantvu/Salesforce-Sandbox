/************************************************************************************
 Apex Class Name     : leadDeclineHelperTest
 Version             : 1.0
 Created Date        : 27th August 2019
 Function            : test Class to cover leadDeclineHelperClass
 Author              : Jason Sun
 
 Modification Log    :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Jason Sun           	08/27/2019                Original Version
*************************************************************************************
* changed by Caro Veliz.
* Implementing ticket : https://unison-technology.atlassian.net/browse/BUS-155110006
* 
*/
@isTest
public class leadDeclineHelper_test {

    public static testMethod void test_declineTestLead(){
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Lead');
        Schema.DescribeSobjectResult objTypeDesc = objType.getDescribe();
        map<Id, Schema.RecordTypeInfo> recTypeMap = objTypeDesc.getRecordTypeInfosById();
        system.debug('**recTypeMap**'+recTypeMap);
        Map<string,Id> mapretypes = new Map<string,Id>();
        for(Schema.RecordTypeInfo s : recTypeMap.values()){
            mapretypes.put(s.getDeveloperName(),s.getrecordtypeId());
        }
        
        //setup firstName Case
		List<Lead> ldlist = new List<Lead>();
        Lead ld1 = new Lead();
        ld1.recordtypeid = mapretypes.get('HomeOwner');
        ld1.FirstName = 'jeiroTestERlif';
        ld1.LastName = 'Last';
        ld1.Company = 'Test Last Company'; 
        ld1.Autopilot_Sync__c = true;
        
        //setup LastName Case        
        Lead ld2 = new Lead();
        ld2.recordtypeid = mapretypes.get('HomeOwner');
        ld2.FirstName = 'First';
        ld2.LastName = 'asldkfjTest23049fdj';
        ld2.Company = 'John Company';
        ld2.Autopilot_Sync__c = true;
        
        //setup Negative Case           
        Lead ld3 = new Lead();
        ld3.recordtypeid = mapretypes.get('HomeOwner');
        ld3.FirstName = 'First';
        ld3.LastName = 'Last';
        ld3.Company = 'First Last Company'; 
        ld3.Autopilot_Sync__c = true;        
        
        ldlist.add(ld1);
        ldlist.add(ld2);
        ldlist.add(ld3);
		
        //invoke processing method
		leadDeclineHelper.autoDeclineLeads(ldlist);
		
        //asserts positive casees
        system.assertEquals(false,ld1.Autopilot_Sync__c);
        system.assertEquals(LABEL.Closed_Lost,ld1.Status);
        system.assertEquals(LABEL.Invalid,ld1.Loss_Type__c);       
        
        system.assertEquals(false,ld2.Autopilot_Sync__c);
        system.assertEquals(LABEL.Closed_Lost,ld2.Status);
        system.assertEquals(LABEL.Invalid,ld2.Loss_Type__c);
        system.assertEquals(LABEL.CustomerInformationFake,ld2.Loss_Reason_Type__c);
        
        system.assertNotEquals(false,ld3.Autopilot_Sync__c);
        system.assertNotEquals(LABEL.CustomerInformationFake,ld3.Loss_Reason__c);
        system.assertNotEquals(LABEL.Closed_Lost,ld3.Status);
        system.assertNotEquals(LABEL.Invalid,ld3.Loss_Type__c);        
    }
    
}