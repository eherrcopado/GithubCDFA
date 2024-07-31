import { LightningElement,track,wire,api } from 'lwc';
//import Utility from 'c/utility';
import getRecordData from '@salesforce/apex/ApplicationRelatedList.getRecordData';

const columns = [
  //  { label: 'Name', fieldName: 'Name', editable: false },
    // { label: 'Reviewer', fieldName: 'Reviewer__c', editable: true }
   
   { label: 'Project Name', fieldName: 'ProjectURL', editable: false, wrapText: true, type: 'url', sortable: true ,typeAttributes:{
    label: {
        fieldName: 'Name'
    }
} },
    // { label: 'Lead Agency Applicant', fieldName: 'Lead_Agency_Applicant__r', editable: false, wrapText: true },
    // { label: 'Status', fieldName: 'Status__c', editable: false, wrapText: true },
     { label: 'Record Type', fieldName: 'RecordTypeName', editable: false, wrapText: true },
    { label: 'Name', fieldName: 'Name', type: 'text', editable: false, wrapText: true },
    // { label: 'Created By', fieldName: 'CreatedByName', editable: false, wrapText: true },
    // { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', editable: false, wrapText: true, typeAttributes: {  
    //     day: 'numeric',  
    //     month: 'numeric',  
    //     year: 'numeric',  
    //     hour: '2-digit',  
    //     minute: '2-digit',  
    //     hour12: true}

];

export default class accountRelatedList  {
    
   // @api recordId; 
    @track wireExecutor = new Date().getTime() +'';
    columns = columns;
    @api objectApi;
    @track data=[];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
     
    @wire(getRecordData, { wireExecutor:'$wireExecutor', objectApiName: '$objectApi'})
    getData({data, error}){
        if(data){

         console.log('#data :',data.cont);
         console.log('#URL-- :',data.URL);
        // this.data = data.cont;
        let contList = [];
        for (let i = 0; i < data.cont.length; i++) {
            let element = {};
           // element.RecordTypeName = data.cont[i].RecordType.Name;
            element.Name = data.cont[i].Name;
            //element.Lead_Agency_Applicant__r = data.cont[i].Lead_Agency_Applicant__r.Name;
            //element.Status__c = data.cont[i].Status__c;
            //element.Requested_Amount__c ='$ '+data.cont[i].Requested_Amount__c;
            //element.CreatedByName = data.cont[i].CreatedBy.Name;
            //element.CreatedDate = new Date(data.cont[i].CreatedDate);
            //element.ProjectURL = data.URL+data.cont[i].Id;

            contList.push(element);
        }  
        this.data= contList;
      
         }else{
             this.error = error;
             this.data = undefined;
             console.log('#wire error :',this.error);
         }

    }
    sortBy(field, reverse, primer) {
        
        if(field == 'ProjectURL') {
            field = 'Name';
        }
        console.log('field---', field);
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };
              return function (a, b) {
                a = key(a);
                b = key(b);
                return reverse * ((a > b) - (b > a));
            };
        }
    
        onHandleSort(event) {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const cloneData = [...this.data];
            
    
            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
            this.data = cloneData;
            this.sortDirection = sortDirection;
              this.sortedBy = sortedBy;
    }
    
    

}