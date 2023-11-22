@RestResource(urlMapping='/groups/*')
global without sharing class websiteGroups {
  @HttpPost
  global static List<Client_List__c> getGroups(String userEmail) {
    if (String.isNotBlank(userEmail)) {
      List<User> usr = [
        SELECT Id
        FROM User
        WHERE Email = :userEmail AND isActive = TRUE
      ];
      if (usr != null && !usr.isEmpty()) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission(
          'Client_All_List'
        );
        if (hasCustomPermission) {
          return [
            SELECT Id, Name, Owner.Alias
            FROM Client_List__c
            ORDER BY Name, OwnerId
          ];
        } else {
          return [
            SELECT Id, Name, Owner.Alias
            FROM Client_List__c
            WHERE OwnerId = :usr[0].Id
            ORDER BY Name, OwnerId
          ];
        }
      }
    }
    return null;
  }

  @HttpGet
  global static List<User> allRecruiters() {
    return [
      SELECT Id, Name
      FROM User
      WHERE isActive = TRUE AND Profile.Name = 'Recruiter'
    ];
  }
}
