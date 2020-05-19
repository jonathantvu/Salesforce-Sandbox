/**
 * Created by Ivan Garcia on 5/22/2019.
 */

@IsTest public with sharing class MercuryAPICustomTest {

    @testSetup static void setup(){

    }

    @isTest private static void nullSession(){
        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());

        MercuryAPICustom ctrl = new MercuryAPICustom();
        try{
            MercuryAPICustom.GetAMCCompanies();
        }catch(Exception e){}

        try{
            MercuryAPICustom.GetTypesOfAppraisal();
        }catch(Exception e){}

        try{
            MercuryAPICustom.GetCurrentStatusXSiteClientEx(null);
        }catch(Exception e){}

        try{
            MercuryAPICustom.PlaceAppraisalOrderEx(null);
        }catch(Exception e){}
    }

    @isTest private static void notNullSession(){
        Test.setMock(HttpCalloutMock.class, new SpruceCalloutMock());

        //MercuryAPICustom ctrl = new MercuryAPICustom();
        MercuryAPICustom.sessionId = 'auth';
        try{
            MercuryAPICustom.GetAMCCompanies();
        }catch(Exception e){}

        try{
            MercuryAPICustom.GetTypesOfAppraisal();
        }catch(Exception e){}

        try{
            MercuryAPICustom.GetCurrentStatusXSiteClientEx(null);
        }catch(Exception e){}

        try{
            MercuryAPICustom.PlaceAppraisalOrderEx(null);
        }catch(Exception e){}

        MercuryAPICustom.CreateLogEntry('','','','','','');
        MercuryAPICustom.InsertAllLogs();
    }

    @isTest private static void PlaceAppraisalOrderExTest()
    {
        MercuryAPICustom.sessionId = 'auth';
        String xml = '<root xmlns="http://alamode.com/"><to>Tove</to><bResult>true</bResult><TrackingID>Reminder</TrackingID><body><bResult>true</bResult><TrackingID>Reminder</TrackingID></body></root>';
        String xml2 = '<root xmlns="http://alamode.com/"><to>Tove</to><Success>true</Success><TrackingID>Reminder</TrackingID><body><Success>true</Success><StatusName>Reminder</StatusName></body></root>';

        try{
            MercuryAPICustom.PlaceAppraisalOrderEx(xml);
        }catch(Exception e){}

        try{
            MercuryAPICustom.GetCurrentStatusResponse response = MercuryAPICustom.GetCurrentStatusXSiteClientEx(xml2);
        }catch(Exception e){}

        try{
            MercuryAPICustom.GetTypesOfAppraisal();
        }catch(Exception e){}



    }

}