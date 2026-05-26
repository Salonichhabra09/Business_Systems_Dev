({
    doInit : function(component, event, helper) {
        if(component.get("v.simplerecord.Qualifications__c")!=null && component.get("v.simplerecord.Qualifications__c")!="None")
        {
            var qual = component.get("v.simplerecord.Qualifications__c").toString();
            
            //alert(qual);
            var qual2 = new Array();
            qual2 = qual.split(";");
            //alert(qual2[0]);
            component.set("v.listofQualification",qual2);
            //alert(component.get("v.listofQualification[0]"));
        }
         else
        {
            var text = 'There are no qualifications to display';
            component.set("v.listofQualification",text);
        }
    }
})