({
    createObjectData: function (component, event) {
        // get the TimeSheetList from component and add(push) New Object to List  
        var RowItemList = component.get("v.TimeSheetList");
        RowItemList.push({
            'sobjectType': 'Timesheet_Line__c',
            'Project__c': '',
            'Time_Category__c': '',
            /*'Task_Category__c': ''*/
        });
        // set the updated list to attribute (TimeSheetList) again    
        component.set("v.TimeSheetList", RowItemList);
    },

    addrowhelper: function (component) {

        var testlist = [];
        for (var i = 0; i < component.get("v.DayItems").length; i++) {
            testlist.push({ 'label': component.get("v.DayItems")[i], 'value': '', 'Status': 'New', 'Id': null });
        }
        component.set("v.DateTimeList", testlist);
        var rowitem = component.get("v.TimeSheetRow");
        //Added Project_Nickname__c SSE-20058
        rowitem.push({
            'Timesheet': {
                'sobjectType': 'Timesheet_Line__c', 'Project_Name__c': '', 'Project_Number__c': '', 'Project_Nickname__c': '', 'Time_Category__c': '',
                /*'Task_Category__c': '',*/ 'Task__c': '', 'DateTime': component.get("v.DateTimeList")
            }, 'TotalHours': 0,
        });
        component.set("v.TimeSheetRow", rowitem);
        //console.log('Timeseet length after adding row '+component.get("v.TimeSheetRow").length);
        //console.log('This is test 3 '+JSON.stringify(component.get("v.TimeSheetRow")));

    },

    DateConversions: function (component, view, stwk, Enwk) {
        //alert(stwk);
        var Month = new Array(12);
        Month[0] = "January";
        Month[1] = "February";
        Month[2] = "March";
        Month[3] = "April";
        Month[4] = "May";
        Month[5] = "June";
        Month[6] = "July";
        Month[7] = "August";
        Month[8] = "September";
        Month[9] = "October";
        Month[10] = "November";
        Month[11] = "December";

        var strtwk = new Date(stwk);
        var Endwk = new Date(Enwk);
        var Pr1 = strtwk.getDate() + '-' + Month[strtwk.getMonth()] + '-' + strtwk.getFullYear();
        var Pr2 = Endwk.getDate() + '-' + Month[Endwk.getMonth()] + '-' + Endwk.getFullYear();
        var MonV = Month[strtwk.getMonth()] + '-' + strtwk.getFullYear();
        if (view == 'Week') {
            component.set("v.TimePeriod", Pr1 + ' to ' + Pr2);
        }
        if (view == 'Day') {
            component.set("v.TimePeriod", Pr1);
        }
        if (view == 'Month') {
            component.set("v.TimePeriod", MonV);
        }
    },

    SetNextTimePeriod: function (component, view, dir, Std, End, Tdt) {
        //alert(Tdt);
        var Month = new Array(12);
        Month[0] = "January";
        Month[1] = "February";
        Month[2] = "March";
        Month[3] = "April";
        Month[4] = "May";
        Month[5] = "June";
        Month[6] = "July";
        Month[7] = "August";
        Month[8] = "September";
        Month[9] = "October";
        Month[10] = "November";
        Month[11] = "December";
        if (view == 'Week') {
            var strtwk = new Date(Std);
            strtwk.setDate(strtwk.getDate() + 7 * dir);
            var Endwk = new Date(End);
            Endwk.setDate(Endwk.getDate() + 7 * dir);


            var Pr1 = strtwk.getDate() + '-' + Month[strtwk.getMonth()] + '-' + strtwk.getFullYear();
            var StDtToApx = strtwk.getDate() + '/' + (strtwk.getMonth() + 1) + '/' + (strtwk.getFullYear()).toString().substr(-2);
            component.set("v.curPrdStdate", Pr1);
            component.set("v.CurrentPeriodDate", strtwk);
            var self = this;
            self.GenerateDateList(component, Pr1, view);
            var Pr2 = Endwk.getDate() + '-' + Month[Endwk.getMonth()] + '-' + Endwk.getFullYear();
            var EnDtToApx = Endwk.getDate() + '/' + (Endwk.getMonth() + 1) + '/' + (Endwk.getFullYear()).toString().substr(-2);
            //component.set("v.curPrdEDdate",Pr2);
            var blanklist = [];
            component.set("v.TimeSheetRow", blanklist);
            this.GetCurrentTimelists(component, event, this, StDtToApx, EnDtToApx);

            component.set("v.TimePeriod", Pr1 + ' to ' + Pr2);
        }
        if (view == 'Day') {
            var dview = new Date(Tdt);
            //alert(dview);
            dview.setDate(dview.getDate() + 1 * dir);
            var self = this;
            self.GenerateDateList(component, dview, view);
            var DV = dview.getDate() + '-' + Month[dview.getMonth()] + '-' + dview.getFullYear();
            component.set("v.TimePeriod", DV);
            component.set("v.CurrentPeriodDate", dview);
            var StDtToApx = dview.getDate() + '/' + (dview.getMonth() + 1) + '/' + (dview.getFullYear()).toString().substr(-2);
            var EnDtToApx = dview.getDate() + '/' + (dview.getMonth() + 1) + '/' + (dview.getFullYear()).toString().substr(-2);
            var blanklist = [];
            component.set("v.TimeSheetRow", blanklist);
            this.GetCurrentTimelists(component, event, this, StDtToApx, EnDtToApx);
        }
        if (view == 'Month') {
            var Mview = new Date(Tdt);
            //alert(Mview);
            Mview.setMonth(Mview.getMonth() + 1 * dir);
            var self1 = this;
            self1.GenerateDateList(component, Mview, view);
            var MV = Month[Mview.getMonth()] + '-' + Mview.getFullYear();
            component.set("v.TimePeriod", MV);
            component.set("v.CurrentPeriodDate", Mview);
            //console.log('start date test '+component.get("v.curPrdStdate"));
            //console.log('end date test'+component.get("v.curPrdEDdate"));
            var blanklist = [];
            component.set("v.TimeSheetRow", blanklist);
            var FDofWK = component.get("v.curPrdStdate");
            var LDofWK = component.get("v.curPrdEDdate");
            var StDtToApx = FDofWK.getDate() + '/' + (FDofWK.getMonth() + 1) + '/' + (FDofWK.getFullYear()).toString().substr(-2);
            var EnDtToApx = LDofWK.getDate() + '/' + (LDofWK.getMonth() + 1) + '/' + (LDofWK.getFullYear()).toString().substr(-2);
            this.GetCurrentTimelists(component, event, this, StDtToApx, EnDtToApx);

        }
    },

    GenerateDateList: function (component, CurDt, view) {
        var TodDt = new Date(CurDt);
        var weekday = new Array(7);

        weekday[0] = "Sun";
        weekday[1] = "Mon";
        weekday[2] = "Tue";
        weekday[3] = "Wed";
        weekday[4] = "Thu";
        weekday[5] = "Fri";
        weekday[6] = "Sat";

        var day = TodDt.getDay();
        var lessDays = day == 0 ? 6 : day - 1;
        var FDayofWK = new Date(new Date(TodDt).setDate(TodDt.getDate() - lessDays));
        var LDayofWK = new Date(new Date(FDayofWK).setDate(FDayofWK.getDate() + 6));
        //var LDayofWK = new Date(TodDt.setDate(TodDt.getDate() - TodDt.getDay() + 7));
        //var LDayofWK = new Date(FDayofWK.setDate(FDayofWK.getDate() + 6));
        //alert('Ldayofwk'+LDayofWK);
        var FDayMnth = new Date(TodDt.getFullYear(), TodDt.getMonth(), 1);
        //alert('FdayofMN'+FDayMnth);
        var LDayMnth = new Date(TodDt.getFullYear(), TodDt.getMonth() + 1, 0);
        //alert('LdayofMn'+LDayMnth);
        //alert(LDayofWK);
        var CurrDay;
        var j;
        var curPrdStDt;
        var curPrdEnDt;//New Date logic
        if (view == 'Week') {
            CurrDay = FDayofWK;
            j = 7;
            curPrdStDt = FDayofWK;
            curPrdEnDt = LDayofWK;//New Date logic
        } else if (view == 'Month') {
            CurrDay = FDayMnth;
            j = (LDayMnth.getDate());
            curPrdStDt = FDayMnth;
            curPrdEnDt = LDayMnth;//New Date logic
        } else {
            CurrDay = CurDt;
            curPrdStDt = CurDt//New Date logic
            curPrdEnDt = CurDt//New Date logic
            j = 1;
        }
        var FrmtdDt = weekday[CurrDay.getDay()] + ' ' + CurrDay.getDate() + '/' + (CurrDay.getMonth() + 1);
        var WkLstJS = [];
        //var perdaylist = [];
        for (var i = 0; i < j; i++) {
            //var FrmtdDt = weekday[(CurrDay.getDay()+i)%7] +' '+(CurrDay.getDate()+i)+'/'+(CurrDay.getMonth()+1);
            var FrmtdDt = new Date(CurrDay);
            FrmtdDt.setDate(FrmtdDt.getDate() + i);
            //alert(FrmtdDt);
            //var lstdys = weekday[(FrmtdDt.getDay()+i)%7]+' '+FrmtdDt.setDate((FrmtdDt.getDate()+i))+'/'+(FrmtdDt.getMonth()+1);;
            WkLstJS.push(weekday[(FrmtdDt.getDay()) % 7] + ' ' + FrmtdDt.getDate() + '/' + (FrmtdDt.getMonth() + 1));
            //perdaylist.push({'Day':weekday[(FrmtdDt.getDay())%7]+' '+FrmtdDt.getDate()+'/'+(FrmtdDt.getMonth()+1),'Totalhours':0});
        }
        //alert("List has Dates"+WkLstJS);
        component.set("v.DayItems", WkLstJS);
        //component.set("v.PerDayLoggedHours",perdaylist);
        component.set("v.curPrdStdate", curPrdStDt);
        component.set("v.curPrdEDdate", curPrdEnDt);
        var testlist = [];
        //var testlist2 = [{'label': 'Daily', 'value': '1'}];
        //alert(component.get("v.DayItems"));
        for (var i = 0; i < component.get("v.DayItems").length; i++) {
            testlist.push({ 'label': component.get("v.DayItems")[i], 'value': 0 });
        }
        component.set("v.DateTimeList", testlist);

    },

    GetCurrentTimelists: function (component, event, helper, D1, D2) {
        console.log('Timesheet to apex in save' + JSON.stringify(component.get("v.Timesheetrecords")));
        component.set("v.spinner", true);
        //console.log('Inside GetCurrentTimelists method');
        //alert('Date range toApx is---'+D1+ '--To--'+D2);
        var action = component.get("c.ReturnCurrentTimeSheets");
        action.setParams({
            "startdate1": D1,
            "enddate1": D2
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('This is state '+response.getState());
            if (state === "SUCCESS") {
                component.set("v.CurrentTimesheets", response.getReturnValue());
                console.log('ABC ' + JSON.stringify(component.get("v.CurrentTimesheets")));
                //console.log('Timesheet to apex in save'+JSON.stringify(component.get("v.Timesheetrecords")));
                if (component.get('v.CurrentTimesheets').length != 0) {
                    //console.log('This is timesheets '+JSON.stringify(component.get("v.CurrentTimesheets")));
                    var rowitem = component.get("v.TimeSheetRow");
                    //var datetimelst = component.get("v.DateTimeList");
                    //console.log('this is datetime list '+JSON.stringify(component.get("v.DateTimeList")));
                    var datetimelsttemp = [];
                    for (var j = 0; j < component.get("v.DateTimeList").length; j++) {
                        datetimelsttemp.push({ 'label': component.get("v.DateTimeList")[j].label, 'value': '', 'Status': 'New', 'Id': null });
                    }
                    console.log('Timesheet to apex in save' + JSON.stringify(component.get("v.Timesheetrecords")));
                    //console.log('this is datetime list temp '+JSON.stringify(datetimelsttemp));
                    //Added Project_Nickname__c SSE-20058
                    rowitem.push({
                        'Timesheet': {
                            'sobjectType': 'Timesheet_Line__c', 'Project__c': component.get("v.CurrentTimesheets")[0].Project__c,
                            'Project_Number__c': component.get("v.CurrentTimesheets")[0].Project_Number__c,
                            'Project_Name__c': component.get("v.CurrentTimesheets")[0].Project_Name__c,
                            'Project_Nickname__c': component.get("v.CurrentTimesheets")[0].Project_Nickname__c,
                            'Time_Category__c': component.get("v.CurrentTimesheets")[0].Time_Category__c,
                            /*'Task_Category__c': component.get("v.CurrentTimesheets")[0].Task_Category__c,*/ 'Task__c': component.get("v.CurrentTimesheets")[0].Task__c, 'DateTime': datetimelsttemp
                        }, 'TotalHours': 0
                    });
                    console.log('this is first rowitem ' + JSON.stringify(rowitem));
                    var Match = false;
                    var rowIndextouse = 0;
                    //console.log('Timesheet to apex in save'+JSON.stringify(component.get("v.Timesheetrecords")));
                    for (var i = 0; i < component.get("v.CurrentTimesheets").length; i++) {
                        for (var k = 0; k < rowitem.length; k++) {
                            if (rowitem[k].Timesheet.Project__c == component.get("v.CurrentTimesheets")[i].Project__c &&
                                rowitem[k].Timesheet.Task__c == component.get("v.CurrentTimesheets")[i].Task__c &&
                                rowitem[k].Timesheet.Time_Category__c == component.get("v.CurrentTimesheets")[i].Time_Category__c /*&&
                                rowitem[k].Timesheet.Task_Category__c == component.get("v.CurrentTimesheets")[i].Task_Category__c*/) {
                                Match = true;
                                rowIndextouse = k;
                                break;
                            }
                        }
                        if (Match == true) {
                            for (var j = 0; j < datetimelsttemp.length; j++) {
                                if (rowitem[rowIndextouse].Timesheet.DateTime[j].label == this.ConvertDtAPXtoUI(component.get("v.CurrentTimesheets")[i].Date_Invoiced__c)) {
                                    rowitem[rowIndextouse].Timesheet.DateTime[j].value = component.get("v.CurrentTimesheets")[i].Hours__c;
                                    rowitem[rowIndextouse].Timesheet.DateTime[j].Status = 'Old'
                                    rowitem[rowIndextouse].Timesheet.DateTime[j].Id = component.get("v.CurrentTimesheets")[i].Id;
                                    rowitem[rowIndextouse].TotalHours = parseFloat(rowitem[rowIndextouse].TotalHours) + parseFloat(component.get("v.CurrentTimesheets")[i].Hours__c);
                                    break;
                                }
                            }
                            //console.log('This is timetemp '+JSON.stringify(rowitem[k].Timesheet.DateTime));
                        }

                        else {
                            datetimelsttemp = [];
                            for (var j = 0; j < component.get("v.DateTimeList").length; j++) {
                                datetimelsttemp.push({ 'label': component.get("v.DateTimeList")[j].label, 'value': '', 'Status': 'New', 'Id': null });
                            }
                            for (var j = 0; j < datetimelsttemp.length; j++) {
                                if (datetimelsttemp[j].label == this.ConvertDtAPXtoUI(component.get("v.CurrentTimesheets")[i].Date_Invoiced__c)) {
                                    datetimelsttemp[j].value = component.get("v.CurrentTimesheets")[i].Hours__c;
                                    datetimelsttemp[j].Status = 'Old'
                                    datetimelsttemp[j].Id = component.get("v.CurrentTimesheets")[i].Id;
                                    break;
                                }
                            }
                            //Added Project_Nickname__c SSE-20058
                            rowitem.push({
                                'Timesheet': {
                                    'sobjectType': 'Timesheet_Line__c', 'Project__c': component.get("v.CurrentTimesheets")[i].Project__c, 'Project_Name__c': component.get("v.CurrentTimesheets")[i].Project_Name__c,
                                    'Project_Number__c': component.get("v.CurrentTimesheets")[i].Project_Number__c,
                                    'Project_Nickname__c': component.get("v.CurrentTimesheets")[i].Project_Nickname__c,
                                    'Time_Category__c': component.get("v.CurrentTimesheets")[i].Time_Category__c,
                                    /*'Task_Category__c': component.get("v.CurrentTimesheets")[i].Task_Category__c,*/ 'Task__c': component.get("v.CurrentTimesheets")[i].Task__c, 'DateTime': datetimelsttemp
                                }, 'TotalHours': component.get("v.CurrentTimesheets")[i].Hours__c,
                            });
                            //console.log('This is timetemp '+JSON.stringify(rowitem[k].Timesheet.DateTime));

                        }
                        Match = false;
                    }
                    //console.log('This is timesheets row '+JSON.stringify(rowitem));
                    component.set("v.TimeSheetRow", rowitem);

                }

                else {
                    this.addrowhelper(component);
                }
                component.set("v.InitialList", component.get("v.TimeSheetRow"));
                //console.log('This is initial timesheet row on doInit'+JSON.stringify(component.get("v.InitialList")));

            }
            //console.log('Timesheet to apex in save'+JSON.stringify(component.get("v.Timesheetrecords")));
            //console.log('Timesheet to delete in save'+JSON.stringify(component.get("v.TimesheetsToDelete")));
            helper.CalculateTotalHoursInDay(component);
            component.set("v.spinner", false);


        });
        $A.enqueueAction(action);

    },
    ConvertDtUItoAPX: function (component, Dtstrt) {
        /* var Dtstr = new Date(Dtstrt);
        var dt = new Date();
        var Dt4Apx = Dtstr.getDate()+'/'+Dtstr.getMonth()+'/'+dt.getFullYear();
        //alert(Dt4Apx);
        //console.log(Dt4Apx);
        return Dt4Apx; */
        var datestring1 = Dtstrt.substring(4);
        var dates = datestring1.split('/');
        //var date1 = new Date(component.get("v.CurrentPeriodDate"));
        //alert("year "+component.get("v.CurrentPeriodDate").getFullYear());
        var returnstring = dates[1] + '/' + dates[0] + '/' + component.get("v.CurrentPeriodDate").getFullYear();
        //alert("date "+returnstring);
        return returnstring;

    },
    ConvertDtAPXtoUI: function (Dtss) {
        var weekday = new Array(7);

        weekday[0] = "Sun";
        weekday[1] = "Mon";
        weekday[2] = "Tue";
        weekday[3] = "Wed";
        weekday[4] = "Thu";
        weekday[5] = "Fri";
        weekday[6] = "Sat";
        //console.log("USA Date from Apex "+Dtss);
        //console.log("User's locale "+$A.get("$Locale.country"));
        //console.log("User's timezone offset "+new Date().getTimezoneOffset());
        var offset = new Date().getTimezoneOffset();
        var offsettouse = (offset / 60);
        //console.log("test "+offsettouse%1);
        var offsetString;
        if (offsettouse > 0 && offsettouse < 10 && (offsettouse % 1 == 0)) {
            offsetString = 'T12:00:00.000-0' + offsettouse + ':00';
        }
        else if (offsettouse > 0 && offsettouse >= 10 && (offsettouse % 1 == 0)) {
            offsetString = 'T12:00:00.000-' + offsettouse + ':00';
        }
        else if (offsettouse < 0 && offsettouse > -10 && (offsettouse % 1 == 0)) {
            offsettouse = -1 * offsettouse;
            offsetString = 'T12:00:00.000+0' + offsettouse + ':00';
        }
        else if (offsettouse < 0 && offsettouse <= -10 && (offsettouse % 1 == 0)) {
            offsettouse = -1 * offsettouse;
            offsetString = 'T12:00:00.000+' + offsettouse + ':00';
        }
        else if (offsettouse > 0 && offsettouse < 10 && (offsettouse % 1 == 0.5)) {
            offsettouse = offsettouse - 0.5;
            offsetString = 'T12:00:00.000-0' + offsettouse + ':30';
        }
        else if (offsettouse > 0 && offsettouse >= 10 && offsettouse % 1 == 0.5) {
            offsettouse = offsettouse - 0.5;
            offsetString = 'T12:00:00.000-' + offsettouse + ':30';
        }
        else if (offsettouse < 0 && offsettouse > -10 && (offsettouse % 1 == -0.5)) {
            offsettouse = (-1 * offsettouse) - 0.5;
            offsetString = 'T12:00:00.000+0' + offsettouse + ':30';
        }
        else if (offsettouse < 0 && offsettouse <= -10 && (offsettouse % 1 == -0.5)) {
            offsettouse = (-1 * offsettouse) - 0.5;
            offsetString = 'T12:00:00.000+' + offsettouse + ':30';
        }
        else if (offsettouse > 0 && offsettouse < 10 && (offsettouse % 1 == 0.75)) {
            offsettouse = offsettouse - 0.75;
            offsetString = 'T12:00:00.000-0' + offsettouse + ':45';
        }
        else if (offsettouse > 0 && offsettouse >= 10 && offsettouse % 1 == 0.75) {
            offsettouse = offsettouse - 0.75;
            offsetString = 'T12:00:00.000-' + offsettouse + ':45';
        }
        else if (offsettouse < 0 && offsettouse > -10 && (offsettouse % 1 == -0.75)) {
            offsettouse = (-1 * offsettouse) - 0.75;
            offsetString = 'T12:00:00.000+0' + offsettouse + ':45';
        }
        else if (offsettouse < 0 && offsettouse <= -10 && (offsettouse % 1 == -0.75)) {
            offsettouse = (-1 * offsettouse) - 0.75;
            offsetString = 'T12:00:00.000+' + offsettouse + ':45';
        }

        else if (offsettouse == 0) {
            offsetString = 'T12:00:00.000+00:00';
        }
        //console.log("offset to use "+offsetString);
        var DateString = Dtss + offsetString;
        var Dtstr = new Date(DateString);
        var Dt4UI = weekday[(Dtstr.getDay()) % 7] + ' ' + Dtstr.getDate() + '/' + (Dtstr.getMonth() + 1);
        //console.log('USA Dt4UI '+Dt4UI);
        return Dt4UI;


    },
    MergeDuplicateTimesheets: function (component) {
        //console.log("Insise MergeDuplicateRows");
        var arr = component.get("v.TimeSheetRow");
        var timesheetstodeletelist = component.get("v.TimesheetsToDelete");
        var temparr = {};
        var result = arr.reduce(function (r, o) {
            var key = o.Timesheet.Project__c + '-' + o.Timesheet.Task__c + '-' + o.Timesheet.Time_Category__c /*+ '-' + o.Timesheet.Task_Category__c*/;
            if (!temparr[key]) {
                temparr[key] = Object.assign({}, o); // create a copy of o
                r.push(temparr[key]);
            } else {
                temparr[key].TotalHours = parseFloat(temparr[key].TotalHours) + parseFloat(o.TotalHours);
                var tempdattimelist = o.Timesheet.DateTime.concat(temparr[key].Timesheet.DateTime);
                //console.log('This is combined datetime list '+JSON.stringify(tempdattimelist));
                var tempdatetimearr = {};
                temparr[key].Timesheet.DateTime = tempdattimelist.reduce(function (s, p) {
                    var keydatetime = p.label;
                    //console.log('key datetime '+keydatetime);
                    if (!tempdatetimearr[keydatetime]) {
                        tempdatetimearr[keydatetime] = Object.assign({}, p); // create a copy of p
                        s.push(tempdatetimearr[keydatetime]);
                    } else {
                        if (p.Id !== null) {
                            timesheetstodeletelist.push({ 'sobjectType': 'Timesheet_Line__c', 'Id': p.Id });
                        }
                        if (isNaN(parseFloat(tempdatetimearr[keydatetime].value)))
                            tempdatetimearr[keydatetime].value = 0;
                        if (isNaN(parseFloat(p.value)))
                            p.value = 0;
                        tempdatetimearr[keydatetime].value = parseFloat(p.value) + parseFloat(tempdatetimearr[keydatetime].value);
                    }
                    return s;
                }, []);
                //console.log('This is reduced datetime list '+JSON.stringify(result2));   
            }
            return r;
        }, []);

        //console.log('This is '+JSON.stringify(result));
        //console.log('This is timesheets to delete '+JSON.stringify(timesheetstodeletelist));
        component.set("v.TimesheetsToDelete", timesheetstodeletelist);
        component.set("v.TimeSheetRow", result);
    },
    ValidateTotalHoursInDay: function (component) {
        var arr = component.get("v.TimeSheetRow");
        if (arr.length == 0) {
            return 'All OK';
        }
        var combineddatetimearr = [];
        for (var i = 0; i < arr.length; i++) {
            combineddatetimearr = combineddatetimearr.concat(arr[i].Timesheet.DateTime);
        }
        var tempdatetimearr = {};
        var combineddatetimearrunique = combineddatetimearr.reduce(function (s, p) {
            var keydatetime = p.label;
            //console.log('key datetime '+keydatetime);
            if (!tempdatetimearr[keydatetime]) {
                tempdatetimearr[keydatetime] = Object.assign({}, p); // create a copy of p
                s.push(tempdatetimearr[keydatetime]);
            } else {
                tempdatetimearr[keydatetime].value = parseFloat((p.value == '' ? 0.00 : p.value)) + parseFloat((tempdatetimearr[keydatetime].value == '' ? 0.00 : tempdatetimearr[keydatetime].value));
            }
            return s;
        }, []);
        var status;
        for (var i = 0; i < combineddatetimearrunique.length; i++) {
            if (combineddatetimearrunique[i].value > 24) {
                component.set("v.spinner", false);
                status = 'Total hours value in a Day exceeds in ' + combineddatetimearrunique[i].label;
                return status;
            }
            else {
                status = 'All OK';
            }
        }
        return status;

    },
    CalculateTotalHoursInDay: function (component) {
        var arr = component.get("v.TimeSheetRow");
        var totalOfTotal = 0;
        var combineddatetimearr = [];
        var unit;
        var unit2;
        for (var i = 0; i < arr.length; i++) {
            combineddatetimearr = combineddatetimearr.concat(arr[i].Timesheet.DateTime);
            totalOfTotal = parseFloat(totalOfTotal) + parseFloat(arr[i].TotalHours);
        }
        var tempdatetimearr = {};
        var combineddatetimearrunique = combineddatetimearr.reduce(function (s, p) {
            var keydatetime = p.label;
            if (!tempdatetimearr[keydatetime]) {
                tempdatetimearr[keydatetime] = Object.assign({}, p); // create a copy of p
                s.push(tempdatetimearr[keydatetime]);
            } else {
                if (isNaN(parseFloat(p.value))) {
                    unit = 0;
                }
                else {
                    unit = parseFloat(p.value);
                }
                if (isNaN(parseFloat(tempdatetimearr[keydatetime].value))) {
                    unit2 = 0;
                }
                else {
                    unit2 = parseFloat(tempdatetimearr[keydatetime].value);
                }
                tempdatetimearr[keydatetime].value = unit + unit2;
            }
            return s;
        }, []);
        var status;
        var templist = [];
        for (var i = 0; i < combineddatetimearrunique.length; i++) {
            templist.push({ 'Day': combineddatetimearrunique[i].label, 'Totalhours': combineddatetimearrunique[i].value })
        }
        templist.push({ 'Day': 'TotalOfTotal', 'Totalhours': totalOfTotal });
        //console.log('PerDayLoggedHours list CalculateTotalHoursInDay '+JSON.stringify(templist));
        component.set("v.PerDayLoggedHours", templist);

    },

    CallProjectData: function (component, ProjectrecId, index) {
        //console.log('Inside callProjectData with Id '+ProjectrecId);
        var action = component.get("c.ProjectData");
        action.setParams({ "Project_record_Id": ProjectrecId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('This is Projectcall state '+response.getState());
            if (state === "SUCCESS") {
                component.set("v.ProjectRecord", response.getReturnValue());
                console.log("This is project data " + JSON.stringify(component.get("v.ProjectRecord")));
                var docobj = component.get("v.TimeSheetRow");
                //console.log('Index record is '+JSON.stringify(docobj[index]));
                //console.log('Index project type is '+component.get("v.ProjectRecord").Project_Name__c);
                docobj[index].Timesheet.Project__c = ProjectrecId;
                docobj[index].Timesheet.Project_Name__c = component.get("v.ProjectRecord").Project_Name__c;
                //Added Project_Nickname__c mapping SSE-20058
                docobj[index].Timesheet.Project_Nickname__c = component.get("v.ProjectRecord").Project_Nick_Name__c;
                docobj[index].Timesheet.Project_Number__c = component.get("v.ProjectRecord").Name;
                component.set("v.TimeSheetRow", docobj);


            }
            else {
                //console.log('Project Error '+response.getReturnValue());
            }

        });
        $A.enqueueAction(action);
    },

})