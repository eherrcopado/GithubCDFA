({
    loadLocation : function(component, event, helper) {
        component.set('v.loccolumns', [
            {label: 'Location Name', fieldName: 'locationName', type: 'text'},
            {label: 'Location Type',fieldName:'locationType',type:'text'},
            {label: 'Payment Status',fieldName:'paymentStatus',type:'text'},
            {label: 'Amount',fieldName:'amount',type:'currency'}
        ]);
       
        //alert('Test'+component.get("v.recordId"));
        var action = component.get("c.getRelatedLocation");
        action.setParams({
            'recordId' : component.get("v.recordId")
        })
        
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS"){
                //alert('state'+response.getReturnValue());
                component.set("v.locList", response.getReturnValue());
                //alert('before Load Location amount');
                helper.loadAmountLocation(component, event, helper);
                
            }
            
        });
        $A.enqueueAction(action);
        
        
    },
    loadAmountLocation : function(component, event, helper) {
        //alert('Inside Load Location amount');
        var action = component.get("c.getAmountLocation");
        action.setParams({
            'recordId' : component.get("v.recordId")
        })
        
        action.setCallback(this, function(response){
            var state = response.getState();
            // alert('Inside Load Location amount state'+state);
            if(state === "SUCCESS"){
                //alert('Inside Load Location amount state'+response.getReturnValue());
                component.set("v.amntLocation", response.getReturnValue());
                helper.loadAmountContact(component, event, helper);
                
            }
            
        });
        $A.enqueueAction(action);
        
        
    }
    ,
    loadAmountContact : function(component, event, helper) {
        
        var action = component.get("c.getTotalAmountContact");
        action.setParams({
            'recordId' : component.get("v.recordId")
        })
        
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS"){
                //alert('state'+response.getReturnValue());
                component.set("v.amntContact", response.getReturnValue());
                
                
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    
    getSelectedContact: function (component, event, helper) {
        
        // Display that fieldName of the selected rows
        /* for (var i = 0; i < selectedRows.length; i++){
        alert("You selected: " + selectedRows[i].opportunityName);
    }*/
    }
    
})