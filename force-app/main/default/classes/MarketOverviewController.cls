public with sharing class MarketOverviewController {
  @AuraEnabled(Cacheable=true)
  public static Map<Id, String> getUsers() {
    Map<Id, String> userNameByIdMap = new Map<Id, String>();
    List<Client_List__c> clientList = [
      SELECT OwnerId, Owner.Name
      FROM Client_List__c
      WHERE OwnerId != :UserInfo.getUserId()
      ORDER BY Owner.Name
    ];
    for (Client_List__c cl : clientList) {
      userNameByIdMap.put(cl.OwnerId, cl.Owner.Name);
    }
    return userNameByIdMap;
  }

  @AuraEnabled(Cacheable=true)
  public static List<Account> getCanvasingAccounts(List<String> IDs) {
    if (IDs != null && !IDs.isEmpty()) {
      List<Account> tmpList = [
        SELECT Id, Name
        FROM Account
        WHERE id IN :IDs
        ORDER BY Name
      ];
      return tmpList;
    } else {
      return null;
    }
  }
}
