/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_LASERCA_Personal_Credit_ReportTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_LASERCA_Personal_Credit_Ra0WTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new LASERCA__Personal_Credit_Report__c());
    }
}