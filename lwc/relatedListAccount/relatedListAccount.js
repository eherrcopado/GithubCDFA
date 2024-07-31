import { LightningElement, api, wire, track } from 'lwc'; 
import fetchRecords from '@salesforce/apex/RelatedListController.fetchRecords'; 
import { NavigationMixin } from 'lightning/navigation';
import pubsub from 'c/pubsub';
import ACCOUNTID from '@salesforce/schema/AccountContactRelation.AccountId';
import CONTACTID from '@salesforce/schema/AccountContactRelation.ContactId';
import STATUS from '@salesforce/schema/AccountContactRelation.Status__c';
export default class RelatedListAccount extends NavigationMixin(LightningElement) { 

    @api objectName; 
    @api parentObjectName;
    @api fieldName; 
    @api fieldValue; 
    @api parentFieldAPIName; 
    @api recordId; 
    @api strTitle; 
    @api filterType; 
    @api operator; 
    @api fieldsList;
    @api relationshipApiName;
    @track field1;
    @track field2;
    @track field3;
    @track field4;
    @track listRecords;
    @track titleWithCount;
    @track countBool = false;
    @api buttonName ="New";
    @track renderData =false;
    @api hideButton =false;
    @track contactComponent =true;
    @api noteText;
    @track openModel =false;

    
    selectedFields = [ACCOUNTID, CONTACTID, STATUS];
    connectedCallback() {
        var listFields = this.fieldsList.split( ',' );
        console.log( 'Fields are ' + listFields );
        if(listFields.length ==2){
            this.field1 = listFields[ 0 ].trim();
            this.field2 = listFields[ 1 ].trim();
        } else {
            this.field1 = listFields[ 0 ].trim();
            this.field2 = listFields[ 1 ].trim();
            this.field3 = listFields[ 2 ].trim();
            this.field4 = listFields[ 3 ].trim();
            this.hasFourField =true;
        }
        console.log( 'Field 1 is ' + this.field1 );
        console.log( 'Field 2 is ' + this.field2 );
        console.log( 'Field 3 is ' + this.field3 );
        console.log( 'Field 4 is ' + this.field4 );
        

    }

    get vals() { 

        return this.recordId + '-' + this.objectName + '-' +  
               this.parentFieldAPIName + '-' + this.fieldName + '-' +  
               this.fieldValue + '-' + this.filterType + '-' + this.operator + '-' + this.fieldsList; 

    } 
     
    @wire(fetchRecords, { listValues: '$vals' }) 
    accountData( { error, data } ) {

        if ( data ) {
            this.listRecords = data.listRecords;
            this.renderData =true;
            console.log('this.listRecords---',this.listRecords);
            console.log('data.recordCount---',data.recordCount);
            if ( data.recordCount ) {
                this.titleWithCount = this.strTitle + '(1)';
                console.log('this.titleWithCount---',this.titleWithCount);
            
               console.log('count---');
                if ( data.recordCount > 3 ) {

                    this.titleWithCount = this.strTitle + '(3+)';
                    this.countBool = true;
               
                } else {

                    this.countBool = false;
                    this.titleWithCount = this.strTitle + '(' + data.recordCount + ')';

                }
            } else {
                this.titleWithCount = this.strTitle +'(0)';
            }

        }
        if(error) {
            console.log('Error while getting data--', error);
        }

    }

    createNew() {
        try{
            console.log('this.parentFieldAPIName---',this.parentFieldAPIName);
            var parentData = this.parentFieldAPIName +'='+this.recordId;
            console.log('defaultValues---',parentData);
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: this.objectName,
                    actionName: 'new'
                },
                state: {
                    //defaultFieldValues:defaultValues
                  defaultFieldValues:parentData
                }
            });
            const selectedEvent = new CustomEvent('contactselect', { detail: this.recordId});
        }catch(e){
            console.log('error---',e);
        }
    }

    //createNew(){
    //    this.openModel =true;
    //}

    navigateToRelatedList() {
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.parentObjectName,
                relationshipApiName: this.relationshipApiName,
                actionName: 'view'
            }
        });

    }
    closeModal(){
        this.openModel =false;
    }
 
}