/**
 * Created by Ivan Garcia on 5/13/2019.
 */
@IsTest
public with sharing class BoxControllerTest {
    @testSetup static void setup(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        Account tmpAcc = new Account(Name = 'test');
        insert tmpAcc;
        OAuthApp__c tmpOA = new OAuthApp__c(Access_Token__c = 'test', Name = 'Box');
        insert tmpOA;
    }

    @IsTest private static void redirect(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        Test.startTest();
        BoxController tmpCtrl = new BoxController();
        tmpCtrl.redirectOnCallback();
        Test.stopTest();
    }

    @IsTest private static void mainTest(){
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        Test.startTest();
        Account tmpAcc = [SELECT id FROM Account LIMIT 1];
        BoxController.createFolder(tmpAcc.id);
        Test.stopTest();
    }
}