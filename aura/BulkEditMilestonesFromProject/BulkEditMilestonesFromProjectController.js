({
    onPageReferenceChange: function(component, event, helper) {
       /* var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        component.set("v.recordId", context.attributes.recordId); */
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__recordId;
        component.set("v.recordId", id);
        helper.getProjectData(component, event);
    },    
	/* addRow: function(component, event, helper) {
        helper.addrowhelper(component, event);
    },*/
    
     removeRow: function(component, event, helper) {
        //Get the account list
        var docList = component.get("v.MilestoneList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        docList.splice(index, 1);
        component.set("v.MilestoneList", docList);
        helper.updateMilestoneValueHelper(component, event, helper);
    },
     clonerow: function(component, event, helper) {
        //Get the account list
        //var docList = component.get("v.WorkpacketList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        index = Number(index);
        console.log('index---',index);
         var docobj = component.get("v.MilestoneList");
        console.log('This is docobj '+JSON.stringify(docobj));
        var rowItemList = component.get("v.MilestoneList");

        try {
            var booleanValue = false;
            if(JSON.stringify(docobj[index].Is_Signed__c)=="true")
                booleanValue=true;
            // rowItemList.push({ 'sobjectType': 'Milestone__c','Project__c':component.get("v.recordId"),'BU__c':JSON.stringify(docobj[index].BU__c).slice(1, -1),'Service_Type2__c': JSON.stringify(docobj[index].Service_Type2__c).slice(1, -1),
            //                   'Milestone_Period__c':JSON.stringify(docobj[index].Milestone_Period__c).slice(1, -1),'Amount__c':JSON.stringify(docobj[index].Amount__c).slice(1, -1),'Milestone_Owner__c':JSON.stringify(docobj[index].Milestone_Owner__c).slice(1, -1),'CurrencyIsoCode':JSON.stringify(docobj[index].CurrencyIsoCode).slice(1, -1),'Cross_Border_BU__c':JSON.stringify(docobj[index].Cross_Border_BU__c).slice(1, -1),'Is_Signed__c':booleanValue});
            
            let milestoneObject = { 'sobjectType': 'Milestone__c',
                                   'Project__c':component.get("v.recordId"),
                                   'BU__c':docobj[index].BU__c,
                                   'Service_Type2__c': docobj[index].Service_Type2__c,
                                    'Milestone_Period__c':docobj[index].Milestone_Period__c,
                                   'Amount__c':docobj[index].Amount__c.toString(),
                                   'Practice_Area__c':docobj[index].Practice_Area__c,                       
                                   'Milestone_Description__c':docobj[index].Milestone_Description__c,
                                   //Added by Prachi as part of SSE-22281
                          'Milestone_Risk__c':docobj[index].Milestone_Risk__c,
                          'Track_change__c':docobj[index].Track_change__c,
                          //Changes End as part of SSE-22281
                                   'CurrencyIsoCode':docobj[index].CurrencyIsoCode,
                                   'Is_Signed__c':booleanValue};
            milestoneObject.clonedRow = true;
            rowItemList.splice(index + 1, 0 , milestoneObject);
            console.log('This is rowItemList '+JSON.stringify(rowItemList));
            component.set("v.MilestoneList", rowItemList); 
            helper.updateMilestoneValueHelper(component, event, helper);
        } catch(error) {
            let errorMsg = JSON.stringify(docobj[index].BU__c) ? error.message : 'Insufficient access on milestone records.';
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": errorMsg,
                    "type": "Error",
                    "mode":"dismissible",
                    duration:8000
                })
                toastEvent.fire();
        }
    },
    
    save: function(component, event, helper) {
       // if (helper.validateAccountList(component, event)) {
            helper.saveMilestoneList(component, event);
        //}
    },
    cancel: function(component, event, helper) {
       // if (helper.validateAccountList(component, event)) {
            var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "related"
                    });
                    navEvt.fire(); 
        //}
    },
     updateMilestoneValue: function(component, event, helper) {
     helper.updateMilestoneValueHelper(component, event, helper);
    },
   
})