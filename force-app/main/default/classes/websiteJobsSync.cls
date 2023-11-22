@RestResource(urlMapping='/jobs/sync/*')
/**
POST REQUEST EXAMPLE:
URL: /services/apexrest/jobs/sync\
BODY:
{
    “dateFrom” : “2020-10-01 00:00:00" (YYYY-MM-DD HH:MM:SS),
    “publishedOnly” : “true” (WHERE Publish= true / false),
    “closedOnly” : “true” (WHERE isClosed= true / false),
    “contentOnly” : “true” (WHERE Job_Type__c = / != ‘Content’)
    "limitNum" : "10",
    "lastId" : "0060900000BQGDOAA5" (WHERE ID>"0060900000BQGDOAA5")
}
*/
global without sharing class websiteJobsSync {
    @HttpPost
    global static List<Opportunity> getJobs() {
        String query = 'SELECT Id, Name, Slug__c, StageName, Job_Type__c, Work_Location__c, Function__c, Desired_Skills__c, Required_Skills__c, Effort__c, Experience__c, Level__c, Technical_Skills__c, Account.Account_Region__c, '+
                            'Max_Rate__c, Min_Rate__c, Description, Publish__c, Advertising__c, Account.BillingCity, Account.BillingState, Radius__c, Account.ShippingCity, Contract_Duration_Months__c, Duration__c, CAP_Number__c, isInternal__c, '+
                            'Project_Purpose__c, Location__c, Project_Start__c, Project_Start_Other__c, Client_Description__c, Benefits__c, Job_Rate__c, Job_Rating__c, RecordType.Name, Skill_Group__c, Skill_Group__r.Name, LegacySkillGroupId__c, '+
                            'Owner.Name, Owner.Email, Recruiter_Email__c, isClosed, LegacyOpaID__c, CreatedDate, MD_Description__c, '+
                            '(SELECT id, Job__c, Type__c, Level__c, Skill__r.Name, Skill__r.LegacySkillId__c, Skill__r.Alias__c, '+
                                'LegacyObjectID__c, LegacyOpaID__c, LegacySkillID__c '+
                                'FROM Skill_Associations__r) '+
                        'FROM Opportunity';
        String requestQuery = RestContext.request!=null ? (RestContext.request.requestBody!=null ? RestContext.request.requestBody.toString() : '') : '';
        if (!String.isBlank(requestQuery)) {
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(requestQuery);
            String dateFrom = RestContext.request!=null ? (String)params.get('dateFrom') : '';
            if (!String.isBlank(dateFrom)) {
                try {
                    DateTime modifyFilter = DateTime.valueOf(dateFrom);//(Datetime)JSON.deserialize(dateFrom, DateTime.class);//"2018-10-01T00:00:00Z"
                    system.debug('modifyFilter: '+modifyFilter);
                } catch (Exception e) {
                    system.debug('Error during date pasing: '+e.getMessage());
                }
                query +=' WHERE LastModifiedDate>=:modifyFilter';
            }
            String closedOnly = RestContext.request!=null ? (String)params.get('closedOnly') : null;
            query+= (!String.isBlank(closedOnly)) ? (query.contains('WHERE') ? ' AND isClosed='+closedOnly : ' WHERE isClosed='+closedOnly) : '';
            String contentOnly = RestContext.request!=null ? (String)params.get('contentOnly') : null;
            if (!String.isBlank(contentOnly)) {
                if (contentOnly=='true') {
                    query+= query.contains('WHERE') ? ' AND Job_Type__c=\'Content\'' : ' WHERE Job_Type__c=\'Content\'';
                } else {
                    query+= query.contains('WHERE') ? ' AND Job_Type__c!=\'Content\'' : ' WHERE Job_Type__c!=\'Content\'';
                }
                system.debug('query: '+query);
            }
            String publishedOnly = RestContext.request!=null ? (String)params.get('publishedOnly') : '';
            query+= (!String.isBlank(publishedOnly)) ? (query.contains('WHERE') ? ' AND Publish__c='+publishedOnly : ' WHERE Publish__c='+publishedOnly) : '';
            String lastId = RestContext.request!=null ? (String)params.get('lastId') : '';
            query+= (!String.isBlank(lastId)) ? (query.contains('WHERE') ? ' AND Id>:lastId' : ' WHERE Id>:lastId') : '';
            query+=' ORDER BY Id ASC';
            String limitNum = RestContext.request!=null ? (String)params.get('limitNum') : '';
            query+= !String.isBlank(limitNum) ? ' LIMIT '+Integer.valueOf(limitNum) : '';
        }
        List<Opportunity> tmpList = new List<Opportunity>();
        try {
            tmpList = Database.query(query);
        } catch (Exception e) {
            system.debug('Error during job sync: '+e.getMessage());
        }
        return tmpList;
    }
    /*
        'city' -> Account.ShippingCity
        'slug' -> ...
        'effort' -> Effort__c
        'region' -> Account.Account_Region__c
        'online' -> Publish__c
        'status' -> StageName
        'on_hold' -> ?
        'job_type' -> Job_Type__c (Content, CW, E4O, Live)
        'location' -> Work_Location__c
        'workplace' -> ?
        'operation' -> ?
        'reference' -> ?
        'vacancy_type' -> ?
        'experience_level' -> Experience__c / Level__c
        'contract_duration' -> Contract_Duration_Months__c / Duration__c
        'recruiter' -> ?
        'desired_disciplines' -> Desired_Skills__c
        'skills' -> Skill_Associations__r (Type__c, Level__c, Skill__r.Name, Skill__r.LegacySkillId__c, Skill__r.Alias__c)
        'time_of_commencement' -> ?
        'required_disciplines' -> Required_Skills_Text__c / Technical__c
        'salary_range' -> Min_Rate__c / Max_Rate__c
        'job_function' -> Function__c
        'description' -> Description
    */

    @HttpGet
    global static List<Deleted_Job__c> getDeletedJobs() {
        return [SELECT Id, JobID__c, LegacyId__c, DeletedDate__c, Owner.Name FROM Deleted_Job__c];
    }
}