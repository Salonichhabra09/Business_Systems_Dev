({	
    doCancel: function(component, event) {
        var dismissActionPanel = $A.get("e.force:refreshView");
        //$A.get("e.force:closeQuickAction")
        dismissActionPanel.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})