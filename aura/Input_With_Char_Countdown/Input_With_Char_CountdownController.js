({
    doInit : function( component, event, helper ) {
        component.set('v.charsRemaining', component.get("v.inputCharLimit"));
    },
    
    handlechange : function(component, event, helper) {
        
        var max = component.get("v.inputCharLimit"); 
        var body = component.get('v.inputText');
        
        const textEncoder = new TextEncoder();
        var textByteSize=  textEncoder.encode(body).length; 
        
        
        if(textByteSize > max){
            var remaining = textByteSize - max;
            component.set('v.charsRemaining', '-' + remaining);
        }
        else if (textByteSize<max)
        {         
            var remaining = max - textByteSize;
             component.set('v.charsRemaining', remaining);
         
        }else{
            var remaining = max - textByteSize;
             component.set('v.charsRemaining', remaining);
        }
        
       
    }
})