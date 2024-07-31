@isTest
public class AssetProductUpdate_Test {
    @isTest
    Private static void test_Method(){
        Try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
             
            Map<String,Id> productsMap = new Map<String,Id>();
        
            
            
            Product2 pdt= new Product2();
       		pdt.Name = 'CNG Meters ';
            insert pdt;
            
            Asset ast = new Asset();
            ast.Product2Id = pdt.Id;
            ast.Name=pdt.Name;
            ast.Device_Type__c = 'Weighing';
            ast.Other_Device_Comments__c = 'testt';
            ast.AccountId = accRec.Id;
            ast.ContactId = conRec.Id;
            insert ast;
            
            Asset ast1 = new Asset();
            //ast.Product2Id = pdt.Id;
            ast1.Name=pdt.Name;
            ast1.Device_Type__c = 'Weighing';
            ast1.Other_Device_Comments__c = 'testt';
            ast1.AccountId = accRec.Id;
            ast1.ContactId = conRec.Id;
            insert ast1;
            
            test.startTest();
            AssetProductUpdate.setProductIdForEachAsset();
            AssetProductUpdate.getProductId(productsMap, pdt.Name);
            test.stopTest();
            
         }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
}