@isTest(SeeAllData=true)
private class TimesheetTriggerManager_Tester2
{
    static testMethod void TimeSheetTester2(){
        ProjectObject__c PsnoProj =[select id,PS_Project_Number__c,Functional_Area__c  from projectobject__c where PS_Project_Number__c!=null limit 1];
        User GlobsUser=[select id from user where username like'%globus.development@shlgroup.com%' limit 1];
        
        Timesheet_Line__c timesheet = new Timesheet_Line__c ();
        timesheet.Project__c =PsnoProj.Id;
        //timesheet.Project__c ='a09D000000vOLau';
        timesheet.Resource__c = GlobsUser.Id;
        //timesheet.Billable__c = true;
        timesheet.Time_Category__c='Delivery';
        timesheet.Task_Category__c = 'PS Consulting';//Modified by prabhat
        timesheet.Task__c = 'Design';
        timesheet.Billable1__c = 'YES';
        //timesheet.Date_Invoiced__c = Date.newInstance(200,4+i,21);
        //timesheet.Billing_Rate__c = 50 + i*10;
        timesheet.Hours__c = 1;
        timesheet.Function__c = 'CT';
        //timesheet.Timesheet_From_CPS_Project__c=true;
        
       
        insert timesheet;
        timesheet.Hours__c = 2;
        Test.startTest();
        update timesheet;
        Test.stopTest();
        delete timesheet;
    }

    
    
}