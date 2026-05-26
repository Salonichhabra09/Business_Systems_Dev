({
	doInit : function(component, event, helper) {
     
        if(component.get("v.simplerecord.Qualification_required__c")!=null)
        { 
            var req = component.get("v.simplerecord.Qualification_required__c").toString();
            var req2 = new Array();
            req2 = req.split(";");
        component.set("v.listofrequirement",req2)
        }
        else
        
            {
            var text = 'There are no qualifications Required to display!';
            component.set("v.listofrequirement",text);
             }
        
        
	}
})