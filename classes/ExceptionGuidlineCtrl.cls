/**********************************************************
 * Class        : ExceptionGuidlineCtrl.cls
 * Test Class   : ExceptionGuidlineCtrl_TEST.cls
 * Created Date : January 11, 2018
 * Modified by  : -
 * Modified Date: -
 * Objective    : This class provide methods for ExceptionGuidline.page
 *
 *
 **********************************************************/ 

public class ExceptionGuidlineCtrl  {

    public List<String> guidelineTypes { get { return new List<String> { 'HO', 'NHO', 'HO IO', 'NHO IO' }; } }
    public List<integer> allFicoValues { get { return new List<integer> { 850, 825, 800, 775, 750, 725, 700, 680, 675, 650, 625, 600 }; } }
    public Map<integer, string> allFicoValuesMap {
        get {
            return new Map<integer, string> {
                850 => 'Above 850',
                825 => '825 - 849', 
                800 => '800 - 824', 
                775 => '775 - 799',
                750 => '750 - 774', 
                725 => '725 - 749', 
                700 => '700 - 724', 
                680 => '680 - 699', 
                675 => '675 - 679', 
                650 => '640 - 674', 
                625 => '625 - 649', 
                600 => '600 - 624'
            };
        }
    }
    public List<integer> allLtvValues { get { return new List<integer> { 100, 95, 90, 85, 80, 75, 70, 65, 60, 55, 50, 45, 40, 35, 30, 25, 20, 15, 10, 5, 0 }; } }
    public Map<integer, string> allLtvValuesMap {
        get {
            return new Map<integer, string> {
                100 => '100%',
                95 => '95% - 99.99%', 
                90 => '90% - 94.99%', 
                85 => '85% - 89.99%',
                80 => '80% - 84.99%', 
                75 => '75% - 79.99%', 
                70 => '70% - 74.99%', 
                65 => '65% - 69.99%', 
                60 => '60% - 64.99%', 
                55 => '55% - 59.99%', 
                50 => '50% - 54.99%', 
                45 => '45% - 49.99%', 
                40 => '40% - 44.99%', 
                35 => '35% - 39.99%', 
                30 => '30% - 34.99%', 
                25 => '25% - 29.99%', 
                20 => '20% - 24.99%', 
                15 => '15% - 19.99%', 
                10 => '10% - 14.99%', 
                5 => '5% - 9.99%', 
                0 => '0% - 4.99%'
            };
        }
    }
    public List<integer> allDtiValues { get { return new List<integer> { 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180 }; } }
    public Map<integer, string> allDtiValuesMap {
        get {
            return new Map<integer, string> {
                0 => '0%',
                10 => '0.01% - 10%', 
                20 => '10.01% - 20%', 
                30 => '20.01% - 30%',
                40 => '30.01% - 40%', 
                50 => '40.01% - 50%', 
                60 => '50.01% - 60%', 
                70 => '60.01% - 70%', 
                80 => '70.01% - 80%', 
                90 => '80.01% - 90%', 
                100 => '90.01% - 100%', 
                110 => '100.01% - 110%', 
                120 => '110.01% - 120%', 
                130 => '120.01% - 130%', 
                140 => '130.01% - 140%', 
                150 => '140.01% - 150%', 
                160 => '150.01% - 160%', 
                170 => '160.01% - 170%', 
                180 => '170.01% - 180%'
            };
        }
    }

    public static List<SelectOption> getStatusValues(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--'));
        options.add(new SelectOption('Yes', 'Yes'));
        options.add(new SelectOption('No', 'No'));
        options.add(new SelectOption('Exception', 'Exception'));

        return options;
    }
    
    public string currentTab { get; set; }

    public Map<String, Map<integer, Map<integer, Exception_Fico_Guideline__c>>> ficoGuideLineMap {get;set;}
    public Map<String, Map<integer, Map<integer, Exception_DTI_Guideline__c>>> dtiGuideLineMap {get;set;}

    public ExceptionGuidlineCtrl(){
        ficoGuideLineMap = new Map<String, Map<integer, Map<integer, Exception_Fico_Guideline__c>>>();
        dtiGuideLineMap = new Map<String, Map<integer, Map<integer, Exception_DTI_Guideline__c>>>();

        loadValues();
        
        currentTab = 'HO';
    }

    /******************** Public Methods *************************/

    public string gType { get; set; }
    public integer ltv { get; set; }
    public integer fico { get; set; }
    public integer dti { get; set; }
    public string selValue { get; set; }
    public void SetFICOValue() {
        ficoGuideLineMap.get(gType).get(ltv).get(fico).Status__c = selValue;
    }
    public void SetDTIValue() {
        dtiGuideLineMap.get(gType).get(ltv).get(dti).Status__c = selValue;
    }
    
    public void ChangeTab() {}
    
    public void SaveEverything() {
        List<Exception_Fico_Guideline__c> ficoToUpsert = new List<Exception_Fico_Guideline__c>();
        for (Map<integer, Map<integer, Exception_Fico_Guideline__c>> map1 : ficoGuideLineMap.values()) {
            for (Map<integer, Exception_Fico_Guideline__c> map2 : map1.values()) {
                ficoToUpsert.addAll(map2.values());
            }
        }
        
        if (ficoToUpsert.size() > 0) {
            try {
                upsert ficoToUpsert;
            } catch(Exception ex) { 
                ApexPages.addMessages(ex);
            }
        }
        
        List<Exception_Dti_Guideline__c> dtiToUpsert = new List<Exception_Dti_Guideline__c>();
        for (Map<integer, Map<integer, Exception_Dti_Guideline__c>> map1 : dtiGuideLineMap.values()) {
            for (Map<integer, Exception_Dti_Guideline__c> map2 : map1.values()) {
                dtiToUpsert.addAll(map2.values());
            }
        }
        
        if (dtiToUpsert.size() > 0) {
            try {
                upsert dtiToUpsert;
            } catch(Exception ex) { 
                ApexPages.addMessages(ex);
            }
        }
    }

    /******
    *
    * This method is used to add all data in tables
    *
    ******/
    public void loadValues() {
        for (String typeStr: guidelineTypes) {
            Map<integer, Map<integer, Exception_Fico_Guideline__c>> ficoMatrix = new Map<integer, Map<integer, Exception_Fico_Guideline__c>>();
            Map<integer, Map<integer, Exception_DTI_Guideline__c>> dtiMatrix = new Map<integer, Map<integer, Exception_DTI_Guideline__c>>();

            for (integer ltv: allLtvValues){
                
                Map<integer, Exception_Fico_Guideline__c> ficoMap = new Map<integer, Exception_Fico_Guideline__c>();
                for (integer fico: allFicoValues) {
                    String keyStr = typeStr + '~' + String.valueOf(fico) + '~' + String.valueOf(ltv);

                    Exception_Fico_Guideline__c ficoG = new Exception_Fico_Guideline__c();
                    ficoG.Name = keyStr;
                    ficoG.Type__c = typeStr;
                    ficoG.FICO__c = fico;
                    ficoG.LTV__c = ltv;

                    ficoMap.put(fico, ficoG);
                }
                ficoMatrix.put(ltv, ficoMap); 
                
                Map<integer, Exception_DTI_Guideline__c> dtiMap = new Map<integer, Exception_DTI_Guideline__c>();
                for (integer dti: allDtiValues) {
                    String keyStr = typeStr + '~' + String.valueOf(dti) + '~' + String.valueOf(ltv);

                    Exception_DTI_Guideline__c dtiG = new Exception_DTI_Guideline__c();
                    dtiG.Name = keyStr;
                    dtiG.Type__c = typeStr;
                    dtiG.LTV__c = ltv;
                    dtiG.DTI__c = dti; 

                    dtiMap.put(dti, dtiG);
                }
                dtiMatrix.put(ltv, dtiMap);
            }//end 2nd for

            ficoGuideLineMap.put(typeStr, ficoMatrix);
            dtiGuideLineMap.put(typeStr, dtiMatrix);
        }
        
        List<Exception_Fico_Guideline__c> ficoGuidelines = [Select Id, FICO__c, LTV__c, Status__c, Type__c from Exception_Fico_Guideline__c];
        for (Exception_Fico_Guideline__c ficoG: ficoGuidelines) {
            if (ficoGuideLineMap.containsKey(ficoG.Type__c) && ficoGuideLineMap.get(ficoG.Type__c).containsKey(integer.valueOf(ficoG.LTV__c)))
                ficoGuideLineMap.get(ficoG.Type__c).get(integer.valueOf(ficoG.LTV__c)).put(integer.valueOf(ficoG.FICO__c), ficoG);
        }

        List<Exception_DTI_Guideline__c> dtiGuidelines = [Select Id, DTI__c, LTV__c, Status__c, Type__c from Exception_DTI_Guideline__c];
        for(Exception_DTI_Guideline__c dtiG: dtiGuidelines){
            if(dtiGuideLineMap.containsKey(dtiG.Type__c) && dtiGuideLineMap.get(dtiG.Type__c).containsKey(integer.valueOf(dtiG.LTV__c)))
                dtiGuideLineMap.get(dtiG.Type__c).get(integer.valueOf(dtiG.LTV__c)).put(integer.valueOf(dtiG.DTI__c), dtiG);
        }
    }
}