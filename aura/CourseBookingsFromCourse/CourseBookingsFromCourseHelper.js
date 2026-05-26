({  
    
     
    //Used to get the Course Details
	 getCourseData: function(component, event) {
        //Call Apex class and pass Course ID recieved from URL to get the fields
        console.log('This is Inside getCourseData with id as '+ component.get("v.recordId"));
        var action = component.get("c.getCourseData");
        action.setParams({
            "CourseId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("This is state "+response.getState());
            if (state === "SUCCESS") { 
                component.set("v.CourseRecord",response.getReturnValue());
                component.set("v.coursePrice",component.get("v.CourseRecord").Course_Price__c);
                component.set("v.MaxFreeSpaceValue",component.get("v.CourseRecord").Course_Free_Spaces__c);
                component.set("v.CurrentFreeSpaceValue",component.get("v.CourseRecord").Course_Free_Spaces__c);
                component.set("v.courseCategory",component.get("v.CourseRecord").Course_Category__c);
                component.set("v.CurrencyIsoCode",component.get("v.CourseRecord").CurrencyIsoCode);
                component.set("v.spinner", false); 
                component.set("v.ShowDetails",true);
                this.addrowhelper(component);
                //this.requiredQualificationsWarning(component);
                console.log('This is Course data '+JSON.stringify(component.get("v.CourseRecord")));
            }       
        }); 
        $A.enqueueAction(action);
    },
    
  //Used to add a new Row   
     addrowhelper: function(component) {
         debugger;
        var freeSpaceUsed = component.get('v.FreeSpaceCounter')+1;
        component.set('v.FreeSpaceCounter' , freeSpaceUsed); 
        component.set("v.hasDuplicatesCB", false);  
        var fs = component.get('v.CurrentFreeSpaceValue'); 
        var docobj = component.get("v.courseBookingList");

        var rowItemList = component.get("v.courseBookingList");
                 rowItemList.push({ 'sobjectType': 'Course_Booking__c',
                           'Course_Number__c':component.get("v.recordId"),
                           'Delegate_Contact__c': '',
                           'Lead_Source__c': '',
                           'Booking_Status__c': fs <= 0 ? 'Waiting' : 'Confirmed',
                           'CurrencyIsoCode':component.get("v.CurrencyIsoCode"),        
                           'Course_Price__c':component.get("v.coursePrice") }); 
       
          fs = fs-1;
          fs < 0 ? component.set('v.CurrentFreeSpaceValue' , 0 ) : component.set('v.CurrentFreeSpaceValue' , fs );
          fs <= 0 ? component.set('v.isDisabled' , true  ) : component.set('v.isDisabled' , false);
        component.set("v.courseBookingList", rowItemList);
    },
    
    //Check if Course Status is not cancelled
    checkCourseStatus: function(component,event,helper) {
           debugger;
           var title = 'Alert';
           var message ='No new booking can be created as this Course has been Cancelled.';
           this.showToast(component, event, helper , message, title );
        
     },
    
    MaxDelegateBookedHelper: function(component, event, helper ){
           var title = 'Warning';
           var message ='This course is currently full so this booking will be saved with a Status of Waiting.';
           this.showToast(component, event, helper , message, title );
         
    },
    
    //Show warning/alert as soon as page opens
    requiredQualificationsWarning: function(component) {

           var title = 'Alert';
           var message ='Please ensure the delegate has the required qualifications for this course before making the booking.';
           this.showToast(component, event, helper , message, title );
    },
    
    //Used to Save the Course Booking Data
    saveCBListHelper: function(component, event, helper) {
        //Call Apex class and pass Course Booking list parameters
        debugger;
        
        var action = component.get("c.saveCourseBookings");
        var cbList = component.get("v.courseBookingList");
        if(cbList.length > 0 ){
        action.setParams({
            "CBList": component.get("v.courseBookingList"),
            "fs": component.get("v.MaxFreeSpaceValue")
                     
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                     var title = response.getReturnValue().MessageType;
                     var message = response.getReturnValue().Message;
                     this.showToast(component, event, helper , message, title );
                     let CBListReturned = response.getReturnValue().duplicateCB;
                     if(CBListReturned.length != 0){
                        component.set("v.hasDuplicatesCB", true);  
                        component.set("v.courseBookingList", CBListReturned);
                        component.set("v.errorMessage",  'Duplicate Course Booking! This Course already has a Course Booking with this Delegate Contact.'); 
                     }
                     else{component.set("v.courseBookingList", []);
                     this.closeSubtabHelper(component);}
                     
                    
            }
             else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                         var title = 'Error';
                         var message = 'Please check all the mandatory fields are filled';
                         this.showToast(component, event, helper , message, title );
                       
                      
                    }
                }  }
            
            });
            $A.enqueueAction(action);}
        else{
             var title = 'Error';
                         var message = 'Please add a Course Booking to Save';
                         this.showToast(component, event, helper , message, title );
            
        }
    },
    
    closeSubtabHelper : function(component){
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                var parentTabId = response.parentTabId;
                workspaceAPI.refreshTab({tabId: parentTabId, includeAllSubtabs: false});
                workspaceAPI.closeTab({tabId: focusedTabId , label: "New Course Bookings"});
            });
          var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
            	"recordId": component.get("v.recordId"),
            	"slideDevName": "related"
            });
            navEvt.fire();
    },
    
    renameSubtabHelper : function(component, event, helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
             var focusedTabId;
             if(response.isSubtab){
             	focusedTabId = response.tabId;
             } else {
                 var parentTabId = response.tabId;
                 for(var i = 0; i < response.subtabs.length; i++){
                     if(response.title === "Loading..."){
                         focusedTabId = response.subtabs.tabId;       
                     }
                 }
             }
             
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "New Course Bookings"  });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: 'standard:event',
                iconAlt: " "}); })
        .catch(function(error) {
            console.log(error);
        });
    },
   
    
    removeRowHelper : function(component,event){
        
        var freeSpaceUsed = component.get('v.FreeSpaceCounter')-1;
        component.set('v.FreeSpaceCounter' , freeSpaceUsed);
        var maxFS = component.get('v.MaxFreeSpaceValue');
        var fs = component.get('v.CurrentFreeSpaceValue'); 
         fs = maxFS -freeSpaceUsed ;
      
        fs < 0 ? component.set('v.CurrentFreeSpaceValue' , 0 ) :  component.set('v.CurrentFreeSpaceValue' , fs ) ;
       
        var docList = component.get("v.courseBookingList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        docList.splice(index, 1);
        component.set("v.courseBookingList", docList);
    },
    
   /* cloneRowHelper : function(component , event){
         var freeSpaceUsed = component.get('v.FreeSpaceCounter')+1;
        component.set('v.FreeSpaceCounter' , freeSpaceUsed);
        var fs = component.get('v.CurrentFreeSpaceValue'); 
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        var docobj = component.get("v.courseBookingList");
        console.log('This is docobj '+JSON.stringify(docobj));
        var rowItemList = component.get("v.courseBookingList");
        var booleanValue = false;
           
          rowItemList.push({ 'sobjectType': 'Course_Booking__c',
                           'Course_Number__c':component.get("v.recordId"),
                           'Delegate_Contact__c': JSON.stringify(docobj[index].Delegate_Contact__c).slice(1, -1),
                           'Lead_Source__c': JSON.stringify(docobj[index].Lead_Source__c).slice(1, -1),
                            'CurrencyIsoCode':component.get("v.CurrencyIsoCode"),
                           'Booking_Status__c': fs <= 0 ? 'Waiting' : 'Confirmed',
                           'Course_Price__c':component.get("v.coursePrice")});
     
         console.log('This is rowItemList '+JSON.stringify(rowItemList));
          fs = fs-1;
          fs < 0 ? component.set('v.CurrentFreeSpaceValue' , 0 ) : component.set('v.CurrentFreeSpaceValue' , fs );
         
        component.set("v.courseBookingList", rowItemList); 
    },*/
     
    showToast : function(component, event, helper , message, title ) {
        debugger;
        
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": title,
        "message": message,
        "type" : title,
        "duration": 12000
    });
    component.set("v.spinner", false);     
    toastEvent.fire();
}
    
})