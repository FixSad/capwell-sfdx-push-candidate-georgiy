trigger SkillAssociation_UpdateCandidate on Skill_Association__c (after insert, after update, after delete) {
    Set<Id> contIds = new Set<Id>();
    List<Skill_Association__c> listToProcess = new List<Skill_Association__c>();
    if (Trigger.isDelete) {
        listToProcess = Trigger.old;
    } else {
        listToProcess = Trigger.new;
    }
    for (Skill_Association__c tmpRec : listToProcess) {
        if (tmpRec.Contact__c != null) {
            contIds.add(tmpRec.Contact__c);
        }
    }
    if (!contIds.isEmpty()) {
        List<Contact> contacts = [SELECT Id, Raw_Skills__c, (SELECT id, Skill__r.Name FROM Skill_Associations__r WHERE isActive__c = true) FROM Contact WHERE Id IN :contIds];
        if (contacts!=null) {
            if (!contacts.isEmpty()) {
                List<Contact> toUpdate = new List<Contact>();
                for (Contact tmpCont : contacts) {
                    String tmpSkills = '';
                    for (Skill_Association__c tmpSkill : tmpCont.Skill_Associations__r) {
                        tmpSkills += String.isBlank(tmpSkills) ? (String.isNotBlank(tmpSkill.Skill__r.Name) ? tmpSkill.Skill__r.Name : '') : (String.isNotBlank(tmpSkill.Skill__r.Name) ? ','+tmpSkill.Skill__r.Name : '');
                    }
                    if (String.isNotBlank(tmpSkills)) {
                        tmpCont.Raw_Skills__c = tmpSkills;
                        toUpdate.add(tmpCont);
                    }
                }
                if (!toUpdate.isEmpty()) {
                    try {
                        update toUpdate;
                    } catch (Exception e) {
                        system.debug(e);
                    }
                }
            }
        }
    }
}