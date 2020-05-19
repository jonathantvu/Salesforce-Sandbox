global class CustomIterable implements Iterator<ContentDocumentLink>
{ 

   List<ContentDocumentLink> lstCDL {get; set;} 
   Integer i {get; set;} 
   Date d = System.today() - Integer.valueOf(Label.No_of_Days_to_Delete_Files);
   public CustomIterable()
   { 
       
       lstCDL = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Document_MetaData__c WHERE Box_File_URL__c != Null AND  Createddate >= :d) and LinkedEntity.Type='Document_MetaData__c'];
       i = 0;      
   }   

   global boolean hasNext()
   { 
       if(i >= lstCDL.size()) 
       {
           return false; 
       } else 
       {
           return true; 
       }
   }    

   global ContentDocumentLink next()
   {  
       if(i == 200){return null;} 
       i++; 
       return lstCDL[i-1]; 
   } 
}