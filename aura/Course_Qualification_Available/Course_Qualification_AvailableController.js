({
	doInit : function(component, event, helper) {
        if(component.get("v.simplerecord.Qualification_Available__c")!=null)
        {
            var qual = component.get("v.simplerecord.Qualification_Available__c").toString();
             var qual2 = new Array();
     	     qual2 = qual.split(";");
             component.set("v.listofQualification",qual2);
        }    
        else
           {
            var text = 'There are no qualifications available to display.';
            component.set("v.listofQualification",text);
             }
        
	}
    
})