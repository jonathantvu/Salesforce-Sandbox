/**
 * Created by Carolina Veliz on 5/6/2019.
 */
@isTest
public class DataIntegrationClassTest {
    private static void testData() {
        string txt = DataIntegrationClass.ReturnAccessToken();
        system.debug(txt);
    }
}