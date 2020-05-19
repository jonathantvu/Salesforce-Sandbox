public class AccListController {

@AuraEnabled
public static List<Contact> getContacts(Id aid) {
return [SELECT id, Name
FROM Contact where accountId=:aid
ORDER BY createdDate DESC];
}
}