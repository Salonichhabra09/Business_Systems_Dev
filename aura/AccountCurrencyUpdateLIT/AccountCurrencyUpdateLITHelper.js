({
	GetAllMapValues : function(component, event, helper) {
		var recordId = component.get("v.simplerecord.Id"); ////
        helper.callServer(component,"c.getMyMap",recordId,
                          function(response){
                              component.set("v.AccountCurrency_BU_Map",response);
                              var MapValue = response;
                              //alert('Value '+component.get("v.simplerecord.BU__c"));
                              if(component.get("v.simplerecord.BU__c")!=null){
                              var MappedCurrency = component.get("v.simplerecord.BU__c").split('- ')[1];                              
                              if(MapValue != null && JSON.stringify(MapValue[MappedCurrency]) != null){
                                  //alert('entered to match currency');
                                  var cur = JSON.stringify(MapValue[MappedCurrency].Default_Currency__c);
                                  var mcur = cur.substring(1,4)
                                  //alert('Mapped Currency' + mcur);
                                  component.set("v.buCurrency", mcur);
                              }
                              component.set("v.showCurrencyEditSection", false);            
                              if(component.get("v.simplerecord.CurrencyIsoCode") != mcur){
                                  //alert('not matched');
                                  component.set("v.isCurrencyChanged", true);
                              }
                              else{
                                  //alert('matched');
                                  component.set("v.isCurrencyChanged", false);
                              }
                              }
                          });
	},
    GetAllIsoCurrencies : function(component, event, helper) {
        var recordId = component.get("v.simplerecord.Id"); ////
        helper.callServer(component,"c.getCurrencyMap",recordId,
                          function(response){
                                 var custs = [];
                                 var conts = response;
                                 for(var key in conts){
                                        custs.push(key);
                                 }
                                 component.set("v.listOfCurrencies", custs);
                                 component.set("v.CurrencyISO_Map",conts);
                          });
		
	}
})