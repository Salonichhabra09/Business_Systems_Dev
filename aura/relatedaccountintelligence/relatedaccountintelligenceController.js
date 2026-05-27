({ 
  doInit: function(cmp) {
    console.log('in child');
    var myPageRef = cmp.get("v.pageReference").state;         
    let recId = myPageRef.c__recordId;
    cmp.set("v.recordId",recId);  
    cmp.set("v.loadall",true);  
    //cmp.find('accountIntelligenceRelated').handleChange1();
      
},
})