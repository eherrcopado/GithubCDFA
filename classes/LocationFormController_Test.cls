@isTest
public class LocationFormController_Test {
    @isTest
    public static void tMethod(){
        
        Account acc1=new Account(Name='Account1',Industry='Agriculture');
        insert acc1; 
        
        Account accountId=[SELECT Id, Industry FROM Account LIMIT 1];
        
        Contact conrec = TestDataFactory_Community.createContactTestRec('Rashmi', 'hiremath', 'Rashmi@gmail.com', acc1.Id);
        insert conrec;
        Schema.Location locRec = TestDataFactory_Community.getLocationTestRec();
        Insert locRec;
        RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
        insert rAuth;
        BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(acc1.Id, conrec.Id, rAuth.Id);
        insert licrec;
        Schema.AssociatedLocation assloc = TestDataFactory_Community.getAscLationTestRec(acc1.Id,locRec.Id);
        Insert assloc;
        
        Schema.Address addrec = testdatafactory_community.getAddessRec(locRec.Id);
        Insert addrec;
        
        //LocationFormController test=New LocationFormController();
        List<schema.AssociatedLocation> mylist = LocationFormController.getLocation(accountId.Id);
        system.debug(mylist.size());
        system.assertEquals(1, mylist.size());
        
        //getLookupAddress
        string searchkey = addrec.id;
        List<schema.address> mylist2 = LocationFormController.getLookupAddress(searchkey);
        system.debug(mylist2.size());
        
        //createALocation
        //==============================
        LocationFormController.createALocation(accountId.Id,addrec.Id);
        
        //addAssociatedLocation
        List<String>wrpList = new List<String>();
        wrpList.add(addrec.Id);
        LocationFormController.addAssociatedLocation(wrpList,acc1.Id);
        system.assertEquals(1, wrpList.size());
        
        //removeAssociatedLocation
        LocationFormController.removeAssociatedLocation(wrpList,acc1.Id);
        system.assertEquals(1, wrpList.size());
        
        //createLocation
        //===========================
        LocationFormController.createLocation(acc1.Id, 'MG road', 'Bangalore', 'Test', 'India', '560087','Alameda');
        //system.assert(createLocation.size()>0);
        
        //getDuplicateAddress
        Boolean dupadd = LocationFormController.getDuplicateAddress('MG road', '560087');
        system.assert(dupadd);
        
        //createALocation
        //LocationFormController.createALocation(acc1.Id,addrec.Id);
        
        //changeAssociatedLocation
        //=============================
        LocationFormController.changeAssociatedLocation(assloc.Id, acc1.Id, acc1.Id);
        
        //addAssociatedLocation2
        //=================================
        LocationFormController.addAssociatedLocation2(addrec.Id, acc1.Id);
        
        //getLookupAddress
        //LocationFormController.getLookupAddress(searchkey);
        
        
    }
}