@IsTest
public with sharing class RadarSearchControllerTest {

    @TestSetup
     static void setup() {
        Contact con01 = new Contact(LastName='Jane');
        Contact con02 = new Contact(LastName='John');
        Contact con03 = new Contact(LastName='Doe');
        Contact con04 = new Contact(LastName='Pitt');
        insert new List<Contact>{con01, con02, con03, con04};
        Skill__c pSkill = new Skill__c(Name='salesforce');
        insert pSkill;
        insert new Skill__c(Name='apex', Parent__c=pSkill.Id);
        insert new Skill__c(Name='lwc', Parent__c=pSkill.Id);
    }

    @IsTest 
    static void testSearchContactBySkills() {
        Contact contact1 = [SELECT Name FROM Contact WHERE LastName = 'John' LIMIT 1];
        Contact contact2 = [SELECT Name FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        Contact contact3 = [SELECT Name FROM Contact WHERE LastName = 'Jane' LIMIT 1];
        Skill__c mainSkill = [SELECT Name FROM Skill__c WHERE Name = 'salesforce' LIMIT 1];
        Skill__c apex = [SELECT Name FROM Skill__c WHERE Name = 'apex' LIMIT 1];
        Skill__c lwc = [SELECT Name FROM Skill__c WHERE Name = 'lwc' LIMIT 1];
        SkillsController.createSkillAssociation('Contact', contact1.Id, 'Primary', apex.Id, 'Junior');
        SkillsController.createSkillAssociation('Contact', contact2.Id, 'Primary', lwc.Id, 'Junior');
        SkillsController.createSkillAssociation('Contact', contact3.Id, 'Primary', mainSkill.Id, 'Junior');
        RadarSearchController.RadarRequest radarReq = new RadarSearchController.RadarRequest();
        radarReq.skillId = mainSkill.Id;
        Test.startTest();
        RadarSearchControllerTest.mockRequest(radarReq);
        List<Contact> expected = RadarSearchController.getContactByFilters(radarReq);
        Test.stopTest();
        System.assertEquals(3, expected.size());
    }

    @IsTest 
    static void testSearchContactByDistance() {
        Contact contact1 = [SELECT Name FROM Contact WHERE LastName = 'John' LIMIT 1];
        Contact contact2 = [SELECT Name FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        contact1.Geolocation__Latitude__s=52.370216;
        contact1.Geolocation__Longitude__s=4.895168;
        update contact1;
        contact2.Geolocation__Latitude__s=30.157457;
        contact2.Geolocation__Longitude__s=71.524918;
        update contact2;
        Skill__c mainSkill = [SELECT Name FROM Skill__c WHERE Name = 'salesforce' LIMIT 1];
        Skill__c apex = [SELECT Name FROM Skill__c WHERE Name = 'apex' LIMIT 1];
        Skill__c lwc = [SELECT Name FROM Skill__c WHERE Name = 'lwc' LIMIT 1];
        SkillsController.createSkillAssociation('Contact', contact1.Id, 'Primary', apex.Id, 'Junior');
        SkillsController.createSkillAssociation('Contact', contact2.Id, 'Primary', lwc.Id, 'Junior');
        RadarSearchController.RadarRequest radarReq = new RadarSearchController.RadarRequest();
        radarReq.skillId = mainSkill.Id;
        radarReq.latitude = 52.370216;
        radarReq.longitude = 4.895168;
        radarReq.radius = 10;
        Test.startTest();
        RadarSearchControllerTest.mockRequest(radarReq);
        List<Contact> expected = RadarSearchController.getContactByFilters(radarReq);
        Test.stopTest();
        System.assertEquals(1, expected.size());
        System.assertEquals(contact1.Id, expected[0].Id);
    }

    public static void mockRequest(RadarSearchController.RadarRequest req) {
        RestRequest restReq = new RestRequest();
        restReq.requestURI = '/services/apexrest/Radar/Search';
        restReq.httpMethod = 'POST';
        restReq.requestBody = Blob.valueOf(JSON.serialize(req));
        RestContext.request = restReq;
    }
}