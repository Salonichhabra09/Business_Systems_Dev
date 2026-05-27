({
  doInit: function(component, event, helper) {
    component.set("v.recordId", component.get("v.pageReference").state.c__id);
    var action = component.get("c.checkuser");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var validuser = response.getReturnValue();
        if (validuser) {
          var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            url:
              "/lightning/o/ProjectObject__c/new?recordTypeId=012D0000000VAFcIAO&nooverride=1&defaultFieldValues=PS_Project_Number__c="+component.get("v.recordId")+"&backgroundContext=%2Flightning%2Fr%2FProjectObject__c%2F"+component.get("v.recordId")+"%2Fview?"
            //"url": "/lightning/o/Milestone_Period__c/new?nooverride=1&defaultFieldValues=Name=To be Autopopulated&backgroundContext=%2Flightning%2Fo%2FMilestone_Period__c%2Flist%3FfilterName%3DRecent"
          });
            //alert(urlEvent);
          urlEvent.fire();
        } else {
            
          var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        mode: 'sticky',
                        message: "You do not have access to create a Central PS project.",
                        type: "error"
                    });
                    toastEvent.fire();  
          //alert("You do not have access to create a Central PS project.");
          var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            url:
              "/lightning/r/ProjectObject__c/"+component.get("v.recordId")+"/view"
            //"url": "/lightning/o/Milestone_Period__c/new?nooverride=1&defaultFieldValues=Name=To be Autopopulated&backgroundContext=%2Flightning%2Fo%2FMilestone_Period__c%2Flist%3FfilterName%3DRecent"
          });
            //alert(urlEvent);
          urlEvent.fire();
        }
      } else {
        alert("error occured");
      }
    });
    $A.enqueueAction(action);
  }
});