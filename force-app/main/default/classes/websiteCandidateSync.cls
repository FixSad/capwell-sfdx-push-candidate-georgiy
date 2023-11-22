@RestResource(urlMapping='/candidates/sync/*')
/**
POST REQUEST EXAMPLE:
URL: /services/apexrest/candidates/sync/*
BODY:
{
    “dateFrom” : “2020-10-01 00:00:00" (YYYY-MM-DD HH:MM:SS),
    "limitNum" : "10",
    "lastId" : "0060900000BQGDOAA5" (WHERE ID>"0060900000BQGDOAA5")
}
*/

/*
    Name - Name
    KvK - KVK_Nummer__c
    BTW - BTW_Number__c
    Address - BillingAddress

    Bank Name - Bank_Name__c
    Bank Country - NL
    IBAN / Account - AccountNumber
*/

global without sharing class websiteCandidateSync {
  @HttpPost
  global static List<Contact> getCandidates() {
    String query =
      'SELECT Id, FirstName, LastName, Name, Email, Education__c, Studierichting__c, Field_Of_Study__c, Geolocation__Latitude__s, Geolocation__Longitude__s, MailingLatitude, MailingLongitude, ' +
      'Birthdate, HomePhone, Phone, MobilePhone, LinkedIn_Profile__c, Title, Description, MailingCity, MailingStreet, MailingPostalCode, Portal_Active__c, Portal_ID__c, ' +
      'AccountId, Account.Name, Account.KVK_Nummer__c, Account.BTW_Number__c, Account.Bank_Name__c, Account.AccountNumber, Account.LegacyOpaID__c, ' +
      'Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet, ' +
      '(SELECT id, Contact__c, Type__c, Level__c, Skill__r.Name, Skill__r.LegacySkillId__c, Skill__r.Alias__c, ' +
      'LegacyObjectID__c, LegacyOpaID__c, LegacySkillID__c ' +
      'FROM Skill_Associations__r WHERE isActive__c = true) ' +
      'FROM Contact ' +
      'WHERE ((RecordType.DeveloperName=\'Freelance\' OR RecordType.DeveloperName=\'Permanent\') OR (Employable__c=true AND Is_Manager__c=false)) ';
    String requestQuery = RestContext.request != null
      ? (RestContext.request.requestBody != null
          ? RestContext.request.requestBody.toString()
          : '')
      : '';
    if (!String.isBlank(requestQuery)) {
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        requestQuery
      );
      String dateFrom = RestContext.request != null
        ? (String) params.get('dateFrom')
        : '';
      if (!String.isBlank(dateFrom)) {
        try {
          DateTime modifyFilter = DateTime.valueOf(dateFrom); //(Datetime)JSON.deserialize(dateFrom, DateTime.class);//"2018-10-01T00:00:00Z"
        } catch (Exception e) {
          system.debug('Error during date pasing: ' + e.getMessage());
        }
        query += query.contains('WHERE')
          ? ' AND LastModifiedDate>=:modifyFilter'
          : ' WHERE LastModifiedDate>=:modifyFilter';
      }
      String lastId = RestContext.request != null
        ? (String) params.get('lastId')
        : '';
      query += (!String.isBlank(lastId))
        ? (query.contains('WHERE') ? ' AND Id>:lastId' : ' WHERE Id>:lastId')
        : '';
      query += ' ORDER BY Id ASC';
      String limitNum = RestContext.request != null
        ? (String) params.get('limitNum')
        : '';
      query += !String.isBlank(limitNum)
        ? ' LIMIT ' + Integer.valueOf(limitNum)
        : '';
    }
    List<Contact> tmpList = new List<Contact>();
    try {
      tmpList = Database.query(query);
    } catch (Exception e) {
      system.debug('Error during job sync: ' + e.getMessage());
    }
    return tmpList;
  }

  @HttpGet
  global static Contact getCandidate() {
    RestRequest req = RestContext.request;
    String contactID = req.params.get('candidate_id');
    if (String.isNotBlank(contactID)) {
      List<Contact> contacts = [
        SELECT
          Id,
          FirstName,
          LastName,
          Name,
          Email,
          Education__c,
          Studierichting__c,
          Field_Of_Study__c,
          Geolocation__Latitude__s,
          Geolocation__Longitude__s,
          MailingLatitude,
          MailingLongitude,
          Birthdate,
          HomePhone,
          Phone,
          MobilePhone,
          LinkedIn_Profile__c,
          Title,
          Description,
          MailingCity,
          MailingStreet,
          MailingPostalCode,
          Portal_Active__c,
          Portal_ID__c,
          AccountId,
          Account.Name,
          Account.KVK_Nummer__c,
          Account.BTW_Number__c,
          Account.Bank_Name__c,
          Account.AccountNumber,
          Account.LegacyOpaID__c,
          Account.BillingCity,
          Account.BillingCountry,
          Account.BillingPostalCode,
          Account.BillingState,
          Account.BillingStreet,
          (
            SELECT
              id,
              Name,
              reiskosten__c,
              project_functie__c,
              Account__c,
              Account__r.Name,
              Manager__c,
              Manager__r.Name,
              Manager__r.Email,
              Status__c,
              Billing_period__c
            FROM CandidateProjects__r
            WHERE Status__c != 'Draft'
          ),
          (
            SELECT
              id,
              Contact__c,
              Type__c,
              Level__c,
              Skill__r.Name,
              Skill__r.LegacySkillId__c,
              Skill__r.Alias__c,
              LegacyObjectID__c,
              LegacyOpaID__c,
              LegacySkillID__c
            FROM Skill_Associations__r
            WHERE isActive__c = TRUE
          )
        FROM Contact
        WHERE Id = :contactID
      ];
      return contacts.isEmpty() ? null : contacts[0];
    } else {
      return null;
    }
  }
}
