/**
 * Utility Result class for get unified result style.
 * @Created Date : 06-04-2017
 * @Authors      : StarrData
 */
public with sharing class SFUtilityResult {

    // public variable declaration.
    public boolean isSuccess     { 
        get {
            if(isSuccess == null) {
                isSuccess = false;
            }
            return isSuccess;
        }
        set; 
    }
    public string displayMessage { 
        get {
            if(displayMessage == null) {
                displayMessage = '';
            }
            return displayMessage;
        } 
        set; 
    }
    public List<Object> result   { 
        get {
            if(result == null) {
                result = new List<Object>();
            }
            return result;
        }
        set;
    }   
}