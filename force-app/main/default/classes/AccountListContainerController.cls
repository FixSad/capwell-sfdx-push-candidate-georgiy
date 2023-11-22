public with sharing class AccountListContainerController {
   
    @AuraEnabled
	public static List<Account> getAccountNames(List<Id> accountIdList) {
        return [
            SELECT  Name 
            FROM    Account 
            WHERE   Id IN :accountIdList
            ORDER BY Name ASC
        ];
    }

    @AuraEnabled
	public static Account getAccountDetail(Id accountId, List<String> accountFieldsList) {
        String accountFieldsStr = String.join(accountFieldsList,',');
        Account acc = new Account();
        String accQuerry = 'SELECT ' + accountFieldsStr + 
                            ' FROM Account' + 
                            ' WHERE Id' +
                            ' =: accountId' +
                            ' ORDER BY Name' +
                            ' ASC';

        try {
            acc = Database.query(accQuerry);
        } catch (Exception ex) {
            System.debug('Error while fetching the Accounts: ' + ex.getMessage());
        }
        return acc;
    }

    @AuraEnabled
	public static List<Client_List__c> getClientLists(Id userId) {
        return [
            SELECT  OwnerId, 
                    Name,
                        (SELECT Account__c
                        FROM Client_List_Associations__r
                        ORDER BY Account__r.Name ASC)
            FROM     Client_List__c 
            WHERE    OwnerId = :userId
            ORDER BY Name ASC
        ];
    }
    
}
