/**
 * Created by Ivan Garcia on 5/6/2019.
 */
@isTest
public with sharing class AWS_OutboundMessageHelperTest {

    @testSetup static void setup(){

        ContentVersion cv = new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

    }

    @IsTest private static void mainTest(){
        Set<String> recordIdSet = new Set<String>();
        for(ContentVersion item: [SELECT id FROM ContentVersion]){
            recordIdSet.add(item.id);
        }
        AWS_OutboundMessageHelper.SendOutboundMessage(recordIdSet,'ContentDocumentInfo');
    }

}