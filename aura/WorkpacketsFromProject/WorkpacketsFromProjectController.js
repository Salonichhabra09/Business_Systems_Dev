({
    doInit : function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        component.set("v.ProjectId", context.attributes.recordId);
        helper.getProjectData(component, event);
	},
    
	 addRow: function(component, event, helper) {
        helper.addrowhelper(component, event);
    },
    
     removeRow: function(component, event, helper) {
        //Get the account list
        var docList = component.get("v.WorkpacketList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        docList.splice(index, 1);
        component.set("v.WorkpacketList", docList);
    },
     clonerow: function(component, event, helper) {
        //Get the account list
        //var docList = component.get("v.WorkpacketList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
         var docobj = component.get("v.WorkpacketList");
         //alert(JSON.stringify(docobj[index].Product_PS__c));
        //console.log('docobj'+JSON.stringify(docobj));
        var rowItemList = component.get("v.WorkpacketList");
        rowItemList.push({ 'sobjectType': 'Workpacket__c','CPS_Project_Number__c':component.get("v.ProjectId"),'Product_PS__c':JSON.stringify(docobj[index].Product_PS__c).slice(1, -1),'Solution_Type__c': JSON.stringify(docobj[index].Solution_Type__c).slice(1, -1),
                          'Status__c':JSON.stringify(docobj[index].Status__c).slice(1, -1),'Agreed_Delivery__c':JSON.stringify(docobj[index].Agreed_Delivery__c).slice(1, -1),'Description__c':JSON.stringify(docobj[index].Description__c).slice(1, -1),'CPS_Project_Manager_New__c':JSON.stringify(docobj[index].CPS_Project_Manager_New__c).slice(1, -1)});
        component.set("v.WorkpacketList", rowItemList); 
    },
    
    save: function(component, event, helper) {
       // if (helper.validateAccountList(component, event)) {
            helper.saveWorkpacketList(component, event);
        //}
    },
    cancel: function(component, event, helper) {
       // if (helper.validateAccountList(component, event)) {
            var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.ProjectId"),
                        "slideDevName": "related"
                    });
                    navEvt.fire(); 
        //}
    },
})