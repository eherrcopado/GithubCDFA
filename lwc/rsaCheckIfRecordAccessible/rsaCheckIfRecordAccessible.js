import { LightningElement, wire, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import checkIfRecordFromSameAccount from '@salesforce/apex/RSACheckIfRecordAccessCtrl.checkIfRecordFromSameAccount';
export default class RsaCheckIfRecordAccessible extends NavigationMixin(LightningElement) {

    @api recordId;
    @track isRecordVisible = true;
    
    @wire(checkIfRecordFromSameAccount, {recordId:'$recordId'})
    checkRecAccess ({error, data}) {
        console.log('error---', error);
        console.log('error---', data);
        if(data ==  undefined) return;
        
        if (error) {
            // TODO: Error handling
        } else if (data) {
            this.isRecordVisible = true;
        } else {
            this.isRecordVisible = false;
        }
        if(this.isRecordVisible == false) {
            try {
                console.log('redirecting--');
                /*this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'home'
                    },
                });*/
            } catch(e) {
                console.log('--e--', e);
            }
            
        }
    }

    redirectoHome() {
        try {
            /*this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                }
            });*/
            window.location.href = "/";
        } catch(e) {
            console.log('--e---', e);
        }
    }

    

}