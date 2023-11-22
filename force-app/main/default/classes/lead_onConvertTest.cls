@IsTest
public class lead_onConvertTest {

    private static final String ACC_NAME = 'Test Acc';
    private static final String CON_NAME = 'Test Con';

    @TestSetup
	private static void setup() {
        Account acc = new Account(Name = ACC_NAME);
        insert acc;
        Lead lead = new Lead ( 
            FirstName = 'Test',
            LastName = 'Sample',
            Company = 'Testing Sample Co' 
        ); 
        insert lead;  
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Contact con01 = new Contact(
            LastName = CON_NAME,
            Email = 'testContact01@gmail.com',
            RecordTypeId = conRecordTypeId,
            AccountId = acc.Id
        );
        insert con01;
        Qualification_Question__c qq = new Qualification_Question__c ();
        qq.Question__c = 'test Q';
        qq.Object__c = 'ACCOUNT; CONTACT';
        insert qq;
        Qualification_Answer__c qa = new Qualification_Answer__c ();
        qa.Lead__c = lead.Id;
        qa.Answer__c = 'Test';
        qa.Qualification_Question__c = qq.Id;
        insert qa;
        Skill__c s = new Skill__c();
        s.Name = 'Test Skill';
        insert s;
        Skill_Association__c sa = new Skill_Association__c();
        sa.Lead__c = lead.Id;
        sa.Skill__c = s.Id;
        insert sa;
    }
    
    @IsTest
    static void testLeadConvert() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        Database.LeadConvert lc = new Database.LeadConvert();  
        lc.setLeadId(lead.Id);  
        lc.setConvertedStatus('Qualified'); 
        lc.setAccountId(acc.Id); 
        lc.setContactId(con.Id); 
        Database.LeadConvertResult lcr = Database.convertLead(lc, true);  
        Test.stopTest();
        Skill_Association__c skill = [SELECT Account__c, Contact__c FROM Skill_Association__c LIMIT 1];
        Qualification_Answer__c answer = [SELECT Account__c, Contact__c FROM Qualification_Answer__c LIMIT 1];
        System.assertEquals(acc.Id, skill.Account__c);
        System.assertEquals(con.Id, skill.Contact__c);
        System.assertEquals(acc.Id, answer.Account__c);
        System.assertEquals(con.Id, answer.Contact__c);
    }
}