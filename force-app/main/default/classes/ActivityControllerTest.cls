@IsTest
public with sharing class ActivityControllerTest {
  @IsTest
  static void runEmptyTest() {
    List<ActivityController.ActivityItem> tmpList = ActivityController.getActivities(
      ''
    );
    System.assertEquals(true, tmpList.isEmpty());
  }

  @IsTest
  static void runTaskTest() {
    Account acc = new Account(Name = 'Test Acc');
    insert acc;

    Contact cnt = new Contact();
    cnt.AccountId = acc.Id;
    cnt.LastName = 'Test Cont';
    insert cnt;

    Task tsk = new Task();
    tsk.Subject = 'call';
    tsk.WhatId = acc.id;
    insert tsk;

    Task cntTsk = new Task();
    tsk.Subject = 'call';
    tsk.WhoId = cnt.id;
    insert cntTsk;

    opa_recruiter_log__c recLog = new opa_recruiter_log__c();
    recLog.Account__c = acc.id;
    insert recLog;

    opa_candidate_log__c cntLog = new opa_candidate_log__c();
    cntLog.Contact__c = cnt.Id;
    insert cntLog;

    List<ActivityController.ActivityItem> tmpList = ActivityController.getActivities(
      acc.id
    );
    System.assertEquals(false, tmpList.isEmpty());
  }

  @isTest
  static void createRecord() {
    Account acc = new Account(Name = 'Test Acc');
    insert acc;

    Contact cnt = new Contact();
    cnt.AccountId = acc.Id;
    cnt.LastName = 'Test Cont';
    insert cnt;

    Task_Wrapper__c tmp = new Task_Wrapper__c();
    tmp.Account__c = acc.Id;
    tmp.COntact__c = cnt.Id;
    tmp.Type__c = 'Call';
    tmp.Follow_up__c = true;
    tmp.DueDate__c = Date.today();

    String result = ActivityController.recordNewActivity(tmp);
    system.assertEquals('success', result);
  }
}
