import { LightningElement, api, wire, track } from 'lwc'; 
import fetchRecords from '@salesforce/apex/RelatedListController.fetchRecords'; 
import deleteAssociatedRecord from '@salesforce/apex/RelatedListController.deleteAssociatedRecord'; 
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import pubsub from 'c/pubsub';

export default class RelatedList extends NavigationMixin( LightningElement ) { 
 
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
    @api hideViewAll;
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
    @track hasFourField =false;
    @track hasThreeField =false;
    @track hasTwoField = false;
    @track accountComponent =true;
    @api availableActions = [];
    @track openChild =false;
    @track modelopen =false;
    @track url;
    @api showViewAll =false;
    @track  showViewAllButton =false;
    @track showButton =false;
    @track associatedLocationId;
    @track associatedObj=false;
    @track showpopup=false;

    connectedCallback() {
        var listFields = this.fieldsList.split( ',' );
        if(listFields.length ==2){
            this.field1 = listFields[ 0 ].trim();
            this.field2 = listFields[ 1 ].trim();
            this.hasTwoField =true;
        } 
        else if(listFields.length ==3){
            this.field1 = listFields[ 0 ].trim();
            this.field2 = listFields[ 1 ].trim();
            this.field3 = listFields[ 2 ].trim();
            this.hasThreeField =true;
        }
        else if(listFields.length ==4){
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
        console.log('listFields---',listFields.length);
        
    }

    get vals() { 
        console.log( 'this.recordId is ',this.recordId);
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
            if ( data.recordCount >0 ) {
               console.log('count---');
                if ( data.recordCount > 2) {

                    this.titleWithCount = this.strTitle + '(2+)';
                    this.countBool = true;
               
                } else {

                    this.countBool = false;
                    this.titleWithCount = this.strTitle + '(' + data.recordCount + ')';
                    //if(this.objectName == 'RegulatoryTrxnFee' || this.objectName == 'AccountContactRelation'){
                    if(this.objectName == 'RegulatoryTrxnFee' || this.objectName == 'AccountContactRelation' || this.objectName == 'Asset'){ //modified on 26/09
                        this.showViewAllButton =true;
                    }
                }
                
            }else {

                this.countBool = false;
                this.titleWithCount = this.strTitle +'(0)';

            }
            if(this.objectName == 'AssociatedLocation'){
                this.showButton =true;
            }

        }
        if(error) {
            console.log('Error while getting data--', error);
        }

    }

   createNew() {
        if(this.objectName == 'AssociatedLocation'){
            this.openChild =true;
            this.modelopen =true;
            this.url = '/flow/Address_Location_New_Action?recordId='+this.recordId;
            
            
        } else{
            var parentData = this.parentFieldAPIName +'='+this.recordId;
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: this.objectName,
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues:parentData
                }
            });
        }

    }

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
    handleClick(event){
        deleteAssociatedRecord({recordId:this.associatedLocationId}).then(result=>{
            console.log('result--',result);
            window.location.reload();
        }).catch(error=>{
            console.log('error--',error);
        });
    }
    redirectToEditFlow(event){
        this.openChild =true;
        this.modelopen =true;
        this.associatedObj =true;
        this.associatedLocationId = event.target.dataset.id;
        console.log('this.associatedLocationId',this.associatedLocationId);
        this.url = '/flow/Address_Location_New_Action?recordId='+this.associatedLocationId;
    }
    openPopUpScreen(event){
        this.associatedLocationId = event.target.dataset.id;
        this.showpopup=true;
    }
    closeModal(){
        this.showpopup=false;
    }
    handleSelectEvent(event){
        this.openChild =event.detail;
        this.modelopen =event.detail;
        this.associatedLocationId = '';
    }
}