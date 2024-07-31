({
    // This function will close the quickaction modal
    // As on 17-05-22 we are not using this method as we are not using the button anymore on Community page
    handleclickCancelButton: function(component, event) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})