/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Neeraja Cherukuri
 *  Create date:  June 18 2019
 *   Details
 *  -------------------------------------------------------------------------
 *  Apex Class to handle Duplicate Phone Numbers on Lead.
 *   
 * ************************************************************************************/



public class phoneNumberTransform {
    public static String standardize(string inputPhone){
        //need to strip all formatting. Add +1 to input phone
        string noChars = inputPhone.replaceAll('\\D','');
         
        string firstChar = noChars.substring(0,1);
        system.debug('firstChar: ' + firstChar);
        
        string firstTwo = noChars.substring(0,2);
         
        if (firstChar == '1'){
            noChars = '+' + noChars;
        }
         
        else if(firstTwo != '+1'){
            system.debug('firstTwo: ' + firstTwo);
            noChars = '+1' + noChars;
        }
        return(noChars);
    }
}