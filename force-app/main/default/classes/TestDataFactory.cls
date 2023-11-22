@IsTest
public class TestDataFactory {
    @TestVisible
    public static TestData generateData() {
        TestData res = new TestData();
        Account tmpAcc = new Account(Name='Test Acc');
        insert tmpAcc;
        res.acc = tmpAcc;

        Opportunity job = new Opportunity(
            LegacyOpaID__c= '123',
            Name='Test Job',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            Publish__c = true
        );
        insert job;
        res.job = job;
        
        Mailshot__c mailshot = new Mailshot__c(Job__c=res.job.id, Title__c=res.job.Name);
        mailshot.Subject__c='test email';
        mailshot.HTML_Body__c = 'Dear {!Contact.Name}. {!Contact.Email} We would like to to check our  . Please check full description on our website';
        mailshot.Type__c = 'Job';
        insert mailshot;
        res.mailshot = mailshot;
        
        Contact contact = new Contact(LastName='Doe', Email='r.mikita@capwell.nl');
        insert contact;
        res.contact = contact;

        return res;
    }

    public class TestData {
        public Opportunity job;
        public Mailshot__c mailshot;
        public Contact contact;
        public Account acc;
    }
}