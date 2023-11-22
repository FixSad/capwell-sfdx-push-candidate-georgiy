public with sharing class candidateReviewController {
  public static List<Database.upsertResult> createReviewRequest(
    List<websitePushCandidates.candidateWrapper> candidates
  ) {
    List<Database.upsertResult> result = new List<Database.upsertResult>();
    if (candidates != null && !candidates.isEmpty()) {
      List<PortalRequest__c> newList = new List<PortalRequest__c>();
      for (websitePushCandidates.candidateWrapper tmpRec : candidates) {
        if (
          String.isNotBlank(tmpRec.portal_id) ||
          tmpRec.candidate_type == 'Website'
        ) {
          PortalRequest__c newRec = new PortalRequest__c();
          newRec.Candidate__c = String.isNotBlank(tmpRec.sf_id)
            ? tmpRec.sf_id
            : null;
          newRec.City__c = tmpRec.city;
          newRec.Country__c = tmpRec.country;
          newRec.Date_of_Birth__c = tmpRec.date_of_birth;
          newRec.DisplayName__c = tmpRec.display_name;
          newRec.FirstName__c = tmpRec.first_name;
          newRec.HouseNumber__c = tmpRec.house_number;
          //newRec.Inzet__c = tmpRec.inzet; ?
          newRec.LastName__c = tmpRec.Last_name;
          newRec.LinkedIn_Profile__c = tmpRec.linkedin_profile;
          newRec.Location__c = tmpRec.location;
          newRec.PhoneNumber__c = tmpRec.phone_number;
          newRec.Portal_ID__c = tmpRec.portal_id;
          newRec.PostalCode__c = tmpRec.postal_code;
          newRec.Radius__c = tmpRec.radius;
          if (tmpRec.skills != null && !tmpRec.skills.isEmpty()) {
            for (websitePushCandidates.skillWrapper tmpSkill : tmpRec.skills) {
              newRec.Skills__c += tmpSkill.sf_id + ',';
            }
          }
          newRec.Start_from__c = tmpRec.start_from_date;
          newRec.Street__c = tmpRec.street;
          newRec.Title__c = (tmpRec.candidate_title != null &&
            !tmpRec.candidate_title.isEmpty())
            ? String.join(tmpRec.candidate_title, ',')
            : null;
          newRec.company_name__c = tmpRec.company_name;
          newRec.Account__c = String.isNotBlank(tmpRec.sf_company_id)
            ? tmpRec.sf_company_id
            : null;
          newRec.kvk_number__c = tmpRec.kvk_number;
          newRec.btw_number__c = tmpRec.btw_number;
          newRec.Company_Street__c =
            tmpRec.company_address +
            ' ' +
            tmpRec.company_house_no;
          newRec.company_city__c = tmpRec.company_city;
          newRec.company_country__c = tmpRec.company_country;
          newRec.company_postal_code__c = tmpRec.company_postal_code;
          newRec.bank_name__c = tmpRec.bank_name;
          newRec.bank_country__c = tmpRec.bank_country;
          newRec.bank_account__c = tmpRec.bank_account_number;
          newRec.description__c = tmpRec.about_description;
          newRec.type__c = tmpRec.candidate_type;
          newList.add(newRec);
        }
      }
      if (!newList.isEmpty()) {
        result = Database.upsert(newList, PortalRequest__c.Portal_ID__c, false);
      }
    }
    return result;
  }

  @AuraEnabled(cacheable=true)
  public static List<PortalRequest__c> getAllRequests() {
    return [
      SELECT Id, Name, Icon__c
      FROM PortalRequest__c
      WHERE Status__c = 'New'
    ];
  }

  @AuraEnabled(cacheable=true)
  public static PortalRequest__c getRequestMergeData(String requestId) {
    return [
      SELECT
        Id,
        Name,
        FirstName__c,
        LastName__c,
        AvailableNow__c,
        Candidate__c,
        City__c,
        Country__c,
        PostalCode__c,
        HouseNumber__c,
        Street__c,
        Date_of_Birth__c,
        DisplayName__c,
        Inzet__c,
        LinkedIn_Profile__c,
        Location__c,
        PhoneNumber__c,
        Portal_ID__c,
        Project_Duration__c,
        Radius__c,
        Start_from__c,
        Start_until__c,
        Title__c,
        Company_name__c,
        Kvk_number__c,
        BTW_Number__c,
        Company_Street__c,
        Company_city__c,
        Company_country__c
        Company_postal_code__c,
        Bank_name__c,
        Bank_country__c,
        Bank_account__c,
        Description__c,
        Type__c,
        Candidate__r.Description,
        Candidate__r.FirstName,
        Candidate__r.LastName,
        Candidate__r.MailingCity,
        Candidate__r.MailingCountry,
        Candidate__r.MailingPostalCode,
        Candidate__r.MailingStreet,
        Candidate__r.Birthdate,
        Candidate__r.LinkedIn_Profile__c,
        Candidate__r.MobilePhone,
        Candidate__r.Available_Date__c,
        Candidate__r.Title,
        Candidate__r.Portal_ID__c,
        Account__r.Name,
        Account__r.KVK_Nummer__c,
        Account__r.BTW_Number__c,
        Account__r.BillingCity,
        Account__r.BillingCountry,
        Account__r.BillingPostalCode,
        Account__r.BillingStreet,
        Account__r.Bank_Name__c,
        Account__r.AccountNumber,
        Account__r.Bank_Country__c,
        Account__r.Description,
        Account__r.Type
      FROM PortalRequest__c
      WHERE ID = :requestId
    ];
  }

  @AuraEnabled
  public static void rejectRequest(String requestId) {
    List<PortalRequest__c> request = [
      SELECT Id, Status__c
      FROM PortalRequest__c
      WHERE Id = :requestId
    ];
    request[0].Status__c = 'Rejected';
    update request;
  }

  @AuraEnabled
  public static void approveRequest(String requestId) {
    PortalRequest__c request = getRequestMergeData(requestId);
    request.Status__c = 'Approved';
    Contact contact = [
      SELECT
        Id,
        Name,
        FirstName,
        LastName,
        Birthdate,
        MobilePhone,
        LinkedIn_Profile__c,
        MailingStreet,
        MailingPostalCode,
        MailingCity,
        MailingCountry,
        Portal_ID__c,
        Available_Date__c,
        Title
      FROM Contact
      WHERE Id = :request.Candidate__c
      LIMIT 1
    ];

    contact.Id = request.Candidate__c;
    contact.FirstName = request.FirstName__c;
    contact.LastName = request.LastName__c;
    contact.Birthdate = request.Date_of_Birth__c;
    contact.MobilePhone = request.PhoneNumber__c;
    contact.LinkedIn_Profile__c = request.LinkedIn_Profile__c;
    contact.MailingStreet = request.Street__c;
    contact.MailingCountry = request.Country__c;
    contact.Portal_ID__c = request.Portal_ID__c;
    contact.Available_Date__c = request.Start_from__c;
    update contact;

    Account account = [
      SELECT
        Name,
        KVK_Nummer__c,
        BTW_Number__c,
        BillingCity,
        BillingCountry,
        BillingPostalCode,
        BillingStreet,
        Bank_Name__c,
        AccountNumber,
        Bank_Country__c,
        Description,
        Type
      FROM Account
      WHERE Id = :request.Account__c
      LIMIT 1
    ];

    account.Name = request.Name;
    account.KVK_Nummer__c = request.KvK_Number__c;
    account.BTW_Number__c = request.BTW_Number__c;
    account.BillingCity = request.Company_city__c;
    account.BillingCountry = request.Company_country__c;
    account.BillingPostalCode = request.Company_postal_code__c;
    account.BillingStreet = request.Company_Street__c;
    account.Bank_Name__c = request.Bank_name__c;
    //account.AccountNumber = 
    account.Bank_Country__c = request.Bank_country__c;
    account.Description = request.Description__c;
    account.Type = request.Type__c;
    
    update account;
  }
}
