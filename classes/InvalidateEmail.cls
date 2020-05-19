/**
 * Created by cveli on 3/2/2020.
 */

public with sharing class InvalidateEmail {

    public static Boolean thisIsSandbox(){
        return  [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static void invalidateEmail(List<lead> newList) {
        if (thisIsSandbox() || test.isRunningTest()) {
            for (Lead newLead : newList) {
                newLead.Email = invalidEmail(newLead.Email);
                newLead.Co_Applicant_Email__c = invalidEmail(newLead.Co_Applicant_Email__c);
                newLead.Manager_Email__c = invalidEmail(newLead.Manager_Email__c);
                newLead.Salesforce_User_Email__c = invalidEmail(newLead.Salesforce_User_Email__c);
                newLead.zisf__ZoomInfo_Email__c = invalidEmail(newLead.zisf__ZoomInfo_Email__c);
            }
        }
    }

    public static void invalidateEmail(List<Account> newList) {
        if (thisIsSandbox() || test.isRunningTest()) {
            for (Account acc : newList) {
                acc.Email__c = invalidEmail(acc.Email__c);
            }
        }
    }

    public static void invalidateEmail(List<Recorded_Information__c> newList) {
        if (thisIsSandbox() || test.isRunningTest()) {
            for (Recorded_Information__c riInformation : newList) {
                riInformation.Escrow_Email__c = invalidEmail(riInformation.Escrow_Email__c);
                riInformation.Lender_Email__c = invalidEmail(riInformation.Lender_Email__c);
                riInformation.Title_Email__c = invalidEmail(riInformation.Title_Email__c);
                riInformation.Trustee_Email__c = invalidEmail(riInformation.Trustee_Email__c);
            }
        }
    }
    public static void invalidateEmail(List<Application__c> newList) {
        if (thisIsSandbox() || test.isRunningTest()) {
            for (Application__c newApp : newList) {
                newApp.Email__c = invalidEmail(newApp.Email__c);
                newApp.Email_Co__c = invalidEmail(newApp.Email_Co__c);
            }
        }
    }

    public static void invalidateEmail(List<contact> newList) {
        if (thisIsSandbox() || test.isRunningTest()) {
            for (contact newContact : newList) {
                newContact.email = invalidEmail(newContact.email);
                newContact.Secondary_Email__c = invalidEmail(newContact.Secondary_Email__c);
                newContact.zisf__ZoomInfo_Email__c = invalidEmail(newContact.zisf__ZoomInfo_Email__c);
                System.debug(newContact.email);
            }
        }
    }

    private static string invalidEmail(string email){
        System.debug('invalidateEmail **1');
        if (string.isNotBlank(email)){
            System.debug('invalidateEmail **2');
            if(!(email.contains('+test'))) {
                System.debug('invalidateEmail **3');
                System.debug(email);
                System.debug(email.contains('.invalid'));
                System.debug(email.containsNone('.invalid'));
                if (!email.contains('.invalid') ){
                    System.debug('invalidateEmail **4');
                    email = email + '.invalid';
                }
            }
        }
        return email;
    }
}