/*****************************************************************
 *   ------------------------------------------------------------------------
 *  Author: Raga Sindhu
 *  Create date:  Dec 17 2018
 *  Details
 *  -------------------------------------------------------------------------
 *  Apex class to handle all creating Requirements +Project Tasks 
 *  Update History
 *  ----------------------------------------------------------------------------
 *  Neeraja Cherukuri 4/12/2019-->Updated onAfterInsert + onAfterUpdate Methods.
 * ---------------------------------------------------------------------------
 ************************************************************************************/


public class DMATriggerHandler
{
    public static boolean createdDMAReqflag = false;
    public static String TASK_CODE_801 = 'Task-081';
    public static String TASK_CODE_802 = 'Task-082';
    public static String TASK_CODE_803 = 'Task-083';
    public static String TASK_CODE_804 = 'Task-084';

    public static String TASK_Name_1 = 'Request documentation of completion and/or payment confirmation';
    public static String TASK_Name_2 = 'Receive documentation of completion and/or payment confirmation';
    public static String TASK_Name_3 = 'Request contractor bid for escrow holdback';
    public static String TASK_Name_4 = 'Upload contractor bid for escrow holdback';

    public static void onbeforeInsert(List<DMA__c> dmalist)
    {
        set<Id> oppids  = new set<Id>();
        for(DMA__c dopp: dmalist) {
            if(dopp.Opportunity__c != Null) {
                oppids.add(dopp.opportunity__c);
            }
        }

        if(oppids.size() > 0){
            Map<Id, DMA__c> dmamap = new Map<Id, DMA__c>();
            for(DMA__c dma : [Select Id,Opportunity__c, Inspection_Date__c, Total_Number_of_Pages__c, lastmodifieddate,createddate  from DMA__c where Opportunity__c =: oppids]) {
                if(!dmamap.keyset().contains(dma.Opportunity__c)){
                    dmamap.put(dma.Opportunity__c,dma);
                }else {
                    DMA__c tempdma = dmamap.get(dma.Opportunity__c);
                    system.debug('dma.createddate: '+dma.createddate);
                    system.debug('tempdma.createddate: '+tempdma.createddate);
                    if(dma.createddate < tempdma.createddate){
                        dmamap.put(dma.Opportunity__c,dma);
                    }
                }
            }

            if(dmamap.keyset().size() > 0){
                for(DMA__c dopp: dmalist) {
                    if(dmamap.keyset().contains(dopp.Opportunity__c) && dmamap.get(dopp.Opportunity__c) != Null){
                        if(dmamap.get(dopp.Opportunity__c).Inspection_Date__c != Null) {
                            dopp.Inspection_Date__c  =  dmamap.get(dopp.Opportunity__c).Inspection_Date__c;
                        }
                        if(dmamap.get(dopp.Opportunity__c).Total_Number_of_Pages__c != Null) {
                            dopp.Page_Number__c      =  dmamap.get(dopp.Opportunity__c).Total_Number_of_Pages__c;
                        }
                    }
                }
            }
        }
    }

   /* public static void onAfterInsert(List<DMA__c> lstDMA)
    {
        Set<Id> oppIds  = new Set<Id>();
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        Map<Id, Integer> mapOptyId_DMACount = new Map<Id, Integer>();

        for(DMA__c objDMA: lstDMA)
        {
            if(objDMA.Opportunity__c != Null)
            {
                oppIds.add(objDMA.opportunity__c);
            }
        }
        System.debug('This is the size of the oppIds: '+ oppIds.size());
        if(oppIds.size()>0)
        {
            for(Opportunity objOpty : [ SELECT Id, DMA_Required_f_del__c, DMA_Count__c, Post_Close_Home_Inspection_Check__c, (select Id from DMAs__r) FROM Opportunity WHERE Id IN: oppIds] )
            {
                mapOpportunities.put(objOpty.Id, objOpty);
                Integer i = 0;
                for(DMA__c objD :  objOpty.DMAs__r)
                {
                    i++;
                }
                mapOptyId_DMACount.put(objOpty.Id, i);
            }
            //mapOpportunities = new Map<Id, Opportunity>([SELECT Id, DMA_Required_f_del__c, DMA_Count__c, Post_Close_Home_Inspection_Check__c FROM Opportunity WHERE Id IN: oppIds]);    
        }

        List<Current_Conditions__c> lstRequirements = new List<Current_Conditions__c>();
        // Query giving no rows for assignment to SObject
        //Id successFactoryId = [SELECT Id FROM Success_Factor__c WHERE Success_Factor__c =: 'Post-Closing' LIMIT 1].Id;
        // Start Change
        Success_Factor__c[] successFactories = [SELECT Id FROM Success_Factor__c WHERE Success_Factor__c = 'Post-Closing' LIMIT 1];
        if(successFactories.size()>0) {
            Id successFactoryId = successFactories[0].id;

            for(DMA__c objDMA: lstDMA)
            {

                if(objDMA.Opportunity__c != Null  && mapOptyId_DMACount.get(objDMA.Opportunity__c) == 1 )
                {
                    Current_Conditions__c objRequirements = new Current_Conditions__c();
                    objRequirements.Opportunity__c = objDMA.Opportunity__c;
                    objRequirements.Requirement__c = 'DMA Required';
                    objRequirements.Success_Factor__c = successFactoryId;
                    objRequirements.DMA__c  = objDMA.Id;
                    objRequirements.Type__c  = 'Stipulation';
                    objRequirements.Applicant_Type__c = 'Applicant';
                    objRequirements.Category__c = 'Home Condition';
                    objRequirements.Code__c  = 'CON-0206';
                    objRequirements.Internal_vs_External__c  = 'External';

                    // objRequirements.Assigned_To__c = 'TS';


                    lstRequirements.add(objRequirements);
                }

            }
            //End Change
        }
        System.debug('====lstRequirements=='+lstRequirements);
        if(lstRequirements.size()>0)

        {
            // createdDMAReqflag = True;
            //Insert lstRequirements;
        }
        //createProjectTasks(lstDMA, null);
    }*/

    /*
    public static void onAfterUpdate(List<DMA__c> lstDMA,Map<Id,DMA__c> oldMap)
    {
        createProjectTasks(lstDMA, oldMap);
    }

    public static void createProjectTasks(List<DMA__c> lstDMA,Map<Id,DMA__c> oldMap)
    {
        Set<Id> oppIds  = new Set<Id>();
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        Map<Id, Integer> mapOptyId_DMACount = new Map<Id, Integer>();
        Map<String, Current_Conditions__c > mapReqName_ReqId = new Map<String, Current_Conditions__c >();
        List<Id> reqIds  = new List<Id>();
        Set<String> setPTNames = new Set<String>();

        for(DMA__c objDMA: lstDMA)
        {
            if(oldMap != null && objDMA.Urgent_Fix_Type__c   != oldMap.get(objDMA.Id).Urgent_Fix_Type__c)
            {
                if(objDMA.Opportunity__c != Null)
                {
                    oppIds.add(objDMA.opportunity__c);
                }
            }
            else
            {
                if(objDMA.Opportunity__c != Null)
                {
                    oppIds.add(objDMA.opportunity__c);
                }
            }
        }
        System.debug('=========+oppIds'+oppIds);
        for(Project_Task__c objPT  : [SELECT Id, Name FROM Project_Task__c WHERE Opportunity__c IN: oppIds])
        {
            setPTNames.add(objPT.Name);
        }
        System.debug('=====setPTNames==='+setPTNames);
        System.debug('=====setPTNames size==='+setPTNames.size());
        List<Id> lstreq = new List<Id>();
        Map<Id, Id> mapOptyId_ReqId = new Map<Id, Id>();
        for(Current_Conditions__c objReq: [Select Id, Requirement__c, Opportunity__c ,Opportunity__r.UnisonProcessor__c
        FROM Current_Conditions__c
        WHERE Opportunity__c in :oppIds])
        {
            if(objReq.Requirement__c == 'Urgent Property Fix')
            {
                lstreq.add(objReq.id);
                mapOptyId_ReqId.put(objReq.Opportunity__c, objReq.Id);
            }
        }
        System.debug('=========+lstreq'+lstreq);
        System.debug('=========mapOptyId_ReqId==='+mapOptyId_ReqId);

        List<Project_Task__c> lstProjectTasksForInsert = new List<Project_Task__c>();


        for(DMA__c objDMA :[SELECT Id,Urgent_Fix_Type__c, Opportunity__c,  Opportunity__r.UnisonProcessor__c FROM DMA__c
        WHERE Opportunity__c IN: oppIds] ) // and Requirement__c  in:lstreq
        {
            if(objDMA.Urgent_Fix_Type__c == 'Pre-Close' && mapOptyId_ReqId.containsKey(objDMA.Opportunity__c))
            {
                if(!setPTNames.contains(TASK_Name_1))
                {
                    lstProjectTasksForInsert.add(ProjectTasksUtil.createProjectTasks(TASK_Name_1,TASK_CODE_801,objDMA.Opportunity__c,mapOptyId_ReqId.get(objDMA.Opportunity__c),objDMA.Opportunity__r.UnisonProcessor__c)); //
                    setPTNames.add(TASK_Name_1);
                }
                if(!setPTNames.contains(TASK_Name_2))
                {
                    lstProjectTasksForInsert.add(ProjectTasksUtil.createProjectTasks(TASK_Name_2,TASK_CODE_802,objDMA.Opportunity__c,mapOptyId_ReqId.get(objDMA.Opportunity__c),objDMA.Opportunity__r.UnisonProcessor__c));
                    setPTNames.add(TASK_Name_2);
                }

            }
            else if(objDMA.Urgent_Fix_Type__c == 'Escrow Holdback' && mapOptyId_ReqId.containsKey(objDMA.Opportunity__c))
            {
                if(!setPTNames.contains(TASK_Name_3))
                {
                    lstProjectTasksForInsert.add(ProjectTasksUtil.createProjectTasks(TASK_Name_3,TASK_CODE_803,objDMA.Opportunity__c,mapOptyId_ReqId.get(objDMA.Opportunity__c),objDMA.Opportunity__r.UnisonProcessor__c));
                    setPTNames.add(TASK_Name_3);
                }
                if(!setPTNames.contains(TASK_Name_4))
                {
                    lstProjectTasksForInsert.add(ProjectTasksUtil.createProjectTasks(TASK_Name_4,TASK_CODE_804,objDMA.Opportunity__c,mapOptyId_ReqId.get(objDMA.Opportunity__c),objDMA.Opportunity__r.UnisonProcessor__c));
                    setPTNames.add(TASK_Name_4);
                }
            }
        }

        System.debug('=========+lstProjectTasksForInsert'+lstProjectTasksForInsert);
        if(lstProjectTasksForInsert.size()>0)

        {
            createdDMAReqflag = True;
            // Insert lstProjectTasksForInsert;
        }

    } */
    


}