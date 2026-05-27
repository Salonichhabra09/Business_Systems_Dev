({
    newCourseBooking: function(component, event, helper) {
        debugger;

        var workspaceAPI = component.find("workspace");
        var myPageRef = component.get("v.pageReference").state.c__courseStatus;
              
        if( myPageRef == "Cancelled" ||myPageRef == "Cancelled - to be rebooked" || 
           myPageRef == "Cancelled - to be credited"||myPageRef == "Cancelled - chargeable") {

            var toastEvent1 = $A.get("e.force:showToast");
            toastEvent1.setParams({
                mode: 'sticky',
                type: 'warning',
                title: 'Alert',
                message: 'No new booking can be created as this Course has been Cancelled.',
            });
            toastEvent1.fire();
            
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
            	"recordId": component.get("v.pageReference").state.c__id,
            	"slideDevName": "related"
            });
            navEvt.fire();

        } else{
            var bookingStatus;
             if (parseInt(component.get("v.pageReference").state.c__freeSpaces) <= 0){
                bookingStatus = "Waiting";
            } else {
                bookingStatus = "Confirmed";
            }
            
            
            var str = component.get("v.pageReference").state.c__coursePrice
            
            var price;
            
            if(str != ''){
                var s = str.split(" ");
                price = s[1].replace(",","");  
            } else {
                price = '0';
            }
            
            var urlString = "/lightning/o/Course_Booking__c/new?defaultFieldValues=Course_Name__c="+ component.get("v.pageReference").state.c__cName +
                        ",Course_Number__c=" + component.get("v.pageReference").state.c__id + 
                        ",Course_Price__c=" + price +
                        ",CurrencyIsoCode=" + component.get("v.pageReference").state.c__currency +
                		",Booking_Status__c=" + bookingStatus

            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});         
           }).then(
                workspaceAPI.openTab({
                    recordId: component.get("v.pageReference").state.c__id,
                    focus: true
                }).then(function(response) {
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: urlString,
                        focus: true
                    }).then(function(){

                        
                        if (parseInt(component.get("v.pageReference").state.c__freeSpaces) <= 0){
                            //setTimeout(function() {
                                var toastEvent3 = $A.get("e.force:showToast");
                                toastEvent3.setParams({
                                    duration: 12000,
                                    type: 'info',
                                    title: 'Information',
                                    message: 'This course is currently full so this booking will be saved with a Status of Waiting.',
                                });
                                toastEvent3.fire();
                           // }, 5000);
                        }
                        
                        /*var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            duration: 12000,
                            type: 'warning',
                            title: 'Alert',
                            message: 'Please ensure the delegate has the required qualifications for this course before making the booking.',
                        });
                        toastEvent2.fire();*/
                    });
                })
			)
       }

    }
});