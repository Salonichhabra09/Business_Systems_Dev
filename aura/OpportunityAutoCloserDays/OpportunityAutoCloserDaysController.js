({
    
    doInit : function(component, event, helper) {
        
        /*var action = component.get("c.calculateDaysForAutoClose");    
        var oppId = component.get("v.recordId");
        
        action.setParams({
            "oppId":oppId
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            var response1=response.getReturnValue();
            if(state==="SUCCESS")
            {
                component.set("v.CountRemainingDays",response1);
            }
        });
        // Queue this action to send to the server
        $A.enqueueAction(action); */

        let action = component.get('c.getUsersToChangeAutoCloseDate');
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let userEmail = $A.get("$SObjectType.CurrentUser.Email");
                let userCheck = response.getReturnValue() != null && response.getReturnValue().includes(userEmail) ? true : false;
                component.set('v.checkUserToChangeAutoCloseDate', userCheck);
            }
        });
        $A.enqueueAction(action);
        
    },

   
changeCloseDate: function (component, event) {
    if(component.get("v.numberOfDays")==''){
        component.set("v.numberOfDays",0);
    }
    var today = new Date();
    var renewalDate =  new Date(component.get("v.OpportunityRecord").Renewal_Date__c);
    var updatedAutoCloseDate =new Date(component.get("v.OpportunityRecord").Renewal_Date__c);
    updatedAutoCloseDate.setDate(renewalDate.getDate()+parseInt(component.get("v.numberOfDays")));
    var tempUpdatedDate = $A.localizationService.formatDate(updatedAutoCloseDate, "YYYY-MM-DD");
    if(tempUpdatedDate-$A.localizationService.formatDate(today, "YYYY-MM-DD")<0){
        //component.find('IntegerInput').setCustomValidity(' ');
        //component.find('IntegerInput').reportValidity();   
        component.set("v.errorMessage","Auto-Close Date cannot be in the past.");
    }    
    else{
    //component.find('IntegerInput').setCustomValidity('');
    //component.find('IntegerInput').reportValidity();     
    component.set("v.errorMessage",null);  
    var allValid = component.find('IntegerInput').checkValidity();
    if (allValid) {
        component.set("v.spinner", true);
        console.log('NUmber of days '+component.get("v.numberOfDays"));
        console.log('Updated Date is '+updatedAutoCloseDate);
        component.set("v.OpportunityRecord.Auto_Close_Date__c",updatedAutoCloseDate); 
        component.find("recordHandler").saveRecord($A.getCallback(function(response) {
            if (component.isValid() && response.state == "SUCCESS") {
                window.location.reload();
                component.set("v.spinner", false);
            } else if (response.state == "ERROR") {
                component.set("v.spinner", false);
                console.log('Inside Error');
                //It is always entering here.
            }
        }));

    } else {

    }
}
        
    },

    recordUpdate:function(component, event, helper) {
        component.set("v.CountRemainingDays",component.get("v.OpportunityRecord").Days_left_to_Auto_Close__c+' DAY(S) LEFT');
        console.log(component.get("v.OpportunityRecord").Auto_Close_Date__c);
        console.log(component.get("v.OpportunityRecord").Renewal_Date__c);
        if(component.get("v.OpportunityRecord").Auto_Close_Date__c!=null && component.get("v.OpportunityRecord").Renewal_Date__c!=null){
            var autoCloseDate = new Date(component.get("v.OpportunityRecord").Auto_Close_Date__c) ;
            var renewalDate =  new Date(component.get("v.OpportunityRecord").Renewal_Date__c);
            var timeDiffrence = autoCloseDate.getTime() - renewalDate.getTime();
            var differenceInDays = Math.ceil(timeDiffrence / (1000 * 3600 * 24)); 
            console.log('Difference In Days '+differenceInDays);
            component.set("v.numberOfDaysInitialValue",differenceInDays);
            component.set("v.numberOfDays",differenceInDays);
        }
    },

    increaseHandleClick:function(component, event, helper){
        var numb = Number(component.get("v.numberOfDays"));
        component.set("v.numberOfDays",numb+1);
        helper.ButtonTogglefunc(component);
    },

    decreaseHandleClick:function(component, event, helper){
        var numb = Number(component.get("v.numberOfDays"));
        component.set("v.numberOfDays",numb-1);
        helper.ButtonTogglefunc(component);
    },
    checkValidity:function(component, event, helper){
       helper.ButtonTogglefunc(component);
        var allValid = component.find('IntegerInput').checkValidity();
    }

})