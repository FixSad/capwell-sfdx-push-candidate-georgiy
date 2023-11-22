@IsTest
public with sharing class websiteCandidateSyncTest {

    @IsTest
    static void testContactSync() {
        TestDataFactory.TestData data = TestDataFactory.generateData();
        Id freeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Freelance').getRecordTypeId();
        data.contact.RecordTypeId = freeRecordTypeId;
        update data.contact;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/candidates/sync';       
        req.requestBody = Blob.valueof('{"dateFrom":"2000-01-01 00:00:00", "limitNum" : "1"}');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
          List<Contact> resp = websiteCandidateSync.getCandidates();
        Test.stopTest();
        System.assertEquals(1, resp.size());
        System.assertEquals(data.contact.Id, resp[0].Id);
    }
    
    @isTest
    static void testGetCandidate() {
        TestDataFactory.TestData data = TestDataFactory.generateData();
        Id freeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Freelance').getRecordTypeId();
        data.contact.RecordTypeId = freeRecordTypeId;
        update data.contact;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'GET');
        req.addParameter('candidate_id', data.contact.Id);
        req.requestUri = '/services/apexrest/candidates/sync';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
          Contact resp = websiteCandidateSync.getCandidate();
        Test.stopTest();
        System.assertEquals(data.contact.Id, resp.Id);
    }
}