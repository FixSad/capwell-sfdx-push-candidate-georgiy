@IsTest
public with sharing class candidatesSearchControllerTest {
  private static final String ACC_NAME = 'candidatesSearchControllerTest Acc candidatesSearchControllerTest';
  private static final String CON_NAME = 'candidatesSearchControllerTest Contact candidatesSearchControllerTest';
  private static final String SKILL_NAME = 'Test Skill';
  private static final String EMAIL = 'testcontact01.candidatesSearchControllerTest@gmail.com';

  @TestSetup
  private static void setup() {
    TestDataFactory.TestData data = TestDataFactory.generateData();
    Account acc01 = new Account(Name = ACC_NAME);
    insert acc01;
    Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Freelance Candidate')
      .getRecordTypeId();
    Contact con = new Contact(
      LastName = CON_NAME,
      Email = EMAIL,
      RecordTypeId = conRecordTypeId,
      AccountId = acc01.Id,
      Employable__c = true,
      Is_Manager__c = false,
      Job_Type__c = 'Live',
      Geolocation__latitude__s = 10.022,
      Geolocation__longitude__s = 10.0133
    );
    insert con;
    insert new ContentVersion(
      Title = 'cv',
      PathOnClient = 'cv.docx',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    List<ContentDocument> documents = [
      SELECT Title, LatestPublishedVersionId
      FROM ContentDocument
    ];
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.LinkedEntityId = con.Id;
    cdl.ContentDocumentId = documents[0].Id;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;
    Skill__c skill01 = new Skill__c(Name = SKILL_NAME);
    insert skill01;
    insert new Skill_Association__c(
      Skill__c = skill01.Id,
      Type__c = 'Primary',
      Level__c = 'Junior',
      isActive__c = true,
      Contact__c = con.Id
    );
  }

  @IsTest
  static void testSearchCandidates() {
    Skill__c skill = [SELECT Id FROM Skill__c LIMIT 1];
    Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
    ContentDocument document = [SELECT Id FROM ContentDocument LIMIT 1];
    Test.startTest();
    List<candidatesSearchController.candidateWrapper> result = candidatesSearchController.searchCandidates(
      new List<String>{ skill.Id },
      'Test',
      mailShot.Id,
      'Live',
      10,
      10.022,
      10.0133,
      true
    );
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(1, result.size());
    System.assertEquals(ACC_NAME, result[0].account);
    //System.assertEquals(EMAIL, result[0].email);
    //System.assertEquals(document.Id, result[0].contentDocuments[0]);
    System.assertNotEquals('', result[0].skills);
  }

  @IsTest
  static void testAddCandidateMailshot() {
    Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
    Contact con = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    candidatesSearchController.addCandidateMailshot(
      mailShot.Id,
      new List<String>{ con.Id }
    );
    Test.stopTest();
    List<Candidate_Mailshot__c> candidateMail = [
      SELECT Id
      FROM Candidate_Mailshot__c
    ];
    System.assertNotEquals(null, candidateMail);
    System.assertEquals(1, candidateMail.size());
  }
}
