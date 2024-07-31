public class DataCoversion{
    
    public static void bLicense() {
        Contact c = new Contact();
        PersonExamination p = new PersonExamination();
        
        RegulatoryAuthorizationType br = [select id from RegulatoryAuthorizationType limit 1];
                
        for (tmpAgency__c a : [select id, Pri_Licname__c, FromDate__c, ToDate__c, pri_regno__c from tmpAgency__c]) {
            Account acc = [select id from Account where name = :a.Pri_Licname__c limit 1];
            BusinessLicense bl = new BusinessLicense();
            bl.accountid = acc.id;
            bl.name = a.Pri_Licname__c + ' ' + a.pri_regno__c;
            bl.PeriodStart = a.fromdate__c;
            bl.PeriodEnd = a.todate__c;
            bl.RegulatoryAuthorizationTypeId = br.id;
            bl.status = 'Active';
            insert bl;
        }
            
    }

    public static void hqlocation() {
                
        for (tmpAgency__c a : [select id, Pri_Licname__c, Pri_Street__c, Pri_City__c, Pri_County__c, Pri_state__c, Pri_Zip__c  from tmpAgency__c]) {
            Account acc = [select id from Account where name = :a.Pri_Licname__c limit 1];
            Schema.Location l = new Schema.Location();
            l.name = a.Pri_Licname__c + ' - Primary';
            insert l;
            
            Schema.Address ad = new Schema.Address();
            ad.parentid = l.id;
            ad.street = a.Pri_street__c;
            ad.city = a.Pri_City__c;
            ad.state = a.Pri_state__c;
            ad.postalcode = a.Pri_Zip__c  ;
            ad.country = 'USA';
            ad.locationtype = 'Business Site';
            insert ad;
            
            l.VisitorAddressId = ad.id;
            update l;
            
            AssociatedLocation al = new AssociatedLocation();
            al.ParentRecordId = acc.id;
            al.type = 'Primary';
            al.status__c = 'Active';
            al.LocationId = l.id;
            insert al;
            

        }
            
    }

    public static void branches() {
    
        string oldAgency;
        integer i;
                
        for (tmpBranches__c a : [select id, Pri_Licname__c, br_address__c, br_City__c, br_County__c, br_state__c, br_Zip__c  from tmpBranches__c]) {
            Account acc = [select id from Account where name = :a.Pri_Licname__c limit 1];
            
            if (oldAgency <> a.Pri_Licname__c)
                i = 1;
           
            
            Schema.Location l = new Schema.Location();
            l.name = a.Pri_Licname__c + ' - Other ' + i;
            insert l;
            
            Schema.Address ad = new Schema.Address();
            ad.parentid = l.id;
            ad.street = a.br_address__c;
            ad.city = a.br_City__c;
            ad.state = a.br_state__c;
            ad.postalcode = a.br_Zip__c  ;
            ad.country = 'USA';
            ad.locationtype = 'Business Site';
            insert ad;
            
            l.VisitorAddressId = ad.id;
            update l;
            
            AssociatedLocation al = new AssociatedLocation();
            al.ParentRecordId = acc.id;
            al.type = 'Other';
            al.status__c = 'Active';
            al.LocationId = l.id;
            insert al;
            i = i + 1;
            oldAgency = a.Pri_Licname__c;
            

        }
            
    }
            
    public static void AgentExam() {
                
        for (tmpAgent_Agency_List__c a : [select id, Agent_licno__c, Exam_Date__c, Expiration_Date__c, Percent__c from tmpAgent_Agency_List__c]) {
            Contact c = [select id from Contact where license_no__c = :a.Agent_licno__c limit 1];
            PersonExamination p = new PersonExamination();
            p.contactid = c.id;
            p.License_No__c = a.Agent_licno__c;
            p.ExaminationDate = a.Exam_Date__c ;
            p.EffectiveFrom = a.Exam_Date__c ;
            p.EffectiveTo = a.Expiration_Date__c;
            p.score = Integer.ValueOf(a.Percent__c) ;
            p.result = 'Pass'; 
            insert p;
        }
            
    }  
    
    public static void regtrans() {
                
        
                
        for (tmpAgency__c a : [select id, Pri_Licname__c, FromDate__c, ToDate__c, pri_regno__c from tmpAgency__c]) {
                    
            Account acc = [select id from Account where name = :a.Pri_Licname__c limit 1];
            BusinessLicense bl = [select id from BusinessLicense where AccountId = :acc.id and status = 'Active' limit 1];
            
            tmpTransactions__c  tr = [select id,Rc_Number__c, rcdate__c, licenseFee__c from tmpTransactions__c where Pri_Licname__c = :a.Pri_Licname__c order by rcdate__c desc limit 1];
            
            RegulatoryTrxnFee newRtf = new RegulatoryTrxnFee();
            newRtf.accountid = acc.Id;
            newRtf.ParentRecordId = bl.id;
            newRtf.status = 'Paid';
            newRtf.Paid_Date__c = tr.rcdate__c;
            newRtf.status = 'Paid';
            insert newRtf;
            
            RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
            newRtfi.RegulatoryTrxnFeeId = newrtf.id;
            newRtfi.name = tr.Rc_Number__c;
            newRtfi.RcNumber__c = tr.Rc_Number__c;
            newRtfi.FeeAmount = tr.licenseFee__c ;
            newRtfi.status__c = 'Paid';
            insert newRtfi;
            

        }
            
    }      
}