/**
 * Created by Ivan Garcia on 5/24/2019.
 */

@IsTest public with sharing class OAuthControllerTest {
    @TestSetup static void setup(){

    }

    @isTest public static void test0(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        OAuthController ctrl = new OAuthController();
        ctrl.isCallback = true;
        ctrl.application_name = 'test';

        OAuthApp__c tmpOA = new OAuthApp__c(Access_Token__c = 'test', Name = 'Box', Client_Id__c = '1234567890123', Client_Secret__c = 'Mine', Access_Token_URL__c = '/asdf');
        insert tmpOA;

        OAuthController.OAuthResult tmpOAuth = new OAuthController.OAuthResult();
        tmpOAuth.access_token = 'test';
        tmpOAuth.refresh_token = null;

        PageReference pageRef = new PageReference('/');
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('code','test');
        ApexPages.currentPage().getParameters().put('Host','temp\\?asd');

        try{
            ctrl.validateCode('test','redirecturl');
        }catch(Exception e){}

        try{
            ctrl.getAuthUrl();
        }Catch(Exception e){}

        ctrl.getPageUrl();
        ctrl.getHasToken();

        try{
            ctrl.redirectOnCallback(pageRef);
        }Catch(Exception e){}

    }

}