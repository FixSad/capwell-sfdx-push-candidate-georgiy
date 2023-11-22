public with sharing class UniversalContactTileController {

    @AuraEnabled(Cacheable=true)
	public static Contact getContactDetail(Id contactId, List<String> conFieldsList) {
        String conFieldsStr = String.join(conFieldsList,',');
        List<Contact> getCon = new List<Contact>();
        String accQuerry = 'SELECT ' + conFieldsStr + 
                            ',(SELECT Skill__r.Name FROM Skill_Associations__r)' +
                            ' FROM Contact' + 
                            ' WHERE Id' +
                            ' =: contactId' +
                            ' ORDER BY Name' +
                            ' ASC';
        try {
            getCon = Database.query(accQuerry);
        } catch (Exception ex) {
            System.debug('Error while fetching the Accounts: ' + ex.getMessage());
        }
        return getCon[0];
    }
}
