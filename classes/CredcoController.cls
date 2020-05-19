//DEPRECATED AS OF 7/3/2017
//PER PAUL TUCKER: 
//We do not have any need for CredCo functionality. 
//This was an apparently costly experiment that predates both John and I.
public with sharing class CredcoController {
/*
    private final sObject mysObject;

    public CredcoController(ApexPages.StandardController stdController) {

    }

    public PageReference pageMethod() {
       String contactId = ApexPages.currentPage().getParameters().get('Id');
       basicAuthCallout(contactId);
       PageReference retURL = new PageReference('/' + contactId);
       retURL.setRedirect(true);
       return retURL;
    }

    @future(callout=true)
    public static void basicAuthCallout(String contactId) {
        String USERNAME = '4002696';
        String PASSWORD = '64WLGVTP';
        String ENDPOINT = 'https://beta.credcoconnect.com/cc/listener'; //Prod: https://www.credcoconnect.com/cc/listener
        String CERTIFICATE_NAME = 'salesforce';

        Contact currContact = [SELECT FirstName, LastName, Social_Security_Number__c, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :contactId LIMIT 1];
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod('GET');
        req.setClientCertificateName(CERTIFICATE_NAME);

        String firstname = currContact.FirstName;
        String lastname = currContact.LastName;
        String ssn = currContact.Social_Security_Number__c;
        String streetaddress = currContact.MailingStreet;
        String city = currContact.MailingCity;
        String state = currContact.MailingState;
        String postalcode = currContact.MailingPostalCode;
        String xml = '<REQUEST_GROUP MISMOVersionID="2.3"><REQUESTING_PARTY><PREFERRED_RESPONSE _Format="XML"/><PREFERRED_RESPONSE _Format="Text"/><PREFERRED_RESPONSE _Format="PDF"/></REQUESTING_PARTY><REQUEST LoginAccountIdentifier="' + USERNAME + '" LoginAccountPassword="' + PASSWORD + '"><REQUEST_DATA><CREDIT_REQUEST MISMOVersionID="2.3"><CREDIT_REQUEST_DATA CreditRequestType="Individual" CreditReportRequestActionType="Submit" CreditReportType="Other" CreditReportTypeOtherDescription="BureauPrint"/><LOAN_APPLICATION><BORROWER _FirstName="' + firstname + '" _LastName="' + lastname + '" _PrintPositionType="Borrower" _SSN="' + ssn + '"><_RESIDENCE _StreetAddress="' + streetaddress + '" _City="' + city + '" _State="' + state + '" _PostalCode="' + postalcode + '" BorrowerResidencyBasisType="Own" BorrowerResidencyType="Current"></_RESIDENCE></BORROWER></LOAN_APPLICATION></CREDIT_REQUEST></REQUEST_DATA></REQUEST></REQUEST_GROUP>';
        String resbody;
        req.setBody(xml);
        req.setTimeout(20000);

        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            System.debug(LoggingLevel.INFO, 'STATUS: ' + res.getStatus());
            System.debug(LoggingLevel.INFO, 'STATUS_CODE: ' + res.getStatusCode());
            if (res.getStatusCode() != 200) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'CREDCO Connection error! Status: ' + res.getStatus() + ' Status code: ' + res.getStatusCode()));
                return;
            } else {
                resbody = res.getBody();
            }
        } catch(System.CalloutException e) {
            System.debug('Error: ' + e);
        }

        Dom.Document doc = new Dom.Document();
        doc.load(resbody);

        String curr_tradelines_cnt;
        String cls_tradelines_cnt;
        String unr_tradelines_cnt;
        String late30d;
        String late60d;
        String late90d;
        Integer tradelines_total = 0;
        Integer public_records_cnt = 0;
        String inq_cnt;
        String late30d_hd;
        String late60d_hd;
        String late90d_hd;
        String mnt;
        String score;
        String scores = '';
        String reptype;
        String message;
        String messages = '';
        String err_message;
        String err_messages = '';

        //_TotalPRCount

        Dom.XMLNode ordDtls = doc.getRootElement();
        for (DOM.XMLNode xmlnodeobj:doc.getRootElement().getChildElements()) {
            if(xmlnodeobj.getName()=='RESPONSE') {
                for (DOM.XMLNode xmlrespobj:xmlnodeobj.getChildElements()) {
                    if(xmlrespobj.getName()=='RESPONSE_DATA') {
                        for (DOM.XMLNode xmlrespdata:xmlrespobj.getChildElements()) {
                            if(xmlrespdata.getName()=='CREDIT_RESPONSE') {
                                for (DOM.XMLNode body:xmlrespdata.getChildElements()) {
                                    if(body.getName()=='CREDIT_SUMMARY') {
                                        for (DOM.XMLNode bodydata:body.getChildElements()) {
                                            if (bodydata.getAttribute('_Name', null) == '_TotalCurrentTradelinesCount') {
                                                curr_tradelines_cnt = bodydata.getAttribute('_Value', null);
                                                tradelines_total += integer.valueof(curr_tradelines_cnt);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalClosedTradelinesCount') {
                                                cls_tradelines_cnt = bodydata.getAttribute('_Value', null);
                                                tradelines_total += integer.valueof(cls_tradelines_cnt);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalUnratedTradelinesCount') {
                                                unr_tradelines_cnt = bodydata.getAttribute('_Value', null);
                                                tradelines_total += integer.valueof(unr_tradelines_cnt);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalLate30DaysCurrentDelinquencies') {
                                                late30d = bodydata.getAttribute('_Value', null);
                                                tradelines_total += integer.valueof(late30d);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalLate60DaysCurrentDelinquencies') {
                                                late60d = bodydata.getAttribute('_Value', null);
                                                tradelines_total += integer.valueof(late60d);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalLate90PlusDaysCurrentDelinquencies') {
                                                late90d = bodydata.getAttribute('_Value', null);
                                                tradelines_total += integer.valueof(late90d);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalInquiriesCount') {
                                                inq_cnt = bodydata.getAttribute('_Value', null);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalLate30DaysHistoricalDelinquencies') {
                                                late30d_hd = bodydata.getAttribute('_Value', null);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalLate60DaysHistoricalDelinquencies') {
                                                late60d_hd = bodydata.getAttribute('_Value', null);
                                            } else if (bodydata.getAttribute('_Name', null) == '_TotalLate90PlusDaysHistoricalDelinquencies') {
                                                late90d_hd = bodydata.getAttribute('_Value', null);
                                            }
                                        }
                                    } else if(body.getName()=='CREDIT_PUBLIC_RECORD') {
                                        public_records_cnt++;
                                    } else if(body.getName()=='CREDIT_SCORE') {
                                        mnt = body.getAttribute('_ModelNameType', null);
                                        if (mnt == 'Other') {
                                            mnt = body.getAttribute('_ModelNameTypeOtherDescription', null);
                                        }
                                        score = body.getAttribute('_Value', null);
                                        scores += score + ' ' + mnt + '\n';
                                    } else if(body.getName()=='CREDIT_FILE') {
                                        reptype = body.getAttribute('CreditRepositorySourceType', null);
                                        messages += reptype + ':\n';
                                        for (DOM.XMLNode alerts:body.getChildElements()) {
                                            if(alerts.getName()=='_ALERT_MESSAGE') {
                                                for (DOM.XMLNode alerts_text:alerts.getChildElements()) {
                                                    if(alerts_text.getName()=='_Text') {
                                                        message = alerts_text.getText();
                                                        messages += message + '\n';
                                                    }
                                                }
                                            } else if(alerts.getName()=='CREDIT_COMMENT') {
                                                err_message = alerts.getAttribute('_SourceType', null) + ': ';
                                                for (DOM.XMLNode comm:alerts.getChildElements()) {
                                                    if(comm.getName()=='_Text') {
                                                        err_message += comm.getText();
                                                        err_messages += err_message + '\n';
                                                }
                                            }
                                        }
                                    }
                                    } else if(body.getName()=='CREDIT_ERROR_MESSAGE') {
                                        for (DOM.XMLNode err:body.getChildElements()) {
                                            if(err.getName()=='_Text') {
                                                err_message = err.getText();
                                                err_messages += err_message + '\n';
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
       }

       currContact.TotalCurrentTradelinesCount__c = curr_tradelines_cnt;
       currContact.TotalClosedTradelinesCount__c = cls_tradelines_cnt;
       currContact.TotalUnratedTradelinesCount__c = unr_tradelines_cnt;
       currContact.TotalLate30DaysCurrentDelinquencies__c = late30d;
       currContact.TotalLate60DaysCurrentDelinquencies__c = late60d;
       currContact.TotalLate90PlusDaysCurrentDelinquencies__c = late90d;
       currContact.GrandTotalDelinquencies__c = string.valueof(tradelines_total);
       currContact.Public_records_count__c = string.valueof(public_records_cnt);
       currContact.Inquiry__c = inq_cnt;
       currContact.Delinquencies__c = '30 days: ' + late30d_hd + '; 60 days: ' + late60d_hd + '; 90+ days: ' + late90d_hd;
       currContact.Scores__c = scores;
       currContact.Fraud_alerts__c = messages;
       currContact.Additional_Attributes__c = err_messages;
       update currContact;
     }
*/
}