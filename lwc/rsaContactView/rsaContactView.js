import { api, LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateContactRec from '@salesforce/apex/RSAContactViewCtrl.updateContact';

export default class RsaContactView extends LightningElement {
    @api recordId;
    // @track changeMode ="Edit";

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        fields.Id = this.recordId; // modify a field
        console.log('fields--', JSON.parse(JSON.stringify(fields)));
        //this.template.querySelector('lightning-record-form').submit(fields);
        updateContactRec({ contactStr: JSON.stringify(fields) })
            .then((result) => {
                console.log(result);
                // Refresh Account Detail Page
                // eval("$A.get('e.force:refreshView').fire();");
                const evt = new ShowToastEvent({
                    title: 'Update',
                    message: 'Contact updated successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                window.location.reload();
                //this.template.querySelector('lightning-record-form').changeMode ="view";
            })
            .catch((error) => {
                console.log(error);
            });
    }

}