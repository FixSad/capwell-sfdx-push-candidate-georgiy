public without sharing class clientSearchController {
  @AuraEnabled(cacheable=false)
  public static List<accountTeamController.teamWrapper> searchClients(
    String[] skills,
    String mailShotId,
    Integer radius,
    Decimal latitude,
    Decimal longitude,
    String region,
    List<String> markets
  ) {
    List<accountTeamController.teamWrapper> accountsRes = new List<accountTeamController.teamWrapper>();
    if (!skills.isEmpty()) {
      String selectFields = 'SELECT Id, Name, ShippingCity';
      String whereClause = 'WHERE Id IN (SELECT Account__c FROM Skill_Association__c WHERE Skill__c IN :skills AND Account__c!=null)';
      if (!String.isBlank(region)) {
        whereClause += ' AND Account_Region__c = :region';
      }
      if (radius != null && latitude != null && longitude != null) {
        selectFields += ', DISTANCE(ShippingCity, GEOLOCATION(:latitude, :longitude), \'km\') Distance ';
        whereClause += ' AND DISTANCE(ShippingAddress, GEOLOCATION(:latitude, :longitude), \'km\') < :radius';
      }
      if (!markets.isEmpty()) {
        whereClause += ' AND Id IN (SELECT Account__c FROM Market_List_Account__c WHERE Market_List__c IN :markets)';
      }
      List<Account> resAccounts = (List<Account>) Database.query(
        selectFields + ' FROM Account ' + whereClause
      );
      if (!resAccounts.isEmpty()) {
        Set<Id> accountsIDs = new Set<Id>();
        for (Account tmpRec : resAccounts) {
          accountsIDs.add(tmpRec.Id);
        }

        List<Contact> accountConts = [
          SELECT
            Id,
            Name,
            Title,
            Phone,
            Email,
            Account_Team__c,
            Account_Team__r.Name,
            AccountId,
            (SELECT Id, Skill__c, Skill__r.Name FROM Skill_Associations__r)
          FROM Contact
          WHERE
            AccountId IN :accountsIDs
            AND RecordType.DeveloperName = 'Contact'
            AND Id NOT IN (
              SELECT Contact__c
              FROM Candidate_Mailshot__c
              WHERE Mailshot__c = :mailShotId
            )
            AND Email != NULL
          ORDER BY AccountId
        ];
        for (Account tmpAcc : resAccounts) {
          accountTeamController.teamWrapper tmpRec = new accountTeamController.teamWrapper();
          tmpRec.id = tmpAcc.Id;
          tmpRec.name = tmpAcc.Name;
          tmpRec.type = 'account';
          if (radius != null && latitude != null && longitude != null) {
            tmpRec.distance = (Decimal) tmpAcc.get('Distance');
            system.debug('Distance: ' + tmpRec.distance);
          }
          for (Contact tmpCont : accountConts) {
            if (tmpCont.AccountId == tmpAcc.Id) {
              accountTeamController.teamWrapper tmpChild = new accountTeamController.teamWrapper();
              tmpChild.id = tmpCont.Id;
              tmpChild.name = tmpCont.Name;
              tmpChild.title = tmpCont.Title;
              tmpChild.phone = tmpCont.Phone;
              tmpChild.email = tmpCont.Email;
              tmpChild.type = 'contact';
              tmpChild.team = tmpCont.Account_Team__r?.Name;
              if (!tmpCont.Skill_Associations__r.isEmpty()) {
                tmpChild.skills = new List<Skill_Association__c>(
                  tmpCont.Skill_Associations__r
                );
              }
              if (tmpRec.children == null) {
                tmpRec.children = new List<accountTeamController.teamWrapper>{
                  tmpChild
                };
              } else {
                tmpRec.children.add(tmpChild);
              }
            }
          }
          accountsRes.add(tmpRec);
        }
      }
    }
    return accountsRes;
  }

  @AuraEnabled(cacheable=false)
  public static string addClientsToMailshot(
    List<String> contacts,
    String mailshotId
  ) {
    system.debug('Contacts ' + contacts);
    if (
      contacts != null &&
      !contacts.isEmpty() &&
      String.isNotBlank(mailshotId)
    ) {
      List<Candidate_Mailshot__c> mailshotContacts = new List<Candidate_Mailshot__c>();
      for (String tmpRec : contacts) {
        if (String.isNotBlank(tmpRec)) {
          Candidate_Mailshot__c newCont = new Candidate_Mailshot__c();
          newCont.Contact__c = tmpRec;
          newCont.Mailshot__c = mailshotId;
          mailshotContacts.add(newCont);
        }
      }
      if (!mailshotContacts.isEmpty()) {
        insert mailshotContacts;
        return 'Success';
      }
      return 'No clients\' contacts with email address';
    }
    return 'No clients\' contacts provided';
  }
}
