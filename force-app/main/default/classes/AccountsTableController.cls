public with sharing class AccountsTableController {

    @AuraEnabled
	public static List<Account> getAccounts(List<Id> accountIdList, List<String> accountFieldsList) {
        String accountFieldsStr = String.join(accountFieldsList,',');
        List<Account> accList = new List<Account>();
        String accQuerry = 'SELECT ' + accountFieldsStr + 
                            ' FROM Account' + 
                            ' WHERE Id' +
                            ' IN :accountIdList' +
                            ' ORDER BY Name' +
                            ' ASC';

        try {
            accList = Database.query(accQuerry);
        } catch (Exception ex) {
            System.debug('Error while fetching the Accounts: ' + ex.getMessage());
        }
        return accList;
    } 
    
    @AuraEnabled
	public static void moveAccounts(Id clientListIdForInsertAs, List<Id> accountIdList, Id clientListIdForDeleteAs) {
        try {
            if (clientListIdForInsertAs == null || accountIdList == null 
                || accountIdList.isEmpty() || clientListIdForDeleteAs == null) {
                AuraHandledException ex = new AuraHandledException('Error');
                ex.setMessage('Error in the process of moving accounts.');
                throw ex;
            }
            List<Client_List_Association__c> clientAsListDelete = [
                SELECT  Id 
                FROM    Client_List_Association__c 
                WHERE   Client_List__c =: clientListIdForDeleteAs
                AND     Account__c IN: accountIdList
            ];
            if (!clientAsListDelete.isEmpty()) {
                delete clientAsListDelete;
            }
            List<Client_List_Association__c> clientAsList = [
                SELECT  Account__c
                FROM    Client_List_Association__c 
                WHERE   Client_List__c =: clientListIdForInsertAs 
            ];
            Map<Id, Id> accIdClientAsIdMap = new Map<Id,Id>();
            for (Client_List_Association__c clAs: clientAsList) {
                accIdClientAsIdMap.put(clAs.Account__c, clAs.Id);
            }
            List<Client_List_Association__c> clientAsInsert = new List<Client_List_Association__c>();
            for (Id accId: accountIdList) {
                if (accIdClientAsIdMap.get(accId) == null) {
                    clientAsInsert.add(
                        new Client_List_Association__c(
                        Account__c = accId,
                        Client_List__c = clientListIdForInsertAs
                    ));
                }
            }
            if (!clientAsInsert.isEmpty()) {
                insert clientAsInsert;
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
