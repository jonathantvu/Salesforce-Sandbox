/**
 * Created by Eliot Rojas on 7/12/2019.
 */

public with sharing class UnisonMasterNotificationsWrapper {
    @InvocableMethod
    public static void ManageNotificationsForOpportunityStage(List<Opportunity> newList) {
        UnisonMasterNotifications.ManageNotificationsForOpportunityStage(newList);
    }
}