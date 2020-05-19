@isTest
private class LendingTreeWebhookTest 
{	
	@isTest static void test_method_one() 
    {
		System.Test.startTest();

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/LendingTree/*';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('<LeadInformation RequestType="LONGFORM" LoanRequestType="PURCHASE" IsTest="N"><TrackingNumber>102345679</TrackingNumber><RequestAssignmentDate>2014-04-12</RequestAssignmentDate><ConsumerContactInformation><ContactAddress>123 Main Street</ContactAddress><ContactCity>Charlotte</ContactCity><ContactState>NC</ContactState><ContactZip>28277</ContactZip><EmailAddress IsMasked="Y">consumer@mail.com</EmailAddress><ContactPhone IsMasked="Y">5555555555</ContactPhone><ContactPhoneExtension>78901234</ContactPhoneExtension><ConsumerGeoPhoneAreaCode>704</ConsumerGeoPhoneAreaCode><ConsumerGeoPhoneCountryCode>011</ConsumerGeoPhoneCountryCode><FirstName>John</FirstName><LastName>Tylor</LastName><TimeToContact>0000</TimeToContact></ConsumerContactInformation><ConsumerProfileInformation><DateOfBirth>1972-03-28</DateOfBirth><SSN>111111111</SSN><IsMilitary>Y</IsMilitary><Credit><AssignedCreditValue>800</AssignedCreditValue><SelfCreditRating Id="2">GOOD</SelfCreditRating><Bankruptcy Id="3">25-36_MONTHS</Bankruptcy><Foreclosure Id="6">61-72_MONTHS</Foreclosure></Credit><ProductProfileInformation><WorkingWithAgent>N</WorkingWithAgent><FoundHome>Y</FoundHome><PropertyPurchasePrice>400000</PropertyPurchasePrice> <ExistingCustomerRelationship>Y</ExistingCustomerRelationship></ProductProfileInformation></ConsumerProfileInformation><ProductInformation><PropertyInformation IsTarget="Y"> <PropertyValue>400000</PropertyValue><PropertyType Id="2">SINGLEFAMATT</PropertyType><PropertyUse Id="3">INVESTMENTPROPERTY</PropertyUse><PropertyCounty>MECKLENBURG</PropertyCounty><PropertyZip/><PropertyCity>SAN JOSE</PropertyCity><PropertyMSA>Charlotte-Gastonia-Concord, NC-SC</PropertyMSA><PropertyState>NC</PropertyState></PropertyInformation></ProductInformation><LoanInformation><LoanRequestType Id="1">PURCHASE</LoanRequestType><LoanRequestPurpose></LoanRequestPurpose><DownPayment>50000</DownPayment><LoanAmount>3250000</LoanAmount><PresentLTV>66.6674</PresentLTV><ProposedLTV>66.6674</ProposedLTV><FirstMortgageBalance>160001</FirstMortgageBalance><SecondMortgageBalance>250001</SecondMortgageBalance><Term></Term></LoanInformation><PartnerProfileInformation>5/26/2017 Confidential Page 2<TrusteePartnerID>123456</TrusteePartnerID><NameOfPartner>Bank Of Lending</NameOfPartner><FilterName>NC Premium</FilterName><FilterRoutingID>861827</FilterRoutingID> <FilterCategory>CREDITSCORE_LF</FilterCategory><RoutingParam>lowLA</RoutingParam></PartnerProfileInformation><AdditionalServicesCategory><Option Id="303">plumbing</Option></AdditionalServicesCategory><LeadQuality><Score Id="1" Description="TargusVerification"></Score><Score Id="2" Description="ContactValidation"></Score></LeadQuality><Fees><Fee Id="1" Description="Transmit/Match">24</Fee><Fee Id="2" Description="Transfer">100</Fee></Fees></LeadInformation>');
            RestContext.request = req;
            RestContext.response = res;

            LendingTreeWebhook.CreateLead();

        System.Test.stopTest();

        List<Lead> leadList = [Select Id from Lead];
        System.assertEquals(leadList.size(), 1);
	}
}