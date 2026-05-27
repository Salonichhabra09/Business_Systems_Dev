public class EmailTemplate_Selection
{
    List<Folder> folderList = [SELECT Id,Name FROM Folder WHERE type = 'Email'];
    public List<EmailTemplate> emailTemplatesList{get;set;}
    public string folderId{get;set;}
    public string emailTemplateId {get;set;}
    public string courseId {get;set;}
    public string message{get;set;}
    
    public string actionString = '%'+ApexPages.currentPage().getParameters().get('foldername')+'%';
    public string success {get;set;}
    
    //This method checks Is there any email template exist for the passed query or not
    public Boolean getIsTemplateExist()
    {
        if(emailTemplateslist != null && emailTemplatesList.size()>0)
        return false;
        else
        return true;
    }
    //This method creates emailtemplatelist and show this list in detail page at time of page load as folderid and actionstring passed
    public EmailTemplate_Selection()
    {
        if(folderList.size()>0)
            emailTemplatesList = [SELECT Id, Name,TemplateType,Description FROM EmailTemplate where FolderId=:folderList[0].id and Name like :actionString];
    }
    //This method is used to populate folder names in Folder picklist
    public List<SelectOption> getItems()
    {
        List<SelectOption> options = new List<SelectOption>();
        for(Folder folder:folderList)
        {
            options.add(new SelectOption(folder.id,folder.Name));
        }
        return options;
    }
    // This method creates emailtemplatelist to show in detail page as folder name gets changed
    public PageReference changeFolder()
    {
        emailTemplatesList = [SELECT Id, Name,TemplateType,Description FROM EmailTemplate where FolderId=:folderId and Name like :actionString];
        System.debug('*******emailTemplatesList.size()*******'+emailTemplatesList.size());
        return null;
    }
    // This method is used to send emails to delegate contacts of course bookings 
    public PageReference executeAction()
    {
        String actionResult;
        String action = ApexPages.currentPage().getParameters().get('action');
        if(action == 'Course_sendJoiningInstructions')
            actionResult = Course_Manager.sendJoiningInstructions(this.courseId, this.emailTemplateId); 
        /*else if(action == 'Course_SendSurvey')
            actionResult = Course_Manager.sendSurvey(this.courseId, this.emailTemplateId);*/
        if(actionResult.startsWith('SUCCESS:'))
        {
            message = actionResult.substring(8);
            success = 'true';
        }
        else if (actionResult.startsWith('FAILURE:')) 
        {
            message = actionResult.substring(8);
            success = 'false';
        }
        System.debug('*********success********'+success);
        return null;
    }
    /*static testMethod void testSendSurvey()     
    {    
            Courses__c course = [SELECT Id FROM Courses__c WHERE Course_Confirmed_Total__c>0 AND Date_JI_First_Sent__c=:null AND Lead_Source__c!=:null LIMIT 1];  
            ApexPages.standardController controller = new ApexPages.standardController(course); 
            Course_SendSurvey classSC = new Course_SendSurvey(controller);
            classSC.emailTemplateId = [SELECT Id, Name,TemplateType,Description FROM EmailTemplate LIMIT 1].Id;
            classSC.getIsTemplateExist();
            classSC.changeFolder();
            classSC.getItems();
            classSC.sendJIEmail();
    } */  
    
}