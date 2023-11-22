public without sharing class qualificationController {
    @AuraEnabled(cacheable=true)
    public static List<Qualification_Question__c> getQuestions(String objectName, String Id, String recordTypeName) {
        //objectName = String.isNotBlank(objectName) ? (objectName.toLowerCase()=='opportunity' ? 'job' : objectName) : '';
        String objectNameCompare = String.isNotBlank(objectName) ? (objectName.toLowerCase()=='opportunity' ? 'job' : objectName) : '';
        if(String.isBlank(recordTypeName)){
            string query = 'select recordType.Name from '+objectName+' where id=:Id';
            system.debug(query);
            Sobject sobj=Database.query(query);
            recordTypeName = (String) sobj.getSobject('recordType').get('Name');
        }
        if (String.isNotBlank(objectName)) {
            String query = 'SELECT Id, Question__c, Stage_Value__c, Answer_Options__c, Answer_Type__c, Field_Name__c, Use_in_Summary__c, Description__c, isActive__c, isRequired__c, ';
            query +=            '(Select id, Answer__c, CreatedBy.Name, CreatedDate from Qualification_Answers__r WHERE '+objectName+'__c =:Id ORDER BY CreatedDate DESC) ';
            query +=        'FROM Qualification_Question__c WHERE Object__c LIKE \'%'+objectNameCompare+'%\' ';
            query +=        String.isNotBlank(recordTypeName) ? ' AND (Record_Type__c=:recordTypeName OR Record_Type__c=null) ' : '';
            query +=        'ORDER By Order__c';
            system.debug(query);
            return (List<Qualification_Question__c>)Database.query(query);
        } else {
            return null;
        }
    }

    @AuraEnabled(cacheable=false)
    public static void saveAnswers(String objectName, String answers) {
        system.debug(answers);
        if (!String.isBlank(objectName) && !String.isBlank(answers)) {
            List<Qualification_Answer__c> tmpList = (List<Qualification_Answer__c>) JSON.deserialize(answers, List<Qualification_Answer__c>.class);
            if (!tmpList.isEmpty()) {
                upsert tmpList;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getStatuses(String objectName) {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult;
        switch on objectName {
            when 'Account' {
                fieldResult = Account.Status__c.getDescribe();
            }
            when 'Lead' {
                fieldResult = Lead.Status.getDescribe();
            }
            when 'Opportunity' {
                fieldResult = Opportunity.StageName.getDescribe();
            }
            when 'Contact' {
                fieldResult = Contact.Status__c.getDescribe();
            }
        }
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordStatus(String objectName, String Id) {
        String res='';
        String query = 'SELECT ';
        switch on objectName {
            when 'Account', 'Contact' {
                query+= ' Status__c ';
            }
            when 'Lead' {
                query += ' Status ';
            }
            when 'Opportunity' {
                query += ' StageName ';
            }
        }
        query += 'FROM '+objectName+' WHERE Id=:Id';
        List<sObject> tmp = Database.query(query);
        if (tmp!=null && !tmp.isEmpty()) {
            switch on objectName {
                when 'Account', 'Contact' {
                    res = (String)tmp[0].get('Status__c');
                }
                when 'Lead' {
                    res = (String)tmp[0].get('Status');
                }
                when 'Opportunity' {
                    res = (String)tmp[0].get('StageName');
                }
            }
        }
        return res;
    }
}