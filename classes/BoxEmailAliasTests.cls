@IsTest
public class BoxEmailAliasTests {
	public static testmethod void testParseMember() {
		BoxJsonObject tmpBox;

        BoxApiConnection api = new BoxApiConnection('accesstoken');
		BoxEmailAlias boxEmailAlias = new BoxEmailAlias(api,'10543463');
		BoxEmailAlias.Info emailAliasInfo = new BoxEmailAlias.Info();

		try{
			BoxEmailAlias.Info emailAliasInfo2 = new BoxEmailAlias.Info( '"title":"Shirt"');
		}catch(Exception e){}

		try{
			BoxEmailAlias.Info emailAliasInfo2 = new BoxEmailAlias.Info(tmpBox);
		}catch(Exception e){}

		try{
			emailAliasInfo.addValue('1',tmpBox);
		}catch(Exception e){}

		emailAliasInfo.addValue('email', 'test@box.com');

		Test.startTest();
		emailAliasInfo.parseMember('is_confirmed', 'true');
		emailAliasInfo.parseMember('email','testEmail@box.com');
		boxEmailAlias.getObjectType();

		boxEmailAlias.setInfo(null);
        Test.stopTest();

		System.assertEquals(true, emailAliasInfo.isConfirmed);
		System.assertEquals('testEmail@box.com', emailAliasInfo.email);
     }
}