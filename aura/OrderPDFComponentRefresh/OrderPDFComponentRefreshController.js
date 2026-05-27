({
	isRefreshedToast: function(component, event, helper) {
      // alert('added')
        var message = event.getParams().message;
        if(message.includes('added to Order.'))
     //  $A.get('e.force:refreshView').fire();
      location.reload();
            if(message.includes('was deleted.'))
      // $A.get('e.force:refreshView').fire();
        location.reload();
		
	}
})