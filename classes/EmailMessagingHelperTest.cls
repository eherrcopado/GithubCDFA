@isTest
public class EmailMessagingHelperTest {
	
    @isTest
    static void testSendEmailWithOutOWA () {
        EmailMessagingHelper.sendEmail (
            new String[] {Label.Error_Notification_Email_Address},
            new String[] {Label.Error_Notification_Email_Address},
            Label.Error_Notification_Email_Address,
            'CDFA-Support',
            null,
            'Error: while processing email',
            'Error Message',
            'Error Message',
            false,
            false
        );
    }
    
    @isTest
    static void testSendEmailWithOutOWAAndSenderName () {
        EmailMessagingHelper.sendEmail (
            new String[] {Label.Error_Notification_Email_Address},
            new String[] {Label.Error_Notification_Email_Address},
            Label.Error_Notification_Email_Address,
            null,
            null,
            'Error: while processing email',
            'Error Message',
            'Error Message',
            false,
            false
        );
    }
    
    @isTest
    static void testSendEmailWithOWA () {
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-reply@cdfa.ca.gov' LIMIT 1];

        EmailMessagingHelper.sendEmail (
            new String[] {Label.Error_Notification_Email_Address},
            new String[] {Label.Error_Notification_Email_Address},
            Label.Error_Notification_Email_Address,
            null,
            (owea != null && owea.size () > 0) ? owea[0].Id : null,
            'Error: while processing email',
            'Error Message',
            'Error Message',
            false,
            false
        );
    }
}