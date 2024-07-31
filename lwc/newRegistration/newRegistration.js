import { LightningElement, track,wire, api } from 'lwc';
import getPortalUsrActId_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActId';
import getPortalUsrActRecType_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActRecType';
import createNewAccountRecord_ from '@salesforce/apex/NewAgencyController.createNewAccountRecord';


export default class NewRegistration extends LightningElement {
    @api recordId; 
    @api originalAccid;
    @api acctRecType;
    @api acctName;
    @api isNewRegistration=false;
    @api newRegAccId;
   

connectedCallback() {
    //this.isNewRegistration=true;
    //console.log('New Reg Form => ',this.isNewRegistration);
    /*
    createNewAccountRecord_()
            .then(result => {
                this.newRegAccId=result;
             }) .catch(error => {
                    console.log('error createNewAccountRecord_ --------> ',error);
                });
                */
}  

@wire(getPortalUsrActId_js)
        wirePortalUsrActId({error, data}){
            console.log('getPortalUsrActId_js Data at First time in renew Reg****', data);
            if(data){
            this.recordId= data;
            this.originalAccid= this.recordId; 
            console.log('getPortalUsrActId_js Data in renew Reg****', this.originalAccid);
            getPortalUsrActRecType_js({accId:this.originalAccid})
                .then(result => {
                    this.acctRecType = result.accRecType;
                    this.acctName = result.accName;
                    console.log('this.acctRecType -> ', this.acctRecType);
                    if(this.acctRecType !== 'RSA' ||  this.acctName ==='Agents'){
                        this.isNewRegistration=true;
                    }else{
                        this.isNewRegistration=false;
                    }
                    console.log('New Reg Form =>2 ',this.isNewRegistration);
                }) .catch(error => {      
                    console.log('error   this.acctRecType  --------> ',error);
                });
            }
            else if (error) {
                   console.log('(error getPortalUsrActId_js****---> ' + JSON.stringify(error));
            }
    }
}