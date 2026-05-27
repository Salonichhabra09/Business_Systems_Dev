({
	doInit : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/lightning/o/Milestone_Period__c/new?nooverride=1&defaultFieldValues=Name=To be Autopopulated&backgroundContext=%2Flightning%2Fo%2FMilestone_Period__c%2Flist%3FfilterName%3DRecent"
    });
    urlEvent.fire();
	}
})