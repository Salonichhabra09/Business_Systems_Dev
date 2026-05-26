({
    doInit: function (component, event, helper) {

        var TodayDate = new Date();
        var day = TodayDate.getDay();
        var lessDays = day == 0 ? 6 : day - 1;
        var FDofWK = new Date(new Date(TodayDate).setDate(TodayDate.getDate() - lessDays));
        var LDofWK = new Date(new Date(FDofWK).setDate(FDofWK.getDate() + 6));
        var StDtToApx = FDofWK.getDate() + '/' + (FDofWK.getMonth() + 1) + '/' + (FDofWK.getFullYear()).toString().substr(-2);
        var EnDtToApx = LDofWK.getDate() + '/' + (LDofWK.getMonth() + 1) + '/' + (LDofWK.getFullYear()).toString().substr(-2);
        component.set("v.CurrentPeriodDate", FDofWK);
        component.set("v.StrtOfweekDt", FDofWK);
        component.set("v.EndOfweekDt", LDofWK);
        helper.GetCurrentTimelists(component, event, helper, StDtToApx, EnDtToApx);
        helper.GenerateDateList(component, TodayDate, 'Week');
        helper.DateConversions(component, 'Week', component.get("v.curPrdStdate"), component.get("v.curPrdEDdate"));

        //Below logic is for getting logged in User name
        var action = component.get("c.getUserName");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.currentUserName", result);
            }
        });
        $A.enqueueAction(action);
    },

    handleContactSelection: function (component, event, helper) {
        //component.set("v.dataReceived", event.getParam('detail'));
        //console.log(' abc ' + event.getParam());
        console.log(' abc ' + event.getParam('projectId'));
        console.log(' abc ' + event.getParam('indexId'));
        var projectid = event.getParam('projectId');
        var index = event.getParam('indexId');
        helper.CallProjectData(component, projectid, index);
        //console.log(' def ' + event.detail);
        //console.log(' def ' + event.detail.data);
        //console.log(' def ' + event.target);
        //console.log('handleContactSelection dataReceived: ', component.get("v.dataReceived"));

    },

    handleContactRemoval: function (component, event, helper) {
        var projectid = event.getParam('projectId');
        console.log('projectid: ', projectid);
        var index = event.getParam('indexId');
        console.log('index: ', index);
        //helper.CallProjectData(component, projectid, index);
        var docobj = component.get("v.TimeSheetRow");
        console.log('docobj: ', JSON.stringify(docobj));
        docobj[index].Timesheet.Project__c = '';
        //docobj[index].Timesheet.Project_Name__c = '';
        //docobj[index].Timesheet.Project_Nickname__c = '';
        docobj[index].Timesheet.Project_Number__c = '';
        console.log('docobj: ', JSON.stringify(docobj));
        component.set("v.TimeSheetRow", docobj);
        console.log('TimeSheetRow: ', JSON.stringify(component.get("v.TimeSheetRow")));
    },

    /*GetChartView: function (component, event, helper) {
        var viewclk = event.getSource().get("v.value");
        //alert(viewclk);
        var action = component.get("c.setChartVal");
        action.setParams({
            "SelView": viewclk
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //component.set("v.currentUserName", result);
            }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },
    
    loadWholeWindow: function(component,event){
        location.reload();
    },*/
    SetCurrentWeek: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    handleChange: function (component, event, helper) {
        var confirmation = true;
        if (component.get("v.EditMode") == false) {
            var selectedEventId = event.target.id;
            var msg = 'Changes you made may not be saved. Want to continue?';
            if (!confirm(msg)) {
                //console.log('No');
                confirmation = false;
                return false;
            } else {
                //console.log('Yes');
                confirmation = true;
            }
        }
        if (confirmation == true) {

            var btnclk = event.getSource().get("v.value");
            var selectedOptionValue = btnclk;
            component.set("v.selectedView", selectedOptionValue);
            var Gridsize = component.get("v.DatewrapList");

            //var d = new Date();
            var d = component.get("v.curPrdStdate");
            component.set("v.DateToday", d);
            component.set("v.TimePeriod", d);

            if (selectedOptionValue == 'Day') {
                helper.GenerateDateList(component, d, 'Day');
                helper.DateConversions(component, btnclk, d);

                var StDtToApx = d.getDate() + '/' + (d.getMonth() + 1) + '/' + (d.getFullYear()).toString().substr(-2);
                var EnDtToApx = d.getDate() + '/' + (d.getMonth() + 1) + '/' + (d.getFullYear()).toString().substr(-2);
                //('start date test '+component.get("v.curPrdStdate"));
                //console.log('end date test'+component.get("v.curPrdEDdate"));
                helper.GetCurrentTimelists(component, event, helper, StDtToApx, EnDtToApx);
            }
            if (selectedOptionValue == 'Week') {
                //var stwk = component.get("v.StrtOfweekDt");
                //var Enwk = component.get("v.EndOfweekDt");
                var stwk = component.get("v.curPrdStdate");
                var Enwk = component.get("v.curPrdEDdate");
                helper.GenerateDateList(component, stwk, 'Week');//this method always updates curr prd Strt & End date
                var stwk = component.get("v.curPrdStdate");
                var Enwk = component.get("v.curPrdEDdate");
                var StDtToApx = stwk.getDate() + '/' + (stwk.getMonth() + 1) + '/' + (stwk.getFullYear()).toString().substr(-2);
                var EnDtToApx = Enwk.getDate() + '/' + (Enwk.getMonth() + 1) + '/' + (Enwk.getFullYear()).toString().substr(-2);


                helper.DateConversions(component, btnclk, stwk, Enwk);
                //console.log('start date test '+component.get("v.curPrdStdate"));
                //console.log('end date test'+component.get("v.curPrdEDdate"));
                helper.GetCurrentTimelists(component, event, helper, StDtToApx, EnDtToApx);
            }
            if (selectedOptionValue == 'Month') {
                var stwk = component.get("v.curPrdStdate");// New Date logic
                helper.GenerateDateList(component, stwk, 'Month');
                var stwk = component.get("v.curPrdStdate");// New Date logic
                helper.DateConversions(component, btnclk, stwk);
                //console.log('start date test '+component.get("v.curPrdStdate"));
                //console.log('end date test'+component.get("v.curPrdEDdate"));
                var FDofWK = component.get("v.curPrdStdate");
                var LDofWK = component.get("v.curPrdEDdate");
                var StDtToApx = FDofWK.getDate() + '/' + (FDofWK.getMonth() + 1) + '/' + (FDofWK.getFullYear()).toString().substr(-2);
                var EnDtToApx = LDofWK.getDate() + '/' + (LDofWK.getMonth() + 1) + '/' + (LDofWK.getFullYear()).toString().substr(-2);
                helper.GetCurrentTimelists(component, event, helper, StDtToApx, EnDtToApx);

            }
            var blanklist = [];
            component.set("v.TimeSheetRow", blanklist);
        }
    },

    PeriodHandler: function (component, event, helper) {
        var confirmation = true;
        if (component.get("v.EditMode") == false) {
            var selectedEventId = event.target.id;
            var msg = 'Changes you made may not be saved. Want to continue?';
            if (!confirm(msg)) {
                //console.log('No');
                confirmation = false;
                return false;
            } else {
                //console.log('Yes');
                var blanklist = [];
                component.set("v.Timesheetrecords", []);
                component.set("v.TimesheetsToDelete", []);
                component.set("v.TimeSheetRow", []);
                confirmation = true;
            }
        }
        if (confirmation == true) {
            var Arowval = event.getSource().get("v.value");
            var Gridsize = component.get("v.DatewrapList");
            var view = component.get("v.selectedView");
            var stdtwk = component.get("v.curPrdStdate");
            var Endtwk = component.get("v.curPrdEDdate");
            var TdDt = component.get("v.TimePeriod");
            helper.SetNextTimePeriod(component, view, Arowval, stdtwk, Endtwk, TdDt);
        }
    },
    /*
    onbtnclick: function(component, event, helper) {
        var tbl = component.find("table1");
        var lastRow = tbl.rows.length;
        alert(lastRow);
    },
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            // disable and reset sub dependent field 
            
            
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields,"v.listDependingValues");    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
        
        component.set("v.bDisabledSubDependentFld" , true);
        component.set("v.listSubDependingValues", ['--- None ---']);
    },
    
    
    onSubControllerFieldChange : function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected sub controller field value
        var depnedentFieldMap = component.get("v.subDepnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledSubDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields,"v.listSubDependingValues");    
            }else{
                component.set("v.bDisabledSubDependentFld" , true); 
                component.set("v.listSubDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listSubDependingValues", ['--- None ---']);
            component.set("v.bDisabledSubDependentFld" , true);
        }
    },*/

    addRow: function (component, event, helper) {
        helper.addrowhelper(component, event);
    },

    removeRow: function (component, event, helper) {
        //Get the account list
        var docobj = component.get("v.TimeSheetRow");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        var rowItemList = component.get("v.TimesheetsToDelete");
        for (var i = 0; i < docobj[index].Timesheet.DateTime.length; i++) {
            if (JSON.stringify(docobj[index].Timesheet.DateTime[i].Id) != "null") {
                rowItemList.push({ 'sobjectType': 'Timesheet_Line__c', 'Id': JSON.stringify(docobj[index].Timesheet.DateTime[i].Id).slice(1, -1) });
            }
        }
        component.set("v.TimesheetsToDelete", rowItemList);
        docobj.splice(index, 1);
        component.set("v.TimeSheetRow", docobj);
        helper.CalculateTotalHoursInDay(component);
        //console.log('Timesheetrow size '+component.get("v.TimeSheetRow").length);
        //console.log('Timesheetrow size '+component.get("v.TimeSheetRow").length);
        //console.log('Timesheets to delete '+JSON.stringify(component.get("v.TimesheetsToDelete")));
    },

    EnableEdit: function (component, event, helper) {
        component.set("v.EditMode", false);

    },

    GetProjectFunction: function (component, event, helper) {
        var projectid = '' + event.getSource().get("v.value");
        var index = event.getSource().get("v.id");
        helper.CallProjectData(component, projectid, index);
    },

    CountSum: function (component, event, helper) {

        var row = component.get('v.TimeSheetRow');
        var totalhrs = 0;
        var unit;
        for (var i = 0; i < row.length; i++) {
            totalhrs = 0;
            //alert(row[i].Timesheet.DateTime);
            for (var j = 0; j < row[i].Timesheet.DateTime.length; j++) {
                //alert(row[i].Timesheet.DateTime[j].value);
                if (isNaN(parseFloat(row[i].Timesheet.DateTime[j].value))) {
                    unit = 0;
                }
                else {
                    unit = parseFloat(row[i].Timesheet.DateTime[j].value);
                }
                totalhrs = unit + totalhrs;

            }
            row[i].TotalHours = totalhrs;
            //console.log('This is total hours '+totalhrs);
        }
        component.set("v.TimeSheetRow", row);
        helper.CalculateTotalHoursInDay(component);

    },

    saveTimeSheets: function (component, event, helper) {
        component.set("v.spinner", true);
        event.preventDefault();
        var abc = component.find('customlookupcomponent');//.handleRequiredFieldValidation('strategy');
        console.log('abc: ', JSON.stringify(abc));


        helper.MergeDuplicateTimesheets(component);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var TotalHoursInDayStatus = helper.ValidateTotalHoursInDay(component);
        console.log('This is TotalHoursInDayStatus ' + TotalHoursInDayStatus);
        if (TotalHoursInDayStatus == "All OK") {
            var row = component.get("v.TimeSheetRow");
            var rowItemList = component.get("v.Timesheetrecords");
            var rowItemListtodelete = component.get("v.TimesheetsToDelete");
            console.log('This is timesheet row ' + JSON.stringify(component.get("v.TimeSheetRow")));
            for (var i = 0; i < row.length; i++) {
                console.log('DateTime status ' + JSON.stringify(row[i].Timesheet));

                if (row[i].Timesheet.Project__c == null && abc[i]) {
                    abc[i].handleRequiredFieldValidation('strategy');
                    component.set("v.spinner", false);
                }

                for (var j = 0; j < row[i].Timesheet.DateTime.length; j++) {
                    if (row[i].Timesheet.DateTime[j].value != 0 && row[i].Timesheet.DateTime[j].value != '') {
                        //console.log('Date in UI mode ' + row[i].Timesheet.DateTime[j].label);
                        //console.log('Date in apex mode ' + helper.ConvertDtUItoAPX(row[i].Timesheet.DateTime[j].label));

                        if (row[i].Timesheet.DateTime[j].Status == 'Old') {
                            rowItemList.push({
                                'sobjectType': 'Timesheet_Line__c', 'Id': row[i].Timesheet.DateTime[j].Id, 'Project__c': row[i].Timesheet.Project__c, 'Time_Category__c': row[i].Timesheet.Time_Category__c,
                                /*'Task_Category__c': row[i].Timesheet.Task_Category__c,*/ 'Task__c': row[i].Timesheet.Task__c, 'Hours__c': parseFloat(row[i].Timesheet.DateTime[j].value), 'Date_Invoiced__c': helper.ConvertDtUItoAPX(component, row[i].Timesheet.DateTime[j].label), 'Resource__c': userId
                            });
                        }
                        else {
                            rowItemList.push({
                                'sobjectType': 'Timesheet_Line__c', 'Id': null, 'Project__c': row[i].Timesheet.Project__c, 'Time_Category__c': row[i].Timesheet.Time_Category__c,
                                /*'Task_Category__c': row[i].Timesheet.Task_Category__c,*/ 'Task__c': row[i].Timesheet.Task__c, 'Hours__c': parseFloat(row[i].Timesheet.DateTime[j].value), 'Date_Invoiced__c': helper.ConvertDtUItoAPX(component, row[i].Timesheet.DateTime[j].label), 'Resource__c': userId
                            });
                        }

                    }
                    else {
                        if (row[i].Timesheet.DateTime[j].Id != null) {
                            rowItemListtodelete.push({ 'sobjectType': 'Timesheet_Line__c', 'Id': row[i].Timesheet.DateTime[j].Id });
                        }
                    }

                }
            }
            component.set("v.Timesheetrecords", rowItemList);
            component.set("v.TimesheetsToDelete", rowItemListtodelete);
            console.log('Timesheet to apex in save' + JSON.stringify(component.get("v.Timesheetrecords")));
            console.log('Timesheet to delete in save' + JSON.stringify(component.get("v.TimesheetsToDelete")));
            var action = component.get("c.saveTimesheets");
            action.setParams({
                "TimesheetListapex": component.get("v.Timesheetrecords"),
                "TimesheetsToDeleteList": component.get("v.TimesheetsToDelete")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('This is status inside callback ' + response.getState());

                if (state === "SUCCESS") {
                    if (response.getReturnValue() == 'Timesheets records saved successfully') {
                        if (event.getSource().getLocalId() == "save") {
                            component.set("v.EditMode", true);
                        }
                        component.set("v.spinner", false);
                        var blanklist = [];
                        component.set("v.Timesheetrecords", []);
                        component.set("v.TimesheetsToDelete", []);
                        component.set("v.TimeSheetRow", blanklist);
                        var FDofWK = component.get("v.curPrdStdate");
                        var LDofWK = component.get("v.curPrdEDdate");
                        console.log('Timesheet to apex in save' + JSON.stringify(component.get("v.Timesheetrecords")));
                        //console.log('this is start date '+FDofWK);
                        //console.log('this is End date '+LDofWK);
                        var StDtToApx = FDofWK.getDate() + '/' + (FDofWK.getMonth() + 1) + '/' + (FDofWK.getFullYear()).toString().substr(-2);
                        var EnDtToApx = LDofWK.getDate() + '/' + (LDofWK.getMonth() + 1) + '/' + (LDofWK.getFullYear()).toString().substr(-2);
                        helper.GetCurrentTimelists(component, event, helper, StDtToApx, EnDtToApx);

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": response.getReturnValue(),
                            "type": "Success"
                        })
                        toastEvent.fire();

                    }
                    else {
                        var blanklist = [];
                        component.set("v.Timesheetrecords", []);
                        component.set("v.TimesheetsToDelete", []);
                        component.set("v.spinner", false);
                        var responseString = response.getReturnValue();
                        //SSE-17628 Changes start (Added by Jai Khandelwal)
                        var errorString = '';
                        if (responseString == 'Duplicate timesheet entries found, Please refresh the page for up to date data!' || responseString == 'The timesheet/timesheets that you are trying to delete doesn\'t exist , Please refresh the page for up to date data!') {
                            errorString = responseString;
                        }
                        else {
                            errorString = responseString.substring(87, responseString.length);
                        }
                        //SSE-17628 Changes end (Added by Jai Khandelwal)
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": errorString,
                            "type": "Error"
                        })
                        toastEvent.fire();

                    }
                    //$A.get('e.force:refreshView').fire(); 
                }

            });
            $A.enqueueAction(action);

        }
        else {

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": TotalHoursInDayStatus,
                "type": "Error"
            })
            toastEvent.fire();

        }

    },
    /*ConfirmationCheck: function(component, event, helper){
        var confirmation = true;
        console.log("Inside Confirmation");
        if(component.get("v.EditMode") == false){
            console.log("Inside Confirmation edit mode");
            consile.log("token "+window.location.pathname);
            var selectedEventId = event.target.id;
            var msg ='Changes you made may not be saved. Want to continue?';
            if (!confirm(msg)) {
                console.log('Confirmation check :No');
                confirmation = false;
                return false;
            } else {
                console.log('Confirmation check :Yes');
                confirmation = true;  
            }
        }
    },*/

    cancelchanges: function (component, event, helper) {
        component.set("v.EditMode", true);
        var blanklist = [];
        component.set("v.Timesheetrecords", []);
        component.set("v.TimesheetsToDelete", []);
        component.set("v.TimeSheetRow", blanklist);
        var FDofWK = component.get("v.curPrdStdate");
        var LDofWK = component.get("v.curPrdEDdate");
        var StDtToApx = FDofWK.getDate() + '/' + (FDofWK.getMonth() + 1) + '/' + (FDofWK.getFullYear()).toString().substr(-2);
        var EnDtToApx = LDofWK.getDate() + '/' + (LDofWK.getMonth() + 1) + '/' + (LDofWK.getFullYear()).toString().substr(-2);
        helper.GetCurrentTimelists(component, event, helper, StDtToApx, EnDtToApx);
    },
    showSpinner: function (component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true);
    },

    // function automatic called by aura:doneWaiting event 
    hideSpinner: function (component, event, helper) {
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },

    handleMenuSelect: function (component, event, helper) {
        var startdate = component.get("v.curPrdStdate");
        var enddate = component.get("v.curPrdEDdate");
        //alert(startdate);
        //alert(enddate);
        //if(component.get("v.selectedView") === "Week"){
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue === "Clone last Week") {
            var strtwk = new Date(startdate);
            var Endwk = new Date(enddate);
            if (component.get("v.selectedView") === "Week") {
                strtwk.setDate(strtwk.getDate() - 7)
                Endwk.setDate(Endwk.getDate() - 7);
            }
            else if (component.get("v.selectedView") === "Month") {
                //alert(strtwk);
                //alert(Endwk);
                Endwk.setDate(strtwk.getDate() - 1);
                strtwk.setDate(strtwk.getDate() - 7);
                //alert(strtwk);
                //alert(Endwk);
            }
            else if (component.get("v.selectedView") === "Day") {
                //alert(strtwk);
                //alert(Endwk);
                strtwk.setDate(strtwk.getDate() - 7)
                Endwk.setDate(Endwk.getDate() - 1);
                //alert(strtwk);
                //alert(Endwk);
            }
            var strtmnth = parseInt(strtwk.getMonth()) + 1;
            var endmnth = parseInt(Endwk.getMonth()) + 1;
            var Pr1 = strtwk.getDate() + '/' + strtmnth + '/' + strtwk.getFullYear();
            var Pr2 = Endwk.getDate() + '/' + endmnth + '/' + Endwk.getFullYear();
            //alert(Pr1);
            //alert(Pr2);
        }
        else if (selectedMenuItemValue === "Clone last Month") {
            var strtmnth = new Date(startdate);
            var endmnth = new Date(enddate);
            var Pr1;
            var Pr2;
            if (component.get("v.selectedView") === "Week") {
                //alert(strtmnth);
                //alert(endmnth);
                //var FDayofWK = new Date(new Date(TodDt).setDate(TodDt.getDate() - lessDays));
                var firstday = new Date(strtmnth.getFullYear(), (strtmnth.getMonth() - 1), 1);
                var lastday = new Date(firstday.getFullYear(), (firstday.getMonth() + 1), 0);
                Pr1 = firstday.getDate() + '/' + (firstday.getMonth() + 1) + '/' + firstday.getFullYear();
                Pr2 = lastday.getDate() + '/' + (lastday.getMonth() + 1) + '/' + lastday.getFullYear();
                //alert('Pr1'+Pr1);
                //alert('Pr2'+Pr2);
            }
            else if (component.get("v.selectedView") === "Month") {

                var firstday = new Date(strtmnth.getFullYear(), (strtmnth.getMonth() - 1), 1);
                var lastday = new Date(firstday.getFullYear(), (firstday.getMonth() + 1), 0);
                Pr1 = firstday.getDate() + '/' + (firstday.getMonth() + 1) + '/' + firstday.getFullYear();
                Pr2 = lastday.getDate() + '/' + (lastday.getMonth() + 1) + '/' + lastday.getFullYear();

                //Pr1 = strtmnth.getDate()+'/'+strtmnth.getMonth()+'/'+strtmnth.getFullYear();
                //Pr2 = endmnth.getDate()+'/'+endmnth.getMonth()+'/'+endmnth.getFullYear();
            }
            else if (component.get("v.selectedView") === "Day") {

                var firstday = new Date(strtmnth.getFullYear(), (strtmnth.getMonth() - 1), 1);
                var lastday = new Date(firstday.getFullYear(), (firstday.getMonth() + 1), 0);
                Pr1 = firstday.getDate() + '/' + (firstday.getMonth() + 1) + '/' + firstday.getFullYear();
                Pr2 = lastday.getDate() + '/' + (lastday.getMonth() + 1) + '/' + lastday.getFullYear();


                //var firstday = new Date(strtmnth.getFullYear(), strtmnth.getMonth(), 1);
                //var lastday = new Date(strtmnth.getFullYear(), strtmnth.getMonth() + 1, 0);

                //Pr1 = firstday.getDate()+'/'+firstday.getMonth()+'/'+firstday.getFullYear();
                //Pr2 = lastday.getDate()+'/'+lastday.getMonth()+'/'+lastday.getFullYear();  
            }


            //alert(Pr1);
            //alert(Pr2);
        }
        else if (selectedMenuItemValue === "Clone last 4 Weeks") {
            var strtwk = new Date(startdate);
            var Endwk = new Date(enddate);
            if (component.get("v.selectedView") === "Week") {
                strtwk.setDate(strtwk.getDate() - 28);
                Endwk.setDate(Endwk.getDate() - 7);
            }
            else if (component.get("v.selectedView") === "Day") {
                strtwk.setDate(strtwk.getDate() - 28);
                Endwk.setDate(Endwk.getDate() - 1);
                //alert(strtwk);
                //alert(Endwk);
            }

            var strtmnth = parseInt(strtwk.getMonth()) + 1;
            var endmnth = parseInt(Endwk.getMonth()) + 1;
            var Pr1 = strtwk.getDate() + '/' + strtmnth + '/' + strtwk.getFullYear();
            var Pr2 = Endwk.getDate() + '/' + endmnth + '/' + Endwk.getFullYear();
        }
        var action = component.get('c.ReturnTimeSheets');
        action.setParams({ "startdate1": Pr1, "enddate1": Pr2 });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var rowitem = component.get("v.TimeSheetRow");
                //console.log("this is result"+JSON.stringify(result));
                if (rowitem.length == 1 && result.length > 0 && rowitem[0].Timesheet.Project__c === '') {
                    rowitem.pop();
                }
                if (result.length < 1) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "No Timesheet Rows found in the time period selected to Clone",
                        "type": "Error",
                        "mode": "sticky"
                    })
                    toastEvent.fire();
                }


                for (var i = 0; i < result.length; i++) {
                    var datetimelsttemp = [];
                    for (var j = 0; j < component.get("v.DateTimeList").length; j++) {
                        datetimelsttemp.push({ 'label': component.get("v.DateTimeList")[j].label, 'value': '', 'Status': 'New', 'Id': null });
                    }
                    //Added Project_Nickname__c SSE-20058
                    rowitem.push({
                        'Timesheet': {
                            'sobjectType': 'Timesheet_Line__c', 'Project__c': result[i].Project__c, 'Project_Name__c': result[i].Project_Name__c,
                            'Project_Number__c': result[i].Project_Number__c, 'Project_Nickname__c': result[i].Project_Nickname__c,
                            'Time_Category__c': result[i].Time_Category__c,
                            /*'Task_Category__c': result[i].Task_Category__c,*/ 'Task__c': result[i].Task__c, 'DateTime': datetimelsttemp
                        }, 'TotalHours': 0,
                    });
                }
                //var datetimelist = [{'label': 'Weekly', 'value': '7'}];


                component.set("v.TimeSheetRow", rowitem);
            }
        });
        $A.enqueueAction(action);
    }

})