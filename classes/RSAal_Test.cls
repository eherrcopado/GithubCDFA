@isTest
public class RSAal_Test {
 @isTest
    Private static void test_Method(){
        
        Try{
            
           Account accRec = TestDataFactory_Community.createAccountTestRec2('TestAcc', 'RSA');
            Insert accRec;
          
             Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            
            RegulatoryAuthorizationType raType = new RegulatoryAuthorizationType();
            raType.Name = 'Test raType';
            raType.RegulatoryAuthCategory = 'License';
            raType.DurationType ='Hour';
            Insert raType;
            system.debug('raType - '+raType);
   
            
            BusinessLicense bl2 = new BusinessLicense();
            bl2.Name = 'BL 12445';
            bl2.AccountId = accRec.Id;
            bl2.RegulatoryAuthorizationTypeId = raType.Id;
            bl2.status = 'Active';
            bl2.JurisdictionType = 'STATE';
            bl2.VerificationStatus ='Authorized';
            Insert bl2;
            
          
		   Schema.AssociatedLocation asl2 = new Schema.AssociatedLocation(Type ='Primary',ParentRecordId = accRec.Id,
                                                                          LocationId =  locationRec.Id,Status__c='Active' );
            insert asl2; 
            
            Schema.AssociatedLocation asl3 = new Schema.AssociatedLocation(Id=asl2.Id ,Type ='other',ParentRecordId = accRec.Id,
                                                                          LocationId =  locationRec.Id,Status__c='Active' );
            update asl3;
            
            delete asl2;
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
}