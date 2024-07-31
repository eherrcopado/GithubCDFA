import { track,LightningElement, wire,api } from 'lwc';
import fetchDefaultRecord from '@salesforce/apex/ViewAccountCreateLocationController.fetchDefaultRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import createAssociatedLocation_JS from '@salesforce/apex/ViewAccountCreateLocationController.createAssociatedLocation';
import updateAssociatedLocation_JS from '@salesforce/apex/ViewAccountCreateLocationController.updateAssociatedLocation';
import getAllAddress_JS from '@salesforce/apex/ViewAccountCreateLocationController.getAllAddress';
import getAccountRelatedAddress_JS from '@salesforce/apex/ViewAccountCreateLocationController.getAccountRelatedAddress';
import uspsAddressSearch_JS from '@salesforce/apex/USPSAddressVerifier.uspsAddressSearch';
import getAssociatedLocationRecord_JS from '@salesforce/apex/ViewAccountCreateLocationController.getAssociatedLocationRecord';

// County Field
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Address_OBJECT from '@salesforce/schema/Address';
import County_FIELD from '@salesforce/schema/Address.County__c';

export default class ViewAccountCreateLocation extends LightningElement {
    // public properties with initial default values
    @api recId;
    @api isModalOpen;
    @api aslcId;

    // private properties
    selectedRecord = {}; // to store selected lookup record in object formate
    showCreation = false;
    city ='';
    street ='';
    country ='';
    province ='';
    postalcode ='';
    locationName='';
    countyName='';
    addressVerification=true;

    selectedAddress=[];
    myAddress=[];
    enteredAddressFlag=false;
    recomendedAddressFlag=false;
    addressNotFound=false;
    serverError=false;
    existingAddress =[];
    operationType;
    formLabel;
    existingAccountRelatedAddress =[];

    // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){
        console.log(this.recId,' <==aslcId==> ',this.aslcId);
        if(this.recId != '' && (this.aslcId == '' || this.aslcId == null || this.aslcId == undefined)){
            this.operationType = 'create';
            this.formLabel = 'Create Associated Location';
            console.log(this.operationType);
            this.commonFunctionOnCBCall();
        }
        else if(this.recId != '' && this.aslcId != ''){
                this.operationType = 'edit';
                this.formLabel = 'Edit Associated Location';
                console.log(this.operationType);
                this.editRecord();
                this.commonFunctionOnCBCall();
        }

    }

    commonFunctionOnCBCall(){
        this.getSelectedCall();
        this.showCreation = true;
        this.addressVerification = true;
        this.showCreation = this.isModalOpen;
        this.getAddress();
        this.getAccountRelatedAddressData();
    }

    getSelectedCall(){
        fetchDefaultRecord({ recordId: this.recId})
            .then((result) => {
                if(result != null){
                    this.selectedRecord = result;
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                //this.error = error;
                this.selectedRecord = {};
            });
    }

    editRecord(){
        getAssociatedLocationRecord_JS({ accountId: this.recId , associatedLocationId: this.aslcId})
            .then((result) => {
                console.log(result,' <==EDIT==> ');
                if(result != null){
                    this.city =result.city;
                    this.street =result.street;
                    this.country =result.country;
                    this.province =result.state;
                    this.postalcode =result.postalCode;
                    this.locationName=result.locationName;
                    this.countyName=result.county;
                }
            })
            .catch((error) => {
                //this.error = error;
                console.log(error);
            });
    }

    getAccountRelatedAddressData(){
        getAccountRelatedAddress_JS({ accountId: this.recId})
            .then((result) => {
                if(result != null){
                    let addressList = result;
                    try{
                        let fullAddressList = addressList.map( x => {
                            let fullAddress = x.street + ',' + x.city + ',' + x.state + ',' + x.postalCode;
                            return fullAddress.toLowerCase();
                        });
                        this.existingAccountRelatedAddress = [...new Set(fullAddressList)];
                    }catch(e){
                        console.log(e);
                    }
                    
                }
            })
            .catch((error) => {
                //this.error = error;
                console.log(error);
            });
    }

    // Description : This Method is used to Hide Address Creation Form after Submission
    closeModal() {
        
        // to close modal set isModalOpen tarck value as false
        this.clearData();
        this.showCreation = false;
        this.isModalOpen = this.showCreation;
        const selectedEvent = new CustomEvent('selected', { detail: this.isModalOpen });
        this.dispatchEvent(selectedEvent);
        this.enteredAddressFlag=false;
        this.recomendedAddressFlag=false;
        this.addressNotFound=false;
        this.serverError=false;
        this.addressVerification=true;
    }

    addressVerificationTrue(){
        this.getSelectedCall();
        this.addressVerification = true;
        this.enteredAddressFlag = false;
        this.recomendedAddressFlag = false;
    }

    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');     
    } // End of COMMON HELPER

    // Start Of clearData
    // Description : This Method is used to clear the variables Values
    clearData(){
        this.city ='';
        this.street ='';
        this.country ='';
        this.province ='';
        this.postalcode ='';
        this.locationName = '';
        this.countyName = '';
    } // End Of clearData

    // Start Of handleChange
    // Description : 
    handleChange(event) {
        this.city = event.target.city;
        this.street = event.target.street;
        this.country = event.target.country;
        this.province = event.target.province;
        this.postalcode = event.target.postalCode;
    } // End Of handleChange

    // Location Name Starts Here
    /*
    handleLocationChange(event){
        this.locationName = event.target.value;
    } */ // Location Name Ends Here

    // County Name Starts Here
    countyHandleChange(event){
        this.countyName = event.target.value;
    } // County Name Ends Here

    // Start Of showToastMsg
    // Description : This method for Show Toast Message
    showToastMsg(Title, Message, Variant) {
        const event = new ShowToastEvent({
            title: Title,
            message: Message,
            variant: Variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    } // End Of showToastMsg

    // County PickList Method Starts 
    @wire(getObjectInfo, { objectApiName: Address_OBJECT })
    addressMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$addressMetadata.data.defaultRecordTypeId', 
            fieldApiName: County_FIELD
        }
    )
    CountyPicklist;
    // County PickList Method Ends    

    // submitDetails Starts Here
    /* This Method for Validating the Form and USPS Verifaction in 1st Stage */
    submitDetails(event){
        // field Validation Starts
        event.preventDefault();
        const address = this.template.querySelector('lightning-input-address');
        //const inputName = this.template.querySelector(".locationName");
        const county = this.template.querySelector(".county");

        //this.locationName = inputName.value;
        this.countyName = county.value;
        
        //street Field Validation
        this.street = address.street;
        if (!this.street) {
            address.setCustomValidityForField('Complete this field.', 'street');
        } else {
            address.setCustomValidityForField("", 'street'); //Reset previously set message
        }

        //city Field Validation
        this.city = address.city;
        if (!this.city) {
            address.setCustomValidityForField('Complete this field.', 'city');
        } else {
            address.setCustomValidityForField("", 'city'); //Reset previously set message
        }

        //State Field Validation
        this.province = address.province;
        if (!this.province) {
            address.setCustomValidityForField('Complete this field.', 'province');
        } else {
            address.setCustomValidityForField("", 'province'); //Reset previously set message
        }

        //Country Field Validation
        this.country = address.country;
        if (!this.country) {
            address.setCustomValidityForField('Complete this field.', 'country');
        } else {
            address.setCustomValidityForField("", 'country'); //Reset previously set message
        }

        //postalcode Field Validation
        this.postalcode = address.postalCode;
        if (!this.postalcode) {
            address.setCustomValidityForField('Complete this field.', 'postalCode');
        } else {
            address.setCustomValidityForField("", 'postalCode'); //Reset previously set message
        }

        address.reportValidity(); // Refreshes the component to show or remove error messages from UI

        // Location Field Validation
        /*
        if (!this.locationName) {                 
            inputName.setCustomValidity("Complete this field.");
        } else {
            inputName.setCustomValidity("");
        }
        inputName.reportValidity();
        */

        // County Field Validation
        if (!this.countyName) {                 
            county.setCustomValidity("Complete this field.");
        } else {
            county.setCustomValidity("");
        }
        county.reportValidity();
        // Validation Ends

        // Verification Starts
        if(!(this.street === "" || this.city === "" || this.country === "" || this.province === "" || this.postalcode === "" ||
         this.countyName == undefined || this.countyName == null || this.countyName == '' )){
            // || this.locationName == undefined || this.locationName == null || this.locationName == ''
            try{
                let address = (this.street.trim() +','+ this.city.trim()  +','+ this.province.trim() +','+ this.postalcode.trim()).toLowerCase().trim();
                //let duplicateAddress = this.existingAddress.includes(address);//.toLowerCase()

                let duplicateAddress = this.existingAccountRelatedAddress.includes(address);
            
            if(duplicateAddress === true){
                this.showToastMsg('Address Already In Use', 'Please try with different address', 'warning');
                this.addressVerification = true;
            }else{
                this.addressVerification = false;
                    uspsAddressSearch_JS({street:this.street,city:this.city,province:this.province,postalcode:this.postalcode})
                    .then(result =>{
                        this.recomendedAddress = result;

                        if(this.recomendedAddress.apiStatusCode != 200){
                            this.serverError=true;
                        }//
                        if(this.recomendedAddress.errorDescription.includes('Address Not Found') || this.recomendedAddress.errorDescription != '' ){
                            this.addressNotFound = true;
                        }else{
                            this.addressNotFound = false;
                        }

                        this.myAddress = [
                                    {
                                        id:"A",
                                        answers:{
                                            a:{
                                                type: 'Address entered',
                                                street: this.street,
                                                city : this.city,
                                                state : this.province,
                                                postalCode : this.postalcode
                                            },
                                            b:{
                                                type: 'Suggested Address',
                                                street: this.recomendedAddress.street,
                                                city : this.recomendedAddress.city,
                                                state : this.recomendedAddress.province,
                                                postalCode : this.recomendedAddress.postalcode
                                            }
                                        }
                                    }
                                ];
                    })
                    .catch(error =>{
                        console.log('error in vaildateAddress_JS--------> ',error);
                    });
                }
            }catch(e){
                    console.log('shahid error--> ',e);
            }            
        }

    } // submitDetails Ends Here

    // All Address and Duplicate Address Starts Here
    getAddress(){
        getAllAddress_JS()
                .then((result) => {
                    let addressList = result;
                    let fullAddressList = addressList.map( x => {
                        let fullAddress = x.Street + ',' + x.City + ',' + x.State + ',' + x.PostalCode;
                        return fullAddress.toLowerCase();
                    });
                    this.existingAddress = [...new Set(fullAddressList)];
                })
                .catch((error) => {
                    console.log('Error in getAllAddress ==> '+error);
            });
    } // All Address and Duplicate Address Ends Here

    // entered Address & recomended Address Handler Starts Here
    changeHandler(event){
        const{name,value}=event.target;
        this.selectedAddress = {...this.selectedAddress,[name]:value}
        if(value == 'a'){
            this.enteredAddressFlag = true;//enteredAddressFlag
            this.recomendedAddressFlag = false;
        }else if(value == 'b'){
            this.enteredAddressFlag = false;
            this.recomendedAddressFlag = true;
        }
    } // entered Address & recomended Address Handler Ends Here

    // Final Submit Starts Here
    submitHandler(event){
        let flag = true;
        let addressData =[];
        event.preventDefault();

        if(this.enteredAddressFlag == false && this.recomendedAddressFlag == false){
            this.showToastMsg('Required Field Missing ', 'Select The Address', 'error');
            flag = true;
        }else if(this.enteredAddressFlag == true){
            addressData = {
                            street : this.street,
                            city : this.city,
                            province : this.province,
                            postalcode : this.postalcode,
                            country : this.country              
                        }
        }else if(this.recomendedAddressFlag == true){
            addressData = {
                            street : this.recomendedAddress.street,
                            city : this.recomendedAddress.city,
                            province : this.recomendedAddress.province,
                            postalcode : this.recomendedAddress.postalcode,
                            country : this.recomendedAddress.country              
                        }
        }

        if(!(this.enteredAddressFlag == false && this.recomendedAddressFlag == false)){

            let address = (addressData.street.trim() +','+ addressData.city.trim()  +','+ addressData.province.trim() +','+ addressData.postalcode.trim()).toLowerCase().trim();
            //let duplicateAddress = this.existingAddress.includes(address);//.toLowerCase()

            let duplicateAddress = this.existingAccountRelatedAddress.includes(address);
            if(duplicateAddress === true){
                this.showToastMsg('Address Already In Use', 'Please try with different address', 'warning');
            }else{
                if(this.operationType == 'create'){
                    // Creation of createAssociatedLocation_JS Starts Here

                    let parameterAddress = {
                        locationName : addressData.street+'-Location',
                        street : addressData.street,
                        city : addressData.city,
                        state : addressData.province,
                        country : addressData.country,
                        postalCode : addressData.postalcode,
                        county : this.countyName,
                        parentRecordId : this.recId,
                        type : 'Other'
                    };
                    
                    createAssociatedLocation_JS({ wrapper: parameterAddress})
                        .then((result) => {
                            this.showToastMsg('Address Creation', 'Record Inserted Successfully.!', 'success');
                            this.resetFunction();
                        })
                        .catch((error) => {
                            //this.error = error;
                            console.log('Error in Apex'+error);
                        });
                    // Creation of createAssociatedLocation_JS Ends Here

                }else if(this.operationType == 'edit'){
                    // Updation of createAssociatedLocation_JS Starts Here

                    let updateAddress = {
                        locationName : addressData.street+'-Location',
                        street : addressData.street,
                        city : addressData.city,
                        state : addressData.province,
                        country : addressData.country,
                        postalCode : addressData.postalcode,
                        county : this.countyName,
                        parentRecordId : this.recId,
                        ascId : this.aslcId
                    };

                    updateAssociatedLocation_JS({ wrapper: updateAddress})
                        .then((result) => {
                            this.showToastMsg('Record Update', 'Record Updated Successfully.!', 'success');
                            this.resetFunction();
                        })
                        .catch((error) => {
                            //this.error = error;
                            console.log('Error in Apex'+error);
                        });
                    // Updation of createAssociatedLocation_JS Ends Here
                }
                

            }
        }
        this.showCreation = flag;
    } // Final Submit Ends Here

    resetFunction(){
        this.showCreation = false;
        this.addressVerification=true;
        this.enteredAddressFlag = false;
        this.recomendedAddressFlag = false;
        this.clearData();
        document.location.reload();
    }
     

}