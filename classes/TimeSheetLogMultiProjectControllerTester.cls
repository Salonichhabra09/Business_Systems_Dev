@isTest(seeAllData = true)
private class TimeSheetLogMultiProjectControllerTester {
    static testMethod void CoverMethods(){
        Date Date1 = Date.today();
        Date Date2 = Date.Today() +5;  
        String startDate = Date1.format();
        String EndDate = Date2.format();
        TimeSheetLogMultiProjectControllerTester.CreateTimesheetTestRecords();
        TimeSheetLogMultiProjectController.getUserName();
        ProjectObject__c project = [select id from ProjectObject__c where Project_Status__c='In Progress' and opportunity__r.Variation_Opportunity__c='No' limit 1 ];
        TimeSheetLogMultiProjectController.ProjectData(project.Id);
        TimeSheetLogMultiProjectController.ReturnTimeSheets(startDate,EndDate );
        TimeSheetLogMultiProjectController.ReturnCurrentTimeSheets(startDate, EndDate);
        TimeSheetLogMultiProjectController.saveTimesheets(TimeSheetLogMultiProjectControllerTester.CreateTimesheetTestRecords(), new List<Timesheet_Line__c>());
        TimeSheetLogMultiProjectController.saveTimesheets(new List<Timesheet_Line__c>(), TimeSheetLogMultiProjectControllerTester.CreateTimesheetTestRecords());
        
    }
    static testMethod List<Timesheet_Line__c> CreateTimesheetTestRecords(){
        Date timesheetdate = date.Today();
        List<Timesheet_Line__c> TempTimesheets = new List<Timesheet_Line__c>();
        ProjectObject__c project = [select id from ProjectObject__c where Project_Status__c='In Progress' and opportunity__r.Variation_Opportunity__c='No' limit 1];
        for(integer i=0;i<5;i++){
            Timesheet_Line__c timesheet = new Timesheet_Line__c();
            timesheet.Date_Invoiced__c = timesheetdate + i;
            timesheet.Hours__c = 8;
            timesheet.Project__c = project.Id;
            timesheet.Resource__c = userinfo.getUserId();
            //Changes for SSE-17628 start (Added by Jai Khandelwal)
            timesheet.Task__c = 'Other';
            timesheet.Task_Category__c = 'Other';
            timesheet.Time_Category__c = 'Delivery - Other';
            //Changes for SSE-17628 end (Added by Jai Khandelwal)
            TempTimesheets.add(timesheet);
        }
        insert TempTimesheets;
        //Changes for SSE-17628 start (Added by Jai Khandelwal)
        Timesheet_Line__c timesheet = new Timesheet_Line__c();
            timesheet.Date_Invoiced__c = timesheetdate + 6;
            timesheet.Hours__c = 8;
            timesheet.Project__c = project.Id;
            timesheet.Resource__c = userinfo.getUserId();
            timesheet.Task__c = 'Other';
            timesheet.Task_Category__c = 'Other';
            timesheet.Time_Category__c = 'Delivery - Other';
            TempTimesheets.add(timesheet);
        //Changes for SSE-17628 end (Added by Jai Khandelwal)
        return TempTimesheets;
    }
}