public class RequestRSIController {

    public boolean errormsg { get; set; }
    public Id recordid;
    public boolean dataexist {get;set;}
    public boolean datasaved {get;set;}
    public boolean datanotvalid {get;set;}
    public boolean dataupdate {get;set;}
    public String orderPropertyReports {get;set;}
    public String completeReportsTask {get;set;}
    public boolean isPropertyReportCompleted {get;set;}
    public List<Current_Conditions__c> reqlist {get;set;}
    public Project_Task__c prjtask {get;set;}
    public List<Project_Task__c> notifyPropertyReportTask {get;set;}


    public RequestRSIController(){
        system.debug('******inside constructor******');
        datasaved = false;
        isPropertyReportCompleted = false;
        dataexist = false;
        datanotvalid = false;
        errormsg = false;
        recordid = ApexPages.currentPage().getParameters().get('Id');
        orderPropertyReports = ApexPages.currentPage().getParameters().get('orderPropertyReport');
        completeReportsTask = ApexPages.currentPage().getParameters().get('completeReportsTask');
        system.debug('******recordid******'+recordid);
        reqlist = [select Id, Requirement__c, Reason__c from Current_Conditions__c
        where Opportunity__c =: recordid
        and Reason__c = Null and RSI_Eligible__c = True and Status__c = 'Document Received, In progress'];

        notifyPropertyReportTask = [select Id, Status__c, Requirement__c from Project_Task__c
        where Opportunity__c =: recordid AND Code__c = 'T10211'];
        system.debug('******reqlist******'+reqlist);
        if(reqlist != Null && reqlist.size() > 0){
            dataexist = true;
        }else{
            if(completeReportsTask != 'true') {
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no requirements that needed to be updated'));
                errormsg = true;
            } else {
                if(notifyPropertyReportTask.isEmpty()) {
                    apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'This task does not exist'));
                    errormsg = true;
                } else if(notifyPropertyReportTask[0].Status__c == 'Completed') {
                    apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Notify TS Property Reports are Ready to Order task is already completed'));
                    errormsg = true;
                    isPropertyReportCompleted = true;
                }
            }
        }
        system.debug('****errormsg***'+errormsg);
    }

    public void saveReq(){
        if(reqlist != Null && reqlist.size() > 0){
            for(Current_Conditions__c req : reqlist){
                if(req.Reason__c == Null){
                    datanotvalid = true;
                    apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please fill all the Reasons'));
                    errormsg = true;
                    break;
                }

            }


            if(!datanotvalid){
                update reqlist;
                datanotvalid = false;
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM,'Reasons are successfully updated'));
                datasaved = true;
                errormsg = true;

            }
            datanotvalid = false;
            //return null;

        }
        //return null;
    }

    public void completeProjectTask() {
        system.debug('********recordid*******'+recordid);
        dataupdate = false;
        Current_Conditions__c rsireq = [Select Id, Requirement__c, Opportunity__c, (Select Id from Project_Tasks__r where Name IN ('Notify file is ready for RSI', 'Notify TS Property Reports are Ready to Order')) from Current_Conditions__c where Opportunity__c =: recordid AND Requirement__c = 'RSI Letter' limit 1];
        system.debug('********rsireq *******'+rsireq);
        if(!dataupdate){
            for(Project_Task__c ptask: rsireq.Project_Tasks__r) {
                /*Caro Veliz: BUS-155110073*/
                //prjtask.Completed__c  = True;
                ptask.Status__c = 'Completed';
            }

            if(rsireq.Project_Tasks__r != Null) {
                update rsireq.Project_Tasks__r;
                dataupdate = true;
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM,'"Notify file is ready for RSI" is Completed'));
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM,'"Notify TS Property Reports are Ready to Order" is Completed'));
            }

        }
    }

    public void propertyReportIsReady() {
        system.debug('********recordid*******'+recordid);
        dataupdate = false;
        Current_Conditions__c rsireq = [Select Id, Requirement__c, Opportunity__c, (Select Id from Project_Tasks__r where Name = 'Notify TS Property Reports are Ready to Order') from Current_Conditions__c where Opportunity__c =: recordid AND Requirement__c = 'RSI Letter' limit 1];
        system.debug('********rsireq *******'+rsireq);
        if(!dataupdate){
            for(Project_Task__c ptask: rsireq.Project_Tasks__r) {
                /*Caro Veliz: BUS-155110073*/
                //prjtask.Completed__c  = True;
                ptask.Status__c = 'Completed';
            }

            if(rsireq.Project_Tasks__r != Null) {
                update rsireq.Project_Tasks__r;
                dataupdate = true;
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM,'"Notify TS Property Reports are Ready to Order" is Completed'));
            }

        }
    }

    public void completeRSIOnly() {
        system.debug('********recordid*******'+recordid);
        dataupdate = false;
        Current_Conditions__c rsireq = [Select Id, Requirement__c, Opportunity__c, (Select Id from Project_Tasks__r where Name = 'Notify file is ready for RSI') from Current_Conditions__c where Opportunity__c =: recordid AND Requirement__c = 'RSI Letter' limit 1];
        system.debug('********rsireq *******'+rsireq);
        if(!dataupdate){
            for(Project_Task__c ptask: rsireq.Project_Tasks__r) {
                /*Caro Veliz: BUS-155110073*/
                //prjtask.Completed__c  = True;
                ptask.Status__c = 'Completed';
            }

            if(rsireq.Project_Tasks__r != Null) {
                update rsireq.Project_Tasks__r;
                dataupdate = true;
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM,'"Notify file is ready for RSI" is Completed'));
            }

        }
    }
}