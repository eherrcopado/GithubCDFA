import { LightningElement, track,api,wire } from 'lwc';
import getContacts_JS from '@salesforce/apex/ContactsLwcController.getContacts';
import fetchLookupData from '@salesforce/apex/ContactsLwcController.fetchLookupData';
import agentDML_JS from '@salesforce/apex/ContactsLwcController.addAgent';
import removeAgent_JS from '@salesforce/apex/ContactsLwcController.removeAgent';
import checkPrimaryContact_JS from '@salesforce/apex/ContactsLwcController.checkPrimaryContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const DELAY = 300; // dealy apex callout timing in miliseconds
import { refreshApex } from '@salesforce/apex';

export default class AddAgentsForm extends LightningElement {
    @track disableRemove = false;
    @track keyIndex = 0;
    @track agentList = []; 
    @track index = 0;
    @track recId;
    @track conName;
    @api recordId;
    @api accidf;
    isLoaded = false;
    error;
    @track recMap = new Map();
    @track recordsArray = [];
    @track getCons = [];

    // lookup prty
    @api label = 'custom lookup label';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:contact';
    @api sObjectApiName = 'contact';
    @api defaultRecordId = '';
    @api createRecord  = false;

    @track initalData = [];
    @track nothingSelected = false;

    @track oldRecMap = new Map();
    @track allDataMap = new Map();
    @track orgData = [];
    @track newData = [];

    @api agencyrenwalapproved;
    @track disableControls;

    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    selectedRecord = {}; // to store selected lookup record in object formate 

    connectedCallback(){

        let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = false;
            console.log('this.disableControls --> ',this.disableControls);
        }else{
            this.disableControls = true;
            console.log('this.disableControls --> ',this.disableControls);
        }

        let acid = this.accidf;
        console.log('before size--- ', this.oldRecMap.size);
        getContacts_JS({accId:acid})
            .then(result => {
                let childData = JSON.parse(JSON.stringify(result));
                childData.forEach(oCon => {
                    let newRec = {
                        conId : oCon.Id,
                        Name : oCon.Name,
                        License_No__c : oCon.License_No__c,
                        accontId : this.accidf                    
                    }
                    this.agentList.push(newRec);
                    console.log('newRec--- ', newRec);
                    this.orgData.push(newRec.conId);
                });
                 console.log(typeof(JSON.stringify(this.orgData)),'  orgData--- ', JSON.stringify(this.orgData));

                if(this.agentList.length <= 1){
                    this.disableRemove = true;
                }else{
                    this.disableRemove = false;
                }
                 // Refresh Data Without Refreshing the Whole Page
                return refreshApex(this.agentList);
            }) .catch(error => {
                console.log(error);
                this.error = error;
                console.log('error--------> '.error);
            });
            console.log('array Size--- in CCB', this.agentList.length);           
    }

    renderedCallback(){  
        let agencyrenwalapproved2 = this.agencyrenwalapproved;
        if(agencyrenwalapproved2 > 0){
            this.disableControls = true;
            this.disableRemove = true
        }else{
            this.disableControls = false;
            if(this.agentList.length <= 1){
                this.disableRemove = true;
            }else{
                this.disableRemove = false;
            }
        }  
    }

    // lookup js Starts shahid afreed

    @wire(fetchLookupData, { searchKey: '$searchKey' , sObjectApiName : '$sObjectApiName' })
      searchResult(value) {
         const { data, error } = value; // destructure the provisioned value
         this.isSearchLoading = false;
         if (data) {
              this.hasRecords = data.length == 0 ? false : true; 
              this.lstResult = JSON.parse(JSON.stringify(data)); 
          }
         else if (error) {
             console.log('(error---> ' + JSON.stringify(error));
          }
     };
        
   // update searchKey property on input field change  
     handleKeyChange(event) {
         // Debouncing this method: Do not update the reactive property as long as this function is
         // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
         this.isSearchLoading = true;
         window.clearTimeout(this.delayTimeout);
         const searchKey = event.target.value;
         this.delayTimeout = setTimeout(() => {
         this.searchKey = searchKey;
         }, DELAY);
         console.log('this.searchKey--> ', this.searchKey);
     }
     // method to toggle lookup result section on UI 
     toggleResult(event){
         const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
         const clsList = lookupInputContainer.classList;
         const whichEvent = event.target.getAttribute('data-source');
         switch(whichEvent) {
             case 'searchInputField':
                 clsList.add('slds-is-open');
                break;
             case 'lookupContainer':
                 clsList.remove('slds-is-open');    
             break;                    
            }
     }
    // method to clear selected lookup record  
    handleRemove(){
        try{
            console.log('enter--- ');
            this.searchKey = '';    
            this.selectedRecord = {};

            const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
            searchBoxWrapper.classList.remove('slds-hide');
            searchBoxWrapper.classList.add('slds-show');
            const pillDiv = this.template.querySelector('.pillDiv');
            pillDiv.classList.remove('slds-show');
            pillDiv.classList.add('slds-hide');
        }catch(error){
            console.log('err--- ',error);
        }
    
   }
   // method to update selected record from search result 
 handelSelectedRecord(event){
     
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        console.log('selected Record event---> ',event.detail);
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list
        //let childData = JSON.parse(JSON.stringify(this.selectedRecord));
       // alert(childData);
       
      this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI

 }
 /*COMMON HELPER METHOD STARTED*/
 handelSelectRecordHelper(){
     this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
      const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
      searchBoxWrapper.classList.remove('slds-show');
      searchBoxWrapper.classList.add('slds-hide');
      const pillDiv = this.template.querySelector('.pillDiv');
      pillDiv.classList.remove('slds-hide');
      pillDiv.classList.add('slds-show');     
 }

 // lookup JS End

    addAgent(){
        console.log('before array Size--- in addAgent', this.agentList.length);
        
        let arrsize = Object.keys(this.selectedRecord).length;
        console.log('size =======', arrsize);

        if(!(arrsize>0)){
            //this.showEmptySelection();
            this.showToastMsg('Record Not Selected.','Please Select The Agent...', 'error' );
        }else{
            let selectedRecId = this.selectedRecord.Id;//alert('selectedRecId --> '+selectedRecId);
            const myVal = this.agentList.filter( x => x.conId === selectedRecId);

            if(myVal.length === 0){
                let childData = JSON.parse(JSON.stringify(this.selectedRecord));
                    console.log('childData------ ',childData); 
                    try{            
                        let newRec = {
                            conId : childData.Id,
                            Name : childData.Name,
                            License_No__c : childData.License_No__c,
                            accontId : this.accidf
                        }            
                        this.agentList.push(newRec);
                        this.handleRemove();
                        // Refresh Data Without Refreshing the Whole Page
                            return refreshApex(this.agentList);
                    }catch(error) {
                        console.log('error------------  ',error);
                    }
                
            }else{
                    //this.showToastDuplicate();
                    this.showToastMsg('Duplicate Agent Found.','You are Inserting Duplicate Agents..!', 'error' );
                }
                
            }
        console.log('Afetr array Size--- in addAgent', this.agentList.length);
        this.handleRemove();
        addAgentArray=[];       
    }

    removeRow(event){
        var rowIndex = parseInt(event.currentTarget.dataset.id);
        let rValue = this.agentList[rowIndex];
        let conId = JSON.stringify(rValue.conId).split('"').join('');
        let acnId = JSON.stringify(rValue.accontId).split('"').join('');
        console.log(conId,' <--- conId---------acnId---> ', acnId);

        console.log('rowIndex--> '+rowIndex);
        this.isLoaded = true;
       // var selectedRow = event.currentTarget;
       // var key = selectedRow.dataset.id;

        let key = String(rowIndex)
        //console.log(typeof(rowIndex),' -------rowIndex--> key----- ',typeof(key), '--kk---', typeof(kk));
        
                            
    checkPrimaryContact_JS({ acnId:acnId , conId:conId })
        .then(result => {
            console.log('result--- ', result);
            if(result === true){
            console.log('if--- ', this.agentList.length);
                //this.showPrimaryAgent();
                // Primary Contact Warning
                this.showToastMsg('Primary Contact.','This is Primary Contact, You Can not remove.', 'warning' );
            }else{
                console.log(key,' -------else--- ', this.agentList.length);
                if(this.agentList.length>0){
                    this.agentList.splice(key, 1);
                    this.index--;
                    this.isLoaded = false;
                }else if(this.agentList.length == 1){
                    this.agentList = [];
                    this.index = 0;
                    this.isLoaded = false;
                }
            }
        }).catch(error => {
            console.log('error--------> ',error);
        });
    
    } 

    @api saveAgents(){

        if(this.disableControls == false){
            if(this.agentList.length != 0){

                this.agentList.forEach(rec => {
                    this.newData.push(rec.conId);
                });
                console.log('this.orgData--> ',JSON.stringify(this.orgData));
                console.log('this.newData--> ',JSON.stringify(this.newData));

                let removeData = this.orgData.filter(conId => this.newData.indexOf(conId) == -1);
                console.log('removeData--> ',removeData);

                let addData = this.newData.filter(conId => this.orgData.indexOf(conId) == -1);
                console.log('addData--> ',addData);
                
                //alert('Shahid to Save the records');
                let nwRec = [];
                this.agentList.forEach(function(acc){
                    nwRec.push(acc.conId);
                });

                const toFindDuplicates = nwRec => nwRec.filter((item, index) => nwRec.indexOf(item) !== index)
                const duplicateElements = toFindDuplicates(nwRec);

                    if(duplicateElements.length>0){
                        console.log('duplicate Found --> ', duplicateElements.length);
                        //this.showToastDuplicate();
                        this.showToastMsg('Duplicate Agent Found.','You are Inserting Duplicate Agents..!', 'error' );
                        this.nothingSelected = true;
                    }else{
                        this.nothingSelected = false;
                        // SO Add Agent Method
                        let aid = this.accidf
                        agentDML_JS({wrapperList:addData, accId:aid})
                        .then(result => {
                            this.agentList = [];
                            
                        }) .catch(error => {
                            console.log(error);
                            this.error = error;
                            console.log('error--------> '.error);
                        });
                        // EO Add Agent Method

                        // SO Remove Agent Method
                        
                        if(removeData.length>0){
                            removeAgent_JS({removeList:removeData, accId:aid})
                            .then(result => {
                                console.log('delete result--------> ', result);
                            }) .catch(error => {
                                this.error = error;
                                console.log('error--------> ', error);
                            });
                        }
                        // EO Remove Agent Method
                    }

                
            }else{
                this.showToastMsg('No Records', 'Select Atleast One Record', 'error');
                this.nothingSelected = true;
            }
        }else{
            this.nothingSelected = false;
        }

        console.log('flag --- ',this.nothingSelected);
        return this.nothingSelected;
    }
   
    // Start Of showToastMsg
    // Description : This method for Show Toast Message
    showToastMsg(Title, Message, Variant) {
        const event = new ShowToastEvent({
            title: Title,
            message: Message,
            variant: Variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    } // End Of showToastMsg
    
}