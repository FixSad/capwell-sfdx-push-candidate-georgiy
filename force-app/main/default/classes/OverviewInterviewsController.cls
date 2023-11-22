public with sharing class OverviewInterviewsController {

    @TestVisible
    private static final String NEXT_WEEK = 'NextWeek';

    @AuraEnabled(Cacheable=true)
    public static Map<Integer,List<Interview__c>> getInterviewsMap(String week) {
        if (String.isBlank(week)) return null;
        Datetime dt = (DateTime)System.today();
        if(week.equals(NEXT_WEEK)) {
            dt = (DateTime)System.today().AddDays(7);
        }
        Integer dayOfWeek = Integer.valueof(dt.format('u'));
        DateTime startDay = dt.AddDays(-(dayOfWeek-1));
        DateTime endDay = dt.AddDays(8 - dayOfWeek);

        List<Interview__c> interList = [
            SELECT      Start_Date_Time__c,
                        Name,
                        Candidate__r.LastName,
                        Account__r.Name,
                        Job__r.Name
            FROM        Interview__c
            WHERE       Start_Date_Time__c >= :startDay     
            AND         Start_Date_Time__c <= :endDay
            ORDER BY    Start_Date_Time__c 
            ASC         NULLS FIRST
        ];

        if (interList.isEmpty()) return null;
        Map<Integer,List<Interview__c>> interviewByDayOfWeekMap = new Map<Integer, List<Interview__c>>();
        for (Integer i = 1; i <= 7; i++) {
            interviewByDayOfWeekMap.put(i, new List<Interview__c>());
        }
        for (Interview__c inter: interList) {
            Integer weekNumber = Integer.valueof(inter.Start_Date_Time__c.format('u'));
            List<Interview__c> interviewList = interviewByDayOfWeekMap.get(weekNumber);
            interviewList.add(inter);
            interviewByDayOfWeekMap.put(weekNumber, interviewList);
        }
        return interviewByDayOfWeekMap;
    }
}
