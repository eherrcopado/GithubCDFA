import { LightningElement, track,wire, api } from 'lwc';
import fetchAccRegNo_js from '@salesforce/apex/RenewalAgencyController.getInitialData';
import createRenewalAgency_js from '@salesforce/apex/RenewalAgencyController.createRenewalAgency';
import updateRenewalAgency_js from '@salesforce/apex/RenewalAgencyController.updateRenewalAgency';
import getRenewalPaid_js from '@salesforce/apex/ContactsLwcController.getRenewalPaid';
import getPaidStatus_js from '@salesforce/apex/ContactsLwcController.getPaidStatus';
import updateAgencyRenewalFormStatus_js from '@salesforce/apex/RenewalAgencyController.updateAgencyRenewalFormStatus';
import getPortalUsrActId_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActId';
import agencyPaymentReq_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.agencyPaymentReq';
import CreatePaymentTxn_js from '@salesforce/apex/RegulatoryTxn.CreatePaymentTxn';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import createNewAgency_js from '@salesforce/apex/NewAgencyController.createNewAccountRecord';

import { NavigationMixin } from "lightning/navigation";



export default class Progressindicatorlwc extends LightningElement {
    @api userAccount;
    @api conFName;
    @api conLName;
    @track selectedStep = 'Step1';
    @api recordId; 
    @api agentCount=0;
    @track regiNo;
    @api accid;// Clone Id
    @api originalAccid;
    @track nothingSelectedValue;
    @track nothingSelectedValue2;
    @track agentFlag;
    @track nothingSelectedValue1;
    @api totalAmount;

    @api agencyRenwalApproved = 0;// 1 - disable, 0- enable
    @api agencyRenwalFormF = 0;// 1 - disable, 0- enable
    @track lblsavennext;
    @track lblnext;
    @track disableControls;
    @track disableMakePayment;
    @track nextButtonClicked;
    //@track updatedAccount;

    @api renewProcess;
    @api newProcess;


 /* Description : wire method to get logged in user's account record Id and assign to recordId */
   @wire(getPortalUsrActId_js)
        wirePortalUsrActId({error, data}){
            console.log('getPortalUsrActId_js Data at First time****', data);
            if(data){
            this.recordId= data;
            console.log('this.renewProcess55=>',this.renewProcess);
            if(this.renewProcess==true){
               this.originalAccid= this.recordId;  
            }
            
            console.log('getPortalUsrActId_js Data****', this.originalAccid);
            
           // this.createRenewalAgency(this.originalAccid);
            }
            
            else if (error) {
                
                console.log('(error getPortalUsrActId_js****---> ' + JSON.stringify(error));
            }
    }


     //@wire(fetchAccRegNo_js, { recId: '$recordId'})
     @wire(fetchAccRegNo_js, { AgencyID: '$recordId', sType:'AGNREGNUM' })
     searchResult(value) {
         const { data, error } = value; // destructure the provisioned value
         if (data) {     
             console.log('recordId=>',this.recordId);
              console.log('this.renewProcess77=>',this.renewProcess);
             if(this.renewProcess==true){
               this.originalAccid=data[0].Id; //original acc id  
               this.regiNo=data[0].Registration_Number__c;
            }
             console.log('Accid*****=>',this.originalAccid);
             //console.log('Reg No*****-->',this.regiNo);

            console.log('this.renewProcess  Progressindicatorlwc ==> ',this.renewProcess);

            if(this.renewProcess == true){
                console.log('Renewal Created');
                this.createRenewalAgency(this.originalAccid);
            }
            
            if(this.newProcess == true){
                console.log('New Created');
                this.createNewAgencyCall();//move to save and next button click
                //this.createNewAgency();
            }

         else if (error) {
             console.log('(error---> ' + JSON.stringify(error));
         }
     };
     }



    createNewAgencyCall(){
        createNewAgency_js()
            .then(result => {
                console.log(result,' createNewAgency_js result with cloned id==>',JSON.stringify(result));
                this.accid=result.renewalAccount.Id;
                this.originalAccid=result.renewalAccount.Id;
                this.conFName=result.conFName;
                this.conLName=result.conLName;
                this.userAccount = result.renewalAccount;
                console.log('originalAccid in NewAgency==> ', this.originalAccid);
                console.log('conFName in NewAgency==> ', this.conFName);
                console.log('conLName in NewAgency==> ', this.conLName);
                console.log('userAccount in NewAgency==> ', this.userAccount);
            })
            .catch(error => {
                console.log('(error createNewalAgency' + JSON.stringify(error));
            });
    }
    // EO createNewalAgency



     connectedCallback() {
        this.nextButtonClicked = false;
        console.log('newProcess=> ',this.newProcess);
        console.log('renewProcess=> ',this.renewProcess);

        //console.log('agencyRenwalApproved 3 --> ',this.agencyRenwalApproved);
/*
        // disable ability to navigate to other steps
        const progressSteps = this.template.querySelectorAll('.lightning-progress-step');
        progressSteps.forEach(step => {
            step.addEventListener('click', () => {
                this.selectedStep = 'Step1';
            });
        }); */

        if(this.agencyRenwalApproved > 0){
            this.lblsavennext = 'Next';
            this.disableControls = true;
        }else{
            this.lblsavennext = 'Save and Next';
            this.disableControls = false;
        }
        //this.disableControls = false; //tobe removed
    //agencyRenwalFormF,disableMakePayment
        if(this.agencyRenwalFormF > 0){
            this.disableMakePayment = true;
        }else{
            this.disableMakePayment = false;
        }
     }

    renderedCallback(){
        this.nextButtonClicked = false;

        if(this.agencyRenwalApproved > 0){
            this.lblsavennext = 'Next';
            this.disableControls = true;
        }else{
            this.lblsavennext = 'Save and Next';
            this.disableControls = false;
        }
        //this.disableControls = false; //tobe removed

        if(this.agencyRenwalFormF > 0){
            this.disableMakePayment = true;
        }else{
            this.disableMakePayment = false;
        }
        
     }
     

    // This Method for Renewal Registration Purpose
    createRenewalAgency(pAccId){
         
        console.log('pAccId=>',pAccId);
        createRenewalAgency_js({originalAccountId: pAccId})
            .then(result => {
                console.log('result with cloned id==>',JSON.stringify(result));
               // this.accid=result[0];
               // this.regiNo=result[1];
                //this.originalAccid=pAccId;
                this.accid=result.renewalAccount.Id;
               // this.regiNo=result.renewalAccount.Registration_Number__c; 
                this.regiNo=result.renewalAccount.Renewal_Registration_Number__c; 
                this.originalAccid=pAccId;
                console.log('originalAccid123=====>',this.originalAccid);
                console.log('regiNo1234======>',this.regiNo);
                console.log('accid123======>',this.accid);
                this.userAccount = result.renewalAccount;
                this.conFName = result.conFName;
                this.conLName = result.conLName;
              console.log('userAccount123=====>',this.userAccount);
              console.log('conFName======>',this.conFName);
              console.log('conLName======>',this.conLName);
               // console.log('originalAccid 123=>',this.originalAccid);
             
               
            // new Method 0908
           getRenewalPaid_js({renAccId:this.accid})
                .then(result => {
                    console.log(result,' result 1-- ',JSON.stringify(result));
                    this.agencyRenwalApproved = result;
                    //this.agencyRenwalApproved = 0;
                    console.log(this.accid, ' -----this.agencyRenwalApproved 1-- ',this.agencyRenwalApproved);
                }) .catch(error => {
                    this.agencyRenwalApproved = 0;
                    
                    console.log('error agencyRenwalApproved 2 --------> ',error);
                });
            // Method for Form F Enable & Disable
            getPaidStatus_js({renAccId:this.accid})
                .then(result => {
                    console.log(result,' result 1-- ',JSON.stringify(result));
                    this.agencyRenwalFormF = result;
                   // this.agencyRenwalFormF = 0;
                    console.log('this.agencyRenwalFormF 1-- ',this.agencyRenwalFormF);
                }) .catch(error => {
                    this.agencyRenwalFormF = 0;
                    
                    console.log('error agencyRenwalFormF 2 --------> ',error);
                });


            })
            .catch(error => {
                console.log('(error createRenewalAgency_js' + JSON.stringify(error));
            });
    }


    // This Method for New Registration Purpose



    updateFormADetails(){
            var updatedAccount = this.template.querySelector('c-business-info-form').getBusinessFormData(); 
            if((!updatedAccount.Phone||updatedAccount.Phone=='undefined') || (!updatedAccount.Email__c||updatedAccount.Email__c=='undefined')||
                ((!updatedAccount.BillingStreet||updatedAccount.BillingStreet=='undefined')||(!updatedAccount.BillingCity||updatedAccount.BillingCity=='undefined')
                ||(!updatedAccount.BillingState||updatedAccount.BillingState=='undefined')||(!updatedAccount.BillingPostalCode||updatedAccount.BillingPostalCode=='undefined'))){
                 const evt = new ShowToastEvent({
                     title: "Error",
                     message: "Please enter the required fields in Business Information form",
                     variant: "error",
                 });
                 this.dispatchEvent(evt);
             }else{
                 if(!updatedAccount.Name||updatedAccount.Name=='undefined' ||updatedAccount.Name=='New Agency'){
                 const evt = new ShowToastEvent({
                     title: "Error",
                     message: "Please enter your Business Name correctly.",
                     variant: "error",
                 });
                 this.dispatchEvent(evt);
                 }else{
                 //this.createNewAgencyCall();
                 updateRenewalAgency_js({
                     "Id": updatedAccount.Id,
                     "phone": updatedAccount.Phone,
                     "email": updatedAccount.Email__c,
                     "street": updatedAccount.BillingStreet,
                     "city": updatedAccount.BillingCity,
                     "state": updatedAccount.BillingState,
                     "country": updatedAccount.BillingCountry,
                     "zipcode": updatedAccount.BillingPostalCode,
                     "accName":updatedAccount.Name,
                     "entity":updatedAccount.Legal_Entity__c,
                     "dbaName":updatedAccount.DBA_Name__c})
                 .then(result => {
                     console.log("updateRenewalAgency_js result:::::"+JSON.stringify(result));
                     this.accid = result.Id;
                     console.log("result.Id:::::"+result);
                     //updating current form status picklist value
                     let statusString= 'Form A Completed';
                     console.log('statusString in form A',statusString);
                    this.userAccount = result;
                     this.updAgencyRenFormStatus(statusString);
      
                 })
                 .catch(error => {
                     console.log('(error updateRenewalAgency_js' + JSON.stringify(error));
                 });
                 this.selectedStep = 'Step2'; 
             }
             }
    }

    handleNext() {
        var getselectedStep = this.selectedStep;
        
        if(getselectedStep === 'Step1') {
            console.log('Inside HandleNext=>');
           this.updateFormADetails();
          
        }
        else if(getselectedStep === 'Step2'){
            let statusString= 'Form B Completed';
            this.updAgencyRenFormStatus(statusString);
            this.selectedStep = 'Step3';
        }
        else if(getselectedStep === 'Step3'){
        let statusString= 'Form C Completed';
            this.updAgencyRenFormStatus(statusString);
            this.selectedStep = 'Step4';
        }
        else if(getselectedStep === 'Step4'){
            let statusString= 'Form D Completed';
            this.updAgencyRenFormStatus(statusString);
            this.selectedStep = 'Step5';
        }
        else if(getselectedStep === 'Step5'){
            let statusString= 'Form E Completed';
            this.updAgencyRenFormStatus(statusString);
            this.selectedStep = 'Step6';
        }
    }
 
    handlePrev() {
        var getselectedStep = this.selectedStep;
        if(getselectedStep === 'Step2'){
            if(this.renewProcess == true){
                this.createRenewalAgency(this.originalAccid);
            }
            this.selectedStep = 'Step1';
           
           
        }
        else if(getselectedStep === 'Step3'){
            this.selectedStep = 'Step2';
        }
        else if(getselectedStep === 'Step4'){
            this.selectedStep = 'Step3';
        }
        else if(getselectedStep === 'Step5'){
            this.selectedStep = 'Step4';
           
        }
        else if(getselectedStep === 'Step6'){
            this.selectedStep = 'Step5';
             console.log('Inside 6 step');
        }
    }

    updAgencyRenFormStatus(formStatus){
         //updating current form status picklist value
         console.log('inside updAgencyRenFormStatus  this.originalAccid=>'+ this.originalAccid);
          console.log('inside updAgencyRenFormStatus==>', formStatus);
                     updateAgencyRenewalFormStatus_js({originalAccountId: this.originalAccid, statusValue : formStatus, renewalAccId : this.accid })
                         .then(result=>{

                         })
                         .catch(error=> {
                             console.log('error in updateAgencyRenewalFormStatus_js' + JSON.stringify(error));
                         });

    }

    saveAssociatedLocation(){
        this.agentFlag = this.template.querySelector("c-location-form").saveAssociatedLocation();
        if(this.agentFlag === false){
            this.nextButtonClicked = true;
            this.handleNext();
        }
        
    } 



    saveDevices(){
        this.nothingSelectedValue=this.template.querySelector("c-form-dlwc").saveRecord();
        if(this.nothingSelectedValue === false) //  && this.nothingSelectedValue2 == false
        {
            this.nextButtonClicked = true;
            this.handleNext();
        }
    }      
    
   
    saveAgents(){
        this.agentFlag = this.template.querySelector("c-add-agents-form").saveAgents();
        if(this.agentFlag === false){
            this.nextButtonClicked = true;
            this.handleNext();
        }
        
    }

    saveSecERecord(){
        this.nothingSelectedValue1=this.template.querySelector("c-form-e-section").saveSecERecord();
      if(this.nothingSelectedValue1 === false){
            this.nextButtonClicked = true;
            this.handleNext();
        }
    }

@track penValArr =[];
/* Description:called on click of make Payment button */
    makePaymentClick(){
        let isSignAvailable=false;
        console.log('Make Payment Method');
        //alert('isSignAvailable='+isSignAvailable);
        isSignAvailable = this.template.querySelector("c-form-flwc").saveSignature();
        //alert('isSignAvailable=='+isSignAvailable);
        if(isSignAvailable === true){
         let statusString= 'Form F Completed';
         this.updAgencyRenFormStatus(statusString);  
         this.totalAmount=this.template.querySelector("c-form-flwc").handlePayment();
         console.log('totalAmt-->',this.totalAmount);
        var paymentURL;

        this.penValArr = this.template.querySelector("c-form-flwc").penaltyValues();
        //alert('penValArr=='+this.penValArr);
        try{
             //alert(this.accid);
             CreatePaymentTxn_js({RenewAgencyID:this.accid,  dPenaltyAmount:this.penValArr[0], dPenaltyPercent:this.penValArr[1]});
             //alert('inside CreatePaymentTxn_js');
        }catch{
            console.log('--Error in CreatePaymentTxn method calling--');
        }
       
       
        agencyPaymentReq_js({ actId: this.originalAccid , renAccId: this.accid , totalAmt: this.totalAmount})
            .then((result) => {
                console.log('Inside agencyPaymentReq_js');
                paymentURL = result;
                console.log('Inside agencyPaymentReq_js paymentURL=>',paymentURL);
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('After agencyPaymentReq_js paymentURL');
                this.navigateToWebPage(paymentURL);
                error  = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.rslt = undefined;
            });
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }//EO makePaymentClick

     // Start navigateToWebPage function 
    /* Description : This Method for navigating the LWC to URL Page in Same Tab */
    @api
    navigateToWebPage(url1) { 
        console.log('Inside navigateToWebPage');
        var pUrl = url1;
        //window.location.replace("http://stackoverflow.com");
        window.open(pUrl, "_top");
        this.handleclick(event);

    } // EO navigateToWebPage function
    

    selectStep1() {
        this.selectedStep = 'Step1';
    }
    selectStep2() {
        if(this.nextButtonClicked || this.isSelectStep6 || this.isSelectStep5 || this.isSelectStep4 || this.isSelectStep3)
            this.selectedStep = 'Step2';
        else if(!this.isSelectStep2)
            this.showNoStepSkippingMessage();
    }
    selectStep3() {
        if(this.nextButtonClicked || this.isSelectStep6 || this.isSelectStep5 || this.isSelectStep4)
            this.selectedStep = 'Step3';
        else if(!this.isSelectStep3)
            this.showNoStepSkippingMessage();
    }
    selectStep4() {
        if(this.nextButtonClicked || this.isSelectStep6 || this.isSelectStep5)
            this.selectedStep = 'Step4';
        else if(!this.isSelectStep4)
            this.showNoStepSkippingMessage();
    }
    selectStep5() {
        if(this.nextButtonClicked || this.isSelectStep6)
            this.selectedStep = 'Step5';
        else if(!this.isSelectStep5)
            this.showNoStepSkippingMessage();
    }
    selectStep6() {
        if(this.nextButtonClicked)
            this.selectedStep = 'Step6';
        else if(!this.isSelectStep6)
            this.showNoStepSkippingMessage();
    }
    get isSelectStep1() {
        return this.selectedStep === "Step1";
    }
    get isSelectStep2() {
        return this.selectedStep === "Step2";
    }
    get isSelectStep3() {
        return this.selectedStep === "Step3";
    }
    get isSelectStep4() {
        return this.selectedStep === "Step4";
    }
    get isSelectStep5() {
        return this.selectedStep === "Step5";
    }
    get isSelectStep6() {
        return this.selectedStep === "Step6";
    }
    
    showNoStepSkippingMessage(){
        const evt = new ShowToastEvent({
            title: 'Alert',
            message: 'Please click the "' + this.lblsavennext + '" button to continue to the next step.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}