@IsTest
public with sharing class webformRegistrationTest {

    @IsTest
    static void testRegisterClient() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/webform/Register';       
        String postData = '{ "type" : "client", "firstName" : "John", '+
            ' "lastName" : "Smith", "company" : "Acme Corp.", "requestType" : "Zoekprofiel doorgeven", '+
            ' "email" : "roman.mikita@gmail.com" }';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String resp = webformRegistration.webformRegister();
        Test.stopTest();
        System.assertEquals('Success', resp);
    }

    @IsTest
    static void testRegisterContact() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/webform/Register';       
        String postData = '{ "type" : "contact", "firstName" : "John", '+
            ' "lastName" : "Smith", "company" : "Acme Corp.", "requestType" : "Zoekprofiel doorgeven", '+
            ' "email" : "roman.mikita@gmail.com", "city" : "Den Haag", "radius" : "10", "latitude": "86.2333033", "longitude": "4.3232999","fileBase64" : "Test", "fileExtension" : "txt" }';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String resp = webformRegistration.webformRegister();
        Test.stopTest();
        System.assertEquals('Success', resp);
    }
    
    @IsTest
    static void testRequestContact() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/webform/Register';       
        String postData = '{ "type" : "client", "firstName" : "John", '+
            ' "lastName" : "Smith", "company" : "Acme Corp.", "requestType" : "Beschikbaarheid aanvragen", '+
            ' "email" : "roman.mikita@gmail.com", "requestContact" : "r.m@cloud.com.example" }';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String resp = webformRegistration.webformRegister();
        Test.stopTest();
        System.assertEquals('Success', resp);
    }
    
    @IsTest
    static void testApplyContact() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/webform/Register';       
        String postData = '{ "type" : "direct", "firstName" : "John", '+
            ' "lastName" : "Smith", "company" : "Acme Corp.", '+
            ' "email" : "roman.mikita@gmail.com", "jobLegacyID" : "111", "fileBase64" : "Test", "fileExtension" : "txt" }';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String resp = webformRegistration.webformRegister();
        Test.stopTest();
        System.assertEquals('Success', resp);
    }
    
}