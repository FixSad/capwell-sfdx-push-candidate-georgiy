@isTest
public with sharing class accountTeamControllerTest {

    private static final String ACC_NAME = 'Test Acc';
    private static final String CON_NAME = 'Test Contact';

    @TestSetup
	private static void setup() {
        Account acc01 = new Account(Name = ACC_NAME, IT_Teams__c = 'TI; HR');
        Account acc02 = new Account(Name = ACC_NAME + '02');
        insert new List<Account>{acc01, acc02};
        Account_Team__c accTeam = new Account_Team__c(Name = 'Test Account Team', Account__c = acc02.Id);
        insert accTeam;
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Contact con01 = new Contact(
            LastName = CON_NAME,
            Email = 'testContact01@gmail.com',
            RecordTypeId = conRecordTypeId,
            AccountId = acc02.Id
        );
        Contact con02 = new Contact(
            LastName = CON_NAME + '02',
            Email = 'testContact02@gmail.com',
            RecordTypeId = conRecordTypeId,
            AccountId = acc02.Id,
            Account_Team__c = accTeam.Id
        );
        insert new List<Contact>{con01, con02};
    }

    @IsTest
    static void testAutoCreateTeamsTrigger() {
        Id accId = [SELECT Id FROM Account WHERE Name =: ACC_NAME].Id;
        List<Account_Team__c> accTeamList = [SELECT Id FROM Account_Team__c WHERE Account__c =: accId];
        System.assertEquals(2, accTeamList.size());
    }

    @IsTest
    static void testGetAccountTeam() {
        Id accId = [SELECT Id FROM Account WHERE Name =: ACC_NAME + '02'].Id;
        Test.startTest();
        List<accountTeamController.teamWrapper> teamWrapperList = accountTeamController.getAccountTeam(accId);
        Test.stopTest();
        System.assertNotEquals(0, teamWrapperList.size());
        System.assertEquals(2, teamWrapperList.size());
        Integer countChildren = 0;
        for(accountTeamController.teamWrapper tw: teamWrapperList) {
            if(tw.children != null && !tw.children.isEmpty()) {
                countChildren++;
            }
        }
        System.assertEquals(1, countChildren);
    }

    
    @IsTest
    static void testGetTeams() {
        Id accId = [SELECT Id FROM Account WHERE Name =: ACC_NAME].Id;
        Test.startTest();
        List<Account_Team__c> accTeam = accountTeamController.getTeams(accId);
        Test.stopTest();
        System.assertEquals(2, accTeam.size());
    }

    @IsTest
    static void testLogContactCall() {
        Id accId = [SELECT Id FROM Account WHERE Name =: ACC_NAME].Id;
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        accountTeamController.logContactCall('subj', 'description', 'callDisposition', contactId, accId);
        Test.stopTest();
        List<Task> taskList = [SELECT Id FROM Task];
        System.assertEquals(1, taskList.size());
    }
    
    @IsTest
    static void testGetContactAccounts() {
        Id contactId = [SELECT Id FROM Contact WHERE Name =: CON_NAME LIMIT 1].Id;
        Test.startTest();
        List<AccountContactRelation> accConRelList = accountTeamController.getContactAccounts(contactId);
        Test.stopTest();
        System.assertEquals(1, accConRelList.size());
    }

}
