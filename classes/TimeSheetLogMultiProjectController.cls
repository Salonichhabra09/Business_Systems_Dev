public without sharing class TimeSheetLogMultiProjectController {
    
    @AuraEnabled
    public static String getUserName() {
        return userinfo.getName();
    }
    
    @AuraEnabled
    public static String saveTimesheets(List<Timesheet_Line__c> TimesheetListapex,List<Timesheet_Line__c> TimesheetsToDeleteList){
        try{
            if(TimesheetsToDeleteList.size()!=0){
                List<Id> timesheetsToDeleteIds = new List<Id>();
                for (Timesheet_Line__c timesheet : TimesheetsToDeleteList) {
                    timesheetsToDeleteIds.add(timesheet.Id);
                }
                List<Timesheet_Line__c> timesheetsToCheckDelete = [SELECT Id, Resource__c FROM Timesheet_Line__c WHERE Id IN :timesheetsToDeleteIds];
                system.debug('this is list '+TimesheetsToDeleteList);
                if(timesheetsToCheckDelete.size()!=TimesheetsToDeleteList.size()){
                    throw new HandledException('The timesheet/timesheets that you are trying to delete doesn\'t exist , Please refresh the page for up to date data!');
                }
                else{
                    delete TimesheetsToDeleteList;
                }
            }
            
            if(TimesheetListapex.size()!=0){
                List<Timesheet_Line__c> timesheetToInsert = new List<Timesheet_Line__c>();
                //SSE-17628 Changes start (Added by Jai Khandelwal)
                List<Timesheet_Line__c> timesheetsToCheck = new List<Timesheet_Line__c>();
                String query= 'Select Id FROM Timesheet_Line__c WHERE ';
                Integer countOfTimesheet = 0;
                for (Timesheet_Line__c  timesheet: TimesheetListapex) {
                    if(timesheet.Id==null){
                        timesheetToInsert.add(timesheet);
                    }
                }
                if(!timesheetToInsert.isEmpty()){
                for (Timesheet_Line__c  timesheet: timesheetToInsert) {
                    countOfTimesheet++;
                    String queryCondition='';
                    if(countOfTimesheet==1){
                        queryCondition = '(Timesheet_From_CPS_Project__c = false AND Date_Invoiced__c = '+ DateTime.newInstance(timesheet.Date_Invoiced__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd') + ' AND Task__c = \''+timesheet.Task__c + '\' AND Time_Category__c = \''+timesheet.Time_Category__c + '\' AND Resource__c = \''+timesheet.Resource__c + '\' AND Project__c = \''+timesheet.Project__c + '\')';
                        query = query + queryCondition;
                    }
                    else{
                        queryCondition = ' OR (Timesheet_From_CPS_Project__c = false AND Date_Invoiced__c = '+ DateTime.newInstance(timesheet.Date_Invoiced__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd') + ' AND Task__c = \''+timesheet.Task__c + '\' AND Time_Category__c = \''+timesheet.Time_Category__c + '\' AND Resource__c = \''+timesheet.Resource__c + '\' AND Project__c = \''+timesheet.Project__c + '\')';
                        query = query + queryCondition;
                    }
                }
                timesheetsToCheck = Database.query(query);
            }
                if(timesheetsToCheck.size()>0){
                    throw new HandledException('Duplicate timesheet entries found, Please refresh the page for up to date data!');
                }
                else{
                    upsert TimesheetListapex;
                }
            }
        
        //SSE-17628 Changes end (Added by Jai Khandelwal)
        return 'Timesheets records saved successfully';
        }
        catch(Exception e){
            System.debug('error message '+e.getMessage());
            return e.getMessage();
        }
        
    } 
    
    @AuraEnabled
    public static list<Timesheet_Line__c> ReturnCurrentTimeSheets(string startdate1,string enddate1){
        date startdate;
        date enddate;
        String startdatevalyear;
        List<String> startdateSplit = startdate1.split('/');
        List<String> enddateSPlit = enddate1.split('/');
        String userlocale =UserInfo.getLocale();
        system.debug('startdate1'+startdate1);
        system.debug('enddate1'+enddate1);
        List<Timesheet_Locale__mdt> TimeLocale = [Select DeveloperName,Dateformat__c,Delimiter__c from Timesheet_Locale__mdt where DeveloperName=: userlocale];
        system.debug('TimeLocale'+TimeLocale);
        String Delimiter = TimeLocale[0].Delimiter__c;
        String Dateformat = TimeLocale[0].Dateformat__c;
        String startdateval;
        String enddateval;    
        system.debug('Length '+Delimiter.length());
        if(Delimiter.length()==1){
        startdateval = startdateSplit[integer.valueof(Dateformat.substring(0,1))]+Delimiter+startdateSplit[integer.valueof(Dateformat.substring(1,2))]+Delimiter+startdateSplit[integer.valueof(Dateformat.substring(2,3))];
        enddateval = enddateSPlit[integer.valueof(Dateformat.substring(0,1))]+Delimiter+enddateSPlit[integer.valueof(Dateformat.substring(1,2))]+Delimiter+enddateSPlit[integer.valueof(Dateformat.substring(2,3))];
        }
        else if(Delimiter.length()==5){
        List<String> MultiDelimiter = TimeLocale[0].Delimiter__c.split(',');
        startdateval = startdateSplit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+startdateSplit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+startdateSplit[integer.valueof(Dateformat.substring(2,3))]+MultiDelimiter[2];
        enddateval = enddateSPlit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+enddateSPlit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+enddateSPlit[integer.valueof(Dateformat.substring(2,3))]+MultiDelimiter[2];
        }
        else{
        List<String> MultiDelimiter = TimeLocale[0].Delimiter__c.split(',');
        startdateval = startdateSplit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+startdateSplit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+startdateSplit[integer.valueof(Dateformat.substring(2,3))];
        enddateval = enddateSPlit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+enddateSPlit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+enddateSPlit[integer.valueof(Dateformat.substring(2,3))];    
        }
        
        /*if(UserInfo.getLocale()=='en_US')
        {
            String USstartdate = startdateSplit[1]+'/'+startdateSplit[0]+'/'+startdateSplit[2];
            String USenddate = enddateSPlit[1]+'/'+enddateSPlit[0]+'/'+enddateSPlit[2];
            startdate=Date.parse(USstartdate);
            enddate=Date.parse(USenddate);
            
        }
        else if (UserInfo.getLocale()=='nl_NL'){
            String customstartdate = startdateSplit[0]+'-'+startdateSplit[1]+'-'+startdateSplit[2];
            String customenddate = enddateSPlit[0]+'-'+enddateSPlit[1]+'-'+enddateSPlit[2];
            startdate=Date.parse(customstartdate);
            enddate=Date.parse(customenddate);
        }
        else{
            startdate = Date.parse( startdate1 );
            enddate = Date.parse( enddate1 );
        }*/
        System.debug('startdateval '+startdateval);
        System.debug('enddateval '+enddateval);
        startdate = Date.parse(startdateval);
        enddate = Date.parse(enddateval);
        System.debug('Test Start Date '+startdate);
        System.debug('Test End Date '+enddate);
        //Added Project_Nickname__c in query SSE-20058
        list<Timesheet_Line__c> TimeSheetList = [select id,Project__c,Project_Name__c,Task__c,Task_Category__c,Time_Category__c,Hours__c,Date_Invoiced__c,Project_Nickname__c,Project_Number__c from Timesheet_Line__c where Date_Invoiced__c >= :startdate and Date_Invoiced__c <= :enddate and createdbyid = :userinfo.getUserId() and Timesheet_From_CPS_Project__c=False order by Project__c,Task__c,Task_Category__c,Time_Category__c ];
        system.debug('TimeSheetList'+TimeSheetList);
        return TimeSheetList;
    }
    
     @AuraEnabled
    public static ProjectObject__c ProjectData(string Project_record_Id){
        System.debug('Project Id is '+Project_record_Id);
        // Added Project_Nick_Name__c field in below query to display Project's nickname on timesheet. Changes by Aashi SSE-20058
        ProjectObject__c project = [select Id,Project_Name__c,Project_Nick_Name__c,Name from ProjectObject__c where Id=:Project_record_Id];
        return project;
    }
    
    @AuraEnabled
    public static list<Timesheet_Line__c> ReturnTimeSheets(string startdate1,string enddate1){
       /* system.debug('startdate1'+startdate1);
        date startdate = Date.parse( startdate1 );
        date enddate = Date.parse( enddate1 );
        system.debug('startdate'+startdate);
        system.debug('enddate'+enddate); */ // commented by priyank to solve local date issue.
        date startdate;
        date enddate;
        List<String> startdateSplit = startdate1.split('/');
        List<String> enddateSPlit = enddate1.split('/');
        String userlocale =UserInfo.getLocale();
        List<Timesheet_Locale__mdt> TimeLocale = [Select DeveloperName,Dateformat__c,Delimiter__c from Timesheet_Locale__mdt where DeveloperName=: userlocale];
        system.debug('TimeLocale'+TimeLocale);
        String Delimiter = TimeLocale[0].Delimiter__c;
        String Dateformat = TimeLocale[0].Dateformat__c;
       String startdateval;
        String enddateval;    
        system.debug('Length '+Delimiter.length());
        if(Delimiter.length()==1){
        startdateval = startdateSplit[integer.valueof(Dateformat.substring(0,1))]+Delimiter+startdateSplit[integer.valueof(Dateformat.substring(1,2))]+Delimiter+startdateSplit[integer.valueof(Dateformat.substring(2,3))];
        enddateval = enddateSPlit[integer.valueof(Dateformat.substring(0,1))]+Delimiter+enddateSPlit[integer.valueof(Dateformat.substring(1,2))]+Delimiter+enddateSPlit[integer.valueof(Dateformat.substring(2,3))];
        }
        else if(Delimiter.length()==5){
        List<String> MultiDelimiter = TimeLocale[0].Delimiter__c.split(',');
        startdateval = startdateSplit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+startdateSplit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+startdateSplit[integer.valueof(Dateformat.substring(2,3))]+MultiDelimiter[2];
        enddateval = enddateSPlit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+enddateSPlit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+enddateSPlit[integer.valueof(Dateformat.substring(2,3))]+MultiDelimiter[2];
        }
        else{
        List<String> MultiDelimiter = TimeLocale[0].Delimiter__c.split(',');
        startdateval = startdateSplit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+startdateSplit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+startdateSplit[integer.valueof(Dateformat.substring(2,3))];
        enddateval = enddateSPlit[integer.valueof(Dateformat.substring(0,1))]+MultiDelimiter[0]+enddateSPlit[integer.valueof(Dateformat.substring(1,2))]+MultiDelimiter[1]+enddateSPlit[integer.valueof(Dateformat.substring(2,3))];    
        }
        
        /*if(UserInfo.getLocale()=='en_US')
        {
            String USstartdate = startdateSplit[1]+'/'+startdateSplit[0]+'/'+startdateSplit[2];
            String USenddate = enddateSPlit[1]+'/'+enddateSPlit[0]+'/'+enddateSPlit[2];
            startdate=Date.parse(USstartdate);
            enddate=Date.parse(USenddate);
            
        }
         else if (UserInfo.getLocale()=='nl_NL'){
            String customstartdate = startdateSplit[0]+'-'+startdateSplit[1]+'-'+startdateSplit[2];
            String customenddate = enddateSPlit[0]+'-'+enddateSPlit[1]+'-'+enddateSPlit[2];
            startdate=Date.parse(customstartdate);
            enddate=Date.parse(customenddate);
        }
        else{
            startdate = Date.parse( startdate1 );
            enddate = Date.parse( enddate1 );
        }*/
        System.debug('startdateval '+startdateval);
        System.debug('enddateval '+enddateval);
        startdate = Date.parse( startdateval );
        enddate = Date.parse( enddateval );
        
        //Added Project_Nickname__c in query SSE-20058
        list<Timesheet_Line__c> TimeSheetList = [select id,Project__c,Project_Name__c,Task__c,Task_Category__c,Time_Category__c,Function__c,Hours__c,Date_Invoiced__c,Project_Nickname__c,Project_Number__c from Timesheet_Line__c where Date_Invoiced__c >= :startdate and Date_Invoiced__c <= :enddate and createdbyid = :userinfo.getUserId()and Timesheet_From_CPS_Project__c=False order by Date_Invoiced__c];
        //system.debug('TimeSheetList'+TimeSheetList);
        system.debug('TimeSheetListsize'+TimeSheetList.size());
        
        //set<Timesheet_Line__c> timesheetset = new set<Timesheet_Line__c>();
        list<Timesheet_Line__c> TimeSheetListToReturn = new list<Timesheet_Line__c>();
        boolean match = false ;
            for(integer i = 0;i<TimeSheetList.size();i++){
            if(i==0){
                TimeSheetListToReturn.add(TimeSheetList[i]);
            }
            //for(integer j = i+1;j<TimeSheetList.size();j++){
            else{
                for(integer j = 0;j<TimeSheetListToReturn.size();j++){
                    if(TimeSheetList[i].Project__c == TimeSheetListToReturn[j].Project__c&&
                   TimeSheetList[i].Task__c == TimeSheetListToReturn[j].Task__c&&
                   /*TimeSheetList[i].Task_Category__c == TimeSheetListToReturn[j].Task_Category__c&&*/
                   TimeSheetList[i].Time_Category__c == TimeSheetListToReturn[j].Time_Category__c){
                    match = true;
                }
                }
                if(match == true){
                    match = false;
                }
                else{
                    TimeSheetListToReturn.add(TimeSheetList[i]);
                }
            } 
            
            //}
        }
       /* integer abc = 1;
        for(Timesheet_Line__c tc : TimeSheetListToReturn){
            system.debug(abc+'tc'+tc);
            abc++;
        }*/
        return TimeSheetListToReturn;
    }
}