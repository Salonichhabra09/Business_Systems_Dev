/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CandidateRatingManager {

    public CandidateRatingManager() {

    }
    
    public class CandidateAndRatingData{
        @AuraEnabled public list<Bureau_Rating__c> ratingData;
        @AuraEnabled public List<Bureau_Candidate__c> candidateData;
    }

    @AuraEnabled
    public static CandidateAndRatingData getRatingDataForReportView(String soqlQueryList, String soqlQueryCandidateList,  String jobId, Integer offSetValue, List<Map<String, String>> filters){
    //public static CandidateAndRatingData getRatingDataForReportView(String soqlQueryList, String soqlQueryCandidateList,  String jobId, Integer offSetValue, String filterValue){
        list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        list<Id> candidateIdList = new list<Id>();
        CandidateAndRatingData wrapper = new CandidateAndRatingData();
        String soqlQuery;
        String baseQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =:jobId AND ';
        system.debug('--->offSetValue'+offSetValue);
        system.debug('--->baseQuery '+baseQuery);
        //commented poc search function
        List<String> conditions = new List<String>();
		System.debug('Filters from LWC '+filters);
        // Generate WHERE clause based on filters
        if(filters!=null){
           for (Map<String, String> filter : filters) {
            String field = filter.get('key');
            String value = filter.get('value');
               if(field=='participantName'){
                   field = 'Participant__r.Full_Name__c';
               }
               else if(field=='participantEmail'){
                   field = 'Participant__r.Email__c';
               }
               else if(field=='respondentName'){
                   field = 'Respondent__r.Full_Name__c';
               }
               else if(field=='respondentEmail'){
                   field = 'Respondent__r.Email__c';
               }
            Schema.DescribeFieldResult fieldDescribe = null;
               if(!field.contains('.')){
                   fieldDescribe = Schema.getGlobalDescribe().get('Bureau_Rating__c').getDescribe().fields.getMap().get(field).getDescribe();
               }
                
            if (fieldDescribe!=null && fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                System.debug('Inside If');
                conditions.add(field + ' = \'' + value + '\'');
            } 
               else if(field=='Deadline__c'){
                System.debug('Inside Else If');
                conditions.add(field + ' = '+ value +' '); 
               }
               else {
                conditions.add(field + ' LIKE \'%' + value + '%\'');
            }
        }
        }
       

        // Combine conditions using AND
        if (conditions.isEmpty()) {
            soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =:jobId ORDER BY Participant__r.Full_Name__c LIMIT 200 OFFSET: offSetValue'; // No filters
        } else {
            soqlQuery = baseQuery + String.join(conditions, ' AND ') +  'ORDER BY Participant__r.Full_Name__c LIMIT 200 OFFSET: offSetValue';
        }
        //old search function
       /* if(String.isBlank(filterValue)){
                   soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =:jobId ORDER BY Participant__r.Full_Name__c LIMIT 200 OFFSET: offSetValue';
        }
        else{
            String namePattern = '%' + String.escapeSingleQuotes(filterValue) + '%';
                  soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =:jobId AND (Participant__r.Full_Name__c like: namePattern OR Respondent__r.Full_Name__c like: namePattern OR Rater_Type__c like: namePattern OR Respondent__r.Email__c like: namePattern OR MFS_Status__c like: namePattern OR TC_Status__c like: namePattern OR Overall_Status__c like: namePattern OR Report_Ready__c like: namePattern OR Report_Sent__c like: namePattern ) ORDER BY Participant__r.Full_Name__c LIMIT 200 OFFSET: offSetValue';
        }*/

        system.debug('--->soqlQuery'+soqlQuery);
        
        ratingList = database.query(soqlQuery);
        
        for(Bureau_Rating__c r : ratingList){
            candidateIdList.add(r.Respondent__c);
        }
        
        String soqlQueryCandidate = 'Select ' + soqlQueryCandidateList + ' FROM Bureau_Candidate__c WHERE Id IN :candidateIdList ORDER BY Full_Name__c';
        candidateList = database.query(soqlQueryCandidate);
        wrapper.ratingData = ratingList;
        wrapper.candidateData = candidateList;
        return wrapper;
    }
    
    @AuraEnabled
    public static CandidateAndRatingData getRatingDataWrf(String soqlQueryList, String jobId, Integer offSetValue, String filterValue, String TCstatus, String MFSstatus, String ReminderVal){
        list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        list<Id> candidateIdList = new list<Id>();
        CandidateAndRatingData wrapper = new CandidateAndRatingData();
        if(String.isBlank(filterValue) && String.isBlank(TCstatus) && String.isBlank(MFSstatus) && String.isBlank(ReminderVal)){
            system.debug('--->All filters are blank<---'+String.isBlank(filterValue));
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,
                      Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = :jobId ORDER BY Participant__r.Full_Name__c LIMIT 200 OFFSET: offSetValue];
            
        }
        else if(String.isBlank(filterValue) == false && String.isBlank(TCstatus) == false && String.isBlank(MFSstatus) == false && String.isBlank(ReminderVal) == false)
        {
            system.debug('--->All filters are applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue OR MFS_Status__c like: filterValue OR TC_Status__c like: filterValue OR Overall_Status__c like: filterValue OR Reminder__c =: filterValue) AND (TC_Status__c =: TCstatus) AND (MFS_Status__c =: MFSstatus) AND(Reminder__c =:ReminderVal) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
        else if(String.isBlank(TCstatus) && String.isBlank(filterValue) == false && String.isBlank(MFSstatus) && String.isBlank(ReminderVal)){
            system.debug('--->Only search string<---'+String.isBlank(filterValue));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue OR MFS_Status__c like: filterValue OR TC_Status__c like: filterValue OR Overall_Status__c like: filterValue OR Reminder__c =: filterValue OR Participant__r.Work_Request__r.Name LIKE:filterValue) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
		else if(String.isBlank(TCstatus) == false && String.isBlank(filterValue) && String.isBlank(MFSstatus) && String.isBlank(ReminderVal)){
			system.debug('--->Only TC status applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (TC_Status__c =: TCstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        
		}
		else if(String.isBlank(TCstatus) && String.isBlank(filterValue) && String.isBlank(MFSstatus) == false && String.isBlank(ReminderVal)){
			system.debug('--->Only MFS status applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (MFS_Status__c =: MFSstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        
		}
        else if(String.isBlank(TCstatus) && String.isBlank(filterValue) && String.isBlank(MFSstatus) && String.isBlank(ReminderVal) == false){
			system.debug('--->Only Reminder applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c , Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Reminder__c =: ReminderVal) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        
		}
		else if(String.isBlank(TCstatus)== false && String.isBlank(filterValue) && String.isBlank(MFSstatus) == false && String.isBlank(ReminderVal)){
			system.debug('--->Only MFS and TC status applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (MFS_Status__c =: MFSstatus) AND (TC_Status__c =: TCstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        
		}
		else if(String.isBlank(TCstatus) == false && String.isBlank(filterValue) == false && String.isBlank(MFSstatus) && String.isBlank(ReminderVal)){
            system.debug('--->TC & Search string<---'+String.isBlank(filterValue));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue OR MFS_Status__c like: filterValue OR TC_Status__c like: filterValue OR Overall_Status__c like: filterValue OR Reminder__c =: filterValue) AND (TC_Status__c =: TCstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
		else if(String.isBlank(TCstatus)  && String.isBlank(filterValue) == false && String.isBlank(MFSstatus) == false && String.isBlank(ReminderVal)){
            system.debug('--->MFS & Search string<---'+String.isBlank(filterValue));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue OR MFS_Status__c like: filterValue OR TC_Status__c like: filterValue OR Overall_Status__c like: filterValue OR Reminder__c =: filterValue) AND (MFS_Status__c =: MFSstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
        else if(String.isBlank(TCstatus)  && String.isBlank(filterValue) == false && String.isBlank(MFSstatus) && String.isBlank(ReminderVal)  == false){
            system.debug('--->Reminder & Search string<---'+String.isBlank(filterValue));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue OR MFS_Status__c like: filterValue OR TC_Status__c like: filterValue OR Overall_Status__c like: filterValue OR Reminder__c =: filterValue) AND (Reminder__c =: ReminderVal) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
        else if(String.isBlank(TCstatus)== false && String.isBlank(filterValue) && String.isBlank(MFSstatus) && String.isBlank(ReminderVal)  == false){
			system.debug('--->Only Reminder and TC status applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Reminder__c =: ReminderVal) AND (TC_Status__c =: TCstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        
		}
        else if(String.isBlank(TCstatus)&& String.isBlank(filterValue) && String.isBlank(MFSstatus) == false  && String.isBlank(ReminderVal)  == false){
			system.debug('--->Only Reminder and MFS status applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Reminder__c =: ReminderVal) AND (MFS_Status__c =: MFSstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        
		}
        else if(String.isBlank(TCstatus) == false && String.isBlank(filterValue) && String.isBlank(MFSstatus) == false  && String.isBlank(ReminderVal)  == false){
			system.debug('--->Only Reminder, TC and MFS status applied<---'+String.isBlank(TCstatus));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Reminder__c =: ReminderVal) AND (MFS_Status__c =: MFSstatus) AND (TC_Status__c =: TCstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        
		}
        else if(String.isBlank(TCstatus) == false  && String.isBlank(filterValue) == false && String.isBlank(MFSstatus) && String.isBlank(ReminderVal)  == false){
            system.debug('--->Reminder, TC & Search string<---'+String.isBlank(filterValue));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c , Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue OR MFS_Status__c like: filterValue OR TC_Status__c like: filterValue OR Overall_Status__c like: filterValue OR Reminder__c =: filterValue) AND (Reminder__c =: ReminderVal) AND(TC_Status__c =:TCstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
        else if(String.isBlank(TCstatus)   && String.isBlank(filterValue) == false && String.isBlank(MFSstatus)== false && String.isBlank(ReminderVal)  == false){
            system.debug('--->Reminder, TC & Search string<---'+String.isBlank(filterValue));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c, Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue OR MFS_Status__c like: filterValue OR TC_Status__c like: filterValue OR Overall_Status__c like: filterValue OR Reminder__c =: filterValue) AND (Reminder__c =: ReminderVal) AND(MFS_Status__c =:MFSstatus) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
        else {
            system.debug('--->else no filter<---'+String.isBlank(filterValue));
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c,Report_Ready__c,Report_Sent__c,Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c, MFS_Report_Sent__c, TC_Report_Sent__c , Insights_Status__c, VADC_Status__c,
                      Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name,
                          EmailType__c, Email_File_Name__c, Sharepoint_File_Path__c // Added for SSE-28492
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
      
            
        }
        for(Bureau_Rating__c r : ratingList){
            candidateIdList.add(r.Respondent__c);
        }
        
        String soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Id IN :candidateIdList ORDER BY Full_Name__c';
        System.debug('soqlQuery '+soqlQuery);
        candidateList = database.query(soqlQuery);
        wrapper.ratingData = ratingList;
        wrapper.candidateData = candidateList;
        return wrapper;
    }
    
    @AuraEnabled
    public static list<Bureau_Rating__c> getRatingData(String jobId, Integer offSetValue, String filterValue){
        list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
        if(String.isBlank(filterValue)){
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,
                          Participant__r.Reports_Status__c , Insights_Status__c, VADC_Status__c, Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name
         				FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = :jobId ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }else{
            filterValue = '%'+filterValue+'%';
            ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,
                          Participant__r.Reports_Status__c , Insights_Status__c, VADC_Status__c, Participant__r.Work_Request__c, Participant__r.Work_Request__r.Name
         				FROM Bureau_Rating__c WHERE (Participant__r.Bureau_Job__c = :jobId) AND (Participant__r.Full_Name__c like: filterValue OR Respondent__r.Full_Name__c like: filterValue OR Rater_Type__c like: filterValue OR Respondent__r.Email__c like: filterValue) ORDER BY Participant__c LIMIT 200 OFFSET: offSetValue];
        }
        return ratingList;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getPicklistValues(String objectName, List<String> fieldNames) {
        Map<String, List<String>> picklistValues = new Map<String, List<String>>();
        
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        for (String fieldName : fieldNames) {
            Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
            List<String> values = new List<String>();
            
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                values.add(entry.getValue());
            }
            
            picklistValues.put(fieldName, values);
        }
        
        return picklistValues;
    }
}