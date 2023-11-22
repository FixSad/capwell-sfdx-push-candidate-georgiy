@IsTest
public with sharing class MarketOverviewControllerTest {
  private static final String USER_NAME = 'Test User Name';

  @TestSetup
  private static void setup() {
    List<Profile> profileNameList = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User testUser;
    if (!profileNameList.isEmpty()) {
      testUser = new User(
        FirstName = USER_NAME,
        LastName = 'TEST',
        ProfileId = profileNameList[0].Id,
        Alias = USER_NAME.length() > 5
          ? USER_NAME.substring(0, 5)
          : USER_NAME + 'TST',
        Email = USER_NAME.replaceAll('[^a-zA-Z0-9+]', '') + '@gtstestclass.com',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/New_York',
        UserName = USER_NAME.replaceAll('[^a-zA-Z0-9+]', '') +
          Crypto.getRandomInteger() +
          '@gtstestclass.com'
      );
      insert testUser;
    }
    insert new Client_List__c(
      Name = 'Test Client List 01',
      OwnerId = testUser.Id
    );
  }

  @IsTest
  static void testGetUsers() {
    Test.startTest();
    Map<Id, String> result = MarketOverviewController.getUsers();
    Test.stopTest();
    System.assertNotEquals(null, result);
    Id userId = [SELECT Id FROM User WHERE Name = :USER_NAME + ' TEST' LIMIT 1]
    .Id;
    System.assertEquals(USER_NAME + ' TEST', result.get(userId));
  }

  @isTest
  static void testCanvasing() {
    Account acc = new Account();
    acc.Name = 'MarketOverviewControllerTest';
    insert acc;

    Test.startTest();
    List<Account> tmpList = MarketOverviewController.getCanvasingAccounts(
      new List<String>{ acc.Id }
    );
    Test.stopTest();

    System.assertEquals(1, tmpList.size());
    System.assertEquals('MarketOverviewControllerTest', tmpList[0].Name);
  }
}
