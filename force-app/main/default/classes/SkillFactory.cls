@IsTest
public with sharing class SkillFactory {
    public static void create(Integer times) {
        List<Skill__c> testSkills = new List<Skill__c>();
        
        for(Integer i = 0; i < times; i++) {
            testSkills.add(new Skill__c(Name = 'Skill'+i));
        }

        insert testSkills;
    }
}