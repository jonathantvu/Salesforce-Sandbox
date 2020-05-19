/**
 * Created by Eliot Rojas on 5/1/2019.
 */

public class OpportunityChatterUpdatesQueueable implements Queueable {
    private List<Opportunity> newList;
    private Map<Id, Opportunity> oldMap;
    private Boolean isInsert;

    // Trigger.isInsert && Trigger.isAfter
    public OpportunityChatterUpdatesQueueable(List<Opportunity> newList) {
        this.newList = newList;
        this.isInsert = true;
    }

    // Trigger.isUpdate && Trigger.isAfter
    public OpportunityChatterUpdatesQueueable(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        this.newList = newList;
        this.oldMap = oldMap;
        this.isInsert = false;
    }

    public void execute(QueueableContext context) {
        if(isInsert) {
            OpportunityChatterUpdates.doChatterUpdates(newList);
        } else {
            OpportunityChatterUpdates.doChatterUpdates(newList, oldMap);
        }
    }
}