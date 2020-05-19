//Updated by Neeraja Cherukuri as a part of the ticket fix https://unison-technology.atlassian.net/browse/BUS-155109266

@isTest
public class OrderHomeInspectionTest {
   
    @isTest
    public static void Test1(){
        
        // Data setup
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 936834';
        opp.StageName = 'Submit to Ops';
       opp.UnisonProcessor__c = '00544000009UuV7';

        opp.CloseDate = Date.today();
        insert opp;
        
        // Run the code
        Test.startTest();
        OrderHomeInspection ctrl = new OrderHomeInspection(new ApexPages.StandardController(opp));
        ctrl.emailBody = 'Test Email Body';
        ctrl.emailTo =  'test@test.com';
        ctrl.emailCC = 'test1@test.com';
        ctrl.emailSubject = 'test subject';
        ctrl.emailBody = 'test email body';
        ctrl.generateEmailBody();
        ctrl.SendEmail();
        Test.stopTest();
        
        // Verify Results
        System.assert(ctrl.emailSubject != null);
        opp = [SELECT Home_Inspection_Ordered__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, opp.Home_Inspection_Ordered__c);
    }
    
}