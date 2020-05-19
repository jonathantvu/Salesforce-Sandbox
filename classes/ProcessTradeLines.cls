public with sharing class ProcessTradeLines {

    public static final String COLLECTION_TYPE = 'Collection';

    private class Match {
        Integer position;
        Integer match;
        Integer months;

        public Match(Integer pos, Integer ma, Integer mon) {
            position = pos;
            match = ma;
            months = mon;
        }
    }

    @InvocableMethod(label='Process trade lines' description='Uses id of report, process trade lines attached to report and return approve or decline result.')
    public static void execute(List<Id> reportIds) {
        LASERCA__Personal_Credit_Report__c creditReport = [
            SELECT CreatedDate, Credit_Pre_Qualification_Status__c, Tier_2_Credit_Decision__c
            FROM LASERCA__Personal_Credit_Report__c 
            WHERE Id IN :reportIds
            LIMIT 1
        ];

        Date today = Date.newInstance(creditReport.CreatedDate.year(), creditReport.CreatedDate.month(), creditReport.CreatedDate.day());

        List<LASERCA__Trade_Accounts__c> tradeLineList = [
            SELECT Id, LASERCA__Credit_Loan_Type__c, LASERCA__Payment_Pattern_Start_Date__c, 
                LASERCA__Payment_Pattern_Data__c, LASERCA__Account_Balance__c
            FROM LASERCA__Trade_Accounts__c
            WHERE LASERCA__Personal_Credit_Report__c IN :reportIds
                AND ((LASERCA__Payment_Pattern_Start_Date__c != NULL
                AND LASERCA__Payment_Pattern_Data__c != NULL
                AND LASERCA__Credit_Loan_Type__c != :COLLECTION_TYPE) 
                     OR LASERCA__Credit_Loan_Type__c = :COLLECTION_TYPE)
        ];

        Set<String> tradeline_types = new Set<String>();

        for (LASERCA__Trade_Accounts__c tradeLine : tradeLineList) {
            if (tradeLine.LASERCA__Credit_Loan_Type__c != COLLECTION_TYPE) {
                tradeline_types.add(tradeLine.LASERCA__Credit_Loan_Type__c);
            }
            
        }

        System.debug('tradeline_types -> ' + tradeline_types);

        if (tradeline_types.size() == 0) {
            return;
        }

        Map<String, Integer> data = new Map<String, Integer> {
            'TotalMarksLastYear' => 0, 
            'TotalMarks1To3'     => 0,
            'TotalMarks3To5'     => 0,
            'TotalMarks5Plus'    => 0
        };

        for (String t : tradeline_types) {
            List<LASERCA__Trade_Accounts__c> d_type = new List<LASERCA__Trade_Accounts__c>();

            for (LASERCA__Trade_Accounts__c tradeLine : tradeLineList) {
                if (tradeLine.LASERCA__Credit_Loan_Type__c == t) {
                    d_type.add(tradeLine);
                }
            }

            System.debug(t +  ' --- ' + d_type);

            if (d_type.size() == 0) {
                continue;
            }

            List<Match> marks = new List<Match>();

            for (LASERCA__Trade_Accounts__c ta : d_type) {
                String line = ta.LASERCA__Payment_Pattern_Data__c;
                String pmt_patt_start_date = ta.LASERCA__Payment_Pattern_Start_Date__c;

                if (line.length() == 0 || line.replace('C', '').replace('X', '').length() == 0) {
                    continue;
                }

                Date last_act_dt = Date.newinstance(Integer.valueOf(pmt_patt_start_date.substring(0, 4)), Integer.valueOf(pmt_patt_start_date.substring(5, 7)), 1);

                System.debug('last_act_dt -> ' + last_act_dt);

                Integer months_since_pmt = (today.year() - last_act_dt.year()) * 12 + today.month() - last_act_dt.month();

                System.debug('months_since_pmt ->' + months_since_pmt);

                for (Integer i=0; i < line.length(); i++) {
					// Jason 7/13/18: added check to exclude codes 7-9 which are non-lates
					string paymentCode = line.substring(i, i+1);
                    if (paymentCode.isNumeric() && integer.valueOf(paymentCode) >0 && integer.valueOf(paymentCode) <7 ) { 
                        marks.add(new Match(i, Integer.valueOf(line.substring(i, i+1)), months_since_pmt));
                    }
                }
            }

            System.debug('marks -> ' + marks + ' type -> ' + t);

            Integer lessThanYear = 0;
            Integer oneToThreeYears = 0;
            Integer threeToFiveYears = 0;
            Integer moreThanFive = 0;

            if (marks.size() > 0) {
                for (Match mark : marks) {
                    if (mark.position + mark.months < 12) {
                        lessThanYear++;
                    }
                    if (mark.position + mark.months >= 12 && mark.position + mark.months < 36) {
                        oneToThreeYears++;
                    }
                    if (mark.position + mark.months >= 36 && mark.position + mark.months < 60) {
                        threeToFiveYears++;
                    }
                    if (mark.position + mark.months >= 60) {
                        moreThanFive++;
                    }
                }

                data.put(t + '_MarksLastYear', lessThanYear);
                data.put(t + '_Marks1To3', oneToThreeYears);
                data.put(t + '_Marks3To5', threeToFiveYears);
                data.put(t + '_Marks5Plus', moreThanFive);

                Integer tempMarksFirst = 0;
                Integer tempMarksSecond = 0;

                tempMarksFirst = data.get('TotalMarksLastYear');
                tempMarksSecond = data.get(t + '_MarksLastYear');
                data.put('TotalMarksLastYear', tempMarksFirst + tempMarksSecond);

                tempMarksFirst = data.get('TotalMarks1To3');
                tempMarksSecond = data.get(t + '_Marks1To3');
                data.put('TotalMarks1To3', tempMarksFirst + tempMarksSecond);

                tempMarksFirst = data.get('TotalMarks3To5');
                tempMarksSecond = data.get(t + '_Marks3To5');
                data.put('TotalMarks3To5', tempMarksFirst + tempMarksSecond);

                tempMarksFirst = data.get('TotalMarks5Plus');
                tempMarksSecond = data.get(t + '_Marks5Plus');
                data.put('TotalMarks5Plus', tempMarksFirst + tempMarksSecond);

            }

        }

        System.debug('data -> ' + data);

        Map<String, Integer> results = new Map<String, Integer>();

        Integer accountBalance = 0;

        for (LASERCA__Trade_Accounts__c tradeLine : tradeLineList) {
            if (tradeLine.LASERCA__Credit_Loan_Type__c == COLLECTION_TYPE) {
                accountBalance += (tradeLine.LASERCA__Account_Balance__c != NULL) ? (Integer) tradeLine.LASERCA__Account_Balance__c : 0;
            }
        }

        results.put('total_collections_outstanding', accountBalance);

        results.put('total_lates_in_last_year', 
            data.get('TotalMarksLastYear') != null ? data.get('TotalMarksLastYear') : 0
        );

        results.put('total_mortgage_lates_in_last_3_years', 
            (data.get('Mortgage_MarksLastYear') != null ? data.get('Mortgage_MarksLastYear') : 0) + 
            (data.get('Mortgage_Marks1To3') != null ? data.get('Mortgage_Marks1To3') : 0)
        );

        results.put('total_lates_in_last_5_years', 
            (data.get('TotalMarksLastYear') != null ? data.get('TotalMarksLastYear') : 0) + 
            (data.get('TotalMarks1To3') != null ? data.get('TotalMarks1To3') : 0) + 
            (data.get('TotalMarks3To5') != null ? data.get('TotalMarks3To5') : 0) + 
            (data.get('TotalMarks5Plus') != null ? data.get('TotalMarks5Plus') : 0)
        );

        results.put('time_periods_with_lates', 0);

        Set<String> marksItems = new Set<String>{'TotalMarksLastYear','TotalMarks1To3','TotalMarks3To5','TotalMarks5Plus'};
        
        for (String t : marksItems) {
            if (0 < data.get(t)) {
                Integer temp = results.get('time_periods_with_lates') + 1;
                results.put('time_periods_with_lates', temp);
            }
        }

        System.debug('results -> ' + results );        
        
        Boolean isApproved = results.get('total_collections_outstanding') <= 3500 
            && results.get('total_lates_in_last_year') <= 0
            && results.get('total_mortgage_lates_in_last_3_years') <= 0
            && results.get('total_lates_in_last_5_years') <= 10
            && results.get('time_periods_with_lates') <= 2;

        String decision;

        if (isApproved) {
            decision = 'Approved';
        } else {
            decision = 'Declined';
        }

        System.debug('decision -> ' + decision);
	
        try {
            creditReport.Credit_Pre_Qualification_Status__c = decision;
            //creditReport.Tier_2_Credit_Decision__c = decision;
            update creditReport;
        } catch (DmlException ex) {
            ex.getMessage();
        }
    }
    
    public static List<string> tier2CreditEval(Id reportId,boolean singlepull) {
        List<string> toReturn = new List<string>();
        
        LASERCA__Personal_Credit_Report__c creditReport = [
            SELECT CreatedDate, Credit_Pre_Qualification_Status__c
            FROM LASERCA__Personal_Credit_Report__c 
            WHERE Id = :reportId
            LIMIT 1
        ];

        Date today = Date.newInstance(creditReport.CreatedDate.year(), creditReport.CreatedDate.month(), creditReport.CreatedDate.day());

        List<LASERCA__Trade_Accounts__c> tradeLineList = [
            SELECT Id, LASERCA__Credit_Loan_Type__c, LASERCA__Payment_Pattern_Start_Date__c, 
                LASERCA__Payment_Pattern_Data__c, LASERCA__Account_Balance__c
            FROM LASERCA__Trade_Accounts__c
            WHERE LASERCA__Personal_Credit_Report__c = :reportId
                AND ((LASERCA__Payment_Pattern_Start_Date__c != NULL
                AND LASERCA__Payment_Pattern_Data__c != NULL
                AND LASERCA__Credit_Loan_Type__c != :COLLECTION_TYPE) 
                     OR LASERCA__Credit_Loan_Type__c = :COLLECTION_TYPE)
        ];

        Set<String> tradeline_types = new Set<String>();

        for (LASERCA__Trade_Accounts__c tradeLine : tradeLineList) {
            if (tradeLine.LASERCA__Credit_Loan_Type__c != COLLECTION_TYPE) {
                tradeline_types.add(tradeLine.LASERCA__Credit_Loan_Type__c);
            }
            
        }

        System.debug('tradeline_types -> ' + tradeline_types);

        if (tradeline_types.size() == 0) {
            if(!singlepull){
                toReturn.add('Declined');
            }else{
                 toReturn.add('Declined (Single score)');
            }
            toReturn.add('No Valid trade lines found');
            toReturn.add('No Valid trade lines found');		
            toReturn.add('No Valid trade lines found');		
            toReturn.add('No Valid trade lines found');		
            toReturn.add('No Valid trade lines found');
            return toReturn;
        }

        Map<String, Integer> data = new Map<String, Integer> {
            'TotalMarksLastYear' => 0, 
            'TotalMarks1To3'     => 0,
            'TotalMarks3To5'     => 0,
            'TotalMarks5Plus'    => 0
        };

        for (String t : tradeline_types) {
            List<LASERCA__Trade_Accounts__c> d_type = new List<LASERCA__Trade_Accounts__c>();

            for (LASERCA__Trade_Accounts__c tradeLine : tradeLineList) {
                if (tradeLine.LASERCA__Credit_Loan_Type__c == t) {
                    d_type.add(tradeLine);
                }
            }

            System.debug(t +  ' --- ' + d_type);

            if (d_type.size() == 0) {
                continue;
            }

            List<Match> marks = new List<Match>();

            for (LASERCA__Trade_Accounts__c ta : d_type) {
                String line = ta.LASERCA__Payment_Pattern_Data__c;
                String pmt_patt_start_date = ta.LASERCA__Payment_Pattern_Start_Date__c;

                if (line.length() == 0 || line.replace('C', '').replace('X', '').length() == 0) {
                    continue;
                }

                Date last_act_dt = Date.newinstance(Integer.valueOf(pmt_patt_start_date.substring(0, 4)), Integer.valueOf(pmt_patt_start_date.substring(5, 7)), 1);

                System.debug('last_act_dt -> ' + last_act_dt);

                Integer months_since_pmt = (today.year() - last_act_dt.year()) * 12 + today.month() - last_act_dt.month();

                System.debug('months_since_pmt ->' + months_since_pmt);

                for (Integer i=0; i < line.length(); i++) {
					// Jason 7/13/18: added check to exclude codes 7-9 which are non-lates
					string paymentCode = line.substring(i, i+1);
                    if (paymentCode.isNumeric() && integer.valueOf(paymentCode) >0 && integer.valueOf(paymentCode) <7 ) { 
                        marks.add(new Match(i, Integer.valueOf(line.substring(i, i+1)), months_since_pmt));
                    }
                }
            }

            System.debug('marks -> ' + marks + ' type -> ' + t);

            Integer lessThanYear = 0;
            Integer oneToThreeYears = 0;
            Integer threeToFiveYears = 0;
            Integer moreThanFive = 0;

            if (marks.size() > 0) {
                for (Match mark : marks) {
                    if (mark.position + mark.months < 12) {
                        lessThanYear++;
                    }
                    if (mark.position + mark.months >= 12 && mark.position + mark.months < 36) {
                        oneToThreeYears++;
                    }
                    if (mark.position + mark.months >= 36 && mark.position + mark.months < 60) {
                        threeToFiveYears++;
                    }
                    if (mark.position + mark.months >= 60) {
                        moreThanFive++;
                    }
                }

                data.put(t + '_MarksLastYear', lessThanYear);
                data.put(t + '_Marks1To3', oneToThreeYears);
                data.put(t + '_Marks3To5', threeToFiveYears);
                data.put(t + '_Marks5Plus', moreThanFive);

                Integer tempMarksFirst = 0;
                Integer tempMarksSecond = 0;

                tempMarksFirst = data.get('TotalMarksLastYear');
                tempMarksSecond = data.get(t + '_MarksLastYear');
                data.put('TotalMarksLastYear', tempMarksFirst + tempMarksSecond);

                tempMarksFirst = data.get('TotalMarks1To3');
                tempMarksSecond = data.get(t + '_Marks1To3');
                data.put('TotalMarks1To3', tempMarksFirst + tempMarksSecond);

                tempMarksFirst = data.get('TotalMarks3To5');
                tempMarksSecond = data.get(t + '_Marks3To5');
                data.put('TotalMarks3To5', tempMarksFirst + tempMarksSecond);

                tempMarksFirst = data.get('TotalMarks5Plus');
                tempMarksSecond = data.get(t + '_Marks5Plus');
                data.put('TotalMarks5Plus', tempMarksFirst + tempMarksSecond);

            }

        }

        System.debug('data -> ' + data);

        Map<String, Integer> results = new Map<String, Integer>();

        Integer accountBalance = 0;

        for (LASERCA__Trade_Accounts__c tradeLine : tradeLineList) {
            if (tradeLine.LASERCA__Credit_Loan_Type__c == COLLECTION_TYPE) {
                accountBalance += (tradeLine.LASERCA__Account_Balance__c != NULL) ? (Integer) tradeLine.LASERCA__Account_Balance__c : 0;
            }
        }

        results.put('total_collections_outstanding', accountBalance);

        results.put('total_lates_in_last_year', 
            data.get('TotalMarksLastYear') != null ? data.get('TotalMarksLastYear') : 0
        );

        results.put('total_mortgage_lates_in_last_3_years', 
            (data.get('Mortgage_MarksLastYear') != null ? data.get('Mortgage_MarksLastYear') : 0) + 
            (data.get('Mortgage_Marks1To3') != null ? data.get('Mortgage_Marks1To3') : 0)
        );

        results.put('total_lates_in_last_5_years', 
            (data.get('TotalMarksLastYear') != null ? data.get('TotalMarksLastYear') : 0) + 
            (data.get('TotalMarks1To3') != null ? data.get('TotalMarks1To3') : 0) + 
            (data.get('TotalMarks3To5') != null ? data.get('TotalMarks3To5') : 0) + 
            (data.get('TotalMarks5Plus') != null ? data.get('TotalMarks5Plus') : 0)
        );

        results.put('time_periods_with_lates', 0);

        Set<String> marksItems = new Set<String>{'TotalMarksLastYear','TotalMarks1To3','TotalMarks3To5','TotalMarks5Plus'};
        
        for (String t : marksItems) {
            if (0 < data.get(t)) {
                Integer temp = results.get('time_periods_with_lates') + 1;
                results.put('time_periods_with_lates', temp);
            }
        }
        
        System.debug('results -> ' + results );        

        Boolean isApproved = results.get('total_collections_outstanding') <= 3500 
            && results.get('total_lates_in_last_year') <= 0
            && results.get('total_mortgage_lates_in_last_3_years') <= 0
            && results.get('total_lates_in_last_5_years') <= 10
            && results.get('time_periods_with_lates') <= 2;
        
        String decision;
        
        System.debug('This is isApproved$123' +isApproved);
        
        if (isApproved) {
            if(!singlepull){
            	 decision = 'Approved';   
            }else{
            	 decision = 'Approved (Single score)';    
            }         
        } else {
            if(!singlepull){
            	 decision = 'Declined';   
            }else{
            	 decision = 'Declined (Single score)';    
            }
        }
        
        System.debug('This is decision$123' +decision);
        
        toReturn.add(decision);
        toReturn.add(string.valueOf(results.get('total_collections_outstanding')));         //Credit_Decision_Result_1__c 
        toReturn.add(string.valueOf(results.get('total_lates_in_last_year')));              //Credit_Decision_Result_2__c
        toReturn.add(string.valueOf(results.get('total_mortgage_lates_in_last_3_years')));  //Credit_Decision_Result_3__c        
        toReturn.add(string.valueOf(results.get('total_lates_in_last_5_years')));           //Credit_Decision_Result_4__c 
        toReturn.add(string.valueOf(results.get('time_periods_with_lates')));               //Credit_Decision_Result_5__c        
        
        System.debug('decision -> ' + toReturn[0]);

        return toReturn;
    }    
}