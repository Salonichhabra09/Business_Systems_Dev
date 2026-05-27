({
   /* doInit : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url": "/"+component.get("v.recordId")+"/e?clone=1"
    });
    urlEvent.fire();
	},*/
	navigatetoNewMilestone : function(component, event, helper) {
        var templist = [];
        templist.push({"Amount__c":component.get("v.MilestoneRecord").Amount__c,
                       "BU__c":component.get("v.MilestoneRecord").BU__c,
                       "CurrencyIsoCode":component.get("v.MilestoneRecord").CurrencyIsoCode,
                       "Milestone_Period__c":component.get("v.MilestoneRecord").Milestone_Period__c,
                       "Project__c":component.get("v.MilestoneRecord").Project__c,
                       "Service_Type2__c":component.get("v.MilestoneRecord").Service_Type2__c,
                       "Cross_Border_BU__c":component.get("v.MilestoneRecord").Cross_Border_BU__c,
                       "Milestone_Description__c":component.get("v.MilestoneRecord").Milestone_Description__c,
                       "Milestone_Owner__c":component.get("v.MilestoneRecord").Milestone_Owner__c,
                       "Milestone_Risk__c":component.get("v.MilestoneRecord").Milestone_Risk__c,
                       "Practice_Area__c":component.get("v.MilestoneRecord").Practice_Area__c});
        component.set("v.MilestoneRecordToUse",templist);
        if(component.get("v.MilestoneRecordToUse")[0].Cross_Border_BU__c==null)
            component.get("v.MilestoneRecordToUse")[0].Cross_Border_BU__c=''; 
        if(component.get("v.MilestoneRecordToUse")[0].Milestone_Description__c==null)
            component.get("v.MilestoneRecordToUse")[0].Milestone_Description__c='';
        if(component.get("v.MilestoneRecordToUse")[0].Milestone_Risk__c==null)
            component.get("v.MilestoneRecordToUse")[0].Milestone_Risk__c='';
        if(component.get("v.MilestoneRecordToUse")[0].Practice_Area__c==null)
            component.get("v.MilestoneRecordToUse")[0].Practice_Area__c='';
         if(component.get("v.MilestoneRecordToUse")[0].Milestone_Owner__c==null)
            component.get("v.MilestoneRecordToUse")[0].Milestone_Owner__c=''; 
        console.log("Milestone record after update "+JSON.stringify(component.get("v.MilestoneRecordToUse")));
        var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/lightning/o/Milestone__c/new?defaultFieldValues=Service_Type2__c="+component.get("v.MilestoneRecordToUse")[0].Service_Type2__c+
        ",Milestone_Owner__c="+component.get("v.MilestoneRecordToUse")[0].Milestone_Owner__c+
        ",Cross_Border_BU__c="+component.get("v.MilestoneRecordToUse")[0].Cross_Border_BU__c+
        //",Milestone_Description__c="+component.get("v.MilestoneRecordToUse")[0].Milestone_Description__c+ // commented for SSE-15004
        ",CurrencyIsoCode="+component.get("v.MilestoneRecordToUse")[0].CurrencyIsoCode+
        ",Project__c="+component.get("v.MilestoneRecordToUse")[0].Project__c+
        ",BU__c="+component.get("v.MilestoneRecordToUse")[0].BU__c+
        ",Milestone_Period__c="+component.get("v.MilestoneRecordToUse")[0].Milestone_Period__c+
        ",Amount__c="+component.get("v.MilestoneRecordToUse")[0].Amount__c+
        ",Practice_Area__c="+component.get("v.MilestoneRecordToUse")[0].Practice_Area__c+
        ",Milestone_Risk__c="+component.get("v.MilestoneRecordToUse")[0].Milestone_Risk__c+
        "&backgroundContext=%2Flightning%2Fr%2FMilestone__c%2F"+component.get("v.MilestoneRecord").Id+"%2Fview"+"&nooverride=1"
    });
    urlEvent.fire();
	}
		
	
})