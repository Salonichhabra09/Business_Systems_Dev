({
    fetchrech : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        helper.callServer(component,"c.getRecordList",recordId,
                          function(response){
                              if(response){
                                  //alert(response);
                                  var acc1=response;
                                  component.set("v.listOfRecordType", acc1); 
                              }
                              
                          });
    },
    
    accdata: function(component, event, helper) {
        //alert('In the account');
        var rectype = component.find("levels").get("v.value");
        //alert('rectype recieved'+ rectype);
        var recordId = component.get("v.recordId");
        //alert('rec id receivedd'+ recordId);
        //alert('rec---'+recordId);
        helper.callServer(component,"c.getAccList",recordId,
                          function(response){
                              if(response){
                                  
                                  var acc1=response;
                                  
                                  component.set("v.address", acc1.CurrencyIsoCode); 
                                  
                                  var createRecordEvent = $A.get("e.force:createRecord");
                                  var userId = $A.get("$SObjectType.CurrentUser.Id");
                                  //var accid = $A.get("$SObjectType.Account.fields.Id");
                                  //var parentId = component.get('v.recordId');
                                  var curVal = component.get("v.address");
                                  //alert("curVal:-->"+curVal);
                                  createRecordEvent.setParams({
                                      "entityApiName": "Opportunity" ,
                                      'recordTypeId': rectype,
                                      "defaultFieldValues": {
                                          'Name' : 'Will be autopopulated',                                
                                          'Opportunity_Submitted__c' : userId,
                                          'AccountId' : component.get("v.recordId"),
                                          'CurrencyIsoCode' : curVal,
                                          'CampaignId' : "7012000000006S1AAI"
                                          
                                          
                                      }
                                      
                                  });
                                  createRecordEvent.fire();
                                  /* var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire(); */
                              }
                              
                          });
        
    },
    
    contdata : function(component, event, helper) {
        var rectype = component.find("levels").get("v.value");
        var recordId = component.get("v.recordId");
        helper.callServer(component,"c.getConList",recordId,
                          function(response){
                              if(response){
                                  var acc1=response;
                                  
                                  // var acccurrency = acc1.account.CurrencyIsoCode;
                                  component.set("v.address", acc1.Account.CurrencyIsoCode); 
                                  
                                  component.set("v.Conacc", acc1.AccountId); 
                                  var createRecordEvent = $A.get("e.force:createRecord");
                                  var userId = $A.get("$SObjectType.CurrentUser.Id");
                                  //var accid = $A.get("$SObjectType.Account.fields.Id");
                                  //var parentId = component.get('v.recordId');
                                  var curVal = component.get("v.address");
                                  var acccon = component.get("v.Conacc");
                                  
                                  //alert("curVal:-->"+curVal);
                                  createRecordEvent.setParams({
                                      "entityApiName": "Opportunity" ,
                                      'recordTypeId': rectype,
                                      "defaultFieldValues": {
                                          'Name' : 'Will be autopopulated',                                
                                          'Opportunity_Submitted__c' : userId,
                                          'AccountId' : acccon,
                                          'Billing_Contact__c' : component.get("v.recordId"),
                                          'CurrencyIsoCode' : curVal,
                                          'CampaignId' : "7012000000006S1AAI"
                                          
                                          
                                      }
                                      
                                  });
                                  createRecordEvent.fire();  
                                  /* var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire(); */
                              }
                          });
    }
    
})