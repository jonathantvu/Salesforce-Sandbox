/*********************************************************
Apex class: LeadConversionProcess
Test Class: LeadTriggerHandlerTest
Author    : Raga Sindhu Adapala

Adjustments:
        Details                        Date        Version
        -------                        ----        -------
1. Created nintex requirements   -  02-14-2019   -   1
1. Creating new object(Property) -  02-13-2019   -   1
***********************************************************/
public class LeadConversionProcess {
    private static final string HOUSEHOLD_RT_LABEL = 'Household';
    private static final string HOME_OWNER = 'HomeOwner';
    private static final string HOME_BUYER = 'HomeBuyer';
    public static boolean createdRequirements  = false;

    public static boolean conversionProcess = false;

    private static List<Lead_Conversion_Process_Field__mdt> fieldsPrivate;
    public static List<Lead_Conversion_Process_Field__mdt> fields {
        get {
            if (fieldsPrivate == null) {
                fieldsPrivate = [SELECT Lead_Field__c, Default_Value__c, Application_Field__c, CoApplicant_Field__c, Property_Field__c, Recorded_Information_Field__c FROM Lead_Conversion_Process_Field__mdt];
            }
            return fieldsPrivate;
        }
    }

    public static void createchildforconvLead(Set<Id> convleadids) {

        List<Case> newcases = new List<Case>();
        List<LASERCA__Personal_Credit_Report__c> newpcrs = new List<LASERCA__Personal_Credit_Report__c>();
        List<dsfs__DocuSign_Status__c> newdocs = new List<dsfs__DocuSign_Status__c>();
        List<Current_Conditions__c> newccs = new List<Current_Conditions__c>();
        List<Project_Task__c> newtasks = new List<Project_Task__c>();
        List<Document_MetaData__c>   newdmds =  new List<Document_MetaData__c>();
        List<Success_Factor__c> newsf = new List<Success_Factor__c>();
        List<Application__c> newapps = new List<Application__c>();
        List<contact> newcoapps = new List<contact>();
        List<Property__c> newprop = new List<Property__c>();
        List<Recorded_Information__c> newrecinfos = new List<Recorded_Information__c>();


        //List<Fee_Management__c> newfeemanage = new List<Fee_Management__c>();
        List<Account> acclist = new List<Account>();
        List<Success_Factor__c> sflist = new List<Success_Factor__c>();
        List<Success_Factor__c> sfreq = new List<Success_Factor__c>();
        Set<Id> accids = new Set<Id>();
        Set<Id> appids = new Set<Id>();
        Set<Id> oppids = new Set<Id>();
        Set<Id> coappids = new Set<Id>();
        Map<Id,Id> oppaccidmap = new Map<Id,Id>();
        Map<Id,string> sfopprtmap = new Map<Id,string>();
        set<Id> exisreq = new set<Id>();

        //map<string, Requirement__mdt> reqMD = new map<string, Requirement__mdt>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Lead');
        Schema.DescribeSobjectResult objTypeDesc = objType.getDescribe();
        map<Id, Schema.RecordTypeInfo> recTypeMap = objTypeDesc.getRecordTypeInfosById();

        string leadQuery = 'SELECT Id';
        for (Lead_Conversion_Process_Field__mdt field : fields) {
            if (field.Lead_Field__c != null && field.Lead_Field__c.trim() != '') {
                leadQuery += ', ' + field.Lead_Field__c;
            }
        }
        leadQuery += ', (SELECT Id, LASERCA__Credit_Score_Median__c, LASERCA__Co_Applicant_Credit_Score_Median__c' + 
                        ' FROM LASERCA__Personal_Credit_Reports__r ORDER BY LastModifiedDate desc LIMIT 1)';
        leadQuery += ', (SELECT Id FROM Cases__r)';
        leadQuery += ', (SELECT Id, Success_Factor__c FROM Risk_Factors__r)';
        leadQuery += ', (SELECT Id FROM Requirements__r)';
        leadQuery += ', (SELECT Id FROM Document_MetaData__r)';
        leadQuery += ', (SELECT Id FROM dsfs__DocuSign_Status__r)';
        leadQuery += ' FROM Lead WHERE Id = :convleadids';
        List<Lead> leadchildrec = Database.query(leadQuery);
        
        Map<Id, List<Project_Task__c>> tasksmap = new Map<Id, List<Project_Task__c>>();
        for (Project_Task__c task : [SELECT Id, Requirement__r.Lead__c FROM Project_Task__c WHERE Requirement__r.Lead__c IN :convleadids]) {
            if (!tasksmap.containsKey(task.Requirement__r.Lead__c)) {
                tasksmap.put(task.Requirement__r.Lead__c, new List<Project_Task__c>());
            }
            tasksmap.get(task.Requirement__r.Lead__c).add(task);
        }

        system.debug('********leadchildrec**********' + leadchildrec);
        ContactRolesUtility.setupContactRoles();

        for (Lead ld : leadchildrec) {
            string recordtype = '';
            if(recTypeMap != Null && recTypeMap.keyset().size() > 0){
                recordtype = recTypeMap.get(ld.RecordtypeId).getDeveloperName();
                System.debug('**********Recordtype:'+ recordtype );
            }

            //create Appication
            Application__c app = createApplication(recordtype, ld);
            if(app != Null) {
                System.debug('****in app****');
                newapps.add(app);
            }

            //create CoApplicant
            if(ld.Is_there_Co_App__c == TRUE) {
                contact cca = createCoApplicant(recordtype, ld);
                if(cca != Null){
                System.debug('****in contact***');
                    newcoapps.add(cca);
                }
            }


            //create Property
            Property__c prop = createProperty(ld);
            if(prop != Null) {
                System.debug('**** in Property ****');
                newprop.add(prop);
            }

            //Create Recorded Information
            Recorded_Information__c recinfo = createRecInfo(ld);
            if(recinfo != Null){
                System.debug('****in recinfo***');
                newrecinfos.add(recinfo);
            }

            if(ld.ConvertedAccountId != Null){
                accids.add(ld.ConvertedAccountId);
            }

            if(ld.ConvertedContactId!= Null){
                appids.add(ld.ConvertedContactId);
            }

            if(ld.ConvertedOpportunityId != Null){
                System.debug('*** oppid ***');
                System.debug('*** ConvertedOpportunityId ***'+ ld.ConvertedOpportunityId);
                oppids.add(ld.ConvertedOpportunityId);
                //List<Success_Factor__c> csf = createSuccessFactors(ld.ConvertedOpportunityId);
                //sflist.addAll(csf);
            }

            if(ld.LASERCA__Personal_Credit_Reports__r != Null){
                system.debug('****PCR***');
                for(LASERCA__Personal_Credit_Report__c pcr : ld.LASERCA__Personal_Credit_Reports__r){
                    system.debug('*******');
                    LASERCA__Personal_Credit_Report__c temppcr = new LASERCA__Personal_Credit_Report__c();
                    temppcr.Id = pcr.Id;
                    temppcr.Opportunity__c = ld.ConvertedOpportunityId;
                    newpcrs.add(temppcr);
                }
            }

            if(ld.Cases__r != Null){
                system.debug('enter case');
                for(Case c : ld.Cases__r){
                    Case tempc = new Case();
                    tempc.Id = c.Id;
                    tempc.Opportunity__c = ld.ConvertedOpportunityId;
                    newcases.add(tempc);
                }
            }

            if(ld.Risk_Factors__r != Null){
                system.debug('****risk factor is not null ***');
                system.debug('*******');
                for(Success_Factor__c sf : ld.Risk_Factors__r){
                    Success_Factor__c tempsf = new Success_Factor__c();
                    tempsf.Id = sf.Id;
                    tempsf.Success_Factor__c = sf.Success_Factor__c;
                    tempsf.Opportunity__c = ld.ConvertedOpportunityId;
                    sfopprtmap.put(sf.Id,ld.ConvertedOpportunity.Recordtype.Name);
                    sflist.add(tempsf);

                }
            }

            system.debug('ld.Document_MetaData__r: '+ld.Document_MetaData__r);
            if(ld.Document_MetaData__r != Null){
                for(Document_MetaData__c dmd : ld.Document_MetaData__r){
                    system.debug('*******');
                    Document_MetaData__c tempdmd = new Document_MetaData__c();
                    tempdmd.Id = dmd.Id;
                    tempdmd.Opportunity__c = ld.ConvertedOpportunityId;
                    newdmds.add(tempdmd);
                }
            }

            if(ld.Requirements__r!= Null){
                system.debug('*******');
                for(Current_Conditions__c cc : ld.Requirements__r){
                    exisreq.add(cc.Id);
                    system.debug('*******');
                    Current_Conditions__c tempcc = new Current_Conditions__c();
                    tempcc.Id = cc.Id;
                    tempcc.Opportunity__c = ld.ConvertedOpportunityId;
                    newccs.add(tempcc);
                }
            }
            if (tasksmap.containsKey(ld.Id)) {
                for (Project_Task__c task : tasksmap.get(ld.Id)) {
                    task.Opportunity__c = ld.ConvertedOpportunityId;
                    newtasks.add(task);
                }
            }

            if(ld.dsfs__DocuSign_Status__r != Null){
                system.debug('*******');
                for(dsfs__DocuSign_Status__c ds : ld.dsfs__DocuSign_Status__r){
                    system.debug('*******');
                    dsfs__DocuSign_Status__c tempds = new dsfs__DocuSign_Status__c();
                    tempds.Id = ds.Id;
                    tempds.dsfs__Opportunity__c = ld.ConvertedOpportunityId;
                    newdocs.add(tempds);
                }
            }

            ContactRolesUtility.createContactRoles(ld);
            }

        ContactRolesUtility.insertContactRoles();



        if(sflist.size() > 0){
            System.debug('*** inserting sf'+sflist);
            update sflist;
        }

        if(newcases.size() > 0){
            system.debug('newcases: '+newcases);
            update newcases;
        }

        if(newpcrs.size() > 0){
            system.debug('*******');
            conversionProcess = true;
            update newpcrs;
            conversionProcess = false;
        }

        if(newdocs.size() > 0){
            system.debug('*******');
            update newdocs;
        }

        if(newccs.size() > 0 && !createdRequirements){
            system.debug('*******');
            upsert newccs;
            createdRequirements = true;

            List<Document_MetaData__c> newdmdlist = new List<Document_MetaData__c>();
            for(Current_Conditions__c req : newccs){
                system.debug('********req********'+req);
                Document_MetaData__c dmd = new Document_MetaData__c();
                dmd.Opportunity__c = req.Opportunity__c;
                dmd.Requirement__c = req.Id;
                if(!exisreq.contains(req.Id)){
                    if(req.Requirement__c == 'Home Inspection') {
                        dmd.Document_Type__c  = 'Home Inspection';
                        newdmdlist.add(dmd);
                    }
                    else if(req.Requirement__c == 'Title Report') {
                        dmd.Document_Type__c  = 'Title Report';
                        newdmdlist.add(dmd);
                    }
                }
            }
            if(newdmdlist.size() > 0){
                insert newdmdlist;
                system.debug('********newdmdlist********'+newdmdlist);
            }
        }

        if (newtasks.size() > 0) {
            update newtasks;
        }

        if(newdmds.size() > 0){
            system.debug('*******');
            update newdmds;
        }

        if(newapps.size() > 0){
            System.debug('***insert app***');
            system.debug('****newapps******'+newapps);
            insert newapps;
        }

        if(newprop.size() > 0){
            System.debug('***insert prop***');
            system.debug('****newprop******'+newprop);
            insert newprop;
        }


        if(newcoapps.size() > 0){
            System.debug('***insert contact***');
            system.debug('*****newcoapps*****'+newcoapps);
            insert newcoapps;
        }




        if((appids.size() > 0 || newcoapps.size() > 0) && oppids.size() > 0 && accids.size() > 0){
            System.debug('**** inside acclist loop ****');

            for(Contact c : newcoapps){
                coappids.add(c.Id);
            }
            system.debug('****coappids*****'+coappids);
            Set<Id> conids = new Set<Id>();
            conids.addAll(appids);
            conids.addAll(coappids);

            acclist = [select Id,(select Id, FirstName, LastName from Contacts where Id =: conids),
                                (select Converted_Lead_RT__c, RecordTypeId, Applicant__c, Co_Applicant__c from Opportunities where id =: oppids),
                                (select id,Opportunity__c from Applications__r)
                                from Account where Id =: accids];
           List<LASERCA__Personal_Credit_Report__c> pcrlist = [select Opportunity__c, (select Id from LASERCA__Trade_Accounts__r)
                                                               from LASERCA__Personal_Credit_Report__c where Opportunity__c =: oppids];
           if(pcrlist.size() > 0){
               for(LASERCA__Personal_Credit_Report__c pcr : pcrlist){
                   if(pcr.LASERCA__Trade_Accounts__r != Null && pcr.LASERCA__Trade_Accounts__r.size()>0){
                       oppaccidmap.put(pcr.Opportunity__c,pcr.LASERCA__Trade_Accounts__r[0].Id);
                   }
               }
           }
        }

        if(newrecinfos.size() > 0){
            System.debug('*****'+ newrecinfos);
            if(acclist.size() > 0){
                system.debug('**** updating recorded info ****');
                for(Recorded_Information__c nrf : newrecinfos){
                    for(Account acc : acclist){
                        System.debug('**** lookup *****');
                        if(acc.Applications__r != Null){
                            System.debug('***** inside****');
                            for(Application__c app : acc.Applications__r){
                                if(app.Opportunity__c != Null && nrf.Opportunity2__c != Null && app.Opportunity__c == nrf.Opportunity2__c){
                                    nrf.Application__c = app.Id;
                                }
                            }
                        }
                        if(acc.Contacts!= Null){
                            for(Contact con : acc.Contacts){
                                System.debug('*****con*****'+con);
                                System.debug('*****nrf*****'+nrf);
                                System.debug('***** co-app*****');
                                if(coappids.contains(con.Id)){
                                    nrf.Co_Applicant__c         =con.Id;
                                    nrf.Co_Applicant_Name__c    =con.FirstName+' '+con.LastName;
                                }


                            }
                            //nrf.Co_Applicant_Name__c = newcoapps[1].FirstName + ' '+newcoapps[1].LastName;

                        }
                    }
                    if(oppaccidmap.keyset().contains(nrf.Opportunity2__c)){
                        //nrf.Trade_Accounts__c = oppaccidmap.get(nrf.Opportunity2__c);
                    }
                }
            }
            insert newrecinfos;
        }

        // update opportunities with applicant and co-applicant
        if(acclist.size() > 0){
            System.debug('**** before ****updatechildopp method');
            updateApplicantstoOpportunity(appids,coappids,newcoapps,acclist,leadchildrec,newrecinfos);
            System.debug('**** after ****updatechildopp method');
        }

        //update TradeAccounts
        system.debug('****before Trade Accounts***');
        List<LASERCA__Trade_Accounts__c> newtas = new List<LASERCA__Trade_Accounts__c>();
        List<LASERCA__Personal_Credit_Report__c> trdaccs = [select Id,Opportunity__c, (select Id,Credit_Loan_Type_pick__c,LASERCA__Credit_Loan_Type__c,To_Be_Paid_Off__c,Paid_off_on_Lead__c,LASERCA__Account_Balance__c from LASERCA__Trade_Accounts__r)
                  from LASERCA__Personal_Credit_Report__c where LASERCA__Lead__c =: convleadids ORDER BY LastModifiedDate desc LIMIT 1];
        for(LASERCA__Personal_Credit_Report__c pcr : trdaccs){
            if(pcr.LASERCA__Trade_Accounts__r != Null){
                system.debug('****Trade Accounts***');
                for(LASERCA__Trade_Accounts__c ta : pcr.LASERCA__Trade_Accounts__r){
                    system.debug('*******');
                    LASERCA__Trade_Accounts__c tempta = new LASERCA__Trade_Accounts__c();
                    tempta.Id = ta.Id;
                    //tempta.Opportunity__c = pcr.Opportunity__c;

                    //Modified on 5/9/2019 by Carolina Veliz- Cloudforia
                    //Jira ticket: https://unison-technology.atlassian.net/browse/BUS-155109280
                    if (string.isEmpty(tempta.Credit_Loan_Type_pick__c))
                        tempta.Credit_Loan_Type_pick__c = ta.LASERCA__Credit_Loan_Type__c;

                    // Brad: If the Trade Account has been marked to be paid off AND
                    // the trade account is not a Subject-Property Lien
                    // set the Amount to pay off to the account balance
                    //Boolean is_subject_lien = TradeAccountTriggerHandler.is_subject_lien(tempta.Credit_Loan_Type_pick__c);
                    if (ta.To_Be_Paid_Off__c && /*!is_subject_lien && */tempta.Amount_To_Pay_Off2__c == null) {
                        tempta.Amount_To_Pay_Off2__c = ta.LASERCA__Account_Balance__c;
                    } else { // ADDED - not in Dev, tempaorary solution.
                            // Ideally, this should be equal to whatever the PS decides.
                        tempta.Target_Pct_Value_Of_Home__c = 0;
                        tempta.Amount_To_Pay_Off2__c = 0;
                    }
                    if (tempta.Target_Pct_Value_Of_Home__c == null)
                        tempta.Target_Pct_Value_Of_Home__c = 0;

                    tempta.Paid_off_on_Lead__c = ta.To_Be_Paid_Off__c;


                    system.debug(tempta);

                    newtas.add(tempta);
                }

            }
        }

        if(newtas.size() > 0){
            update newtas;
        }


    }

    public static Current_Conditions__c createRequirements(Requirement__mdt mrMDT) {
        System.debug('*** inside create req method ****');
        Current_Conditions__c req = new Current_Conditions__c();
        req.Requirement__c = mrMDT.Requirement_Type__c;
        req.Code__c = mrMDT.Code__c;
        req.Category__c = mrMDT.Category__c;
        req.Type__c       = mrMDT.Type__c;

        req.Applicant_Type__c = mrMDT.Applicant_Type__c;
        return req;
    }


    // Function to map Lead fields to new Application Object at Lead Conversion
    // Brad: Reviewed field mapping: 2019-05-23
    public static Application__c createApplication(string recordtype, Lead l) {

        Map<String, Schema.SObjectField> fieldsDesc = Schema.SObjectType.Application__c.fields.getMap();

        System.debug('****recordtype***');
        System.debug('***creating app****');
        Application__c app = new Application__c();

        for (Lead_Conversion_Process_Field__mdt field : fields) {
            if (field.Lead_Field__c != null && field.Lead_Field__c.trim() != '' && field.Application_Field__c != null && field.Application_Field__c.trim() != '') {
                CopyField(l, field.Lead_Field__c, app, field.Application_Field__c);
            }
            if (field.Default_Value__c != null && field.Default_Value__c.trim() != '' && field.Application_Field__c != null && field.Application_Field__c.trim() != '') {
                SetFieldDefault(field.Default_Value__c, app, field.Application_Field__c, fieldsDesc.get(field.Application_Field__c).getDescribe().getType());
            }
        }

        if (l.Applicant_Birth_Date_Free_Response__c != Null && l.Applicant_Birth_Date_Free_Response__c != '') {
            app.Birthdate__c = date.parse(l.Applicant_Birth_Date_Free_Response__c);
        }

        return app;
    }

    public static Contact createCoApplicant(string recordtype, Lead convertedLeadInfo) {
        Schema.DescribeSObjectResult conDesc = Schema.SObjectType.Contact;
        Map<String,Schema.RecordTypeInfo> ContRTMapByName = conDesc.getRecordTypeInfosByName();

        Map<String, Schema.SObjectField> fieldsDesc = conDesc.fields.getMap();

        System.debug('***creating coapp****');
        Contact coAppContact = new Contact();
        if(ContRTMapByName.get(HOUSEHOLD_RT_LABEL) != NULL){
            coAppContact.RecordTypeId = ContRTMapByName.get(HOUSEHOLD_RT_LABEL).getRecordTypeId();
        }
        coAppContact.Opp_Lookup_Helper__c = 'coapplicant1';

        for (Lead_Conversion_Process_Field__mdt field : fields) {
            if (field.Lead_Field__c != null && field.Lead_Field__c.trim() != '' && field.CoApplicant_Field__c != null && field.CoApplicant_Field__c.trim() != '') {
                CopyField(convertedLeadInfo, field.Lead_Field__c, coAppContact, field.CoApplicant_Field__c);
            }
            if (field.Default_Value__c != null && field.Default_Value__c.trim() != '' && field.CoApplicant_Field__c != null && field.CoApplicant_Field__c.trim() != '') {
                SetFieldDefault(field.Default_Value__c, coAppContact, field.CoApplicant_Field__c, fieldsDesc.get(field.CoApplicant_Field__c).getDescribe().getType());
            }
        }

        return coAppContact;
    }

    // Function to map Lead fields to new Property Object at Lead Conversion
    // Brad: Reviewed and edited field mapping: 2019-05-23
    public static Property__c createProperty(Lead l) {
        System.debug('*** inside create property');

        Map<String, Schema.SObjectField> fieldsDesc = Schema.SObjectType.Property__c.fields.getMap();

        Property__c property = new Property__c();

        for (Lead_Conversion_Process_Field__mdt field : fields) {
            if (field.Lead_Field__c != null && field.Lead_Field__c.trim() != '' && field.Property_Field__c != null && field.Property_Field__c.trim() != '') {
                CopyField(l, field.Lead_Field__c, property, field.Property_Field__c);
            }
            if (field.Default_Value__c != null && field.Default_Value__c.trim() != '' && field.Property_Field__c != null && field.Property_Field__c.trim() != '') {
                SetFieldDefault(field.Default_Value__c, property, field.Property_Field__c, fieldsDesc.get(field.Property_Field__c).getDescribe().getType());
            }
        }

        // If indicated as investment property
        if (l.Occupancy_Statement_Dropdown__c == 'Investment Property') {
            property.Is_NOO__c = true;
        }

        return property;
    }



     public static Recorded_Information__c createRecInfo(Lead l) {
        System.debug('*** inside recinfo*****');

        Map<String, Schema.SObjectField> fieldsDesc = Schema.SObjectType.Recorded_Information__c.fields.getMap();

        Recorded_Information__c recinfo = new Recorded_Information__c();
        if (l.ConvertedOpportunityId != Null && l.ConvertedContact.Name != Null) {

            for (Lead_Conversion_Process_Field__mdt field : fields) {
                if (field.Lead_Field__c != null && field.Lead_Field__c.trim() != '' && field.Recorded_Information_Field__c != null && field.Recorded_Information_Field__c.trim() != '') {
                    CopyField(l, field.Lead_Field__c, recinfo, field.Recorded_Information_Field__c);
                }
                if (field.Default_Value__c != null && field.Default_Value__c.trim() != '' && field.Recorded_Information_Field__c != null && field.Recorded_Information_Field__c.trim() != '') {
                    SetFieldDefault(field.Default_Value__c, recinfo, field.Recorded_Information_Field__c, fieldsDesc.get(field.Recorded_Information_Field__c).getDescribe().getType());
                }
            }
        }
        return recinfo;
    }
    
    private static void CopyField(sObject fromObj, string fromField, sObject toObj, string toField) {
        object valueToCopy = null;
        while (fromObj != null && fromField.contains('.')) { // "From Field" can be a reference, like ConvertedOpportunity.Recordtype.Name, we need to dig into it
            List<String> aux = fromField.split('\\.', 2);
            fromField = aux[1];
            fromObj = fromObj.getSObject(aux[0]);
        }
        if (fromObj != null && fromField.trim() != '') {
            valueToCopy = fromObj.get(fromField);
        }
        if (valueToCopy != null) {
            List<String> fields = toField.split(';'); // "To field" can actually be more than one field, separated by ";", like "Opportunity__c;Opportunity2__c"
            for (String field : fields) {
                toObj.put(field, valueToCopy);
            }
        }
    }

    private static void SetFieldDefault(string defaultVal, sObject toObj, string toField, Schema.DisplayType fdt) {
        object valueToCopy = null;
        if (fdt == Schema.DisplayType.BOOLEAN) {
            valueToCopy = Boolean.valueOf(defaultVal);
        }
        if (fdt == Schema.DisplayType.CURRENCY) {
            valueToCopy = Decimal.valueOf(defaultVal);
        }
        if (fdt == Schema.DisplayType.INTEGER) {
            valueToCopy = Integer.valueOf(defaultVal);
        }
        if (fdt == Schema.DisplayType.PERCENT) {
            valueToCopy = Decimal.valueOf(defaultVal);
        }
        if (fdt == Schema.DisplayType.DOUBLE) {
            valueToCopy = Decimal.valueOf(defaultVal);
        }
        if (fdt == Schema.DisplayType.DATE) {
            valueToCopy = Date.valueOf(defaultVal);
        }
        if (fdt == Schema.DisplayType.DATETIME) {
            valueToCopy = DateTime.valueOf(defaultVal);
        }
        if (valueToCopy == null) {
            valueToCopy = defaultVal;
        }
        
        if (valueToCopy != null) {
            List<String> fields = toField.split(';'); // "To field" can actually be more than one field, separated by ";", like "Opportunity__c;Opportunity2__c"
            for (String field : fields) {
                toObj.put(field, valueToCopy);
            }
        }
    }

    public static void updateApplicantstoOpportunity(Set<Id> appids,Set<Id> coappids,List<Contact> newcoapps,List<Account> acclist,List<Lead> ldlist, List<Recorded_Information__c> recinfolist){
        System.debug('***inside updatechildopportunity****');
        system.debug('****appids****'+appids);
        system.debug('***newcoapps*****'+newcoapps);
        system.debug('***coappids*****'+coappids);
        system.debug('***acclist****'+acclist);

        Schema.DescribeSObjectResult oppDesc = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRTMapByName = oppDesc.getRecordTypeInfosByName();

        system.debug('****acclist****'+acclist);
        if(acclist != Null && acclist.size()>0){
            List<Opportunity> updopps = new List<Opportunity>();
            for(Account acc : acclist){
                List<Contact> conts = acc.Contacts;
                if(acc.Opportunities != Null && acc.Opportunities.size() > 0){
                    System.debug('***lookup to contact in opp**');
                    for(Opportunity opp : acc.Opportunities){
                        System.debug('**** checking record type****');
                        System.debug('*** lead recordtype: ****'+ opp.Converted_Lead_RT__c);
                        Opportunity o = new Opportunity();
                        o.Id = opp.Id;
                        o.RecordTypeId =  oppRTMapByName.get(opp.Converted_Lead_RT__c).getRecordTypeId();

                        for(Recorded_Information__c recinfo: recinfolist) {
                            if(recinfo.Id != Null) {
                                o.Recorded_Information__c = recinfo.Id;
                            }
                        }

                        for(Lead l : ldlist){
                            System.debug('******** mapping income fields to opp1 ********');
                            if(l.Income_Monthly_Total__c == Null){
                                o.Income_App1__c = 0;
                            }else{
                                o.Income_App1__c = l.Income_Monthly_Total__c;
                            }
                            System.debug('******** mapping income fields to opp2 ********');

                            if(l.Personal_Credit_Report__c != null) {
                                Decimal FICO = 0.0;
                                if(l.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c != null && l.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c > 300){
                                    FICO = l.Personal_Credit_Report__r.LASERCA__Credit_Score_Median__c;
                                }
                                if(l.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c != null && l.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c > 300){
                                    FICO = Math.Min(FICO, l.Personal_Credit_Report__r.LASERCA__Co_Applicant_Credit_Score_Median__c);
                                }
                                o.FICO__c = Math.Round(FICO * 100) / 100;
                            }

                            System.debug('******** mapping income fields to opp3 ********');
                            if(l.Income_Monthy_Total_Co__c == Null){
                                o.Income_Co_App1__c = 0;
                            }else{
                                o.Income_Co_App1__c = l.Income_Monthy_Total_Co__c;
                            }
                            System.debug('******** mapping income fields to opp ********');
                            if(l.Additional_Income_From_Other_Applicants__c == Null){
                                o.Additional_Applicant_Income__c = 0;
                            }else{
                                o.Additional_Applicant_Income__c = l.Additional_Income_From_Other_Applicants__c;
                            }
                            System.debug('******** mapping income fields to opp4 ********');
                            o.Assets_Bank_Acct__c = l.Assets_Bank_Acct__c != Null?l.Assets_Bank_Acct__c:0;
                            o.Assets_Brokerage_Acct__c = l.Assets_Brokerage_Acct__c != Null?l.Assets_Brokerage_Acct__c:0;
                            o.Assets_Other__c = l.Assets_Other__c != Null?l.Assets_Other__c:0;
                            o.Assets_Other__c = l.Assets_Other_Real_Estate__c != Null?l.Assets_Other_Real_Estate__c:0;
                            o.Assets_Retirement_Acct__c = l.Assets_Retirement_Acct__c != Null?l.Assets_Retirement_Acct__c:0;

                            if(l.Maximum_Authorized_DTI__c != Null) {
                                o.Maximum_Authorized_DTI__c = l.Maximum_Authorized_DTI__c;
                            }
                            if(l.Maximum_Authorized_LTV__c != Null) {
                                o.Maximum_Authorized_LTV__c = l.Maximum_Authorized_LTV__c;
                            }


                            if(l.ConvertedOpportunityId == o.Id){
                                if(l.Assets_Bank_Acct__c != Null || l.Assets_Brokerage_Acct__c != Null || l.Assets_Other__c != Null
                                    || l.Assets_Other_Real_Estate__c != Null || l.Assets_Retirement_Acct__c != Null) {
                                    Decimal bnkacc = l.Assets_Bank_Acct__c != Null?l.Assets_Bank_Acct__c:0;
                                    Decimal brokacc = l.Assets_Brokerage_Acct__c != Null?l.Assets_Brokerage_Acct__c:0;
                                    Decimal assoth = l.Assets_Other__c != Null?l.Assets_Other__c:0;
                                    Decimal assre = l.Assets_Other_Real_Estate__c != Null?l.Assets_Other_Real_Estate__c:0;
                                    Decimal assreacc = l.Assets_Retirement_Acct__c != Null?l.Assets_Retirement_Acct__c:0;


                                }

                            }

                            // Populate Post Close Second Mortgage with Pre Close Second Mortgage if its not null
                            // https://unison-technology.atlassian.net/browse/BUS-155109590
                            if(l.Payment_Monthly_Second_Mortgage__c != null && l.Payment_Monthly_Second_Mortgage__c > 0) {
                                o.Post_Close_Monthly_Second_Mortgage2__c = l.Payment_Monthly_Second_Mortgage__c;
                            }
                        }
                        if(conts != Null && conts.size() >0){
                            System.debug('**** applicant & co-applicant *****');
                            for(Contact c : conts){
                                System.debug('*** looping contacts *****');
                                if(appids.contains(c.Id)){
                                    System.debug('**** applicant exists****');
                                    o.Applicant__c = c.Id;
                                }else if(coappids.contains(c.Id)){
                                    System.debug('**** co-applicant exists****');
                                    o.Co_Applicant__c = c.Id;
                                }
                            }
                        }
                        updopps.add(o);
                    }
                }
            }

            update updopps;

        }
    }
}