@isTest
public class GreenLightInquiryTest {
    
    public static testMethod void TestSendInquiry() {
        
        // Data setup
        Lead le1 = new Lead();
        le1.LastName = 'Test937153';
        le1.Status = 'Pending Qualification';
        le1.Company = 'Test983729';
        le1.Property_Street_Number_and_Name__c = '1234 Sesamy Street';
        le1.Property_City__c = 'Los Angeles';
        le1.Property_State__c = 'CA';
        le1.Property_Zip_Code__c = '00000';
        le1.New_Construction_Dropdown__c = 'Yes';
        le1.Occupancy_Statement_Dropdown__c = 'Principal Residence';
        le1.Property_Type__c = 'Townhouse';
		le1.Income_Monthly_Base__c  = 6000;
		le1.Home_Value__c =100000;        
        insert le1;

        Test.setMock(HttpCalloutMock.class, new GreenLightTest.MockClass());
        
        // Run the code
        Test.startTest();

        GreenLightInquiry ctrl = new GreenLightInquiry(new Apexpages.StandardController(le1));
        ctrl.MakeCall();
        Lead le2 = [SELECT Greenlight_Id__c, Inquiry_Sequence_ID__c FROM Lead WHERE Id = :le1.Id];

        Test.stopTest();
        
        // Verify Results
        System.assertEquals('test276834', le2.Greenlight_Id__c);
        System.assertEquals('test276835', le2.Inquiry_Sequence_ID__c);
        if (GreenLightAPI.Settings.Save_Logs__c)
            System.assertEquals(1, [SELECT COUNT() FROM GreenLight_API_Log__c]);
        
    }

    public static testMethod void TestSendInquiry_Errors() {
        
        // Data setup
        Lead le1 = new Lead();
        le1.LastName = 'Test937153';
        le1.Status = 'Pending Qualification';
        le1.Company = 'Test983729';
		le1.Income_Monthly_Base__c  = 6000;
		le1.Home_Value__c =100000;        
        insert le1;

        Test.setMock(HttpCalloutMock.class, new GreenLightTest.MockClass());
        
        // Run the code
        Test.startTest();

        GreenLightInquiry ctrl = new GreenLightInquiry(new Apexpages.StandardController(le1));
        ctrl.MakeCall();
        Lead le2 = [SELECT Greenlight_Id__c, Inquiry_Sequence_ID__c FROM Lead WHERE Id = :le1.Id];

        Test.stopTest();
        
        // Verify Results
        System.assertEquals(null, le2.Greenlight_Id__c);
        System.assertEquals(null, le2.Inquiry_Sequence_ID__c);
        
    }
}