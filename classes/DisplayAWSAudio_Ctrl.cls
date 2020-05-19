/**********************************************************
 * @className   : DisplayAWSAudio_Ctrl.cls
 * @testClass   : DisplayAWSAudio_Ctrl_TEST.cls
 * @author      : - 
 * @date        : August 22, 2018
 * @description : This provides methods for DisplayAWSAudio lightning componenet
 *
 *
 **********************************************************/ 

public class DisplayAWSAudio_Ctrl  {

    public String jsonAuthDetail {get;set;}

    public DisplayAWSAudio_Ctrl(){
        jsonAuthDetail = '';
    }

    /********************** Public Methods ****************/

    public void getAuthConfig(){
        String taskId = ApexPages.currentPage().getParameters().get('Id');

        //set authDetail
        jsonAuthDetail = JSON.serialize(getConfig(taskId));
    }

    public PageReference backToTaks(){
        String taskId = ApexPages.currentPage().getParameters().get('Id');
        return new PageReference('/' + taskId);
    }

    @AuraEnabled
    public static ConfigDetail getConfig(String taskId){
        ConfigDetail config = new ConfigDetail();
		List<AWS_Authentication__mdt> authDetails = [Select Id, AccessKey__c, BucketName__c, SecretKey__c, File_Folder__c, AWS_Region__c
                                                        from AWS_Authentication__mdt Limit 1];
		if (authDetails != null && authDetails.size() > 0){
			config = new ConfigDetail(authDetails.get(0));
			Task tsk = [Select Id,  Five9CallRecordingFile__c from Task Where Id = :taskId];
			System.debug('***DisplayAWSAudio_Ctrl - getConfig() - tsk: ');
			System.debug(tsk);

			if (!String.isBlank(tsk.Five9CallRecordingFile__c)){
				config.filePath += '/' + tsk.Five9CallRecordingFile__c;
			}else{
				config.errorMessage = 'File NOT found. Please fill the Five9CallRecordingFile field with the file name.';
				System.debug('***DisplayAWSAudio_Ctrl - getConfig() - ERROR: ' + config.errorMessage);
			}

			System.debug('***DisplayAWSAudio_Ctrl - getConfig() - config: ');
			System.debug(config);
		}else{
			config.errorMessage = 'No authentication details found. Please add a new AWS_Authentication__mdt custom metadata record.';
			System.debug('***DisplayAWSAudio_Ctrl - getConfig() - ERROR: ' + config.errorMessage);
		}
        
        return config;
    }


    /************************** Wrapper **********************/
    public class ConfigDetail{
        @AuraEnabled
        public String accessKey {get;set;}
        @AuraEnabled
        public String bucketName {get;set;}
        @AuraEnabled
        public String secretKey {get;set;}
        @AuraEnabled
        public String region {get;set;}
        @AuraEnabled
        public String filePath {get;set;}
		@AuraEnabled
        public String errorMessage {get;set;}

        public ConfigDetail(){
            this.accessKey = '';
            this.bucketName = '';
            this.secretKey = '';
            this.region = '';
            this.filePath = '';
			this.errorMessage = '';
        }

        public ConfigDetail(AWS_Authentication__mdt authDetail){
            this.accessKey = authDetail.AccessKey__c;
            this.bucketName = authDetail.BucketName__c;
            this.secretKey = authDetail.SecretKey__c;
            this.region = authDetail.AWS_Region__c;
            this.filePath = authDetail.File_Folder__c != null ? authDetail.File_Folder__c : '';
			this.errorMessage = '';

			if (String.isBlank(authDetail.AccessKey__c) || String.isBlank(authDetail.BucketName__c) 
					|| String.isBlank(authDetail.SecretKey__c) || String.isBlank(authDetail.AWS_Region__c)){

				this.errorMessage = 'Do not found all the authentication details. Please fill the required fields from AWS_Authentication__mdt custom metadata.';
				System.debug('***DisplayAWSAudio_Ctrl - ConfigDetail() - ERROR: ' + this.errorMessage);
			}
        }
    }
}