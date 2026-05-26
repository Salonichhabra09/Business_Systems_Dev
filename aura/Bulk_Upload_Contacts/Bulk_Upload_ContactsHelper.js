({

    success: 0,
    error: 0,
    count: 0,
    arraySuccess:[],
    arrayDuplicatesCB:[],
    parentTabId:'',
    subTabId:'',
    
    inithelper: function (cmp, event, helper) {
        var self = this;
        var workspaceAPI = cmp.find("workspace");
        var myPageRef = cmp.get("v.pageReference");
        var id = myPageRef.state.c__recordId;
        cmp.set('v.spaces', myPageRef.state.c__spaces);
        var category = myPageRef.state.c__category;
		
		cmp.set('v.recordId' , id);
		self.parentTabId = '';
        self.subTabId = '';
        
        
		workspaceAPI.getFocusedTabInfo().then(function(response) {
             var focusedTabId;
             if(response.isSubtab){
             	focusedTabId = response.tabId;
                self.subTabId = response.tabId;
                self.parentTabId = response.parentTabId;
             } else {
                 self.parentTabId = response.tabId;
                 for(var i = 0; i < response.subtabs.length; i++){
                     if(response.title === "Loading..."){
                         focusedTabId = response.subtabs.tabId;
                         self.subTabId = response.subtabs.tabId;                       
                     }
                 }
             }
             
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: 'Contacts'
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: 'standard:contact',
                    iconAlt: "Contacts"
                });
         });
        
        /*if(category === 'Public') {
            this.addrowhelper(cmp, event)
        } else {*/
            this.getCourse(cmp, event);
        //}
      
        cmp.set("v.spinner", false);
    },
    
    addrowhelper: function (component, event) {
        var docobj = component.get("v.ContactList");
        var rowItemList = component.get("v.ContactList");
        if(component.get("v.accountId") === undefined || component.get("v.accountId") === ''){
            component.set("v.disable", false);
        } else {
            component.set("v.disable", true); 
        }
        rowItemList.push({ 'sobjectType': 'Contact', 'AccountId': component.get("v.accountId"), 'FirstName': '', 'LastName': '', 'Email': '', 'Phone': '', 'Registration_Number__c':'' ,'Same_As_The_Account_Billing_Address__c': true });
        component.set("v.ContactList", rowItemList);
        component.set("v.hasDuplicatesContacts", false);
    },

    getCourse: function(component, event) {
        let self = this;
        let accountId = '';
        var action = component.get("c.getCourse");
        
        action.setParams({
            "CourseId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") { 
                component.set("v.courseCategory", response.getReturnValue().Course_Category__c);
                component.set("v.coursePrice", response.getReturnValue().Course_Price__c);
				component.set("v.CurrencyIsoCode", response.getReturnValue().CurrencyIsoCode);
                
                if(response.getReturnValue().Course_Category__c != 'Public'){                  
                    component.set("v.accountId",response.getReturnValue().Partner_Account_Name__c);

                    if(component.get("v.accountId") === undefined){
                        component.set("v.disable", false);
                    } else {
                       component.set("v.disable", true); 
                    }
                    
                } else {
                    component.set("v.accountId",'');
                    component.set("v.disable", false);
                }
            }else {
                component.set("v.accountId",'');
                component.set("v.disable", false);
            }
            self.addrowhelper(component, event);
        }); 
        $A.enqueueAction(action);
    },
    
    
    removeRowHelper: function (component, event, helper) {
        var docList = component.get("v.ContactList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;

        docList.splice(index, 1);
        component.set("v.ContactList", docList);
        
        if(component.get("v.accountId") === undefined || component.get("v.accountId") === ''){
            component.set("v.disable", false);
        } else {
            component.set("v.disable", true); 
        }
        
        if(docList.length == 0){
            self.arrayDuplicatesCB = [];
            component.set("v.hasDuplicatesContacts", false);
        	component.set("v.disabledWhenDuplicates",  false);
        };
    },

    removeAllRowsHelper: function (component, event, helper) {
        component.set("v.ContactList",[]);
        self.arrayDuplicatesCB = [];
        component.set("v.hasDuplicatesContacts", false);
        component.set("v.disabledWhenDuplicates",  false);
        component.set("v.display", 'display: none;');
        component.set("v.width", '20%'); 
        this.addrowhelper(component, event);
    },
    
    cloneRowHelper: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var docobj = component.get("v.ContactList");
        var rowItemList = component.get("v.ContactList");

        rowItemList.push({
            'sobjectType': 'Contact',
            'AccountId': JSON.stringify(docobj[index].AccountId).slice(1, -1),
            'FirstName': JSON.stringify(docobj[index].FirstName).slice(1, -1),
            'LastName': JSON.stringify(docobj[index].LastName).slice(1, -1),
            'Email': JSON.stringify(docobj[index].Email).slice(1, -1),
            'Phone': JSON.stringify(docobj[index].Phone).slice(1, -1),
            'Same_As_The_Account_Billing_Address__c': true,
        });

        component.set("v.ContactList", rowItemList);
    },

    cancelHelper: function (component, event, helper) {
       	var workspaceAPI = component.find("workspace");
        let self = this;
        workspaceAPI.closeTab({ tabId: self.subTabId });
        workspaceAPI.focusTab({ tabId : self.parentTabId});
        self.subTabId = '';
    },
	
        
	saveCourseBookings: function (component, event, helper, conList, close){

        let self = this;
        component.set("v.courseBookingList", []);
        let cb = [];        
		var workspaceAPI = component.find("workspace");
		
        (conList).forEach(function (element) {
                              cb.push({ 'sobjectType': 'Course_Booking__c',
                              'Course_Number__c': component.get("v.recordId"),
                              'Delegate_Contact__c': element.Id,
                              'Lead_Source__c': '',
                              'CurrencyIsoCode':component.get("v.CurrencyIsoCode"),
                              'Course_Price__c':component.get("v.coursePrice")});
        });
        component.set("v.courseBookingList",cb);
        
            var action = component.get("c.saveCourseBookings");
                action.setParams({
                    "courseBookingList": cb
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();

                    if (state === "SUCCESS") {
                        let contactListReturned = response.getReturnValue().duplicateContacts;

                        let contactListAux = [];
                        if(contactListReturned.length != 0){
                            close = false;
                            (contactListReturned).forEach(function (element) {
                                
                                let regNum = element.Registration_Number_legacy__c != null ? element.Registration_Number_legacy__c : element.Registration_Number__c;  
                                
                              contactListAux.push({'sobjectType': 'Contact', 
                                'AccountId': element.AccountId, 
                                'FirstName': element.FirstName, 
                                'LastName': element.LastName, 
                                'Email': element.Email, 
                                'Phone': element.Phone,
                                'Registration_Number__c': regNum,
                                'Same_As_The_Account_Billing_Address__c': true });                               
                            });
                            component.set("v.errorMessage",  response.getReturnValue().errorMessage);                           
							component.set("v.ContactList",  contactListAux);

                            self.arrayDuplicatesCB = contactListReturned;
                            
                            component.set("v.hasDuplicatesContacts", true);
        					component.set("v.disabledWhenDuplicates",  true);
                        }
                        
                        if (response.getReturnValue().insertedCB == true) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "message": 'Course Booking(s) Successfully Created',
                                "type": "Success",
                                "mode": "dismissible",
                                 duration: 11000
                            })
                            toastEvent.fire();
                            
                            workspaceAPI.refreshTab({
                                      tabId: this.parentTabId,
                                      includeAllSubtabs: false
                             });
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "message": response.getReturnValue().errorMessage,
                                "title": "Error inserting Course Booking: ",
                                "type": "Error",
                                "mode": "dismissible",
                                duration: 15000
                            })
                            toastEvent.fire();
                        }
                    } else {
                            //var responseString = response.getReturnValue();
                            //var errorString = responseString.substring(89, responseString.length);
                            //var errorString2 = responseString.substring(responseString.indexOf(":") + 1, responseString.lastIndexOf(":"));
							close = false;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "message": 'Something went wrong while saving the Course Bookings. Please Contact your System Administrator',
                                "type": "Error",
                                "mode": "dismissible",
                                duration: 12000
                            })
                            toastEvent.fire();
                     }
                    
                    //self.arrayDuplicatesCB = [];
                    component.set("v.spinner", false);
                    
                	if (close) {
                        self.cancelHelper(component, event, helper);
                    }

                });
                $A.enqueueAction(action); 
	},
        
 	removeBlankRows: function (component) {
        var docList = component.get("v.ContactList");
        var i = 0;
        docList.forEach(function (element) {         
            if((element.AccountId =='' || element.AccountId == null || element.AccountId == undefined ) &&
               (element.FirstName =='' || element.FirstName == null || element.FirstName == undefined ) &&
               (element.LastName =='' || element.LastName == null || element.LastName == undefined ) &&
               (element.Email =='' || element.Email == null || element.Email == undefined ) &&
               (element.Phone =='' || element.Phone == null || element.Phone == undefined ) ) {
                docList.splice(i, 1);
            };
            i++;
        });    
        component.set("v.ContactList", docList);

	},
        
    
    saveContactListHelper: function (component, event, helper) {
        let self = this;
        self.arrayDuplicatesCB = [];

        component.set("v.courseBookingList", []);
		component.set("v.hasDuplicatesContacts", false);
        let arrayDuplicates = [];
        
        if (component.get("v.ContactList").length == 0) {
            var toastEvent1 = $A.get("e.force:showToast");
            toastEvent1.setParams({
                "message": "Please ensure that there is at least one Contact to insert!",
                "type": "Error"
            })
            toastEvent1.fire();
            component.set("v.spinner", false);

        } else {
            const forms = component.find("Contactform");
            let fields = component.find("field");

            const valid = fields.reduce((validSoFar, field) => {
                field.reportValidity();
                return (validSoFar && field.reportValidity());
            }, true);

            if (valid) {
                console.log('RECORDS -- ', component.get("v.ContactList"));
                var action = component.get("c.saveContacts");
                action.setParams({
                    "contactList": component.get("v.ContactList")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    var contactList = component.get("v.ContactList");
					console.log("STATE --> ", state);
                    console.log("RESULT --> ", response.getReturnValue());
                    if (state === "SUCCESS") {
                        
                        let duplicateResults = response.getReturnValue().duplicateContacts;

                        if(duplicateResults.length > 0 ){

                            (duplicateResults).forEach(function (element) {
                              
                              	let regNum = element.Registration_Number_legacy__c != null ? element.Registration_Number_legacy__c : element.Registration_Number__c;  
                              	console.log('REgistration number 1 ' + element.Registration_Number_legacy__c) ;
                                console.log('REgistration number 2 ' + element.Registration_Number__c) ;
                                console.log('REgistration number  3' + regNum) ;
                                
                                arrayDuplicates.push({'sobjectType': 'Contact', 
                                'AccountId': element.AccountId, 
                                'FirstName': element.FirstName, 
                                'LastName': element.LastName, 
                                'Email': element.Email, 
                                'Phone': element.Phone,
                                'Registration_Number__c': regNum,
                                'Same_As_The_Account_Billing_Address__c': true });                               
                            });
                            
                            self.arrayDuplicatesCB = duplicateResults;
							component.set("v.ContactList",  arrayDuplicates);
                            component.set("v.disabledWhenDuplicates",  true);
                            component.set("v.disable",  true);
                            component.set("v.errorMessage",  response.getReturnValue().errorMessage);
                            component.set("v.hasDuplicatesContacts", true);
                        }
                        
                        let insertedResult = response.getReturnValue().insertedContacts;
                        if(insertedResult.length > 0 ){

                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": insertedResult.length + " Contact(s) Successfully Created",
                                "message": " ",
                                "type": "Success",
                                "mode": "dismissible",
                                duration: 11000
                            })
                            toastEvent.fire();
                         }
                        
                        if(insertedResult.length != 0  && duplicateResults.length == 0){
                            //only unique values
                            let close = true;
                            self.saveCourseBookings(component, event, helper, insertedResult, close);
                        } else if ( insertedResult.length != 0  && duplicateResults.length != 0){
                            // unique values and duplicates
                            let close = false;
                            component.set("v.display", '/*display: none;*/');
                            self.saveCourseBookings(component, event, helper, insertedResult, close);
                        }else if ( insertedResult.length == 0  && duplicateResults.length != 0){
                            // only duplicates values
                            component.set("v.spinner", false);
                            component.set("v.width", '15%');
                            component.set("v.display", '/*display: none;*/');
                        } else {
                            console.log('Message' , response.getReturnValue().errorMessage);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": 'The following error is preventing the Contacts from being ceated:',
                                "message": response.getReturnValue().errorMessage,
                                "type": "Error",
                                "mode": "dismissible",
                                duration: 15000
                            })
                            toastEvent.fire();
                            component.set("v.spinner", false);
                        }
                        

                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "Something Went wrong while saving the Contacts! Please Contact your System administrator",
                            "type": "Error",
                            "mode": "dismissible",
                            duration: 10000
                        })
                        toastEvent.fire();
                        component.set("v.spinner", false);
                    }
                });
                $A.enqueueAction(action);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Please ensure that all Required fields have a value !",
                    "type": "Warning",
                    "mode": "dismissible",
                    duration: 10000
                })
                toastEvent.fire();
                component.set("v.spinner", false);
            }
        }
    },
	
    saveCourseBookingsForDuplicatesHelper: function (component, event, helper) {
        let self = this; 
        let close = true;  	
        self.saveCourseBookings(component, event, helper, self.arrayDuplicatesCB, close );
    	self.arrayDuplicatesCB = [];
    },

        
        
    handleUploadFinishedHelper: function (component, event, helper) {
        let self = this;
        var file = event.getSource().get("v.files")[0];
		component.set("v.hasDuplicatesContacts", false);
        
        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = function (evt) {
                var csv = evt.target.result;

                var result = self.parseCSV(component, csv);
                
            }
            reader.onerror = function (evt) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error reading file, please try again or contact your System Administrator.",
                    "message": "",
                    "type": "Error",
                    "mode": "dismissible",
                     duration: 12000
                })
                toastEvent.fire();
                component.set("v.spinner", false);
            }
        }

    },

    parseCSV: function (component, csv) {
        let accountNumerList = [];
        let tempContactList = [];
        
        var arr = [];
        
        let csvTemp = csv.replaceAll('"\n','');
        let csvTemp1 = csvTemp.replaceAll('\n"','');
		let csvTemp2 = csvTemp1.replaceAll('"','');
        
        arr = csvTemp2.split('\n');
        arr.pop();

        var headers = arr[0].split(',');
        
        if (headers.length === 1) {
        	arr[0] = arr[0].replaceAll(';', ',');
        	headers = arr[0].split(',');
        }

		if( headers[0].toUpperCase().trim().replaceAll(' ', '') != 'ACCOUNTNUMBER' || 
			headers[1].toUpperCase().trim().replaceAll(' ', '') != 'FIRSTNAME' || 
            headers[2].toUpperCase().trim().replaceAll(' ', '') != 'LASTNAME' || 
            headers[3].toUpperCase().trim() != 'EMAIL' || 
            headers[4].replaceAll('\r', '').toUpperCase().trim() != 'PHONE') {
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Wrong Format.",
                "message": "Please ensure that the csv file has the columns: Account Number, First Name, Last Name, Email, Phone. \n Please ensure that the csv file cells have no line breaks before or after the text!",
                "type": "Error",
                "mode": "dismissible",
                 duration: 17000
            })
            toastEvent.fire();
            component.set("v.spinner", false);
            
        } else {
             
            var rowItemList = component.get("v.ContactList");
    		this.removeBlankRows(component);
            let countSkipedLines = 0;
            for (var i = 1; i < arr.length; i++) {
                var data = arr[i].split(',');
    
                if (data.length == 1) {
                    arr[i] = arr[i].replaceAll(';', ',');
                    data = arr[i].split(',');
                }
                
                if(data.length == headers.length){
                    if(data[0].trim() != '' || data[1].trim() != '' ||
                       data[2].trim() != '' || data[3].trim() != '' ||
                       data[4].replaceAll('\r', '') != '' ){
                        tempContactList.push({
                            'sobjectType': 'Contact',
                            'AccountId': data[0].trim(),
                            'FirstName': data[1].trim(),
                            'LastName': data[2].trim(),
                            'Email': data[3].trim(),
                            'Phone': data[4].replaceAll('\r', ''),
                            'Same_As_The_Account_Billing_Address__c': true,
                        });                     
                    }
            	} else {
                    countSkipedLines++;
                }
				accountNumerList.push(data[0].trim());
            }
            
            let myPageRef = component.get("v.pageReference");
            let category = myPageRef.state.c__category;
            let accId = component.get("v.accountId");

            if(category === 'Public' || (category !== 'Public' && (accId === undefined || accId === null ))) { 
                if(accountNumerList.length > 0){
                    component.set("v.spinerMessage", "Matching Accounts to uploaded Contacts. Please wait a few seconds ...");
                    var action = component.get("c.getAccounts");        
                    action.setParams({
                        "accountsNumber": accountNumerList
                    });
                    action.setCallback(this, function(response) {
                        
                    	var state = response.getState();

                        if (state === "SUCCESS") {                      
                                tempContactList.forEach(function (element) {
                                    const obj = response.getReturnValue().find(object => {
                                        return (object.Account_Number__c === element.AccountId );
                                    });
                                    element.AccountId = obj ? obj.Id : '';
                                    rowItemList.push(element);
                                });
                                component.set("v.ContactList", rowItemList);                      
                        } else { 
  
                                tempContactList.forEach(function (element) {       
                                    rowItemList.push(element);
                                });                            
                                component.set("v.ContactList", rowItemList);
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Something went wrong getting the Accounts",
                                    "message": "Please select Accounts mannually or refresh window and try again!",
                                    "type": "Warning",
                                    "mode": "dismissible",
                                     duration: 12000
                                })
                                toastEvent.fire();
                        }
                        
                    }); 
                    $A.enqueueAction(action);
                    component.set("v.spinner", false);
                } else {
                	tempContactList.forEach(function (element) {       
                        rowItemList.push(element);
                    });
                    component.set("v.ContactList", rowItemList);
                    component.set("v.spinner", false);
                }
            } else {
                
                if(accId !== undefined){
                     tempContactList.forEach(function (element) {       
                        element.AccountId = accId;
                        rowItemList.push(element);
                    });
                component.set("v.ContactList", rowItemList);
                component.set("v.spinner", false);                    
                }


            }
            
            if(countSkipedLines > 0){
				var toastEvent3 = $A.get("e.force:showToast");
                toastEvent3.setParams({
                    "title": "Some lines in the file were not loaded.",
                    "message": "Some lines in the CSV have issues. Please ensure that the file cells don't have line breaks after the text!",
                    "type": "Information",
                    "mode": "dismissible",
                     duration: 18000
                })
                toastEvent3.fire();           
            }

		}
    },


})