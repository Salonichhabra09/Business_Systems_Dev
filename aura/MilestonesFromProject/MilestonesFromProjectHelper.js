({
    addrowhelper: function(component) {
        var docobj = component.get("v.MilestoneList");
        console.log('docobj'+JSON.stringify(docobj));
        var rowItemList = component.get("v.MilestoneList");
        rowItemList.push({ 'sobjectType': 'Milestone__c','Project__c':component.get("v.recordId"),'BU__c': component.get("v.ProjectRecord.LBU__c"),'Service_Type2__c': '',
                          'Milestone_Period__c':'','Amount__c':'0.00','Practice_Area__c':'','Milestone_Description__c':'','CurrencyIsoCode':component.get("v.ProjectRecord.CurrencyIsoCode"),'Is_Signed__c':false});
        component.set("v.MilestoneList", rowItemList);
    },
    
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    saveMilestoneList: function(component, event, helper) {
        //Call Apex class and pass account list parameters
        var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.reportValidity();
        }, true);
        if(allValid){
        component.set("v.spinner", true);    
        var action = component.get("c.saveMilestones");            
        console.log("This is milestones list "+JSON.stringify(component.get("v.MilestoneList")));
        action.setParams({
            "MilestoneList": component.get("v.MilestoneList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if(response.getReturnValue()=='Milestone records saved successfully'){
                    component.set("v.spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": response.getReturnValue(),
                        "type": "Success"
                    })
                    toastEvent.fire();
                    component.set("v.MilestoneList", []);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "related"
                    });
                    navEvt.fire(); 
                }
                else{
                component.set("v.spinner", false);
                var responseString = response.getReturnValue();
                var errorString = responseString.substring(89,responseString.length);
                var errorString2 = responseString.substring(
                        responseString.indexOf(":") + 1, 
                        responseString.lastIndexOf(":")
                    );    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": errorString2,
                    "type": "Error",
                    "mode":"dismissible",
                    duration:8000
                })
                toastEvent.fire();
            }
        
            }
            
        }); 
            $A.enqueueAction(action); }
        else{
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": 'Please rectify the errors before saving.',
                    "type": "Error",
                    "mode":"dismissible",
                    duration:8000
                })
                toastEvent.fire();
        }
    },
    getProjectData: function(component, event, helper) {
        //Call Apex class and pass account list parameters
        console.log('This is Inside getProjectData with id as '+component.get("v.recordId"));
        var action = component.get("c.getProjectData");
        action.setParams({
            "ProjectId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("This is state "+response.getState());
            if (state === "SUCCESS") {
                
                component.set("v.ProjectRecord",response.getReturnValue());
                component.set("v.CurrentMilestoneValue",component.get("v.ProjectRecord").Milestones_Value__c);
                component.set("v.ShowDetails",true);
                this.addrowhelper(component);
                console.log('This is project data '+JSON.stringify(component.get("v.ProjectRecord")));
            }       
        }); 
        $A.enqueueAction(action);
    },
    updateMilestoneValueHelper: function(component, event, helper) {
      var row= component.get('v.MilestoneList');
        var totalAmount=0;
        var unit=0;
        for (var i = 0; i < row.length; i++){
                if(isNaN(parseFloat(row[i].Amount__c))){
                    unit=0;
                } 
                else{
                    unit = parseFloat(row[i].Amount__c);
                }
                totalAmount= unit + totalAmount;
             
                
            }
        console.log("Today This is total amount "+totalAmount);
        console.log("Today This is project amount "+component.get("v.ProjectRecord").Milestones_Value__c);
         var currentMilestonevalue = totalAmount + parseFloat(component.get("v.ProjectRecord").Milestones_Value__c);
        component.set("v.CurrentMilestoneValue",currentMilestonevalue);
        //console.log("This is total amount "+totalAmount);
        //console.log("This is CurrentMilestoneValue "+currentMilestonevalue);
    },
   
    
})