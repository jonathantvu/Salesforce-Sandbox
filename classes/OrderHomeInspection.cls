public class OrderHomeInspection {

    private Id oppId;
    private Order_Home_Inspection__mdt settings;
    
    public string errorMessage { get; set; }
    public string emailTo { get; set; }
    public string emailCC { get; set; }
    public string emailSubject { get; set; }
    public string emailBody { get; set; }
    
    public OrderHomeInspection(ApexPages.StandardController ctrl) {
        oppId = ctrl.getId();
        
        for (Order_Home_Inspection__mdt setts : [SELECT Id, Email_Template_API_Name__c, Email_To_Address__c FROM Order_Home_Inspection__mdt LIMIT 1]) {
            settings = setts;
        }
    }
    
    public void generateEmailBody() {
        if (settings != null) {
            emailTo = settings.Email_To_Address__c;
            Opportunity opp = [SELECT Id, Home_Inspection_Ordered__c, UnisonProcessor__r.Email, Owner.Email FROM Opportunity WHERE Id = :oppId];
            
            //Added By Neeraja Cherukuri as a part of a Ticket fix https://unison-technology.atlassian.net/browse/BUS-155109266
            emailCC = opp.UnisonProcessor__r.Email;
                
            List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :settings.Email_Template_API_Name__c];
            if (templates.size() > 0) {
                
                // Fake sending email to obtained the merged fields.
                Savepoint sp = Database.setSavepoint();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(templates[0].Id);
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setWhatId(oppId);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                Database.rollback(sp);
                
                emailSubject = mail.getSubject();
                emailBody = mail.getHtmlBody();
                
            } else {
                errorMessage = '"' + settings.Email_Template_API_Name__c + '" email template could not be found';
            }
        } else {
            errorMessage = '"Order Home Inspection" custom metadata type could not be found';
        }
    }
    
    public PageReference SendEmail() {
        
        Opportunity opp = [SELECT Id, Home_Inspection_Ordered__c, UnisonProcessor__r.Email, Owner.Email FROM Opportunity WHERE Id = :oppId];
        
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailTo.split(','));
        mail.setCcAddresses(new List<String> { opp.UnisonProcessor__r.Email });
        mail.setSubject(emailSubject);
        mail.setUseSignature(false);
        mail.setHtmlBody(emailBody);
        System.debug(Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }));
        
        opp.Home_Inspection_Ordered_Date_TIme__c = datetime.now();
        if (opp.Home_Inspection_Ordered__c != true) {
            opp.Home_Inspection_Ordered__c = true;
            update opp;
        }
        
        return new ApexPages.StandardController(opp).view();
        
    }
    
}