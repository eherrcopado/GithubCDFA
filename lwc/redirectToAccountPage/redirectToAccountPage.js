import { LightningElement,track,wire,api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Account_ID from "@salesforce/schema/User.Contact.Account.Id";
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
export default class RedirectToAccountPage extends NavigationMixin(LightningElement) {
    @track accountId;
    @track flag =true;
    @api strRecordId;

    @wire(getRecord, { recordId: USER_ID, fields: [Account_ID] })
    user({data,error}){
        if(data){
            //console.log('this.contactId---',this.contactId);
            
            this.accountId = getFieldValue(data, Account_ID);
            this.strRecordId = this.accountId;
            console.log('this.accountId---',this.accountId);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.strRecordId,
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            });
        }
        if(error){
            console.log('error---',error);
        }
    }
}