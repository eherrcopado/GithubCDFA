import { LightningElement, track,wire, api } from 'lwc';
import getPortalUsrActId_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActId';
import getPortalUsrActRecType_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActRecType';


export default class RenewRegistration extends LightningElement {
    @api recordId; 
    @api originalAccid;
    @api acctRecType;
    @api acctName;
    @api isRenewRegistration=false;
    @api daysToRenewal;
    @api formAvailableDate;
    @api isRenewalFormAvailable=false;

    isLoading = true;

    connectedCallback() {
        //this.isRenewRegistration=true;
       // console.log('Renew Reg Form => ',this.isRenewRegistration);
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
                    this.daysToRenewal = result.daysToRenewal;
                    this.formAvailableDate = result.formAvailableDate;
                    console.log('formAvailableDate=>',this.formAvailableDate);
                    // if(this.daysToRenewal <= 60){
                    //         this.isRenewalFormAvailable =  true;
                    // }
                    console.log('this.acctRecType -> ', this.acctRecType);
                    if(this.acctRecType==='RSA' && this.acctName !=='Agents'){
                        this.isRenewRegistration=true;
                    }else{
                        this.isRenewRegistration=false;
                    }
                    console.log('Renew Reg Form =>2 ',this.isRenewRegistration);
                    //console.log('isRenewRegistration in Renew -> ', this.isRenewRegistration);
                    this.isLoading = false;
                }) .catch(error => {      
                    this.isLoading = false;
                    console.log('error   this.acctRecType  --------> ',error);
                });
            }
            else if (error) {
                    this.isLoading = false;
                   console.log('(error getPortalUsrActId_js****---> ' + JSON.stringify(error));
            }
    }
}