@isTest (seeAllData=true)
public class testPublishToSlackBasic{
 
    static testmethod void testPublishToSlack(){
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        List<publishToSlackBasic.slackRequest> requests = new List<publishToSlackBasic.slackRequest>();
        publishToSlackBasic.slackRequest r = new publishToSlackBasic.slackRequest();
        r.slackMessage='THIS IS A TEST MESSAGE';
        r.channel='#general';
        requests.add(r);
        publishToSlackBasic.publishToSlack(requests);
    }
    
    public class mockCallout implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse res = new HttpResponse();
            res.setBody( '{"text":"value"}');
            res.setStatusCode(200);
            return res;
        }   
    }
}