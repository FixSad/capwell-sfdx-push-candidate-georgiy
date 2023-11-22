@IsTest
public with sharing class OverviewInterviewsControllerTest {
  private static final String CURRENT_WEEK = 'Current Week';

  @TestSetup
  private static void setup() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    Opportunity job = new Opportunity(
      LegacyOpaID__c = '123',
      Name = 'Test Job',
      AccountId = acc.Id,
      StageName = 'Qualification',
      CloseDate = Date.today().addDays(30),
      Publish__c = true
    );
    insert job;
    Contact contact = new Contact(
      LastName = 'Test Contact',
      Email = 'test@test.com',
      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Freelance')
        .getRecordTypeId()
    );
    insert contact;
    Applicant__c app = new Applicant__c(
      Candidate__c = contact.Id,
      Job__c = job.Id
    );
    insert app;
    insert new List<Interview__c>{
      new Interview__c(
        Applicant__c = app.Id,
        Candidate__c = contact.Id,
        Account__c = acc.Id,
        Job__c = job.Id,
        Start_Date_Time__c = (DateTime) System.today().AddDays(8)
      ),
      new Interview__c(
        Applicant__c = app.Id,
        Candidate__c = contact.Id,
        Account__c = acc.Id,
        Job__c = job.Id,
        Start_Date_Time__c = (DateTime) System.today().AddDays(9)
      ),
      new Interview__c(
        Applicant__c = app.Id,
        Candidate__c = contact.Id,
        Account__c = acc.Id,
        Job__c = job.Id,
        Start_Date_Time__c = (DateTime) System.today().AddDays(10)
      )
    };
  }

  @IsTest
  static void testGetInterviewsMapPositive() {
    Test.startTest();
    Map<Integer, List<Interview__c>> result = OverviewInterviewsController.getInterviewsMap(
      OverviewInterviewsController.NEXT_WEEK
    );
    Test.stopTest();
    System.assertNotEquals(null, result);
    Integer count = 0;
    for (List<Interview__c> interList : result.values()) {
      if (!interList.isEmpty()) {
        count++;
      }
    }
    System.assertEquals(3, count, 'Should be returned three interviews.');
  }

  @IsTest
  static void testGetInterviewsMapNegative() {
    Test.startTest();
    Map<Integer, List<Interview__c>> result = OverviewInterviewsController.getInterviewsMap(
      CURRENT_WEEK
    );
    Test.stopTest();
    System.assertEquals(null, result);
  }
}
