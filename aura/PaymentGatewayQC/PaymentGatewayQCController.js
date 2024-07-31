({
    onload : function(component, event, helper) {
        component.set('v.columns', [
           
            {label: 'Agent Name', fieldName: 'Name', type: 'text'},
            {label: 'Role',fieldName:'Role__c',type:'text'},
            {label:'Payment Status',fieldName:'Payment_Status__c',type:'text'},
            {label: 'Amount',fieldName:'Amount__c',type:'currency'}
            
        ]);
        //alert('Test'+component.get("v.recordId"));
        var action = component.get("c.getRelatedContact");
        action.setParams({
            'recordId' : component.get("v.recordId")
        })
        
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS"){
                // alert('state'+response.getReturnValue());
                component.set("v.newList", response.getReturnValue());
                helper.loadLocation(component, event, helper);
            }
            
        });
        $A.enqueueAction(action);
        
        
    },
    
    handleSelect : function(component, event, helper) {
        
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            
            setRows.push(selectedRows[i].id);
            
        }
        component.set("v.selectedAccts", setRows);
        
    },
    
    contactMakePayment : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "isredirect" : "false",
            "url": 'https://uat.thepayplace.com/epayconsumerweb/stateofca/foodagriculture/cdfapayments?returnurl=https%3a%2f%2frsadev-cdfa-dev.cs133.force.com%2fcdfalpi%2fapex%2fPaymentReturn&ref=1234&id=2114&bfn=Johnny&bmn=K&bln=Test&custom=This+is+the+description.,$125.00&cfamount=2.00'
        });
        urlEvent.fire();
        
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
        /*
        var records = component.get("v.selectedAccts");
        if(records.length == 0)
        {
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Please select one or more Agent',
                messageTemplate: '',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            
            
        }
        else{
        var setRows = [];
        for ( var i = 0; i < records.length; i++ ) {
            
            setRows.push(records[i]);
            //alert(records);
            // alert(setRows);
            
        }
            
             var action = component.get("c.insertPaymentRequest");
            action.setParams({
            'recordId' : component.get("v.recordId")
            })
            
            action.setCallback(this, function(response){
            var state = response.getState();
           // alert('Inside Load Location amount state'+state);
            if(state === "SUCCESS"){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Success',
                message:'Record Processed Succesfully',
                messageTemplate: '',
                duration:' 5000',
                key: 'info_alt',
                type: 'info',
                mode: 'pester'
            });
            toastEvent.fire();
            
            }
            
            });
            $A.enqueueAction(action);
            
        }
        */
    }
    
    
})