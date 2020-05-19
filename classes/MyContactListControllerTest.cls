@isTest
public with sharing class MyContactListControllerTest{
    static testmethod void MyContactTest(){
    Account a = new Account(Name='TestAccount' , Latest_Opportunity_Id__c = '123456789012345');
    insert a;
    Contact con = new Contact( 
                                       FirstName= 'test',
                                       LastName= 'name',
                                       Email= 'sa@gmail.com',
                                       Phone = '4535673456',
                                       AccountId = a.id
                                       
                           );
            insert con; 
            List<Contact> conlist = MyContactListController.getContacts(a.id);
            System.assertEquals(1, conlist.size());
            
    }    
}