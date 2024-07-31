public Without Sharing class PenaltyCalculationHandler {
    
    @auraenabled
    Public static Integer PenaltyCalculator (String accId) {
        
        Datetime LicenseEndDate;
        Datetime CurrentDate;
        Integer PenaltyDays;
        Integer Penalty;

        BusinessLicense bl = [select id, PeriodEnd from BusinessLicense where AccountId = :accId and status = 'Active' limit 1];
        LicenseEndDate = bl.PeriodEnd;
       
        Long dt1Long = LicenseEndDate.getTime();
        Long dt2Long = DateTime.now().getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        Long days = hours / 24;        
        PenaltyDays = Integer.valueOf(days);                
        System.debug('PenaltyDays-->'+PenaltyDays);
        if(PenaltyDays<5)
        {
            Penalty = 0;            
        }
        else if ((PenaltyDays>=5)&&(PenaltyDays<30))
        {
            Penalty = 30;            
        }
         else if (PenaltyDays>=30)
        {
            Penalty = 50;
        }
        system.debug('Penalty ---> '+Penalty);
        return Penalty;
    }
      
    
}