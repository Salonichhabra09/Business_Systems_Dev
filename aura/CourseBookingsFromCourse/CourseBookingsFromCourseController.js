({
	onPageReferenceChange: function(component, event, helper) {
        debugger;
        component.set("v.spinner", true); 
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__recordId;
        component.set('v.recordId' , id);
        if(myPageRef.state.c__courseStatus == "Cancelled" ||myPageRef.state.c__courseStatus == "Cancelled - to be rebooked" || 
           myPageRef.state.c__courseStatus == "Cancelled - to be credited"||myPageRef.state.c__courseStatus == "Cancelled - chargeable" ){
           
            helper.checkCourseStatus(component,event,helper);
            helper.closeSubtabHelper(component);
              }
        else{
           //To change the name of Subtab in Service Console
             helper.renameSubtabHelper(component,event,helper);
             component.set("v.spinner", true);
        //To get the Related Course ID on which Course Bookings are being created.
            helper.getCourseData(component, event,helper);}
    },   
    
    addRow: function(component, event, helper) {
        helper.addrowhelper(component, event);
    },
     removeRow: function(component, event, helper) {
        
        helper.removeRowHelper(component , event);
    },
     clonerow: function(component, event, helper) {
        
        helper.cloneRowHelper(component,event);
    },
    
    save: function(component, event, helper) {
            debugger;
            component.set("v.spinner", true);
            helper.saveCBListHelper(component, event);
            
        
    },
    cancel: function(component, event, helper) {
           helper.closeSubtabHelper(component);
        
    },
   
})