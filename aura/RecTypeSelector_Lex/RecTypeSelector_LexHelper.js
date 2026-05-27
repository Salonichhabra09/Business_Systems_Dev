({
    
    fetchfromBase:function (component, event, helper) {
        var recordId = component.get("v.simpleRecord.Id");
        helper.callServer(component,"c.getRecordList",recordId,
                          function(response){
                              if(response){
                                  var opp= response;
                                  component.set("v.listOfRecordType", opp);
                              }
                          });
    },
    
    createOppRecord : function (component, event, helper) {
        var recordId = component.get("v.childAttribute");
        helper.callServer(component,"c.getOppDetails",recordId,
                          function(response){
                              if(response){
                                  var opp= response;
                                  var rectype = component.find("levels").get("v.value");
                                  
                                  var createOpportunityEvent = $A.get("e.force:createRecord");
                                  var Today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                                  var userId = $A.get("$SObjectType.CurrentUser.Id");    
                                  createOpportunityEvent.setParams({
                                      "entityApiName": "Opportunity",
                                      'recordTypeId': rectype,
                                      "defaultFieldValues": {
                                          'Name' : 'New Record',
                                          'Business_Type__c' : opp.Business_Type__c,
                                          'Billing_Contact__c':opp.Billing_Contact__c,
                                          'Primary_Contact__c':opp.Primary_Contact__c,
                                          'CampaignId' : opp.CampaignId,
                                          'StageName' : 'New',
                                          'Variation_Opportunity__c': 'Yes',
                                          'Original_Opportunity__c' : opp.Original_Opportunity__c,
                                          'AccountId' : opp.AccountId,
                                          'CloseDate' : Today,
                                          'TM_Phase__c': opp.TM_Phase__c,
                                          'Offering__c':opp.Offering__c,
                                          'Talent_Level__c':opp.Talent_Level__c,
                                          'Client_Business_Function__c':opp.Client_Business_Function__c,
                                          'Amount': opp.Amount,
                                          'Opportunity_Submitted__c' : userId,
                                          'Forecast_Category__c': opp.Forecast_Category__c,
                                          'Renewal_Date__c': opp.Renewal_Date__c,
                                          'Marketing_Attribution__c': opp.Marketing_Attribution__c,
                                          'Running_total_of_non_subscription_amount__c': opp.Running_total_of_non_subscription_amount__c,
                                          'Running_total_of_subscription_amount__c': opp.Running_total_of_subscription_amount__c,
                                          'Running_total_of_subscription_days__c': opp.Running_total_of_subscription_days__c,
                                          'last_Forecast_category_field_change__c':opp.last_Forecast_category_field_change__c,
                                          'Current_Date__c':opp.Current_Date__c,
                                          'Probability':'0',
                                          //'Variation_Reason__c':,
                                          'Package_Level__c': opp.Package_Level__c,
                                          'Legal_Owner__c': opp.Legal_Owner__c,
                                          'Cross_Border_Opportunity__c':opp.Cross_Border_Opportunity__c,
                                          'User__c': opp.User__c,
                                          'User_2__c': opp.User_2__c,
                                          'Integrated_Solution__c':opp.Integrated_Solution__c,
                                          'Closed_Lost_Reason__c': opp.Closed_Lost_Reason__c,
                                        //  'Competitor__c': opp.Competitor__c,
                                        //  'Opportunity_Lost_To__c': opp.Opportunity_Lost_To__c,
                                          'Reasons_for_lost_Opportunity__c': opp.Reasons_for_lost_Opportunity__c
                                      }
                                  });
                                  createOpportunityEvent.fire();
                              }
                          })
    }
})