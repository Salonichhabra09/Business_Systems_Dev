(   
    {
    doInit : function(component, event, helper) {
       //window.location = "http://system.shl.com/GCSCInboundSalesInquiry";
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": 'https://engage.shl.com/GCSCInboundSalesInquiry'
        });
       urlEvent.fire();
       window.history.back();
       //window.location = "https://shl--uat.lightning.force.com/lightning/o/Lead/list?filterName=Recent";  
        
    }
})