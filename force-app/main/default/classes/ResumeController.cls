public with sharing class ResumeController {
    @AuraEnabled(cacheable=true)
    public static Resume__c findByContactId(String recordId){
        return [SELECT Id, Text__c, Contact__c FROM Resume__c WHERE Contact__c = :recordId LIMIT 1];
    }
}