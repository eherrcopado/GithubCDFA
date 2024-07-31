import { api, LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getTaskDetailsByTaskId from '@salesforce/apex/PersonExaminationTaskCntl.getTaskDetailsByTaskId';
import fetchDuplicateContacts from '@salesforce/apex/PersonExaminationTaskCntl.fetchDuplicateContacts';
import reviewTask from '@salesforce/apex/PersonExaminationTaskCntl.reviewTask';

import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation'; ///Navigation


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CONTACT_OBJECT from '@salesforce/schema/Contact';

import FIRST_NAME_FIELD from '@salesforce/schema/Contact.FirstName';
import MIDDLE_NAME_FIELD from '@salesforce/schema/Contact.MiddleName';
import LAST_NAME_FIELD from '@salesforce/schema/Contact.LastName';

import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PHONE_FILED from '@salesforce/schema/Contact.Phone';

import MAILING_STREET_FIELD from '@salesforce/schema/Contact.MailingStreet';
import MAILING_CITY_FIELD from '@salesforce/schema/Contact.MailingCity';
import MAILING_STATE from '@salesforce/schema/Contact.MailingState';
import MAILING_POSTAL_CODE from '@salesforce/schema/Contact.MailingPostalCode';

import PROOF_OF_IDENTITY_FIELD from '@salesforce/schema/Contact.Proof_Of_Identity__c';
import IDENTITY_NUMBER_FIELD from '@salesforce/schema/Contact.Identity_No__c';

import LICENSE_FROM_DATE_FIELD from '@salesforce/schema/Contact.License_From_Date__c';
import LICENSE_TO_DATE_FIELD from '@salesforce/schema/Contact.License_To_Date__c';
import LICENSE_NUMBER from '@salesforce/schema/Contact.License_No__c';

import EXAM_SCORE_FIELD from '@salesforce/schema/Contact.Exam_Score__c';
import EXAMINATION_TYPE_FIELD from '@salesforce/schema/Contact.Examination_Type__c';

const COLUMNS = [
    { 
        label: 'First Name', fieldName: 'contactIdURL', 
        type: 'url', 
        typeAttributes: { 
            label: { fieldName: 'FirstName' }, 
            target: '_blank' 
        } 
    },
    { label: 'Last Name', fieldName: 'LastName' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'License No.', fieldName: 'License_No__c' },
];

export default class PersonExaminationReviewComp extends LightningElement {
    
    @api objectApiName;
    @api recordId;

    @track task;
    @track duplicateContacts = [];

    columns = COLUMNS;

    @track hasSelectedRows = false;

    @wire(getTaskDetailsByTaskId, { taskId: '$recordId' })
    taskData({ error, data }) {
        if (data) {
            this.task = JSON.parse (data);
            this.error = undefined;
            this.fetchDuplicateContacts ();
        } else if (error) {
            this.error = error;
            console.log ('error :' + error);
        }
    }

    contactObj = {
        objApiName : CONTACT_OBJECT,
        firstName : FIRST_NAME_FIELD,
        middleName : MIDDLE_NAME_FIELD,
        lastName : LAST_NAME_FIELD,
        email : EMAIL_FIELD,
        phone : PHONE_FILED,
        mailingStreet : MAILING_STREET_FIELD,
        mailingCity : MAILING_CITY_FIELD,
        mailingState : MAILING_STATE,
        mailingPostalCode : MAILING_POSTAL_CODE,
        proofOfIdentity : PROOF_OF_IDENTITY_FIELD,
        identityNumber : IDENTITY_NUMBER_FIELD,
        licenseFrom : LICENSE_FROM_DATE_FIELD,
        licenseTo : LICENSE_TO_DATE_FIELD,
        licenseNumber : LICENSE_NUMBER,
        examScore : EXAM_SCORE_FIELD,
        examType : EXAMINATION_TYPE_FIELD
    };

    get whoId() {
        return this.task.WhoId;
    }

    get hasSelectedRows () {
        const el = this.template.querySelector('lightning-datatable');
        return el && el.selectedRows && el.selectedRows.length > 0;
    }

    get reviewButtonName () {
        return this.hasSelectedRows ? 'Complete review with Update' : 'Complete review';
    }

    handleRowSelection = event => {
        let selectedRows = event.detail.selectedRows;
        if(selectedRows.length>1)
        {
            const el = this.template.querySelector('lightning-datatable');

            if(selectedRows.length == this.duplicateContacts.length){
                selectedRows = el.selectedRows = [];
            }else{
                selectedRows = el.selectedRows = el.selectedRows.slice(1);
            }

            event.preventDefault();
        }

        this.hasSelectedRows = selectedRows && selectedRows.length > 0;
        return;
    }
    fetchDuplicateContacts () {
        fetchDuplicateContacts ({contactId : this.whoId})
        .then (result => {
            console.log ('result :' + result);
            let tempDuplicateContacts = [];
            //add each row data in array using for loop
            JSON.parse (result).forEach(eachContact => {
                let contactRow = {...eachContact, contactIdURL : '/' + eachContact.Id};
                tempDuplicateContacts.push(contactRow);
            });
            this.duplicateContacts = tempDuplicateContacts;

        })
        .catch (error => {
            console.log ('error :' + error);
        })
    }

    handleCancel(event) {
        //this.dispatchEvent(new CloseActionScreenEvent());
        const closequickActionEvent = new CustomEvent("closequickAction");
        this.dispatchEvent(closequickActionEvent);
    }

    handleSubmit(e) {
        let selectedContact;

        const lightningTable = this.template.querySelector('lightning-datatable');
        if (lightningTable && lightningTable.selectedRows && lightningTable.selectedRows.length > 0) {
            selectedContact = lightningTable.selectedRows [0];
        }

        reviewTask ({
            taskId : this.recordId,
            selectedContactId :  selectedContact
        }).then (result => {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated!',
                    variant: 'success'
                })
            );

            // Close the modal window and display a success toast
            // this.dispatchEvent(new CloseActionScreenEvent());
            const closequickActionEvent = new CustomEvent("closequickAction");
            this.dispatchEvent(closequickActionEvent);
        }).catch (error => {
            console.log ('error :' + error );
            console.log ('error :' + JSON.stringify (error) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Record updated failed ' + JSON.stringify (error),
                    variant: 'error'
                })
            );
        });
    }
}