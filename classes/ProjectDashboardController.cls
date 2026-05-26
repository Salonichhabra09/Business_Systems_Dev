public without sharing class ProjectDashboardController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDashboardData(Id jobId) {
        Map<String, Object> result = new Map<String, Object>();
		Job__c job = [SELECT Contract__c,Contract_End_Date__c,Contract_Start_Date__c,Project_Manager__r.FirstName,Project_Manager__r.LastName, Project_Manager__r.Email,Contact_Details__c,Number_of_Participants_New__c,Solution_Cap__c,Is_GCSC_Opp__c FROM Job__c WHERE Id = :jobId LIMIT 1];
        Work_Request__c workRequest = [select id,WRF_Link_Generated_for_Client__c from Work_Request__c where Job__c=:jobId and (Work_Request_Type__c='Client Submitted' OR Work_Request_Type__c='Internal Submission') order by createddate desc limit 1];

        //Contract contract = [SELECT Id, Name, Subscription_Start_Date__c, Contract_End_Date__c FROM Contract WHERE contractnumber = :job.Contract__c LIMIT 1];
        result.put('newRequestForm',workRequest.WRF_Link_Generated_for_Client__c);
        result.put('Is_GCSC_Opp',job.Is_GCSC_Opp__c);
        if(job.Contract__c!=null){
         result.put('contractNumber', job.Contract__c);
        result.put('startDate', job.Contract_Start_Date__c.format());
        result.put('endDate', job.Contract_End_Date__c.format());   
        }
        String name = job.Project_Manager__r.FirstName + ' '+job.Project_Manager__r.LastName;
         // Fetch Project Contacts
        List<Map<String, String>> contacts = new List<Map<String, String>>();
        
        // Add Project Manager
        if (job.Project_Manager__r != null) {
            contacts.add(new Map<String, String>{
                'name' => name,
                'email' => job.Project_Manager__r.Email,
                'role' => 'Project Manager'
            });
        }
       
         if (String.isNotBlank(job.Contact_Details__c)) {
            try {
                List<Object> contactList = (List<Object>) JSON.deserializeUntyped(job.Contact_Details__c);
                for (Object contactObj : contactList) {
                    Map<String, Object> contactMap = (Map<String, Object>) contactObj;
                    contacts.add(new Map<String, String>{
                        'name' => String.valueOf(contactMap.get('name')),
                        'email' => String.valueOf(contactMap.get('email')),
                        'role' => String.valueOf(contactMap.get('role'))
                    });
                }
            } catch (Exception e) {
                System.debug('Error parsing Contact_Details__c: ' + e.getMessage());
            }
        }
  		result.put('projectContacts', contacts);
        // Fetch Bureau Ratings for Pie Chart
        //List<Bureau_Rating__c> ratings = [SELECT Status__c FROM Bureau_Rating__c WHERE Participant__c IN (SELECT Id FROM Bureau_Candidate__c WHERE Bureau_Job__c = :jobId)];
        Integer processed = (Integer)job.Number_of_Participants_New__c;
        Integer remaining = 0;
        if(job.Solution_Cap__c!=null){
           remaining = (Integer)job.Solution_Cap__c-(Integer)job.Number_of_Participants_New__c; 
        }
        
        /*for (Bureau_Rating__c rating : ratings) {
            if (rating.Status__c == 'Completed') {
                processed++;
            } else {
                remaining++;
            }
        }*/
        result.put('processed', processed);
        result.put('remaining', remaining);

        // Fetch Bureau Candidates for Bar Chart
        /*Map<String, Integer> statusCounts = new Map<String, Integer>{'Completed' => 0, 'In Progress' => 0, 'Not Started' => 0, 'Recalled' => 0};
        for (Bureau_Candidate__c candidate : [SELECT Status__c FROM Bureau_Candidate__c WHERE Bureau_Job__c = :jobId]) {
            if (statusCounts.containsKey(candidate.Status__c)) {
                statusCounts.put(candidate.Status__c, statusCounts.get(candidate.Status__c) + 1);
            }
        }
        result.put('completed', statusCounts.get('Completed'));
        result.put('inProgress', statusCounts.get('In Progress'));
        result.put('notStarted', statusCounts.get('Not Started'));
        result.put('recalled', statusCounts.get('Recalled'));*/

        return result;
    }
}