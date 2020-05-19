/**
 * Created by Carolina Veliz on 4/26/2019.
 */

public with sharing class PsCommunicationDMACriterias {


    public static void sendEmailToPs ( List<Opportunity> oppList,Map<Id,Opportunity> oldMap,id emailTemplate) {

        List<Opportunity> oppToSendOpps= new List<Opportunity>();

        for (Opportunity opp: oppList) {

            if ((opp.Home_Inspection_Received__c != oldMap.get(opp.Id).Home_Inspection_Received__c) &&
                    (opp.Home_Inspection_Received__c == true)) {

                List<DMA__c> dmaItems = [
                        select id, name
                        from dma__c
                        where Opportunity__c = :opp.Id
                ];

                List<Current_Conditions__c> reqItems = [
                        select id, name,Requirement__c,
                                Status__c,Opportunity__r.Home_Inspection_Received__c,Opportunity__r.DMA_Count__c
                        from Current_Conditions__c
                        where Opportunity__c = :opp.id
                        and ((Requirement__c = 'Home Inspection') or
                        (Requirement__c = 'Post Close Home Inspection'))
                        and Status__c = 'Completed'
                ];

                boolean result = (dmaItems.size() > 0) &&
                        (reqItems.size() > 0);

                system.debug(dmaItems);
                system.debug(reqItems);
                system.debug(result);

                if (result) {
                    oppToSendOpps.add(opp);
                }
            }
        }

        //id emailTemplate = [select id from EmailTemplate where developername='PS_Communication_DMAs'].id;
        system.debug(emailTemplate);


        for( Opportunity opp: oppToSendOpps){

            Messaging.SingleEmailMessage email =
                    Messaging.renderStoredEmailTemplate(emailTemplate, opp.OwnerId, opp.id);
            email.setSubject('DMAs Identified');
            email.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }
}