/**
 * Created by Carolina Veliz on 5/7/2019.
 */

@isTest
public class AccListControllerTest {
    @isTest(SeeAllData=true)
    private static void testData() {

        Contact con = [SELECT id, AccountId FROM Contact where AccountId != null limit 1];
        system.debug(con);
        //if (acc != null)
        List<Contact> contacts = AccListController.getContacts(con.accountid);

        contacts.size();

    }

}