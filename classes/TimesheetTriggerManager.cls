/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 22-07-2019
DESCRIPTION :- This class contains various Methods/Checks/Assignments to controll TimeSheets Functionality as per SHL business process,
               this class is being refered from TimeSheet_Trigger, covering all the Before/After, Insert/Delete & Update Events on TimeSheet Records.
******************************************************************************/

global class TimesheetTriggerManager{
    //Restricting the deletion of time sheet if user role is not "PSA Lead" & TimeSheet Status is Approved.
    public static void RestrictTimeshtDelete(List<Timesheet_Line__c> OldTimeshtList){
        User user = [SELECT Id, PSA_Role__c FROM User WHERE Id= :UserInfo.getUserId()];
        for(Integer i=0; i<OldTimeshtList.size(); i++){
            if(OldTimeshtList[i].Status__c=='Approved' && user.PSA_Role__c!='PSA Lead')
            OldTimeshtList[i].addError('You do not have permissions to delete this timesheet');
        }
    }
    //Creating(cloned from Original) TimeSheet Record if the project is CPS Project.
    /*public static void TimesheetforCPSProjects(List<Timesheet_Line__c> NewTimeshtList){
        id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        Set<Id> projectIdsSet = new Set<Id>();
        for(Timesheet_Line__c timeSheetLine: NewTimeshtList)
            projectIdsSet.add(timeSheetLine.Project__c);
        Map<Id,ProjectObject__c> projectsMap = new Map<Id,ProjectObject__c>([Select id,RecordTypeId,PS_Project_Number__c from ProjectObject__c where id in :projectIdsSet]);
        List<Timesheet_Line__c> timeSheetLineList = new List<Timesheet_Line__c>();
        for(Timesheet_Line__c timeSheetLine: NewTimeshtList){
            if(projectsMap.get(timeSheetLine.Project__c).RecordTypeId == selectedRecordTypeId && projectsMap.get(timeSheetLine.Project__c).PS_Project_Number__c!=null)
            {
                //SSE-17629 Changes start (Added by Jai Khandelwal)
                //Timesheet_Line__c tLine = timeSheetLine.clone(false, true);
                Timesheet_Line__c tLine = new Timesheet_Line__c();
                tLine.Time_Category__c = timeSheetLine.Time_Category__c;
                tLine.Task_Category__c = timeSheetLine.Task_Category__c;
                tLine.Task__c = timeSheetLine.Task__c;
                tLine.Resource__c = timeSheetLine.Resource__c;
                tLine.Date_Invoiced__c = timeSheetLine.Date_Invoiced__c;
                tLine.Hours__c = timeSheetLine.Hours__c;
                //SSE-17629 Changes end (Added by Jai Khandelwal)
                tLine.Project__c = projectsMap.get(timeSheetLine.Project__c).PS_Project_Number__c;
                tLine.Timesheet_From_CPS_Project__c = true;
                tLine.CPS_Timesheet__c = timeSheetLine.id;
                timeSheetLineList.add(tLine);
            }
        }
        if(timeSheetLineList.size()>0)
        insert timeSheetLineList;
    }*/
    //Updating the Total Actual time on Project based on the Hours logged in timesheet
    public static void UpdateTATonProject(List<Timesheet_Line__c> NewTimeshtList){
        id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        Set<Id> projectIdsSet = new Set<Id>();
        for(Timesheet_Line__c timeSheetLine: NewTimeshtList)
            projectIdsSet.add(timeSheetLine.Project__c);
        List<ProjectObject__c> updatedProjectList = new List<ProjectObject__c>();
        for(ProjectObject__c proj :[select id,Total_Actual_Time__c,Scoped_Hours_Effort__c,(select id,Hours__c from Timesheets__r) from ProjectObject__c where ID IN: projectIdsSet and RecordTypeId = :selectedRecordTypeId])
        {
            Decimal i=0;
            for(Timesheet_Line__c timeLine : proj.Timesheets__r){
                if(timeLine.Hours__c != null)
                 i += timeLine.Hours__c;
            }
            if(i!=0)
                proj.Total_Actual_Time__c = i/7.5;
            else
                proj.Total_Actual_Time__c = i;
                updatedProjectList.add(proj);
        }
        if(updatedProjectList.size()>0){
            Utility.Timesheetinsert = false;
            update updatedProjectList;
        }
    }
    //Updating the Hours on the TimeSheet if Task or Task Category is Changed
    public static void UpdateTimeShtHrs(List<Timesheet_Line__c> NewTimeshtList,List<Timesheet_Line__c> OldTimeshtList,Map<Id,Timesheet_Line__c> NewTmshtLineMap){
        id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        Set<Id> projectIdsSet = new Set<Id>();
        //Below loop add timesheet lines project ids to projectIdsSet where hours or task or task category field has been changed. we need to updated hours in the cloned timesheets on PS Projects.
        for(Integer i = 0;i<NewTimeshtList.size();i++){
            if(NewTimeshtList[i].Hours__c!=OldTimeshtList[i].Hours__c || NewTimeshtList[i].Task_Category__c!=OldTimeshtList[i].Task_Category__c || NewTimeshtList[i].Task__c!=OldTimeshtList[i].Task__c)
                projectIdsSet.add(NewTimeshtList[i].Project__c);
        }
        //Fetching projects of the timesheets where hours field is changed to know whether its CPS project or not. If yes then we need to update the related cloned timesheet line.
        Map<Id,ProjectObject__c> projectsMap = new Map<Id,ProjectObject__c>([Select id,RecordTypeId,PS_Project_Number__c from ProjectObject__c where id in :projectIdsSet]);
        List<Timesheet_Line__c> timeSheetLineList = new List<Timesheet_Line__c>();
        Set<Id> cpsTimeSheetIdsSet = new Set<Id>();
        //Creating set of the timesheet line ids where there is a change in hours field to fetch cloned timesheet lines.
        for(Integer i = 0;i<NewTimeshtList.size();i++){
            if((NewTimeshtList[i].Hours__c!=OldTimeshtList[i].Hours__c || NewTimeshtList[i].Task_Category__c!=OldTimeshtList[i].Task_Category__c || NewTimeshtList[i].Task__c!=OldTimeshtList[i].Task__c) && projectsMap.get(NewTimeshtList[i].Project__c).RecordTypeId == selectedRecordTypeId)
                cpsTimeSheetIdsSet.add(NewTimeshtList[i].id);
        }
        //Fetching all the cloned timesheet lines.
        timeSheetLineList = [Select id,Hours__c,CPS_Timesheet__c,Task_Category__c,Task__c from Timesheet_Line__c where CPS_Timesheet__c in :cpsTimeSheetIdsSet];
        //Updating hours field on cloned timesheet lines from the original timesheet line.
        for(Timesheet_Line__c timesheetLine:timeSheetLineList){
            timesheetLine.Hours__c = NewTmshtLineMap.get(timesheetLine.CPS_Timesheet__c).Hours__c;
            timesheetLine.Task_Category__c = NewTmshtLineMap.get(timesheetLine.CPS_Timesheet__c).Task_Category__c;
            timesheetLine.Task__c = NewTmshtLineMap.get(timesheetLine.CPS_Timesheet__c).Task__c;
        }
        if(timeSheetLineList.size()>0)
            update timeSheetLineList;
    }
    //Updating the Total Actual Time on Project.
    public static void UpdateTATfrmTimeShtHrs(List<Timesheet_Line__c> NewTimeshtList,List<Timesheet_Line__c> OldTimeshtList){
        id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        Set<Id> projectIdsSet = new Set<Id>();
        //Below loop add timesheet lines project ids to projectIdsSet where hours or task or task category field has been changed. we need to updated hours in the cloned timesheets on PS Projects.
        for(Integer i = 0;i<NewTimeshtList.size();i++){
            if(NewTimeshtList[i].Hours__c!=OldTimeshtList[i].Hours__c || NewTimeshtList[i].Task_Category__c!=OldTimeshtList[i].Task_Category__c || NewTimeshtList[i].Task__c!=OldTimeshtList[i].Task__c)
            projectIdsSet.add(NewTimeshtList[i].Project__c);
        }
        List<ProjectObject__c> updatedProjectList = new List<ProjectObject__c>();
        for(ProjectObject__c proj :[select id,Total_Actual_Time__c,(select id,Hours__c from Timesheets__r) from ProjectObject__c where ID IN: projectIdsSet and RecordTypeId = :selectedRecordTypeId]){
        Decimal i=0;
        for(Timesheet_Line__c timeLine : proj.Timesheets__r){
            if(timeLine.Hours__c != null)
            i += timeLine.Hours__c;
            system.debug('------>timeLine.Hours__c<------'+timeLine.Hours__c);
        }
            system.debug('------>i<------'+i);
            system.debug('------>proj.Total_Actual_Time__cbefore<------'+proj.Total_Actual_Time__c);
        if(i!=0)
            proj.Total_Actual_Time__c = i/7.5;
        else
            proj.Total_Actual_Time__c = i;
            updatedProjectList.add(proj);
            system.debug('------>proj.Total_Actual_Time__cafter<------'+proj.Total_Actual_Time__c);
        }

        if(updatedProjectList.size()>0){

        // modified on 19/06/2015 to skip validation on Closed/Deliveerd projects and allow timesheet entry as hours are rolling up on total time field on project.
            Utility.Timesheetinsert = false;
            update updatedProjectList;
        }
    }
    //Deleting all the timesheet entries against a main project when someone delete the timesheet entry against CPS project.
    public static void DeleteTimshtEntries(List<Timesheet_Line__c> OldTimeshtList){
        //List<Timesheet_Line__c> parentProjectTimesheetlist = new List<Timesheet_Line__c>();
        string year = String.valueOf(DateTime.Now().Year());
        string month = '1';
        string day = '1';
        string hour = '12';
        string minute = '00';
        string second = '00';
        string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute +  ':' + second;
        Datetime myDate = Datetime.valueOf(stringDate);
        // for(Timesheet_Line__c tms : [select id,name from Timesheet_Line__c where CreatedDate >: myDate AND Timesheet_From_CPS_Project__c=true AND CPS_Timesheet__c = null]){
        //     parentProjectTimesheetlist.add(tms);
        // }
            //Modified on 19/06/2015 to skip validation on Closed/Deliveerd projects and allow timesheet entry as hours are rolling up on total time field on project.
            Utility.Timesheetinsert = false;

        //Actual time calculation on basis of timesheet delete
        Set<Id> projectIdsSet = new Set<Id>();
        List<ProjectObject__c> updatedProjectList = new List<ProjectObject__c>();
        for(Timesheet_Line__c timeSheetLine: OldTimeshtList)
            projectIdsSet.add(timeSheetLine.Project__c);
        if(projectIdsSet.size()>0){
        id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
            for(ProjectObject__c proj :[select id,Total_Actual_Time__c,Scoped_Hours_Effort__c,(select id,Hours__c from Timesheets__r) from ProjectObject__c where ID IN: projectIdsSet and RecordTypeId = :selectedRecordTypeId])
            {
            Decimal i=0;
                for(Timesheet_Line__c timeLine : proj.Timesheets__r){
                    if(timeLine.Hours__c != null)
                    i += timeLine.Hours__c;
                }
                if(i!=0)
                proj.Total_Actual_Time__c = i/7.5;
                else
                proj.Total_Actual_Time__c = i;
                updatedProjectList.add(proj);
            }
        }
        if(updatedProjectList.size()>0){
            update updatedProjectList;

        }
    // if(parentProjectTimesheetlist.size()>0)
    // delete parentProjectTimesheetlist;
    }
}