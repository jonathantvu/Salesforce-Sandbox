/**********************************************************
 * @className   : Yodlee_YOR_Report_Ext.cls
 * @testClass   : Yodlee_YOR_Report_Ext_TEST.cls
 * @date        : May 11, 2018
 * @description : This is used to display a pdf in a Yodlee_YOR_Report.page received from a rest call
 *
 *
 **********************************************************/

public class Yodlee_YOR_Report_Ext  {

	private Yodlee_Order_Request__c yor;
	public Boolean displayError {get;set;}
	public Attachment attach {get;set;}

	public Yodlee_YOR_Report_Ext(ApexPages.StandardController sc){
		this.yor = (Yodlee_Order_Request__c)sc.getRecord();
		this.displayError = false;
		attach = new Attachment();
	}

	public PageReference init(){
		String errorMessage = '';
		Yodlee_Order_Request__c currentYor = [Select Id, Yodlee_Public_Id__c, Status__c from Yodlee_Order_Request__c Where Id =: this.yor.Id];

		if (currentYor != null && String.isNotBlank(currentYor.Yodlee_Public_Id__c)){
			Blob pdfFile = YodleeHelper.RetriveReportOrder(currentYor.Yodlee_Public_Id__c);

			if (pdfFile != null){
				Long lNow = Datetime.now().getTime();

				attach = new Attachment();
				attach.Body = pdfFile;
				attach.Name = 'YodleeOrderReport-' + lNow + '.pdf';
				attach.ParentId = currentYor.Id;
				attach.IsPrivate = false;
				attach.ContentType = 'application/pdf';

				insert attach;

				return new PageReference('/servlet/servlet.FileDownload?file=' + attach.Id);
			}else{
				errorMessage = 'The response received is not valid. No PDF File was generated.';
			}
		}else{
			errorMessage = 'The "Yodlee Public Id" field is empty.';
		}

		if (String.isNotBlank(errorMessage)){
			this.displayError = true;
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
			ApexPages.addMessage(msg);
		}	
		return null;
	}
}