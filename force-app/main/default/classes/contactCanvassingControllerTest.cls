@IsTest
public with sharing class contactCanvassingControllerTest {
  private static final String ACC_NAME = 'Test Acc';

  @TestSetup
  private static void setup() {
    insert new Account(Name = ACC_NAME);
  }

  @IsTest
  static void testSaveCallLog01() {
    Id accId = [SELECT Id FROM Account WHERE Name = :ACC_NAME LIMIT 1].Id;
    Test.startTest();
    contactCanvassingController.saveCallLog(
      accId,
      null,
      'New',
      'Comments',
      'Subject',
      false,
      null
    );
    Test.stopTest();
    List<Task> taskList = [
      SELECT WhatId, Status, Description, Type, Subject, TaskSubtype
      FROM Task
    ];
    System.assertEquals(false, taskList.isEmpty());
    System.assertEquals(1, taskList.size());
    System.assertEquals(accId, taskList[0].WhatId);
    System.assertEquals('New', taskList[0].Status);
    System.assertEquals('Comments', taskList[0].Description);
    System.assertEquals('Call', taskList[0].Type);
    System.assertEquals('Subject', taskList[0].Subject);
    System.assertEquals('Call', taskList[0].TaskSubtype);
  }

  @IsTest
  static void testSaveCallLog02() {
    Id accId = [SELECT Id FROM Account WHERE Name = :ACC_NAME LIMIT 1].Id;
    Test.startTest();
    contactCanvassingController.saveCallLog(
      accId,
      null,
      'New',
      'Comments',
      'Subject',
      true,
      Date.today()
    );
    Test.stopTest();
    List<Task> taskList = [
      SELECT WhatId, Status, Description, Type, Subject, TaskSubtype
      FROM Task
    ];
    System.assertEquals(false, taskList.isEmpty());
    System.assertEquals(2, taskList.size());
  }

  @IsTest
  static void testGetContactActivities() {
    Id accId = [SELECT Id FROM Account WHERE Name = :ACC_NAME LIMIT 1].Id;
    insert new Task(
      Status = 'Status',
      Type = 'Call',
      TaskSubtype = 'Call',
      ActivityDate = Date.today(),
      Description = 'Comments',
      WhatId = accId
    );
    Test.startTest();
    List<ActivityController.ActivityItem> taskList = ActivityController.getActivities(
      accId
    );
    Test.stopTest();
    List<Task> result = [
      SELECT WhatId, Status, Description, Type, Subject, TaskSubtype
      FROM Task
    ];
    System.assertEquals(false, result.isEmpty());
    System.assertEquals(1, result.size());
    System.assertEquals(accId, result[0].WhatId);
  }
}
