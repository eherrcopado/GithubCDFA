import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class RedirectToVFPage extends NavigationMixin (LightningElement) {
    connnetedCallback(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/AgentPDF'
            }
        }).then(generatedUrl => {
            console.log('generatedUrl---',generatedUrl);
            window.open(generatedUrl);
        });
    }
    
}