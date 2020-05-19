/**
 * Created by cveli on 3/3/2020.
 */

@IsTest
private class InvalidateEmailTest {

    @IsTest
    static void testRecordedInfo() {
        Recorded_Information__c rec = new Recorded_Information__c();
        rec.Fund_Number__c = 45;
        rec.Escrow_Email__c = 'dummy@domain.com';

        test.startTest();
        insert rec;
        test.stopTest();
    }
    @IsTest
    static void testAccountAndContact() {
        Account objAcc = new Account (Name='Dummy Account',Email__c='dummy@domain.com');
        test.startTest();
        insert objAcc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@domain.com',
                AccountID = objAcc.Id);
        insert con;

        test.stopTest();
    }
    @IsTest
    static void testLead() {

        Lead newLead = new Lead();
        newLead.FirstName = 'First';
        newLead.LastName = 'Last';
        newLead.Email = 'theName@domain.com';
        newLead.Phone = '1234567890';
        newLead.Retired__c = true;
        newLead.Self_Employed__c = true;
        newLead.Company = 'Dummy Company';
        newLead.Product_Specialist_to_Call_Now__c = true;
        newLead.Status = 'New';
        newLead.Street = 'Dummy Street';
        newLead.Is_there_Co_App__c = true;
        newLead.City = 'Dummy City';
        newLead.State = 'Dummy State';
        newLead.PostalCode = '12345';
        newLead.Applicant_Credit_Score_Estimate__c = '700';
        newLead.Property_Street_Number_and_Name__c = '534 Cardinal St';
        newLead.Property_City__c = 'Brea';
        newLead.Income_Monthly_Base__c = 100;

        Test.startTest();
        insert newLead;
        test.stopTest();
    }

    @IsTest
    static void testApplication() {

        Application__c tmpApp = new Application__c();
        tmpApp.Name = 'tmpApp';
        //tmpApp.Opportunity__c = opp.id;
        tmpApp.Birthdate__c = system.today();
        tmpApp.Declaration_Intent_of_Proceeds__c = '1';
        tmpApp.Applicant_Address__c = '1';
        tmpApp.Applicant_City__c = '1';
        tmpApp.Applicant_Middle_Name__c = '1';
        tmpApp.Applicant_Postal_Code__c = '12345';
        tmpApp.Applicant_Social_Security_Number__c = '123456789';
        tmpApp.Applicant_State__c = 'ca';
        tmpApp.Co_Applicant_Address__c = '10';
        tmpApp.Co_Applicant_City__c = 'dummy';
        tmpApp.Co_Applicant_Middle_Name__c = 'dummy';
        tmpApp.Co_Applicant_Postal_Code__c = '12345';
        tmpApp.Co_Applicant_Social_Security_Number__c = '1234567890';
        tmpApp.Co_Applicant_State__c = 'ca';
        tmpApp.Declaration_Adult_Name_and_Relationship__c = 'dummy';
        tmpApp.Declaration_Bankruptcy__c = 'Yes';
        tmpApp.Declaration_Bankruptcy_Co__c = 'Yes';
        tmpApp.Declaration_Deed_in_Lieu__c = 'Yes';
        tmpApp.Declaration_Deed_in_Lieu_Co__c = 'Yes';
        tmpApp.Declaration_Explanation__c = 'yes';
        tmpApp.Declaration_Felony_Co__c = 'yes';
        tmpApp.Declaration_Felony__c = 'no';
        tmpApp.Declaration_Foreclosure__c = 'no';
        tmpApp.Declaration_Foreclosure_Co__c = 'no';
        tmpApp.Declaration_Outstanding_Judgments__c = 'no';
        tmpApp.Declaration_Outstanding_Judgments_Co__c = 'no';
        tmpApp.Declaration_Permanent_Resident__c = 'no';
        tmpApp.Declaration_Permanent_Resident_Co__c = 'no';
        tmpApp.Declaration_Power_of_Attorney__c = 'no';
        tmpApp.Declaration_Power_of_Attorney_Co__c = 'no';
        tmpApp.Declaration_US_Citizen__c = 'yes';
        tmpApp.Declaration_US_Citizen_Co__c = 'yes';
        tmpApp.Email__c = 'dummy@email.com';
        tmpApp.Email_Co__c = 'dummy@email.com';
        tmpApp.Employer_Name__c = 'dummy';
        tmpApp.Employer_Name_Co__c = 'dummy';
        tmpApp.Employer_Address__c = 'dummy';
        tmpApp.Employer_Address_Co__c = 'dummy';
        tmpApp.First_Name__c = 'dummy';
        tmpApp.First_Name_Co__c = 'dummy';
        tmpApp.Gender__c = 'male';
        tmpApp.Gender_Co__c = 'male';
        tmpApp.Highest_Degree_Earned__c = 'dummy';
        tmpApp.Highest_Degree_Earned_Co__c = 'dummy';
        tmpApp.How_did_you_hear_about_FirstREX__c = 'dummy';
        tmpApp.Income_Monthly_Base__c = 1;
        tmpApp.Income_Monthly_Base_Co__c = 1;
        tmpApp.Income_Monthly_Commissions__c = 1;
        tmpApp.Income_Monthly_Commissions_Co__c = 1;
        tmpApp.Income_Monthly_Div_Interest__c = 1;
        tmpApp.Income_Monthly_Div_Interest_Co__c = 1;
        tmpApp.Income_Monthly_Other__c = 1;
        tmpApp.Income_Monthly_Other_Co__c = 1;
        tmpApp.Income_Monthly_Overtime__c = 1;
        tmpApp.Income_Monthly_Overtime_Co__c = 1;
        tmpApp.Industry__c = 'Other';
        tmpApp.Industry_Co__c = 'Other';
        tmpApp.Last_Name__c = 'dummy';
        tmpApp.Last_Name_Co__c = 'dummy';
        tmpApp.Marital_Status__c = 'single';
        tmpApp.Marital_Status_Co__c = 'single';
        tmpApp.MobilePhone__c = '1234567890';
        tmpApp.MobilePhone_Co__c = '3216549870';
        tmpApp.Months_in_Current_Job__c = 1;
        tmpApp.Months_in_Current_Job_Co__c = 1;
        tmpApp.Persons_on_Title_Dropdown__c = '2';
        tmpApp.Phone__c = '1234567890';
        tmpApp.Phone_Co__c = '3216549870';
        tmpApp.Preferred_Phone__c = '1234567890';
        tmpApp.Preferred_Phone_Co__c = '1234567890';
        tmpApp.Profession__c = 'dummy';
        tmpApp.Profession_Co__c = 'dummy';
        tmpApp.Property_Number_of_Years__c = 1;
        tmpApp.Property_Years_Planning_to_Stay__c = '1';
        tmpApp.School__c = 'dummy';
        tmpApp.School_Co__c = 'dummy';
        tmpApp.Title__c = 'dummy';
        tmpApp.Title_Co__c = 'dummy';
        tmpApp.Work_Phone__c = '1234567890';
        tmpApp.Work_Phone_Co__c = '1234567890';
        tmpApp.Years_In_This_Profession_Co__c = 1;
        tmpApp.Years_of_School__c = 1;
        tmpApp.Years_of_School_Co__c = 1;
        tmpApp.Years_on_This_Job_Co__c = 1;
        test.startTest();
        insert tmpApp;
        test.stopTest();
    }
}