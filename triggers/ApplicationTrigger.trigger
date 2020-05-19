/**
 * Created by cveli on 3/3/2020.
 */

trigger ApplicationTrigger on Application__c (before insert, before update, before delete) {
    InvalidateEmail.invalidateEmail(Trigger.new);

}