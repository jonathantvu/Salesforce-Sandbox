/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Minimum_Required_DocumentsTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Minimum_Required_DocumentsTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Minimum_Required_Documents__c());
    }
}