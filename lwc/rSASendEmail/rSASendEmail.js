import { LightningElement,track } from 'lwc';
import sendEmailData from '@salesforce/apex/RSASendEMailCtrl.sendEmail';
import getEmailRecord from '@salesforce/apex/RSASendEMailCtrl.getEmailRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RSASendEmail extends LightningElement {

    @track toEmail;

    connectedCallback() {
      console.log('connectedCallBack');
      getEmailRecord().then(result=>{
        console.log('result--', result);
        this.toEmail = result.supportEmail.Value__c;
      }).catch(error=>{
        console.log('error--',error);
      });
    }
      
    handleSubject(event) {
      this.subject = event.target.value;
    }
      
    handleBody(event) {
      this.body= event.target.value;
    }
    
    sendEmail(event) {   
      console.log('email-------',this.toEmail);
      console.log('subject-------',this.subject);
      console.log('body-------',this.body);
      // const recordInput = {body: this.body, toEmail: this.toEmail, subject: this.subject} 
      sendEmailData({body :this.body, subject:this.subject})
      .then(response=>{
        this.data = response;
        console.log('data-----',this.data);
        const event = new ShowToastEvent({
          title: 'success',
          message: 'mail send successfully',
          variant:'success'
        });
        this.dispatchEvent(event);
        // this.clearForm();
      })
        .catch(error=>{
          console.log('error--------',error);
        });
    }
}