import { track,LightningElement, wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getLocation_JS from '@salesforce/apex/LocationFormController.getLocation';
import getLookupAddress_JS from '@salesforce/apex/LocationFormController.getLookupAddress';
//import createALocation_JS from '@salesforce/apex/LocationFormController.createALocation';
//import addAssociatedLocation_JS from '@salesforce/apex/LocationFormController.addAssociatedLocation';
import removeAssociatedLocation_JS from '@salesforce/apex/LocationFormController.removeAssociatedLocation';
import createLocation_JS from '@salesforce/apex/LocationFormController.createLocation';
//import getDuplicateAddress_JS from '@salesforce/apex/LocationFormController.getDuplicateAddress';
import changeAssociatedLocation_JS from '@salesforce/apex/LocationFormController.changeAssociatedLocation';
import addAssociatedLocation2_JS from '@salesforce/apex/LocationFormController.addAssociatedLocation2';

import uspsAddressSearch_JS from '@salesforce/apex/USPSAddressVerifier.uspsAddressSearch';

// Shahid
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Address_OBJECT from '@salesforce/schema/Address';
import County_FIELD from '@salesforce/schema/Address.County__c';//Address
import Address_FIELD from '@salesforce/schema/Address.Address';

//define row actions
const actions = [
{ label: 'Delete', name: 'delete' }
];

const columns = [
{ label: 'Make Primary',fixedWidth:150},
{ label: 'Type', fieldName: 'Type',fixedWidth:150 },
//{ label: 'Location', fieldName: 'Location' },
{ label: 'Address', fieldName: 'Address__c' },
{
            type:"button-icon",
            fixedWidth: 40,
            typeAttributes: {
                iconName: 'utility:delete',
                label: 'Delete',
                name: 'Delete',
                variant: 'brand' //rowActions: this.getRowActions
                
            }
}

];

const columns2 = [
{ label: 'Make Primary',fixedWidth:150},
{ label: 'Type', fieldName: 'Type',fixedWidth:150 },
{ label: 'Address', fieldName: 'Address__c' },
{
            type:"button-icon",
            fixedWidth: 40,
            typeAttributes: {
                iconName: 'utility:delete',
                label: 'Delete',
                name: 'Delete',
                disabled: 'true',
                variant: 'brand' //rowActions: this.getRowActions
            }
}

];


export default class LocationForm extends LightningElement {
@api accidf;
@api agencyrenwalapproved;
@track disableControls;
@track disableControls2;


@track asoLocationList=[];

@track preSelectedRows = [];

error;  
columns = columns;
columns2 = columns2;


contactRecord;

// lookup prty
@api label = 'custom lookup label';
@api placeholder = 'Search...'; 
@api iconName = 'standard:address';
@api defaultRecordId = '';
@api createRecord  = false;

@track initalData = [];
@track nothingSelected = false;

@track oldRecMap = new Map();
@track allDataMap = new Map();
@track orgData = [];
@track newData = [];
@track showCreation = false;

@track city ='';
@track street ='';
@track country ='';
@track province ='';
@track postalcode ='';
@track locationWrapper = [];
@track disableRemove = false;
@track counter=0;

@track orgPriAssocLocID=undefined;
@track newPriAssocLocID= undefined;
@track orgPriLocId=undefined;
@track newPriLocId= undefined;
@track onchge=false;
// FROM R4 Phase
@track recomendedAddress=[];
@track enteredAddress;
@track addressVerification=true;
@track selectedValue;





selectedAddress=[];
myAddress=[];
enteredAddressFlag=false;
recomendedAddressFlag=false;
addressNotFound=false;
serverError=false;
existingAddress =[];
countyValue;


// private properties 
lstResult = []; // to store list of returned records   
hasRecords = true; 
searchKey=''; // to store input field value    
isSearchLoading = false; // to control loading spinner  
delayTimeout;
selectedRecord = {}; // to store selected lookup record in object formate

@track disableButton=false;

    // ConnectedCallback Start
    connectedCallback()
    {
        
        console.log(' Shahid --',this.disableControls2);
        let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
            this.disableControls2 = true;
        }else{
            this.disableControls = false;
            this.disableControls2 = false;
        }
            
        let acid = this.accidf;
        console.log('acid--- ', acid);


        getLocation_JS({accId:acid})
        .then((result,error) => {
            if (result) {

            let tempRecords = JSON.parse( JSON.stringify( result ) );
            tempRecords = tempRecords.map( row => {
                console.log('location --', row.Location.Name);
                return {
				Id: row.Id,
				visitorId__c: row.visitorId__c,
				LocationId: row.LocationId,
				Type: row.Type,
				Status__c: row.Status__c,
				ParentRecordId: row.ParentRecordId,
				Address__c: row.Address__c,
				AssociatedLocationNumber: row.AssociatedLocationNumber,
				Location: row.Location.Name
				};
                
            });
			this.asoLocationList=tempRecords;

               // this.asoLocationList=result;
                console.log('result --> ', result);
                console.log('result with JSON --> ', JSON.stringify(result));

                this.setPrimaryLocation(result);

                let childData = JSON.parse(JSON.stringify(result));
                childData.forEach(oCon => {
                    let newRec = {
                        Address__c: oCon.Address__c,
                        Type: oCon.Type,
                        "Addr1" : oCon.visitorId__c,
                        Id : oCon.Id,
                        Name : oCon.Location.Name           
                    }
                    console.log('newRec--- ', newRec);
                    console.log('newRec Location--- ', newRec.Name);
                    this.orgData.push(newRec.Addr1);
                    //this.orgData.push(oCon.Address__c);
                });
                console.log(JSON.stringify(this.orgData), ' ----this.orgData size --- ', typeof(JSON.stringify(this.orgData)));

                
            } else if (error) {
                console.error(error);
            }
        });

        this.enteredAddressFlag = false;
        this.recomendedAddressFlag = false;
        this.addressNotFound = false;
        this.serverError = false;

    } // ConnectedCallback End,

    renderedCallback(){
        let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
            this.disableControls2 = true;
        }else{
            this.disableControls = false;
            this.disableControls2 = false;
        }
        
    }

    // End Of setPrimaryLocation
    setPrimaryLocation(data){
        console.log('data in setPrimaryLocation ', data);
        let priId =[];
        for(var i = 0; i <= data.length - 1; i++){
            if(data[i].Type == 'Primary'){
                priId.push(data[i].Id);
                this.orgPriAssocLocID = data[i].Id;
                this.orgPriLocId = data[i].LocationId;
                console.log('orgPriLocId ---SUM', this.orgPriLocId);
                console.log('orgPriAssocLocID', this.orgPriAssocLocID);
            }
                console.log('priId-> ',priId);                        
        }
        this.preSelectedRows = priId;
        
    } // End Of setPrimaryLocation

    // Start Of addLocation
    addLocation(){

        let tst =[];
        console.log(this.orgData.length, ' Before Size && Data ', JSON.stringify(this.orgData));
        console.log(this.asoLocationList.length, ' Before Size && asoLocationList ', JSON.stringify(this.asoLocationList));  
        let arrsize = Object.keys(this.selectedRecord).length;
        if (arrsize > 0) {
            let addrId = this.selectedRecord.Id;
            const myVal = this.asoLocationList.filter( x => x.visitorId__c === addrId);
            console.log('myVal --> ', myVal.length);

            if(myVal.length === 0){

            let acid = this.accidf
                addAssociatedLocation2_JS({addressId:addrId,accountId:acid})
                .then(result => {
                    //this.agentList = [];
                    //alert('Added');
                    console.log('result--->', JSON.stringify(result));

                    // Adding the Created associated Data in Table
                    let adr = JSON.parse(JSON.stringify(result));
                    let newRec = [];
                    adr.forEach(item => {
                        newRec = {
                            Id : item.ascId,
                            visitorId__c : item.addresId,
                            LocationId : item.locationId,
                            Type : item.type,
                            Status__c : item.status,
                            ParentRecordId : item.parentRecordId,
                            Address__c : item.address,
                            AssociatedLocationNumber : item.associatedLocationNumber,
                            Location : item.Location              
                        }
                        
                        
                    });
                    console.log('newRec--->', newRec);
                    if(newRec.Type == 'Primary'){
                        this.orgPriAssocLocID = newRec.Id;
                       // alert(this.orgPriAssocLocID);
                    }
                    
                    this.orgData.push(newRec.visitorId__c);
                    //this.asoLocationList.push(newRec);
                    //refreshApex(this.asoLocationList);

                    try {                                        
                        for(var i = 0; i <= this.asoLocationList.length - 1; i++){
                            tst.push(this.asoLocationList[i]);                           
                        }
                        tst.push(newRec);                                           
                    }catch{
                        console.log('error------------  ', error);
                    }
                    this.asoLocationList = tst;
                    console.log(this.orgData.length, ' After Size && Data ', JSON.stringify(this.orgData));
                    console.log(this.asoLocationList.length, ' After Size && asoLocationList ', JSON.stringify(this.asoLocationList));   
                    
                }) .catch(error => {
                    console.log(error);
                    this.error = error;
                    console.log('error--------> '.error);
                });
                this.handleRemove();

            }else{
                this.showToastMsg('Duplicate', 'This Address Already Added', 'error');
                this.handleRemove();
            }
        } else {
            this.showToastMsg('Location Empty', 'Please Select The Location', 'error');
        }


    } // End Of addLocation

    // Start Of removeRow
    removeRow(event){
        if(this.asoLocationList.length > 1){
            
            try{
                const row = event.detail.row;
                const conId =  row.Id;
                var tst = [];
                var el = this.template.querySelector('lightning-datatable');
                var sel1 = el.getSelectedRows();
                
                if(sel1.length>0){
                    var selectedID = sel1[0].Id
                }

                for(var i = 0; i <= this.asoLocationList.length - 1; i++){
                    if(this.asoLocationList[i].Id == conId){                                      
                        if(this.asoLocationList[i].Id == selectedID){
                            this.showToastMsg('Primary Location Delete','Cannot Delete Primary Location', 'Warning');
                            tst.push(this.asoLocationList[i]);
                        }                    
                    } else {
                        tst.push(this.asoLocationList[i]);
                    }           
                }
                this.asoLocationList = tst;
            }catch (error) {
                console.error('error---> ',error); 
            }
        }else{
            //alert('Cant Delete');
            this.showToastMsg('You can not remove', 'Atleast one Record Required', 'error');
        }
    } // End Of removeRow

    // Start Of handleRowSelection
    handleRowSelection = event => {
        this.onchge = true;
        var selectedRows=event.detail.selectedRows;
        console.log('selectedRows----> ', JSON.stringify(selectedRows));
        //alert(JSON.stringify(selectedRows));
        console.log(selectedRows);
        let selectedId = selectedRows[0].Id;
        let selectedLocId = selectedRows[0].LocationId;
        //alert(selectedId);
        console.log('selectedId----> ', selectedId);
        //this.asoLocationListRecord = selectedRows[0];
        

        var tst = [];
        for(var i = 0; i <= this.asoLocationList.length - 1; i++){
            tst.push(this.asoLocationList[i]); 

            if (this.asoLocationList[i].Id === selectedId) {
            tst[i].Type = 'Primary';
            this.newPriAssocLocID = selectedId;
            this.newPriLocId = selectedLocId;
            console.log('newPriLocId ---SUM', this.newPriLocId);
        }else{
            tst[i].Type = 'Other';
        }
                                
        }
        
        this.asoLocationList = tst;
        console.log('handle Selection----  ', JSON.stringify(this.asoLocationList));
        this.newPriAssocLocID = selectedId;
        console.log('orgPriAssocLocID 290 ---', this.orgPriAssocLocID);
        console.log('newPriAssocLocID 291 ---', this.newPriAssocLocID);
    } // End Of handleRowSelection

    // Renew Code Start from here
    //getLookupAddress_JS Start
    @wire(getLookupAddress_JS, { searchKey: '$searchKey'})
        searchResult(value) {
        console.log('called 1-- ');
            const { data, error } = value; // destructure the provisioned value
            this.isSearchLoading = false;
            if (data) {
                this.hasRecords = data.length == 0 ? false : true; 
            //  this.lstResult = JSON.parse(JSON.stringify(data));
                //console.log('this.lstResult--> ', this.lstResult);
            let lstResult1 = JSON.parse(JSON.stringify(data));
            let r1 = lstResult1.map( x => {
            x.Address__c = x.Street + ', ' + x.City + ' ' + x.State + ' ' + x.PostalCode;
            x.LocationId = x.ParentId;
            return x;
            })
            this.lstResult=this.toUniqueArray(lstResult1);
            console.log('toUniqueArray---> ' + JSON.stringify(this.lstResult));
            //17-10-2022--Shahid
                try{
                    this.existingAddress = this.lstResult.map( x => {
                                            let Address = x.Street.trim() + ',' + x.City.trim() + ',' + x.State.trim() + ',' + x.PostalCode.trim();
                                            return Address.toLowerCase().trim();
                                        });
                    console.log('shahid 1710--> ',this.existingAddress);
                }catch(e){
                    console.log('shahid error--> ',e);
                }
            }
            else if (error) {
                console.log('getLookupAddress_JS error---> ' + JSON.stringify(error));
            }
        };
    //getLookupAddress_JS End

    // to filter duplicate values in an array
        toUniqueArray(a){
        var newArr = [];
        var newTmp = [];
        for (var i = 0; i < a.length; i++) {
            if (newTmp.indexOf(a[i].Address__c) === -1) {
                newTmp.push(a[i].Address__c);
                newArr.push(a[i]);
            }
        }
        return newArr;
    } // EO toUniqueArray

    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
            break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
        }
    } // EO toggleResult

    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        console.log('searchKey--> ', searchKey);
        console.log('this.searchKey--> ', this.searchKey);
    } // EO handleKeyChange

    // method to update selected record from search result 
    handelSelectedRecord(event){
        
            var objId = event.target.getAttribute('data-recid'); // get selected record Id 
            console.log('selected Record event---> ',event.detail);
            this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list
            console.log('this.selectedRecord--> ', this.selectedRecord);
            //let childData = JSON.parse(JSON.stringify(this.selectedRecord));
            //alert(this.selectedRecord.Id);
        
        this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI

    }  // EO handelSelectedRecord


    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');     
    }// EO handelSelectRecordHelper

    // method to clear selected lookup record  
    handleRemove(){
        try{
            console.log('enter--- ');
            this.searchKey = '';    
            this.selectedRecord = {};

            const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
            searchBoxWrapper.classList.remove('slds-hide');
            searchBoxWrapper.classList.add('slds-show');
            const pillDiv = this.template.querySelector('.pillDiv');
            pillDiv.classList.remove('slds-show');
            pillDiv.classList.add('slds-hide');
        }catch(error){
            console.log('err--- ',error);
        }

    }

    // Start Of saveAssociatedLocation
    // Description : This Method used to Submit Details
    @api saveAssociatedLocation(){
        if(this.disableControls == false){
            if(this.asoLocationList.length != 0){
                let asoLocArray=[];
                
            //alert('inside saveAssociatedLocation--> ', this.asoLocationList.length);
            console.log('inside saveAssociatedLocation--> ', this.asoLocationList.length);
            console.log('AssociatedLocation SUMANTH--> ', JSON.stringify(this.asoLocationList));
            try{
                this.asoLocationList.forEach(rec => {
                    console.log('inside try--> ', rec.visitorId__c);
                    this.newData.push(rec.visitorId__c);
                    asoLocArray.push(rec.Id);
                });
                console.log('asoLocArray==>'+asoLocArray);
                console.log(this.orgData.length, ' ----this.orgData size --- ', JSON.stringify(this.orgData));
                console.log(this.newData.length, ' ----this.newData size --- ', JSON.stringify(this.newData));

                let addData = this.newData.filter(visitorId__c => this.orgData.indexOf(visitorId__c) == -1);
                console.log('addData--> ',addData);
                //alert('addData--> '+ JSON.stringify(addData));

                let removeData = this.orgData.filter(visitorId__c => this.newData.indexOf(visitorId__c) == -1);
                //alert('addData--> '+ JSON.stringify(removeData));
                console.log('removeData--> ',removeData);

                

                

                    this.nothingSelected = false;
                    let aid = this.accidf;

                    // Starting the Remove Location Method
                    if(removeData.length>0){
                        console.log('remove location Data--------> ', removeData);
                        
                        removeAssociatedLocation_JS({removeList:removeData, accId:aid})
                        .then(result => {
                            console.log('remove location result--------> ', result);
                        }) .catch(error => {
                            this.error = error;
                            console.log('error--------> ', error);
                        });
                    }
                    // End of the Remove Location Method

                    if(this.onchge == true){
                        if(this.orgPriAssocLocID != this.newPriAssocLocID){
                            let aid = this.accidf;
                            changeAssociatedLocation_JS({orgPrLocId:this.orgPriAssocLocID , newPrLocId:this.newPriAssocLocID , accId:aid})
                            .then(result => {
                                console.log('saved');
                            }) .catch(error => {
                                console.log('error--------> ',error);
                            });
                        }
                    }
                   
                
                    

                

                
            refreshApex(this.asoLocationList);
            }catch (error) {
                console.error('error---> ',error);
            }
            }else{
                this.showToastMsg('No Records', 'Select Atleast One Record', 'error');
                this.nothingSelected = true;
            }
        }else{
            this.nothingSelected = false;
        }

        return this.nothingSelected;
    } // End Of saveAssociatedLocation

    // Start Of saveAssociatedLocation
    // Description : This Method is used to Display Address Creation Form
    createLocation(){
        this.clearData();
        this.showCreation = true;
    } // End Of saveAssociatedLocation

    // Start Of saveAssociatedLocation
    // Description : This Method is used to Hide Address Creation Form after Submission
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.clearData();
        this.showCreation = false;
        this.enteredAddressFlag=false;
        this.recomendedAddressFlag=false;
        this.addressNotFound=false;
        this.serverError=false;
        this.addressVerification=true;
        this.countyValue = '';
    } // End Of saveAssociatedLocation

    // Start Of clearData
    // Description : This Method is used to clear the variables Values
    clearData(){
        this.city ='';
        this.street ='';
        this.country ='';
        this.province ='';
        this.postalcode ='';
    } // End Of clearData

    // Start Of submitDetails
    // Description : This Method is used to Create Address Record
    submitDetails(event) {
        console.log(this.addressMetadata, ' == addressMetadata == ', JSON.stringify(this.addressMetadata));
        console.log(this.AddressPicklist, ' == AK == ', JSON.stringify(this.AddressPicklist));//Address

        if(this.countyValue == undefined || this.countyValue == null || this.countyValue == ''){
            this.showToastMsg('Field Missing', 'Select the County.!', 'error');
            //alert('Select the County');
        }

        event.preventDefault();
        const address = this.template.querySelector('lightning-input-address');

        //street Field Validation
        this.street = address.street;
        if (!this.street) {
            address.setCustomValidityForField('Field is Required', 'street');
        } else {
            address.setCustomValidityForField("", 'street'); //Reset previously set message
        }

        //city Field Validation
        this.city = address.city;
        if (!this.city) {
            address.setCustomValidityForField('Field is Required', 'city');
        } else {
            address.setCustomValidityForField("", 'city'); //Reset previously set message
        }

        //State Field Validation
        this.province = address.province;
        if (!this.province) {
            address.setCustomValidityForField('Field is Required', 'province');
        } else {
            address.setCustomValidityForField("", 'province'); //Reset previously set message
        }

        //Country Field Validation
        this.country = address.country;
        if (!this.country) {
            address.setCustomValidityForField('Field is Required', 'country');
        } else {
            address.setCustomValidityForField("", 'country'); //Reset previously set message
        }

        //postalcode Field Validation
        this.postalcode = address.postalCode;
        if (!this.postalcode) {
            address.setCustomValidityForField('Field is Required', 'postalCode');
        } else {
            address.setCustomValidityForField("", 'postalCode'); //Reset previously set message
        }

        

        
        address.reportValidity(); // Refreshes the component to show or remove error messages from UI
        const isValid = address.checkValidity(); //Check if the address is Valid and accordingly proceed.

        // after Validation Submisson to the DataBase
        
        let flag=true;
        if(!(this.street === "" || this.city === "" || this.country === "" || this.province === "" || this.postalcode === "" || this.countyValue == undefined || this.countyValue == null || this.countyValue == ''))
        {
            
                //check address validity with USPS
            //String street, String city, String province, String postalcode
            
            //recomendedAddress,enteredAddress
            try{
                let address = (this.street.trim() +','+ this.city.trim()  +','+ this.province.trim() +','+ this.postalcode.trim()).toLowerCase().trim();
                let duplicateAddress = this.existingAddress.includes(address);//.toLowerCase()
                console.log(address,'  duplicateAddress--> ',duplicateAddress);
                if(duplicateAddress === true){
                    this.showToastMsg('Duplicate Address', 'Entered address already exists in DB.!', 'warning');
                    this.addressVerification = true;
                }else{
                    this.addressVerification = false;
                    uspsAddressSearch_JS({street:this.street,city:this.city,province:this.province,postalcode:this.postalcode})
                    .then(result =>{
                        this.recomendedAddress = result;
                        //this.recomendedAddress = JSON.stringify(result);
                        console.log('Address--> ', JSON.stringify(this.recomendedAddress));

                        console.log(this.recomendedAddress.street ,'  <==Street--> ', this.recomendedAddress.apiStatusCode);
                        if(this.recomendedAddress.apiStatusCode != 200){
                            this.serverError=true;
                        }//
                        if(this.recomendedAddress.errorDescription.includes('Address Not Found') || this.recomendedAddress.errorDescription != '' ){
                            this.addressNotFound = true;
                            console.log('Address Not Found-->');
                        }else{
                            this.addressNotFound = false;
                            console.log('Valid Address');
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
                                        },
                                        correctAnswer:"b"
                                    }
                                ];
                        
                        console.log('myAddress--------> ',this.myAddress);
                    })
                    .catch(error =>{
                        console.log('error in vaildateAddress_JS--------> ',error);
                    });
                }
            }catch(e){
                console.log('duplicateAddress error--> ',e);
            }
            flag=false;
        }
        
    } // End Of submitDetails

    // Start Of handleChange
    // Description : 
    handleChange(event) {
        this.city = event.target.city;
        this.street = event.target.street;
        this.country = event.target.country;
        this.province = event.target.province;
        this.postalcode = event.target.postalCode;

        this.locationWrapper=[{
                        street:this.city,
                        city:this.street,
                        province:this.country,
                        country:this.province,
                        postalcode:this.postalcode
                    }];
    } // End Of handleChange
    
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


    

    addressVerificationTrue(){
        this.addressVerification = true;
        this.enteredAddressFlag = false;
        this.recomendedAddressFlag = false;
    }

    addressVerificationFalse(){
        this.addressVerification = false;
    }

   

    changeHandler(event){
        const{name,value}=event.target;
        this.selectedAddress = {...this.selectedAddress,[name]:value}
        if(value == 'a'){
            this.enteredAddressFlag = true;//enteredAddressFlag
            this.recomendedAddressFlag = false;
            //console.log('Address', this.enteredAddress);//recomendedAddress,enteredAddress
        }else if(value == 'b'){
            this.enteredAddressFlag = false;
            this.recomendedAddressFlag = true;
            //console.log('Suggested', this.recomendedAddress);
        }
    }

    submitHandler(event){
        let flag = true;
        let addressData =[];
        event.preventDefault();
        // if(this.selectedAddress.A == 'a'){
        //     console.log('u r selected Address entered');
        // }else if(this.selectedAddress.A == 'b'){
        //     console.log('u r selected Suggested Address');
        // }
        if(this.enteredAddressFlag == false && this.recomendedAddressFlag == false){
            //alert('Select one Address');
            this.showToastMsg('Required Field Missing ', 'Select The Address', 'error');
            flag = true;
        }else if(this.enteredAddressFlag == true){
            console.log('Address Entered', this.enteredAddress);
            addressData = {
                            street : this.street,
                            city : this.city,
                            province : this.province,
                            postalcode : this.postalcode,
                            country : this.country              
                        }
        }else if(this.recomendedAddressFlag == true){
            console.log('Suggested Address', this.recomendedAddress);
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
            let duplicateAddress = this.existingAddress.includes(address);//.toLowerCase()
            console.log(address,'  duplicateAddress--> ',duplicateAddress);
            if(duplicateAddress === true){
                this.showToastMsg('Duplicate Address', 'Entered address already exists in DB.!', 'warning');
                
            }else{

                createLocation_JS({
                    actId:this.accidf,street:addressData.street,city:addressData.city,province:addressData.province,
                    country:addressData.country,postalcode:addressData.postalcode,county:this.countyValue
                    })
                    .then(result => {
                        let adr = JSON.parse(JSON.stringify(result));
                        console.log('adr--- ', adr);
                        var tst = [];
                        var locLen = this.asoLocationList.length;
                        var sType = 'Other';
                        if(locLen == 0) {
                            sType = 'Primary';
                        }
                        adr.forEach(item => {
                            let newRec = {
                                Id : item.ascId,
                                visitorId__c : item.addresId,
                                LocationId : item.locationId,
                                Type : item.type,
                                Status__c : item.status,
                                ParentRecordId : item.parentRecordId,
                                Address__c : item.address,
                                AssociatedLocationNumber : ''              
                            }
                            //item.addresId 
                            //this.asoLocationList.push(newRec);
                            this.orgData.push(newRec.visitorId__c);                                    
                            try {                                        
                                for(var i = 0; i <= this.asoLocationList.length - 1; i++){
                                    tst.push(this.asoLocationList[i]);                           
                                }
                                tst.push(newRec);
                            console.log('New Creation== ',this.existingAddress.length);
                            let newAddress = (addressData.street.trim() +','+ addressData.city.trim()  +','+ addressData.province.trim() +','+ addressData.postalcode.trim()).toLowerCase().trim();
                            this.existingAddress.push(newAddress);
                            console.log('New Creation2== ',this.existingAddress.length);                                           
                            }catch{
                                console.log('error------------  ', error);
                            }
                        });
                        
                        //refreshApex(this.asoLocationList);
                        this.asoLocationList = tst;
                        this.showToastMsg('Address Creation', 'Record Inserted Successfully.!', 'success');
                        this.showCreation = false;
                        this.addressVerification=true;
                        this.enteredAddressFlag = false;
                        this.recomendedAddressFlag = false;
                        this.clearData();
                        //flag = false;
                        console.log(this.asoLocationList.length, ' --size == asoLocationList Data After--- ', JSON.stringify(this.asoLocationList));
                    }) .catch(error => {
                        console.log('error--------> ',error);
                    });
            }
        }
        console.log('flag-- ',this.showCreation);
        this.showCreation = flag;
    }

    // Shahid 18-10-2022 County  
    @wire(getObjectInfo, { objectApiName: Address_OBJECT })
    addressMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$addressMetadata.data.defaultRecordTypeId',  
            fieldApiName: County_FIELD
        }
    )
    AddressPicklist;

    handleChange2(event){
        this.countyValue = event.detail.value;
        console.log('selectedData--> ',this.countyValue);
    }

    // get countyList() {
    //     return [
    //         { label: 'Alameda', value: 'Alameda' },
	// 		{ label: 'Alpine', value: 'Alpine' },
    //         { label: 'Amador', value: 'Amador' },
    //         { label: 'Butte', value: 'Butte' },
    //         { label: 'Calaveras', value: 'Calaveras' },
    //         { label: 'Colusa', value: 'Colusa' },
    //         { label: 'Contra Costa', value: 'Contra Costa' },
	// 		{ label: 'Del Norte', value: 'Del Norte' },
	// 		{ label: 'El Dorado', value: 'El Dorado' },
    //         { label: 'Fresno', value: 'Fresno' },
    //         { label: 'Glenn', value: 'Glenn' },
    //         { label: 'Humboldt', value: 'Humboldt' },
    //         { label: 'Imperial', value: 'Imperial' },
    //         { label: 'Inyo', value: 'Inyo' },
	// 		{ label: 'Kern', value: 'Kern' },
	// 		{ label: 'Kings', value: 'Kings' },
    //         { label: 'Lake', value: 'Lake' },
    //         { label: 'Lassen', value: 'Lassen' },
    //         { label: 'Los Angeles', value: 'Los Angeles' },
    //         { label: 'Madera', value: 'Madera' },
    //         { label: 'Marin', value: 'Marin' },
	// 		{ label: 'Mariposa', value: 'Mariposa' },
	// 		{ label: 'Mendocino', value: 'Mendocino' },
    //         { label: 'Merced', value: 'Merced' },
    //         { label: 'Modoc', value: 'Modoc' },
    //         { label: 'Mono', value: 'Mono' },
    //         { label: 'Monterey', value: 'Monterey' },
    //         { label: 'Napa', value: 'Napa' },
	// 		{ label: 'Nevada', value: 'Nevada' },
	// 		{ label: 'Orange', value: 'Orange' },
    //         { label: 'Placer', value: 'Placer' },
    //         { label: 'Plumas', value: 'Plumas' },
    //         { label: 'Riverside', value: 'Riverside' },
    //         { label: 'Sacramento', value: 'Sacramento' },
    //         { label: 'San Benito', value: 'San Benito' },
	// 		{ label: 'San Bernardino', value: 'San Bernardino' },
	// 		{ label: 'San Diego', value: 'San Diego' },
    //         { label: 'San Francisco', value: 'San Francisco' },
    //         { label: 'San Joaquin', value: 'San Joaquin' },
    //         { label: 'San Luis Obispo', value: 'San Luis Obispo' },
    //         { label: 'San Mateo', value: 'San Mateo' },
    //         { label: 'Santa Barbara', value: 'Santa Barbara' },
	// 		{ label: 'Santa Clara', value: 'Santa Clara' },
	// 		{ label: 'Santa Cruz', value: 'Santa Cruz' },
    //         { label: 'Shasta', value: 'Shasta' },
    //         { label: 'Sierra', value: 'Sierra' },
    //         { label: 'Siskiyou', value: 'Siskiyou' },
    //         { label: 'Solano', value: 'Solano' },
    //         { label: 'Sonoma', value: 'Sonoma' },
	// 		{ label: 'Stanislaus', value: 'Stanislaus' },
	// 		{ label: 'Sutter', value: 'Sutter' },
    //         { label: 'Tehama', value: 'Tehama' },
    //         { label: 'Trinity', value: 'Trinity' },
    //         { label: 'Tulare', value: 'Tulare' },
    //         { label: 'Tuolumne', value: 'Tuolumne' },
    //         { label: 'Ventura', value: 'Ventura' },
	// 		{ label: 'Yolo', value: 'Yolo' },
    //         { label: 'Yuba', value: 'Yuba' },
    //     ];	
    // }

	
}