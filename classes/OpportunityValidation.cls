public class OpportunityValidation {

    private Id oppId { get; set; }
    public OpportunityPipelineValidator.ValidationResult result { get; set; }
    
    public OpportunityValidation(ApexPages.StandardController ctrl) {
        oppId = ctrl.getId();
        
        result = OpportunityPipelineValidator.ValidateOpportunity(oppId);
    }

    public PageReference MoveToNextStage() {

        Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :oppId];

        boolean useNext = false;

        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();     
        for (Schema.PicklistEntry s : ple) {
            if (useNext) {
                opp.StageName = s.getValue();
                try {
                    update opp;
                } catch (Exception ex) {
                    ApexPages.addMessages(ex);
                    return null;
                }
                PageReference oppPage = new ApexPages.StandardController(opp).view();
	            oppPage.setRedirect(true);
	            return oppPage;
            }
            if (opp.StageName == s.getValue()) {
                useNext = true;
            }
        }

        return null;
    }
    
}