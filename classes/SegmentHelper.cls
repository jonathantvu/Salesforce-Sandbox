public without sharing class SegmentHelper {
  //VK - Commented out the code for BUS-155110189  
    @future(callout=true)
    public static void TrackFuture(Set<Id> trackerIds) {
        Track(trackerIds);
    }

    public static void Track(Set<Id> trackerIds) {
        List<Deal_Stage_Tracker__c> trackers = [SELECT Id, Encompass_Loan_Number__c, Event_Name__c, Email__c, First_Name__c, Last_Name__c, Phone__c, Lead__c 
                                                FROM Deal_Stage_Tracker__c WHERE Id IN :trackerIds];
        for (Deal_Stage_Tracker__c tracker : trackers) {
            Track(tracker);
        }
        update trackers;
    }
    
    @future(callout=true)
    public static void TrackFuture(Id trackerId) {
        Track(trackerId);
    }

    public static SegmentAPI.APICallResult Track(Id trackerId) {
        Deal_Stage_Tracker__c tracker = [SELECT Id, Encompass_Loan_Number__c, Event_Name__c, Email__c, First_Name__c, Last_Name__c, Phone__c, Lead__c 
                                            FROM Deal_Stage_Tracker__c WHERE Id = :trackerId];
        SegmentAPI.APICallResult req = Track(tracker);
        update tracker;

        return req;
    }
    
    public static SegmentAPI.APICallResult Track(Deal_Stage_Tracker__c tracker) {

        SegmentAPI.TrackRequest req = new SegmentAPI.TrackRequest();

        req.type = 'track';
        req.anonymousId = tracker.Encompass_Loan_Number__c;
        req.event = tracker.Event_Name__c;
        req.timestamp = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); // or 'yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'

        req.properties.email = tracker.Email__c;
        req.properties.first_name = tracker.First_Name__c;
        req.properties.last_name = tracker.Last_Name__c;
        req.properties.phone = tracker.Phone__c;
        req.properties.lead_id = tracker.Lead__c;

        /*SegmentAPI.APICallResult res = SegmentAPI.CallTrack(req);

        if (res.error) {
            tracker.Segment_Integration_Status__c = 'Error';
        } else {
            tracker.Segment_Integration_Status__c = 'Success';
        }
        tracker.Segment_Integration_Response__c = res.message;*/

        return null;
    }
}