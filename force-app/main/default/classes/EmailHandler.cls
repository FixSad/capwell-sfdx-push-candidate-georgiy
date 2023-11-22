global class EmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //String mailshotref = email.subject.substringBetween('[Ref::', ']');
        String mailshotref = email.plainTextBody!=null ? email.plainTextBody.substringBetween('[Ref::', ']') : email.htmlBody.substringBetween('[Ref::', ']');
        if (mailshotref!=null && mailshotref!='') {
            List<Candidate_Mailshot__c> candidates = [SELECT Id, Contact__c, Contact__r.Email, Contact__r.OwnerId, isReplied__c FROM Candidate_Mailshot__c WHERE Id=:mailshotref AND Contact__c!=null AND Contact__r.Email!=null];
            List<Candidate_Mailshot__c> updateCandidates = new List<Candidate_Mailshot__c>();
            if (!candidates.isEmpty()) {
                set<String> setConemail = new set<String>();
                set<String> setUseremail = new set<String>();
                if(!email.fromAddress.containsIgnoreCase('@capwell.nl')) {
                    setConemail.add(email.fromAddress);
                } else if(email.fromAddress.containsIgnoreCase('@capwell.nl')) {
                    setUseremail.add(email.fromAddress);
                }
                if (email.toAddresses!=null) {
                    for(String to : email.toAddresses){
                        if(!to.containsIgnoreCase('@capwell.nl')) {
                            setConemail.add(to);
                        } else if(to.containsIgnoreCase('@capwell.nl') && setUseremail.size()==0){
                            setUseremail.add(to);
                        }            
                    }
                }
                if (email.ccAddresses!=null) {
                    for(string cc : email.ccAddresses){
                        if(!cc.containsIgnoreCase('@capwell.nl')) {
                            setConemail.add(cc);
                        } else if(cc.containsIgnoreCase('@capwell.nl') && setUseremail.size()==0){
                            setUseremail.add(cc);
                        }
                    }
                }
                if(!setConemail.isEmpty()){
                    String emailbody='';
                    if (email.plainTextBody!=null) {
                        emailbody=email.plainTextBody;
                    } else if (email.htmlBody!=null) {
                        String backlash = '\n';
                        String backlashReplacement = '---n';
                        String tempstr = email.htmlBody;
                        tempstr = tempstr.replaceAll(backlash, backlashReplacement);
                        tempstr = tempstr.stripHtmlTags();
                        tempstr = tempstr.replaceAll(backlashReplacement, backlash);
                        emailbody=tempstr;  
                    }
                    String Subj = email.subject==null ? 'No Subject' : (email.subject.length()>255 ? email.subject.substring(0,255) : email.subject);
                    String Description = emailbody.length()>32000 ? emailbody.substring(0, 32000) : emailbody;
                    list<Task> lsttk = new list<Task>();
                    list<User> lstu =new list<User>(); 
                    if(!setUseremail.isEmpty()) {
                        lstu=[SELECT id FROM user WHERE email=:setUseremail AND isactive=true AND UserType!='Guest'];
                    }
                    for (String tmpEmail : setConemail) {
                        for (Candidate_Mailshot__c tmpCandidate : candidates) {
                            if (tmpCandidate.Contact__r?.Email==tmpEmail) {
                                Task tk = getNewTask(tmpCandidate.Contact__c, Subj, Description, !lstu.isEmpty() ? lstu[0].Id : tmpCandidate.Contact__r?.OwnerId);
                                tk.whatid=mailshotref;
                                lsttk.add(tk);
                                tmpCandidate.isReplied__c = true;
                                updateCandidates.add(tmpCandidate);
                                setConemail.remove(tmpCandidate.Contact__r?.Email);
                            }
                        }
                    }
                    if(!lsttk.isEmpty()){
                        insert lsttk;
                    }
                    if (!updateCandidates.isEmpty()) {
                        update updateCandidates;
                    }
                }            
            }
        }

        result.success = true;
        return result;
    }

    private static Task getNewTask(String whoId, String subject, String description, String owner) {
        Task tk = new Task();
        tk.Priority='low';
        tk.Status='completed';
        tk.ActivityDate=System.today();
        tk.Type = 'Email';
        tk.TaskSubtype = 'Email';
        tk.WhoId=whoId;
        tk.Subject=subject;
        tk.Description = description;
        tk.ownerid = owner;
        return tk;
    }
}