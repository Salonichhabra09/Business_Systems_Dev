({
    createOppRecord: function (component, event, helper) {
        var recordId = component.get("v.simpleRecord.Id");
        helper.callServer(component, "c.getOppDetails", recordId,
            function (response) {
                if (response) {
                    var opp = response;
                    var primary_contact;
                    var billing_contact;
                    var oppRecordType;
                    var createOpportunityEvent = $A.get("e.force:createRecord");
                    var Today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    var userId = $A.get("$SObjectType.CurrentUser.Id");
                    //Changes start SSE-16097
                    if (opp.Primary_Contact__c != null) {
                        if (opp.Primary_Contact__r.Contact_Status__c == 'Active') {
                            primary_contact = opp.Primary_Contact__c;
                        } else { primary_contact = ''; }
                    } else { primary_contact = ''; }

                    if (opp.Billing_Contact__c != null) {
                        if (opp.Billing_Contact__r.Contact_Status__c == 'Active') {
                            billing_contact = opp.Billing_Contact__c;
                        } else { billing_contact = ''; }
                    } else { billing_contact = ''; }

                    //Changes end SSE-16097
                    //alert(Today);
                    console.log('opp record type id ' + opp.Previous_Record_Type__c);
                    console.log('label id ' + $A.get("$Label.c.GCSCRecordType"));
                    if (opp.Previous_Record_Type__c == $A.get("$Label.c.GCSCRecordType")) {
                        oppRecordType = $A.get("$Label.c.GCSCRecordType");
                    }
                    else {
                        oppRecordType = $A.get("$Label.c.IgniteRecordType");
                    }
                    console.log('opp record type value ' + oppRecordType);
                    createOpportunityEvent.setParams({
                        "entityApiName": "Opportunity",
                        'recordTypeId': oppRecordType,
                        "defaultFieldValues": {
                            'Name': 'New Record',
                            'StageName': 'New',
                            //'Opportunity_Nickname__c':opp.Opportunity_Nickname__c,
                            'AccountId': opp.AccountId,
                            // Changes start SSE-16097
                            // 'Primary_Contact__c':opp.Primary_Contact__c,
                            'Primary_Contact__c': primary_contact,
                            // Changes end SSE-16097
                            'Days_remaining_from_annual_subscription__c': opp.Days_remaining_from_annual_subscription__c,
                            // Changes start SSE-16097
                            // 'Billing_Contact__c':opp.Billing_Contact__c,
                            'Billing_Contact__c': billing_contact,
                            // Changes end SSE-16097
                            'Transition_related__c': opp.Transition_related__c,
                            //'Lead_Stage__c':opp.Lead_Stage__c,
                            'Is_Subsrciption__c': opp.Is_Subsrciption__c,
                            //'Business_Type__c' : opp.Business_Type__c,
                            'Earliest_Start_Date__c': opp.Earliest_Start_Date__c,
                            //'Running_total_of_subscription_days__c':opp.Running_total_of_subscription_days__c,
                            'Earliest_Start_Date_Plus_Leap_Year__c': opp.Earliest_Start_Date_Plus_Leap_Year__c,
                            'Running_total_of_non_subscription_amount__c': opp.Running_total_of_non_subscription_amount__c,
                            'Marketing_Attribution__c': opp.Marketing_Attribution__c,
                            'Running_total_of_subscription_amount__c': opp.Running_total_of_subscription_amount__c,
                            'Forecast_Category__c': opp.Forecast_Category__c,
                            'Opportunity_Deal_Year__c': opp.Opportunity_Deal_Year__c,

                            'last_Forecast_category_field_change__c': opp.last_Forecast_category_field_change__c,
                            'Current_Date__c': opp.Current_Date__c,
                            'Amount': opp.Amount,
                            'CloseDate': Today,
                            'Renewal_Date__c': opp.Renewal_Date__c,
                            'Probability': '0',
                            'TM_Phase__c': opp.TM_Phase__c,
                            'Proposition__c': opp.Proposition__c,
                            'Offering__c': opp.Offering__c,
                            'Talent_Level__c': opp.Talent_Level__c,
                            'Client_Business_Function__c': opp.Client_Business_Function__c,
                            'Variation_Opportunity__c': 'Yes',
                            'Original_Opportunity__c': opp.Id,
                            'Cross_Border_Opportunity__c': opp.Cross_Border_Opportunity__c,
                            'Non_Standard_T_s_C_s__c': opp.Non_Standard_T_s_C_s__c,
                            'Legal_Owner__c': opp.Legal_Owner__c,
                            'User__c': opp.User__c,
                            'User_2__c': opp.User_2__c,
                            //'NextStep':opp.NextStep,//commented as per SSE-23404
                            'Central_PS_Attributed_to__c': opp.Central_PS_Attributed_to__c,
                            'CampaignId': opp.CampaignId,
                            'Includes_Managed_Services__c': opp.Includes_Managed_Services__c,
                            'Integrated_Solution__c': opp.Integrated_Solution__c,
                            'Includes_Multimedia_Services__c': opp.Includes_Multimedia_Services__c,
                            'Includes_Central_Professional_Services__c': opp.Includes_Central_Professional_Services__c,
                            'Closed_Lost_Reason__c': opp.Closed_Lost_Reason__c,
                            //  'Competitor__c':opp.Competitor__c,
                            'Previsor_SFDC_Id__c': opp.Previsor_SFDC_Id__c,
                            'Won_LossReason_Influencer__c': opp.Won_LossReason_Influencer__c,
                            'Won_Loss_Explanation__c': opp.Won_Loss_Explanation__c,
                            'Competitor_winner__c': opp.Competitor_winner__c,
                            //  'Opportunity_Lost_To__c':opp.Opportunity_Lost_To__c,
                            'ReasonforlostOpportunity__c': opp.ReasonforlostOpportunity__c,
                            'Content_Groups__c': opp.Content_Groups__c,
                            'MMS_Next_Step_Due_Date__c': opp.MMS_Next_Step_Due_Date__c,
                            'Project_Manager__c': opp.Project_Manager__c,
                            'MMS_Next__c': opp.MMS_Next__c,
                            'Lead_Consultant__c': opp.Lead_Consultant__c,
                            'MMS_Next_Step_Description__c': opp.MMS_Next_Step_Description__c,
                            'Previsor_Stage__c': opp.Previsor_Stage__c,
                            'Previsor_Migration_Date__c': opp.Previsor_Migration_Date__c,
                            'Challenger_opportunity__c': opp.Challenger_opportunity__c,
                            'RFP_Status__c': opp.RFP_Status__c,
                            'Likelihood__c': '0%',
                            'Opportunity_Submitted__c': userId,
                            'MS_Opportunity__c': opp.MS_Opportunity__c,
                            'GCSC__c': opp.GCSC__c,
                            'CurrencyIsoCode': component.get("v.simpleRecord.CurrencyIsoCode"),
                            // Change as per SSE-27813 by Aashi
                            'Target_Program__c': opp.Target_Program__c
                        }
                    });
                    createOpportunityEvent.fire();
                }
            })
    },
    /* Added below function callInit for SSE-18138 by Aashi
        Getting Contract End Date from Opportunity
        Enable/Disable Create Variation button based on Contract Start Date
    */
    callInit: function (component, event, helper) {
        var oppRecordId = component.get("v.recordId");
        helper.callServer(component, "c.getOppDetails", oppRecordId,
            function (response) {
                if (response) {
                    var oppDetail = response;
                    if (oppDetail.ContractId) {
                        component.set("v.contractId", oppDetail.ContractId);
                        var contractEndDate = oppDetail.Contract.Contract_End_Date__c;
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        if (contractEndDate < today &&
                            (component.get("v.currentUserDetails.ProfileId") != $A.get("$Label.c.System_Admin_Id_18_Digit"))
                            &&
                            (component.get("v.currentUserDetails.ProfileId") != $A.get("$Label.c.OAT_profile"))
                            //Add the condition to allow the creation of Variation for Jo Tinning (Prachi)
                            && (component.get("v.currentUserDetails.Id") != $A.get("$Label.c.Show_Variation_Opp_for_Jo"))) {
                            //if(contractEndDate < today){
                            component.set("v.isContractEndDateLessThanToday", true);
                            component.set("v.isAllowCreation", false);
                            console.log('Inside If 1');
                        }
                        var contractStartDate = oppDetail.Contract.StartDate;
                        var dateToCheck = new Date(contractStartDate);
                        var monthsToAdd = (oppDetail.Opportunity_Deal_Year__c) * 12;
                        dateToCheck.setMonth(dateToCheck.getMonth() + monthsToAdd);
                        var contractEndDateForThisYear = $A.localizationService.formatDate(dateToCheck, "YYYY-MM-DD");
                        console.log('Date ' + contractEndDateForThisYear);
                        console.log('id ' + component.get("v.currentUserDetails.ProfileId"));
                        if (contractEndDateForThisYear <= today &&
                            (component.get("v.currentUserDetails.ProfileId") != $A.get("$Label.c.System_Admin_Id_18_Digit"))
                            && (component.get("v.currentUserDetails.ProfileId") != $A.get("$Label.c.OAT_profile"))
                            //Add the condition to allow the creation of Variation for Jo Tinning (Prachi)
                            && (component.get("v.currentUserDetails.Id") != $A.get("$Label.c.Show_Variation_Opp_for_Jo"))) {
                            //if(contractEndDateForThisYear <= today){
                            helper.checkActiveYearOpportunity(component, event, helper);
                            component.set("v.isContractEndDateForThisYearLessThanToday", true);
                            component.set("v.isAllowCreation", false);
                            console.log('Inside If 2');
                        }
                    }
                }
            });
    },

    checkActiveYearOpportunity: function (component, event, helper) {
        var contractId = component.get("v.contractId");
        var action = component.get("c.getOpportunityList");
        action.setParams({
            contractId: contractId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var breakLoop = false;
            if (state === "SUCCESS") {
                var oppList = response.getReturnValue();
                for (var i = 0; i < oppList.length; i++) {
                    if (!breakLoop) {
                        var oppRecord = oppList[i];
                        var contractStartDate = oppRecord.Contract.StartDate;
                        var dateToCheck = new Date(contractStartDate);
                        var monthsToAdd = (oppRecord.Opportunity_Deal_Year__c) * 12;
                        dateToCheck.setMonth(dateToCheck.getMonth() + monthsToAdd);
                        var contractEndDateForThisYear = $A.localizationService.formatDate(dateToCheck, "YYYY-MM-DD");
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        if (contractEndDateForThisYear >= today) {
                            component.set('v.currentYearOpportunity', oppRecord);
                            let oppName = component.get('v.currentYearOpportunity.Name');
                            let result = oppName.lastIndexOf("/");
                            let oppName1 = oppName.substring(result + 1);
                            component.set('v.oppName', oppName1);
                            breakLoop = true;
                        }
                    }
                }
            } else if (state === "ERROR") {
                var errorMsg = response.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    }
})