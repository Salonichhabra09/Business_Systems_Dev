({
    ReadFile : function(component, event, helper) {
        var filetype;
        var fileInput;
        //alert("Event type is "+event.getSource().getLocalId());
        if(event.getSource().getLocalId()=="PricebookEntry")
        {
            filetype='file';
            fileInput=component.find('file').getElement();
        }
        else
        {
            filetype='file1';
            fileInput=component.find('file1').getElement();
        }
        component.set("v.filetype",filetype);
        //alert("Filetype is "+filetype);
        //alert("fileInput is "+fileInput);
        if(fileInput.files.length ==0)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Please select a file before clicking Upload button.",
                "type": "Error"
            })
            toastEvent.fire();
            return;
        }
        else
        {
            var file = fileInput.files[0];
            //alert("This is File "+file);
            if (file) {
                console.log("File");
                var reader = new FileReader();
                reader.readAsText(file, "ISO-8859-1");  
                reader.onload = function (evt) {
                    console.log("EVT FN");
                    var csv = evt.target.result;
                    helper.CallServer(component,csv);
                }
                reader.onerror = function (evt) {
                    console.log("error reading file");
                }
            }
        }
        
    },
    doCancel: function(component, event) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})