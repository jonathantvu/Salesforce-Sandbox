/************************************************************************************
 Apex Class Name     : DeleteDMDFilesBatch 
 Version             : 1.0
 Created Date        : 23th March 2019
 Function            : Once a File is uploaded in DMD we are purging the files with BOX URL generated.
 Author              : Neeraja Cherukuri
 
 Modification Log    :

* Developer                   Date                    Description
* ----------------------------------------------------------------------------------                 
* Neeraja Cherukuri            03/22/2019               Original Version
*************************************************************************************
*/


global class DeleteDMDFilesBatch implements Database.batchable<ContentDocumentLink>
{ 
   global Iterable<ContentDocumentLink> start(Database.batchableContext info)
   { 
       return new CustomIterableCaller(); 
   }     
   global void execute(Database.batchableContext info, List<ContentDocumentLink> scope)
   { 
       List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>(); 
       for(ContentDocumentLink a : scope){ 
           
           lstCDL.add(a); 
       } 
       System.debug('=====accsToUpdate===='+lstCDL.size());
       Delete lstCDL; 
   }     
   global void finish(Database.batchableContext info)
   {     
   } 
}