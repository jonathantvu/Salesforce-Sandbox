global class Exporter implements System.Schedulable {
    global void execute(SchedulableContext sc) {
        DoExport();
    }
    
    @future(callout=true)
    public static void DoExport(){
        List<Exporter__c> exportList = new List<Exporter__c>{};
        List<Exporter__c> exportUpdateList = new List<Exporter__c>{};
        List<Messaging.SingleEmailMessage> mails  = new List<Messaging.SingleEmailMessage>();
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Date d = Date.today();
        Date firstDate = d.toStartOfMonth();
        Date lastDay = firstDate.addDays(Date.daysInMonth(d.year(), d.month())-1);
        
        system.debug('First Day: ' + firstDate);
        system.debug('Last Day: ' + lastDay);
            
        exportList = [Select Id, Name, Report_ID__c, Attachment_Name__c, Email_Subject__c, Email_Body__c, Email_Recipients__c, Frequency__c, Weekly_Days_Multi__c, Monthly_Day__c, Last_Ran__c from Exporter__c];
        
        for(Exporter__c e : exportList){
            //Determine if Exporter record is scheduled to run today.
            Boolean process = Test.isRunningTest() ? true : false;
            
            //Test for Weekly frequency.
            process = e.Frequency__c == 'Weekly' && e.Weekly_Days_Multi__c.contains(dt.format('EEEE')) ? true : process;
            
            //Test for Monthly frequency.
            process = e.Frequency__c == 'Monthly' && (e.Monthly_Day__c == String.valueOf(d.day()) || e.Monthly_Day__c == 'last' && d == lastDay || lastDay.day() <= Integer.valueOf(e.Monthly_Day__c)) ? true : process;
                       
            //Run process if scheduled.
            if(process){
                System.debug('Starting message processing for: ' + e.Name);
                ApexPages.PageReference report = new ApexPages.PageReference('/' + e.Report_ID__c + '?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(e.Attachment_Name__c);
                Blob content = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : report.getContent();
                attachment.setBody(content);
                attachment.setContentType('text/csv');
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
                message.setSubject(e.Email_Subject__c);
                message.setPlainTextBody(e.Email_Body__c);
                String[] emailRecipients = e.Email_Recipients__c.split(',');
                message.setToAddresses(emailRecipients);
                mails.add(message);
                System.debug('Completed message processing for: ' + e.Name);
                
                //Update Last Ran date and add to update list.
                e.Last_Ran__c = System.now();
                exportUpdateList.add(e);
            }
        }
        //Send the email messages all at once to avoid limits.
        Messaging.sendEmail(mails);
        System.debug('Send emails.');
        
        //Update Export record with Last Ran date.
        update exportUpdateList;
    }
}