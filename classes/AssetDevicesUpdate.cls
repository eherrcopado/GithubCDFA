public class AssetDevicesUpdate {
    
    public static void setDeviceTypes(){
        List<String> measuringList = new List<String>();
        List<String> weighingList = new List<String>();        
        measuringList.add('Multi-Dimension Measuring Devices');
        measuringList.add('Taximeters/Odometers');
        measuringList.add('Grain Moisture Meters');
        measuringList.add('Electric Meter (Watthour)');
        measuringList.add('CNG Meters');
        measuringList.add('Retail Motor Fuel Dispensers'); 
        measuringList.add('LNG Meters');
        measuringList.add('Generic Retail Meters');
        measuringList.add('Electric Vehicle Charging Station');
        measuringList.add('Cryogenic Liquid Measuring');
        measuringList.add('Other Measuring Devices');
        measuringList.add('Water Meter (Submeter)');
        measuringList.add('Hydrocarbon Gas Vapor Meters');
        measuringList.add('Vehicle Tank Meters');
        measuringList.add('Timing Devices');
        measuringList.add('Milk Meters');
        measuringList.add('Measuring System Software');
        measuringList.add('LPG Meters');
        measuringList.add('Wholesale Liquid Meters');
        measuringList.add('Hydrogen Dispensers');
        
        weighingList.add('Weighing System Software');
        weighingList.add('Retail Point of Sale/ECR'); 
        weighingList.add('Postal/Parcel Scales');
        weighingList.add('Monorail (Static and In-Motion)'); 
        weighingList.add('Belt Conveyor Scales');
        weighingList.add('Heavy Industrial (5000 lbs)'); 
        weighingList.add('Wheel Loader Weighers');
        weighingList.add('Light Industrial (up to 5,000 lb)'); 
        weighingList.add('Other Weighing Devices');
        weighingList.add('Precision and Lab Balances');
        weighingList.add('Onboard Weighing Devices');
        
        Set<Asset> assetsSet  = new Set<Asset>();
        for(Asset a : [select Name,Device_Type__c,Other_Device_Comments__c from Asset where Device_Type__c='']) 
        { 
            if(measuringList.contains(a.Name.trim())){
            	a.Device_Type__c = 'Measuring';    
            }else if(weighingList.contains(a.Name.trim())){
                a.Device_Type__c = 'Weighing'; 
            }
            assetsSet.add(a);
        }
        List<Asset> assetList = new List<Asset>();
        assetList.addAll(assetsSet);
         if(assetsSet.size() > 0){  
                update assetList;  
        }
        
    }

}