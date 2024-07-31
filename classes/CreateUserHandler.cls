public with sharing class CreateUserHandler {
    @future
    public static void createUserFromContact(Set<Id> contactIds){
        List<User> userList = new List<User>();
        List<Profile> profileList = [Select Id from Profile where Name=: 'CDFA Community Login User' limit 1];
        for(Contact contactObj : [Select Id, Name,FirstName,LastName, Email from Contact where Id IN: contactIds limit 50000]){
            User uObj = new User();
            uObj.FirstName = contactObj.FirstName ;
            uObj.LastName = contactObj.LastName ;
            uObj.Username = contactObj.Email;
            uObj.Email = contactObj.Email;
            uObj.Alias = 'guest';
            // uObj.UserRoleId = roleList[0].Id;
            uObj.ProfileId = profileList[0].Id;
            uObj.IsActive = true; 
            uObj.TimeZoneSidKey = 'GMT';
            uObj.LanguageLocaleKey = 'en_US';
            uObj.EmailEncodingKey = 'UTF-8';
            uObj.LocaleSidKey = 'en_US';
            uObj.ContactId = contactObj.Id;
            userList.add(uObj);
        }
        try{
           if(!userList.isEmpty()){
               insert userList; 
            }
        }
        catch(Exception e){
          // Catch Exception
        }
    }
}