@IsTest
private with sharing class websiteSkillGroupsTest {

    private static final String SKILL_NAME = 'Test Skill';

    @TestSetup
	private static void setup() {
        Skill__c skill01 = new Skill__c(Name = SKILL_NAME);
        insert skill01;
        Skill_Group__c skillGroup = new Skill_Group__c(
            Name = 'Test Group 1',
            Plural_Name__c = 'Test Group',
            Function__c = 'Test function'
            );
        insert skillGroup;
        Skill_Group_Association__c skillGroupAssot = new Skill_Group_Association__c();
        skillGroupAssot.Professional_Skill__c = skill01.id;
        skillGroupAssot.Skill_Group__c = skillGroup.Id;
        insert skillGroupAssot;
    }

    @IsTest 
    static void testGetGroups() {
        Skill_Group__c skillGroup = [SELECT Name, Plural_Name__c, Function__c FROM Skill_Group__c LIMIT 1];
        Test.startTest();
            List<websiteSkillGroups.groupWrapper> groupWrapperList = websiteSkillGroups.getGroups();
        Test.stopTest();
        /*System.assertNotEquals(null, groupWrapperList);
        System.assertEquals(1, groupWrapperList.size());
        System.assertEquals(skillGroup.Id, groupWrapperList[0].id);
        System.assertEquals(skillGroup.Name, groupWrapperList[0].name);
        System.assertEquals(skillGroup.Plural_Name__c, groupWrapperList[0].pluralName);
        System.assertEquals(skillGroup.Function__c, groupWrapperList[0].function);
        System.assertNotEquals(null, groupWrapperList[0].skills);
        System.assertEquals(1, groupWrapperList[0].skills.size());*/
    }

    @IsTest 
    static void testPushGroups() {
        Test.startTest();
        List<websiteSkillGroups.groupWrapper> groupWrapperList = new List<websiteSkillGroups.groupWrapper>();
        List<websiteSkillGroups.groupWrapper> result = websiteSkillGroups.pushGroups(groupWrapperList);
        Test.stopTest();
        /*System.assert(result != null);
        System.assert(result.isEmpty());*/
    }
}
