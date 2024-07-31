import { LightningElement,wire,track,api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import { NavigationMixin } from 'lightning/navigation';
import pubsub from 'c/pubsub';
export default class RedirectToContactPage extends NavigationMixin(LightningElement) {
    
    @track contactId;
    @track contactRecId;
    
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user({data,error}){
        if(data){
            //console.log('this.contactId---',this.contactId);
            this.contactId = getFieldValue(data, CONTACT_ID);
            console.log('this.contactId---',this.contactId);
            
            let message = {
                contactId: this.contactId
            }
            pubsub.fire('simplevt', message);
            
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.contactId,
                    objectApiName: 'Contact',
                    actionName: 'view'
                },
            });
        }
        if(error){
            console.log('error---',error);
        }
    }
   
}