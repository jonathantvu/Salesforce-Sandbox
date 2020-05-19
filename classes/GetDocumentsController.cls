public with sharing class GetDocumentsController 
{
    public Id propertyDueDiligenceId {get; set;}
    public List<DocumentTypeWrapper> documentTypeWrapperList {get; set;}
    public Property_Due_Diligence_Reports__c pddr {get; set;} 
    public Boolean showFiles {get; set;}
    public List<Attachment> attachmentList {get; set;}

	public GetDocumentsController(ApexPages.StandardController stdController)
    {
		propertyDueDiligenceId = ((Property_Due_Diligence_Reports__c)stdController.getRecord()).Id;
        documentTypeWrapperList = new List<DocumentTypeWrapper>();
        showFiles = false;
	}

    public PageReference GetRecordTypes()
    {
        List<Property_Due_Diligence_Reports__c> pddrList =
            [
                SELECT Id, Spruce_Order_Id__c, Opportunity__c
                FROM Property_Due_Diligence_Reports__c
                WHERE Id = :propertyDueDiligenceId
            ];

        if(pddrList.size() > 0)
        {
            if(String.isEmpty(pddrList[0].Spruce_Order_Id__c) || String.isEmpty(pddrList[0].Opportunity__c))
            { 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This record has no Order Id or is not linked to any opportunity.'));
            }
            else
            {         
                pddr = pddrList[0];

                SpruceAPI.RetrieveAvailableDocumentTypesForOrderResponse serverResponse = SpruceHelper.RetrieveAvailableDocumentTypesForOrder(pddr.Spruce_Order_Id__c);

                // if no error was encounter
                if(String.isEmpty(serverResponse.errorMessage))
                {                     
                    List<String> availableDocumentTypes = serverResponse.availableDocumentTypes;
                    //List<String> availableDocumentTypes = new List<String>{'PreliminaryClosingDisclosure', 'WiringInstructions', 'CPL'};
                    system.debug('availableDocumentTypes--> '+availableDocumentTypes);

                    for(String documentType : availableDocumentTypes)
                    {
                        DocumentTypeWrapper documentTypeWrapper = new documentTypeWrapper();
                        documentTypeWrapper.documentType = documentType;

                        documentTypeWrapperList.add(documentTypeWrapper);
                    }
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred: ' + serverResponse.errorMessage));
                }
            }
        }

        return null;
    }

    /*public void GetDocuments()
    {
        attachmentList = new List<Attachment>();

        for(DocumentTypeWrapper documentTypeWrapper : documentTypeWrapperList)
        {
            if(documentTypeWrapper.isChecked == true)
            {
                SpruceAPI.RetrieveAvailableDocumentOfGivenTypeResponse response = SpruceHelper.RetrieveAvailableDocumentOfGivenType(pddr.Spruce_Order_Id__c, documentTypeWrapper.documentType);
                
                Blob file = response.file;

                if(file != null)
                { 
                    Attachment attachment = new Attachment();
                    attachment.ParentId = pddr.Opportunity__c;
                    attachment.Name = documentTypeWrapper.documentType + '.pdf';
                    attachment.ContentType = 'application/pdf';
                    attachment.Body = file;
                    
                    attachmentList.add(attachment);
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred: ' + response.errorMessage));
                    return;
                }
            }
        }

        insert attachmentList;
        attachmentList = [SELECT Id, Name, ContentType FROM Attachment WHERE Id IN :attachmentList];
        SpruceAPI.InsertCallLogBuffer();
        showFiles = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The operation was successfull.'));
    }*/

    public PageReference goBack()
    {
        PageReference url = new PageReference('/'+ propertyDueDiligenceId);
        url.setRedirect(true);
        return url;
    }
    @RemoteAction
    public static MAP<String,String> getSpruceCredentials(){
        Map<String,String> credMap=new Map<String,String>();
        if(SpruceAPI.SETTINGS!=null){
            credMap.put('url', SpruceAPI.SETTINGS.URL__c);
            credMap.put('token', SpruceAPI.SETTINGS.Token__c);
        }
    	
            return credMap;
    }
    
    
    public class DocumentTypeWrapper
    {
        public Boolean isChecked {get; set;}
        public String documentType {get; set;}

        public DocumentTypeWrapper()
        {
            isChecked = false;
            documentType = '';
        }
    }
}