/**
 * Created by Carolina Veliz on 7/11/2019.
 */

/* This class was created to implement tickets:
* https://unison-technology.atlassian.net/browse/BUS-155109819
* (Loan Officer, Trustee, and Escrow Contact Roles should be populated upon Lead Conversion (or IDD))
*
* https://unison-technology.atlassian.net/browse/BUS-155109832
* (HO - Add Escrow Contact Role when a Title report is requested by a TS)
*
* */
public class ContactRolesUtility {

    private static List<OpportunityContactRole> contactRoles;
    private static Map<string, contact > mapTrustee;
    private static Map<string, contact > mapEscrow;
    private static Map<string, contact > mapTrusteeColorado;
    private static ID idTrustee;
    private static ID idEscrow;
    private static ID idLender;
    private static ID idAcctRecordType;
    private static Id idHomeBuyerCAN;
    private static contact CONTACT_AmericanTitleInc ;


    public static void setupContactRoles() {

        contactRoles = new List<OpportunityContactRole>();
        idTrustee = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Trustee').getRecordTypeId();
        idLender = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        idAcctRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor Management').getRecordTypeId();
        idHomeBuyerCAN = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeBuyer Canada').getRecordTypeId();


        system.debug(idTrustee);
        system.debug('mapTrustee');
        mapTrustee = new Map<string, contact >();
        mapTrusteeColorado = new Map<string, contact >();

        List<contact> trusteeContacts = [
                select id, name, property_state__c, County__c
                from contact
                where recordtypeid = :idTrustee
                and Contact_Role__c = 'Trustee'
        ];

        system.debug(trusteeContacts);
        for (Contact theContact : trusteeContacts) {
            mapTrustee.put(theContact.property_state__c, theContact);
            if (theContact.property_state__c == 'CO')
                mapTrusteeColorado.put(theContact.County__c, theContact);
            if (theContact.name.contains('American Title Inc'))
                CONTACT_AmericanTitleInc = theContact;
        }

        system.debug(mapTrustee);
        system.debug(mapTrusteeColorado);

    }


    private static void createEscrowOfficer(ID oppID, id theContact){
        if (theContact != Null) {
            OpportunityContactRole contactRole = new OpportunityContactRole();
            system.debug('ld.Escrow_Officer__c');
            system.debug(theContact);
            //system.debug(ld.Escrow_Officer__r.id);
            contactRole.ContactId = theContact;
            contactRole.Role = 'Escrow';
            contactRole.OpportunityId = oppId;
            contactRoles.add(contactRole);
        }

    }

    private static void createEscrowOfficerForOpp(Opportunity opp, string orderType){
        idEscrow = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Escrow').getRecordTypeId();
        string contactsQuery;
        OpportunityContactRole theContactRole;
        Contact theContact;
        string propertyState = '';


        List<OpportunityContactRole> contactRoles = [ select ContactId,  OpportunityId from OpportunityContactRole
                                                        where OpportunityId = :opp.id and Role = 'Escrow' limit 1];
        if (contactRoles.size()>0)
            theContactRole = contactRoles[0];

        string Escrow = 'Escrow';
        contactsQuery = 'select id, name, property_state__c, County__c,Contact_Role__c, order_type__C '+

        'from contact  '+
        'where recordtypeid = :idEscrow '+
        'and Contact_Role__c = :Escrow '+
        'and order_type__c = :orderType {0} '+

        'limit 1  ';
        List<Object> parameters = new List<Object> {'and property_state__c = :propertyState ' };

        if (OrderType != ''){

            if ((OrderType == 'Spruce') &&
                (opp.property_state__c == 'AZ' ||
                opp.property_state__c == 'CA' ||
                opp.property_state__c == 'OH' ||
                opp.property_state__c == 'VA' ||
                opp.property_state__c == 'FL' ||
                opp.property_state__c == 'IL' ||
                opp.property_state__c == 'GA' ||
                opp.property_state__c == 'NV' ||
                opp.property_state__c == 'CT' ||
                opp.property_state__c == 'DE' )){
                propertyState = opp.Property_State__c;
            }
            else if ((OrderType == 'Vantage') &&
                      ( opp.property_state__c == 'CA' ||
                            opp.property_state__c == 'WA' ||
                            opp.property_state__c == 'GA' )){
                propertyState = opp.Property_State__c;
            }

        }

        system.debug(parameters);
        contactsQuery = string.format( contactsQuery, parameters );

        system.debug(contactsQuery);

        List<Contact> theContacts = database.query(contactsQuery);
        if  (theContacts.size()>0)
            theContact = theContacts[0];

        if (theContact != null) {
            if (contactRoles.size() > 0) {
                theContactRole.ContactId = theContact.id;

            }
            else{
                theContactRole = new OpportunityContactRole();
                theContactRole.ContactId = theContact.id;
                theContactRole.Role = 'Escrow';
                theContactRole.OpportunityId = opp.Id;
            }
        }

        system.debug(theContact);
        system.debug(theContactRole);
        if (theContactRole != null )
            upsert theContactRole;
    }

    public static void createEscrowOfficerForSpruce(Opportunity opp) {
        createEscrowOfficerForOpp(opp, 'Spruce');
    }

    public static void createEscrowOfficerForVantage(Opportunity opp) {
        createEscrowOfficerForOpp(opp, 'Vantage');
    }

    public static void createContactRoles(List<Opportunity> opps) {
        //if (TriggrUtility.RunOnceOCR) {

            system.debug('Create Contact Roles for Opportunity');
            system.debug(opps.size());
            system.debug(opps);
            setupContactRoles();



            for (Opportunity opp : opps) {
                createTrusteeOfficerForColorado(opp);
            }
            insertContactRoles();
            //TriggrUtility.RunOnceOCR = false;
        //}
    }

    private static void createTrusteeOfficerForColorado(Opportunity opp){
        contact theContact;
        if (opp.Property_State__c == 'CO' && string.isNotEmpty(opp.Property_County__c )) {
            theContact = mapTrusteeColorado.get(opp.Property_County__c);
            system.debug('trustee theContact');
            system.debug(theContact);

            if (theContact == null) {
                Account theAccount = New Account();
                theAccount.type = 'Vendor';
                theAccount.Website = 'http://the.website.com';
                theAccount.RecordTypeId = idAcctRecordType;
                theAccount.Name = 'The Public Trustee of ' + opp.Property_County__c + ' County';
                /* Caro Veliz
                * To implement ticket: https://unison-technology.atlassian.net/browse/BUS-155110359 */
                theAccount.Only_SysAdmin_Can_Edit__c = true;
                /***/
                insert theAccount;

                theContact = New contact();
                theContact.accountid=theAccount.id;
                theContact.recordtypeid = idTrustee;
                theContact.Contact_Role__c = 'Trustee';
                theContact.Property_State__c = opp.Property_State__c;
                theContact.County__c = opp.Property_County__c;

                theContact.FirstName = 'The Public Trustee of';
                theContact.LastName = opp.Property_County__c + ' County';
                theContact.email = 'noemail@noemail.com';
                theContact.phone = '+180 000 000';
                /* Caro Veliz
                * To implement ticket: https://unison-technology.atlassian.net/browse/BUS-155110359 */
                theContact.Only_SysAdmin_Can_Edit__c = true;
                /***/


                insert theContact;
                //addContactRoles(opp.id, theContact);
            } else {
                //addContactRoles(opp.id, theContact);
            }

            List<OpportunityContactRole> contactRoles = [ select ContactId,  OpportunityId from OpportunityContactRole
            where OpportunityId = :opp.id and Role = 'Trustee' limit 1];
            OpportunityContactRole theContactRole;

            if (contactRoles.size()>0)
                theContactRole = contactRoles[0];

            if (theContact != null) {
                if (contactRoles.size() > 0) {
                    theContactRole.ContactId = theContact.id;

                }
                else{
                    theContactRole = new OpportunityContactRole();
                    theContactRole.ContactId = theContact.id;
                    theContactRole.Role = 'Trustee';
                    theContactRole.OpportunityId = opp.Id;
                }
            }

            system.debug(theContact);
            system.debug(theContactRole);
            if (theContactRole != null )
                upsert theContactRole;
        }
    }

    public static void createContactRoles(Lead ld) {
        system.debug('Create Contact Roles');

        createLoanOfficer(ld);
        createEscrowOfficer(ld.ConvertedOpportunityId,ld.Escrow_Officer__c);
        createTrusteeOfficer(ld);
        createLoanProcessorOfficer(ld.ConvertedOpportunityId,ld.Loan_Processor__c);
        createBuyersRealEstateAgent(ld.ConvertedOpportunityId,ld.Real_Estate_Agent__c);
        createHBCLender(ld);
    }

    public static void insertContactRoles() {
        system.debug('++contactRoles');
        system.debug(contactRoles);
        if (contactRoles.size() > 0) {
            upsert contactRoles;
        }
    }


    private static void addContactRoles(ID oppID, contact theContact) {
        system.debug('addContactRoles');
        system.debug(theContact);
        if (theContact != null) {
            OpportunityContactRole contactRole = new OpportunityContactRole();
            contactRole.ContactId = theContact.id;
            contactRole.Role = 'Trustee';
            contactRole.OpportunityId = oppID;
            contactRoles.add(contactRole);
        }
    }

    private static void createLoanOfficer(Lead ld){
        //Create Contact Roles
        if (ld.Loan_Officer__c != Null) {
            OpportunityContactRole contactRole = new OpportunityContactRole();
            system.debug('ld.Loan_Officer__c');
            system.debug(ld.Loan_Officer__c);
            system.debug(ld.Loan_Officer__r.id);
            contactRole.ContactId = ld.Loan_Officer__r.id;
            contactRole.Role = 'Loan Officer';
            contactRole.OpportunityId = ld.ConvertedOpportunityId;
            contactRoles.add(contactRole);
        }
    }


    private static void createTrusteeOfficer(Lead ld){
        /* retrieve Trustee Contact depending on the Lead.Property State*/
        system.debug('ld.Property_State__c');
        system.debug(ld.Property_State__c);
        if (string.isNotEmpty(ld.Property_State__c) &&
                //For COLORADO Trustee will be assigned when Opp changes to Stage = Closing.
                ld.Property_State__c != 'CO' ) {

            contact theContact;

            if ((ld.Property_State__c == 'VA') ||
                    (ld.Property_State__c == 'OR') ||
                    (ld.Property_State__c == 'UT')) {

                //if (ld.Property_State__c == 'UT')
                //    theContact = mapTrustee.get('FL');
                //else
                    theContact = mapTrustee.get(ld.Property_State__c);

                addContactRoles(ld.ConvertedOpportunityId, theContact);

            }
            // All the other states
            else {
                addContactRoles(ld.ConvertedOpportunityId, CONTACT_AmericanTitleInc);
            }
        }
    }

    private static void createContactRole(ID oppID, id theContact, string role){
        if (oppID != null && theContact != null) {
            OpportunityContactRole contactRole = new OpportunityContactRole();
            contactRole.ContactId = theContact;
            contactRole.Role = role;
            contactRole.OpportunityId = oppId;
            contactRoles.add(contactRole);
        }

    }

    private static void createLoanProcessorOfficer(ID oppID, id theContact){
        createContactRole(oppID, theContact, 'LO Processor');
    }

    private static void createBuyersRealEstateAgent(ID oppID, id theContact){
        createContactRole(oppID, theContact, 'Buying Real Estate Agent');
    }
    private static void createHBCLender( Lead ld){
        if (ld.RecordTypeId == IdHomeBuyerCAN){
            List<contact> lenderContacts = [
                    select id, name
                    from contact
                    where recordtypeid = :idLender
                    and Contact_Role__c = 'Lender'
                    and HBC_Eligible__c = true
                    limit 1
            ];
            if (lenderContacts.size()>0){
                Contact theContact = lenderContacts[0];
                createContactRole(ld.ConvertedOpportunityId, theContact.id , 'Lender');
            }
    }
    }
}