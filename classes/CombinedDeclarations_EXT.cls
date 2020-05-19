public class CombinedDeclarations_EXT {

    //Deprecated --- Not used
    /*
    private final Opportunity theOpp;
    private final Id oppId;    
    
    public CombinedDeclarations_EXT(apexpages.StandardController sc){
        theOpp = (Opportunity)sc.getRecord();
        oppId = sc.getId();
    }
    
    public string getCombinedDeclarations(){
        string toReturn = '';
        for(Opportunity o: [SELECT Applicant__r.Declaration_Explanation__c,
                            Applicant2__r.Declaration_Explanation__c,
                            Applicant3__r.Declaration_Explanation__c,
                            Co_Applicant__r.Declaration_Explanation__c,
                            Co_Applicant2__r.Declaration_Explanation__c,
                            Co_Applicant3__r.Declaration_Explanation__c
                            FROM Opportunity WHERE Id=:this.oppId]){
        	toReturn += (o.Applicant__r.Declaration_Explanation__c != NULL ? 'app1:' + o.Applicant__r.Declaration_Explanation__c  + '<br/><br/>' : '');
        	toReturn += (o.Co_Applicant__r.Declaration_Explanation__c != NULL ? 'co-app1:' +  o.Co_Applicant__r.Declaration_Explanation__c  + '<br/><br/>': '');
        	toReturn += (o.Applicant2__r.Declaration_Explanation__c != NULL ? 'app2:' + o.Applicant2__r.Declaration_Explanation__c  + '<br/><br/>': '');
        	toReturn += (o.Co_Applicant2__r.Declaration_Explanation__c != NULL ? 'co-app2:' + o.Co_Applicant2__r.Declaration_Explanation__c  + '<br/><br/>': '');
        	toReturn += (o.Applicant3__r.Declaration_Explanation__c != NULL ? 'app3:' + o.Applicant3__r.Declaration_Explanation__c  + '<br/><br/>': '');
        	toReturn += (o.Co_Applicant3__r.Declaration_Explanation__c != NULL ? 'co-app3:' + o.Co_Applicant3__r.Declaration_Explanation__c  + '<br/><br/>': '');                                
		}
        return toReturn;
    }
    */
}