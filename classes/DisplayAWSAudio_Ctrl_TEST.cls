/**********************************************************
 * @className   : DisplayAWSAudio_Ctrl_TEST.cls
 * @author      : Marian Iovi (marian.iovi@deutoria.com)
 * @date        : September 4, 2018
 * @description : This class provides test methods for DisplayAWSAudio_Ctrl.cls
 *
 *
 **********************************************************/ 

@isTest 
private class DisplayAWSAudio_Ctrl_TEST {

	@isTest
	private static void testName() {
		Task t = new Task();
		t.Subject = 'Test';
		t.Five9CallRecordingFile__c = 'test.mp3';
		insert t;

		System.Test.startTest();
			
			DisplayAWSAudio_Ctrl.ConfigDetail cnfg = DisplayAWSAudio_Ctrl.getConfig(t.Id);

			ApexPages.currentPage().getParameters().put('Id', t.Id);
			DisplayAWSAudio_Ctrl ctrl = new DisplayAWSAudio_Ctrl();
			ctrl.getAuthConfig();
			ctrl.backToTaks();

		System.Test.stopTest();

		System.assert(cnfg.filePath.contains('test.mp3'));
	}
}