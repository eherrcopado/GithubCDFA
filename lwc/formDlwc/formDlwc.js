import { LightningElement,wire,track,api } from 'lwc';
import setFormCData_js from'@salesforce/apex/FormsServiceController.setFormCData';
import getAllTheProductsMaster from '@salesforce/apex/FormsServiceController.getAllTheProductsMaster';
import getExistingAssetsForAnAccount_js from '@salesforce/apex/FormsServiceController.getExistingAssetsForAnAccount';
import getUploadedDocumentsForAnAgency_js from '@salesforce/apex/FormsServiceController.getUploadedDocumentsForAnAgency';
import getRelatedFilesByRecordId_js from '@salesforce/apex/FormsServiceController.getRelatedFilesByRecordId';
import fetchDevices_js from '@salesforce/apex/RenewalAgencyController.getInitialData';
import getPreviewDocUrl_js from '@salesforce/apex/FormsServiceController.getPreviewDocUrl';


import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class FormDlwc extends NavigationMixin (LightningElement) {
    @track measuringDeviceNames='';
    @track weighingDeviceNames='';
    @track productsList;
    @track assetsList=[];
    @track existingMeasuringOptions = [];
    @track existingWeighingOptions = [];
    @track options1 =[];
    @track items = [];
    @track items1 = [];
    @track weighingOptions = [] ;
    @track showWeighingDevices = false;
    @track showMeasuringDevices = false;
    @track existingItems = [];
    @track existingItems1 = [];
    @api   recid ='';
    @track otherWeighingDevicesInfo;
    @track otherMeasuringDevicesInfo;
    @api   accidf;
    @track devicesMCheckboxesSelected = false; 
    @track devicesWCheckboxesSelected = false; 
    @track existingMachines = '';
    @track existingWeighing = '';
    @track uploadedFiles = '';
    @track areFilesUploaded = false;
    @track fileData=false;
    @track filename='';
    @track filesCount=0;

    @api agencyrenwalapproved;
    @track disableControls;
 

    connectedCallback(){
        this.recid = this.accidf;
        //----------------------------------
        getUploadedDocumentsForAnAgency_js({acctId:this.accidf})
            .then(result => {
                //console.log('result-- ', result);
                if(result.length > 0){
                    this.areFilesUploaded = true ;
                }
            this.filesCount= result.length;

            }).catch(error => {
                this.error = error;
            });     

        this.getRelatedFiles();
        //------------------------------
       getAllTheProductsMaster()      
        .then(result => {            
                this.productsList = result;
                var productsListInJSONFormat = JSON.parse(JSON.stringify(this.productsList));        
                for (var i = 0; i < this.productsList.length; i++) {              
                    if(productsListInJSONFormat[i]['Family'] == 'Measuring Devices'){
                        if(productsListInJSONFormat[i]['Name'] != 'Other Measuring Devices'){
                            this.items.push({ label: productsListInJSONFormat[i]['Name'], value: productsListInJSONFormat[i]['Name'] });
                        }
                    } else{
                        if(productsListInJSONFormat[i]['Name'] != 'Other Weighing Devices'){
                            this.items1.push({ label: productsListInJSONFormat[i]['Name'], value: productsListInJSONFormat[i]['Name'] });
                        }
                    }                            
                }                
                this.items.push({ label: 'Other Measuring Devices', value: 'Other Measuring Devices' });   
                this.items1.push({ label: 'Other Weighing Devices', value: 'Other Weighing Devices' });             
                this.options1 = JSON.parse(JSON.stringify(this.items));
                this.weighingOptions = JSON.parse(JSON.stringify(this.items1));                                                                      
        })
        .catch(error => {
            this.error = error;
        })

        getExistingAssetsForAnAccount_js({acctId:this.accidf})
            .then(data => {
                let childData = JSON.parse(JSON.stringify(data));
                if (childData) {
                    if(childData.length>0){                
                        this.assetsList = childData;
                        var assetsListInJSONFormat = JSON.parse(JSON.stringify(this.assetsList));
                       for (var i = 0; i < this.assetsList.length; i++) {
                           if(assetsListInJSONFormat[i]['Device_Type__c'] == 'Measuring'){
                                this.existingItems.push(assetsListInJSONFormat[i]['Name']);
                                this.tempExistingMeasuringDevices = this.tempExistingMeasuringDevices +assetsListInJSONFormat[i]['Name']+',';
                                if(assetsListInJSONFormat[i]['Name'] == 'Other Measuring Devices'){
                                    this.showMeasuringDevices = true;
                                  this.existingMachines = assetsListInJSONFormat[i]['Other_Device_Comments__c'];
                                 //  this.existingMachines = assetsListInJSONFormat[i]['Description'];
                                }                        
                            } else{
                                this.existingItems1.push(assetsListInJSONFormat[i]['Name']);
                                this.tempExistingWeighingDevices = this.tempExistingWeighingDevices + assetsListInJSONFormat[i]['Name']+',';
                                if(assetsListInJSONFormat[i]['Name'] == 'Other Weighing Devices'){
                                    this.showWeighingDevices = true;
                                   this.existingWeighing = assetsListInJSONFormat[i]['Other_Device_Comments__c'];                
                                  //  this.existingWeighing = assetsListInJSONFormat[i]['Description'];
                                }
                            }      
                        }                
                        this.existingMeasuringOptions = JSON.parse(JSON.stringify(this.existingItems));                      
                        this.existingWeighingOptions = JSON.parse(JSON.stringify(this.existingItems1));
                        this.otherMeasuringDevicesInfo = this.existingMachines;
                        this.otherWeighingDevicesInfo =  this.existingWeighing ;
                    }   
                } else if (error) { 
                    console.log('error',error.message);
                    this.error = error;  
                }
            }).catch(error => {
                this.error = error;
            }); 
   
           this.test1();

           // shahid 
           let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
        }else{
            this.disableControls = false;
        }
    }

    renderedCallback(){
        let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
        }else{
            this.disableControls = false;
        }
    }
   
    test1(){
        fetchDevices_js({ AgencyID: this.accidf, sType:'ALLDEVICES' })
            .then(data => {                
                let childData = JSON.parse(JSON.stringify(data));
                //alert(childData.length);                                
            })
            .catch(error => {
              //  alert('error ' + error);
            });       
    }
   
    handleFormInputChange(event){ 
        console.log('Inside handle form Input on D');       
        if( event.target.name == 'Measuring' ){            
            this.otherMeasuringDevicesInfo = event.target.value;    
             console.log('Inside handle form Input Measuring on D=>',this.otherMeasuringDevicesInfo);         
        }        
        else if( event.target.name == 'Weighing' ){
            this.otherWeighingDevicesInfo = event.target.value; 
             console.log('Inside handle form Input Weighing on D=>',this.otherMeasuringDevicesInfo);           
        } 
    }
    
    storeSelectedMeasuringDevices(event){
        this.measuringDeviceNames = event.detail.value;
        this.devicesMCheckboxesSelected = true;
        if(event.detail.value.length > 0){
            for (let i = 0; i < event.detail.value.length; i++) {
                    this._selected = event.detail.value.slice(i,i+1);
                    if(this._selected.toString().trim() === 'Other Measuring Devices'){
                            this.showMeasuringDevices = true;
                    }else{
                            this.showMeasuringDevices = false;
                    } 
            } 
        }else{
            this.showMeasuringDevices = false;
        }
    }

    storeSelectedWeighingDevices(event){
        this.weighingDeviceNames = event.detail.value;
        this.devicesWCheckboxesSelected = true;
        if(event.detail.value.length > 0){
            for (let i = 0; i < event.detail.value.length; i++) {
                    this._selected = event.detail.value.slice(i,i+1);
                    if(this._selected.toString().trim() === 'Other Weighing Devices'){
                           this.showWeighingDevices = true;
                    } else{
                            this.showWeighingDevices = false;
                    }
                } 
        }else{
            this.showWeighingDevices = false;
        }
    }
    
    @track nothingSelected = false;
    @api saveRecord(){
        if(this.disableControls == false){
            if(((this.devicesMCheckboxesSelected == true && this.measuringDeviceNames.length == 0) && 
            (this.devicesWCheckboxesSelected== true && this.weighingDeviceNames.length == 0)) || 
            (this.showWeighingDevices == true && this.otherWeighingDevicesInfo.length == 0) || 
            (this.showMeasuringDevices == true && this.otherMeasuringDevicesInfo.length == 0)){
            
                if((this.showWeighingDevices == true && this.otherWeighingDevicesInfo.length == 0) || (this.showMeasuringDevices == true && this.otherMeasuringDevicesInfo.length == 0)){
                    const evt = new ShowToastEvent({
                        title: 'Alert',
                        message: 'When selecting Other, you must describe your other device(s)',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                this.dispatchEvent(evt);
                this.nothingSelected = true;
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Alert',
                        message: 'Select atleast one device',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                this.dispatchEvent(evt);
                this.nothingSelected = true;
                }
            }
            else if(this.areFilesUploaded == false){
                const evt = new ShowToastEvent({
                    title: 'Alert',
                    message: 'Please upload a file',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.nothingSelected = true;
                
            }else{
                this.nothingSelected = false;
                setFormCData_js({measuringDevicesNames:this.measuringDeviceNames,weighingDevicesNames:this.weighingDeviceNames,otherWeighingDeviceInfo:this.otherWeighingDevicesInfo,otherMeasuringDevicesInfo:this.otherMeasuringDevicesInfo,acctId:this.accidf})
                .then(result => {
                    //alert('success');
            }) .catch(error => {
                //alert(' <----error---> '+ error.body.message);
            });
            }
        }else{
            this.nothingSelected = false;
        }
        return this.nothingSelected;
    }

    value = ['Other Measuring Devices'];
    selectValue = '';
        get options() {
            return [
                { label: 'Other Measuring Devices', value: 'MeasuringDevices' }
            ];
        }
        get selectedValues() {
            return this.value.join(',');
        }  
        getOthersCheckSelectedStatus(e) {                
          //  alert("checkbox selected :"+e.target.checked);
            if(e.target.checked){
            this.mandatedActivityNotes = [this.template.querySelector("lightning-textarea").value];
               // alert('using if condition selected labels => ' + this.mandatedActivityNotes);
            }
        } 
    
        get acceptedFormats() {
            //return ['.pdf','.jpeg','.png'];
        }

        handleUploadFinished(event) {
            const uploadedFiles = event.detail.files;
            this.areFilesUploaded = true;
             
        let uploadedFileNames = '';
        let fileCount = 0;
        let count = 0 ;
        count = uploadedFileNames.length;
        count = count-1;
        //alert('total count  '+count );
        for(let i = 0; i < uploadedFiles.length; i++) {
            if(i != count){ 
                uploadedFileNames += uploadedFiles[i].name + ', ';
            }else{
                 uploadedFileNames += uploadedFiles[i].name;
            }
            fileCount = fileCount +1 ;           
        }
        this.fileData = true;
        this.filename = uploadedFileNames;
        this.filesCount = fileCount ;
       
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
                mode: 'dismissable'
            }),
        );
        this.getRelatedFiles();
    }
    @api orgaccid;
  
    @track filesList =[];
    /*
    @wire(getRelatedFilesByRecordId_js, {recordId: '$recid'})
    wiredResult({data, error}){ 
        console.log('getRelatedFilesByRecordId_js data11==>',data);
        if(data){ 
            console.log('getRelatedFilesByRecordId_js==>',data);
            this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
             //"url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log('this.filesList==>',this.filesList);
        }
        if(error){ 
            console.log('getRelatedFilesByRecordId_js error=>',error);
        }
    }*/

   getRelatedFiles(){
    getRelatedFilesByRecordId_js({recordId: this.recid})
            .then(result => {
            console.log('getRelatedFilesByRecordId_js==>',result);
                this.filesList = Object.keys(result).map(item=>({"label":result[item],
                "value": item,
                //"url":`/sfc/servlet.shepherd/document/download/${item}`
                }))
                console.log('this.filesList==>',this.filesList);
            }) .catch(error => {
                console.log('getRelatedFilesByRecordId_js error=>',error);
            });
    }



    @api docRecId='';
    @track docPublicUrl='';
    previewHandler(event){
        console.log('previewHandler .dataset.id=>',event.target.dataset.id);
        //alert('in preview');
        getPreviewDocUrl_js({contentDocId:event.target.dataset.id})
        .then(result => {
            console.log('getPreviewDocUrl_js result',result);
           this.docPublicUrl=result;
                this[NavigationMixin.Navigate]({
                type:'standard__webPage',
                attributes:{ 
                    url: this.docPublicUrl
                },    
                })

        }) .catch(error => {
            console.log('error--------> ',error);
        });

    }

    handleFileDelete(event){
    this.docRecId = event.target.dataset.id;
    console.log('recordId# ' + this.docRecId);

     deleteRecord(this.docRecId)  
     .then(() =>{
         this.dispatchEvent(toastEvent);
         const toastEvent = new ShowToastEvent({
            title:'Record Deleted',
            message:'Record deleted successfully',
            variant:'success',
        })
       
      this.getRelatedFiles(); 
      console.log('before error in deleteREcord');
     }).catch(error => {
               
                console.log('in error deleteREcord--------> ',error);
                this.getRelatedFiles(); 
                //return refreshApex(this.filesList);
            });
           
    
}

    }