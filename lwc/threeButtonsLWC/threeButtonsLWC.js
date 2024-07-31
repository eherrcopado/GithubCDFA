import { LightningElement, wire, api} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import getPortalUsrActId_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActId';
import getPortalUsrActRecType_js from '@salesforce/apex/PaymentGateway_LWC_Cntrlr.getPortalUsrActRecType';

export default class ThreeButtonsLWC extends NavigationMixin(LightningElement) {
    @api recordId; 
    @api acctRecType;
    @api acctName;
    @api btnlabel= false;


@wire(getPortalUsrActId_js)
        wirePortalUsrActId({error, data}){
            if(data){
            this.recordId= data;
            this.originalAccid= this.recordId; 
            console.log('getPortalUsrActId_js Data in originalAccid', this.originalAccid);
            getPortalUsrActRecType_js({accId:this.originalAccid})
                .then(result => {
                    this.acctRecType = result.accRecType;
                    this.acctName = result.accName;
                    console.log('this.acctRecType -> ', this.acctRecType);
                    if(this.acctRecType  != 'RSA' || this.acctName == 'Agents'){
            //console.log('if recordtype differ from RSA then set label = Current Agency Renewal Status: NEW'); 
                        this.btnlabel= true; 
                        }else{
            //console.log('if recordtype is RSA then set label = Current Agency Renewal Status: RENEWAL'); 
                        this.btnlabel= false;
                    }
                    
                }) .catch(error => {      
                    console.log('error inside this.acctRecType  ====> ',error);
                });
            }
            else if (error) {
                   console.log('(error getPortalUsrActId_js =====> ' + JSON.stringify(error));
            }
    }


//navigateTonewAgencyRegistration
navigateTonewAgencyRegistration() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'New_Registration__c'
            }
        });
}

//navigateToAgencyRenewalForm
    navigateToAgencyRenewalForm() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Registration_Renewal__c'
            }
        });
    }
}