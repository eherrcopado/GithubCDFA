/*
Class			: USPSAddressVerifier
Test Class		: USPSAddressVerifier_Test
Description		: Gets address fields input and suggest correct address or error in inputed address via USPS API
How to call		: USPSAddressVerifier.uspsAddressSearch('29851 Aventura k','RCHO STA MARG','CA','92688');
*/
public without sharing class USPSAddressVerifier {
    
    public class AddressWrapper{
        @AuraEnabled
        public String street {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String province {get;set;}
        @AuraEnabled
        public String country {get;set;}
        @AuraEnabled
        public String postalcode {get;set;}
        @AuraEnabled
        public String returnText {get;set;}
        @AuraEnabled
        public String errorDescription {get;set;}
		@AuraEnabled
        public Integer apiStatusCode {get;set;}
    }
    
    @AuraEnabled //(cacheable=true)  
    //Address will be verified and suggested correct address using USPS API
    public static AddressWrapper uspsAddressSearch(String street, String city, String province, String postalcode ) {
        if((street ==  null || city==null || province==null || postalcode==null || 
            street ==  '' || city=='' || province=='' || postalcode=='')){  
                return null;
            }
        string xmlOutputString= getXmlString(street, city, province,postalcode);
        string	encodedXmlStr = encodeXmlString(xmlOutputString);
        AddressWrapper suggestedAdr = getSuggestedAddress(encodedXmlStr);
        
        return suggestedAdr;
    }
    
    //Adds address tags and returns generated XML
    public static string getXmlString(String street, String city, String province, String postalcode){
        system.debug('street='+street+'=city='+city+'=province='+province+'=postalcode='+postalcode); 
        
        String xmlOutput='';
        try{
            XmlStreamWriter w = new XmlStreamWriter();
            
            //Address 1 is the suite or apt number - APT 221
            w.writeStartElement(null, 'Address1', null);
            //w.writeCharacters(addressList[0]);
            w.writeEndElement();
            
            //Address 2 is actually the first line of the address - 123 Sunset Blvd
            w.writeStartElement(null, 'Address2', null);
            w.writeCharacters(street);
            w.writeEndElement();
            w.writeStartElement(null, 'City', null);
            w.writeCharacters(city);
            w.writeEndElement();
            w.writeStartElement(null, 'State', null);
            w.writeCharacters(province);
            w.writeEndElement();
            w.writeStartElement(null, 'Zip5', null);
            w.writeCharacters(postalcode);
            w.writeEndElement();
            
            w.writeStartElement(null, 'Zip4', null);
            //w.writeCharacters(addressList[5]);
            w.writeEndElement();
            
            xmlOutput = w.getXmlString();
            w.close(); 
            
        }catch(System.CalloutException e) {
            System.debug('C error line: '+ e.getLineNumber());
            System.debug('C error msg: '+ e.getMessage());
            System.debug('C error: '+ e);
        }
        
        return xmlOutput;
    }
    
    //Encoding XML to pass to USPS API as endpoint
    public static string encodeXmlString(string xmlString){
        //use custom label for userid
        string encodedXmlStr= '<AddressValidateRequest USERID="798CADEP5377"><Address ID="0">' + xmlString + '</Address></AddressValidateRequest>';
        encodedXmlStr=EncodingUtil.urlEncode(encodedXmlStr,'UTF-8');
        return encodedXmlStr;
    }	
    
    //call USPS API and get suggested address
    public static AddressWrapper getSuggestedAddress(string encodedXML){
        AddressWrapper adrsWrp = new AddressWrapper();
        
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        
        //use custom label for url
        string endPointUrl= 'https://production.shippingapis.com/ShippingAPI.dll?API=Verify&XML='+encodedXML;
        system.debug('endPointUrl==>'+endPointUrl); 
        
        req.setEndpoint(endPointUrl);
        
        try { 
            res = ht.send(req);
            System.debug('getBodyDocument:'+res.getBodyDocument());
			System.debug('status code:'+res.getStatusCode());
            adrsWrp.apiStatusCode = res.getStatusCode();
            
       } catch(System.CalloutException e) {
            System.debug('Callout error line: '+ e.getLineNumber());
            System.debug('Callout error msg: '+ e.getMessage());
            System.debug('Callout error: '+ e);
        }
        catch(System.Exception ex) {
            System.debug('line: '+ ex.getLineNumber());
            System.debug('msg: '+ ex.getMessage());
            System.debug('error: '+ ex);
        }
 
        Dom.Document doc = res.getBodyDocument();
        Dom.XMLNode AddressValidate = doc.getRootElement();
        Dom.XmlNode[] Address = AddressValidate.getChildren();
        Dom.XmlNode addressElements = Address[0];
        
        String recmStreet='';
        String recmCity='';
        String recmState='';
        String recmPostalCode='';
        String recmZip5='';
        String rtnText='';
        String errDescr='';

        try{
            for(Dom.XMLNode children : addressElements.getChildren()) {  
                
                if(children.getName()=='Address2'){
                    recmStreet=children.getText();
                    system.debug('Address2='+children.getText()); 
                }
                if(children.getName()== 'City'){
                    recmCity=children.getText();
                    system.debug('City='+children.getText());
                } 
                if(children.getName()== 'State'){
                    recmState=children.getText();
                    system.debug('State='+children.getText()); 
                }
                if(children.getName()== 'Zip5'){
                    recmZip5=children.getText();
                    system.debug('State='+children.getText()); 
                }
                if(children.getName()== 'ReturnText'){
                    rtnText=children.getText();
                    system.debug('State='+children.getText()); 
                }
                
                if(children.getName()== 'Error'){
                    system.debug('Error='+children.getText()); 
                    for (DOM.XmlNode errNode : children.getChildren()){
                        if(errNode.getName() == 'Description'){
                            errDescr=errNode.getText(); 
                            system.debug('Error Description='+errNode.getText()); 
                        }    
                    }
                }
            }
            if(!(errDescr==''||errDescr==null)){         
                adrsWrp.street = '';
                adrsWrp.city = '';
                adrsWrp.province = '';
                adrsWrp.postalcode = '';
                adrsWrp.country = '';
                adrsWrp.returnText = '';
                adrsWrp.errorDescription = errDescr;
            }else{ 
                adrsWrp.street = recmStreet;
                adrsWrp.city = recmCity;
                adrsWrp.province = recmState;
                adrsWrp.postalcode = recmZip5;
                adrsWrp.country = 'USA';
                adrsWrp.returnText = rtnText;
                adrsWrp.errorDescription = '';  
            }
        }catch(System.CalloutException e) {
            //if any error occurs at USPS API it will send following error description.
            System.debug('C error line: '+ e.getLineNumber());
            System.debug('C error msg: '+ e.getMessage());
            System.debug('C error: '+ e);
        }
        
        return adrsWrp;
    }
}