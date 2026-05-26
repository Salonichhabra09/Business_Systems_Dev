public class Attribution_ListView_Controller
{
    public User user {get;set;}
    public Integer selectMonth {get; set;}
    public Integer selectYear {get; set;}
    public Integer TotalRecords {get { return this.RecordSet.getResultSize();} }
    public boolean HasNextPage {get { return this.RecordSet.getHasNext();}}
    public boolean HasPreviousPage {get { return this.RecordSet.getHasPrevious();}}
    public Double TotalAttributionDays {get;set;}
    public Double TotalAttributionValue {get;set;}
    public Double TotalTimesheetHours {get;set;}
    public String TimesheetHoursData {get;set;}
    public Map<String, Timesheet_Line__c > testMap {get;set;}
    public Map<String, Double> timesheetMap {get;set;}
    private Map<String, Double> currencyMap;
    
    public Attribution_ListView_Controller()
    {
        this.selectMonth=date.today().month();
        this.selectYear=date.today().year();
        currencyMap = new Map<String, Double>();
        for(CurrencyType currencyType: [SELECT IsoCode, ConversionRate FROM CurrencyType])
            currencyMap.put(currencyType.IsoCode, currencyType.ConversionRate);
        user = [SELECT Id, DefaultCurrencyIsoCode FROM User WHERE Id= :UserInfo.getUserId()];
    }
    
    public ApexPages.StandardSetController RecordSet 
    {
        get 
        {
            if(RecordSet == null) 
            {
                Database.QueryLocator queryLocator;
                if(selectMonth!=0 && selectYear!=0)
                    queryLocator = Database.getQueryLocator([SELECT Id ,Name,Attribution_Month_Number__c,Project__c, Consultant__c,  Project__r.Name,Project__r.Project_Name__c,Attribution_Month2__c,CurrencyIsoCode,Attribution_Year2__c,Attribution_Days__c,Attribution_Rate__c,Attribution_Value__c,Timesheet_Hours__c FROM RevenueAttribution__c WHERE Consultant__c =:UserInfo.getUserId() AND Attribution_Year2__c=:String.valueOf(this.selectYear) AND Attribution_Month2__c=: getMonthName(this.selectMonth) ORDER BY Attribution_Year2__c DESC, Attribution_Month_Number__c DESC, Project__r.Name DESC]);
                else if(selectYear!=0)
                    queryLocator = Database.getQueryLocator([SELECT Id ,Name,Attribution_Month_Number__c,Project__c, Consultant__c,  Project__r.Name,Project__r.Project_Name__c,Attribution_Month2__c,CurrencyIsoCode,Attribution_Year2__c,Attribution_Days__c,Attribution_Rate__c,Attribution_Value__c,Timesheet_Hours__c FROM RevenueAttribution__c WHERE Consultant__c =:UserInfo.getUserId() AND Attribution_Year2__c=:String.valueOf(this.selectYear) ORDER BY Attribution_Year2__c DESC, Attribution_Month_Number__c DESC, Project__r.Name DESC]);
                else
                    queryLocator = Database.getQueryLocator([SELECT Id ,Name,Attribution_Month_Number__c,Project__c, Consultant__c, Project__r.Name,Project__r.Project_Name__c,Attribution_Month2__c,CurrencyIsoCode,Attribution_Year2__c,Attribution_Days__c,Attribution_Rate__c,Attribution_Value__c,Timesheet_Hours__c FROM RevenueAttribution__c WHERE Consultant__c =:UserInfo.getUserId() AND Attribution_Year2__c!=null AND  Attribution_Month2__c!=null  ORDER BY Attribution_Year2__c DESC, Attribution_Month_Number__c DESC, Project__r.Name DESC]);
                RecordSet = new ApexPages.StandardSetController(queryLocator);
            }
            
            return RecordSet;
         }
        set;
    }
       
    public PageReference Go()
    {
        this.RecordSet = null;
        if(selectYear==0) selectMonth=0;
        return null;
    }
        
    public List<RevenueAttribution__c> getAttributions()
    {
        try
        {
            this.TotalAttributionValue = 0;
            this.TotalAttributionDays = 0;
            this.TotalTimesheetHours = 0;
            this.TimesheetHoursData = '';
            List<RevenueAttribution__c> attributionList = (List<RevenueAttribution__c>)this.RecordSet.getRecords();
            this.createTimesheetMap(attributionList);
            for(RevenueAttribution__c attribution: attributionList)
            { 
                TimesheetHoursData += attribution.Id + ','+ attribution.Timesheet_Hours__c+';';
                UpdateTotals(attribution);
            }
            return attributionList;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,e.getMessage()));
            System.debug(e.getMessage());
            return null;
        }
    }
    
    
          
    private void createTimesheetMap(List<RevenueAttribution__c> attributions)
    {
        this.timesheetMap = new Map<String, Double>();
        for(RevenueAttribution__c attribution: attributions){
          if(attribution.Attribution_Year2__c!=null && attribution.Attribution_Month2__c!=null && attribution.Project__c!=null){    
             timesheetMap.put(Integer.valueOf(attribution.Attribution_Year2__c) + '_' +  getMonthNumber(attribution.Attribution_Month2__c) + '_' +  attribution.Project__c, 0);
         }
        }
        for(Timesheet_Line__c timesheet: fetchTimesheets())
        {
            String timesheetKey =  timesheet.Date_Invoiced__c.year() + '_' + timesheet.Date_Invoiced__c.month() + '_' +  timesheet.Project__c;
            if(!timesheetMap.containsKey(timesheetKey))
                timesheetMap.put(timesheetKey, timesheet.Hours__c);
            else 
                timesheetMap.put(timesheetKey,(timesheetMap.get(timesheetKey) + timesheet.Hours__c));
        }
    }
    
    private List<Timesheet_Line__c> fetchTimesheets()
    {
        Date startDate, endDate;
        if(this.selectYear!=0 && this.selectMonth!=0)
        {
            startDate = date.newInstance(this.selectYear,this.selectMonth,1);
            endDate = startDate.addMonths(1).addDays(-1);
            return [SELECT Date_Invoiced__c,Project__c,Hours__c FROM Timesheet_Line__c WHERE Resource__c=:UserInfo.getUserId() AND Date_Invoiced__c>=:startDate AND Date_Invoiced__c<=:endDate ORDER BY Date_Invoiced__c, Project__c];
    
        }
        else if(this.selectYear!=0)
        {
            startDate = date.newInstance(this.selectYear,1,1);
            endDate = startDate.addYears(1).addDays(-1);
            return [SELECT Date_Invoiced__c,Project__c, Hours__c FROM Timesheet_Line__c WHERE Resource__c=:UserInfo.getUserId() AND Date_Invoiced__c>=:startDate AND Date_Invoiced__c<=:endDate ORDER BY Date_Invoiced__c, Project__c];
        }
        else
        {
            return [SELECT Date_Invoiced__c,Project__c, Hours__c FROM Timesheet_Line__c WHERE Resource__c=:UserInfo.getUserId() ORDER BY Date_Invoiced__c, Project__c];
        }
    }
    
    private String getMonthName(Integer value)
    {
        Map<Integer, String> monthMap = new Map<Integer, String>{1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
        return monthMap.get(value);
    }
    
    private Integer getMonthNumber(String value)
    {
        Map<String, Integer> monthMap = new Map<String, Integer>{'Jan'=>1,'Feb'=>2,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12};
        return monthMap.get(value);
    }
    
    public void UpdateTotals(RevenueAttribution__c attribution)
    {
        Double userCurrencyConversionRate = currencyMap.get(user.DefaultCurrencyIsoCode);
        Double attributionCurrencyConversionRate = currencyMap.get(attribution.CurrencyIsoCode);
        System.debug('Priyank attribution.Attribution_Value__c '+attribution.Attribution_Value__c);
        System.debug('Priyank userCurrencyConversionRate '+userCurrencyConversionRate);
        System.debug('Priyank attributionCurrencyConversionRate '+attributionCurrencyConversionRate);
        this.TotalAttributionValue += (attribution.Attribution_Value__c*userCurrencyConversionRate/attributionCurrencyConversionRate).Divide(1,2,System.RoundingMode.HALF_UP);
        this.TotalAttributionDays +=attribution.Attribution_Days__c;
        if(attribution.Attribution_Year2__c!=null &&  attribution.Attribution_Month2__c!=null && attribution.Project__c!=null){
        String timesheetKey =  Integer.valueOf(attribution.Attribution_Year2__c) + '_' +  getMonthNumber(attribution.Attribution_Month2__c) + '_' +  attribution.Project__c;
        
        if(timesheetMap!=null && timesheetMap.containsKey(timesheetKey))
            this.TotalTimesheetHours+=timesheetMap.get(timesheetKey);
      }
    }
      
      
}