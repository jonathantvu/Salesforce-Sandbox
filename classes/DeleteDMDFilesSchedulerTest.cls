@isTest (seealldata=true)
public class DeleteDMDFilesSchedulerTest {
	public static testMethod void testDeleteDMDFiles()
    {
    	test.startTest();
        DeleteDMDFilesScheduler schedulable = new DeleteDMDFilesScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('DeleteDMDFilesScheduler', sch, schedulable);        	
        test.stopTest();
    }
}