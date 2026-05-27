({
 
   /* On the component Load this function call the apex class method, 
    * which is return the list of RecordTypes of object 
    * and set it to the lstOfRecordType attribute to display record Type values
    * on ui:inputSelect component. */
    
    CheckAccountTerritory: function(component, event, helper) {
        console.log('objectname',component.get('v.sObjectName'));
        if(component.get('v.sObjectName')=='Opportunity'){
            component.set("v.isOpen", true);
            console.log('Opportunityopen',component.get('v.isOpen'));
        }
        if(component.get('v.sObjectName')=='Account'){
            //const searchTerm = /unassigned/i;
            var TerrName = component.get('v.AccountRecord.Territory__r.Name');
            //alert('Account '+component.get('v.AccountRecord.Territory__r.Name'));
            if(component.get('v.AccountRecord.Territory__c')!=null && !TerrName.includes('UNASSIGNED')){
                component.set("v.isOpen", true);
            }
        }
        if(component.get('v.sObjectName')=='Contact'){
            var ConTerr = component.get('v.ContactRecord.Account.Territory__r.Name');
            if(component.get('v.ContactRecord.Account.Territory__c')!=null && !ConTerr.includes('UNASSIGNED')){
                component.set("v.isOpen", true);
            }
        }
        
    },
    
   fetchListOfRecordTypes: function(component, event, helper) {
      
      var action = component.get("c.fetchRecordTypeValues");
      action.setCallback(this, function(response) {
      var recordTypeValues = response.getReturnValue();
         console.log('List of record types',recordTypeValues);
        
          var subAction = component.get("c.getCurrentUserProfile");
          subAction.setCallback(this, function(response) {
                component.set("v.currentUserProfile",response.getReturnValue());
                if(response.getReturnValue()=='Managed Service Lightning'){
                    component.set("v.lstOfRecordType[0]",recordTypeValues[1]);
                    component.set("v.lstOfRecordType[1]",recordTypeValues[0]);
                    component.set("v.lstOfRecordType[2]",recordTypeValues[2]);
                    }
                
                else{
                        component.set("v.lstOfRecordType",recordTypeValues);
                }
           
           });
            $A.enqueueAction(subAction);
          
      });
      $A.enqueueAction(action);
   },
 
   /* In this "createRecord" function, first we have call apex class method 
    * and pass the selected RecordType values[label] and this "getRecTypeId"
    * apex method return the selected recordType ID.
    * When RecordType ID comes, we have call  "e.force:createRecord"
    * event and pass object API Name and 
    * set the record type ID in recordTypeId parameter. and fire this event
    * if response state is not equal = "SUCCESS" then display message on various situations.
    */
   createRecord: function(component, event, helper) {
      
      //alert('Event from child '+event.getSource().getLocalId());
      var cmpEvent = $A.get("e.c:ButtonClicked");
        cmpEvent.setParams({
            "ButtonName" : event.getSource().getLocalId() });
        cmpEvent.fire();
      var action = component.get("c.getRecTypeId");
      var recordTypeLabel = component.find("selectid").get("v.value");
       if(recordTypeLabel==''){
           var recordtypes=component.get("v.lstOfRecordType");
           for(var i=0;i<=recordtypes.length;i++){
               if(component.get("v.currentUserProfile")=='Managed Service Lightning'){
                  if(recordtypes[i]=='GCSC Opportunity'){
                   recordTypeLabel=recordtypes[i];
                   break;
               } 
                    else
                  continue;
               }
               else{
               if(recordtypes[i]=='Configurator Opportunity'){
                   recordTypeLabel=recordtypes[i];
                   break;
               }
               else
                  continue;
               }
           }
       }
      action.setParams({
         "recordTypeLabel": recordTypeLabel
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            //var createRecordEvent = $A.get("e.force:createRecord");
             var RecTypeID  = response.getReturnValue();
             if(component.get('v.sObjectName')=='Account') {
                 /*createRecordEvent.setParams({
                     "entityApiName": 'Opportunity',
                     "recordTypeId": RecTypeID ,
                     "defaultFieldValues": {
                         "Name": 'Will be autopopulated' ,
                         "Opportunity_Submitted__c": $A.get("$SObjectType.CurrentUser.Id"),
                         "AccountId" :  component.get('v.AccountRecord.Id'),
                         "CurrencyIsoCode" : component.get('v.AccountRecord.CurrencyIsoCode') ,
                         'CampaignId' : "7013L0000003MdTQAU"
                     }
                 });*/
                  var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/lightning/o/Opportunity/new?defaultFieldValues=Name=Will be autopopulated"+
        ",CampaignId="+$A.get('$Label.c.Campaign_Id')+
        ",Opportunity_Submitted__c="+$A.get("$SObjectType.CurrentUser.Id")+
        ",AccountId="+component.get('v.AccountRecord.Id')+
        ",CurrencyIsoCode="+component.get('v.AccountRecord.CurrencyIsoCode')+
        "&recordTypeId="+RecTypeID+
        "&backgroundContext=%2Flightning%2Fr%2FAccount%2F"+component.get("v.recordId")+"%2Fview"+"&nooverride=1"
    });
    urlEvent.fire();
                 
             }
             if(component.get('v.sObjectName')=='Contact') {
                /* createRecordEvent.setParams({
                     "entityApiName": "Opportunity" ,
                     'recordTypeId': RecTypeID,
                     "defaultFieldValues": {
                         "Name": 'Will be autopopulated' ,
                         "Opportunity_Submitted__c": $A.get("$SObjectType.CurrentUser.Id"),
                         "AccountId" :  component.get('v.ContactRecord.AccountId'),
                         'Billing_Contact__c' : component.get("v.recordId"),
                         "CurrencyIsoCode" : component.get('v.ContactRecord.CurrencyIsoCode') ,
                         'CampaignId' : "7013L0000003MdTQAU"
                     }
                     
                 }); */
                 var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/lightning/o/Opportunity/new?defaultFieldValues=Name=Will be autopopulated,"+
        ",CampaignId="+$A.get('$Label.c.Campaign_Id')+
        ",Opportunity_Submitted__c="+$A.get("$SObjectType.CurrentUser.Id")+
        ",AccountId="+component.get('v.ContactRecord.AccountId')+
        ",Billing_Contact__c="+component.get("v.recordId")+
        ",Primary_Contact__c="+component.get("v.recordId")+
        ",CurrencyIsoCode="+component.get('v.ContactRecord.Account.CurrencyIsoCode')+
        "&recordTypeId="+RecTypeID+
        "&backgroundContext=%2Flightning%2Fr%2FContact%2F"+component.get("v.recordId")+"%2Fview"+"&nooverride=1"
    });
    urlEvent.fire();
     }
        if(component.get('v.sObjectName')=='Opportunity') {
        var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            "url": "/lightning/o/Opportunity/new?defaultFieldValues=Name=Will be autopopulated,"+
                ",CampaignId="+$A.get('$Label.c.Campaign_Id')+
                ",Opportunity_Submitted__c="+$A.get("$SObjectType.CurrentUser.Id")+
                ",AccountId="+component.get('v.OpportunityRecord.AccountId')+
                ",CurrencyIsoCode="+component.get('v.OpportunityRecord.Account.CurrencyIsoCode')+
                "&recordTypeId="+RecTypeID+
                "&backgroundContext=%2Flightning%2Fr%2FOpportunityt%2F"+component.get("v.recordId")+"%2Fview"+"&nooverride=1"
            });
        urlEvent.fire();
        
             }
             //createRecordEvent.fire();
             
         } else if (state == "INCOMPLETE") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Oops!",
               "message": "No Internet Connection"
            });
            toastEvent.fire();
             
         } else if (state == "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Error!",
               "message": "Please contact your administrator"
            });
            toastEvent.fire();
         }
      });
      $A.enqueueAction(action);
   },
 
   
   closeModal: function(component, event, helper) {
      // Close modal and navigate appropriately based on launch context
       var cmpEvent = $A.get("e.c:ButtonClicked");
        cmpEvent.setParams({
            "ButtonName" : event.getSource().getLocalId() });
        cmpEvent.fire();

       var pageRef = component.get("v.pageReference");

       // If invoked as a Quick Action or has a page reference, just close the panel
       if (pageRef) {
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
         return;
       }

       // If launched from an Opportunity, navigate to Opportunity object home (deterministic)
       if (component.get("v.sObjectName") === 'Opportunity') {
         var navToHome = $A.get("e.force:navigateToURL");
         navToHome.setParams({
           "url": "/lightning/o/Opportunity/home"
         });
         navToHome.fire();
         return;
       }

       // Fallback: navigate back to the originating record
       var navEvt = $A.get("e.force:navigateToSObject");
       navEvt.setParams({
           "recordId": component.get('v.recordId')
       });
       navEvt.fire();
   },
 
   openModal: function(component, event, helper) {
      // set "isOpen" attribute to true to show model box
      component.set("v.isOpen", true);
   },
})