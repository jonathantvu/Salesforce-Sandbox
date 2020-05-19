/**
 * Created by Ivan Garcia on 5/22/2019.
 */

@IsTest public with sharing class MercuryAWSAPITest {
    @testSetup static void setup(){

    }

    @isTest private static void test0(){
        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());

        MercuryAWSAPI.RequestAppraisals tmpReqApp = new MercuryAWSAPI.RequestAppraisals();

        MercuryAWSAPI.Request tmpRequest = new MercuryAWSAPI.Request();
        List<MercuryAWSAPI.RequestAppraisals> tmpListReqApp = tmpRequest.appraisals;

        MercuryAWSAPI.CallAWS(tmpRequest);
    }
}