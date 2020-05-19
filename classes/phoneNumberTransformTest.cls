/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Neeraja Cherukuri
 *  Create date:  June 18 2019
 *   Details
 *  -------------------------------------------------------------------------
 *  phoneNumberTransformTest Test Class
 *   
 * ************************************************************************************/

@isTest
  private class phoneNumberTransformTest {
  static testMethod void test1(){
         
        Contact i = new Contact(FirstName = 'Tyler', LastName = 'Creator', Phone = '5123454235');
        system.debug(i);
        insert i;
         
         
        Contact iNull = new Contact(FirstName = 'Tyler', LastName = 'Creator', Phone = '');
        system.debug(iNull);
        insert iNull;
         
         
        Lead l = new Lead(Company = 'abc', LastName = 'bbb', Phone = '1 234 2345');
        insert l;
         
         
                 
        Lead lNull= new Lead(Company = 'abc', LastName = 'bbb', Phone = '');
        insert lNull;
      
         
    }
     
}