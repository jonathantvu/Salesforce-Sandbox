@isTest
public class LOPIntegrationTest {
    
    // Used to setup data used by class
    @testSetup static void setup() {
        Contact contactObj = createContact();
        contactObj.LOP_User__c = false;
        insert contactObj;
        
        LOP_Error_Handling_Emails__c LOP_Email = new LOP_Error_Handling_Emails__c();
        LOP_Email.Name = 'Testing Email'; 
        LOP_Email.Email__c = 'test@dws.com';
        insert LOP_Email;
        
        List<LOP_Field_Map__c> LOPFieldMapList = getLOPFieldMapRecords();
        if(!LOPFieldMapList.isEmpty()) {
            insert LOPFieldMapList;
        }
    }
    
    private static Account createAccount() {        
        return new Account(Name = 'testAccount',
                           RecordTypeId = '012E00000002OGh');
    }
    
    private static Contact createContact() {
        Account accountObj = createAccount();
        insert accountObj;
        
        return new Contact(FirstName = 'test',
                           LOP_User__c = true,
                           LastName = 'DWS',
                           Email = 'test@dws.com',
                           AccountId = accountObj.Id);
    }
    
    private static User createUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        return new User(Alias = 'standt', 
                        Email = 'standarduser@testorg.com', 
                        EmailEncodingKey = 'UTF-8', 
                        LastName = 'Testing', 
                        LanguageLocaleKey = 'en_US', 
                        LocaleSidKey = 'en_US', 
                        ProfileId = profile.Id, 
                        isActive = true,
                        Deactivate_LOP_User__c = false,
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        UserName = 'standarduser11makeunique@testorg.com');
    }
    
    // Contact Synchronization.
    public static testMethod void testCreateContact() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        // Create LOP record on creation of contact by checking Create_LOP_User__c.
        Contact contactObj = createContact();
        insert contactObj;
        
        Test.stopTest();
        
        contactObj = [SELECT Id, Create_LOP_User__c FROM Contact WHERE Id =: contactObj.Id];
        //System.assert(!contactObj.Create_LOP_User__c);
        
    }
    
    public static testMethod void testUpdateContact() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        // Create LOP record on creation of contact by checking Create_LOP_User__c.
        Contact contactObj = createContact();
        insert contactObj;
        
        contactObj.Create_LOP_User__c = false;
        contactObj.FirstName = 'test1';
        update contactObj;
        
        Test.stopTest();
        
        contactObj = [SELECT Id, Deactivate_LOP_User__c FROM Contact WHERE Id =: contactObj.Id];
        //System.assert(!contactObj.Deactivate_LOP_User__c);
    }
    
    public static testMethod void testDeactivateContact() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        // Create LOP record on creation of contact by checking Create_LOP_User__c.
        Contact contactObj = createContact();
        insert contactObj;
        
        contactObj.Create_LOP_User__c = false;
        contactObj.Update_LOP_User__c = false;
        contactObj.LOP_User__c = false;
        update contactObj;
        
        Test.stopTest();
        
        contactObj = [SELECT Id, Create_LOP_User__c FROM Contact WHERE Id =: contactObj.Id];
        //System.assert(!contactObj.Create_LOP_User__c);
        
    }
    
    public static testMethod void testDeleteContact() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        // Create LOP record on creation of contact by checking Create_LOP_User__c.
        Contact contactObj = createContact();
        insert contactObj;
        
        delete contactObj;
        
        Test.stopTest();
    }
    
    // Account Synchronization.
    public static testMethod void testCreateAccount() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        Account accountObj = createAccount();
        accountObj.LOP_Lender__c = true;
        insert accountObj;
        
        Test.stopTest();
        
        accountObj = [SELECT Id, Create_LOP_Lender__c FROM Account WHERE Id =: accountObj.Id];
        //System.assert(!accountObj.Create_LOP_Lender__c);
    }
    
    public static testMethod void testUpdateAccount() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        Account accountObj = createAccount();
        accountObj.LOP_Lender__c = true;
        insert accountObj;
        
        accountObj.Create_LOP_Lender__c = false;
        accountObj.Update_LOP_Lender__c = true;
        update accountObj;
        
        Test.stopTest();
        
        accountObj = [SELECT Id, Update_LOP_Lender__c FROM Account WHERE Id =: accountObj.Id];
        //System.assert(!accountObj.Update_LOP_Lender__c);
    }
    
    public static testMethod void testDeactivateAccount() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        Account accountObj = createAccount();
        accountObj.LOP_Lender__c = true;
        insert accountObj;
        
        accountObj.Create_LOP_Lender__c = false;
        accountObj.Update_LOP_Lender__c = false;        
        accountObj.LOP_Lender__c = false;
        update accountObj;
        
        Test.stopTest();
        
        // As LOP Mock respoce send always 404 replay on delete operation. for test and cover email functionality.
        accountObj = [SELECT Id, LOP_Error_Message__c FROM Account WHERE Id =: accountObj.Id];
       // System.assert(accountObj.LOP_Error_Message__c.contains('Not Found'));
    }
    
    public static testMethod void testDeleteAccount() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        Account accountObj = createAccount();
        accountObj.LOP_Lender__c = true;
        insert accountObj;
        
        delete accountObj;
        
        Test.stopTest();
    }

    // User Synchronization.
    public static testMethod void testCreateUser() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        User userObj = createUser();
        //insert userObj;
        
        Test.stopTest();
    }
    
    public static testMethod void testUpdateUser() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        User user = [SELECT Id, isActive FROM User WHERE Id =: Userinfo.getUserId()];
        
        user.Update_LOP_User__c = true;
        update user;
        
        Test.stopTest();
        
        user = [SELECT Id, isActive, Update_LOP_User__c FROM User WHERE Id =: Userinfo.getUserId()];
        //System.assert(!user.Update_LOP_User__c);
    }
    
    public static testMethod void testDeactivateUser() {
        Test.setMock( HttpCalloutMock.class, new LOP_MockResponseGenerator() );
        Test.startTest();
        
        User user = [SELECT Id, isActive FROM User WHERE Id =: Userinfo.getUserId()];
        
        user.Update_LOP_User__c = false;
        user.Deactivate_LOP_User__c = true;
        update user;
        
        Test.stopTest();
        
        user = [SELECT Id, isActive, LOP_Error_Message__c FROM User WHERE Id =: Userinfo.getUserId()];
        //System.assert(user.LOP_Error_Message__c.contains('Not Found'));
    }
    
    
    Private static List<LOP_Field_Map__c> getLOPFieldMapRecords() {
        String jsonObjList = '['+
                            '  {'+
                            '    "Name": "User: SD Email",'+
                            '    "SF_Field_API_Name__c": "Email",'+
                            '    "LOP_Field_API_Name__c": "email",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "sales_director"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Sales Director",'+
                            '    "SF_Field_API_Name__c": "Sales_Director__c",'+
                            '    "LOP_Field_API_Name__c": "sales_director_id",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: LOP Deleted",'+
                            '    "LOP_Field_API_Name__c": "deleted",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: NMLS",'+
                            '    "SF_Field_API_Name__c": "NMLS__c",'+
                            '    "LOP_Field_API_Name__c": "nmls",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: ID",'+
                            '    "SF_Field_API_Name__c": "ID",'+
                            '    "LOP_Field_API_Name__c": "salesforce_id",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Phone",'+
                            '    "SF_Field_API_Name__c": "Phone",'+
                            '    "LOP_Field_API_Name__c": "phone",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: State",'+
                            '    "SF_Field_API_Name__c": "State",'+
                            '    "LOP_Field_API_Name__c": "state",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Last Name",'+
                            '    "SF_Field_API_Name__c": "Lastname",'+
                            '    "LOP_Field_API_Name__c": "last_name",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: LOP Password",'+
                            '    "LOP_Field_API_Name__c": "password",'+
                            '    "Static_Value__c": "12345678",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: City",'+
                            '    "SF_Field_API_Name__c": "City",'+
                            '    "LOP_Field_API_Name__c": "city",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Mailing State",'+
                            '    "SF_Field_API_Name__c": "MailingState",'+
                            '    "LOP_Field_API_Name__c": "state",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Email UID",'+
                            '    "SF_Field_API_Name__c": "Email",'+
                            '    "LOP_Field_API_Name__c": "uid",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Title",'+
                            '    "SF_Field_API_Name__c": "Title",'+
                            '    "LOP_Field_API_Name__c": "title",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Address",'+
                            '    "SF_Field_API_Name__c": "Address",'+
                            '    "LOP_Field_API_Name__c": "street",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Email",'+
                            '    "SF_Field_API_Name__c": "Email",'+
                            '    "LOP_Field_API_Name__c": "email",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: SD Email UID",'+
                            '    "SF_Field_API_Name__c": "Email",'+
                            '    "LOP_Field_API_Name__c": "uid",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "sales_director"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: LOP Password",'+
                            '    "LOP_Field_API_Name__c": "password",'+
                            '    "Static_Value__c": "12345678",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Mobile Phone",'+
                            '    "SF_Field_API_Name__c": "MobilePhone",'+
                            '    "LOP_Field_API_Name__c": "mobile",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Mailing Postal Code",'+
                            '    "SF_Field_API_Name__c": "MailingPostalCode",'+
                            '    "LOP_Field_API_Name__c": "zipcode",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Mailing City",'+
                            '    "SF_Field_API_Name__c": "MailingCity",'+
                            '    "LOP_Field_API_Name__c": "city",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Email",'+
                            '    "SF_Field_API_Name__c": "Email",'+
                            '    "LOP_Field_API_Name__c": "email",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Mobile Phone",'+
                            '    "SF_Field_API_Name__c": "MobilePhone",'+
                            '    "LOP_Field_API_Name__c": "mobile",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: LOP Role",'+
                            '    "LOP_Field_API_Name__c": "role",'+
                            '    "Static_Value__c": "user",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: SD Phone",'+
                            '    "SF_Field_API_Name__c": "Phone",'+
                            '    "LOP_Field_API_Name__c": "phone",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "sales_director"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: LOP Unit",'+
                            '    "LOP_Field_API_Name__c": "unit",'+
                            '    "Static_Value__c": "metric",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Top Level Parent",'+
                            '    "SF_Field_API_Name__c": "Top_Level_Parent__c",'+
                            '    "LOP_Field_API_Name__c": "lender_id",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Postal Code",'+
                            '    "SF_Field_API_Name__c": "PostalCode",'+
                            '    "LOP_Field_API_Name__c": "zipcode",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: ID",'+
                            '    "SF_Field_API_Name__c": "Id",'+
                            '    "LOP_Field_API_Name__c": "salesforce_id",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Phone",'+
                            '    "SF_Field_API_Name__c": "Phone",'+
                            '    "LOP_Field_API_Name__c": "phone",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Mailing Street",'+
                            '    "SF_Field_API_Name__c": "MailingStreet",'+
                            '    "LOP_Field_API_Name__c": "street",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Title",'+
                            '    "SF_Field_API_Name__c": "Title",'+
                            '    "LOP_Field_API_Name__c": "title",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Signed PMP",'+
                            '    "SF_Field_API_Name__c": "Signed_PMP__c",'+
                            '    "LOP_Field_API_Name__c": "first_time",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Sales Director ID",'+
                            '    "SF_Field_API_Name__c": "Id",'+
                            '    "LOP_Field_API_Name__c": "salesforce_id",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "sales_director"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: SD Last Name",'+
                            '    "SF_Field_API_Name__c": "Lastname",'+
                            '    "LOP_Field_API_Name__c": "last_name",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "sales_director"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: First Name",'+
                            '    "SF_Field_API_Name__c": "FirstName",'+
                            '    "LOP_Field_API_Name__c": "first_name",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: LOP Role",'+
                            '    "LOP_Field_API_Name__c": "role",'+
                            '    "Static_Value__c": "User",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Account: ID",'+
                            '    "SF_Field_API_Name__c": "Id",'+
                            '    "LOP_Field_API_Name__c": "salesforce_id",'+
                            '    "SF_Object__c": "Account",'+
                            '    "LOP_Object__c": "Lender"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Account: LOP Deleted",'+
                            '    "LOP_Field_API_Name__c": "deleted",'+
                            '    "SF_Object__c": "Account",'+
                            '    "LOP_Object__c": "Lender"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: LOP Unit",'+
                            '    "LOP_Field_API_Name__c": "unit",'+
                            '    "Static_Value__c": "metric",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: SD First Name",'+
                            '    "SF_Field_API_Name__c": "FirstName",'+
                            '    "LOP_Field_API_Name__c": "first_name",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "sales_director"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Contact: Signed PMP",'+
                            '    "SF_Field_API_Name__c": "Signed_PMP__c",'+
                            '    "LOP_Field_API_Name__c": "first_time",'+
                            '    "SF_Object__c": "Contact",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: First Name",'+
                            '    "SF_Field_API_Name__c": "FirstName",'+
                            '    "LOP_Field_API_Name__c": "first_name",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Last Name",'+
                            '    "SF_Field_API_Name__c": "Lastname",'+
                            '    "LOP_Field_API_Name__c": "last_name",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: LOP Deleted",'+
                            '    "LOP_Field_API_Name__c": "deleted",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "User: Email UID",'+
                            '    "SF_Field_API_Name__c": "Email",'+
                            '    "LOP_Field_API_Name__c": "uid",'+
                            '    "SF_Object__c": "User",'+
                            '    "LOP_Object__c": "User"'+
                            '  },'+
                            '  {'+
                            '    "Name": "Account: Name",'+
                            '    "SF_Field_API_Name__c": "Name",'+
                            '    "LOP_Field_API_Name__c": "name",'+
                            '    "SF_Object__c": "Account",'+
                            '    "LOP_Object__c": "Lender"'+
                            '  }'+
                            ']';
        List<LOP_Field_Map__c> LOPFieldMapList = (List<LOP_Field_Map__c>)(JSON.deserialize(jsonObjList, List<LOP_Field_Map__c>.class));
        return LOPFieldMapList;
    }
}