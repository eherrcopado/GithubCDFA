import { LightningElement,api } from 'lwc';

export default class Model extends LightningElement {
    @api isModalOpen;
    @api recId;
    @api frameurl;
    @api editButton;
    connectedCallback(){
        console.log('connectedCallback');
        console.log('window---',window.parent.location);
    }
    
    closeModal(){
        this.isModalOpen = false;
        const selectedEvent = new CustomEvent('selected', { detail: this.isModalOpen });
        this.dispatchEvent(selectedEvent);
    }
}