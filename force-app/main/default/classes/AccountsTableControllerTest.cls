@IsTest
private class AccountsTableControllerTest {

    private static final String USER_NAME = 'Test User Name';
    private static final String CLIENT_LIST_NAME = 'Test Client List';
    private static final String ACC_NAME = 'Test Account';

    @TestSetup
	private static void setup() {
        Account acc01 = new Account(Name = ACC_NAME + '01');
        Account acc02 = new Account(Name = ACC_NAME + '02');
        Account acc03 = new Account(Name = ACC_NAME + '03');
        insert new List<Account>{acc01, acc02, acc03};
        Client_List__c clientList01 = new Client_List__c(Name = CLIENT_LIST_NAME + '01');
        Client_List__c clientList02 = new Client_List__c(Name = CLIENT_LIST_NAME + '02');
        insert new List<Client_List__c>{clientList01, clientList02};
        Client_List_Association__c clientListAs01 = new Client_List_Association__c(Account__c = acc01.Id, Client_List__c = clientList01.Id);
        Client_List_Association__c clientListAs02 = new Client_List_Association__c(Account__c = acc02.Id, Client_List__c = clientList01.Id);
        Client_List_Association__c clientListAs03 = new Client_List_Association__c(Account__c = acc03.Id, Client_List__c = clientList01.Id);
        Client_List_Association__c clientListAs04 = new Client_List_Association__c(Account__c = acc02.Id, Client_List__c = clientList02.Id);
        insert new List<Client_List_Association__c>{clientListAs01, clientListAs02, clientListAs03, clientListAs04};
    }

    @IsTest
    static void testGetAccounts() {
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        List<String> fieldsApiNames =  new List<String>();
        for(String apiName : r.fields.getMap().keySet()){
            fieldsApiNames.add(apiName);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Name FROM Account]);
        Test.startTest();
        List<Account> result = AccountsTableController.getAccounts(new List<Id>(accMap.keySet()), fieldsApiNames);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(3, accMap.keySet().size());
    }

    @IsTest
    static void testMoveAccounts() {
        Client_List__c clientList01 = [SELECT Id FROM Client_List__c WHERE Name =: CLIENT_LIST_NAME + '01' LIMIT 1];
        Client_List__c clientList02 = [SELECT Id FROM Client_List__c WHERE Name =: CLIENT_LIST_NAME + '02' LIMIT 1];
        Map<Id,Account> accMap = new Map<Id, Account>([SELECT Id FROM Account]);
        Test.startTest();
        AccountsTableController.moveAccounts(clientList02.Id, new List<Id>(accMap.keySet()), clientList01.Id);
        Test.stopTest();
        Client_List_Association__c clientListAc01 = [SELECT Id FROM Client_List_Association__c WHERE Account__r.Name =: ACC_NAME + '01' AND Client_List__c =: clientList02.Id LIMIT 1];
        Client_List_Association__c clientListAc02 = [SELECT Id FROM Client_List_Association__c WHERE Account__r.Name =: ACC_NAME + '02' AND Client_List__c =: clientList02.Id LIMIT 1];
        Client_List_Association__c clientListAc03 = [SELECT Id FROM Client_List_Association__c WHERE Account__r.Name =: ACC_NAME + '03' AND Client_List__c =: clientList02.Id LIMIT 1];
        System.assertNotEquals(null, clientListAc01);
        System.assertNotEquals(null, clientListAc02);
        System.assertNotEquals(null, clientListAc03);
        List<Client_List_Association__c> clientListAc01List = [SELECT Id FROM Client_List_Association__c WHERE Account__r.Name =: ACC_NAME + '01' AND Client_List__c =: clientList01.Id];
        List<Client_List_Association__c> clientListAc02List = [SELECT Id FROM Client_List_Association__c WHERE Account__r.Name =: ACC_NAME + '02' AND Client_List__c =: clientList01.Id];
        List<Client_List_Association__c> clientListAc03List = [SELECT Id FROM Client_List_Association__c WHERE Account__r.Name =: ACC_NAME + '03' AND Client_List__c =: clientList01.Id];
        System.assertEquals(0, clientListAc01List.size());
        System.assertEquals(0, clientListAc02List.size());
        System.assertEquals(0, clientListAc03List.size());
    }

    @IsTest
    static void testMoveAccountsNegative() {
        Client_List__c clientList01 = [SELECT Id FROM Client_List__c WHERE Name =: CLIENT_LIST_NAME + '01' LIMIT 1];
        Client_List__c clientList02 = [SELECT Id FROM Client_List__c WHERE Name =: CLIENT_LIST_NAME + '02' LIMIT 1];
        try {
            Test.startTest();
            AccountsTableController.moveAccounts(clientList02.Id, new List<Id>(), clientList01.Id);
            Test.stopTest();
        } catch (Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
            System.assert(ex != null);
        }
    }
}