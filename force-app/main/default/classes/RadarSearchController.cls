@RestResource(urlMapping='/Radar/Search')
global with sharing class RadarSearchController {
    global class RadarRequest {
        public String skillId;
        public String keywords;
        public Double latitude;
        public Double longitude;
        public Integer radius;
	}

    @HttpPost
    global static List<Contact> getContactByFilters(RadarRequest radarRequest) {
        String query = RadarSearchController.buildQuery(radarRequest);
        
        List<Contact> result =  database.query(query);
        
        return result;
    }

    public static List<String> fields() {
        List<String> fields = new List<String>(Contact.SObjectType.getDescribe().fields.getMap().keySet());
        return fields;
    }
    
    public static String buildQuery(RadarRequest request) {
        String soql = 'SELECT ' + String.join(RadarSearchController.fields(), ',') 
            + ', (SELECT Skill_Association__c.Skill__r.Id, Skill_Association__c.Skill__r.Name,' 
            + ' Skill_Association__c.Skill__r.Parent__c FROM Skill_Associations__r)'
            + ' FROM Contact';

        List<String> skillIds = new List<String>();
        for (Skill__c skill : [SELECT Id, Name, (SELECT Id, Name FROM SubSkills__r) FROM Skill__c WHERE Id = :request.skillId]) {
            skillIds.add(skill.Id);
            for (Skill__c subSkill : skill.SubSkills__r) {
                skillIds.add(subSkill.Id);
            }
        }

        soql += ' WHERE Id IN (SELECT Contact__c FROM Skill_Association__c WHERE Skill__c IN (' 
            + '\''+String.join(skillIds,'\',\'')+'\'' + '))';

        Double lat = request.latitude;
        Double lng = request.longitude;
        Integer radius = request.radius;
        if(lat != null && lng != null && radius != null) {
            soql += ' AND DISTANCE(Contact.Geolocation__c,GEOLOCATION(' + lat + ',' + lng + '), \'km\') < ' + radius;
        }
        
        return soql;
    }
}