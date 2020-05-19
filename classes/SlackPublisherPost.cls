@istest
public class SlackPublisherPost{
    @testSetup static void setup(){
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;

        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Post-Closing',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = 'Condominium',
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,Lien_First_Lender_Balance__c = 100, Title_Held__c = 'In Trust',IA_OAV_Override__c = 2);
        insert oppty;

        Success_Factor__c sf1     = new Success_Factor__c();
        sf1.Opportunity__c     = oppty.Id;
        sf1.Success_Factor__c  = 'Post-Closing';
        sf1.Status__c = 'In Progress';
        Insert sf1;

        Current_Conditions__c req2 = new Current_Conditions__c();
        req2.Requirement__c     = 'RSI Letter';
        req2.Success_Factor__c  = sf1.Id;
        req2.Reason__c  = 'test';
        req2.opportunity__c      = oppty.id;
        Insert req2;
    }

    @isTest static void testPostSlack(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        List<Opportunity> tmpOppList = [SELECT id FROM Opportunity];
        Test.StartTest();
        SlackPublisher ctrl = new SlackPublisher();
        List<SlackPublisher.Oppty> tmpOppties = new List<SlackPublisher.Oppty>();
        SlackPublisher.Oppty tmpOppty = new SlackPublisher.Oppty();
        tmpOppty.opptyName = 'test0';
        tmpOppties.add(tmpOppty);
        SlackPublisher.postToSlack(tmpOppties);
        Test.StopTest();
    }
    
}