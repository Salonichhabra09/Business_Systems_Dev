({
	ButtonTogglefunc: function(component) {
		if(component.get("v.numberOfDaysInitialValue")!=component.get("v.numberOfDays")){
            component.set("v.buttonToggle",false);
        }
        else{
            component.set("v.buttonToggle",true);
        }
	}
})