global class CustomIterableCaller implements iterable<ContentDocumentLink>
{
   global Iterator<ContentDocumentLink> Iterator()
   {
      return new CustomIterable();
   }
}