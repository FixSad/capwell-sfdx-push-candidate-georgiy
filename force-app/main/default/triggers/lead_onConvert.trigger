trigger lead_onConvert on Lead (after update) {
    List<Lead> currentLeads = trigger.new;
    Map<Id, Lead> mOldLeads = trigger.oldMap;
    Lead oldLead;
    Set<Id> convertedLeadId = new Set<Id>();
    map<String,String> mapAccount = new map<String,String>();
    map<String,String> mapContact = new map<String,String>();
    map<String,String> mapJob = new map<String,String>();
    for (Lead l : currentLeads) {
        oldLead = mOldLeads.get(l.Id);
        if (!oldLead.IsConverted && l.isConverted) {
            convertedLeadId.add(l.Id);
            if (l.convertedAccountId != null) 
                mapAccount.put(l.Id,l.convertedAccountId);
            if (l.convertedContactId != null) 
                mapContact.put(l.Id,l.convertedContactId);
            if (l.convertedOpportunityId != null) 
                mapJob.put(l.Id,l.convertedOpportunityId);
        }
    }
        
    list<Skill_Association__c> updateSAlst = new list<Skill_Association__c>();
    for(Skill_Association__c sa : [select Id,Lead__c from Skill_Association__c where Lead__c=:convertedLeadId]){
        Skill_Association__c sau = new Skill_Association__c(Id=sa.Id);
         sau.Account__c=mapAccount.get(sa.Lead__C);
         sau.Contact__c=mapContact.get(sa.Lead__C);
         sau.Job__c=mapJob.get(sa.Lead__C);
         updateSAlst.add(sau);
    }    
    
    if(!updateSAlst.isEmpty()) {
        update updateSAlst;
    }
    
    list<Qualification_Answer__c> updateQAlst = new  list<Qualification_Answer__c>();
    for(Qualification_Answer__c qa : [select Id,Qualification_Question__c,Qualification_Question__r.Object__c,Lead__c from Qualification_Answer__c where Lead__c=:convertedLeadId]){
            Qualification_Answer__c qua= new Qualification_Answer__c(Id=qa.Id);
            if((qa.Qualification_Question__r.Object__c).toUpperCase().contains('ACCOUNT'))
                qua.Account__c=mapAccount.get(qa.Lead__C);
            if((qa.Qualification_Question__r.Object__c).toUpperCase().contains('CONTACT'))    
                qua.Contact__c=mapContact.get(qa.Lead__C);
            if((qa.Qualification_Question__r.Object__c).toUpperCase().contains('JOB'))
                qua.Opportunity__c=mapJob.get(qa.Lead__C);
            updateQAlst.add(qua);
    }
    if(!updateQAlst.isEmpty()) {
        update updateQAlst;
    }
}