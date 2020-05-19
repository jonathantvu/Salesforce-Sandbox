trigger DealStageTracker on Deal_Stage_Tracker__c (after insert) {
/* VK - Commented out the code for BUS-155110189  
    if (Trigger.isAfter && Trigger.isInsert) {
        // can't call a @future method more than 50 times so we split the incoming list into batches
        Set<Id> trackerIds = new Set<Id>();
        for (Deal_Stage_Tracker__c tracker : Trigger.new) {
            trackerIds.add(tracker.Id);
            if (trackerIds.size() == 5) {
            	SegmentHelper.TrackFuture(trackerIds);
                trackerIds = new Set<Id>();
            }
        }
        if (trackerIds.size() > 0) { 
            SegmentHelper.TrackFuture(trackerIds);
        }
    }
*/
}