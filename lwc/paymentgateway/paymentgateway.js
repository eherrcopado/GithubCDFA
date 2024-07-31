import { LightningElement, track, api } from 'lwc';
import {NavigationMixin} from "lightning/navigation";
export default class Paymentgateway extends LightningElement {

    @track confirmationMessage;
    _url;
   
   /* 
    connectedCallback()
    {
        this._url = window.location.href;
        apexCallMethod();
    }

    apexCallMethod() {

        const params = {

            input: {"url":this._url},
            sClassName: "CDFA_UpdateFDPayment",
            sMethodName: "UpdateFDPayment",
            options: "{}"
        };

        this.omniRemoteCall(params.true).then((response)=>{

 this.confirmationMessage = response.conformationMessage;

        }).catch(error => {
            console.error("error while posting data", JSON.stringfy(error));
        });
    }
*/

openpaymentsystem(){
 //   connectedCallback(){
    let baseurl = "https://uat.thepayplace.com/epayconsumerweb/stateofca/foodagriculture/cdfapayments?"
   let currenturl = "https://rsadev-cdfa-dev.cs133.force.com/cdfalpi/s/apply-license-permit";
  //  let currenturl = "https://rsadev-cdfa-dev.cs133.force.com/cdfalpi/s/apply-license-permit?&sid=58963";
    let returnurl = "returnurl=" + currenturl;
    //https://cdfa--rsadev.lightning.force.com/lightning/r/Account/0013S000009RtwLQAS/view";
   let parameters="&ref=1234&id=0kx3S00000000njQAA&bfn=Johnny&bmn=K &bln=Test&custom=This+is+the+description.,$20.00&cfamount=2.00";
    let CompleteUrl = baseurl + returnurl +  parameters;
    console.log(CompleteUrl);
    window.open(CompleteUrl, "_self");
//}
    }

}