@isTest
public with sharing class candidateReviewControllerTest {
  @isTest
  static void getAllRequestsTest() {
    PortalRequest__c request = new PortalRequest__c();
    request.Status__c = 'New';
    insert request;

    List<PortalRequest__c> requests = candidateReviewController.getAllRequests();

    System.assertEquals(false, requests.isEmpty());
  }

  @isTest
  static void rejectRequestTest() {
    PortalRequest__c request = new PortalRequest__c();
    insert request;

    candidateReviewController.rejectRequest(request.Id);

    List<PortalRequest__c> requests = [
      SELECT Id, Status__c
      FROM PortalRequest__c
      WHERE Id = :request.Id
    ];

    System.assertEquals('Rejected', requests[0].Status__c);
  }

  @isTest
  static void approveRequestTest() {
    PortalRequest__c request = new PortalRequest__c();
    Contact tempContact = new Contact();
    tempContact.FirstName = 'TestName';
    tempContact.LastName = 'TestLastname';
    insert tempContact;

    request.Candidate__c = tempContact.Id;
    request.FirstName__c = 'reqFirstName';
    request.LastName__c = 'reqLastName';

    insert request;

    candidateReviewController.approveRequest(request.Id);
    List<PortalRequest__c> requests = [
      SELECT Id, Status__c
      FROM PortalRequest__c
      WHERE Id = :request.Id
    ];

    System.assertEquals('Approved', requests[0].Status__c);
  }

  @isTest
  static void createReviewRequestTest() {
    List<websitePushCandidates.skillWrapper> mySkills = new List<websitePushCandidates.skillWrapper>();

    websitePushCandidates.skillWrapper skill = new websitePushCandidates.skillWrapper();
    skill.sf_id = 'testSfId';
    skill.skill_name = 'testSkillName';
    mySkills.add(skill);

    websitePushCandidates.candidateWrapper candidate = new websitePushCandidates.candidateWrapper();
    String[] title = new List<String>();
    title.add('testTitle');
    candidate.candidate_title = title;
    candidate.city = 'TestCity';
    candidate.country = 'Country';
    Date myDate = Date.newInstance(1960, 2, 17);
    candidate.date_of_birth = myDate;
    candidate.display_name = 'Name';
    candidate.first_name = 'FirstName';
    candidate.house_number = 'hNum';
    candidate.inzet = 'inzet';
    candidate.Last_name = 'lastName';
    candidate.linkedin_profile = 'profile';
    candidate.location = 'location';
    candidate.phone_number = 'num';
    candidate.portal_id = 'portalId';
    candidate.postal_code = 'code';
    candidate.radius = 'radius';
    candidate.sf_id = '';
    candidate.skills = mySkills;
    candidate.start_from_date = myDate;
    candidate.street = 'street';
    candidate.user_id = 'userid';

    List<websitePushCandidates.candidateWrapper> candidates = new List<websitePushCandidates.candidateWrapper>{
      candidate
    };

    candidateReviewController.createReviewRequest(candidates);
    String temp = 'FirstName';
    List<PortalRequest__c> req = [
      SELECT Id, Status__c
      FROM PortalRequest__c
      WHERE FirstName__c = :temp
    ];
    System.assertEquals(false, req.IsEmpty());
  }
}
