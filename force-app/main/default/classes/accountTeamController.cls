public class accountTeamController {
    @AuraEnabled
    public static List<teamWrapper> getAccountTeam(String id){
        List<teamWrapper> teams = new List<teamWrapper>();
        List<Account_Team__c> accTeams = [SELECT Id, Name FROM Account_Team__c WHERE Account__c=:id];
        for (Account_Team__c at : accTeams) {
            teamWrapper tmpRec = new teamWrapper();
            tmpRec.id = at.Id;
            tmpRec.name = at.Name;
            tmpRec.type = 'team';
            teams.add(tmpRec);
        }
        for (Contact ct : [SELECT Id, Name, Title, Phone, Email, Account_Team__c, Account_Team__r.Name FROM Contact WHERE AccountId=:id AND RecordType.DeveloperName='Contact']) {
            if (String.isBlank(ct.Account_Team__c)) {
                teams.add(addContact(ct));
            } else {
                for (teamWrapper tw : teams) {
                    if (tw.id==ct.Account_Team__c) {
                        if (tw.children==null) {
                            tw.children = new List<teamWrapper>{addContact(ct)};
                        } else {
                            tw.children.add(addContact(ct));
                        }
                        break;
                    }
                }
            }
        }
        return teams;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Team__c> getTeams(String accountId){
        return [SELECT Id, Name FROM Account_Team__c WHERE Account__c=:accountId];
    }

    @AuraEnabled
    public static void logContactCall(String subj, String descr, String res, String whoId, String whatId) {
        if (!String.isBlank(whoId) && !String.isBlank(whatId)) {
            Task t = new Task();
            t.Subject = subj;
            t.Description = descr;
            t.CallDisposition = res;
            t.WhoId = whoId;
            t.WhatId = whatId;
            t.ActivityDate = Date.today();
            t.Type = 'Call';
            t.TaskSubtype = 'Call';
            t.Status = 'Completed';
            insert t;
        }
    }

    private static teamWrapper addContact(Contact ct) {
        teamWrapper tmpRec = new teamWrapper();
        tmpRec.id = ct.Id;
        tmpRec.name = ct.Name;
        tmpRec.title = ct.Title;
        tmpRec.phone = ct.Phone;
        tmpRec.email = ct.Email;
        tmpRec.type = 'contact';
        tmpRec.team = ct.Account_Team__c;
        return tmpRec;
    }

    public class teamWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String title;
        @AuraEnabled public String phone;
        @AuraEnabled public String email;
        @AuraEnabled public String type;
        @AuraEnabled public String team;
        @AuraEnabled public List<teamWrapper> children;
        @AuraEnabled public List<Skill_Association__c> skills;
        @AuraEnabled public Decimal distance;
    }

    public static void autoCreateTeams(List<Account> accounts) {
        List<Account_Team__c> tmpList = new List<Account_Team__c>();
        for (Account acc : accounts) {
            if (!String.isBlank(acc.IT_Teams__c)) {
                List<String> teams = acc.IT_Teams__c.split(';');
                for (String tName : teams) {
                    Account_Team__c tmpRec = new Account_Team__c();
                    tmpRec.Account__c = acc.Id;
                    tmpRec.Name = tName.trim();
                    tmpList.add(tmpRec);
                }
            }
        }
        if (!tmpList.isEmpty()) {
            insert tmpList;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getContactAccounts(String contactId) {
        return [SELECT id, Accountid, Account.Name, IsDirect, Roles, StartDate FROM AccountContactRelation WHERE IsActive=true AND ContactId=:contactId];
    }
}