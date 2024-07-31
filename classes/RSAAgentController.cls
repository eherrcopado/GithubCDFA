public class RSAAgentController {


    public Contact c { get; set; }

    public String FName { get; set; }
    public String LName { get; set; }
    public String MName { get; set; }
    public String lemail { get; set; }
    public String laddress { get; set; }
    public String lcity { get; set; }
    public String lstate { get; set; }
    public String lzip { get; set; }
    public String lphone { get; set; }
    public String lproofofidentity { get; set; }
    public String lidentitynumber { get; set; }
    public String lapplicationtype { get; set; }
    public String llicensenumber { get; set; }
    public String lexamscore { get; set; }
    public String lexamdate { get; set; }
    public String lResult { get; set; }
    
    
    public Boolean okBoolean { get; set; }

    public RSAAgentController() {
    
    c = new Contact();       
                    
    }
    
  /*  public PageReference test() {
    

            system.debug('** ** '+c.id+'**');

       return null;
    } */
    
    public PageReference AddAgents() {    

               
        c.FirstName = FName = apexPages.currentPage().getParameters().get('fn');
        c.LastName = LName = apexPages.currentPage().getParameters().get('ln');
        c.MiddleName = MName = apexPages.currentPage().getParameters().get('mn');
        c.email = lemail = apexPages.currentPage().getParameters().get('em');
        c.mailingstreet = laddress = apexPages.currentPage().getParameters().get('ad');
        c.mailingcity = lcity = apexPages.currentPage().getParameters().get('ci');
        c.mailingstate = lstate = apexPages.currentPage().getParameters().get('st');
        c.mailingpostalcode = lzip = apexPages.currentPage().getParameters().get('zi');
        c.phone = lphone = apexPages.currentPage().getParameters().get('ph');
        c.proof_of_identity__c = lproofofidentity = apexPages.currentPage().getParameters().get('pi');
        c.identity_no__c = lidentitynumber = apexPages.currentPage().getParameters().get('in');
        lapplicationtype = apexPages.currentPage().getParameters().get('at');
        c.license_no__c = llicensenumber = apexPages.currentPage().getParameters().get('li');
         lexamdate = apexPages.currentPage().getParameters().get('ed');
         lexamscore = apexPages.currentPage().getParameters().get('es');
         lResult = apexPages.currentPage().getParameters().get('rs');
        
        try {
              
            List<Contact> tempc = [Select id, LastName, FirstName, Phone, Email  from Contact where email = :c.Email and recordtype.name='RSAAgent' limit 1]; 
                        
            if (tempc.size() > 0) {
               c.id = tempc[0].id;               
               
               update c;               
               
           }
            else {   
            
                
                c.recordtypeid  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSAAgent').getRecordTypeId();
                List<Account> tempa = [Select id from Account where name = 'Agents' limit 1];             
                c.accountid = tempa[0].id;   
                INSERT c;
            
            }
            

     //     if (ld.email == 'bobm@abcworld.com') {
     //         okBoolean = true;
     //         return null;
     //     }
                                    
                            
                                                  
  
              c.clear(); 
                          
           } catch (Exception e) {
                ApexPages.addMessages(e);
                okBoolean = false;
                return null;
                
            }   
        okBoolean = true; 
        return null;
    
    }  
    

}