@IsTest
public with sharing class SearchJobControllerTest {

    @TestSetup
	private static void setup() {
        Opportunity opp01 =  new Opportunity(
            LegacyOpaID__c='1',
            Name='Test Job 1',
            Job_Type__c='Content',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        Opportunity opp02 = new Opportunity(
            LegacyOpaID__c='2',
            Name='Test Job 2',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        insert new List<Opportunity>{opp01, opp02};
    } 

    @IsTest 
    static void searchJobByType() {
        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();
        jobReq.jobType = 'Content';
        SearchJobControllerTest.mockRequest(jobReq);
        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        System.assertEquals(1, response.records.size());
        System.assertEquals(1, response.total);

        jobReq.jobType = '';
        SearchJobControllerTest.mockRequest(jobReq);
        response = SearchJobController.getJobsByFilters(jobReq);
        System.assertEquals(2, response.records.size());
        System.assertEquals(2, response.total);

        jobReq.jobType = null;
        SearchJobControllerTest.mockRequest(jobReq);
        response = SearchJobController.getJobsByFilters(jobReq);
        System.assertEquals(2, response.records.size());
        System.assertEquals(2, response.total);
    }

    @IsTest 
    static void searchJobBySkills() {
        Skill__c skill01 = new Skill__c(Name='apex');
        Skill__c skill02 = new Skill__c(Name='lwc');
        insert new List<Skill__c>{skill01, skill02};
        Opportunity testJob1 = [SELECT Id FROM Opportunity WHERE Name = 'Test Job 1' LIMIT 1];
        Opportunity testJob2 = [SELECT Id FROM Opportunity WHERE Name = 'Test Job 2' LIMIT 1];
        Skill_Association__c skillAssociation01 = new Skill_Association__c(
			Skill__c = skill01.Id,
            Job__c = testJob1.Id,
			isActive__c = true
        );
        Skill_Association__c skillAssociation02 = new Skill_Association__c(
			Skill__c = skill02.Id,
            Job__c = testJob2.Id,
			isActive__c = true
        );
        insert new List<Skill_Association__c>{skillAssociation01, skillAssociation02};
        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();
        String[] skills = new List<String>();
        skills.add('\'' + skill01.Id + '\'');
        skills.add('\'' + skill02.Id + '\'');
        jobReq.skills = skills;
        jobReq.jobType = 'Content';
        SearchJobControllerTest.mockRequest(jobReq);
        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        System.assertEquals(1, response.records.size());
        System.assertEquals(1, response.total);
    
        jobReq = new SearchJobController.JobRequest();
        jobReq.jobType = 'Live';
        jobReq.skills = skills;
        SearchJobControllerTest.mockRequest(jobReq);
        response = SearchJobController.getJobsByFilters(jobReq);
        System.assertEquals(0, response.records.size());
        System.assertEquals(0, response.total);
    }

    /*
    @IsTest 
    static void searchJobByWorkplace() {
        insert new Opportunity(
            LegacyOpaID__c='1',
            Name='Test Job 1',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        insert new Opportunity(
            LegacyOpaID__c='2',
            Name='Test Job 2',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );

        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();
        jobReq.jobType = 'temp';

        String[] workplaces = new List<String>();
        workplaces.add('\'' + 'remote' + '\'');
        jobReq.workplaces = workplaces;
        SearchJobControllerTest.mockRequest(jobReq);

        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(1, response.records.size());
        //System.assertEquals(1, response.total);

        jobReq = new SearchJobController.JobRequest();
        jobReq.jobType = 'temp';

        workplaces = new List<String>();
        workplaces.add('\'' + 'remote' + '\'');
        workplaces.add('\'' + 'office' + '\'');
        jobReq.workplaces = workplaces;
        SearchJobControllerTest.mockRequest(jobReq);
        response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(2, response.records.size());
        //System.assertEquals(2, response.total);
    }

    @IsTest
    static void searchJobByExperience() {
        insert new Opportunity(
            LegacyOpaID__c='1',
            Name='Test Job 1',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        insert new Opportunity(
            LegacyOpaID__c='2',
            Name='Test Job 2',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );

        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();

        String[] experiences = new List<String>();
        experiences.add('\'' + 'junior' + '\'');

        jobReq.experiences = experiences;
        jobReq.jobType = 'temp';
        SearchJobControllerTest.mockRequest(jobReq);

        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(1, response.records.size());

        jobReq = new SearchJobController.JobRequest();

        experiences = new List<String>();
        experiences.add('\'' + 'junior' + '\'');
        experiences.add('\'' + 'senior' + '\'');

        jobReq.experiences = experiences;
        jobReq.jobType = 'temp';
        SearchJobControllerTest.mockRequest(jobReq);

        response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(2, response.records.size());
        //System.assertEquals(2, response.total);
    }

    @IsTest 
    static void searchJobByContractDuration() {
        insert new Opportunity(
            LegacyOpaID__c='1',
            Name='Test Job 1',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        insert new Opportunity(
            LegacyOpaID__c='2',
            Name='Test Job 2',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );

        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();

        Integer[] durations = new List<Integer>();
        durations.add(5);

        jobReq.durations = durations;
        jobReq.jobType = 'temp';
        SearchJobControllerTest.mockRequest(jobReq);

        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(1, response.records.size());

        jobReq = new SearchJobController.JobRequest();

        durations = new List<Integer>();
        durations.add(5);
        durations.add(10);

        jobReq.durations = durations;
        jobReq.jobType = 'temp';
        SearchJobControllerTest.mockRequest(jobReq);

        response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(2, response.records.size());
        //System.assertEquals(2, response.total);
    }

    @IsTest 
    static void searchJobBySalaryRange() {
        insert new Opportunity(
            LegacyOpaID__c='1',
            Name='Test Job 1',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        insert new Opportunity(
            LegacyOpaID__c='2',
            Name='Test Job 2',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );

        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();
        jobReq.jobType = 'temp';
        jobReq.minSalary = 500;
        jobReq.maxSalary = 1000;
        SearchJobControllerTest.mockRequest(jobReq);

        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(1, response.records.size());
        //System.assertEquals(1, response.total);
    }

    @IsTest 
    static void searchJobByDaysAvailabilityRange() {
        insert new Opportunity(
            LegacyOpaID__c='1',
            Name='Test Job 1',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        insert new Opportunity(
            LegacyOpaID__c='2',
            Name='Test Job 2',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );

        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();
        jobReq.jobType = 'temp';
        jobReq.minDays = 1;
        jobReq.maxDays = 3;
        SearchJobControllerTest.mockRequest(jobReq);

        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(1, response.records.size());
        //System.assertEquals(1, response.total);
    }

    @IsTest
    static void searchJobByDistance() {
        insert new Opportunity(
            LegacyOpaID__c='1',
            Name='Test Job 1',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );
        insert new Opportunity(
            LegacyOpaID__c='2',
            Name='Test Job 2',
            Job_Type__c='Live',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30)
        );

        SearchJobController.JobRequest jobReq = new SearchJobController.JobRequest();
        jobReq.jobType = 'temp';
        jobReq.latitude = 52.370216;
        jobReq.longitude = 4.895168;
        jobReq.radius = 10;
        SearchJobControllerTest.mockRequest(jobReq);

        SearchJobController.Response response = SearchJobController.getJobsByFilters(jobReq);
        //System.assertEquals(1, response.records.size());
        //System.assertEquals(1, response.total);
    }
    */

    public static void mockRequest(SearchJobController.JobRequest req) {
        RestRequest restReq = new RestRequest();
        restReq.requestURI = '/services/apexrest/Jobs/Search';
        restReq.httpMethod = 'POST';
        restReq.requestBody = Blob.valueOf(JSON.serialize(req));
        RestContext.request = restReq;
    }
}