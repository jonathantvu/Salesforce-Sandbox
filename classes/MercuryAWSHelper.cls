public class MercuryAWSHelper {

    public static boolean CallAWS(Id appId) {
        
        Appraisal__c appraisal = [SELECT Id, CreatedDate, LastModifiedDate, Opportunity__c, Appraisal_Ordered_Date__c, Appraisal_External_Id__c, 
                                        MercuryTrackingId__c, Appraisal_Status__c, Appraisal_Order_Number__c, Requirement__c 
                                  FROM Appraisal__c WHERE Id = :appId];/* 4/2/2019 Sundar Subramaniam - Removed "Mercury_Status__c" field from query for Data Model Cleanup */
            
        MercuryAWSAPI.Request req = new MercuryAWSAPI.Request();
        req.appraisals = new List<MercuryAWSAPI.RequestAppraisals>();
        req.appraisals.add(new MercuryAWSAPI.RequestAppraisals());
        req.appraisals[0].eventType = 'ordered';
        req.appraisals[0].appraisal.put('Id', appraisal.Id);
        req.appraisals[0].appraisal.put('CreatedDate', appraisal.CreatedDate);
        req.appraisals[0].appraisal.put('LastModifiedDate', appraisal.LastModifiedDate);
        req.appraisals[0].appraisal.put('Opportunity__c', appraisal.Opportunity__c);
        req.appraisals[0].appraisal.put('Appraisal_Ordered_Date__c', appraisal.Appraisal_Ordered_Date__c);
        req.appraisals[0].appraisal.put('Appraisal_External_Id__c', appraisal.Appraisal_External_Id__c);
        req.appraisals[0].appraisal.put('MercuryTrackingId__c', appraisal.MercuryTrackingId__c);
        req.appraisals[0].appraisal.put('Appraisal_Status__c', appraisal.Appraisal_Status__c);
        //req.appraisals[0].appraisal.put('Mercury_Status__c', appraisal.Mercury_Status__c);/* 4/2/2019 Sundar Subramaniam - Commented for Data Model Cleanup */
        req.appraisals[0].appraisal.put('Appraisal_Order_Number__c', appraisal.Appraisal_Order_Number__c);
        req.appraisals[0].appraisal.put('Requirement__c', appraisal.Requirement__c);
        
        return MercuryAWSAPI.CallAWS(req);
    }
    
}