public with sharing class SendToSegmentAPI {
    
    public Id recId { get; set; }

    public SendToSegmentAPI(ApexPages.StandardController sc) {
        recId = sc.getId();
    }
    
    public PageReference Send() {
        
        if (recId == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No record Id provided.');
            ApexPages.addMessage(myMsg);
            return null;
        }

        SegmentAPI.APICallResult res = SegmentHelper.Track(recId);
        
        if (!res.error) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Success');
            ApexPages.addMessage(myMsg);
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, res.message);
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public PageReference GoBack() {
        if (recId == null) {
            PageReference pageRef = new PageReference('/' + Deal_Stage_Tracker__c.sObjectType.getDescribe().getKeyPrefix());
            pageRef.setRedirect(true);
            return pageref;
        } else {
            PageReference pageRef = new PageReference('/' + recId);
            pageRef.setRedirect(true);
            return pageref; 
        }
    }

}