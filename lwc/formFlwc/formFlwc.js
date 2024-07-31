import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import updateAgencyApproval_js from '@salesforce/apex/FormESectionController.updateAgencyApproval';
import getRecCount_js from '@salesforce/apex/RenewalAgencyController.getRecCount';
import PenaltyCalculator_js from '@salesforce/apex/PenaltyCalculationHandler.PenaltyCalculator';
import createPenaltyRegFeeItem_js from '@salesforce/apex/RegTranFeeItemCreation.createPenaltyRegFeeItem';

export default class FormFlwc extends LightningElement {
    @api totalplfee;
    @api totalalfee;
    @api totallafee;
    @api grandTotal;
    @api returnGrandTotal;

    @api agentCount;
    @api assoLocCount;
    @api priLocations;
    @api accidf;
    @api orgaccid;

    @track signString;
    @track signature = [];
    @track penalty;
    @track penaltyfee;
    @track renewalTotalAmount;
    @track Total;

    @track pltfee;

    @api agencyrenwalapproved;
    @track disableControls;
    @api agencyrenwalformf;
    @api renewalprocess;

    connectedCallback(){
        console.log('inside connectedcallback');
        this.getAgentandLocationCount();
        console.log('orgaccid--->', this.orgaccid);
        //console.log('accidf--->', this.accidf);
    } //EO connectedCallback

//add createPenalty fun , add createPenaltyRegFeeItem_js imparative call here and then call this function in then of PenaltyCalculator_js
    createPenaltyRFItem(){
    /*
    createPenaltyRegFeeItem_js({accId:this.accidf, penaltyFee:this.pltfee})
        .then(result => {
        console.log('result createPenaltyRFItem Pltfee--------> ',this.pltfee);
                }) .catch(error => {
                    console.log('58 createPenaltyRFItem error--------> ',error);
                });
          */     
        let agencyrenwalformf2 = this.agencyrenwalformf;
        if(agencyrenwalformf2 > 0){
            this.disableControls = true;
            console.log('flag1 ', this.disableControls)
        }else{
            this.disableControls = false;
            console.log('flag2 ', this.disableControls)
        }
    }
  /* Method to calculate fees from agent count and location count*/
    calculatefees(){
        try{       
            if( this.assoLocCount==0){
               this.priLocations=0;   
            }
            else{
                this.priLocations=1; 
                this.assoLocCount=Number(this.assoLocCount) - Number(this.priLocations); 
            }           
            this.totalplfee=(this.priLocations*200).toLocaleString('en-US', {style: 'currency',currency: 'USD',});

            this.totalalfee=Number(this.assoLocCount*100).toLocaleString('en-US', {style: 'currency',currency: 'USD',});
            
            this.totallafee=Number(this.agentCount*25).toLocaleString('en-US', {style: 'currency',currency: 'USD',});

            this.Total= Number(this.totalplfee.replace(/[^0-9.-]+/g,"")) + Number(this.totalalfee.replace(/[^0-9.-]+/g,"")) + Number(this.totallafee.replace(/[^0-9.-]+/g,""));
            console.log('Total=>',this.Total);
            console.log('typeof Total=>',typeof(this.Total));
            this.renewalTotalAmount=Number(this.Total).toLocaleString('en-US', {style: 'currency',currency: 'USD',});
            console.log('Total11=>',this.Total);
            console.log('renewalTotalAmount=>',this.renewalTotalAmount);
            if(this.renewalprocess==true){
            this.penaltycalculations();
            }
            else{
                this.grandTotal = Number(parseInt(this.Total)).toLocaleString('en-US', {style: 'currency',currency: 'USD',});  
            }
           

    }catch(err){
        console.error('err--> ', err);
    }
   }// EO calculatefees method

@api penaltyPercentage;

@api penaltycalculations(){
    // Penalty fee calculation - Raghu
             PenaltyCalculator_js({accId:this.orgaccid})
                .then(result => {
                console.log(result,'result 1 penalty --------> ',JSON.stringify(result));
                this.penaltyPercentage=result;
                    if(result==0){
                    this.penalty='None';
                    }else{
                        this.penalty=result;
                    }
                    if(this.penalty==='None')
                    {
                        let pltfeeval=0;
                        this.pltfee=Number(pltfeeval);
                    }
                    else{
                        this.pltfee = Number(this.Total * this.penalty)/100;
                    }
                    console.log('this.pltfee==>',this.pltfee);
                    this.penaltyfee = Number( this.pltfee).toLocaleString('en-US', {style: 'currency',currency: 'USD',});
                    this.grandTotal = Number(parseInt(this.Total) + this.pltfee ).toLocaleString('en-US', {style: 'currency',currency: 'USD',});
                    this.createPenaltyRFItem();
                }).catch(error => {
                            console.log('49 error--------> ',error);
                });
}

@track pval=[];
@api penaltyValues(){
    console.log('pval11 in penaltyValues',this.pval);
    try{
        this.pval.push(this.pltfee);
        this.pval.push(this.penaltyPercentage);
    }
    catch{
        console.log('--Error in penaltyValues-- ');
    }
   
    console.log('pval11 in penaltyPercentage',this.penaltyPercentage);
   
    console.log('pval11 in pltfee',this.pltfee);
    console.log('pval22 in penaltyValues',this.pval);
    return this.pval;
}

    getAgentandLocationCount(){
        console.log('inside getAgentandLocationCount ');
        //Imparative call to get number of agents from form C
        getRecCount_js({AgencyID: this.accidf, sObj: 'AGENT'})
                    .then(result => {
                        this.agentCount = result;
                        console.log('result getRecCount_js agent count=> ',this.agentCount);
                            //Imparative call to get number of associated location from form B
                            getRecCount_js({AgencyID: this.accidf, sObj: 'LOCATION'})
                            .then(result => {
                                this.assoLocCount = result; 
                                console.log('assoLocCount in getRecCount_js=>', this.assoLocCount); 
                                this.calculatefees(); //calling calculatefees method to calculate fees
                            })
                            .catch(error => {
                                console.log('---error in location count---',JSON.stringify(error));
                            });    
                    })
                    .catch(error => {
                        console.log('---error in agent count---',JSON.stringify(error));
                    });
    }


 @api handleClick(event) {
     console.log('In handleclick method on form F');
    }


    @api handlePayment(){
        console.log('Inside handlePayment grandTotal-->',this.grandTotal);
        this.returnGrandTotal=Number((this.grandTotal).replace(/[^0-9.-]+/g,""));
        console.log('Inside handlePayment returnGrandTotal-->',this.returnGrandTotal);
        return this.returnGrandTotal;
    }
    signInput(event){
        this.signString =event.detail.value;

    }
  
  @api saveSignature(){
       let signFlag=false;
        //alert('signString=>'+this.signString);
        if(this.signString=== undefined || this.signString ==="" || this.signString ===" "){
            const evt = new ShowToastEvent({
                title: 'Alert',
                message: 'Write First Name and Last Name in Signature',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else{
            this.signature.push(this.signString);
            this.signature.push(this.accidf);
            //alert('signature=>'+this.signature);
            //alert(this.signature.length);
            let signType= 'SIGNTURE';
           // updateAgencyApproval_js({wrapperText: JSON.stringify(this.signature), accId: this.orgaccid, sType : signType})
           updateAgencyApproval_js({wrapperText: JSON.stringify(this.signature), accId: this.orgaccid , renAccID: this.accidf, sType : signType})
            .then(result => {
                console.log('result updateAgencyApproval_js=> ',result);
            })
            .catch(error => {
                console.log('---error---',JSON.stringify(error));
            });
            signFlag=true;
        }
        this.signature=[];
        return signFlag;
    }
 

}