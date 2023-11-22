public with sharing class MailshotController {
  @AuraEnabled(Cacheable=true)
  public static List<Task> getNextRecord(String recordId, Integer offset) {
    return [
      SELECT Id, WhoId, Shotlisted__c
      FROM Task
      WHERE Mailshot_Email__c = TRUE AND WhatId = :recordId
      LIMIT 1
      OFFSET :offset
    ];
  }

  @AuraEnabled(Cacheable=true)
  public static Integer getTotalRecords(String recordId) {
    return [
      SELECT COUNT()
      FROM Task
      WHERE WhatId = :recordId AND Mailshot_Email__c = TRUE
    ];
  }

  @AuraEnabled(Cacheable=false)
  public static void saveCallLog(
    String mailshotId,
    String contactId,
    String status,
    String comments,
    String subject
  ) {
    contactCanvassingController.saveCallLog(
      mailshotId,
      contactId,
      status,
      comments,
      subject,
      false,
      null
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<Contact> getShotlistCandidates(String recordId) {
    Set<Id> taskWhoIds = new Set<Id>();
    for (Task t : [
      SELECT WhoId
      FROM Task
      WHERE WhatId = :recordId AND Mailshot_Email__c = TRUE
    ]) {
      taskWhoIds.add(t.WhoId);
    }

    return [
      SELECT
        Id,
        Name,
        Email,
        Phone,
        (
          SELECT Id, Mailshot_Email__c, Shotlisted__c
          FROM Tasks
          WHERE WhatId = :recordId AND Mailshot_Email__c = TRUE
          LIMIT 1
        )
      FROM Contact
      WHERE Id IN :taskWhoIds
    ];
  }

  @AuraEnabled(Cacheable=false)
  public static void toggleShortListStatus(
    String mailshotId,
    String contactId,
    String value
  ) {
    try {
      Task task = [
        SELECT Id, Shotlisted__c
        FROM Task
        WHERE
          WhatId = :mailshotId
          AND WhoId = :contactId
          AND Mailshot_Email__c = TRUE
        LIMIT 1
      ];
      task.Shotlisted__c = (value == 'yes');
      update task;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @InvocableMethod(
    label='Fire Mailshot'
    description='Send out Emails to Mailshot List'
    category='Mailshot'
  )
  public static List<String> sendMailshot(List<Id> ids) {
    if (!ids.isEmpty()) {
      List<Mailshot__c> lstMailShots = [
        SELECT
          Id,
          Title__c,
          Type__c,
          Subject__c,
          HTML_Body__c,
          Job__c,
          Send_Standard__c,
          Candidate__c,
          Job__r.CAP_Number__c
        FROM Mailshot__c
        WHERE Id IN :ids
      ];
      if (lstMailShots != null && !lstMailShots.isEmpty()) {
        AggregateResult[] tmpList = [
          SELECT COUNT(id) allCandidates
          FROM Candidate_Mailshot__c
          WHERE Mailshot__c = :lstMailShots[0].Id AND Contact__r.Email != NULL
        ];
        Integer totalCandidates = (Integer) tmpList[0].get('allCandidates');
        if (totalCandidates > 0) {
          MailshotSender senderService = new MailshotSender();
          senderService.query =
            'SELECT Id, isSent__c, Contact__c, Contact__r.Email, Contact__r.Name, Mailshot__r.Job__r.CAP_Number__c FROM Candidate_Mailshot__c WHERE Contact__r.isBlocked__c=false AND Contact__r.Email!=null AND isSent__c=false AND Mailshot__c=\'' +
            lstMailShots[0].id +
            '\'';
          senderService.template = lstMailShots[0].HTML_Body__c;
          senderService.job = lstMailShots[0].Job__c;
          senderService.mailshot = lstMailShots[0].Id;
          senderService.subject =
            lstMailShots[0].Subject__c +
            (lstMailShots[0].Job__r?.CAP_Number__c != null
              ? ' - ' + lstMailShots[0].Job__r?.CAP_Number__c
              : '');
          senderService.type = lstMailShots[0].Type__c != null
            ? lstMailShots[0].Type__c
            : 'Job';
          if (senderService.type == 'Candidate') {
            List<id> ContentDocumentids = new List<id>();
            for (contentDocumentLink CDLink : [
              SELECT LinkedEntityid, ContentDocumentid
              FROM contentDocumentLink
              WHERE LinkedEntityid = :lstMailShots[0].Id
            ]) {
              ContentDocumentids.add(CDLink.ContentDocumentid);
            }
            List<contentversion> contentFiles = [
              SELECT title, PathOnClient, FileExtension, versiondata
              FROM contentversion
              WHERE ContentDocumentId IN :ContentDocumentids
            ];
            if (contentFiles != null && !contentFiles.isEmpty()) {
              senderService.body = contentFiles[0].versiondata;
              senderService.fileTitle = contentFiles[0].PathOnClient;
            }
          }
          Id batchInstanceId = Database.executeBatch(senderService, 50);
          return new List<String>{ 'Success' };
        }
        return new List<String>{ 'No Candidates in Mailshot' };
      }
      return new List<String>{ 'Mailshot not found' };
    }
    return new List<String>{ 'No Mailshot Selected' };
  }

  @AuraEnabled(cacheable=true)
  public static List<MailshotResult> mailShotCandidatesResults(
    String mailshot,
    String filter
  ) {
    if (!String.isBlank(mailshot)) {
      List<MailshotResult> tmpList = new List<MailshotResult>();
      List<Candidate_Mailshot__c> candidates = [
        SELECT
          Id,
          Contact__c,
          Contact__r.Email,
          Contact__r.Phone,
          Contact__r.Name,
          isCanvassed__c,
          isReplied__c
        FROM Candidate_Mailshot__c
        WHERE Mailshot__c = :mailshot
      ];
      List<EmailMessageRelation> messages = new List<EmailMessageRelation>();
      String emailQuery =
        'SELECT Id, EmailMessageId, EmailMessage.FirstOpenedDate, EmailMessage.IsBounced, EmailMessage.IsOpened, ' +
        'EmailMessage.LastOpenedDate, EmailMessage.MessageDate, RelationId, EmailMessage.ToAddress ' +
        'FROM EmailMessageRelation ' +
        'WHERE RelationType=\'ToAddress\' AND EmailMessage.RelatedToId=:mailshot';
      switch on filter {
        when 'opened' {
          emailQuery += ' AND EmailMessage.IsOpened=TRUE';
        }
        when 'bounced' {
          emailQuery += ' AND EmailMessage.IsBounced=TRUE';
        }
      }
      messages = (List<EmailMessageRelation>) Database.query(emailQuery);
      Set<Id> foundContacts = new Set<Id>();
      for (EmailMessageRelation tmpEmail : messages) {
        MailshotResult item = new MailshotResult();
        item.mailshotId = mailshot;
        item.firstOpen = tmpEmail.EmailMessage.FirstOpenedDate;
        item.lastOpen = tmpEmail.EmailMessage.LastOpenedDate;
        item.mailSent = tmpEmail.EmailMessage.MessageDate;
        item.sentTo = tmpEmail.EmailMessage.ToAddress;
        item.IsBounced = tmpEmail.EmailMessage.IsBounced;
        item.IsOpened = tmpEmail.EmailMessage.IsOpened;
        item.Id = tmpEmail.Id;
        for (Candidate_Mailshot__c tmpRec : candidates) {
          if (tmpEmail.RelationId == tmpRec.Contact__c) {
            item.contactId = tmpRec.Contact__c;
            item.contactURL = '/' + tmpRec.Contact__c;
            item.contactName = tmpRec.Contact__r.Name;
            item.contactEmail = tmpRec.Contact__r.Email;
            item.contactPhone = tmpRec.Contact__r.Phone;
            item.Id = item.Id == null ? tmpRec.Id : item.Id;
            item.mailshotRef = tmpRec.Id;
            item.IsCanvassed = tmpRec.isCanvassed__c;
            item.IsReplied = tmpRec.isReplied__c;
            if (filter == 'canvassed' && tmpRec.IsCanvassed__c) {
              tmpList.add(item);
            }
            foundContacts.add(tmpRec.Contact__c);
          }
        }
        if (filter != 'canvassed') {
          tmpList.add(item);
        }
      }
      if (filter == 'all') {
        for (Candidate_Mailshot__c tmpRec : candidates) {
          if (!messages.isEmpty() && !foundContacts.isEmpty()) {
            Boolean isFound = false;
            for (String foundRec : foundContacts) {
              system.debug(foundRec + ' - ' + tmpRec.Contact__c);
              if (tmpRec.Contact__c == foundRec) {
                isFound = true;
                break;
              }
            }
            if (!isFound) {
              MailshotResult item = new MailshotResult();
              item.mailshotId = mailshot;
              item.contactId = tmpRec.Contact__c;
              item.contactURL = '/' + tmpRec.Contact__c;
              item.contactName = tmpRec.Contact__r.Name;
              item.contactEmail = tmpRec.Contact__r.Email;
              item.contactPhone = tmpRec.Contact__r.Phone;
              item.mailshotRef = tmpRec.Id;
              tmpList.add(item);
            }
          } else {
            MailshotResult item = new MailshotResult();
            item.mailshotId = mailshot;
            item.contactId = tmpRec.Contact__c;
            item.contactURL = '/' + tmpRec.Contact__c;
            item.contactName = tmpRec.Contact__r.Name;
            item.contactEmail = tmpRec.Contact__r.Email;
            item.contactPhone = tmpRec.Contact__r.Phone;
            item.IsReplied = tmpRec.isReplied__c;
            item.mailshotRef = tmpRec.Id;
            tmpList.add(item);
          }
        }
      }
      return tmpList;
    } else {
      return null;
    }
  }

  public class MailshotResult {
    @AuraEnabled
    public String Id;
    @AuraEnabled
    public String mailshotId;
    @AuraEnabled
    public String mailshotRef;
    @AuraEnabled
    public String contactId;
    @AuraEnabled
    public String contactURL;
    @AuraEnabled
    public String contactName;
    @AuraEnabled
    public Date lastCV;
    @AuraEnabled
    public String contactPhone;
    @AuraEnabled
    public String contactEmail;
    @AuraEnabled
    public DateTime firstOpen;
    @AuraEnabled
    public DateTime lastOpen;
    @AuraEnabled
    public DateTime mailSent;
    @AuraEnabled
    public String sentTo;
    @AuraEnabled
    public Boolean IsBounced;
    @AuraEnabled
    public Boolean IsOpened;
    @AuraEnabled
    public Boolean IsCanvassed;
    @AuraEnabled
    public Boolean IsReplied;
  }
}
