({
    init: function (cmp, event, helper) { 
        cmp.set("v.spinner", true);
        helper.inithelper(cmp, event, helper);
    },
    
   	addRow: function(component, event, helper) {
        helper.addrowhelper(component, event);
    },
    
    removeRow: function(component, event, helper) {
        helper.removeRowHelper(component, event, helper);
    },
    
    cloneRow: function(component, event, helper) {
		helper.cloneRowHelper(component,event,helper);
    },
    
    cancel: function(component, event, helper) {
        helper.cancelHelper(component,event,helper);
    },
    
    removeAllRows: function(component, event, helper) {
        helper.removeAllRowsHelper(component,event,helper);
        component.set("v.errorMessage",  '');
    },
    
   	save: function(component, event, helper) {
   		component.set("v.spinner", true);
        component.set("v.spinerMessage", "Contacts and Course Bookings are being created, please wait a few seconds ...")
   		helper.saveContactListHelper(component, event, helper);
   	},
    
    saveCourseBookingsForDuplicates: function(component, event, helper) {
        component.set("v.spinner", true);
   		helper.saveCourseBookingsForDuplicatesHelper(component, event, helper);
    },
    
    handleUploadFinished: function(component, event, helper) {
		component.set("v.spinner", true);
        component.set("v.spinerMessage", "Uploading Contacts from .csv file. Please wait a few seconds ...");
        helper.handleUploadFinishedHelper(component, event,helper);
	},
    
})