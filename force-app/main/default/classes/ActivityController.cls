public without sharing class ActivityController {
  @AuraEnabled
  public static List<ActivityController.ActivityItem> getActivities(
    String whatOrWhoId
  ) {
    List<ActivityController.ActivityItem> result = new List<ActivityController.ActivityItem>();
    if (String.isBlank(whatOrWhoId)) {
      return result;
    }
    Set<Id> whoOrWhatIds = new Set<Id>{ whatOrWhoId };
    if (whatOrWhoId.startsWith('001')) {
      List<Contact> accConts = [
        SELECT Id
        FROM Contact
        WHERE AccountId = :whatOrWhoId
      ];
      if (accConts != null) {
        for (Contact tmpRec : accConts) {
          whoOrWhatIds.add(tmpRec.Id);
        }
      }
    }
    List<Task> tmpRes = [
      SELECT
        Id,
        ActivityDate,
        CompletedDateTime,
        CallType,
        TaskSubtype,
        Subject,
        Description,
        Status,
        WhatId,
        What.Name,
        WhoId,
        Who.Name,
        OwnerId,
        Owner.Alias
      FROM Task
      WHERE WhoId IN :whoOrWhatIds OR WhatId IN :whoOrWhatIds
      ORDER BY ActivityDate DESC
    ];
    result.addAll(mapActivities(tmpRes));
    if (whatOrWhoId.startsWith('001')) {
      result.addAll(getAccountActivities(whoOrWhatIds));
    } else {
      result.addAll(getContactActivities(whoOrWhatIds));
    }
    return result;
  }

  private static List<ActivityItem> getAccountActivities(Set<Id> accIds) {
    List<opa_recruiter_log__c> legacyLogs = [
      SELECT
        Id,
        Account__c,
        Account__r.Name,
        Contact__c,
        Contact__r.Name,
        overall_type__c,
        process_type__c,
        ref_type__c,
        text__c,
        User__c,
        User__r.Alias,
        CreatedDate__c
      FROM opa_recruiter_log__c
      WHERE Account__c IN :accIds OR Contact__c IN :accIds
      ORDER BY CreatedDate__c DESC
    ];
    return mapLegacyActivities(legacyLogs);
  }

  private static List<ActivityItem> getContactActivities(Set<Id> contIds) {
    List<opa_candidate_log__c> legacyLogs = [
      SELECT
        Id,
        Account__c,
        Account__r.Name,
        Contact__c,
        Contact__r.Name,
        overall_type__c,
        process_type__c,
        ref_type__c,
        text__c,
        User__c,
        User__r.Alias,
        CreatedDate__c
      FROM opa_candidate_log__c
      WHERE Contact__c IN :contIds
      ORDER BY CreatedDate__c DESC
    ];
    return mapLegacyActivities(legacyLogs);
  }

  @AuraEnabled
  public static String recordNewActivity(Task_Wrapper__c newActivity) {
    if (newActivity != null) {
      List<Task> newTasks = new List<Task>{ mapActivityToTask(newActivity) };
      if (newTasks != null && !newTasks.isEmpty()) {
        if (newActivity.Follow_up__c) {
          newTasks.add(createFollowup(newActivity));
        }
        insert newTasks;
        return 'success';
      }
    }
    return 'error';
  }

  private static Task createFollowup(Task_Wrapper__c rec) {
    if (rec != null) {
      Task tmp = new Task();
      tmp.Subject = rec.Type__c + ' - ' + rec.SubType__c;
      tmp.ActivityDate = rec.DueDate__c;
      tmp.Description = rec.Follow_up_description__c;
      tmp.WhatId = rec.Account__c;
      tmp.WhoId = rec.Contact__c;
      tmp.TaskSubtype = 'Call';
      tmp.IsReminderSet = true;
      tmp.Type = 'Call';
      return tmp;
    }
    return null;
  }

  private static Task mapActivityToTask(Task_Wrapper__c rec) {
    if (rec != null) {
      Task tmp = new Task();
      tmp.Subject = rec.Type__c + ' - ' + rec.SubType__c;
      tmp.ActivityDate = Date.today();
      tmp.Description = rec.Description__c;
      tmp.Status = 'Completed';
      tmp.WhatId = rec.Account__c;
      tmp.WhoId = rec.Contact__c;
      tmp.TaskSubtype = 'Call';
      tmp.Type = 'Call';
      return tmp;
    }
    return null;
  }

  private static List<ActivityItem> mapLegacyActivities(
    List<opa_candidate_log__c> logs
  ) {
    List<ActivityItem> result = new List<ActivityItem>();
    if (logs != null) {
      for (opa_candidate_log__c tmpRec : logs) {
        ActivityItem item = new ActivityItem();
        item.activityDate = tmpRec.CreatedDate__c;
        item.activityFormated = item.activityDate != null
          ? item.activityDate.format()
          : 'No Date';
        item.id = tmpRec.Id;
        item.idURL = '/' + tmpRec.Id;
        item.description = tmpRec.text__c;
        item.status = 'Completed';
        item.whoId = tmpRec.Contact__c;
        item.whoURL = String.isNotBlank(tmpRec.Contact__c)
          ? '/' + tmpRec.Contact__c
          : '';
        item.whoName = String.isNotBlank(tmpRec.Contact__r?.Name)
          ? tmpRec.Contact__r?.Name
          : '';
        item.subType = tmpRec.process_type__c;
        item.subject = tmpRec.overall_type__c;
        item.whatId = tmpRec.Account__c;
        item.whatURL = '/' + tmpRec.Account__c;
        item.whatName = tmpRec.Account__r?.Name;
        item.ownerId = tmpRec.User__c;
        item.ownerURL = tmpRec.User__c != null ? '/' + tmpRec.User__c : '';
        item.ownerName = tmpRec.User__c != null ? tmpRec.User__r.Alias : '';
        result.add(item);
      }
    }
    return result;
  }

  private static List<ActivityItem> mapLegacyActivities(
    List<opa_recruiter_log__c> logs
  ) {
    List<ActivityItem> result = new List<ActivityItem>();
    if (logs != null) {
      for (opa_recruiter_log__c tmpRec : logs) {
        ActivityItem item = new ActivityItem();
        item.activityDate = tmpRec.CreatedDate__c;
        item.activityFormated = item.activityDate != null
          ? item.activityDate.format()
          : 'No Date';
        item.id = tmpRec.Id;
        item.idURL = '/' + tmpRec.Id;
        item.description = tmpRec.text__c;
        item.status = 'Completed';
        item.whoId = tmpRec.Contact__c;
        item.whoURL = String.isNotBlank(tmpRec.Contact__c)
          ? '/' + tmpRec.Contact__c
          : '';
        item.whoName = String.isNotBlank(tmpRec.Contact__r?.Name)
          ? tmpRec.Contact__r?.Name
          : '';
        item.subType = tmpRec.process_type__c;
        item.subject = tmpRec.overall_type__c;
        item.whatId = tmpRec.Account__c;
        item.whatURL = '/' + tmpRec.Account__c;
        item.whatName = tmpRec.Account__r?.Name;
        item.ownerId = tmpRec.User__c;
        item.ownerURL = '/' + tmpRec.User__c;
        item.ownerName = tmpRec.User__r?.Alias;
        result.add(item);
      }
    }
    return result;
  }

  private static List<ActivityItem> mapActivities(List<Task> tasks) {
    List<ActivityItem> result = new List<ActivityItem>();
    if (tasks != null) {
      for (Task tmpRec : tasks) {
        ActivityItem item = new ActivityItem();
        item.activityDate = tmpRec.CompletedDateTime != null
          ? tmpRec.CompletedDateTime
          : tmpRec.ActivityDate;
        item.activityFormated = item.activityDate != null
          ? item.activityDate.format()
          : null;
        item.id = tmpRec.Id;
        item.idURL = '/' + tmpRec.Id;
        item.description = tmpRec.Description;
        item.status = tmpRec.Status;
        item.subject = tmpRec.Subject;
        item.subType = tmpRec.TaskSubtype;
        item.type = tmpRec.CallType;
        item.whatId = tmpRec.WhatId;
        item.whatName = tmpRec.What?.Name;
        item.whatURL = '/' + tmpRec.WhatId;
        item.whoId = tmpRec.WhoId;
        item.whoURL = String.isNotBlank(tmpRec.WhoId) ? '/' + tmpRec.WhoId : '';
        item.whoName = String.isNotBlank(tmpRec.WhoId) ? tmpRec.Who?.Name : '';
        item.ownerId = tmpRec.OwnerId;
        item.ownerURL = '/' + tmpRec.OwnerId;
        item.ownerName = tmpRec.Owner?.Alias;
        result.add(item);
      }
    }
    return result;
  }

  public class ActivityItem {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String idURL { get; set; }
    @AuraEnabled
    public DateTime activityDate { get; set; }
    @AuraEnabled
    public String activityFormated { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String subType { get; set; }
    @AuraEnabled
    public String subject { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public String whatId { get; set; }
    @AuraEnabled
    public String whatURL { get; set; }
    @AuraEnabled
    public String whatName { get; set; }
    @AuraEnabled
    public String whoId { get; set; }
    @AuraEnabled
    public String whoURL { get; set; }
    @AuraEnabled
    public String whoName { get; set; }
    @AuraEnabled
    public String ownerId { get; set; }
    @AuraEnabled
    public String ownerURL { get; set; }
    @AuraEnabled
    public String ownerName { get; set; }
  }
}
