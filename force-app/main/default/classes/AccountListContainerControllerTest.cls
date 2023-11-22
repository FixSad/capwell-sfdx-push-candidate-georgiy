@IsTest
private class AccountListContainerControllerTest {

    private static final String USER_NAME = 'Test User Name';

    @TestSetup
	private static void setup() {
        Account acc01 = new Account(Name = 'Test Account 01');
        Account acc02 = new Account(Name = 'Test Account 02');
        Account acc03 = new Account(Name = 'Test Account 03');
        insert new List<Account>{acc01, acc02, acc03};
        List<Profile> profileNameList = [
            SELECT  Id
            FROM    Profile
            WHERE   Name = 'System Administrator'
            LIMIT   1
        ];
        User testUser;
        if (!profileNameList.isEmpty()) {
            testUser = new User(
                FirstName = USER_NAME,
                LastName = 'TEST',
                ProfileId = profileNameList[0].Id,
                Alias = USER_NAME.length() > 5 ? USER_NAME.substring(0, 5) : USER_NAME + 'TST',
                Email = USER_NAME.replaceAll('[^a-zA-Z0-9+]', '') + '@gtstestclass.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                UserName = USER_NAME.replaceAll('[^a-zA-Z0-9+]', '') + Crypto.getRandomInteger() + '@gtstestclass.com'
            );
            insert testUser;
        }
        insert new Client_List__c(Name = 'Test Client List 01', OwnerId = testUser.Id);
    }

    @IsTest
    static void testGetAccountNames() {
        Map<Id,Account> accByIdMap = new Map<Id,Account>([SELECT Id FROM Account]);
        List<Id> accList = new List<Id>(accByIdMap.keySet());
        Test.startTest();
        List<Account> accListReturn = AccountListContainerController.getAccountNames(accList);
        Test.stopTest();
        System.assertEquals(accListReturn.size(), accByIdMap.keySet().size());
    }

    @IsTest
    static void testGetAccountDetail() {
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        List<String> fieldsApiNames =  new List<String>();
        for(String apiName : r.fields.getMap().keySet()){
            fieldsApiNames.add(apiName);
        }
        Account acc = [SELECT Name FROM Account LIMIT 1];
        Test.startTest();
        Account result = AccountListContainerController.getAccountDetail(acc.Id, fieldsApiNames);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(acc.Name, result.Name);
    }

    @IsTest
    static void testGetClientLists() {
        Id userId = [SELECT Id FROM User WHERE Name =: USER_NAME + ' TEST' LIMIT 1].Id;
        Client_List__c clientList = [SELECT Name FROM Client_List__c WHERE OwnerId =: userId LIMIT 1];
        Test.startTest();
        List<Client_List__c> result = AccountListContainerController.getClientLists(userId);
        Test.stopTest();
        System.assertEquals(false, result.isEmpty());
        System.assertEquals(1, result.size());
        System.assertEquals(clientList.Name, result[0].Name);
    }
}
