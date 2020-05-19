/**
 * Trigger Handler class for handle all event after DML on contact object.
 * @Created Date : 03-04-2017
 * @Authors      : StarrData
 */
public class ContactTriggerHandler 
{
    public static Boolean rollUp = False;
    
    /** 
     * Method to initiates Process of LOP sync functionality.
     * @Param       contactList, list of contact records to process and sync.
     * @Param       IsToBeDelete, boolean for identify record is for delete or not.
     * @Returns     -
     */     
    
    public static void handleLOPUserOperations(SFUtilityClass.APIOperation apiOperation, List<Contact> contactList) {
        if(!contactList.isEmpty()) {
            Database.executeBatch(new LOPBatchProcess(apiOperation, SFUtilityClass.LOP_SFResourceName.CONTACT, contactList), Limits.getLimitCallouts());
        }
    }
    
    /** 
     * Method to automate Loan Officer Contact Status based on trained status and # of leads referred
     * @Param       contactList, list of contact records to process and sync.
     * @Param       
     * @Returns     -
     */    
    public static void CalculateNumberOfReferredLeads(List<Contact> newList) {
        
        Id lenderRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        List<Contact> toUpdate = new List<Contact>();
        
        Map<Id, AggregateResult> ars = new Map<Id, AggregateResult>([SELECT Referring_Contact__c Id, COUNT(Id) Number FROM Lead WHERE Referring_Contact__c IN :newList GROUP BY Referring_Contact__c]);
        
        for (Contact contact : newList) {
            
            contact.Number_of_Leads__c = 0;
            if (ars.containsKey(contact.Id)) {
                contact.Number_of_Leads__c = (decimal)ars.get(contact.Id).get('Number');
            }
            
            if (contact.RecordTypeId == lenderRTId && contact.Manually_Set_Contact_Status__c == false) {
                if (contact.Number_of_Leads__c == 0 && contact.Trained__c && contact.Trained_Date_Time__c != null)
                    contact.Contact_Status__c = Label.Contact_Status_Trained;
                if (contact.Number_of_Leads__c == 1)
                    contact.Contact_Status__c = Label.Contact_Status_1st_Lead_Submitted;
                if (contact.Number_of_Leads__c == 2)
                    contact.Contact_Status__c = Label.Contact_Status_2nd_Lead_Submitted;
                if (contact.Number_of_Leads__c >= 3)
                    contact.Contact_Status__c = Label.Contact_Status_3rd_Lead_Submitted;
            }
        }
        
    }
    
     /** 
     * Method to Update Phone Numbers on Contacts ,to avoid Duplicates from talk Desk.
     * @Param       contactList, list of contact records to process and sync.
     * @Param       
     * Author -- Neeraja Cherukuri
     */    
    
       public static void rewritePhoneOnLead (List<Contact> newList)
    { 
        for(Contact objCon : newList)
        {
            if(objCon.Phone != null && !(objCon.Phone).startsWith('+1'))
            {
                objCon.Phone = phoneNumberTransform.standardize(objCon.Phone);
            }
        }
    }

    public static void handleAfterInsert(List<Contact> newList) {
        Map<Id,Integer> concompcount = new Map<Id,Integer>();
        System.debug('**** after inside****');
        
        Schema.DescribeSObjectResult conDesc = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContRTMapByName = conDesc.getRecordTypeInfosByName();
        
        for(Contact newcon: newList) {
            if(newcon.AccountId != Null && newcon.Contact_Role__c != Null && newcon.Contact_Role__c == 'Loan Officer' 
               && newcon.RecordTypeId == ContRTMapByName.get('Lender').getRecordTypeId()) { 
                System.debug('**** insert: for loop');
                if(!concompcount.keyset().contains(newcon.AccountId)){
                    System.debug('**** insert: new account*****');
                    concompcount.put(newcon.AccountId,1);
                }else{
                    System.debug('**** insert: old account*****');
                    concompcount.put(newcon.AccountId,concompcount.get(newcon.AccountId)+1);
                }
            }
        }
        if(concompcount.keyset().size() > 0 && rollUp == False){
            CountofContacts(concompcount);
            rollUp = True;
        }
           
    }
    
    public static void handleAfterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
        Map<Id,Integer> concompcount = new Map<Id,Integer>();
        Schema.DescribeSObjectResult conDesc = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContRTMapByName = conDesc.getRecordTypeInfosByName();
        for(Contact con: newlist){ 
            System.debug('**** after update****');
            if(con.Contact_Role__c != Null && con.Contact_Role__c == 'Loan Officer' 
                && con.RecordTypeId == ContRTMapByName.get('Lender').getRecordTypeId()){
                /*if(oldmap.get(con.Id) != Null && oldMap.get(con.Id).AccountId == Null && con.AccountId != Null){
                    if(!concompcount.keyset().contains(con.AccountId)){
                        System.debug('**** update1: new account *****');
                        concompcount.put(con.AccountId,1);
                    }else{
                        System.debug('**** update1: old account*****');
                        concompcount.put(con.AccountId,concompcount.get(con.AccountId)+1);
                    }
                
                }else if(oldmap.get(con.Id) != Null && oldmap.get(con.Id).AccountId != Null &&  con.AccountId == Null){
                        if(!concompcount.keyset().contains(con.AccountId)){
                            System.debug('**** update2: new account *****');
                            concompcount.put(con.AccountId,-1);
                        }else{
                            System.debug('**** update2: old account*****');
                            concompcount.put(con.AccountId,concompcount.get(con.AccountId)-1);
                        } 
                      
                } */
                if(oldmap.get(con.Id) != Null && oldmap.get(con.Id).AccountId != Null &&  con.AccountId != Null && con.AccountId != oldmap.get(con.Id).AccountId){
                        
                        if(!concompcount.keyset().contains(oldmap.get(con.Id).AccountId)){
                            System.debug('**** update3: new account *****');
                            concompcount.put(oldmap.get(con.Id).AccountId,-1);
                            
                        }else{
                            System.debug('**** update3: old account*****');
                            concompcount.put(oldmap.get(con.Id).AccountId,concompcount.get(oldmap.get(con.Id).AccountId)-1);
                        }
                        
                        if(!concompcount.keyset().contains(con.AccountId)){
                            System.debug('**** update31: new account*****');
                            concompcount.put(con.AccountId,1);
                        }else{
                            System.debug('**** update31: old account*****');
                            concompcount.put(con.AccountId,concompcount.get(con.AccountId)+1);
                        }
                }
            }
        }
        
        if(concompcount.keyset().size() > 0 && rollUp == False){
            CountofContacts(concompcount);
            rollUp = True;
        }  
    }
    
    public static void handleAfterDelete(List<Contact> oldMap) {
        Map<Id,Integer> concompcount = new Map<Id,Integer>();
        Schema.DescribeSObjectResult conDesc = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContRTMapByName = conDesc.getRecordTypeInfosByName();
        System.debug('**** after delete*****');
        for(Contact con : oldMap){
            if(con.AccountId != Null && con.Contact_Role__c != Null && con.Contact_Role__c == 'Loan Officer' 
                && con.RecordTypeId == ContRTMapByName.get('Lender').getRecordTypeId()){
                if(!concompcount.keyset().contains(con.AccountId)){
                    System.debug('**** delete: new account*****');
                    concompcount.put(con.AccountId,-1);
                }else{
                    System.debug('****  delete: old account*****');
                    concompcount.put(con.AccountId,concompcount.get(con.AccountId)-1);
                }
            }
        }
        
        if(concompcount.keyset().size() > 0 && rollUp == False){
            CountofContacts(concompcount);
            rollUp = True;
        }
    }
    
    public static void handleAfterUndelete(List<Contact> newList) {
        Map<Id,Integer> concompcount = new Map<Id,Integer>();
        Schema.DescribeSObjectResult conDesc = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContRTMapByName = conDesc.getRecordTypeInfosByName();
        System.debug('**** aftre undelete*****');
        for(Contact con : newList){
            if(con.AccountId != Null && con.Contact_Role__c != Null && con.Contact_Role__c == 'Loan Officer' 
                && con.RecordTypeId == ContRTMapByName.get('Lender').getRecordTypeId()){
                if(!concompcount.keyset().contains(con.AccountId)){
                    System.debug('**** udelete: new account*****');
                    concompcount.put(con.AccountId,1);
                }else{
                    System.debug('**** undelete: old account*****');
                    concompcount.put(con.AccountId,concompcount.get(con.AccountId)+1);
                }
            }
        }
        if(concompcount.keyset().size() > 0 && rollUp == False){
            CountofContacts(concompcount);
            rollUp = True;
        }
    }
    
    public static void CountofContacts(Map<Id,Integer> concompcount){
        System.debug('**** inside count*****');
        if(concompcount.keyset().size() > 0){
            System.debug('**** count: checking map size *****');
            List<Account> acclist = [Select Id, Roll_up_of_LOs__c From Account where id =: concompcount.keyset()];
            if(acclist.size() > 0) {
                System.debug('**** count: account size*****');
                for(Account acc : acclist){
                    System.debug('****count: looping account*****');
                    if(concompcount.keyset().contains(acc.Id) && concompcount.get(acc.Id) != Null){
                        System.debug('****count: checking map for account*****');
                        if(acc.Roll_up_of_LOs__c != Null){
                            System.debug('***acc.Roll_up_of_LOs__c****' +acc.Roll_up_of_LOs__c);
                            acc.Roll_up_of_LOs__c = acc.Roll_up_of_LOs__c + concompcount.get(acc.Id);
                            System.debug('***after update acc.Roll_up_of_LOs__c****'+ acc.Roll_up_of_LOs__c);
                        }else{
                            acc.Roll_up_of_LOs__c = concompcount.get(acc.Id);
                        }
                        
                    }
                }                        
            }        
            System.debug('**** account updated*****');
            Database.update(acclist,false);
            
        }    
    }   
}