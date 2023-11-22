public with sharing class SkillsController {
	@AuraEnabled(Cacheable = true)
	public static Skill__c[] getAllSkills() {
		return [ SELECT Id, Name, Alias__c, Parent__r.Name
							FROM Skill__c
							ORDER BY Name
							LIMIT 50];
	}

	@AuraEnabled(Cacheable = true)
	public static Skill__c[] searchSkills(String searchTerm) {
		// Return all skills when no search term
		searchTerm = searchTerm.trim();

		if (searchTerm == '') {
			return getAllSkills();
		}

		// Prepare query paramters
		searchTerm = '%' + searchTerm + '%';

		return [ SELECT Id, Name, Alias__c, Parent__r.Name
							FROM Skill__c
						WHERE Name LIKE :searchTerm
							 OR Alias__C LIKE :searchTerm
						ORDER BY Name LIMIT 50];
	}

	/*@TestVisible private static List<Skill__c> getAllReferencedAccountSkills(String accountId) {
		List<Skill__c> skills = new List<Skill__c>();
		for (Skill_Account_Association__c assoc : [ SELECT Id, Name, Skill__r.Name, Skill__r.Alias__c
																								FROM Skill_Account_Association__c
																								WHERE Account__r.Id = :accountId
																								ORDER BY Name LIMIT 50]) {
			skills.add(assoc.Skill__r);
		}

		return skills;
	}*/

	/*@TestVisible private static List<Skill__c> getAllReferencedContactSkills(String contactId) {
		List<Skill__c> skills = new List<Skill__c>();
		for (Skill_Contact_Association__c assoc : [ SELECT Id, Name, Skill__r.Name, Skill__r.Alias__c
																								FROM Skill_Contact_Association__c
																								WHERE Contact__r.Id = :contactId
																								ORDER BY Name LIMIT 50]) {
			skills.add(assoc.Skill__r);
		}

		return skills;
	}*/

	/*@TestVisible private static List<Skill__c> getAllReferencedJobSkills(String jobId) {
		List<Skill__c> skills = new List<Skill__c>();

		for (Skill_Job_Association__c assoc : [ SELECT Id, Name, Skill__r.Name, Skill__r.Alias__c
																						FROM Skill_Job_Association__c
																						WHERE Job__r.Id = :jobId
																						ORDER BY Name LIMIT 50]) {
			skills.add(assoc.Skill__r);
		}

		return skills;
	}*/


	/*@AuraEnabled(Cacheable = true)
	public static Skill__c[] getAllReferencedSkills(String recordId, String objectApiName) {
		List<Skill__c> skills = new List<Skill__c>();

		if (objectApiName == 'Account') {
			return getAllReferencedAccountSkills(recordId);
		} else if (objectApiName == 'Contact') {
			return getAllReferencedContactSkills(recordId);
		} else if (objectApiName == 'Opportunity') {
			return getAllReferencedJobSkills(recordId);
		}
		return null;
	}*/

	/*@TestVisible public static void createAccountSkillAssociation(String skillId, String accountId) {
		if ([
				SELECT Id
				FROM Skill_Account_Association__c
				WHERE Skill__c = :skillId
					AND Account__C = :accountId
			].isEmpty()) {
				Skill_Account_Association__c assoc = new Skill_Account_Association__c();
				assoc.Skill__c = skillId;
				assoc.Account__c = accountId;

				insert assoc;
			}
	}*/

	/*@TestVisible public static void createContactSkillAssociation(String skillId, String contactId) {
		if ([SELECT Id FROM Skill_Contact_Association__c WHERE Skill__c = :skillId AND Contact__C = :contactId].isEmpty()) {
				Skill_Contact_Association__c assoc = new Skill_Contact_Association__c();
				assoc.Skill__c = skillId;
				assoc.Contact__c = contactId;
				insert assoc;
			}
	}*/

	/*@TestVisible public static void createJobSkillAssociation(String skillId, String jobId) {
		if ([
				SELECT Id
				FROM Skill_Job_Association__c
				WHERE Skill__c = :skillId
					AND Job__c = :jobId
			].isEmpty()) {
				Skill_Job_Association__c assoc = new Skill_Job_Association__c();
				assoc.Skill__c = skillId;
				assoc.Job__c = jobId;

				insert assoc;
			}
	}*/

	/*@AuraEnabled(Cacheable = false)
	public static void createSkillAssociation(String skillId, String recordId, String objectApiName) {
		try {
			if (objectApiName == 'Account') {
				createAccountSkillAssociation(skillId, recordId);
			} else if (objectApiName == 'Contact') {
				createContactSkillAssociation(skillId, recordId);
			} else if (objectApiName == 'Opportunity') {
				createJobSkillAssociation(skillId, recordId);
			}
		}
		catch(Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	/*private static void removeAccountSkillAssociation(String skillId, String accountId) {
		DELETE [
			SELECT Id
			FROM Skill_Account_Association__c
			WHERE Skill__c = :skillId
				AND Account__C = :accountId
		];
	}*/

	/*private static void removeContactSkillAssociation(String skillId, String contactId) {
		DELETE [
			SELECT Id
			FROM Skill_Contact_Association__c
			WHERE Skill__c = :skillId
				AND Contact__C = :contactId
		];
	}*/

	/*private static void removeJobSkillAssociation(String skillId, String jobId) {
		DELETE [
			SELECT Id
			FROM Skill_Job_Association__c
			WHERE Skill__c = :skillId
				AND Job__c = :jobId
		];
	}*/

	@AuraEnabled(Cacheable = false)
	public static void removeSkillAssociation(String associationId) {
		Skill_Association__c tmpRec = new Skill_Association__c(Id = associationId);
		delete tmpRec;
	}

	/*@AuraEnabled(Cacheable = false)
	public static void removeSkillAssociation(String skillId, String recordId, String objectApiName) {
		try {
			if (objectApiName == 'Account') {
				removeAccountSkillAssociation(skillId, recordId);
			} else if (objectApiName == 'Contact') {
				removeContactSkillAssociation(skillId, recordId);
			} else if (objectApiName == 'Opportunity') {
				removeJobSkillAssociation(skillId, recordId);
			}
		}
		catch(Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	@AuraEnabled(cacheable=true)
	public static List<Skill_Association__c> getAssociatedSkills(String objectApiName, String objectId, String skillType) {
		if (objectApiName=='Opportunity') {
			objectApiName = 'Job';
		}
		objectApiName += '__c';
		String query = 'SELECT Id, Skill__r.Name, Skill__c, Type__c, Level__c '+
						'FROM Skill_Association__c '+
						'WHERE isActive__c=true AND '+objectApiName+' = :objectId';
		if (!String.isBlank(skillType)) {
			query += ' AND Type__c = :skillType';
		}
		return (List<Skill_Association__c>)Database.query(query);
	}

	@AuraEnabled
	public static void createSkillAssociation(String objectApiName, String objectId, String skillType, String skillID, String skillLevel){
		if ([SELECT Id FROM Skill_Association__c WHERE Skill__c = :skillId 
				AND (Job__c = :objectId OR Account__c=:objectId OR Contact__c=:objectId)].isEmpty()) {
			Skill_Association__c tmpRec = new Skill_Association__c();
			tmpRec.Skill__c = skillID;
			tmpRec.Type__c = skillType;
			tmpRec.Level__c = skillLevel;
			tmpRec.isActive__c = true;
			switch on objectApiName {
				when 'Contact' {
					tmpRec.Contact__c = objectId;
				}
				when 'Account' {
					tmpRec.Account__c = objectId;
				}
				when 'Opportunity' {
					tmpRec.Job__c = objectId;
				}
				when 'Lead' {
					tmpRec.Lead__c = objectId;
				}
			}
			try {
				insert tmpRec;
			} catch(Exception e) {
				throw new AuraHandledException(e.getMessage());
			}
		}
	}

	@AuraEnabled
	public static void updateSkillLevel(String associationId, String level){
		Skill_Association__c tmpRec = new Skill_Association__c(Id = associationId);
		tmpRec.Level__c = level;
		update tmpRec;
	}

	@AuraEnabled(cacheable=true)
	public static List<Skill_Group__c> getAllGroups(){
		return [SELECT Id, Name, Function__c, (SELECT Professional_Skill__c, Professional_Skill__r.Name FROM Skill_Group_Associations__r) FROM Skill_Group__c WHERE ParentGroup__c = null ORDER BY Name];
	}

	@AuraEnabled(cacheable=true)
	public static List<skillGroups> getAllGroupsTree() {
		List<Skill_Group__c> tmpList = [SELECT Id, Name, Market__c, Function__c, Plural_Name__c, ParentGroup__c FROM Skill_Group__c ORDER BY ParentGroup__c, Name];
		if (tmpList.isEmpty()) {
			return null;
		}
		List<skillGroups> resultList = new List<skillGroups>();
		Map<String, List<skillGroups>> resMap = new Map<String, List<skillGroups>>();
		for (Skill_Group__c tmpRec : tmpList) {
			skillGroups tmpSkill = new skillGroups();
			tmpSkill.id = tmpRec.id;
			tmpSkill.name = tmpRec.Name;
			tmpSkill.market = tmpRec.Market__c;
			tmpSkill.function = tmpRec.Function__c;
			tmpSkill.plural = tmpRec.Plural_Name__c;

			if (tmpRec.ParentGroup__c==null) {
				if (resMap.get('root')==null) {
					resMap.put('root', new List<skillGroups>());
				}
				
				List<skillGroups> tmpItem = resMap.get('root');
				tmpItem.add(tmpSkill);
				resMap.put('root', tmpItem);
			}
		}
		return resultList;
	}

	public class skillGroups {
		@AuraEnabled public String id;
		@AuraEnabled public String name;
		@AuraEnabled public String market;
		@AuraEnabled public String function;
		@AuraEnabled public String plural;
		@AuraEnabled public List<skillGroups> children;
	}
}