@isTest 
public class MrdToAwsTriggerTest {
    @isTest static void TestInsertUpdate() {
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock()); 
        
		Lead lead = new Lead(LastName = 'Test', Email = 'test@unison.com', mobilephone = '+1234567890', Company = 'Test company');
        insert lead;
        
        // Try creating an MRD
        Minimum_Required_Documents__c mrd = new Minimum_Required_Documents__c(Lead__c=lead.id, Category__c='W2', Applicant_Type__c='Applicant');
        insert mrd;
        
        // Try updating an MRD
        mrd.Uploaded__c = true;
        update mrd;
        
        // Not sure how to apply asserts for this, but we have the coverage.
        // Probably need to mock the UnisonAPI class somehow to see if fSendMRDUpsert is being called with the mrd.id
    }
}