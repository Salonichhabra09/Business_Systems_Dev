({
	doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id").substring(0,15);                        
        var URL = "http://10.180.4.97/ReportServer?%2FAssessment%20Platform%2FSales%2FPerformance%2FReports%20on%20demand&rc:Toolbar=false&Logged_in_User_ID="+userId+"&rs%3AParameterLanguage=en-US" ;
        component.set("v.CommercialURLLabel", URL);
    }
})