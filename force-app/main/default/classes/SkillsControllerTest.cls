@IsTest
public with sharing class SkillsControllerTest {
  private static final String ACC_NAME = 'SkillsControllerTest Acc';
  private static final String SKILL_NAME = 'Test Skill';
  private static final String CON_NAME = 'SkillsControllerTest Contact';

  @TestSetup
  private static void setup() {
    TestDataFactory.TestData data = TestDataFactory.generateData();
    Skill__c skill01 = new Skill__c(Name = SKILL_NAME);
    Skill__c skill02 = new Skill__c(Name = SKILL_NAME + '02');
    insert new List<Skill__c>{ skill01, skill02 };
    Skill_Group__c skillGroup = new Skill_Group__c(Name = 'Test Group 1');
    insert skillGroup;
    Skill_Group_Association__c skillGroupAssot = new Skill_Group_Association__c();
    skillGroupAssot.Professional_Skill__c = skill01.id;
    skillGroupAssot.Skill_Group__c = skillGroup.Id;
    insert skillGroupAssot;
    Account acc01 = new Account(Name = ACC_NAME);
    insert acc01;
    Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Contact')
      .getRecordTypeId();
    insert new Contact(
      LastName = CON_NAME,
      Email = 'testContact01@gmail.com',
      RecordTypeId = conRecordTypeId,
      AccountId = acc01.Id
    );
    insert new Lead(LastName = 'Test Lead');
  }

  @IsTest
  static void testGetAllSkills() {
    Test.startTest();
    List<Skill__c> expectedSkills = SkillsController.getAllSkills();
    Test.stopTest();
    System.assertEquals(2, expectedSkills.size());
  }

  @IsTest
  static void testSearchSkills01() {
    Test.startTest();
    List<Skill__c> expectedSkills = SkillsController.searchSkills('Skill');
    Test.stopTest();
    System.assertEquals(2, expectedSkills.size());
  }

  @IsTest
  static void testSearchSkills02() {
    Test.startTest();
    List<Skill__c> expectedSkills = SkillsController.searchSkills('');
    Test.stopTest();
    System.assertEquals(2, expectedSkills.size());
  }

  @IsTest
  static void testReferencedAccountSkills() {
    Id accId = [SELECT Id FROM Account WHERE Name = :ACC_NAME LIMIT 1].Id;
    Id skillId = [
      SELECT Id
      FROM Skill__c
      WHERE Name = :SKILL_NAME + '02'
      LIMIT 1
    ]
    .Id;
    Test.startTest();
    SkillsController.createSkillAssociation(
      'Account',
      accId,
      'Primary',
      skillId,
      null
    );
    List<Skill_Association__c> skills = SkillsController.getAssociatedSkills(
      'Account',
      accId,
      'Primary'
    );
    Test.stopTest();
    System.assertEquals(1, skills.size());
  }

  @IsTest
  static void testReferencedContactSkills() {
    Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
    Id skillId = [
      SELECT Id
      FROM Skill__c
      WHERE Name = :SKILL_NAME + '02'
      LIMIT 1
    ]
    .Id;
    Test.startTest();
    SkillsController.createSkillAssociation(
      'Contact',
      contactId,
      'Primary',
      skillId,
      'Junior'
    );
    List<Skill_Association__c> skills = SkillsController.getAssociatedSkills(
      'Contact',
      contactId,
      ''
    );
    Test.stopTest();
    System.assertEquals(1, skills.size());
  }

  @IsTest
  static void testReferencedJobSkills() {
    Id jobId = [SELECT Id FROM Opportunity LIMIT 1].Id;
    Id skillId = [
      SELECT Id
      FROM Skill__c
      WHERE Name = :SKILL_NAME + '02'
      LIMIT 1
    ]
    .Id;
    Test.startTest();
    SkillsController.createSkillAssociation(
      'Opportunity',
      jobId,
      'Primary',
      skillId,
      null
    );
    List<Skill_Association__c> skills = SkillsController.getAssociatedSkills(
      'Opportunity',
      jobId,
      ''
    );
    Test.stopTest();
    System.assertEquals(1, skills.size());
  }

  @IsTest
  static void testReferenceLeadSkills() {
    Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;
    Id skillId = [
      SELECT Id
      FROM Skill__c
      WHERE Name = :SKILL_NAME + '02'
      LIMIT 1
    ]
    .Id;
    Test.startTest();
    SkillsController.createSkillAssociation(
      'Lead',
      leadId,
      'Primary',
      skillId,
      null
    );
    List<Skill_Association__c> skills = SkillsController.getAssociatedSkills(
      'Lead',
      leadId,
      ''
    );
    Test.stopTest();
    System.assertEquals(1, skills.size());
  }

  @IsTest
  static void testRemoveSkillAssociation() {
    Id accId = [SELECT Id FROM Account WHERE Name = :ACC_NAME LIMIT 1].Id;
    Id skillId = [
      SELECT Id
      FROM Skill__c
      WHERE Name = :SKILL_NAME + '02'
      LIMIT 1
    ]
    .Id;
    Test.startTest();
    SkillsController.createSkillAssociation(
      'Account',
      accId,
      'Primary',
      skillId,
      null
    );
    List<Skill_Association__c> skills = SkillsController.getAssociatedSkills(
      'Account',
      accId,
      ''
    );
    System.assertEquals(1, skills.size());
    SkillsController.removeSkillAssociation(skills[0].Id);
    skills = SkillsController.getAssociatedSkills('Account', accId, '');
    Test.stopTest();
    System.assertEquals(0, skills.size());
  }

  @IsTest
  static void testGetAllGroups() {
    Test.startTest();
    List<Skill_Group__c> skillGroupList = SkillsController.getAllGroups();
    Test.stopTest();
    System.assertEquals(1, skillGroupList.size());
  }

  @IsTest
  static void testUpdateSkillLevel() {
    Id accId = [SELECT Id FROM Account WHERE Name = :ACC_NAME LIMIT 1].Id;
    Id skillId = [
      SELECT Id
      FROM Skill__c
      WHERE Name = :SKILL_NAME + '02'
      LIMIT 1
    ]
    .Id;
    Test.startTest();
    SkillsController.createSkillAssociation(
      'Account',
      accId,
      'Primary',
      skillId,
      'Junior'
    );
    List<Skill_Association__c> skillAssotList = SkillsController.getAssociatedSkills(
      'Account',
      accId,
      ''
    );
    System.assertEquals(1, skillAssotList.size());
    System.assertEquals('Junior', skillAssotList[0].Level__c);
    SkillsController.updateSkillLevel(skillAssotList[0].Id, 'Medior');
    List<Skill_Association__c> result = SkillsController.getAssociatedSkills(
      'Account',
      accId,
      ''
    );
    Test.stopTest();
    System.assertEquals('Medior', result[0].Level__c);
  }
}
