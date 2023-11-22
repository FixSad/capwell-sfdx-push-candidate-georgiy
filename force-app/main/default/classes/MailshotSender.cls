public class MailshotSender implements Database.Batchable<sObject> {
  public String query;
  public String template;
  public String subject;
  public String mailshot;
  public String job;
  public String type;
  public Blob body;
  public String fileTitle;
  public Messaging.SingleEmailMessage demoEmail;

  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
    for (Candidate_Mailshot__c cont : (List<Candidate_Mailshot__c>) scope) {
      Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
      singleMail.setTargetObjectId(cont.Contact__c);
      singleMail.setSubject(subject);
      singleMail.setHtmlBody(
        Messaging.renderEmailTemplate(
              cont.Contact__c,
              job,
              new List<String>{ template }
            )[0]
            .getMergedBody() +
          ' \n [Ref::' +
          cont.Id +
          ']'
      );
      singleMail.setPlainTextBody(template);
      singleMail.setToAddresses(new List<String>{ cont.Contact__r.Email });
      singleMail.setSaveAsActivity(true);
      singleMail.setWhatId(mailshot);
      msgListToBeSend.add(singleMail);
      if (demoEmail == null) {
        demoEmail = singleMail;
      }
      if (type == 'Candidate') {
        if (body != null && String.isNotEmpty(fileTitle)) {
          Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
          efa1.setFileName(fileTitle);
          efa1.setBody(body);
          singleMail.setFileAttachments(
            new List<Messaging.Emailfileattachment>{ efa1 }
          );
          system.debug('Attached');
        }
      }
      cont.isSent__c = true;
    }
    if (!msgListToBeSend.isEmpty()) {
      Messaging.sendEmail(msgListToBeSend, false);
      if (!((List<Candidate_Mailshot__c>) scope).isEmpty()) {
        update scope;
      }
    }
  }

  public void finish(Database.BatchableContext BC) {
    CustomNotificationType notificationType = [
      SELECT Id, DeveloperName
      FROM CustomNotificationType
      WHERE DeveloperName = 'Mailshot_Completed'
    ];
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle('Mailshot Completed');
    notification.setBody('Mailshot ' + subject + ' is completed!');
    notification.setNotificationTypeId(notificationType.Id);
    notification.setTargetId(mailshot);
    try {
      notification.send(new Set<String>{ UserInfo.getUserId() });
    } catch (Exception e) {
      System.debug('Problem sending notification: ' + e.getMessage());
    }
    if (demoEmail != null) {
      demoEmail.setTargetObjectId(null);
      demoEmail.setSaveAsActivity(false);
      demoEmail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
      try {
        Messaging.sendEmail(
          new List<Messaging.SingleEmailMessage>{ demoEmail },
          false
        );
      } catch (Exception e) {
        System.debug('Problem sending demo email: ' + e.getMessage());
      }
    }
  }
}
