public with sharing class SlackPublisher {
     
    private static final String SLACK_URL = 'https://hooks.slack.com/services/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';
     
    public class Oppty {
        @InvocableVariable(label='Opportunity Name')
        public String opptyName;               
    }
     
    @InvocableMethod(label='Post to Slack')
    public static void postToSlack ( List<Oppty> opps ) {
        Oppty o = opps[0]; // bulkify the code later
        
        Map<String,Object> msg = new Map<String,Object>();
        msg.put('text', 'The following Deal is now in Acquisitions: ' + o.opptyName);
        msg.put('mrkdwn', true);
        
        String body = JSON.serialize(msg);   
        System.enqueueJob(new QueueableSlackPost(SLACK_URL, 'POST', body));
    }
     
    public class QueueableSlackPost implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackPost(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            HttpResponse res = http.send(req);
        }
    }
    }