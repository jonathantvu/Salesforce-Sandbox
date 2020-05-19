@isTest
    private class ExporterTest {
       // CRON expression: midnight on March 15. Because this is a test, job executes immediately after Test.stopTest().
       // =========================================================================
       public static String CRON_EXP = '0 0 0 15 3 ? 2022';
       static testmethod void test() {
          Exporter__c e = new Exporter__c();
            e.Name = 'Test Exporter Record';
            e.Report_ID__c = '00OU0000001xEWe';
            e.Attachment_Name__c = 'Test Attachment Name';
            e.Email_Subject__c = 'Test Email Subject';
            e.Email_Body__c = 'Test Email Body';
            e.Email_Recipients__c = 'abc@abc.com';
          Insert(e);
           
          Test.startTest();
     
          // Schedule the test job
          String jobId = System.schedule('ScheduleApexClassTest',
                            CRON_EXP,
                            new Exporter());
              
          // Get the information from the CronTrigger API object
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];
     
          // Verify the expressions are the same
          System.assertEquals(CRON_EXP,
             ct.CronExpression);
     
          // Verify the job has not run
          System.assertEquals(0, ct.TimesTriggered);
     
          // Verify the next time the job will run
          System.assertEquals('2022-03-15 00:00:00',
             String.valueOf(ct.NextFireTime));
          Test.stopTest();
     
       }
    }