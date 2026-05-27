({
   /* addrowhelper: function(component) {
        var docobj = component.get("v.WorkpacketList");
        console.log('docobj'+JSON.stringify(docobj));
        var rowItemList = component.get("v.WorkpacketList");
        rowItemList.push({ 'sobjectType': 'Workpacket__c','CPS_Project_Number__c':component.get("v.ProjectId"),'Product_PS__c': '','Solution_Type__c': '',
                          'Status__c':'','Agreed_Delivery__c':'','Description__c':'','CPS_Project_Manager__c':''});
        component.set("v.WorkpacketList", rowItemList);
    },
    
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    }, */
    
    saveWorkpacketList: function(component, event, helper) {
        //Call Apex class and pass account list parameters
        var action = component.get("c.saveWorkpackets");
        action.setParams({
            "WorkpacketList": component.get("v.WorkpacketList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if(response.getReturnValue()=='Workpacket records saved successfully'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": response.getReturnValue(),
                        "type": "Success"
                    })
                    toastEvent.fire();
                    component.set("v.WorkpacketList", []);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "related"
                    });
                    navEvt.fire(); 
                }
                else{
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
        $A.enqueueAction(action);
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
                component.set("v.ShowDetails",true);
                this.getWorkpacketData(component);
                console.log('This is project data '+JSON.stringify(component.get("v.ProjectRecord")));
            }       
        }); 
        $A.enqueueAction(action);
    },
    getWorkpacketData: function(component, event, helper) {
        //Call Apex class and pass account list parameters
        console.log('This is Inside getMilestonesData with ids as '+component.get("v.SelectedWorkpackets"));
        var action = component.get("c.getData");
        action.setParams({
            "SelectedIds": component.get("v.SelectedWorkpackets")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("This is state "+response.getState());
            console.log("This is response "+response.getReturnValue());
            if (state === "SUCCESS") {
                
                component.set("v.WorkpacketList",response.getReturnValue());
                //component.set("v.CurrentMilestoneValue",component.get("v.ProjectRecord").Milestones_Value__c);
                component.set("v.ShowDetails",true);
                //this.addrowhelper(component);
                //console.log('This is Milestone data '+JSON.stringify(component.get("v.MilestoneList")));
            }       
        }); 
        $A.enqueueAction(action);
    },
    
})