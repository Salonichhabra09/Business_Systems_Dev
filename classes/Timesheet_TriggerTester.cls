public class Timesheet_TriggerTester
{
    public static void testTimesheetTriggers()
    {
        testBasicMethods(null);
    }
    
    public static void testBasicMethods(String projectId)
    {
        List<Timesheet_Line__c> timesheets;
        
        timesheets = insertTimesheets(projectId);
            
        updateTimesheets(timesheets);
        
        deleteTimesheets(timesheets);
    }
    
    public static void testSpecialMethods(List<Timesheet_Line__c> timesheets)
    {
        
    }
    
    public static List<Timesheet_Line__c> insertTimesheets(String projectId)
     {
        system.debug('Timesheet: Insert Started');
        List<ProjectObject__c> projectList = new List<ProjectObject__c>();
        if(projectId==null)
        {
            projectList = [SELECT Id,Function_Timesheet__c from ProjectObject__c WHERE Functional_Area__c INCLUDES ('Consulting & Training') LIMIT 1];
            projectId = projectList[0].id;
        }
        else
            projectList = [SELECT Id,Function_Timesheet__c from ProjectObject__c WHERE id = :projectId];
        String userId = Userinfo.getUserId(); 
         
        List<Timesheet_Line__c> timesheets = new List<Timesheet_Line__c>();
        
        for(Integer i=0;i<2;i++)
        {
            Timesheet_Line__c timesheet = new Timesheet_Line__c();
            timesheet.Project__c =projectId;
            timesheet.Resource__c =  userId;
            timesheet.Billable__c = true;
            timesheet.Task_Category__c = 'Consulting';
            timesheet.Task__c = 'Assessment';
            timesheet.Date_Invoiced__c = Date.newInstance(2008,4+i,21);
            timesheet.Billing_Rate__c = 50 + i*10;
            timesheet.Hours__c = 4;
            timesheet.Function__c = projectList[0].Function_Timesheet__c;
            timesheet.Time_Category__c = 'Internal Organisation';
            timesheet.Task__c = 'Admin, Management And Meetings';
            timesheets.add(timesheet);
        }
    
        insert timesheets;
        
        return timesheets;
     }
     
     public static void updateTimesheets(List<Timesheet_Line__c> insertedTimesheets)
     {
        List<Timesheet_Line__c> timesheets = new List<Timesheet_Line__c>();
        
        for(Timesheet_Line__c timesheet: insertedTimesheets)
        {
            timesheet.Billing_Rate__c += 10;
            timesheets.add(timesheet);
        }
    
        update timesheets ;
        
     }
     
     public static void deleteTimesheets(List<Timesheet_Line__c> insertedTimesheets)
     {
        delete insertedTimesheets;
        
     }
}