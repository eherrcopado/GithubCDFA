import { LightningElement, api, track, wire } from 'lwc';
//import getSelectedValues from '@salesforce/apex/FormESectionController.getSelectedValues';
import updateAgencyApproval_js from '@salesforce/apex/FormESectionController.updateAgencyApproval';
import getAgencyRenewal_js from '@salesforce/apex/FormESectionController.getAgencyRenewal';
//import getExistingAgencyRenewalForAnAccount from '@salesforce/apex/FormESectionController.getExistingAgencyRenewalForAnAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FormESections extends LightningElement {

@track index;
@track Values;
@track SelectedValues = [];
@track value = '';
@track assetsList = [];
 showFirst ;
 showSecond ;
 showThird ;
@api accide;
@track initialData =[];
@track existingSelectedValues = [];
@api agencyrenwalapproved;
@track disableControls;
@api renaccid;

connectedCallback() {
    
    console.log('in connected callback');
   // alert(this.accide+ ' ----  '+ this.renaccid);
    getAgencyRenewal_js({accId:this.accide, renAccID:this.renaccid})
     .then(result => {
/*
       let childData = JSON.parse(JSON.stringify(result));
            if (childData) {
                    if(childData.length>0){ 
					this.agencyList = childData;
                        var agencyListInJSONFormat = JSON.parse(JSON.stringify(this.agencyList));*/
                        console.log('result--------> ', result);
                        let childData = JSON.stringify(result);
                        console.log('childData--------> ', childData);

                        let adr = JSON.parse(JSON.stringify(result));
                        //let newRec = [];
                        adr.forEach(item => {
                            if(item.Business_owns_the_standards_Agency.includes('Agency')){
                                this.showFirst = true;
                                this.SelectedValues.push('My business owns the standards used by my Agency/Agents.');

                            }if(item.Business_uses_certified_standards_owned.includes('weights')){
                                this.showSecond = true;
                                this.SelectedValues.push('My business uses certified standards owned by county weights and measures officials.');
                            }if(item.Business_certified_standards_Third_Party.includes('party')){
                                this.showThird = true;
                                this.SelectedValues.push('My business uses certified standards owned by a third-party.');
                            }
                            
                            
                        });

                        
                        console.log('selectd ---> ', this.SelectedValues);
     }).catch(error => {
        console.log(error);
        this.error = error;
        console.log('error--------> ', error);
    });

    // shahid
    let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
            console.log('flag1 ', this.disableControls)
        }else{
            this.disableControls = false;
            console.log('flag2 ', this.disableControls)
        }

    
}

handleChangeCheck(event) {   
this.Values =  event.target.value;
console.log('selected val----------', this.Values);
console.log('checked val----------', event.target.checked);

//this.SelectedValues[1].push(this.Values);

    if (event.target.checked ){
        this.SelectedValues.push(this.Values);
    }
    else {
       try {
        this.index = this.SelectedValues.indexOf( this.Values);
        this.SelectedValues.splice(this.index, 1);
    } catch (err) {
        }
}
}
// EO handleChangeCheck

@track nothingSelected=false;
@api saveSecERecord(){
   // alert('In SaveESectionRecord');
   if(this.disableControls == false){
        if(this.SelectedValues.length == 0 ){
            // alert('select atleast one device');

                const evt = new ShowToastEvent({
                    title: 'Alert',
                    message: 'Select at least one checkbox',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            this.nothingSelected = true;
        }
       
        else{
             this.nothingSelected = false;
            console.log('result selected values form E=>',JSON.stringify(this.SelectedValues));
            //alert(JSON.stringify(this.SelectedValues));           
            //let selectedValuesData= JSON.stringify(this.SelectedValues);
            updateAgencyApproval_js({wrapperText: JSON.stringify(this.SelectedValues), accId: this.accide , renAccID: this.renaccid, sType :'SIGN'})
            .then(result => {
                
                console.log('Inside updateAgencyApproval_js result ');
                console.log('result ',result);
        })
            .catch(error => {
                alert('k'+error);
                console.log('-------error -------------',JSON.stringify(error));
            });

        }
   }else{
       this.nothingSelected = false;
   }
    return this.nothingSelected;
}
// EO saveRecord
}