public without sharing class AddressWrapper{
        @AuraEnabled
        Public string address{get;set;} // Full Address fron Addres obj
        @AuraEnabled
        Public string type{get;set;}// AssocaiteLocation Type
        @AuraEnabled
        Public string ascId{get;set;}// AssocaiteLocation Id
        @AuraEnabled
        Public string addresId{get;set;}// Address Id
        @AuraEnabled
        Public string locationId{get;set;} // Location Id 
        @AuraEnabled
        Public string status{get;set;}// Status__c
        @AuraEnabled
        Public string parentRecordId{get;set;}// Account Id
        @AuraEnabled
        Public string associatedLocationNumber{get;set;}// Associated Location Number
        @AuraEnabled
        Public string locationName{get;set;}// Location Number
        @AuraEnabled
        Public string street{get;set;}// street
        @AuraEnabled
        Public string city{get;set;}// city
        @AuraEnabled
        Public string state{get;set;}// state
        @AuraEnabled
        Public string country{get;set;} // country 
        @AuraEnabled
        Public string postalCode{get;set;}// postalCode
        @AuraEnabled
        Public string county{get;set;}// county
}