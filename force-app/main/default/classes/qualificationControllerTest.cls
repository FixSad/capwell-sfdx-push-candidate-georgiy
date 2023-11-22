@IsTest 
public class qualificationControllerTest {

    private static final String ACC_NAME = 'Test Acc';

    @TestSetup
	private static void setup() {
        Account acc = new Account(
            Name = ACC_NAME,
            RecordTypeId =  Schema.sObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId(),
            Status__c = 'New'
        );
        insert acc;
        Qualification_Question__c ques = new Qualification_Question__c(
            Question__c = 'test',
            Object__c = 'Account'
        );
        insert ques;
        insert new Qualification_Answer__c(
            Qualification_Question__c = ques.Id,
            Account__c = acc.Id,
            Answer__c = 'Test'
        );
        insert new Lead(
            LastName = 'Lead Name',
            Status = 'New'
        );
        insert new Opportunity(
            Name = 'Test Opp',
            StageName = 'New',
            CloseDate = Date.today().addDays(30)
        );
    }

    @IsTest
    public static void testGetQuestions() {
        Account acc = [SELECT RecordType.Name FROM Account WHERE Name =: ACC_NAME LIMIT 1];
        Test.startTest();
        List<Qualification_Question__c> result = qualificationController.getQuestions('Account', acc.Id, '');
        Test.stopTest();
        System.assertEquals(false, result.isEmpty());
        System.assertEquals(1, result.size());
    }

    @IsTest
    public static void testSaveAnswers() {
        Qualification_Answer__c answer = [SELECT Qualification_Question__c, Account__c, Answer__c FROM Qualification_Answer__c LIMIT 1];
        Test.startTest();
        qualificationController.saveAnswers('Account', JSON.serialize(new List<Qualification_Answer__c>{answer}));
        Test.stopTest();
        List<Qualification_Answer__c> result = [SELECT Qualification_Question__c, Account__c, Answer__c FROM Qualification_Answer__c];
        System.assertEquals(false, result.isEmpty());
        System.assertEquals(1, result.size());
        System.assertEquals(answer.Qualification_Question__c, result[0].Qualification_Question__c);
        System.assertEquals(answer.Account__c, result[0].Account__c);
        System.assertEquals(answer.Answer__c, result[0].Answer__c);
    }
    
    @IsTest
    public static void testGetStatuses() {
        Test.startTest();
        List<String> accStatusList = qualificationController.getStatuses('Account');
        List<String> leadStatusList = qualificationController.getStatuses('Lead');
        List<String> oppStatusList = qualificationController.getStatuses('Opportunity');
        List<String> conStatusList = qualificationController.getStatuses('Contact');
        Test.stopTest();
        System.assertEquals(false, accStatusList.isEmpty());
        System.assertEquals(false, leadStatusList.isEmpty());
        System.assertEquals(false, oppStatusList.isEmpty());
        System.assertEquals(false, conStatusList.isEmpty());
    }

    @IsTest
    public static void testGetRecordStatus() {
        Account acc = [SELECT Id FROM Account WHERE Name =: ACC_NAME LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String accStatus = qualificationController.getRecordStatus('Account', acc.Id);
        String oppStatus = qualificationController.getRecordStatus('Opportunity', opp.Id);
        String leadStatus = qualificationController.getRecordStatus('Lead', lead.Id);
        Test.stopTest();
        System.assertEquals('New', accStatus);
        System.assertEquals('New', oppStatus);
        System.assertEquals('New', leadStatus);
    }
}