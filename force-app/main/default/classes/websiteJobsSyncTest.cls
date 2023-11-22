@IsTest
public with sharing class websiteJobsSyncTest {
  private static final String REQUEST_BODY_WITH_CONTENT = '{"dateFrom":"2000-01-01 00:00:00", "closedOnly":"true", "contentOnly":"true", "publishedOnly":"true", "limitNum" : "1"}';
  private static final String REQUEST_BODY_WITHOUT_CONTENT = '{"dateFrom":"2000-01-01 00:00:00", "closedOnly":"true", "contentOnly":"false", "publishedOnly":"true", "limitNum" : "1"}';

  @TestSetup
  private static void setup() {
    TestDataFactory.TestData data = TestDataFactory.generateData();
    data.job.StageName = 'Closed Won';
    data.job.Job_Type__c = 'Content';
    update data.job;
  }

  @IsTest
  static void testJobsSync01() {
    Opportunity job = [SELECT Id FROM Opportunity LIMIT 1];
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.addHeader('httpMethod', 'POST');
    req.requestUri = '/services/apexrest/jobs/sync';
    req.requestBody = Blob.valueof(REQUEST_BODY_WITH_CONTENT);
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();
    List<Opportunity> resp = websiteJobsSync.getJobs();
    Test.stopTest();
    System.assertEquals(1, resp.size());
    System.assertEquals(resp[0].Id, job.Id);
  }

  @IsTest
  static void testJobsSync02() {
    Opportunity job = [SELECT Job_Type__c FROM Opportunity LIMIT 1];
    job.Job_Type__c = 'Live';
    update job;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.addHeader('httpMethod', 'POST');
    req.requestUri = '/services/apexrest/jobs/sync';
    req.requestBody = Blob.valueof(REQUEST_BODY_WITHOUT_CONTENT);
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();
    List<Opportunity> resp = websiteJobsSync.getJobs();
    Test.stopTest();
    System.assertEquals(1, resp.size());
    System.assertEquals(resp[0].Id, job.Id);
  }

  @IsTest
  static void testJobsSyncDelete() {
    Mailshot__c mailshot = [SELECT Id FROM Mailshot__c LIMIT 1];
    delete mailshot;
    Opportunity job = [SELECT Id FROM Opportunity LIMIT 1];
    delete job;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.addHeader('httpMethod', 'GET');
    req.requestUri = '/services/apexrest/jobs/sync';
    req.requestBody = Blob.valueof(REQUEST_BODY_WITH_CONTENT);
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();
    List<Deleted_Job__c> resp = websiteJobsSync.getDeletedJobs();
    Test.stopTest();
    System.assertEquals(1, resp.size());
    System.assertEquals(job.Id, resp[0].JobID__c);
  }
}
