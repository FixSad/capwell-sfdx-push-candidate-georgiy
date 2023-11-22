public with sharing class MarketController {
    @AuraEnabled(cacheable=true)
    public static List<Market_List__c> getMarkets() {
        return [SELECT Id, Name, Owner.Name, isOnly__c FROM Market_List__c WITH SECURITY_ENFORCED ORDER BY Owner.Name, Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<Market_List_Account__c> getAssociatedMarkets(String accountId) {
        if (!String.isBlank(accountId)) {
            return [SELECT Id, Market_List__c, Market_List__r.Name, Market_List__r.Owner.Name, Market_List__r.isOnly__c 
                        FROM Market_List_Account__c 
                        WHERE Account__c=:accountId WITH SECURITY_ENFORCED];
        } else {
            return null;
        }
    }

    @AuraEnabled(cacheable=false)
    public static void removeAssociation(String id) {
        Market_List_Account__c tmpRec = new Market_List_Account__c(Id=id);
        delete tmpRec;
    }
}