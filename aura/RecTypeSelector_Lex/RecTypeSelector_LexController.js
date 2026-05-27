({
    
    fetchrec:function (component, event, helper) {
        var recordId = component.get("v.simpleRecord.Id");
        helper.fetchfromBase(component, event, helper);
    },
    
    navigateTo : function(component, event, helper) {
        var rectype = component.find("levels").get("v.value");
        //alert('this is' +rectype);
        if(rectype === 'Select'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": 'You did not select any record Type!',
                "type": "Error"
            })
            toastEvent.fire();
            return;
        }
        helper.createOppRecord(component, event, helper);
    }
})