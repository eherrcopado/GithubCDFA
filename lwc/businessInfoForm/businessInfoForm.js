import { LightningElement,wire,track,api } from 'lwc';
import getRenewalPaid_js from '@salesforce/apex/ContactsLwcController.getRenewalPaid';
import getPaidStatus_js from '@salesforce/apex/ContactsLwcController.getPaidStatus';

//import insertAccountMethod_js from '@salesforce/apex/RenewalRegistrationController.insertOrUpdateAccount';
//import getOwner_js from '@salesforce/apex/RenewalRegistrationController.getPortalOwner';

import accId from '@salesforce/schema/Account.Id';
import accountName from '@salesforce/schema/Account.Name';
import accPhone from '@salesforce/schema/Account.Phone';
import accEmail from '@salesforce/schema/Account.Email__c';
import accLeg from '@salesforce/schema/Account.Legal_Entity__c';
import accDba from '@salesforce/schema/Account.DBA_Name__c';
import accStreet from '@salesforce/schema/Account.BillingStreet';
import accCity from '@salesforce/schema/Account.BillingCity';
import accState from '@salesforce/schema/Account.BillingState';
import accPostal from '@salesforce/schema/Account.BillingPostalCode';
import accCountry from '@salesforce/schema/Account.BillingCountry';
import accReg from '@salesforce/schema/Account.Renewal_Registration_Number__c';
import owner from '@salesforce/schema/Account.OwnerId';

// Shahid 20-10-2022
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Account_OBJECT from '@salesforce/schema/Account';
import Legal_Entity_FIELD from '@salesforce/schema/Account.Legal_Entity__c';

export default class RenewalRegistration extends LightningElement {
   
   @api portalUserAccount; //renewal acc id
    @api conFname;
    @api conLname;
    @track error;
    @api renewalid;
    @track renewalAccountId;
    
    @api agencyrenwalapproved;
    @track disableControls;
    //@track agencyRenwalApproved;

    //@api newflag=false;
    //@api renewflag=false;
    @api newflag;
    @api renewflag;
    @track enableNewReg=true;
    @track showName=false;

    @track getAccountRecord={
        Id:accId,   
        Name:accountName,       
        Phone:accPhone, 
        Email__c:accEmail,
        Legal_Entity__c:accLeg,         
        DBA_Name__c:accDba,
        BillingStreet:accStreet,
        BillingCity:accCity,
        BillingState:accState,
        BillingPostalCode:accPostal,
        BillingCountry:accCountry,
        Renewal_Registration_Number__c:accReg
    };
    @track LegalEntity;
    @track dbaNameValue;
    
    connectedCallback() {
        console.log('conFName in BInfo', this.conFName);
        console.log('conLName in BInfo==> ', this.conLName);
        console.log(this.portalUserAccount,'portalUserAccount in BInfo==> ',JSON.stringify(this.portalUserAccount) );

        console.log(this.getAccountRecord, 'getAccountRecord In CB==> ', JSON.stringify(this.getAccountRecord));

       this.renewalAccountId = this.renewalid;
        // new Method 0908
           getRenewalPaid_js({renAccId:this.renewalAccountId})
                .then(result => {
                    console.log(result,' result 1-- ',JSON.stringify(result));
                    if(result>0){
                        this.disableControls = true;
                    }
                    //this.agencyRenwalApproved = 0;
                    console.log(this.renewalAccountId, ' -----this.disableControls 1-- ',this.disableControls);
                }) .catch(error => {
                    this.disableControls = false;
                    
                    console.log('error disableControls 2 --------> ',error);
                });
       // new Shahid teacher day

        console.log("businessInfoForm connectedCallback");
        this.getAccountRecord.Id=this.portalUserAccount.Id;
        this.getAccountRecord.Name=this.portalUserAccount.Name;
        this.getAccountRecord.Legal_Entity__c=this.portalUserAccount.Legal_Entity__c;
        this.getAccountRecord.DBA_Name__c=this.portalUserAccount.DBA_Name__c;
        this.getAccountRecord.Phone=this.portalUserAccount.Phone;
        this.getAccountRecord.Email__c=this.portalUserAccount.Email__c;
        this.getAccountRecord.BillingStreet=this.portalUserAccount.BillingStreet;
        console.log("businessInfoForm connectedCallback1",this.getAccountRecord.BillingStreet);
        this.getAccountRecord.BillingCity=this.portalUserAccount.BillingCity;
        this.getAccountRecord.BillingState=this.portalUserAccount.BillingState;
        this.getAccountRecord.BillingCountry=this.portalUserAccount.BillingCountry;
        this.getAccountRecord.BillingPostalCode=this.portalUserAccount.BillingPostalCode;
        this.getAccountRecord.Renewal_Registration_Number__c=this.portalUserAccount.Registration_Number__c;
        this.getAccountRecord.OwnerId=this.portalUserAccount.OwnerId; 

        console.log('shahid portalUserAccount.Phone -->',this.portalUserAccount.Phone);

        console.log(this.portalUserAccount.Legal_Entity__c,' == QualApps== ',this.portalUserAccount.DBA_Name__c);
        this.dbaNameValue = this.portalUserAccount.DBA_Name__c;
        this.LegalEntity = this.portalUserAccount.Legal_Entity__c;
        this.showHideName(this.LegalEntity);
        // Shahid
        /*
       let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
        }else{
            this.disableControls = false;
        }
        console.log('1 this.disableControls value--> ', this.disableControls);
        */
        console.log(this.renewflag ,' Renew && New  ',this.newflag);
        if(this.newflag === true){
            this.enableNewReg = false;
        }else{
            this.enableNewReg=true;
        }
        console.log('enableNewReg--> ',this.enableNewReg);
        
    }
 
  renderedCallback(){
    console.log(this.portalUserAccount,'portalUserAccount in RCB==> ',JSON.stringify(this.portalUserAccount) );
    console.log(this.getAccountRecord, 'getAccountRecord In RCB==> ', JSON.stringify(this.getAccountRecord));
      
    console.log('conFName in BInfo In RCB ', this.conFName);
    console.log('conLName in BInfo==> In RCB ', this.conLName);

    this.getAccountRecord.Id=this.portalUserAccount.Id;
    this.getAccountRecord.Name=this.portalUserAccount.Name;
    this.getAccountRecord.Legal_Entity__c=this.portalUserAccount.Legal_Entity__c;
    this.getAccountRecord.DBA_Name__c=this.portalUserAccount.DBA_Name__c;
    this.getAccountRecord.Phone=this.portalUserAccount.Phone;
    this.getAccountRecord.Email__c=this.portalUserAccount.Email__c;
    this.getAccountRecord.BillingStreet=this.portalUserAccount.BillingStreet;
    console.log("businessInfoForm renderedCallback",this.getAccountRecord.BillingStreet);
    this.getAccountRecord.BillingCity=this.portalUserAccount.BillingCity;
    this.getAccountRecord.BillingState=this.portalUserAccount.BillingState;
    this.getAccountRecord.BillingCountry=this.portalUserAccount.BillingCountry;
    this.getAccountRecord.BillingPostalCode=this.portalUserAccount.BillingPostalCode;
    this.getAccountRecord.Renewal_Registration_Number__c=this.portalUserAccount.Registration_Number__c;
    this.getAccountRecord.OwnerId=this.portalUserAccount.OwnerId;
    console.log('shahid portalUserAccount.Phone in RCB -->',this.portalUserAccount.Phone);

        // Shahid
        let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
        }else{
            this.disableControls = false;
        }
        console.log('2 this.disableControls value--> ', this.disableControls);
    }


   
   
    addressInputChange(event) {
        this.getAccountRecord.BillingStreet = event.target.street;
        this.getAccountRecord.BillingCity = event.target.city;
        this.getAccountRecord.BillingState = event.target.province;
        this.getAccountRecord.BillingCountry = event.target.country;
        this.getAccountRecord.BillingPostalCode = event.target.postalCode;
   } 
  
   onPhoneChange(event) {
        this.getAccountRecord.Phone=event.target.value;
   }

   onEmailChange(event) {
        this.getAccountRecord.Email__c = event.target.value;
   }
 onNameChange(event) {
        this.getAccountRecord.Name = event.target.value;
        console.log('Legal_Entity_Picklist--> ',this.Legal_Entity_Picklist);
        console.log('AccountMetadata--> ',this.AccountMetadata);
   }


    // Shahid 20-10-2022 Legal Entity Start  //Account_OBJECT,Legal_Entity_FIELD
    @wire(getObjectInfo, { objectApiName: Account_OBJECT })
    AccountMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$AccountMetadata.data.defaultRecordTypeId',  
            fieldApiName: Legal_Entity_FIELD
        }
    )
    Legal_Entity_Picklist;

    handleChangeLegalEntity(event){
        this.LegalEntity = event.detail.value;
        this.showHideName(this.LegalEntity);
        // if(this.LegalEntity=='Sole Owner' || this.LegalEntity=='Partnership' || this.LegalEntity=='Limited Partnership'){
        //     console.log('Display first name and Last Name LegalEntity==>');
        //     this.showName=true;
        // }else if(this.LegalEntity== 'Corporation' || this.LegalEntity=='Limited Liability Company'){
        //     console.log('Dont show first name and Last Name LegalEntity==>');
        //     this.showName=false;
        // }
    }
    //Legal Entity End
    
    showHideName(entity){
           if(entity=='Sole Owner' ||entity=='Partnership' || entity=='Limited Partnership'){
            console.log('Display first name and Last Name LegalEntity==>');
            this.showName=true;
        }else if(entity== 'Corporation' || entity=='Limited Liability Company'){
            console.log('Dont show first name and Last Name LegalEntity==>');
            this.showName=false;
        }
    }

    dbaNameChange(event){
        this.dbaNameValue = event.detail.value;
    }

   @api
    getBusinessFormData() {

    console.log(this.getAccountRecord,'  getAccountRecord In RCB ', JSON.stringify(this.getAccountRecord));
    console.log(this.portalUserAccount,'  2 portalUserAccount In RCB ', JSON.stringify(this.portalUserAccount));

        console.log('Shahid Submit');
        console.log('getAccountRecord****',this.getAccountRecord);
        console.log('getAccountRecord.Id****',this.getAccountRecord.Id);
        console.log('getAccountRecord.Phone****',this.getAccountRecord.Phone);
        console.log('getAccountRecord.Email__c****',this.getAccountRecord.Email__c);
        console.log('getAccountRecord.BillingStreet****',this.getAccountRecord.BillingStreet);
        console.log('getAccountRecord.BillingCity****',this.getAccountRecord.BillingCity);
        console.log('getAccountRecord.BillingState****',this.getAccountRecord.BillingState);
        console.log('getAccountRecord.BillingCountry****',this.getAccountRecord.BillingCountry);
        console.log('getAccountRecord.BillingPostalCode****',this.getAccountRecord.BillingPostalCode);
        // if(this.dbaNameValue == undefined || this.dbaNameValue == null){
        //     this.dbaNameValue = '';
        // }
        this.getAccountRecord.Legal_Entity__c = this.LegalEntity;
        this.getAccountRecord.DBA_Name__c = this.dbaNameValue;
        console.log('getAccountRecord.Legal_Entity__c****',this.getAccountRecord.Legal_Entity__c);
        return this.getAccountRecord;
    }

    @api
    updateLegalEntity(){
        let newRec = {
            LegalEntity : this.LegalEntity,
            Id :this.getAccountRecord.Id
        }
        return newRec;
    }
}