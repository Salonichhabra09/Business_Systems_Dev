({
    doInit: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        if (component.get("v.pageReference") != null) {
            var id = myPageRef.state.c__recordId;
            component.set("v.recordId", id);
            var initiateTopUp = myPageRef.state.c__initiateTopUp;
            component.set("v.initiateTopUp", initiateTopUp);
            component.set("v.hideInfoCard", true);
        } else {
            // Added init function for SSE-18138 by Aashi
            helper.callInit(component, event, helper);
        }
    },
    //Function to create variation-for Standard Opty:
    ActionOnOptyRec: function (component, event, helper) {
        //if(component.get("v.simpleRecord.RecordType.Name")=='Ignite Opportunity')
        //component.set("v.rCHK",true)
        helper.createOppRecord(component, event, helper);
    },
    //Function to Handle button Swapping:
    CheckRecType: function (component, event, helper) {
        if (component.get("v.simpleRecord.RecordType.Name") == 'Configurator Opportunity')
            component.set("v.rCHK", true)
    },
    //Function to Open RecordType Selector for Ignite-Calling another Component:
    openModal: function (component, event, helper) {
        var divId = component.find('modalDiv');
        $A.util.toggleClass(divId, 'slds-hide');
        component.set("v.rCHK", true)
    },
    handleClick: function (component, event, helper) {
        var recordId = event.target.dataset.oppId;
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
    },
    actionOnTopUp: function (component, event, helper) {
        component.set("v.initiateTopUp", true);
    },
    getValueFromLwc: function (component, event) {
        console.log('param ', event.getParam('value'));
        component.set("v.initiateTopUp", event.getParam('value'));
        /*if (component.get("v.hideInfoCard") == true && component.get("v.initiateTopUp") == false) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/lightning/r/Opportunity/" + component.get("v.recordId") + "/related/OpportunityLineItems/view"
            });
            urlEvent.fire();
        }*/


    }
})