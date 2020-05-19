public class NintexDocGenValidation {
    
    Id oppId { get; set; }
    public Opportunity opp { get; set; }

    public NintexDocGenValidation(ApexPages.StandardController ctrl) {

        oppId = ctrl.getId();

        opp = [SELECT Id, Maximum_Authorized_Debt_Final__c FROM Opportunity WHERE Id = :oppId];

    }

    public PageReference Validate() {

        if (opp.Maximum_Authorized_Debt_Final__c != null && opp.Maximum_Authorized_Debt_Final__c > 0) {
            return new PageReference('/apex/loop__looplus?filter=CAP&eid=' + oppId);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MAD is currently 0, please ensure IA has created the appropriate mortgage trade account.'));
            return null;
        }
    }

}