@RestResource(urlMapping='/skill/groups')
global with sharing class websiteSkillGroups {
    @HttpGet
    global static List<groupWrapper> getGroups() {
        List<groupWrapper> resList = new List<groupWrapper>();
        /* for (Skill_Group__c tmpRec : [SELECT Id, opaId__c, Name, Plural_Name__c, Function__c, ParentGroup__c, Parent_OpaId__c, ShowOnRadar__c, (SELECT Name, Professional_Skill__r.Id, Professional_Skill__r.Name, Professional_Skill__r.LegacySkillId__c FROM Skill_Group_Associations__r) FROM Skill_Group__c]) {
            groupWrapper tmpItem = new groupWrapper();
            tmpItem.id = tmpRec.Id;
            tmpItem.opaid = tmpRec.opaId__c;
            tmpItem.name = tmpRec.Name;
            tmpItem.pluralName = tmpRec.Plural_Name__c;
            tmpItem.function = tmpRec.Function__c;
            tmpItem.parentId = tmpRec.ParentGroup__c;
            tmpItem.parentOpaId = tmpRec.Parent_OpaId__c;
            tmpItem.showOnRadar = tmpRec.ShowOnRadar__c; 
            if (!tmpRec.Skill_Group_Associations__r.isEmpty()) {
                tmpItem.skills = new List<skillWrapper>();
                for (Skill_Group_Association__c tmpSkill : tmpRec.Skill_Group_Associations__r) {
                    skillWrapper tmpSkillInner = new skillWrapper();
                    tmpSkillInner.id=tmpSkill.Professional_Skill__r.Id;
                    tmpSkillInner.name=tmpSkill.Professional_Skill__r.Name;
                    tmpSkillInner.opaid=tmpSkill.Professional_Skill__r.LegacySkillId__c;
                    tmpItem.skills.add(tmpSkillInner);
                }
            }
            resList.add(tmpItem);
        } */
        return resList;
    }

    @HttpPost
    global static List<groupWrapper> pushGroups(List<groupWrapper> inbound) {
        return inbound;
    }

    global class groupWrapper{
        global String id;
        global String opaid;
        global String name;
        global String pluralName;
        global String function;
        global String parentId;
        global String parentOpaId;
        global List<skillWrapper> skills;
        global Boolean showOnRadar;
    }

    global class skillWrapper {
        global String id;
        global String opaid;
        global String name;
    }
}