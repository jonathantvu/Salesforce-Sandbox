/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Quality_Control_LogTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Quality_Control_LogTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Quality_Control_Log__c());
    }
}