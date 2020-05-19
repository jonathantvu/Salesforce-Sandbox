/*************************************************************************************************
 * @className   : SurveyLOContactSched.cls
 * @testClass   : SurveyLOContactSched_Test.cls
 * @author      : Omnivo Digital (omnivodigital.com)
 * @date        : May 19, 2019
 * @description : This class is used to run SurveyLOContactBatch batch, which sends Survey LO Contact
 *
*************************************************************************************************/

global class SurveyLOContactSched implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		SurveyLOContactBatch batch = new SurveyLOContactBatch();
		Database.executeBatch(batch);
	}
}