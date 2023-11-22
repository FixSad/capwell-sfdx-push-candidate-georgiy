@IsTest
public class EmailHandlerTest {

    private static final String EMAIL = 'twothousandninteen.twoseventwoone93@test.com';

    @TestSetup
	private static void setup() {
        TestDataFactory.TestData data = TestDataFactory.generateData();
        data.contact.Email = EMAIL;
        data.contact.AccountId = data.acc.Id;
        update data.contact;
        Candidate_Mailshot__c tmpRec = new Candidate_Mailshot__c();
        tmpRec.Contact__c = data.contact.Id;
        tmpRec.Mailshot__c = data.mailshot.Id;
        insert tmpRec; 
    }

    @IsTest
	public static void testHandleInboundEmail() {
        Candidate_Mailshot__c mailShot = [SELECT Id FROM Candidate_Mailshot__c LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        List<String> toadd = new List<String>{'twothousandninteen.twoseventwoone93@test.com'};
        toadd.add('twothousandninteen.twoseventwoone93@test.example.com');
        email.subject = 'Test Email';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye'+'\n [Ref::'+mailShot.Id+']';
        email.fromAddress = UserInfo.getUserEmail();
        email.toAddresses = toadd;
        email.ccAddresses = toadd;
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.Filename = 'test.txt';
        textAttachment.body ='my attachment text';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment };
        Test.startTest();
        EmailHandler objconfirm = new EmailHandler();
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        Test.stopTest();
        System.assertEquals(true, result.success, 'Email Processed');
    }
}