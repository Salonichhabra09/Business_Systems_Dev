({
	doInit: function(component, event, helper) {  
        helper.GetAllMapValues(component, event, helper);
        helper.GetAllIsoCurrencies(component, event, helper);
     },
    
    updateAccountCurrency: function(component, event, helper) {
        var record = component.get("v.simplerecord");        
        record.CurrencyIsoCode = component.get("v.buCurrency");
       
       
        component.find("AccountRecordLoader").saveRecord($A.getCallback(function(saveResult) {           
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                component.set("v.isCurrencyChanged", false);
                component.set("v.showCurrencyEditSection", false);             
            }
            else if (saveResult.state === "ERROR") {
                //alert('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                
                //component.set("v.showError",JSON.stringify(saveResult.error));
                 var errors = "";
                    for (var i = 0; saveResult.error.length > i; i++){
                        errors = errors + saveResult.error[i].message;
                    }            
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type":"error",
                        "title": "Error!",
                        "message": errors                        
                    });
                    resultsToast.fire();
               
            }
            }));
    },
    cancelAccountCurrencyUpdate: function(component, event, helper) {
        component.set("v.showCurrencyEditSection", false);
         //$A.get('e.force:refreshView').fire();
    },
    editAccountCurrency: function(component, event, helper) {
        component.set("v.showCurrencyEditSection", true);
         //$A.get('e.force:refreshView').fire();
    },
    saveAccountCurrency: function(component, event, helper) {
        var record = component.get("v.simplerecord");        
        var chosenCurrency = component.find("CurrencyPicklist").get("v.value");
        var Cursymbol = JSON.stringify(component.get("v.CurrencyISO_Map")[chosenCurrency]);
        var mCursymbol = Cursymbol.substring(1,4);
       
        record.CurrencyIsoCode = mCursymbol;
        component.find("AccountRecordLoader").saveRecord($A.getCallback(function(saveResult) {           
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {                
                record.IsCurrencyChanged__c  = false;                
            }
            else if (saveResult.state === "ERROR") {
                var errors = "";
                    for (var i = 0; saveResult.error.length > i; i++){
                        errors = errors + saveResult.error[i].message;
                    }            
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type":"error",
                        "title": "Error!",
                        "message": errors                        
                    });
                    resultsToast.fire();

            }
            }));
    },
    cancelChange: function(component, event, helper) {
         component.set("v.showCurrencyEditSection", false);
         //$A.get('e.force:refreshView').fire();
    },
    RefreshChange: function(component, event, helper) {
        //alert('hello');  
        //location.reload();
    },
    
    recordUpdated: function(component, event, helper) { 
        var changeType = event.getParams().changeType;
		if (changeType === "CHANGED") { 
    		component.find("AccountRecordLoader").reloadRecord();
            helper.GetAllMapValues(component, event, helper);
        }
	}
    
})