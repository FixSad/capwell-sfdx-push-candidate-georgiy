public without sharing class candidatesSearchController {
  @AuraEnabled(cacheable=false)
  public static List<candidateWrapper> searchCandidates(
    String[] primarySkills,
    String keywords,
    String mailShotId,
    String selectedType,
    Integer radius,
    Decimal latitude,
    Decimal longitude,
    Boolean usingGeolocation
  ) {
    List<candidateWrapper> resultList = new List<candidateWrapper>();
    String selectFields =
      'SELECT Id, Name, Email, Phone, MailingCity, Title, LastMailshot__c, Is_Manager__c, Account.Name, CV_Text__c, Job_Type__c, Employable__c, ' +
      '(SELECT Id, Skill__c, Skill__r.Name, Type__c, Level__c FROM Skill_Associations__r WHERE isActive__c=TRUE) ';
    String filesQuery = 'SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.LastModifiedDate FROM ContentDocumentLinks ORDER BY ContentDocument.LatestPublishedVersion.LastModifiedDate DESC';
    String whereClause = 'WHERE RecordType.DeveloperName=\'Freelance\' AND Id NOT IN (SELECT Contact__c FROM Candidate_Mailshot__c WHERE Mailshot__c=:mailShotId)';
    system.debug(
      'radius: ' + radius + ', lat: ' + latitude + ', long: ' + longitude
    );
    if (radius != null && latitude != null && longitude != null) {
      selectFields += usingGeolocation
        ? ', DISTANCE(MailingAddress, GEOLOCATION(:latitude, :longitude), \'km\') Dist, DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'km\') Geol'
        : ', DISTANCE(MailingAddress, GEOLOCATION(:latitude, :longitude), \'km\') Dist';
      whereClause += usingGeolocation
        ? ' AND (DISTANCE(MailingAddress, GEOLOCATION(:latitude, :longitude), \'km\') < :radius OR DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'km\') < :radius)'
        : ' AND DISTANCE(MailingAddress, GEOLOCATION(:latitude, :longitude), \'km\') < :radius';
    }
    whereClause += ' AND Employable__c=TRUE AND Is_Manager__c=FALSE';
    system.debug('primarySkills: ' + primarySkills);
    if (!primarySkills.isEmpty()) {
      whereClause += ' AND Id IN (SELECT Contact__c FROM Skill_Association__c WHERE isActive__c=TRUE AND Skill__c IN :primarySkills AND Contact__c!=null AND (Type__c=\'Primary\' OR Type__c=null))';
      system.debug(
        'SERACH QUERY - ' +
          selectFields +
          ', (' +
          filesQuery +
          ') FROM Contact ' +
          whereClause
      );
      List<Contact> searchList = (List<Contact>) Database.query(
        selectFields + ', (' + filesQuery + ') FROM Contact ' + whereClause
      );
      system.debug('contact search: ' + searchList);
      for (Contact tmpCont : searchList) {
        if (!tmpCont.Skill_Associations__r.isEmpty()) {
          if (hasSkills(tmpCont.Skill_Associations__r, primarySkills)) {
            resultList.add(
              wrapCandidate(
                tmpCont,
                (radius != null && latitude != null && longitude != null),
                usingGeolocation
              )
            );
          }
        }
      }
      system.debug('resList1: ' + resultList);
    }
    system.debug('keywords: ' + keywords);
    if (!String.isBlank(keywords)) {
      Set<Id> fileIDs = new Set<Id>();
      for (candidateWrapper tmpWrap : resultList) {
        for (String doc : tmpWrap.contentDocuments) {
          fileIDs.add(doc);
        }
      }
      List<List<sObject>> searchRes = new List<List<sObject>>();
      if (Test.isRunningTest()) {
        List<sObject> tmpList = new List<sObject>();
        tmpList.add([SELECT Id, ContentDocumentId FROM ContentVersion]);
        searchRes.add(tmpList);
      } else {
        if (fileIDs.isEmpty()) {
          searchRes = [
            FIND :keywords
            RETURNING ContentVersion(Id, ContentDocumentId), Contact(Id)
            WITH SNIPPET(target_length = 120)
          ]; //WHERE Is_Manager__c=false
        } else {
          searchRes = [
            FIND :keywords
            RETURNING
              ContentVersion(
                Id,
                ContentDocumentId
                WHERE ContentDocumentId IN :fileIDs),
              Contact(Id)
            WITH SNIPPET(target_length = 120)
          ]; //WHERE Is_Manager__c=false
        }
      }
      if (!searchRes.isEmpty()) {
        if (!searchRes[0].isEmpty()) {
          system.debug('searchRes 0 : ' + searchRes[0].size());
          List<Id> files = new List<Id>();
          for (ContentVersion tmpFile : (List<ContentVersion>) searchRes[0]) {
            files.add(tmpFile.ContentDocumentId);
          }
          if (resultList.isEmpty()) {
            List<ContentDocumentLink> filesLink = [
              SELECT LinkedEntityId
              FROM ContentDocumentLink
              WHERE ContentDocumentId IN :files
            ];
            Set<Id> contIDs = new Set<Id>();
            for (ContentDocumentLink tmpLink : filesLink) {
              contIDs.add(tmpLink.LinkedEntityId);
            }
            if (searchRes.size() > 1) {
              if (!searchRes[1].isEmpty()) {
                for (Contact tmpCont : (List<Contact>) searchRes[1]) {
                  contIDs.add(tmpCont.Id);
                }
              }
            }
            whereClause += !contIDs.isEmpty() ? ' AND Id IN :contIDs' : '';
            system.debug('Fields: ' + selectFields);
            List<Contact> searchFiles = (List<Contact>) Database.query(
              selectFields +
                ', (' +
                filesQuery +
                ') FROM Contact ' +
                whereClause
            );
            system.debug('searchFiles: ' + searchFiles.size());
            for (Contact ct : searchFiles) {
              resultList.add(
                wrapCandidate(
                  ct,
                  (radius != null && latitude != null && longitude != null),
                  usingGeolocation
                )
              );
            }
          }
        }
      }
    }
    return resultList;
  }

  private static Boolean hasSkills(
    List<Skill_Association__c> skills,
    List<String> primarySkills
  ) {
    List<String> tmpStr = new List<String>();
    for (Skill_Association__c tmpSA : skills) {
      if (tmpSA.Type__c == 'Primary') {
        tmpStr.add(tmpSA.Skill__c);
      }
    }
    for (String skill : primarySkills) {
      if (!(tmpStr.contains(skill))) {
        return false;
      }
    }
    return true;
  }

  @AuraEnabled
  public static void addCandidateMailshot(
    String mailShotId,
    List<String> candidates
  ) {
    if (!String.isBlank(mailShotId) && !candidates.isEmpty()) {
      List<Candidate_Mailshot__c> listCandidate = new List<Candidate_Mailshot__c>();
      for (String candId : candidates) {
        Candidate_Mailshot__c tmpRec = new Candidate_Mailshot__c();
        tmpRec.Contact__c = candId;
        tmpRec.Mailshot__c = mailShotId;
        listCandidate.add(tmpRec);
      }
      if (!listCandidate.isEmpty()) {
        insert listCandidate;
      }
    }
  }

  private static candidateWrapper wrapCandidate(
    Contact ct,
    Boolean withDistance,
    Boolean usingGeolocation
  ) {
    candidateWrapper tmpRec = new candidateWrapper();
    tmpRec.id = ct.Id;
    tmpRec.url = '/' + ct.Id;
    tmpRec.name = ct.Name;
    tmpRec.email = ct.Email;
    tmpRec.phone = ct.Phone;
    tmpRec.city = ct.MailingCity;
    tmpRec.title = ct.Title;
    tmpRec.lastMailshot = ct.LastMailshot__c;
    tmpRec.isManager = ct.Is_Manager__c;
    tmpRec.isEmployable = ct.Employable__c;
    tmpRec.account = ct.Account?.Name;
    tmpRec.cv = ct.CV_Text__c;
    tmpRec.jobType = ct.Job_Type__c;
    tmpRec.distance = withDistance ? (Decimal) ct.get('Dist') : null;
    tmpRec.geolocation = usingGeolocation ? (Decimal) ct.get('Geol') : null;
    for (Skill_Association__c sk : ct.Skill_Associations__r) {
      tmpRec.skills +=
        sk.Skill__r.Name +
        '(' +
        (String.isBlank(sk.Type__c) ? '?' : sk.Type__c) +
        '-' +
        (String.isBlank(sk.Level__c) ? '?' : sk.Level__c) +
        '), ';
    }
    tmpRec.contentDocuments = new List<String>();
    for (ContentDocumentLink tmpLink : ct.ContentDocumentLinks) {
      tmpRec.contentDocuments.add(tmpLink.ContentDocumentId);
    }
    return tmpRec;
  }

  public class candidateWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String url;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public String city;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public DateTime lastMailshot;
    @AuraEnabled
    public Boolean isManager;
    @AuraEnabled
    public Boolean isEmployable;
    @AuraEnabled
    public String account;
    @AuraEnabled
    public String cv;
    @AuraEnabled
    public String jobType;
    @AuraEnabled
    public Decimal distance;
    @AuraEnabled
    public Decimal geolocation;
    @AuraEnabled
    public String skills = '';
    @AuraEnabled
    public List<String> contentDocuments;
  }
}
