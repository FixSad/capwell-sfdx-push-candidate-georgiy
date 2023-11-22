public with sharing class contactFrontsheetExtention {
    private final Contact cont;
    public String primSkills {get;set;}
    public String secndSkills {get;set;}

    public contactFrontsheetExtention(ApexPages.StandardController stdController) {
        this.cont = (Contact)stdController.getRecord();
        this.primSkills = '';
        this.secndSkills = '';
        if (this.cont!=null) {
            for (Skill_Association__c pSkill : [SELECT Skill__r.Name, Type__c, Level__c FROM Skill_Association__c WHERE Contact__c=:this.cont.Id]) {
                if (pSkill.Type__c == 'Primary') {
                    this.primSkills += pSkill.Skill__r.Name+' ('+pSkill.Level__c+'), ';
                } else {
                    this.secndSkills += pSkill.Skill__r.Name+' ('+pSkill.Level__c+'), ';
                }
            }
            if (this.primSkills.length()>0) {
                this.primSkills = this.primSkills.substring(0, this.primSkills.length()-2);
            }
            if (this.secndSkills.length()>0) {
                this.secndSkills = this.secndSkills.substring(0, this.secndSkills.length()-2);
            }
        }
    }
}