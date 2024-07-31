@isTest
public class USPSAddressVerifier_Test {
    
    //Ref : https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_restful_http_testing_httpcalloutmock.htm
	@isTest static void testCalloutSuccessPart() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         
        string Street = '3941 Harry S Truman Blvd';
        string City = 'St Charles';
        String province =  'Mississippi';
        String postalcode = '63301';
        USPSAddressVerifier.AddressWrapper adrs=USPSAddressVerifier.uspsAddressSearch(Street,City ,province,postalcode );
        system.assert(adrs != NULL);
        system.assertEquals('29851 AVENTURA STE KK', adrs.street);
        system.assertNotEquals('3941 Harry S Truman Blvd', adrs.street);
    }
    
    @isTest static void testCalloutErrorPart(){
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        
        string Street = '3941 Harry S Truman Blvd';
        string City = 'St Charles';
        String province =  'Mississippi';
        String postalcode = '63301';
        USPSAddressVerifier.AddressWrapper adrs=USPSAddressVerifier.uspsAddressSearch(Street,City ,province,postalcode );
        system.assertEquals(400, adrs.apiStatusCode);
        system.assertNotEquals(200, adrs.apiStatusCode);
    }
    
}