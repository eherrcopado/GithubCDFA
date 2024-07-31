@isTest
public class AssetDevicesUpdate_Test {
   @isTest
    Private static void test_Method(){
        Try{
            Test.startTest();
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
        	List<Asset> assetsList  = new List<Asset>();
            Asset ast = new Asset();
            ast.AccountId = accRec.id;
            ast.ContactId = conRec.Id;
            ast.Name = 'LPG Meters';
            insert ast;
            assetsList.add(ast);
            List<String> measuringList = new List<String>();
            measuringList.add('multi-dimension measuring devices');
            measuringList.add('Taximeters and Odometers');
            measuringList.add('Grain Moisture Meters');
            measuringList.add('Electric Meter (Watthour)');
            measuringList.add('CNG Meters');
                
            AssetDevicesUpdate.setDeviceTypes();
          Test.stopTest();
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
}