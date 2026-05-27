({
    init: function (component, event, helper) { 
        component.set("v.showSpinner", true);
        helper.handleInit(component, event, helper);
    },
    
    recordUpdated : function(component, event, helper) {
        if( event.getParams().changeType == 'CHANGED'){
           helper.handleRefreshData(component, event, helper); 
        }
	},
    
    handleSend: function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.handleSendHelper(component, event, helper);
    },
    
    handlePreview: function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.handlePreviewHelper(component, event, helper);
    },
    
    handleDownloadAll: function (component, event, helper) {      
        helper.handleDownloadAllHelper(component, event, helper);
    },
    
    handleClosePreview: function (component, event, helper) {
        helper.handleClosePreviewHelper(component, event, helper);
    },
    
    handleDownloadSingle: function (component, event, helper) {
        helper.handleDownloadSingleHelper(component, event, helper);
    },
    
    handleRefreshData: function (component , event, helper) {
        component.set("v.showSpinner", true);
        helper.handleRefreshData(component , event, helper);
    },
    
    handleFilesChange: function (component , event, helper) {
        component.set("v.showSpinner", true);
        helper.handleFilesChangeHelper(component , event, helper);
    },
    
    handleRemovePartnerLogo: function (component , event, helper) {
        component.set("v.showSpinner", true);
        helper.handleRemovePartnerLogoHelper(component , event, helper);
    }
})