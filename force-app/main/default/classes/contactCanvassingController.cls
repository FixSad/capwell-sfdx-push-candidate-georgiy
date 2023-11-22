public with sharing class contactCanvassingController {
  @AuraEnabled
  public static void saveCallLog(
    String whatId,
    String contactId,
    String status,
    String comments,
    String subject,
    Boolean followUp,
    Date folloUpDate
  ) {
    List<Task> tmpTask = new List<Task>();
    Task taskMain = new Task(
      Subject = subject,
      Status = status,
      Type = 'Call',
      TaskSubtype = 'Call',
      ActivityDate = Date.today(),
      Description = comments,
      WhoId = contactId,
      WhatId = whatId
    );
    tmpTask.add(taskMain);

    if (followUp && folloUpDate != null) {
      Task task = new Task(
        Subject = 'Follow up - ' + subject,
        Type = 'Call',
        TaskSubtype = 'Call',
        ActivityDate = folloUpDate,
        WhoId = contactId,
        WhatId = whatId
      );
      //task.Status = 'Not Started';
      tmpTask.add(task);
    }
    try {
      insert tmpTask;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
