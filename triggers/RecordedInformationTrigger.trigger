/**
 * Created by cveli on 3/3/2020.
 */

trigger RecordedInformationTrigger on Recorded_Information__c (before insert, before update) {
    InvalidateEmail.invalidateEmail(Trigger.new);
}