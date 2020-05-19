@isTest
public class DelightedTests {

    @isTest
    public static void TestSendLead(){
        
        // Data setup
        Lead l = new Lead();
        l.FirstName = 'RealFirstName';
        l.LastName = 'RealLastName923078';
        l.Email = 'AnEmail.email923078@example.com';
        l.Company = 'Company923078';
        l.Campaign_Source__c = 'web';
        insert l;
        
        Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
        npm.Status__c = 'Draft';
        npm.Lead__c = l.Id;
        insert npm;
        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        
        // Run the code
        Test.startTest();
        DelightedHelper.SendSurveyLead(npm.Id, l.Id);
        Test.stopTest();
        
        // Verify Results
        System.assertEquals(1, [SELECT COUNT() FROM Net_Promoter_Measurement__c WHERE Lead__c = :l.Id]);
    }
    
    @isTest
    public static void TestSendOpportunity(){
        
        // Data setup
        Account a = new Account();
        a.Name = 'Totally a Real Account';
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Opportunity923079';
        o.StageName = 'Introduction';
        o.CloseDate = Date.today();
        o.AccountId = a.Id;
        insert o;
        
        Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
        npm.Status__c = 'Draft';
        npm.Opportunity__c = o.Id;
        insert npm;
        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        
        // Run the code
        Test.startTest();
        DelightedHelper.SendSurveyOpportunity(npm.Id, o.Id);
        Test.stopTest();
        
        // Verify Results
        System.assertEquals(1, [SELECT COUNT() FROM Net_Promoter_Measurement__c WHERE Opportunity__c = :o.Id]);
    }

	@isTest
    public static void TestSendContact(){
        
        // Data setup
        Account a = new Account();
        a.Name = 'Totally a Real Account';
        insert a;
        
		Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('contact').getDescribe();
        Id rtId = describeResult.getRecordTypeInfosByName().get('Lender').getRecordTypeId();

        contact con = new Contact(FirstName = 'fname', LastName = 'LName', Email='lname@test.com', AccountId = a.Id,
									RecordTypeId= rtId, Contact_Role__c = 'Loan Officer');
		insert con;
        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        
        // Run the code
        Test.startTest();
        DelightedHelper.SendSurveyLOContact(con);
        Test.stopTest();
        
        // Verify Results
        System.assertEquals(1, [SELECT COUNT() FROM Net_Promoter_Measurement__c WHERE Contact__c = :con.Id]);
    }
    
    @isTest
    public static void TestWebhook(){
        
        // Data setup
        Lead l = new Lead();
        l.FirstName = 'RealFirstName90210';
        l.LastName = 'RealLastName90210';
        l.Email = 'email90210@example.com';
        l.Company = 'Company90210';
        l.Campaign_Source__c = 'web';
        insert l;
        
        Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
        npm.Lead__c = l.Id;
        insert npm;
                
        // Run the code
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf('{ ' +
                                              '"event_type": "survey_response.updated", ' +
                                              '"event_id": "b8d057c59327541d7ec2104c0a9a255ad1997fb00831b9c6bbf09561e6d5cbd0", ' +
                                              '"event_data": { ' +
                                                '"id": "5435", ' +
                                                '"person": { ' +
                                                  '"id": "5975", ' +
                                                  '"email": "charlie_gravis@example.com", ' +
                                                  '"name": "Charlie Gravis", ' +
                                                  '"created_at": 1553182454 ' +
                                                '}, ' +
                                                '"survey_type": "nps", ' +
                                                '"score": 9, ' +
                                                '"comment": "Your service is fast and flawless!", ' +
                                                '"permalink": "https://delighted.com/r/5pFDpmlyC8GUc5oxU6USto5VonSKAqOa", ' +
                                                '"created_at": 1553182514, ' +
                                                '"updated_at": 1553183114, ' +
                                                '"person_properties": { "lead" : "' + l.Id + '" }, ' +
                                                '"notes": [], ' +
                                                '"tags": [], ' +
                                                '"additional_answers": [ ' +
                                                  '{ ' +
                                                    '"id": "4", ' +
                                                    '"value": { ' +
                                                      '"free_response": null, ' +
                                                      '"scale": null, ' +
                                                      '"select_one": null, ' +
                                                      '"select_many": [ ' +
                                                        '{ ' +
                                                          '"id": "DxmjNj", ' +
                                                          '"text": "Convenience" ' +
                                                        '}, ' +
                                                        '{ ' +
                                                          '"id": "uNQIig", ' +
                                                          '"text": "Friendly staff" ' +
                                                        '} ' +
                                                      '] ' +
                                                    '}, ' +
                                                    '"question": { ' +
                                                      '"id": "enum_z9EvYV", ' +
                                                      '"type": "select_many", ' +
                                                      '"text": "What specifically did you enjoy about your experience with us?" ' +
                                                    '} ' +
                                                  '}, ' +
                                                  '{ ' +
                                                    '"id": "5", ' +
                                                    '"value": { ' +
                                                      '"free_response": null, ' +
                                                      '"scale": null, ' +
                                                      '"select_one": { ' +
                                                        '"id": "tp0Q4K", ' +
                                                        '"text": "Yes" ' +
                                                      '}, ' +
                                                      '"select_many": null ' +
                                                    '}, ' +
                                                    '"question": { ' +
                                                      '"id": "enum_caUUdY", ' +
                                                      '"type": "select_one", ' +
                                                      '"text": "Have you purchased from us in the past?" ' +
                                                    '} ' +
                                                  '}, ' +
                                                  '{ ' +
                                                    '"id": "6", ' +
                                                    '"value": { ' +
                                                      '"free_response": null, ' +
                                                      '"scale": 4, ' +
                                                      '"select_one": null, ' +
                                                      '"select_many": null ' +
                                                    '}, ' +
                                                    '"question": { ' +
                                                      '"id": "integer_buwb3w", ' +
                                                      '"type": "scale", ' +
                                                      '"text": "How often do you shop at one of our stores?" ' +
                                                    '} ' +
                                                  '}, ' +
                                                  '{ ' +
                                                    '"id": "7", ' +
                                                    '"value": { ' +
                                                      '"free_response": "A friend recommended you to me!", ' +
                                                      '"scale": null, ' +
                                                      '"select_one": null, ' +
                                                      '"select_many": null ' +
                                                    '}, ' +
                                                    '"question": { ' +
                                                      '"id": "text_BJPEm0", ' +
                                                      '"type": "free_response", ' +
                                                      '"text": "How did you hear about us?" ' +
                                                    '} ' +
                                                  '} ' +
                                                '] ' +
                                              '} ' +
                                            '}');
        DelightedWebhook.doPost(); 
        Test.stopTest();
        
        // Verify Results
        npm = [SELECT Comment__c, PermaLink__c, Score__c, Additional_Answers__c FROM Net_Promoter_Measurement__c WHERE Lead__c = :l.Id];
        System.assertEquals('Your service is fast and flawless!', npm.Comment__c);
        System.assertEquals(9, npm.Score__c);
        System.assertEquals('https://delighted.com/r/5pFDpmlyC8GUc5oxU6USto5VonSKAqOa', npm.PermaLink__c);
        System.debug(npm.Additional_Answers__c);
    }
}