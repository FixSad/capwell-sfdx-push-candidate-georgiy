@IsTest
public with sharing class MailshotControllerTest {
    
    @TestSetup
	private static void setup() {
        TestDataFactory.TestData data = TestDataFactory.generateData();
        Task task = new Task();
        task.Subject = 'Email';
        task.Mailshot_Email__c = true;
        task.WhoId = data.contact.id;
        task.WhatId = data.mailshot.id;
        insert task;
    }

    @IsTest 
    static void testGetNextRecord() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Test.startTest();
        List<Task> tasks = MailshotController.getNextRecord(mailshot.Id, 0);
        Test.stopTest();
        System.assertEquals(1, tasks.size());
    }

    @IsTest 
    static void testGetTotalRecords() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Test.startTest();
        Integer total = MailshotController.getTotalRecords(mailshot.id);
        Test.stopTest();
        System.assertEquals(1, total);
    }

    @IsTest
    static void testSaveCallLog() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        MailshotController.saveCallLog(mailshot.id, con.Id, 'Completed', 'lorem ipsum, zombie ipsum', '');
        Test.stopTest();
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :mailshot.id];
        System.assertEquals(2, tasks.size());
    }

    @IsTest
    static void testGetShotlistCandidates() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Test.startTest();
        List<Contact> contacts = MailshotController.getShotlistCandidates(mailshot.Id);
        Test.stopTest();
        System.assertEquals(1, contacts.size());
    }

    @IsTest 
    static void testToggleShortListStatus01() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        MailshotController.toggleShortListStatus(mailshot.Id, con.Id, 'yes');
        Test.stopTest();
        Task expectedTask = [SELECT Id, Shotlisted__c FROM Task LIMIT 1];
        System.assertEquals(true, expectedTask.Shotlisted__c);
    }

    @IsTest 
    static void testToggleShortListStatus02() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        MailshotController.toggleShortListStatus(mailshot.Id, con.Id, 'no');
        Test.stopTest();
        Task expectedTask = [SELECT Id, Shotlisted__c FROM Task LIMIT 1];
        System.assertEquals(false, expectedTask.Shotlisted__c);
    }

    @IsTest 
    static void testMailshot() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Candidate_Mailshot__c tmpRec = new Candidate_Mailshot__c();
        tmpRec.Contact__c = con.Id;
        tmpRec.Mailshot__c = mailshot.Id;
        insert tmpRec;
        Test.startTest();
        MailshotController.sendMailshot(new List<Id>{mailshot.Id});
        Test.stopTest();
        //todo
    }

    @IsTest
    static void testMassMailshot() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        List<Contact> tmpCont = new List<Contact>();
        List<Candidate_Mailshot__c> tmpList = new List<Candidate_Mailshot__c>();
        for (Integer i=0; i<14; i++) {
            tmpCont.add(new Contact(LastName='Doe'+i, Email='r.mikita+'+i+'@capwell.nl'));
        }
        insert tmpCont;
        for (Contact ct : tmpCont) {
            Candidate_Mailshot__c tmpRec = new Candidate_Mailshot__c();
            tmpRec.Contact__c = ct.Id;
            tmpRec.Mailshot__c = mailShot.Id;
            tmpList.add(tmpRec);
        }
        insert tmpList;
        Test.startTest();
	        MailshotController.sendMailshot(new List<Id>{mailShot.Id});
        Test.stopTest();
        //todo
    }

    @IsTest
    static void testAllMailshot01() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Contact con = [SELECT Email FROM Contact LIMIT 1];
        Candidate_Mailshot__c tmpRec = new Candidate_Mailshot__c();
        tmpRec.Contact__c = con.Id;
        tmpRec.Mailshot__c = mailshot.Id;
        insert tmpRec;
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        emailMessage.relatedToId = mailshot.Id; // related to record e.g. an opportunity
        emailMessage.fromAddress = 'sender@example.com'; // from address
        emailMessage.fromName = 'Dan Perkins'; // from name
        emailMessage.subject = 'This is the Subject!'; // email subject
        emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body
        // Contact, Lead or User Ids of recipients
        String[] toIds = new String[]{con.Id}; 
        emailMessage.toIds = toIds;
        // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
        emailMessage.toAddress = con.Email;
        insert emailMessage; // insert
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.emailMessageId = emailMessage.id;
        emr.relationId = con.Id; // user id of the sender
        emr.relationType = 'ToAddress';
        insert emr;
        EmailMessage emailMessage1 = new EmailMessage();
        emailMessage1.status = '3'; // email was sent
        emailMessage1.relatedToId = mailshot.Id; // related to record e.g. an opportunity
        emailMessage1.fromAddress = 'sender@example.com'; // from address
        emailMessage1.fromName = 'Dan Perkins'; // from name
        emailMessage1.subject = 'This is the Subject!'; // email subject
        emailMessage1.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body
        emailMessage1.toAddress = 'test.mailshot@example.capwell.nl';
        insert emailMessage1; // insert
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr1 = new EmailMessageRelation();
        emr1.emailMessageId = emailMessage1.id;
        emr1.RelationAddress = 'test.mailshot@example.capwell.nl';
        emr1.relationType = 'ToAddress';
        insert emr1;
        Test.startTest();
        MailshotController.sendMailshot(new List<Id>{mailshot.Id});
        List<MailshotController.MailshotResult> result = MailshotController.mailShotCandidatesResults(mailshot.Id, 'all');
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
    }

    @IsTest
    static void testAllMailshot02() {
        Mailshot__c mailShot = [SELECT Id FROM Mailshot__c LIMIT 1];
        Contact con = [SELECT Email FROM Contact LIMIT 1];
        Candidate_Mailshot__c tmpRec = new Candidate_Mailshot__c();
        tmpRec.Contact__c = con.Id;
        tmpRec.Mailshot__c = mailshot.Id;
        insert tmpRec;
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        emailMessage.relatedToId = mailshot.Id; // related to record e.g. an opportunity
        emailMessage.fromAddress = 'sender@example.com'; // from address
        emailMessage.fromName = 'Dan Perkins'; // from name
        emailMessage.subject = 'This is the Subject!'; // email subject
        emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body
        // Contact, Lead or User Ids of recipients
        String[] toIds = new String[]{con.Id}; 
        emailMessage.toIds = toIds;
        // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
        emailMessage.toAddress = con.Email;
        insert emailMessage; // insert
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.emailMessageId = emailMessage.id;
        emr.relationId = con.Id; // user id of the sender
        emr.relationType = 'ToAddress';
        insert emr;
        EmailMessage emailMessage1 = new EmailMessage();
        emailMessage1.status = '3'; // email was sent
        emailMessage1.relatedToId = mailshot.Id; // related to record e.g. an opportunity
        emailMessage1.fromAddress = 'sender@example.com'; // from address
        emailMessage1.fromName = 'Dan Perkins'; // from name
        emailMessage1.subject = 'This is the Subject!'; // email subject
        emailMessage1.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body
        emailMessage1.toAddress = 'test.mailshot@example.capwell.nl';
        emailMessage1.IsBounced = true;
        insert emailMessage1; // insert
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr1 = new EmailMessageRelation();
        emr1.emailMessageId = emailMessage1.id;
        emr1.RelationAddress = 'test.mailshot@example.capwell.nl';
        emr1.relationType = 'ToAddress';
        insert emr1;
        Test.startTest();
        MailshotController.sendMailshot(new List<Id>{mailshot.Id});
        List<MailshotController.MailshotResult> result = MailshotController.mailShotCandidatesResults(mailshot.Id, 'bounced');
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }
}