public class RSACheckIfRecordAccessCtrl {

    @AuraEnabled(cacheable=true)
    public static Boolean checkIfRecordFromSameAccount(String recordId) {
        if(recordId.startsWith('001')) {
            User currentUser = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()];
            if(currentUser.AccountId == recordId) return true;
        }

        if(recordId.startsWith('003')) {
            User currentUser = [SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId()];
            if(currentUser.ContactId == recordId) return true;
        }
        return false;
    }

}