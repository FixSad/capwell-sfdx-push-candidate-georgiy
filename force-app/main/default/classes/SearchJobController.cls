@RestResource(urlMapping='/Jobs/Search')
global with sharing class SearchJobController {
    
    global class JobRequest {
        public String jobType;
        public String[] skills;
        public String[] workplaces;
        public String[] experiences;
        public Integer[] durations;
        public Integer minSalary;
        public Integer maxSalary;
        public Integer minDays;
        public Integer maxDays;
        public Double latitude;
        public Double longitude;
        public Integer radius;
        public Integer skip = 0;
        public Integer take = 10;
	}

    global class Response {
        public Opportunity[] records;
        public Integer total = 0;

        public Response(List<Opportunity> records, Integer total) {
            this.records = records;
            this.total = total;
        }
    }
    
	@HttpPost
    global static Response getJobsByFilters(JobRequest jobRequest) {
        String resultQuery = SearchJobController.buildQuery(jobRequest, true);
        List<Opportunity> result =  database.query(resultQuery);

        String countQuery = SearchJobController.buildQuery(jobRequest, false);
        List<Opportunity> totalResult =  database.query(countQuery);

        Response response = new Response(result, totalResult.size());

        return response;
    }
    
    public static List<String> fields() {
        List<String> fields = new List<String>(Opportunity.SObjectType.getDescribe().fields.getMap().keySet());
        return fields;
    }
    
    public static String buildQuery(JobRequest request, Boolean withPagination) {
        String soql = 'SELECT ' + String.join(SearchJobController.fields(), ',') 
            + ', (SELECT Skill_Association__c.Skill__r.Id, Skill_Association__c.Skill__r.Name,' 
            + ' Skill_Association__c.Skill__r.Parent__c FROM Skill_Associations__r)'
            + ' FROM Opportunity ';

        if(request.jobType != null && request.jobType != '') {
            soql += ' WHERE Job_Type__c = ' + '\'' + request.jobType + '\'';
        }
        
        if(request.skills != null && request.skills.size() > 0) {
            soql += ' AND Id IN (SELECT Job__c FROM Skill_Association__c WHERE Skill__c IN (' 
                + String.join(request.skills, ',') + '))';
        }
        
        /*if(request.workplaces != null && request.workplaces.size() > 0) {
            if (request.workplaces.size() > 1) {
                soql += 'AND (';
                String q = '';
                for (String val : request.workplaces) {
                     q += 'Workplace__c = ' + val + ' OR ';
                }
                soql += q.removeEnd('OR ') + ' ) ';
            } else {
                soql += ' AND Workplace__c = ' + request.workplaces[0];
            }
        }
        
        if(request.experiences != null && request.experiences.size() > 0) {
            soql += ' AND Experience_Level__c includes (' + String.join(request.experiences, ',') + ')';
        }

        if(request.durations != null && request.durations.size() > 0) {
            if (request.durations.size() > 1) {
                soql += 'AND (';
                String q = '';
                for (Integer val : request.durations) {
                     q += 'Contract_Duration_Months__c  = ' + val + ' OR ';
                }
                soql += q.removeEnd('OR ') + ' ) ';
            } else {
                soql += ' AND Contract_Duration_Months__c = ' + request.durations[0];
            }
        }
        
        if(request.minSalary != null) {
            soql += ' AND Minimum_Salary__c >= ' + request.minSalary;
        }
        
        if(request.maxSalary != null) {
            soql += ' AND Maximum_Salary__c <= ' + request.maxSalary;
        }
        
        if(request.minDays != null) {
            soql += ' AND Minimum_Availability_Days__c >= ' + request.minDays;
        }
        
        if(request.maxDays != null) {
            soql += ' AND Maximum_Availability_Days__c <= ' + request.maxDays;
        }
        
        Double lat = request.latitude;
        Double lng = request.longitude;
        Integer radius = request.radius;
        if(lat != null && lng != null && radius != null) {
            soql += ' AND DISTANCE(Job__c.Geolocation__c,GEOLOCATION(' + lat + ',' + lng + '), \'km\') < ' + radius;
        }*/

        soql += ' ORDER BY LegacyOpaID__c DESC';

        if (withPagination) {
            soql += ' LIMIT ' + String.valueOf(request.take);
            soql += ' OFFSET ' + String.valueOf(request.skip);
        }
        
        return soql;
    }
}