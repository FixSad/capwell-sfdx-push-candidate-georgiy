public with sharing class homeComponentsController {
  @AuraEnabled(cacheable=false)
  public static List<Lead> getLeads() {
    return [
      SELECT
        Id,
        Name,
        Company,
        Title,
        Phone,
        Email,
        Status,
        Type__c,
        CreatedDate
      FROM Lead
      WHERE isConverted = FALSE
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate DESC
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Opportunity> getJobs() {
    return [
      SELECT
        Id,
        Name,
        Account.Name,
        Job_Rating__c,
        Probability,
        Amount,
        StageName,
        CloseDate,
        recType__c
      FROM Opportunity
      WHERE IsClosed = FALSE
      WITH SECURITY_ENFORCED
      ORDER BY Job_Rating__c
      LIMIT 50
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Applicant__c> getApplicants() {
    return [
      SELECT
        Id,
        Candidate__r.Name,
        Candidate__r.Email,
        Candidate__r.Phone,
        Status__c,
        Job__r.Name,
        Job__r.Account.Name
      FROM Applicant__c
      WHERE Status__c != 'Hired'
      WITH SECURITY_ENFORCED
      LIMIT 50
    ];
  }
}
