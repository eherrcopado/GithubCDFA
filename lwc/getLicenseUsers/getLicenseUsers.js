import { LightningElement, track, wire, api } from 'lwc';
import getPortalUsrActId_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActId'
import getLicenseUsersInfo_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getLicenseUsersInfo';
import createPaymentRequest_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.createPaymentRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from "lightning/navigation";

export default class GetLicenseUsers extends NavigationMixin(LightningElement) {
    @api recordId;
    @track UsersinfoWrappers;
    @track UsersinfoWrappers_map = [];
    @track reqItemsIDMap = [];
    @track totalAmount;
    @track isModalOpen = false;
    @track showFirstCard = true;

    @track selectedRecordBoolean = false;
    @track lstSelectedRecords;
    @track selectedRecords;
    @track selectedRecord;
    @track error;
    @track cmpURL='';

    @track total = 0;
    @track formattedTotal = 0;
    // Prepared Columns to Display in DatTable
    @track columns = [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'Status', fieldName: 'status', type: 'text'},
        { label: 'Amount', fieldName: 'amount', type: 'currency', typeAttributes: { currencyCode: 'USD'} }
    ];

    @api paymtURL;
    rslt;
    error; 

    connectedCallback(){
        this.showFirstCard = true;
    }

    renderedCallback(){    }


    /* Description : wire method to get logged in user's account record Id and assign to recordId */
    @wire(getPortalUsrActId_js)
        wirePortalUsrActId({error, data}){
            if(data){
            this.recordId= data;
            }
    }


    /* Description : Wire Method to get Users info based on AccountID */
    @wire(getLicenseUsersInfo_js, {accId: '$recordId'})
        WireLicenseUsersInfo_js({error, data}){
        if(data){ 
            for(let key in data){
                this.UsersinfoWrappers_map.push({value:data[key], key:key});
                this.UsersinfoWrappers = data[key];

                // Key Values Converted in Number Format
                let amt = parseFloat(key);

                // Total Amount Converted In currency Format
                this.totalAmount = (amt).toLocaleString('en-US', {style: 'currency',currency: 'USD',});
            }

            this.error = undefined;
        }else{
            this.error = error;
            this.UsersinfoWrappers = undefined;
        }
    }



    //handlePayemnt Block Start
    /* Description : handlePayemnt is used to handle Payment Operation */
    handlePayemnt(){
        var paymentURL;
        let selRecs = this.selectedRecords;
        createPaymentRequest_js({ actId: this.recordId , uiw_ls: this.selectedRecords })
            .then((result) => {
                paymentURL = result;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.navigateToWebPage(paymentURL);
                error  = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.rslt = undefined;
            });
            this.dispatchEvent(new CloseActionScreenEvent());
    }  //EO handlePayemnt function



    // Start navigateToWebPage function 
    /* Description : This Method for navigating the LWC to URL Page in Same Tab */
    @api
    navigateToWebPage(url1) { 
        var pUrl = url1;
        //window.location.replace("http://stackoverflow.com");
        window.open(pUrl, "_top");
        this.handleclick(event);

    } // EO navigateToWebPage function


    // handleNext function Start 
    /* Description : This for Hiding the First DataTable and Showing Second DataTable for Selected Records  */
    handleNext(){
        this.showFirstCard = false;
        this.total = 0;
        this.selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(this.selectedRecords.length === 0){
            this.showErrorToast();
        }
        if(this.selectedRecords.length > 0){
            this.selectedRecordBoolean = true;
            let ids = '';
            this.selectedRecords.forEach(currentItem => {
                this.total = this.total + currentItem.amount;
                ids = ids + ',' + currentItem.Id;
                this.formattedTotal = (this.total).toLocaleString('en-US', {style: 'currency',currency: 'USD',});
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.lstSelectedRecords = JSON.stringify(this.selectedRecords);
        }   
    }// EO handleNext function



    // Error Warning Method function Start
    /* Description : This Method for If 0 Records selected then it will throw the Error */
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Select Atleast One Record..!',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    } //EO showErrorToast function



    // Handle Edit Button Block Start
    /* Description : This Method for back to the first DataTable and Hiding the Second DataTable */
    handleEditItems(){
        this.selectedRecordBoolean = false;
    } //EO handleEditItems function


}