@IsTest
public class UniversalContactTileControllerTest {
    
    @TestSetup
	private static void setup() {
        Account acc01 = new Account(Name = 'Test Account 01');
        insert acc01;
        Contact con01 = new Contact(
            LastName = 'Test Contact Name',
            Title = 'Lead',
            AccountId = acc01.Id
        );
        insert con01;
        Skill__c skill = new Skill__c (Name = 'Skill');
        insert skill;
        insert new Skill_Association__c(
            Contact__c = con01.Id,
            Account__c = acc01.Id
        );
    }

    @IsTest
    static void testGetContactDetail() {
        Schema.DescribeSObjectResult r = Contact.sObjectType.getDescribe();
        List<String> fieldsApiNames =  new List<String>();
        for(String apiName : r.fields.getMap().keySet()){
            fieldsApiNames.add(apiName);
        }
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        Contact result = UniversalContactTileController.getContactDetail(conId, fieldsApiNames);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(conId, result.Id);
        System.assertEquals(1, result.Skill_Associations__r.size());
    }

    
    @IsTest
    static void testGetContactDetailNegative() {
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        try {
        Test.startTest();
        Contact result = UniversalContactTileController.getContactDetail(conId, new List<String>());
        Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('System.ListException', e.getTypeName());
        }
    }
}
