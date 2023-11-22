@IsTest
public class homeComponentsControllerTest {

    @TestSetup
	private static void setup() {
        insert new Lead(LastName = 'Test Lead');
        Opportunity opp =  new Opportunity(
            LegacyOpaID__c= '123',
            Name='Test Job',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            Publish__c = true
        );
        insert opp;
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Contact con = new Contact(
            LastName = 'Contact Name',
            Email = 'testcontact01@gmail.com',
            RecordTypeId = conRecordTypeId
        );
        insert con;
        insert new Applicant__c(
            Candidate__c = con.Id,
            Job__c = opp.Id
        );
    } 

    @IsTest
    static void testGetLeads() {
        Test.startTest();
        List<Lead> leadList = homeComponentsController.getLeads();
        Test.stopTest();
        System.assertNotEquals(null, leadList);                                                                 
        System.assertEquals(1, leadList.size());        
    }

    @IsTest
    static void testGetJobs() {
        Test.startTest();
        List<Opportunity> oppList = homeComponentsController.getJobs();
        Test.stopTest();
        System.assertNotEquals(null, oppList);                                                                 
        System.assertEquals(1, oppList.size());        
    }

    @IsTest
    static void testGetApplicants() {
        Test.startTest();
        List<Applicant__c> appList = homeComponentsController.getApplicants();
        Test.stopTest();
        System.assertNotEquals(null, appList);                                                                 
        System.assertEquals(1, appList.size());        
    }
}