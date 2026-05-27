({
    
    UpdateSaveOrder1 : function(component, event,helper){
        var  OppId=component.get("v.recordId");
        //alert("This is"+OppId);
      helper.UpdateSaveOrder(component, event ,helper);  
        
    }
 })