global class Project_Manager 
{
    public static List<ProjectObject__c> getProjectsForInvoices(List<Project_Invoice__c> invoices)
    {
        Set<Id> projectIds = new Set<Id>();
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
        
        for(Integer i=0;i<invoices.size();i++)
        {
            if(!projectIds.contains(invoices[i].Project__c))
            {
                projects.add(new ProjectObject__c(id = invoices[i].Project__c));    
                projectIds.add(invoices[i].Project__c); 
            }   
        } 
        
        return projects;
    }
    
    public static boolean userCanCreateProjects()
    {
        User user = getUserDetails();
        
        //If the user is a PSA Lead
        if(user.PSA_Role__c == 'PSA Lead')
            return true;
        //If the user is a Project Manager
        else if(user.PSA_Role__c == 'Project Manager')
            return true;
        //if it is any other user
        else
            return false;
    }

    public static boolean userCanManageAllProjects()
    {
        User user = getUserDetails();
        
        //If the user is a PSA Lead
        if(user.PSA_Role__c == 'PSA Lead')
            return true;
        //if it is any other user
        else
            return false;
    }
    
    public static Map<Id, Boolean> userCanManageProjects(List<ProjectObject__c> projects)
    {
        projects = getProjectDetails(projects);
        
        User user = getUserDetails();
        
        Map<Id, Boolean> projectAccessMap = new Map<Id, Boolean>();
        //If the user is a PSA Lead
        if(user.PSA_Role__c == 'PSA Lead')
        {
            for(ProjectObject__c project: projects)
                  projectAccessMap.put(project.Id, true);
        }
        else if(user.PSA_Role__c == 'Project Manager')
        {
            for(ProjectObject__c project: projects)
            {
                if(user.Id == project.Project_Manager__c)
                    projectAccessMap.put(project.Id, true);
                else
                    projectAccessMap.put(project.Id, false);
            }
        }
        else
        {
            for(ProjectObject__c project: projects)
                  projectAccessMap.put(project.Id, false);
        }
        return projectAccessMap;
    }
    
    private static User getUserDetails()
    {
        User user = [SELECT id, Profile.PermissionsModifyAllData, PSA_Role__c FROM USER WHERE id = :Userinfo.getUserId()];
        return user;
    }
    
    private static List<ProjectObject__c> getProjectDetails(List<ProjectObject__c> projects)
    {
        Map<Id, ProjectObject__c> projectMap = new Map<Id, ProjectObject__c>(projects);
        for(ProjectObject__c project: projects)
        {
            if(project.Project_Manager__c==null)
            {
                projects = [SELECT Id, Project_Manager__c FROM ProjectObject__c WHERE Id IN :projectMap.keySet()];
            }
        }
        return projects;
    } 
    
    WebService static void populateProjectWithUpdatedAmounts(ProjectObject__c selectedProject,Boolean includeAssociates)
    {
        ProjectObject__c project = getProjectWithUpdatedAmounts(selectedProject,includeAssociates);
        
    }
    
    WebService static ProjectObject__c getProjectWithUpdatedAmounts(ProjectObject__c selectedProject,Boolean includeAssociates)
    {
        ///Intialize the instance of the project that is to be returned by the function
        ProjectObject__c project = new ProjectObject__c(id=selectedProject.id);
        
        Map<String, Double> currencyMap = new Map<String, Double>();
        for(CurrencyType currencyType: [SELECT IsoCode, ConversionRate FROM CurrencyType])
            currencyMap.put(currencyType.IsoCode, currencyType.ConversionRate);
               
        //Find the Invoice CurrencyType
        Double projectCurrencyConversionRate = currencyMap.get(selectedProject.CurrencyIsoCode);
        return project;
    }
    
    
    /*WebService static void changeProjectNumberFormat(ProjectObject__c selectedProject)
    {
        string Serial;
        Integer Sequence;
        ProjectObject__c project = new ProjectObject__c(id=selectedProject.Id);
        
        Serial = [Select SequenceNo__c from ProjectObject__c Order By SequenceNo__c Desc LIMIT 1].SequenceNo__c;
        Sequence=serial!=null?Integer.valueOf(Serial):1;
        
        string[] monthName = new string[]{'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
        
        project.PNO__c = 'P'+ selectedProject.LBU__c+ selectedProject.createdDate.year()+ monthName[(selectedProject.createdDate.month())-1]+ selectedProject.createdDate.day()+'-'+Sequence;
        update project;
    }
    
    public static testMethod void testChangePNo()
    {
        ProjectObject__c project = [SELECT  Id,LBU__c, CreatedDate from ProjectObject__c Where Id ='a09R0000000Ajxp'LIMIT 1];
        changeProjectNumberFormat(project);
    }*/
}