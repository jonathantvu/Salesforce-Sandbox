@isTest
private class RequirementTriggerTest {
        @testSetup
    public static void testSetup(){
        EOS_Project_Tasks__mdt eOSProjectTasks = new EOS_Project_Tasks__mdt();
        Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(JSON.serializePretty(eOSProjectTasks));
        fields.put(EOS_Project_Tasks__mdt.DeveloperName.getDescribe().getName(),'test group');
        eOSProjectTasks=(EOS_Project_Tasks__mdt) JSON.deserialize(JSON.serialize(fields), EOS_Project_Tasks__mdt.class);
    }
    
    @istest
    private static void manualReqTest1() {
        Test.setMock(HttpCalloutMock.class, new HttpMockTest());

        List<Current_Conditions__c>   reqlist  = new List<Current_Conditions__c>();
        Account acc          = new Account();
            acc.Name         = 'test acc';
        insert acc;    
        
        Schema.DescribeSObjectResult oppDescribe = Opportunity.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> oppRTMap = oppDescribe.getRecordTypeInfosByName();
                        
        Opportunity opp      = new Opportunity();
            opp.AccountId      = acc.Id;
            opp.Name         = 'test opp';
            opp.StageName    = 'Investment Due Diligence';
            opp.recordTypeId = oppRTMap.get('HomeOwner').GetRecordTypeId();
            opp.CloseDate    = System.today();
            opp.Estimated_Funding_Amount__c = 2;
            opp.Pricing_Ratio__c = 2;
            opp.Final_OAV_Calculation__c = 2;
            opp.IA_OAV_Override__c =2;
        insert opp;            
        
        List<Success_Factor__c>  sflist = new List<Success_Factor__c>(); 
        Success_Factor__c sf1     = new Success_Factor__c();
            sf1.Opportunity__c     = opp.Id;
            sf1.Success_Factor__c  = 'LTV';
            sf1.Status__c  = 'In Progress';
            sf1.Program__c = 'HO';
            sflist.add(sf1);
        
        Success_Factor__c sf2     = new Success_Factor__c();
            sf2.Opportunity__c     = opp.Id;
            sf2.Success_Factor__c  = 'DTI';
            sf2.Status__c  = 'In Progress';
            sf2.Program__c = 'HO';
        sflist.add(sf2);
        
        Success_Factor__c sf3     = new Success_Factor__c();
            sf3.Opportunity__c     = opp.Id;
            sf3.Success_Factor__c  = 'Credit';
            sf3.Status__c  = 'In Progress';
            sf3.Program__c = 'HO';
        sflist.add(sf3);       
        
        Success_Factor__c sf4     = new Success_Factor__c();
            sf4.Opportunity__c     = opp.Id;
            sf4.Success_Factor__c  = 'OAV';
            sf4.Status__c  = 'In Progress';
            sf4.Program__c = 'HO';
        sflist.add(sf4);
       
        Success_Factor__c sf5     = new Success_Factor__c();
            sf5.Opportunity__c     = opp.Id;
            sf5.Success_Factor__c  = 'Property Ownership';
            sf5.Status__c  = 'In Progress';
            sf5.Program__c = 'HO';
        sflist.add(sf5); 
        
        
        if(sflist.size() > 0) {
            insert sflist;
        }
        
        
        Current_Conditions__c  req1 = new Current_Conditions__c();
            req1.Requirement__c     = 'Credit Supplement';   
            req1.Success_Factor__c  = sf3.Id; 
            req1.Opportunity__c     = opp.id;
            req1.Code__c            = 'R1022';
            req1.Category__c        = 'Credit';
            req1.Internal_vs_External__c = 'Internal';
        reqlist.add(req1);
        
        Current_Conditions__c  req2 = new Current_Conditions__c();
            req2.Requirement__c     = 'Letter of Explanation - Credit - Credit';   
            req2.Success_Factor__c  = sf3.Id; 
            req2.Opportunity__c     = opp.id;
            req2.Code__c            = 'R1044';
            req2.Category__c        = 'Credit';
            req2.Internal_vs_External__c = 'Internal';
        reqlist.add(req2);
        
        Current_Conditions__c  req3 = new Current_Conditions__c();
            req3.Requirement__c     = 'Other - Credit - Credit';   
            req3.Success_Factor__c  = sf3.Id; 
            req3.Opportunity__c     = opp.id;
            req3.Code__c            = 'R1074';
            req3.Category__c        = 'Credit';
            req3.Internal_vs_External__c = 'Internal';
        reqlist.add(req3);
        
        Current_Conditions__c  req37 = new Current_Conditions__c();
            req37.Requirement__c     = 'Need Updated Credit Supplement';   
            req37.Success_Factor__c  = sf3.Id; 
            req37.Opportunity__c     = opp.id;
            req37.Code__c            = 'R1022';
            req37.Category__c        = 'Credit';
            req37.Internal_vs_External__c = 'Internal';
        reqlist.add(req37);
        
        Current_Conditions__c  req4 = new Current_Conditions__c();
            req4.Requirement__c     = 'Rental Income';   
            req4.Success_Factor__c  = sf2.Id; 
            req4.Opportunity__c     = opp.id;
            req4.Code__c            = 'R1099';
            req4.Category__c        = 'Credit';
            req4.Internal_vs_External__c = 'Internal';
        reqlist.add(req4); 
        
        
        Current_Conditions__c  req5 = new Current_Conditions__c();
            req5.Requirement__c     = 'Letter of Explanation - DTI - Income';   
            req5.Success_Factor__c  = sf2.Id; 
            req5.Opportunity__c     = opp.id;
            req5.Code__c            = 'R1044';
            req5.Category__c        = 'Credit';
            req5.Internal_vs_External__c = 'Internal';
        reqlist.add(req5);
        
        
        Current_Conditions__c  req6 = new Current_Conditions__c();
            req6.Requirement__c     = 'Other - DTI - Income';   
            req6.Success_Factor__c  = sf2.Id; 
            req6.Opportunity__c     = opp.id;
            req6.Code__c            = 'R1076';
            req6.Category__c        = 'Credit';
            req6.Internal_vs_External__c = 'Internal';
        reqlist.add(req6); 
        
        
        Current_Conditions__c  req7 = new Current_Conditions__c();
            req7.Requirement__c     = 'Brokerage Statement';   
            req7.Success_Factor__c  = sf2.Id; 
            req7.Opportunity__c     = opp.id;
            req7.Code__c            = 'R1014';
            req7.Category__c        = 'Credit';
            req7.Internal_vs_External__c = 'Internal';
        reqlist.add(req7); 
        
        
        Current_Conditions__c  req8 = new Current_Conditions__c();
            req8.Requirement__c     = 'Retirement Statement';   
            req8.Success_Factor__c  = sf2.Id; 
            req8.Opportunity__c     = opp.id;
            req8.Code__c            = 'R1101';
            req8.Category__c        = 'Credit';
            req8.Internal_vs_External__c = 'Internal';
        reqlist.add(req8); 
        
        
        Current_Conditions__c  req9 = new Current_Conditions__c();
            req9.Requirement__c     = 'Other - DTI - Assets';   
            req9.Success_Factor__c  = sf2.Id; 
            req9.Opportunity__c     = opp.id;
            req9.Code__c            = 'R1075';
            req9.Category__c        = 'Credit';
            req9.Internal_vs_External__c = 'Internal';
        reqlist.add(req9); 
        
      
        Current_Conditions__c  req10 = new Current_Conditions__c();
            req10.Requirement__c     = 'Client must pay off outstanding past due liability';   
            req10.Success_Factor__c  = sf2.Id; 
                    req10.Opportunity__c     = opp.id;
            req10.Code__c            = 'R1046';
            req10.Category__c        = 'Credit';
            req10.Internal_vs_External__c = 'Internal';
        reqlist.add(req10);
        
        
        Current_Conditions__c  req11 = new Current_Conditions__c();
            req11.Requirement__c     = 'Other - DTI - Debt Reduction';   
            req11.Success_Factor__c  = sf2.Id; 
                    req11.Opportunity__c     = opp.id;
            req11.Code__c            = 'R1046';
            req11.Category__c        = 'Credit';
            req11.Internal_vs_External__c = 'Internal';
        reqlist.add(req11);
        
        Current_Conditions__c  req38 = new Current_Conditions__c();
            req38.Requirement__c     = 'Need Updated Paystub';   
            req38.Success_Factor__c  = sf2.Id; 
                    req38.Opportunity__c     = opp.id;
            req38.Code__c            = 'R1062';
            req38.Category__c        = 'Credit';
            req38.Internal_vs_External__c = 'Internal';
        reqlist.add(req38);
        
        Current_Conditions__c  req39 = new Current_Conditions__c();
            req39.Requirement__c     = 'Need Updated W2';   
            req39.Success_Factor__c  = sf2.Id; 
                    req39.Opportunity__c     = opp.id;
            req39.Code__c            = 'R1071';
            req39.Category__c        = 'Credit';
            req39.Internal_vs_External__c = 'Internal';
        reqlist.add(req39);
        
        Current_Conditions__c  req40 = new Current_Conditions__c();
            req40.Requirement__c     = 'Need Updated Tax Return';   
            req40.Success_Factor__c  = sf2.Id; 
                    req40.Opportunity__c     = opp.id;
            req40.Code__c            = 'R1054';
            req40.Category__c        = 'Credit';
            req40.Internal_vs_External__c = 'Internal';
        reqlist.add(req40);
               
        Current_Conditions__c  req41 = new Current_Conditions__c();
            req41.Requirement__c     = 'Need Updated SS Award Letter';   
            req41.Success_Factor__c  = sf2.Id; 
                    req41.Opportunity__c     = opp.id;
            req41.Code__c            = 'R1070';
            req41.Category__c        = 'Credit';
            req41.Internal_vs_External__c = 'Internal';
        reqlist.add(req41);
        
        Current_Conditions__c  req42 = new Current_Conditions__c();
            req42.Requirement__c     = 'Need Updated Pension Award Letter';   
            req42.Success_Factor__c  = sf2.Id; 
                    req42.Opportunity__c     = opp.id;
            req42.Code__c            = 'R1063';
            req42.Category__c        = 'Credit';
            req42.Internal_vs_External__c = 'Internal';
        reqlist.add(req42);
        
        Current_Conditions__c  req43 = new Current_Conditions__c();
            req43.Requirement__c     = 'Need Updated Rental Income';   
            req43.Success_Factor__c  = sf2.Id; 
                    req43.Opportunity__c     = opp.id;
            req43.Code__c            = 'R1068';
            req43.Category__c        = 'Credit';
            req43.Internal_vs_External__c = 'Internal';
        reqlist.add(req43);
        
        Current_Conditions__c  req44 = new Current_Conditions__c();
            req44.Requirement__c     = 'Need Updated Bank Statement';   
            req44.Success_Factor__c  = sf2.Id; 
                    req44.Opportunity__c     = opp.id;
            req44.Code__c            = 'R1052';
            req44.Category__c        = 'Credit';
            req44.Internal_vs_External__c = 'Internal';
        reqlist.add(req44);
        
        Current_Conditions__c  req45 = new Current_Conditions__c();
            req45.Requirement__c     = 'Need Updated Brokerage Statement';   
            req45.Success_Factor__c  = sf2.Id; 
                    req45.Opportunity__c     = opp.id;
            req45.Code__c            = 'R1053';
            req45.Category__c        = 'Credit';
            req45.Internal_vs_External__c = 'Internal';
        reqlist.add(req45);
        
        Current_Conditions__c  req46 = new Current_Conditions__c();
            req46.Requirement__c     = 'Need Updated Retirement Statement';   
            req46.Success_Factor__c  = sf2.Id; 
                    req46.Opportunity__c     = opp.id;
            req46.Code__c            = 'R1069';
            req46.Category__c        = 'Credit';
            req46.Internal_vs_External__c = 'Internal';
        reqlist.add(req46);
        
        Current_Conditions__c  req47 = new Current_Conditions__c();
            req47.Requirement__c     = 'Need Updated Business Tax Returns';   
            req47.Success_Factor__c  = sf2.Id; 
                    req47.Opportunity__c     = opp.id;
            req47.Code__c            = 'R1054';
            req47.Category__c        = 'Credit';
            req47.Internal_vs_External__c = 'Internal';
        reqlist.add(req47); 
        
        Current_Conditions__c  req12 = new Current_Conditions__c();
            req12.Requirement__c     = 'Letter of Explanation - LTV - Mortgage';   
            req12.Success_Factor__c  = sf1.Id; 
                    req12.Opportunity__c     = opp.id;
            req12.Code__c            = 'R1044';
            req12.Category__c        = 'Credit';
            req12.Internal_vs_External__c = 'Internal';
        reqlist.add(req12);
        
        Current_Conditions__c  req13 = new Current_Conditions__c();
            req13.Requirement__c     = 'Other - LTV - Mortgage';   
            req13.Success_Factor__c  = sf1.Id; 
                    req13.Opportunity__c     = opp.id;
            req13.Code__c            = 'R1078';
            req13.Category__c        = 'Credit';
            req13.Internal_vs_External__c = 'Internal';
        reqlist.add(req13);
        
        Current_Conditions__c  req48 = new Current_Conditions__c();
            req48.Requirement__c     = 'Need Updated Mortgage Statement';   
            req48.Success_Factor__c  = sf1.Id; 
                    req48.Opportunity__c     = opp.id;
            req48.Code__c            = 'R1061';
            req48.Category__c        = 'Credit';
            req48.Internal_vs_External__c = 'Internal';
        reqlist.add(req48); 
        
        Current_Conditions__c  req14 = new Current_Conditions__c();
            req14.Requirement__c     = 'One or more title holders must be removed';   
            req14.Success_Factor__c  = sf5.Id; 
                    req14.Opportunity__c     = opp.id;
            req14.Code__c            = 'R1073';
            req14.Category__c        = 'Credit';
            req14.Internal_vs_External__c = 'Internal';
        reqlist.add(req14); 
        
        
        Current_Conditions__c  req15 = new Current_Conditions__c();
            req15.Requirement__c     = 'Partner must pay delinquent property taxes';   
            req15.Success_Factor__c  = sf5.Id; 
                    req15.Opportunity__c     = opp.id;
            req15.Code__c            = 'R1046';
            req15.Category__c        = 'Credit';
            req15.Internal_vs_External__c = 'Internal';
        reqlist.add(req15);

        
        Current_Conditions__c  req16 = new Current_Conditions__c();
            req16.Requirement__c     = 'Must pay/remove outstanding judgments';   
            req16.Success_Factor__c  = sf5.Id; 
                    req16.Opportunity__c     = opp.id;
            req16.Code__c            = 'R1046';
            req16.Category__c        = 'Credit';
            req16.Internal_vs_External__c = 'Internal';
        reqlist.add(req16); 
        
        
        Current_Conditions__c  req17 = new Current_Conditions__c();
            req17.Requirement__c     = 'Must remove closed out lien';   
            req17.Success_Factor__c  = sf5.Id; 
                    req17.Opportunity__c     = opp.id;
            req17.Code__c            = 'R1048';
            req17.Category__c        = 'Credit';
            req17.Internal_vs_External__c = 'Internal';
        reqlist.add(req17);
        
        Current_Conditions__c  req18 = new Current_Conditions__c();
            req18.Requirement__c     = 'Must obtain flood insurance on property';   
            req18.Success_Factor__c  = sf5.Id; 
                    req18.Opportunity__c     = opp.id;
            req18.Code__c            = 'R1031';
            req18.Category__c        = 'Credit';
            req18.Internal_vs_External__c = 'Internal';
        reqlist.add(req18); 
        
        
        Current_Conditions__c  req19 = new Current_Conditions__c();
            req19.Requirement__c     = 'Hazard Insurance';   
            req19.Success_Factor__c  = sf5.Id; 
                    req19.Opportunity__c     = opp.id;
            req19.Code__c            = 'R1034';
            req19.Category__c        = 'Credit';
            req19.Internal_vs_External__c = 'Internal';
        reqlist.add(req19);
        
        Current_Conditions__c  req20 = new Current_Conditions__c();
            req20.Requirement__c     = 'Death Certificate';   
            req20.Success_Factor__c  = sf5.Id; 
                    req20.Opportunity__c     = opp.id;
            req20.Code__c            = 'R1023';
            req20.Category__c        = 'Credit';
            req20.Internal_vs_External__c = 'Internal';
        reqlist.add(req20); 
        
        
        Current_Conditions__c  req21 = new Current_Conditions__c();
            req21.Requirement__c     = 'Title holder application';   
            req21.Success_Factor__c  = sf5.Id; 
                    req21.Opportunity__c     = opp.id;
            req21.Code__c            = 'R1046';
            req21.Category__c        = 'Credit';
            req21.Internal_vs_External__c = 'Internal';
        reqlist.add(req21);
        
        Current_Conditions__c  req22 = new Current_Conditions__c();
            req22.Requirement__c     = 'Additional Lien Information';   
            req22.Success_Factor__c  = sf5.Id; 
                    req22.Opportunity__c     = opp.id;
            req22.Code__c            = 'R1046';
            req22.Category__c        = 'Credit';
            req22.Internal_vs_External__c = 'Internal';
        reqlist.add(req22); 
        
        
        Current_Conditions__c  req23 = new Current_Conditions__c();
            req23.Requirement__c     = 'Other - Property Ownership';   
            req23.Success_Factor__c  = sf5.Id; 
                    req23.Opportunity__c     = opp.id;
            req23.Code__c            = 'R1046';
            req23.Category__c        = 'Credit';
            req23.Internal_vs_External__c = 'Internal';
        reqlist.add(req23);
        
        Current_Conditions__c  req24 = new Current_Conditions__c();
            req24.Requirement__c     = 'Flood Insurance';   
            req24.Success_Factor__c  = sf5.Id; 
                    req24.Opportunity__c     = opp.id;
            req24.Code__c            = 'R1046';
            req24.Category__c        = 'Credit';
            req24.Internal_vs_External__c = 'Internal';
        reqlist.add(req24); 
        
        
        Current_Conditions__c  req25 = new Current_Conditions__c();
            req25.Requirement__c     = 'Other - Other';   
            req25.Success_Factor__c  = sf5.Id; 
                    req25.Opportunity__c     = opp.id;
            req25.Code__c            = 'R1046';
            req25.Category__c        = 'Credit';
            req25.Internal_vs_External__c = 'Internal';
        reqlist.add(req25);
        
        Current_Conditions__c  req26 = new Current_Conditions__c();
            req26.Requirement__c     = 'Specific lien must subordinate to our position';   
            req26.Success_Factor__c  = sf5.Id; 
                    req26.Opportunity__c     = opp.id;
            req26.Code__c            = 'R1046';
            req26.Category__c        = 'Credit';
            req26.Internal_vs_External__c = 'Internal';
        reqlist.add(req26);
        
        Current_Conditions__c  req49 = new Current_Conditions__c();
            req49.Requirement__c     = 'Need Updated Reorder Title';   
            req49.Success_Factor__c  = sf5.Id; 
                    req49.Opportunity__c     = opp.id;
            req49.Code__c            = 'R1046';
            req49.Category__c        = 'Credit';
            req49.Internal_vs_External__c = 'Internal';
        reqlist.add(req49);
        
        Current_Conditions__c  req50 = new Current_Conditions__c();
            req50.Requirement__c     = 'Need Updated Hazard Insurance';   
            req50.Success_Factor__c  = sf5.Id; 
                    req50.Opportunity__c     = opp.id;
            req50.Code__c            = 'R1046';
            req50.Category__c        = 'Credit';
            req50.Internal_vs_External__c = 'Internal';
        reqlist.add(req50);
        
        Current_Conditions__c  req51 = new Current_Conditions__c();
            req51.Requirement__c     = 'Need Updated Prequal Letter';   
            req51.Success_Factor__c  = sf5.Id; 
                    req51.Opportunity__c     = opp.id;
            req51.Code__c            = 'R1046';
            req51.Category__c        = 'Credit';
            req51.Internal_vs_External__c = 'Internal';
        reqlist.add(req51);
        
        Current_Conditions__c  req52 = new Current_Conditions__c();
            req52.Requirement__c     = 'Need Updated Program Knowledge Review';   
            req52.Success_Factor__c  = sf5.Id; 
                    req52.Opportunity__c     = opp.id;
            req52.Code__c            = 'R1046';
            req52.Category__c        = 'Credit';
            req52.Internal_vs_External__c = 'Internal';
        reqlist.add(req52);
        
        Current_Conditions__c  req53 = new Current_Conditions__c();
            req53.Requirement__c     = 'Need Updated Master Insurance';   
            req53.Success_Factor__c  = sf5.Id; 
                    req53.Opportunity__c     = opp.id;
            req53.Code__c            = 'R1046';
            req53.Category__c        = 'Credit';
            req53.Internal_vs_External__c = 'Internal';
        reqlist.add(req53);
        
        Current_Conditions__c  req54 = new Current_Conditions__c();
            req54.Requirement__c     = 'Need Updated Property titled in Trust';   
            req54.Success_Factor__c  = sf5.Id; 
                    req54.Opportunity__c     = opp.id;
            req54.Code__c            = 'R1046';
            req54.Category__c        = 'Credit';
            req54.Internal_vs_External__c = 'Internal';
        reqlist.add(req54);
        
        Current_Conditions__c  req55 = new Current_Conditions__c();
            req55.Requirement__c     = 'Need Updated Title holder application';   
            req55.Success_Factor__c  = sf5.Id; 
                    req55.Opportunity__c     = opp.id;
            req55.Code__c            = 'R1046';
            req55.Category__c        = 'Credit';
            req55.Internal_vs_External__c = 'Internal';
        reqlist.add(req55);
        
        Current_Conditions__c  req56 = new Current_Conditions__c();
            req56.Requirement__c     = 'Need Updated Additional lien information';   
            req56.Success_Factor__c  = sf5.Id; 
                    req56.Opportunity__c     = opp.id;
            req56.Code__c            = 'R1046';
            req56.Category__c        = 'Credit';
            req56.Internal_vs_External__c = 'Internal';
        reqlist.add(req56);
        
        Current_Conditions__c  req57 = new Current_Conditions__c();
            req57.Requirement__c     = 'Need Updated HOA Questionnaire';   
            req57.Success_Factor__c  = sf5.Id; 
                    req57.Opportunity__c     = opp.id;
            req57.Code__c            = 'R1046';
            req57.Category__c        = 'Credit';
            req57.Internal_vs_External__c = 'Internal';
        reqlist.add(req57);
        
        Current_Conditions__c  req58 = new Current_Conditions__c();
            req58.Requirement__c     = 'Need Updated Flood Insurance';   
            req58.Success_Factor__c  = sf5.Id; 
                    req58.Opportunity__c     = opp.id;
            req58.Code__c            = 'R1046';
            req58.Category__c        = 'Credit';
            req58.Internal_vs_External__c = 'Internal';
        reqlist.add(req58);
        
        Current_Conditions__c  req27 = new Current_Conditions__c();
            req27.Requirement__c     = 'Desk Review';   
            req27.Success_Factor__c  = sf4.Id; 
                    req27.Opportunity__c     = opp.id;
            req27.Code__c            = 'R1046';
            req27.Category__c        = 'Credit';
            req27.Internal_vs_External__c = 'Internal';
        reqlist.add(req27); 
        
        Current_Conditions__c  req28 = new Current_Conditions__c();
            req28.Requirement__c     = 'Reconsideration of Value';   
            req28.Success_Factor__c  = sf4.Id; 
                    req28.Opportunity__c     = opp.id;
            req28.Code__c            = 'R1046';
            req28.Category__c        = 'Credit';
            req28.Internal_vs_External__c = 'Internal';
        reqlist.add(req28);
        
        
        Current_Conditions__c  req29 = new Current_Conditions__c();
            req29.Requirement__c     = 'Other - OAV - Valuation';   
            req29.Success_Factor__c  = sf4.Id; 
                    req29.Opportunity__c     = opp.id;
            req29.Code__c            = 'R1046';
            req29.Category__c        = 'Credit';
            req29.Internal_vs_External__c = 'Internal';
        reqlist.add(req29);
        
        
        Current_Conditions__c  req30 = new Current_Conditions__c();
            req30.Requirement__c     = 'Structural Report';   
            req30.Success_Factor__c  = sf4.Id; 
                    req30.Opportunity__c     = opp.id;
            req30.Code__c            = 'R1046';
            req30.Category__c        = 'Credit';
            req30.Internal_vs_External__c = 'Internal';
        reqlist.add(req30);
        
        
        Current_Conditions__c  req31 = new Current_Conditions__c();
            req31.Requirement__c     = 'Pest Inspection';   
            req31.Success_Factor__c  = sf4.Id; 
                    req31.Opportunity__c     = opp.id;
            req31.Code__c            = 'R1046';
            req31.Category__c        = 'Credit';
            req31.Internal_vs_External__c = 'Internal';
        reqlist.add(req31);
        
        
        Current_Conditions__c  req32 = new Current_Conditions__c();
            req32.Requirement__c     = 'Other - OAV - Home Condition';   
            req32.Success_Factor__c  = sf4.Id; 
                    req32.Opportunity__c     = opp.id;
            req32.Code__c            = 'R1046';
            req32.Category__c        = 'Credit';
            req32.Internal_vs_External__c = 'Internal';
        reqlist.add(req32);
        
        
        Current_Conditions__c  req33 = new Current_Conditions__c();
            req33.Requirement__c     = 'Post-Close Home Inspection';   
            req33.Success_Factor__c  = sf4.Id; 
                    req33.Opportunity__c     = opp.id;
            req33.Code__c            = 'R1046';
            req33.Category__c        = 'Credit';
            req33.Internal_vs_External__c = 'Internal';
        reqlist.add(req33);
        
        
        Current_Conditions__c  req34 = new Current_Conditions__c();
            req34.Requirement__c     = 'Specific item must be repaired as part of funding';   
            req34.Success_Factor__c  = sf4.Id; 
                    req34.Opportunity__c     = opp.id;
            req34.Code__c            = 'R1046';
            req34.Category__c        = 'Credit';
            req34.Internal_vs_External__c = 'Internal';
        reqlist.add(req34); 
         
        Current_Conditions__c  req35 = new Current_Conditions__c();
            req35.Requirement__c     = 'Other - Home Condition';   
            req35.Success_Factor__c  = sf4.Id; 
                    req35.Opportunity__c     = opp.id;
            req35.Code__c            = 'R1046';
            req35.Category__c        = 'Credit';
            req35.Internal_vs_External__c = 'Internal';
        reqlist.add(req35); 
        
        Current_Conditions__c  req59 = new Current_Conditions__c();
            req59.Requirement__c     = 'Need Updated Reorder Appraisal';   
            req59.Success_Factor__c  = sf4.Id; 
                    req59.Opportunity__c     = opp.id;
            req59.Code__c            = 'R1046';
            req59.Category__c        = 'Credit';
            req59.Internal_vs_External__c = 'Internal';
        reqlist.add(req59);
        
        Current_Conditions__c  req60 = new Current_Conditions__c();
            req60.Requirement__c     = 'Need Updated Desk Review';   
            req60.Success_Factor__c  = sf4.Id; 
                    req60.Opportunity__c     = opp.id;
            req60.Code__c            = 'R1046';
            req60.Category__c        = 'Credit';
            req60.Internal_vs_External__c = 'Internal';
        reqlist.add(req60);
        
        Current_Conditions__c  req61 = new Current_Conditions__c();
            req61.Requirement__c     = 'Need Updated Home Inspection';   
            req61.Success_Factor__c  = sf4.Id; 
                    req61.Opportunity__c     = opp.id;
            req61.Code__c            = 'R1046';
            req61.Category__c        = 'Credit';
            req61.Internal_vs_External__c = 'Internal';
        reqlist.add(req61);
        
        Current_Conditions__c  req62 = new Current_Conditions__c();
            req62.Requirement__c     = 'Need Updated Purchase sale agreement or contract';   
            req62.Success_Factor__c  = sf4.Id; 
                    req62.Opportunity__c     = opp.id;
            req62.Code__c            = 'R1046';
            req62.Category__c        = 'Credit';
            req62.Internal_vs_External__c = 'Internal';
        reqlist.add(req62);
        
        Current_Conditions__c  req63 = new Current_Conditions__c();
            req63.Requirement__c     = 'Need Updated Reconsideration of Value';   
            req63.Success_Factor__c  = sf4.Id; 
                    req63.Opportunity__c     = opp.id;
            req63.Code__c            = 'R1046';
            req63.Category__c        = 'Credit';
            req63.Internal_vs_External__c = 'Internal';
        reqlist.add(req63);
        
        Current_Conditions__c  req64 = new Current_Conditions__c();
            req64.Requirement__c     = 'Need Updated Pest Inspection';   
            req64.Success_Factor__c  = sf4.Id; 
                    req64.Opportunity__c     = opp.id;
            req64.Code__c            = 'R1046';
            req64.Category__c        = 'Credit';
            req64.Internal_vs_External__c = 'Internal';
        reqlist.add(req64);
        
        Current_Conditions__c  req65 = new Current_Conditions__c();
            req65.Requirement__c     = 'Need Updated Structural Report';   
            req65.Success_Factor__c  = sf4.Id; 
                    req65.Opportunity__c     = opp.id;
            req65.Code__c            = 'R1046';
            req65.Category__c        = 'Credit';
            req65.Internal_vs_External__c = 'Internal';
        reqlist.add(req65);
        
        Current_Conditions__c  req66 = new Current_Conditions__c();
            req66.Requirement__c     = 'Need Updated Post Close Inspection';   
            req66.Success_Factor__c  = sf4.Id; 
                    req66.Opportunity__c     = opp.id;
            req66.Code__c            = 'R1046';
            req66.Category__c        = 'Credit';
            req66.Internal_vs_External__c = 'Internal';
        reqlist.add(req66);
        
        Current_Conditions__c  req67 = new Current_Conditions__c();
            req67.Requirement__c     = 'Other - Property Ownership - Verification';   
            req67.Success_Factor__c  = sf5.Id; 
                    req67.Opportunity__c     = opp.id;
            req67.Code__c            = 'R1046';
            req67.Category__c        = 'Credit';
            req67.Internal_vs_External__c = 'Internal';
        reqlist.add(req67);
        
        Current_Conditions__c  req68 = new Current_Conditions__c();
            req68.Requirement__c     = 'Divorce Decree';   
            req68.Success_Factor__c  = sf5.Id; 
                    req68.Opportunity__c     = opp.id;
            req68.Code__c            = 'R1046';
            req68.Category__c        = 'Credit';
            req68.Internal_vs_External__c = 'Internal';
        reqlist.add(req68);
        
        Current_Conditions__c  req69 = new Current_Conditions__c();
            req69.Requirement__c     = 'Must pay delinquent property taxes';   
            req69.Success_Factor__c  = sf5.Id; 
                    req69.Opportunity__c     = opp.id;
            req69.Code__c            = 'R1046';
            req69.Category__c        = 'Credit';
            req69.Internal_vs_External__c = 'Internal';
        reqlist.add(req69);
        
        Current_Conditions__c  req70 = new Current_Conditions__c();
            req70.Requirement__c     = 'Must pay outstanding judgements';   
            req70.Success_Factor__c  = sf5.Id; 
                    req70.Opportunity__c     = opp.id;
            req70.Code__c            = 'R1046';
            req70.Category__c        = 'Credit';
            req70.Internal_vs_External__c = 'Internal';
        reqlist.add(req70);
        
        Current_Conditions__c  req71 = new Current_Conditions__c();
            req71.Requirement__c     = 'Specific lien must subordinate to our';   
            req71.Success_Factor__c  = sf5.Id; 
                    req71.Opportunity__c     = opp.id;
            req71.Code__c            = 'R1046';
            req71.Category__c        = 'Credit';
            req71.Internal_vs_External__c = 'Internal';
        reqlist.add(req71);
        
        Current_Conditions__c  req72 = new Current_Conditions__c();
            req72.Requirement__c     = 'Application Required for All Parties on Title';   
            req72.Success_Factor__c  = sf5.Id; 
                    req72.Opportunity__c     = opp.id;
            req72.Code__c            = 'R1046';
            req72.Category__c        = 'Credit';
            req72.Internal_vs_External__c = 'Internal';
        reqlist.add(req72);
        

        
        Current_Conditions__c  req74 = new Current_Conditions__c();
            req74.Requirement__c     = 'Client Must Pay Down Mortgage - 1st Lender';   
            req74.Success_Factor__c  = sf1.Id; 
                    req74.Opportunity__c     = opp.id;
            req74.Code__c            = 'R1046';
            req74.Category__c        = 'Credit';
            req74.Internal_vs_External__c = 'Internal';
        reqlist.add(req74);
        
        Current_Conditions__c  req75 = new Current_Conditions__c();
            req75.Requirement__c     = 'Client Must Pay Down Mortgage - 2nd Lender';   
            req75.Success_Factor__c  = sf1.Id; 
                    req75.Opportunity__c     = opp.id;
            req75.Code__c            = 'R1046';
            req75.Category__c        = 'Credit';
            req75.Internal_vs_External__c = 'Internal';
        reqlist.add(req75);
        
        Current_Conditions__c  req76 = new Current_Conditions__c();
            req76.Requirement__c     = 'Client Must Pay Down Mortgage - 3rd Lender';   
            req76.Success_Factor__c  = sf1.Id; 
                    req76.Opportunity__c     = opp.id;
            req76.Code__c            = 'R1046';
            req76.Category__c        = 'Credit';
            req76.Internal_vs_External__c = 'Internal';
        reqlist.add(req76);
        
        Current_Conditions__c  req77 = new Current_Conditions__c();
            req77.Requirement__c     = 'Document Received, In progress';   
            req77.Success_Factor__c  = sf4.Id; 
                    req77.Opportunity__c     = opp.id;
            req77.Code__c            = 'R1046';
            req77.Category__c        = 'Credit';
            req77.Internal_vs_External__c = 'Internal';
            req77.RSI_Eligible__c=true;
        reqlist.add(req77);
        
        Current_Conditions__c  req78 = new Current_Conditions__c();
            req78.Requirement__c     = 'Second Appraisal';   
            req78.Success_Factor__c  = sf4.Id; 
                    req78.Opportunity__c     = opp.id;
            req78.Code__c            = 'R1046';
            req78.Category__c        = 'Credit';
            req78.Internal_vs_External__c = 'Internal';
        reqlist.add(req78);
        
        Current_Conditions__c  req79 = new Current_Conditions__c();
            req79.Requirement__c     = 'Escrow Holdback for Item that Must';   
            req79.Success_Factor__c  = sf4.Id; 
                    req79.Opportunity__c     = opp.id;
            req79.Code__c            = 'R1046';
            req79.Category__c        = 'Credit';
            req79.Internal_vs_External__c = 'Internal';
        reqlist.add(req79);
        
        Current_Conditions__c  req80 = new Current_Conditions__c();
            req80.Requirement__c     = 'Need Updated Employment Offer Letter';   
            req80.Success_Factor__c  = sf2.Id; 
                    req80.Opportunity__c     = opp.id;
            req80.Code__c            = 'R1046';
            req80.Category__c        = 'Credit';
            req80.Internal_vs_External__c = 'Internal';
        reqlist.add(req80);
        
        Current_Conditions__c  req81 = new Current_Conditions__c();
            req81.Requirement__c     = 'Employment Offer Letter';   
            req81.Success_Factor__c  = sf2.Id; 
                    req81.Opportunity__c     = opp.id;
            req81.Code__c            = 'R1046';
            req81.Category__c        = 'Credit';
            req81.Internal_vs_External__c = 'Internal';
        reqlist.add(req81);
        
        
        
        
        

        try{
            if(reqlist.size() > 0) {
                insert reqlist;
            }
            //Current_Conditions__c currentConditionsUpdate = [Select Requirement__c from Current_Conditions__c where Requirement__c ='Employment Offer Letter' AND Code__c ='R1046' Limit 1];
            //currentConditionsUpdate.Requirement__c='Need Updated Employment Offer Letter';
            //update currentConditionsUpdate;
            
            Current_Conditions__c currentConditionsTest=new Current_Conditions__c(); 
            RequirementTriggerHandler.setDefaultRequirement(currentConditionsTest, '12313', 
                                                            'Credit', 'Credit', 'Credit', 
                                                            true, 'Credit', 'Credit', 
                                                            'Credit', true, 'Credit', 'Credit', 'Test Reason');
            RequirementTriggerHandler.updateopportunity(reqlist);
        } catch(DmlException e) {
            
        }   
        
    }
     
     @istest
    private static void manualReqTest2() {
        
    Test.setMock(HttpCalloutMock.class, new HttpMockTest());
        List<Current_Conditions__c>   reqlist  = new List<Current_Conditions__c>();
        Account acc          = new Account();
            acc.Name         = 'test1 acc';
        insert acc;    
                        
        Opportunity opp      = new Opportunity();
            opp.AccountId      = acc.Id;
            opp.Name         = 'test1 opp';
            opp.StageName    = 'Investment Due Diligence';
            opp.CloseDate    = System.today();
            opp.Estimated_Funding_Amount__c = 2;
            opp.Pricing_Ratio__c = 2;
            opp.Final_OAV_Calculation__c = 4;
            opp.IA_OAV_Override__c =2;
        insert opp;            
        
        List<Success_Factor__c>  sflist = new List<Success_Factor__c>(); 
        Success_Factor__c sf1     = new Success_Factor__c();
            sf1.Opportunity__c     = opp.Id;
            sf1.Success_Factor__c  = 'LTV';
            sf1.Program__c = 'HO';
            sf1.status__c = 'In Progress';
        sflist.add(sf1);
        
        Success_Factor__c sf2     = new Success_Factor__c();
            sf2.Opportunity__c     = opp.Id;
            sf2.Success_Factor__c  = 'DTI';
        sf2.Program__c = 'HO';
         sf2.status__c = 'In Progress';
        sflist.add(sf2);
        
        Success_Factor__c sf3     = new Success_Factor__c();
            sf3.Opportunity__c     = opp.Id;
            sf3.Success_Factor__c  = 'Credit';
        sf3.Program__c = 'HO';
         sf3.status__c = 'In Progress';
        sflist.add(sf3);       
        
        Success_Factor__c sf4     = new Success_Factor__c();
            sf4.Opportunity__c     = opp.Id;
            sf4.Success_Factor__c  = 'OAV';
        sf4.Program__c = 'HO';
         sf4.status__c = 'In Progress';
        sflist.add(sf4);
       
        Success_Factor__c sf5     = new Success_Factor__c();
            sf5.Opportunity__c     = opp.Id;
            sf5.Success_Factor__c  = 'Property Ownership';
        sf5.Program__c = 'HO';
         sf5.status__c = 'In Progress';
        sflist.add(sf5);
        
        Success_Factor__c sf6     = new Success_Factor__c();
            sf6.Opportunity__c     = opp.Id;
            sf6.Success_Factor__c  = 'Investment Due Diligence';
        sf6.Program__c = 'HO';
         sf6.status__c = 'In Progress';
        sflist.add(sf6); 
        
        
        if(sflist.size() > 0) {
            insert sflist;
        }
        
        
        Current_Conditions__c  req1 = new Current_Conditions__c();
            req1.Requirement__c     = 'Credit Supplement';   
            req1.Success_Factor__c  = sf3.Id; 
            req1.Opportunity__c     = opp.id;
            req1.Code__c            = 'R1046';
            req1.Category__c        = 'Credit';
        reqlist.add(req1);
        
        Current_Conditions__c  req2 = new Current_Conditions__c();
            req2.Requirement__c     = 'Letter of Explanation - Credit - Credit';   
            req2.Success_Factor__c  = sf3.Id; 
                            req2.Opportunity__c     = opp.id;
            req2.Code__c            = 'R1046';
            req2.Category__c        = 'Credit';
            req2.Internal_vs_External__c = 'Internal';
        reqlist.add(req2);
        
        Current_Conditions__c  req3 = new Current_Conditions__c();
            req3.Requirement__c     = 'Other - Credit - Credit';   
            req3.Success_Factor__c  = sf3.Id; 
                            req3.Opportunity__c     = opp.id;
            req3.Code__c            = 'R1046';
            req3.Category__c        = 'Credit';
            req3.Internal_vs_External__c = 'Internal';
        reqlist.add(req3);
        
        Current_Conditions__c  req37 = new Current_Conditions__c();
            req37.Requirement__c     = 'Need Updated Credit Supplement';   
            req37.Success_Factor__c  = sf3.Id; 
                            req37.Opportunity__c     = opp.id;
            req37.Code__c            = 'R1046';
            req37.Category__c        = 'Credit';
            req37.Internal_vs_External__c = 'Internal';
        reqlist.add(req37);
        
        Current_Conditions__c  req4 = new Current_Conditions__c();
            req4.Requirement__c     = 'Rental Income';   
            req4.Success_Factor__c  = sf2.Id; 
                            req4.Opportunity__c     = opp.id;
            req4.Code__c            = 'R1046';
            req4.Category__c        = 'Credit';
            req4.Internal_vs_External__c = 'Internal';
        reqlist.add(req4); 
        
        
        Current_Conditions__c  req5 = new Current_Conditions__c();
            req5.Requirement__c     = 'Letter of Explanation - DTI - Income';   
            req5.Success_Factor__c  = sf2.Id;
                            req5.Opportunity__c     = opp.id;
            req5.Code__c            = 'R1046';
            req5.Category__c        = 'Credit';
            req5.Internal_vs_External__c = 'Internal';
        reqlist.add(req5);
        
        
        Current_Conditions__c  req6 = new Current_Conditions__c();
            req6.Requirement__c     = 'Other - DTI - Income';   
            req6.Success_Factor__c  = sf2.Id; 
                            req6.Opportunity__c     = opp.id;
            req6.Code__c            = 'R1046';
            req6.Category__c        = 'Credit';
            req6.Internal_vs_External__c = 'Internal';
        reqlist.add(req6); 
        
        
        Current_Conditions__c  req7 = new Current_Conditions__c();
            req7.Requirement__c     = 'Brokerage Statement';   
            req7.Success_Factor__c  = sf2.Id; 
                            req7.Opportunity__c     = opp.id;
            req7.Code__c            = 'R1046';
            req7.Category__c        = 'Credit';
            req7.Internal_vs_External__c = 'Internal';
        reqlist.add(req7); 
        
        
        Current_Conditions__c  req8 = new Current_Conditions__c();
            req8.Requirement__c     = 'Retirement Statement';   
            req8.Success_Factor__c  = sf2.Id; 
                            req8.Opportunity__c     = opp.id;
            req8.Code__c            = 'R1046';
            req8.Category__c        = 'Credit';
            req8.Internal_vs_External__c = 'Internal';
        reqlist.add(req8); 
        
        
        Current_Conditions__c  req9 = new Current_Conditions__c();
            req9.Requirement__c     = 'Other - DTI - Assets';   
            req9.Success_Factor__c  = sf2.Id; 
                            req9.Opportunity__c     = opp.id;
            req9.Code__c            = 'R1046';
            req9.Category__c        = 'Credit';
            req9.Internal_vs_External__c = 'Internal';
        reqlist.add(req9); 
        
        
        Current_Conditions__c  req10 = new Current_Conditions__c();
            req10.Requirement__c     = 'Client must pay off outstanding past due liability';   
            req10.Success_Factor__c  = sf2.Id; 
                            req10.Opportunity__c     = opp.id;
            req10.Code__c            = 'R1046';
            req10.Category__c        = 'Credit';
            req10.Internal_vs_External__c = 'Internal';
        reqlist.add(req10);
        
        
        Current_Conditions__c  req11 = new Current_Conditions__c();
            req11.Requirement__c     = 'Other - DTI - Debt Reduction';   
            req11.Success_Factor__c  = sf2.Id; 
                            req11.Opportunity__c     = opp.id;
            req11.Code__c            = 'R1046';
            req11.Category__c        = 'Credit';
            req11.Internal_vs_External__c = 'Internal';
        reqlist.add(req11);
        
        Current_Conditions__c  req38 = new Current_Conditions__c();
            req38.Requirement__c     = 'Need Updated Paystub';   
            req38.Success_Factor__c  = sf2.Id; 
                            req38.Opportunity__c     = opp.id;
            req38.Code__c            = 'R1046';
            req38.Category__c        = 'Credit';
            req38.Internal_vs_External__c = 'Internal';
        reqlist.add(req38);
        
        Current_Conditions__c  req39 = new Current_Conditions__c();
            req39.Requirement__c     = 'Need Updated W2';   
            req39.Success_Factor__c  = sf2.Id; 
                            req39.Opportunity__c     = opp.id;
            req39.Code__c            = 'R1046';
            req39.Category__c        = 'Credit';
            req39.Internal_vs_External__c = 'Internal';
        reqlist.add(req39);
        
        Current_Conditions__c  req40 = new Current_Conditions__c();
            req40.Requirement__c     = 'Need Updated Tax Return';   
            req40.Success_Factor__c  = sf2.Id; 
                            req40.Opportunity__c     = opp.id;
            req40.Code__c            = 'R1046';
            req40.Category__c        = 'Credit';
            req40.Internal_vs_External__c = 'Internal';
        reqlist.add(req40);
               
        Current_Conditions__c  req41 = new Current_Conditions__c();
            req41.Requirement__c     = 'Need Updated SS Award Letter';   
            req41.Success_Factor__c  = sf2.Id; 
                            req41.Opportunity__c     = opp.id;
            req41.Code__c            = 'R1046';
            req41.Category__c        = 'Credit';
            req41.Internal_vs_External__c = 'Internal';
        reqlist.add(req41);
        
        Current_Conditions__c  req42 = new Current_Conditions__c();
            req42.Requirement__c     = 'Need Updated Pension Award Letter';   
            req42.Success_Factor__c  = sf2.Id; 
                            req42.Opportunity__c     = opp.id;
            req42.Code__c            = 'R1046';
            req42.Category__c        = 'Credit';
            req42.Internal_vs_External__c = 'Internal';
        reqlist.add(req42);
        
        Current_Conditions__c  req43 = new Current_Conditions__c();
            req43.Requirement__c     = 'Need Updated Rental Income';   
            req43.Success_Factor__c  = sf2.Id; 
                            req43.Opportunity__c     = opp.id;
            req43.Code__c            = 'R1046';
            req43.Category__c        = 'Credit';
            req43.Internal_vs_External__c = 'Internal';
        reqlist.add(req43);
        
        Current_Conditions__c  req44 = new Current_Conditions__c();
            req44.Requirement__c     = 'Need Updated Bank Statement';   
            req44.Success_Factor__c  = sf2.Id; 
                            req44.Opportunity__c     = opp.id;
            req44.Code__c            = 'R1046';
            req44.Category__c        = 'Credit';
            req44.Internal_vs_External__c = 'Internal';
        reqlist.add(req44);
        
        Current_Conditions__c  req45 = new Current_Conditions__c();
            req45.Requirement__c     = 'Need Updated Brokerage Statement';   
            req45.Success_Factor__c  = sf2.Id; 
                            req45.Opportunity__c     = opp.id;
            req45.Code__c            = 'R1046';
            req45.Category__c        = 'Credit';
            req45.Internal_vs_External__c = 'Internal';
        reqlist.add(req45);
        
        Current_Conditions__c  req46 = new Current_Conditions__c();
            req46.Requirement__c     = 'Need Updated Retirement Statement';   
            req46.Success_Factor__c  = sf2.Id; 
                            req46.Opportunity__c     = opp.id;
            req46.Code__c            = 'R1046';
            req46.Category__c        = 'Credit';
            req46.Internal_vs_External__c = 'Internal';
        reqlist.add(req46);
        
        Current_Conditions__c  req47 = new Current_Conditions__c();
            req47.Requirement__c     = 'Need Updated Business Tax Returns';   
            req47.Success_Factor__c  = sf2.Id; 
                            req47.Opportunity__c     = opp.id;
            req47.Code__c            = 'R1046';
            req47.Category__c        = 'Credit';
            req47.Internal_vs_External__c = 'Internal';
        reqlist.add(req47); 
        
        Current_Conditions__c  req12 = new Current_Conditions__c();
            req12.Requirement__c     = 'Letter of Explanation - LTV - Mortgage';   
            req12.Success_Factor__c  = sf1.Id; 
                            req12.Opportunity__c     = opp.id;
            req12.Code__c            = 'R1046';
            req12.Category__c        = 'Credit';
            req12.Internal_vs_External__c = 'Internal';
        reqlist.add(req12);
        
        Current_Conditions__c  req13 = new Current_Conditions__c();
            req13.Requirement__c     = 'Other - LTV - Mortgage';   
            req13.Success_Factor__c  = sf1.Id; 
                            req13.Opportunity__c     = opp.id;
            req13.Code__c            = 'R1046';
            req13.Category__c        = 'Credit';
            req13.Internal_vs_External__c = 'Internal';
        reqlist.add(req13);
        
        Current_Conditions__c  req48 = new Current_Conditions__c();
            req48.Requirement__c     = 'Need Updated Mortgage Statement';   
            req48.Success_Factor__c  = sf1.Id; 
                            req48.Opportunity__c     = opp.id;
            req48.Code__c            = 'R1046';
            req48.Category__c        = 'Credit';
            req48.Internal_vs_External__c = 'Internal';
        reqlist.add(req48); 
        
        Current_Conditions__c  req14 = new Current_Conditions__c();
            req14.Requirement__c     = 'One or more title holders must be removed';   
            req14.Success_Factor__c  = sf5.Id; 
                            req14.Opportunity__c     = opp.id;
            req14.Code__c            = 'R1046';
            req14.Category__c        = 'Credit';
            req14.Internal_vs_External__c = 'Internal';
        reqlist.add(req14); 
        
        
        Current_Conditions__c  req15 = new Current_Conditions__c();
            req15.Requirement__c     = 'Partner must pay delinquent property taxes';   
            req15.Success_Factor__c  = sf5.Id; 
                            req15.Opportunity__c     = opp.id;
            req15.Code__c            = 'R1046';
            req15.Category__c        = 'Credit';
            req15.Internal_vs_External__c = 'Internal';
        reqlist.add(req15);
        
        Current_Conditions__c  req16 = new Current_Conditions__c();
            req16.Requirement__c     = 'Must pay/remove outstanding judgments';   
            req16.Success_Factor__c  = sf5.Id; 
                            req16.Opportunity__c     = opp.id;
            req16.Code__c            = 'R1046';
            req16.Category__c        = 'Credit';
            req16.Internal_vs_External__c = 'Internal';
        reqlist.add(req16); 
        
        
        Current_Conditions__c  req17 = new Current_Conditions__c();
            req17.Requirement__c     = 'Must remove closed out lien';   
            req17.Success_Factor__c  = sf5.Id; 
                            req17.Opportunity__c     = opp.id;
            req17.Code__c            = 'R1046';
            req17.Category__c        = 'Credit';
            req17.Internal_vs_External__c = 'Internal';
        reqlist.add(req17);
        
        Current_Conditions__c  req18 = new Current_Conditions__c();
            req18.Requirement__c     = 'Must obtain flood insurance on property';   
            req18.Success_Factor__c  = sf5.Id; 
                            req18.Opportunity__c     = opp.id;
            req18.Code__c            = 'R1046';
            req18.Category__c        = 'Credit';
            req18.Internal_vs_External__c = 'Internal';
        reqlist.add(req18); 
        
        
        Current_Conditions__c  req19 = new Current_Conditions__c();
            req19.Requirement__c     = 'Hazard Insurance';   
            req19.Success_Factor__c  = sf5.Id; 
                            req19.Opportunity__c     = opp.id;
            req19.Code__c            = 'R1046';
            req19.Category__c        = 'Credit';
            req19.Internal_vs_External__c = 'Internal';
        reqlist.add(req19);
        
        Current_Conditions__c  req20 = new Current_Conditions__c();
            req20.Requirement__c     = 'Death Certificate';   
            req20.Success_Factor__c  = sf5.Id; 
                            req20.Opportunity__c     = opp.id;
            req20.Code__c            = 'R1046';
            req20.Category__c        = 'Credit';
            req20.Internal_vs_External__c = 'Internal';
        reqlist.add(req20); 
        
        
        Current_Conditions__c  req21 = new Current_Conditions__c();
            req21.Requirement__c     = 'Title holder application';   
            req21.Success_Factor__c  = sf5.Id; 
                            req21.Opportunity__c     = opp.id;
            req21.Code__c            = 'R1046';
            req21.Category__c        = 'Credit';
            req21.Internal_vs_External__c = 'Internal';
        reqlist.add(req21);
        
        Current_Conditions__c  req22 = new Current_Conditions__c();
            req22.Requirement__c     = 'Additional Lien Information';   
            req22.Success_Factor__c  = sf5.Id; 
                            req22.Opportunity__c     = opp.id;
            req22.Code__c            = 'R1046';
            req22.Category__c        = 'Credit';
            req22.Internal_vs_External__c = 'Internal';
        reqlist.add(req22); 
        
        
        Current_Conditions__c  req23 = new Current_Conditions__c();
            req23.Requirement__c     = 'Other - Property Ownership';   
            req23.Success_Factor__c  = sf5.Id; 
                            req23.Opportunity__c     = opp.id;
            req23.Code__c            = 'R1046';
            req23.Category__c        = 'Credit';
            req23.Internal_vs_External__c = 'Internal';
        reqlist.add(req23);
        
        Current_Conditions__c  req24 = new Current_Conditions__c();
            req24.Requirement__c     = 'Flood Insurance';   
            req24.Success_Factor__c  = sf5.Id; 
                            req24.Opportunity__c     = opp.id;
            req24.Code__c            = 'R1046';
            req24.Category__c        = 'Credit';
            req24.Internal_vs_External__c = 'Internal';
        reqlist.add(req24); 
        
        
        Current_Conditions__c  req25 = new Current_Conditions__c();
            req25.Requirement__c     = 'Other - Other';   
            req25.Success_Factor__c  = sf5.Id; 
                            req25.Opportunity__c     = opp.id;
            req25.Code__c            = 'R1046';
            req25.Category__c        = 'Credit';
            req25.Internal_vs_External__c = 'Internal';
        reqlist.add(req25);
        
        Current_Conditions__c  req26 = new Current_Conditions__c();
            req26.Requirement__c     = 'Specific lien must subordinate to our position';   
            req26.Success_Factor__c  = sf5.Id; 
                            req26.Opportunity__c     = opp.id;
            req26.Code__c            = 'R1046';
            req26.Category__c        = 'Credit';
            req26.Internal_vs_External__c = 'Internal';
        reqlist.add(req26);
        
        Current_Conditions__c  req49 = new Current_Conditions__c();
            req49.Requirement__c     = 'Need Updated Reorder Title';   
            req49.Success_Factor__c  = sf5.Id; 
                            req49.Opportunity__c     = opp.id;
            req49.Code__c            = 'R1046';
            req49.Category__c        = 'Credit';
            req49.Internal_vs_External__c = 'Internal';
        reqlist.add(req49);
        
        Current_Conditions__c  req50 = new Current_Conditions__c();
            req50.Requirement__c     = 'Need Updated Hazard Insurance';   
            req50.Success_Factor__c  = sf5.Id; 
                            req50.Opportunity__c     = opp.id;
            req50.Code__c            = 'R1046';
            req50.Category__c        = 'Credit';
            req50.Internal_vs_External__c = 'Internal';
        reqlist.add(req50);
        
        Current_Conditions__c  req51 = new Current_Conditions__c();
            req51.Requirement__c     = 'Need Updated Prequal Letter';   
            req51.Success_Factor__c  = sf5.Id; 
                            req51.Opportunity__c     = opp.id;
            req51.Code__c            = 'R1046';
            req51.Category__c        = 'Credit';
            req51.Internal_vs_External__c = 'Internal';
        reqlist.add(req51);
        
        Current_Conditions__c  req52 = new Current_Conditions__c();
            req52.Requirement__c     = 'Need Updated Program Knowledge Review';   
            req52.Success_Factor__c  = sf5.Id; 
                            req52.Opportunity__c     = opp.id;
            req52.Code__c            = 'R1046';
            req52.Category__c        = 'Credit';
            req52.Internal_vs_External__c = 'Internal';
        reqlist.add(req52);
        
        Current_Conditions__c  req53 = new Current_Conditions__c();
            req53.Requirement__c     = 'Need Updated Master Insurance';   
            req53.Success_Factor__c  = sf5.Id; 
                            req53.Opportunity__c     = opp.id;
            req53.Code__c            = 'R1046';
            req53.Category__c        = 'Credit';
            req53.Internal_vs_External__c = 'Internal';
        reqlist.add(req53);
        
        Current_Conditions__c  req54 = new Current_Conditions__c();
            req54.Requirement__c     = 'Need Updated Property titled in Trust';   
            req54.Success_Factor__c  = sf5.Id; 
                            req54.Opportunity__c     = opp.id;
            req54.Code__c            = 'R1046';
            req54.Category__c        = 'Credit';
            req54.Internal_vs_External__c = 'Internal';
        reqlist.add(req54);
        
        Current_Conditions__c  req55 = new Current_Conditions__c();
            req55.Requirement__c     = 'Need Updated Title holder application';   
            req55.Success_Factor__c  = sf5.Id; 
                            req55.Opportunity__c     = opp.id;
            req55.Code__c            = 'R1046';
            req55.Category__c        = 'Credit';
            req55.Internal_vs_External__c = 'Internal';
        reqlist.add(req55);
        
        Current_Conditions__c  req56 = new Current_Conditions__c();
            req56.Requirement__c     = 'Need Updated Additional lien information';   
            req56.Success_Factor__c  = sf5.Id; 
                            req56.Opportunity__c     = opp.id;
            req56.Code__c            = 'R1046';
            req56.Category__c        = 'Credit';
            req56.Internal_vs_External__c = 'Internal';
        reqlist.add(req56);
        
        Current_Conditions__c  req57 = new Current_Conditions__c();
            req57.Requirement__c     = 'Need Updated HOA Questionnaire';   
            req57.Success_Factor__c  = sf5.Id; 
                            req57.Opportunity__c     = opp.id;
            req57.Code__c            = 'R1046';
            req57.Category__c        = 'Credit';
            req57.Internal_vs_External__c = 'Internal';
        reqlist.add(req57);
        
        Current_Conditions__c  req58 = new Current_Conditions__c();
            req58.Requirement__c     = 'Need Updated Flood Insurance';   
            req58.Success_Factor__c  = sf5.Id; 
                            req58.Opportunity__c     = opp.id;
            req58.Code__c            = 'R1046';
            req58.Category__c        = 'Credit';
            req58.Internal_vs_External__c = 'Internal';
        reqlist.add(req58);
        
        Current_Conditions__c  req27 = new Current_Conditions__c();
            req27.Requirement__c     = 'Desk Review';   
            req27.Success_Factor__c  = sf4.Id; 
                            req27.Opportunity__c     = opp.id;
            req27.Code__c            = 'R1046';
            req27.Category__c        = 'Credit';
            req27.Internal_vs_External__c = 'Internal';
        reqlist.add(req27); 
        
        Current_Conditions__c  req28 = new Current_Conditions__c();
            req28.Requirement__c     = 'Reconsideration of Value';   
            req28.Success_Factor__c  = sf4.Id; 
                            req28.Opportunity__c     = opp.id;
            req28.Code__c            = 'R1046';
            req28.Category__c        = 'Credit';
            req28.Internal_vs_External__c = 'Internal';
        reqlist.add(req28);
        
        
        Current_Conditions__c  req29 = new Current_Conditions__c();
            req29.Requirement__c     = 'Other - OAV - Valuation';   
            req29.Success_Factor__c  = sf4.Id; 
                            req29.Opportunity__c     = opp.id;
            req29.Code__c            = 'R1046';
            req29.Category__c        = 'Credit';
            req29.Internal_vs_External__c = 'Internal';
        reqlist.add(req29);
        
        
        Current_Conditions__c  req30 = new Current_Conditions__c();
            req30.Requirement__c     = 'Structural Report';   
            req30.Success_Factor__c  = sf4.Id; 
                            req30.Opportunity__c     = opp.id;
            req30.Code__c            = 'R1046';
            req30.Category__c        = 'Credit';
            req30.Internal_vs_External__c = 'Internal';
        reqlist.add(req30);
        
        
        Current_Conditions__c  req31 = new Current_Conditions__c();
            req31.Requirement__c     = 'Pest Inspection';   
            req31.Success_Factor__c  = sf4.Id; 
                            req31.Opportunity__c     = opp.id;
            req31.Code__c            = 'R1046';
            req31.Category__c        = 'Credit';
            req31.Internal_vs_External__c = 'Internal';
        reqlist.add(req31);
        
        
        Current_Conditions__c  req32 = new Current_Conditions__c();
            req32.Requirement__c     = 'Other - OAV - Home Condition';   
            req32.Success_Factor__c  = sf4.Id; 
                            req32.Opportunity__c     = opp.id;
            req32.Code__c            = 'R1046';
            req32.Category__c        = 'Credit';
            req32.Internal_vs_External__c = 'Internal';
        reqlist.add(req32);
        
        
        Current_Conditions__c  req33 = new Current_Conditions__c();
            req33.Requirement__c     = 'Post-Close Home Inspection';   
            req33.Success_Factor__c  = sf4.Id; 
                            req3.Opportunity__c     = opp.id;
            req33.Code__c            = 'R1046';
            req33.Category__c        = 'Credit';
            req33.Internal_vs_External__c = 'Internal';
        reqlist.add(req33);
        
        
        Current_Conditions__c  req34 = new Current_Conditions__c();
            req34.Requirement__c     = 'Specific item must be repaired as part of funding';   
            req34.Success_Factor__c  = sf4.Id; 
                            req34.Opportunity__c     = opp.id;
            req34.Code__c            = 'R1046';
            req34.Category__c        = 'Credit';
            req34.Internal_vs_External__c = 'Internal';
        reqlist.add(req34); 
         
        Current_Conditions__c  req35 = new Current_Conditions__c();
            req35.Requirement__c     = 'Other - Home Condition';   
            req35.Success_Factor__c  = sf4.Id; 
                            req35.Opportunity__c     = opp.id;
            req35.Code__c            = 'R1046';
            req35.Category__c        = 'Credit';
            req35.Internal_vs_External__c = 'Internal';
        reqlist.add(req35); 
        
        Current_Conditions__c  req59 = new Current_Conditions__c();
            req59.Requirement__c     = 'Need Updated Reorder Appraisal';   
            req59.Success_Factor__c  = sf4.Id; 
                            req59.Opportunity__c     = opp.id;
            req59.Code__c            = 'R1046';
            req59.Category__c        = 'Credit';
            req59.Internal_vs_External__c = 'Internal';
        reqlist.add(req59);
        
        Current_Conditions__c  req60 = new Current_Conditions__c();
            req60.Requirement__c     = 'Need Updated Desk Review';   
            req60.Success_Factor__c  = sf4.Id; 
                            req60.Opportunity__c     = opp.id;
            req60.Code__c            = 'R1046';
            req60.Category__c        = 'Credit';
            req60.Internal_vs_External__c = 'Internal';
        reqlist.add(req60);
        
        Current_Conditions__c  req61 = new Current_Conditions__c();
            req61.Requirement__c     = 'Need Updated Home Inspection';   
            req61.Success_Factor__c  = sf4.Id; 
                            req61.Opportunity__c     = opp.id;
            req61.Code__c            = 'R1046';
            req61.Category__c        = 'Credit';
            req61.Internal_vs_External__c = 'Internal';
        reqlist.add(req61);
        
        Current_Conditions__c  req62 = new Current_Conditions__c();
            req62.Requirement__c     = 'Need Updated Purchase sale agreement or contract';   
            req62.Success_Factor__c  = sf4.Id; 
                            req62.Opportunity__c     = opp.id;
            req62.Code__c            = 'R1046';
            req62.Category__c        = 'Credit';
            req62.Internal_vs_External__c = 'Internal';
        reqlist.add(req62);
        
        Current_Conditions__c  req63 = new Current_Conditions__c();
            req63.Requirement__c     = 'Need Updated Reconsideration of Value';   
            req63.Success_Factor__c  = sf4.Id; 
                            req63.Opportunity__c     = opp.id;
            req63.Code__c            = 'R1046';
            req63.Category__c        = 'Credit';
            req63.Internal_vs_External__c = 'Internal';
        reqlist.add(req63);
        
        Current_Conditions__c  req64 = new Current_Conditions__c();
            req64.Requirement__c     = 'Need Updated Pest Inspection';   
            req64.Success_Factor__c  = sf4.Id; 
                            req64.Opportunity__c     = opp.id;
            req64.Code__c            = 'R1046';
            req64.Category__c        = 'Credit';
            req64.Internal_vs_External__c = 'Internal';
        reqlist.add(req64);
        
        Current_Conditions__c  req65 = new Current_Conditions__c();
            req65.Requirement__c     = 'Need Updated Structural Report';   
            req65.Success_Factor__c  = sf4.Id; 
                            req65.Opportunity__c     = opp.id;
            req65.Code__c            = 'R1046';
            req65.Category__c        = 'Credit';
            req65.Internal_vs_External__c = 'Internal';
        reqlist.add(req65);
        
        Current_Conditions__c  req66 = new Current_Conditions__c();
            req66.Requirement__c     = 'Need Updated Post Close Inspection';   
            req66.Success_Factor__c  = sf4.Id; 
                            req66.Opportunity__c     = opp.id;
            req66.Code__c            = 'R1046';
            req66.Category__c        = 'Credit';
            req66.Internal_vs_External__c = 'Internal';
        reqlist.add(req66);
        
        Current_Conditions__c  req67 = new Current_Conditions__c();
            req67.Requirement__c     = 'Other - Property Ownership - Verification';   
            req67.Success_Factor__c  = sf5.Id; 
                            req67.Opportunity__c     = opp.id;
            req67.Code__c            = 'R1046';
            req67.Category__c        = 'Credit';
            req67.Internal_vs_External__c = 'Internal';
        reqlist.add(req67);
        
        Current_Conditions__c  req68 = new Current_Conditions__c();
            req68.Requirement__c     = 'Need Updated Certificate of Occupancy';   
            req68.Success_Factor__c  = sf5.Id; 
                            req68.Opportunity__c     = opp.id;
            req68.Code__c            = 'R1046';
            req68.Category__c        = 'Credit';
            req68.Internal_vs_External__c = 'Internal';
        reqlist.add(req68);
        
        Current_Conditions__c  req69 = new Current_Conditions__c();
            req69.Requirement__c     = 'Title Policy';   
            req69.Success_Factor__c  = sf5.Id; 
                            req69.Opportunity__c     = opp.id;
            req69.Code__c            = 'R1046';
            req69.Category__c        = 'Credit';
            req69.Internal_vs_External__c = 'Internal';
        reqlist.add(req69);
        
        Current_Conditions__c  req70 = new Current_Conditions__c();
            req70.Requirement__c     = 'Need Updated Lender Pre-Approval';   
            req70.Success_Factor__c  = sf6.Id; 
                            req70.Opportunity__c     = opp.id;
            req70.Code__c            = 'R1046';
            req70.Category__c        = 'Credit';
            req70.Internal_vs_External__c = 'Internal';
        reqlist.add(req70);
        
        Current_Conditions__c  req71 = new Current_Conditions__c();
            req71.Requirement__c     = 'Need Updated Credit Report';   
            req71.Success_Factor__c  = sf3.Id; 
                            req71.Opportunity__c     = opp.id;
            req71.Code__c            = 'R1046';
            req71.Category__c        = 'Credit';
            req71.Internal_vs_External__c = 'Internal';
        reqlist.add(req71);
        
        Current_Conditions__c  req72 = new Current_Conditions__c();
            req72.Requirement__c     = '1040';   
            req72.Success_Factor__c  = sf2.Id; 
                            req72.Opportunity__c     = opp.id;
            req72.Code__c            = 'R1046';
            req72.Category__c        = 'Credit';
            req72.Internal_vs_External__c = 'Internal';
        reqlist.add(req72);
        
        Current_Conditions__c  req73 = new Current_Conditions__c();
            req73.Requirement__c     = '1099';   
            req73.Success_Factor__c  = sf2.Id; 
                            req73.Opportunity__c     = opp.id;
            req73.Code__c            = 'R1046';
            req73.Category__c        = 'Credit';
            req73.Internal_vs_External__c = 'Internal';
        reqlist.add(req73);
        
        Current_Conditions__c  req74 = new Current_Conditions__c();
            req74.Requirement__c     = 'Additional_Assets_Verification_Required';   
            req74.Success_Factor__c  = sf2.Id; 
                            req74.Opportunity__c     = opp.id;
            req74.Code__c            = 'R1046';
            req74.Category__c        = 'Credit';
            req74.Internal_vs_External__c = 'Internal';
        reqlist.add(req74);
        
        Current_Conditions__c  req75 = new Current_Conditions__c();
            req75.Requirement__c     = 'Other - DTI - Liabilities';   
            req75.Success_Factor__c  = sf2.Id; 
                            req75.Opportunity__c     = opp.id;
            req75.Code__c            = 'R1046';
            req75.Category__c        = 'Credit';
            req75.Internal_vs_External__c = 'Internal';
        reqlist.add(req75);
        
        Current_Conditions__c  req76 = new Current_Conditions__c();
            req76.Requirement__c     = 'Add Applicant to Title at Closing';   
            req76.Success_Factor__c  = sf5.Id; 
                            req76.Opportunity__c     = opp.id;
            req76.Code__c            = 'R1046';
            req76.Category__c        = 'Credit';
            req76.Internal_vs_External__c = 'Internal';
        reqlist.add(req76);
        
        Current_Conditions__c  req77 = new Current_Conditions__c();
            req77.Requirement__c     = 'Master Insurance';   
            req77.Success_Factor__c  = sf5.Id; 
                            req77.Opportunity__c     = opp.id;
            req77.Code__c            = 'R1046';
            req77.Category__c        = 'Credit';
            req77.Internal_vs_External__c = 'Internal';
        reqlist.add(req77);
        
        Current_Conditions__c  req78 = new Current_Conditions__c();
            req78.Requirement__c     = 'Additional Appraisal Requested';   
            req78.Success_Factor__c  = sf4.Id; 
                            req78.Opportunity__c     = opp.id;
            req78.Code__c            = 'R1046';
            req78.Category__c        = 'Credit';
            req78.Internal_vs_External__c = 'Internal';
        reqlist.add(req78);
        
        Current_Conditions__c  req79 = new Current_Conditions__c();
            req79.Requirement__c     = 'Appraisal';   
            req79.Success_Factor__c  = sf4.Id; 
                            req79.Opportunity__c     = opp.id;
            req79.Code__c            = 'R1046';
            req79.Category__c        = 'Credit';
            req79.Internal_vs_External__c = 'Internal';
        reqlist.add(req79);
        
        Current_Conditions__c  req80 = new Current_Conditions__c();
            req80.Requirement__c     = 'Home Inspection';   
            req80.Success_Factor__c  = sf4.Id; 
                            req80.Opportunity__c     = opp.id;
            req80.Code__c            = 'R1046';
            req80.Category__c        = 'Credit';
            req80.Internal_vs_External__c = 'Internal';
        reqlist.add(req80);
        
        Current_Conditions__c  req81 = new Current_Conditions__c();
            req81.Requirement__c     = 'Master Insurance';   
            req81.Success_Factor__c  = sf4.Id; 
                            req81.Opportunity__c     = opp.id;
            req81.Code__c            = 'R1046';
            req81.Category__c        = 'Credit';
            req81.Internal_vs_External__c = 'Internal';
        reqlist.add(req81);
        
        Current_Conditions__c  req82 = new Current_Conditions__c();
            req82.Requirement__c     = 'Appraisal - 1004D';   
            req82.Success_Factor__c  = sf4.Id; 
                            req82.Opportunity__c     = opp.id;
            req82.Code__c            = 'R1046';
            req82.Category__c        = 'Credit';
            req82.Internal_vs_External__c = 'Internal';
        reqlist.add(req82);
        
        Current_Conditions__c  req83 = new Current_Conditions__c();
            req83.Requirement__c     = 'Appraisal Desk Review';   
            req83.Success_Factor__c  = sf4.Id; 
                            req83.Opportunity__c     = opp.id;
            req83.Code__c            = 'R1046';
            req83.Category__c        = 'Credit';
            req83.Internal_vs_External__c = 'Internal';
        reqlist.add(req83);
        
        Current_Conditions__c  req84 = new Current_Conditions__c();
            req84.Requirement__c     = 'Roof Inspection';   
            req84.Success_Factor__c  = sf4.Id; 
                            req84.Opportunity__c     = opp.id;
            req84.Code__c            = 'R1046';
            req84.Category__c        = 'Credit';
            req84.Internal_vs_External__c = 'Internal';
        reqlist.add(req84); 
        
        
        if(reqlist.size() > 0) {
            insert reqlist;
        }
       
     }
     
     @isTest 
     private static void manualReqTest() {
         List<Current_Conditions__c> reqlist = [select Id, Code__c, Category__c, Requirement__c from Current_Conditions__c];
         for(Current_Conditions__c req : reqlist){
             if(req.Requirement__c == 'Credit supplement'){
                 System.assertEquals('R1046',req.Code__c);
                 System.assertEquals('Credit', req.Category__c);
             } /*else if(req.Requirement__c == 'Letter of Explanation - Credit - Credit'){
                 System.assertEquals('CON-0112',req.Code__c);
                 System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - Credit - Credit'){
                 System.assertEquals('CON-0113',req.Code__c);
                 System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Rental Income'){
                 System.assertEquals('CON-0106',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Letter of Explanation - DTI - Income'){
                 System.assertEquals('CON-0107',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - DTI - Income'){
                 System.assertEquals('CON-0109',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Brokerage Statement'){
                 System.assertEquals('CON-0115',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Retirement Statement'){
                 System.assertEquals('CON-0116',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - DTI - Assets'){
                 System.assertEquals('CON-0117',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Client must pay off outstanding past due liability'){
                 System.assertEquals('CON-0203',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - DTI - Debt Reduction'){
                 System.assertEquals('CON-0204',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Letter of Explanation - LTV - Mortgage'){
                 System.assertEquals('CON-0120',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - LTV - Mortgage'){
                 System.assertEquals('CON-0121',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Death Certificate'){
                 System.assertEquals('CON-0133',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Title holder application'){
                 System.assertEquals('CON-0134',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Additional Lien Information'){
                 System.assertEquals('CON-0135',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - Property Ownership'){
                 System.assertEquals('CON-0139',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Must obtain flood insurance on property'){
                 System.assertEquals('CON-0214',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Specific lien must subordinate to our position'){
                 System.assertEquals('CON-0208',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'One or more title holders must be removed'){
                 System.assertEquals('CON-0209',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Partner must pay delinquent property taxes'){
                 System.assertEquals('CON-0210',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Must pay/remove outstanding judgments'){
                 System.assertEquals('CON-0211',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Must remove closed out lien'){
                 System.assertEquals('CON-0212',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Flood Insurance'){
                 System.assertEquals('CON-0138',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - Property Ownership - Verification'){
                 System.assertEquals('CON-0136',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Hazard Insurance'){
                 System.assertEquals('CON-0222',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Desk Review'){
                 System.assertEquals('CON-0123',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Reconsideration of Value'){
                 System.assertEquals('CON-0124',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - OAV - Valuation'){
                 System.assertEquals('CON-0125',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Structural Report'){
                 System.assertEquals('CON-0127',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Pest Inspection'){
                 System.assertEquals('CON-0128',req.Code__c);
                 //System.assertEquals('Credit', req.Category__c);
             }else if(req.Requirement__c == 'Other - OAV - Home Condition'){
                 System.assertEquals('CON-0129',req.Code__c);
             }else if(req.Requirement__c == 'Post-Close Home Inspection'){
                 System.assertEquals('CON-0301',req.Code__c);                
             }else if(req.Requirement__c == 'Specific item must be repaired as part of funding'){
                 System.assertEquals('CON-0205',req.Code__c);                 
             }else if(req.Requirement__c == 'Other - Home Condition'){
                 System.assertEquals('CON-0207',req.Code__c);                 
             }
                */      
         }
        
     }   

// VK : BUS-155110164

   @istest
    private static void appraisalReqCompletiontest() {
       Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock());
        List<Current_Conditions__c>   reqlist  = new List<Current_Conditions__c>();
        Account acc          = new Account();
            acc.Name         = 'test acc';
        insert acc;    
        
        Schema.DescribeSObjectResult oppDescribe = Opportunity.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> oppRTMap = oppDescribe.getRecordTypeInfosByName();
       OpportunityTriggerHandler.createdRequirements = true;
        Opportunity opp      = new Opportunity();
            opp.AccountId      = acc.Id;
            opp.Name         = 'test opp';
            opp.StageName    = 'Investment Due Diligence';
            opp.recordTypeId = oppRTMap.get('HomeOwner').GetRecordTypeId();
            opp.CloseDate    = System.today();
            opp.Estimated_Funding_Amount__c = 2;
            opp.Pricing_Ratio__c = 2;
            opp.Final_OAV_Calculation__c = 2;
            opp.IA_OAV_Override__c =2;
            opp.appraisal_ordered__c = true;
        insert opp;            
        
        List<Success_Factor__c>  sflist = new List<Success_Factor__c>(); 
           
        Success_Factor__c sf4     = new Success_Factor__c();
            sf4.Opportunity__c     = opp.Id;
            sf4.Success_Factor__c  = 'OAV';
            sf4.Status__c  = 'In Progress';
            sf4.Program__c = 'HO';
        sflist.add(sf4);
        
        if(sflist.size() > 0) {
            insert sflist;
        }
 		
        Current_Conditions__c  req1 = new Current_Conditions__c();
            req1.Requirement__c     = 'Appraisal - 1st';   
            req1.Success_Factor__c  = sf4.Id; 
            req1.Opportunity__c     = opp.id;
            req1.Code__c            = 'R1008';
            req1.Category__c        = 'Valuation';
            req1.Internal_vs_External__c = 'Internal';
        reqlist.add(req1);
   
		
        if(reqlist.size() > 0) {
             insert reqlist;
        }
        
		List<Appraisal__c> applist = new List<Appraisal__c>();
        Appraisal__c app1     = new Appraisal__c();
        app1.Appraisal_External_Id__c= '123456';
        app1.Appraisal_Ordered_Date__c=System.today();
        app1.Appraisal_Order_Number__c='1';
        app1.Appraisal_Status__c='Ordered';
        app1.MercuryTrackingId__c='123214';
        app1.Opportunity__c=opp.Id;
        app1.Requirement__c = reqlist[0].Id;
        applist.add(app1);      
        
        if(applist.size() >0) {
        	insert applist;
    	}
        

        reqlist[0].Status__c = System.Label.Completed;
        try {
          update reqlist[0];  
        }
        catch(Exception e){
            String expectedError = System.Label.Cannot_close_Requirement_Error_Message;
			Boolean expectedExceptionThrown = e.getMessage().contains(expectedError) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		} 
       // TO DO add a test for Happy Path. 
    }


    }