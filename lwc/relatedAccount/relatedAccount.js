import { LightningElement ,wire,track,api} from 'lwc';
import USER_ID from '@salesforce/user/Id';
//import { getRecord, getFieldValue } from "lightning/uiRecordApi";
//import Account_ID from "@salesforce/schema/User.Contact.Account.Id";
export default class RelatedAccount extends LightningElement {

    connectedCallback() {
        console.log('connected call back');
        window.parent.location.reload();
        //window.parent.location.href = 'https://rsadev-cdfa-dev.cs133.force.com/cdfalpi/';
    }
    
    @track accountId;
    @api openPopup;

    /*@wire(getRecord, { recordId: USER_ID, fields: [Account_ID] })
    user({data,error}){
        if(data){
            console.log('window---',window.parent);
            
            this.accountId = getFieldValue(data, Account_ID);
            //window.open('https://rsadev-cdfa-dev.cs133.force.com/cdfalpi/'+this.accountId,"_self");
            window.parent.location.href = 'https://rsadev-cdfa-dev.cs133.force.com/cdfalpi/'+this.accountId;
            this.openPopup =false;
        }
    }*/
    // connectedCallback(){
    //     window.top.location.reload();
    // }
}