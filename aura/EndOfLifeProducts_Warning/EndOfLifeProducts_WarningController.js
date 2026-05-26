({
	init : function(component, event, helper) {
		let obj = component.get("v.sObjectName");
        let recId = component.get("v.recordId");

        if(obj == 'Account'){
            component.set('v.warningMessage', $A.get("$Label.c.Account_EOFProducst_warning"));
        } else if (obj == 'Opportunity') {
            component.set('v.warningMessage', $A.get("$Label.c.Opportunity_EOFProducst_warning"));
        }
        helper.showMessage(component, event, helper, obj, recId);
	},
    
    recordUpdated : function(component, event, helper) {
        if( event.getParams().changeType != 'ERROR' && event.getParams().changeType !='LOADED'){
            $A.enqueueAction(component.get('c.init'));
        }
	},
})