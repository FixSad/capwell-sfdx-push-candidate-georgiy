@IsTest
public with sharing class clientSearchControllerTest {

    private static final String CON_NAME = 'Test Contact';
    private static final String SKILL_NAME = 'Test Skill';
    private static final String EMAIL = 'testcontact01@gmail.com';
    private static final String ACCOUNT_REGION = 'ZH';

    @TestSetup
	private static void setup() {
        TestDataFactory.TestData data = TestDataFactory.generateData();
        Account acc = data.acc;
        acc.shippinglatitude = 10.022;
        acc.shippinglongitude = 10.0133;
        acc.Account_Region__c = ACCOUNT_REGION;
        update acc;
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Contact con = new Contact(
            LastName = CON_NAME,
            Email = EMAIL,
            RecordTypeId = conRecordTypeId,
            AccountId = data.acc.Id,
            Job_Type__c = 'Live',
            Geolocation__latitude__s = 10.022,
            Geolocation__longitude__s =  10.0133
        );
        insert con;
        insert new ContentVersion (
            Title = 'cv',
            PathOnClient = 'cv.docx',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        List<ContentDocument> documents = [SELECT Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = con.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        Skill__c skill01 = new Skill__c(Name = SKILL_NAME);
        insert skill01;
        Skill_Association__c skillAccAssot = new Skill_Association__c (
            Skill__c = skill01.Id,
            Type__c = 'Primary',
            Level__c = 'Junior',
            isActive__c = true,
            Account__c = data.acc.Id
        );
        Skill_Association__c skillContactAssot = new Skill_Association__c (
            Skill__c = skill01.Id,
            Type__c = 'Primary',
            Level__c = 'Junior',
            isActive__c = true,
            Contact__c = con.Id
        );
        insert new List<Skill_Association__c>{skillAccAssot, skillContactAssot};
    }   
    
    @IsTest
    static void testSearchClients() {
        Skill__c skill = [SELECT Id FROM Skill__c LIMIT 1];
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1]; 
        Account acc = [SELECT Name FROM Account LIMIT 1];
        Contact con = [SELECT Name FROM Contact LIMIT 1];
        Test.startTest();
        List<accountTeamController.teamWrapper> result = clientSearchController.searchClients(
                                                                    new String[]{skill.Id}, mailshot.Id, 10, 10.022, 10.0133, ACCOUNT_REGION, new String[]{});
        Test.stopTest();
        System.assertNotEquals(null, result);                                                                 
        System.assertEquals(1, result.size());                                                                 
        System.assertEquals(acc.Id, result[0].id);                                                                 
        System.assertEquals(acc.Name, result[0].name);                                                                 
        System.assertEquals('account', result[0].type); 
        System.assertNotEquals(null, result[0].children);                                                                 
        System.assertNotEquals(con.Id, result[0].children[0].Id);                                                                 
    }
}