@RestResource(urlMapping='/candidates/upsertCandidates/*')
global without sharing class websitePushCandidates {
  @HttpPost
  global static String pushCandidates() {
    responseWrapper result = new responseWrapper();
    RestRequest req = RestContext.request;
    String body = req.requestBody.toString();
    if (String.isNotBlank(body)) {
      try {
        List<candidateWrapper> candidates = (List<candidateWrapper>) JSON.deserialize(
          body,
          List<candidateWrapper>.class
        );
        if (candidates != null && !candidates.isEmpty()) {
          result.records = candidateReviewController.createReviewRequest(
            candidates
          );
          result.status = 'success';
          result.success = true;
        } else {
          result.status = 'Empty request';
        }
      } catch (Exception e) {
        result.status = e.getMessage();
      }
    } else {
      result.status = 'Empty request';
    }
    return JSON.serialize(result);
  }

  public class candidateWrapper {
    public String sf_id;
    public String portal_id;
    public String city;
    public String street;
    public String country;
    public String first_name;
    public String Last_name;
    public String inzet; // Full Time / Part Time
    public String radius; // Radius from City available from
    public List<skillWrapper> skills;
    public String user_id; // ?
    public String location; // City available from
    public String postal_code;
    public String display_name;
    public String house_number;
    public String phone_number;
    public Date date_of_birth;
    public String[] candidate_title;
    public Date start_from_date;
    public String linkedin_profile;
    public String company_name;
    public String sf_company_id;
    public String kvk_number;
    public String btw_number;
    public String company_house_no;
    public String company_address;
    public String company_city;
    public String company_country;
    public String company_postal_code;
    public String bank_name;
    public String bank_country;
    public String bank_account_number;
    public String about_description;
    public String candidate_type;
  }

  public class skillWrapper {
    public String sf_id;
    public String skill_name;
  }

  public class responseWrapper {
    public List<Database.upsertResult> records;
    public String status;
    public Boolean success = false;
  }
}
