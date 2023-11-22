@isTest
public class SkillAssociation_UpdateCandidate_Test {
	@IsTest
    static void testSkillChange() {
        TestDataFactory.TestData data = TestDataFactory.generateData();
        Id freeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Freelance').getRecordTypeId();
        data.contact.RecordTypeId = freeRecordTypeId;
        update data.contact;

        Contact cn = [SELECT Id, Raw_Skills__c FROM Contact WHERE Id = :data.contact.Id];
        System.assertEquals(null, cn.Raw_Skills__c);
        
        Skill__c sk1 = new Skill__c();
        sk1.Name = 'Product Owner';
        insert sk1;

        Skill__c sk2 = new Skill__c();
        sk2.Name = 'Agile';
        insert sk2;
        
        Skill_Association__c ska = new Skill_Association__c();
        ska.Contact__c = data.contact.Id;
        ska.Skill__c = sk1.Id;
        ska.isActive__c = true;
        insert ska;
        
		ska = new Skill_Association__c();
        ska.Contact__c = data.contact.Id;
        ska.Skill__c = sk2.Id;
        ska.isActive__c = true;
        insert ska;
        
        cn = [SELECT Id, Raw_Skills__c FROM Contact WHERE Id = :data.contact.Id];
        System.assertEquals(true , cn.Raw_Skills__c.containsIgnoreCase('product owner'));
        System.assertEquals(true , cn.Raw_Skills__c.containsIgnoreCase('agile'));
        
        delete ska;
        cn = [SELECT Id, Raw_Skills__c FROM Contact WHERE Id = :data.contact.Id];
        System.assertEquals('Product Owner' , cn.Raw_Skills__c);        
    }
}