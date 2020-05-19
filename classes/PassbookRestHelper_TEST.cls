/**********************************************************
 * @className   : PassbookRestHelper_TEST.cls
 * @date        : May 7, 2018
 * @description : This class provides test methods for PassbookRestHelper.cls
 *
 *
 **********************************************************/ 

@isTest 
private class PassbookRestHelper_TEST {

	@isTest
	private static void testName() {

		PassbookRestHelper.passbookJSON passBookJ = new PassbookRestHelper.passbookJSON();
        passBookJ.Origination_Credit_Score = 712;
        passBookJ.product_type = 'HO';
        passBookJ.Income = 10000 ; 
        passBookJ.Origination_Front_End_DTI = 50.2;
        passBookJ.Original_Loan_Amount = 500000 ; 
        passBookJ.Property_State = 'CA' ;
        passBookJ.Occupancy_Status = 'P';
        passBookJ.Product_Type = 'P';
        passBookJ.Origination_CLTV = 70.2 ;
        passBookJ.Cut_Off_Date = datetime.now().addHours(12);
        passBookJ.Total_Monthly_Debt_Payment = 2000;
        
        /*passBookJ.mortgage_type = 'A';
        passBookJ.ltv = 67.21;
        passBookJ.dti = 43.12;
        passBookJ.has_co_app = false;
        passBookJ.yodlee_report_id = '4b0cb48e-f10a-46bd-4e2d-8f9cfed674b6';*/

		PassbookRestHelper.passbookResponse resp = new PassbookRestHelper.passbookResponse();
		resp.id = 'd1bf1580-344c-11e8-a212-f56282bb4517R';
		resp.response = 'Decline';
		resp.comments = 'None';
		resp.exception_reason = 'Resource not found';
		resp.loss_reason = '';
		resp.grid_one_result = '';
		resp.grid_two_result = '';

		System.Test.startTest();

			Test.setMock(HttpCalloutMock.class, new PassbookRestMockImpl());
			String response = PassbookRestHelper.postToPassbook(passBookJ);

		System.Test.stopTest();

		//System.assertEquals(response, '{"example":"test"}');
	}
}