({
	handleShowModal: function(component, evt, helper) {
        var myPageRef = component.get("v.pageReference");
       if(component.get("v.pageReference")!=null){
         var id = myPageRef.state.c__recordId;
        component.set("v.recordId", id);
        var object = myPageRef.state.c__sObjectName;
        component.set("v.sObjectName", object);   
       }
        var modalBody;
        $A.createComponent("c:NewOpportunityFromAccount",
                           {recordId:component.get('v.recordId'),
                            sObjectName:component.get('v.sObjectName')},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: "",
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "mymodal",
                       closeCallback: function() {
                           //alert('event from parent '+component.get("v.buttonName"));
                           if(component.get("v.buttonName")!='Next'){
                             var navEvt = $A.get("e.force:navigateToSObject");
                           navEvt.setParams({
                               "recordId": component.get('v.recordId'),
                           });
                           navEvt.fire(); 
                           }
                        
                       }
                   })
               }
           });
    },
     handleComponentEvent : function(cmp, event) {
        var buttonName = event.getParam("ButtonName");
        // set the handler attributes based on event data
        cmp.set("v.buttonName", buttonName);
        //alert('Inside Event Handler '+buttonName);
    }
})