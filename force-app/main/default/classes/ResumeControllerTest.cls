@IsTest
public with sharing class ResumeControllerTest {
    @IsTest
     static void testFindByContactId() {
        Contact contact = new Contact(LastName='Doe');
        insert contact;
        Resume__c resume = new Resume__c(Contact__c=contact.Id, Text__c='lorem ipsum');
        insert resume;
        Test.startTest();
        Resume__c record = ResumeController.findByContactId(contact.Id);
        Test.stopTest();
        System.assertEquals(resume.Contact__c, record.Contact__c);
    }
}