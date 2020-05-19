@isTest
private class LeadOwnerTest {
    @testSetup
    private static void testData() {
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Group g1 = new Group(Name='Daily Dialer Queue', type='Queue');
            insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
        User u = new User(
        ProfileId = p.Id,
        LastName = 'last',
        Email = 'ragasindhu.adapala@unison.com',
        Username = 'ragasindhu.adapala@unison.com' + System.currentTimeMillis(),
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
        insert u;
        system.runAs(u) {
            List<Lead> leadList = new List<Lead>(); 
            //Sundar Subramaniam 03/27/2019 - change in the criteria with respect to HB Lead Status Update Project - CM-50  
            
            /*
                Lead l1 = new Lead(LastName= u.LastName,   Company= u.CompanyName, Status= 'Pending Qualified', OwnerId= u.Id);
            leadList.add(l1); 
            Lead l2 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Pending Qualified', OwnerId= g1.Id);
            leadList.add(l2);
            Lead l3 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Closed Lost', OwnerId= g1.Id);
            leadList.add(l3);
            Lead l4 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Credit Qualified', OwnerId= g1.Id);
            leadList.add(l4);
            Lead l5 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Guideline Qualified', OwnerId= g1.Id);
            leadList.add(l5);
            Lead l6 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Application Sent', OwnerId= g1.Id);
            leadList.add(l6);
            Lead l7 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Application Received', OwnerId= g1.Id);
            leadList.add(l7);
            Lead l8 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Documents In', OwnerId= g1.Id);
            leadList.add(l8);
            Lead l9 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Application Sent', OwnerId= g1.Id);
            */
            
            
            
            
            Lead l1 = new Lead(LastName= u.LastName,   Company= u.CompanyName, Status= 'Pre Discovery', OwnerId= u.Id);
            leadList.add(l1); 
            Lead l2 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Pre Discovery', OwnerId= g1.Id);
            leadList.add(l2);
            Lead l3 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Closed Lost', OwnerId= g1.Id);
            leadList.add(l3);
            Lead l4 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Pre Discovery', OwnerId= g1.Id);
            leadList.add(l4);
            Lead l5 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Discovery', OwnerId= g1.Id);
            leadList.add(l5);
            Lead l6 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Application Sent', OwnerId= g1.Id);
            leadList.add(l6);
            Lead l7 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Pending Submission', OwnerId= g1.Id);
            leadList.add(l7);
            Lead l8 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Pending Submission', OwnerId= g1.Id);
            leadList.add(l8);
            Lead l9 = new Lead(LastName= 'Queue',   Company= 'Test Company', Status= 'Application Sent', OwnerId= g1.Id);
            leadList.add(l9);

            
            insert leadList;
            
            LeadQual_Authentication__c temp = new LeadQual_Authentication__c();
            temp.Eed_Point_URL__c = 'http:\\www.test.com';
            insert temp;
        }
        
        
    }    
    @isTest
    public static void testbatchjob(){
        Test.startTest();
        LeadOwner o = new LeadOwner();
        Database.executeBatch(o);
        String sch = '0 0 1 * * ?'; 
        system.schedule('Test Territory Check', sch, o);
        Test.stopTest();
        
    }    
}