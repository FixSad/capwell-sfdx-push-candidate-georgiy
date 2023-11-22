@RestResource(urlMapping='/webform/Register')
global with sharing class webformRegistration {

    @HttpPost
    global static String webformRegister() {
        String result;
        requestWrapper req = new requestWrapper();
        try {
            String request = RestContext.request.requestBody.toString();
            if (String.isBlank(request)) return 'Error: Empty request';
            req = (requestWrapper)JSON.deserialize(request, requestWrapper.class);
            system.debug('Request: '+req);
        } catch(JSONException e) {
            return 'Error: '+e.getMessage();
        }
        switch on req.type {
            when 'client', 'contact' {
                result = validateLead(req);
                if (result!='') return 'Error:' +result;
                result = req.type=='client' ? handleNewLead(req) : handleNewContact(req);
            }
            when 'direct' {
                result = handleNewApplication(req);
            }
            when else {
                result = 'Error: Invalid request type';
            }
        }
        return result;
    }

    private static String handleNewLead(requestWrapper value) {
        Lead newLead = createNewLead(value);
        newLead.Title = value.title;
        newLead.Level__c = value.level;
        newLead.Experience__c = value.experience;
        newLead.Effort__c = value.effort;
        newLead.Duration__c = value.duration;
        if (value.requestType=='Beschikbaarheid aanvragen') {
            if (value.requestContact!=null) {
                newLead.RequestedContact__c = getCandidate(value);
            } 
            else {
                return 'Error: Requested contact is empty';
            }
        }
        try {
            insert newLead;
        } catch (System.Exception e) {
            return 'Error: '+e.getMessage();
        }
        return 'Success';
    }

    private static String handleNewContact(requestWrapper value) {
        // add handle type=Vacatures and no Company => just Contact. What Contact status should be?
        Lead newLead = createNewLead(value);
        newLead.City__c = value.city;
        newLead.Radius__c = value.redius;
        newLead.Work_Location__longitude__s = value.longitude;
        newLead.Work_Location__latitude__s = value.latitude;
        try {
            insert newLead;
        } catch (System.Exception e) {
            return 'Error: '+e.getMessage();
        }
        if (value.fileBase64!=null)
            return handleFileUpload(
                newLead.Id,
                'CV-'+value.firstName+' '+value.lastName,
                'CV-'+value.firstName+' '+value.lastName+'.'+value.fileExtension,
                value.fileBase64
            );
        return 'Success';
    }

    private static Lead createNewLead(requestWrapper value) {
        Lead newLead = new Lead( Status = 'New', LeadSource = 'Website' );
        newLead.firstName = value.firstName;
        newLead.lastName = value.lastName;
        newLead.Email = value.email;
        newLead.Phone = value.phone;
        newLead.City = value.location;
        newLead.Company = value.company;
        newLead.Type__c = value.requestType;
        newLead.Functie__c = value.function;
        newLead.Description = value.description + (value.question!=null ? '\n'+value.question : '');
        newLead.Expected_Start__c = value.startDate;
        newLead.LeadSource = value.source;
        newLead.GCLID__c = value.gclid;
        newLead.utm_source__c = value.utm_source;
        newLead.utm_campaign__c = value.utm_campaign;
        newLead.utm_content__c = value.utm_content;
        newLead.utm_term__c = value.utm_term;
        return newLead;
    }

    private static String validateLead(requestWrapper value) {
        String result = '';
        if (String.isBlank(value.lastName)) result+=' - Last Name cannot be empty - ';
        // we can remove validation if Personal Accounts are on
        if (String.isBlank(value.company) && value.type=='client') {
            result+=' - Company cannot be empty - ';
        } else if (String.isBlank(value.company) && value.type=='contact') {
            value.company = 'Freelance';
        }
        return result;
    }

    private static String handleNewApplication(requestWrapper value) {
        if (String.isNotBlank(value.jobLegacyId) || String.isNotBlank(value.jobId)) {
            Applicant__c newAppl = new Applicant__c();
            if (String.isNotBlank(value.jobLegacyId)) {
                newAppl.Job__c = getJobLegacyID(value.jobLegacyID);
            } else {
                newAppl.Job__c = getJobByID(value.jobId);
            }
            newAppl.Candidate__c = getCandidate(value);
            newAppl.Status__c = 'New';
            if (newAppl.Job__c!=null) {
                try {
                    insert newAppl;
                } catch (Exception e) {
                    return 'Error: '+e.getMessage();
                }
                if (value.fileBase64!=null && value.fileExtension!=null) {
                    return handleFileUpload(
                        newAppl.Candidate__c, 
                        'CV-'+value.firstName+' '+value.lastName, 
                        'CV-'+value.firstName+' '+value.lastName+'.'+value.fileExtension, 
                        value.fileBase64
                    );
                }
            } else {
                return 'Error: Job ID is not found';
            }
        } else {
            return 'Error: Job ID is empty';
        }
        return 'Success';
    }

    private static String getJobByID(String strId) {
        List<Opportunity> appJob = [SELECT Id FROM Opportunity WHERE Id=:strId];
        if (!appJob.isEmpty()) {
            return appJob[0].Id;
        }
        return null;
    }

    private static String getJobLegacyID(String legacyId) {
        List<Opportunity> appJob = [SELECT Id FROM Opportunity WHERE LegacyOpaID__c=:legacyId];
        if (!appJob.isEmpty()) {
            return appJob[0].Id;
        } else {
            Opportunity tmpJob = new Opportunity();
            tmpJob.Name = legacyId;
            tmpJob.StageName = 'New';
            tmpJob.CloseDate = Date.today().addDays(30);
            tmpJob.LegacyOpaID__c = legacyId;
            insert tmpJob;
            return tmpJob.Id;
        }
    }

    private static String getCandidate(requestWrapper value) {
        String searchEmail = value.type=='direct' ? value.email : value.requestContact;
        List<Contact> contList = [SELECT Id FROM Contact WHERE Email=:searchEmail ORDER BY LastModifiedDate DESC];
        if (!contList.isEmpty())
            return contList[0].Id;
        else {
            Contact newContact = new Contact(
                Email = searchEmail
            );
            if (value.type=='direct') {
                newContact.FirstName = value.firstName;
                newContact.LastName = value.lastName;
                newContact.Phone = value.phone;
                newContact.Title = value.function;
                newContact.MailingCity = value.location;
            } else {
                newContact.LastName = 'Not Found';
            }
            insert newContact;
            return newContact.Id;
        }
    }

    private static String handleFileUpload(String Id, String title, String fileName, String base64) {
        try {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = fileName;
            conVer.Title = title;
            conVer.VersionData = EncodingUtil.base64Decode(base64);
            insert conVer;

            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = Id;
            cDe.ShareType = 'I';
            //cDe.Visibility = 'InternalUsers';
            insert cDe;
        } catch (Exception e) {
            return 'Error: '+e.getMessage();
        }
        return 'Success';
    }

    class requestWrapper {
        String function;
        String description;
        String effort;
        String duration;
        String startDate;
        String location;
        String question;
        String level;
        String experience;
        String requestType;
        String requestContact;

        String gclid;
        String utm_source;
        String utm_campaign;
        String utm_content;
        String utm_term;

        String city; 
        Integer redius;
        Decimal latitude;
        Decimal longitude;
        String fileBase64;
        String fileExtension;
        String jobLegacyId;
        String jobId;

        String company;
        String firstName;
        String lastName;
        String title;
        String phone;
        String email;

        String type;
        String source = 'Capwell';
    }
}