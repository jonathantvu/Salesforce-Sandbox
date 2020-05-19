/**
 *  About
 *  -----
 *  Author: Cloud Nerd
 *  Create date: Tue Jul 16 2016
 *  
 *  Details
 *  -----
 *  Apex class which contains all the constants used in code.
 *
 *  Update History
 *  -----
 *  
 *  Issues / TODOs
 *  -----
 *  
 **/

public class CN_Constants {
    //Contact Roles
    public static final string CONTACT_ROLE_LOAN_OFFICER          = 'Loan Officer';
    public static final string CONTACT_ROLE_APPLICANT             = 'Applicant';
    
    //Opportunity Stage
    public static final string OPP_STAGE_APPLICATION_SIGNED       = 'Application Signed';
    public static final string OPP_STAGE_APPLICATION_SENT         = 'Application Sent';
    
    //Docusign status constants
    public static final string DSFS_SENT                          = 'Sent';
    public static final string DSFS_COMPLETED                     = 'Completed';
    
    public static void test(){
    	System.debug('This is for the test class ');
    }
}