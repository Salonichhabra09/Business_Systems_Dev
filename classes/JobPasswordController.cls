public class JobPasswordController {
    @AuraEnabled
    public static void initiatePasswordGeneration(Id jobId, List<String> updatedEmails) {
        Job__c job = [SELECT Id, Client_Report_Password__c, Client_Report_Mail_Ids__c,Sender_Email__c FROM Job__c WHERE Id = :jobId LIMIT 1];

        // Get existing emails from the field
        Set<String> existingEmails = new Set<String>();
        if (String.isNotBlank(job.Client_Report_Mail_Ids__c)) {
            existingEmails.addAll(job.Client_Report_Mail_Ids__c.split(','));
        }

        // Get new emails from the updated list
        Set<String> newEmails = new Set<String>(updatedEmails);

        // Only update Client_Report_Mail_Ids__c if there are changes
        if (!existingEmails.equals(newEmails)) {
            job.Client_Report_Mail_Ids__c = String.join(updatedEmails, ',');
            //update job;
        }

        // Generate a secure password
        String generatedPassword = generateSecurePassword();

        // Encrypt password before storing
        job.Client_Report_Password__c = encryptPassword(generatedPassword);
        //update job;
        
        update job;

        // Send email with password (masked)
        sendPasswordEmail(job, generatedPassword);
    }
    
    public static String generateSecurePassword() {
        return EncodingUtil.base64Encode(Crypto.generateAESKey(256)).substring(0, 12);
    }
    
    public static String encryptPassword(String password) {
         CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
                Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);
    Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(password));
    return EncodingUtil.base64Encode(encryptedBlob); // Convert Blob to Base64 String
}
    
    private static void sendPasswordEmail(Job__c job, String password) {
        List<String> emailList = job.Client_Report_Mail_Ids__c.split(',');
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address =:job.Sender_Email__c LIMIT 1];
       for (String email : emailList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{email});
            mail.setSubject('Job Password Notification');
            mail.setPlainTextBody('Your generated password is: ' + password);
            mail.setSaveAsActivity(false); // Prevents password storage in activity
            mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
            emailsToSend.add(mail);
        }
        Messaging.sendEmail(emailsToSend);
        createEmailMessage(job.Id, emailList);
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getEmailList(Id jobId) {
        Job__c job = [SELECT Client_Report_Mail_Ids__c FROM Job__c WHERE Id = :jobId LIMIT 1];
        return job.Client_Report_Mail_Ids__c != null ? job.Client_Report_Mail_Ids__c.split(',') : new List<String>();
    }
        
    private static void createEmailMessage(String jobId, List<String> emails) {
    EmailMessage emailMessage = new EmailMessage();
    emailMessage.ToAddress = String.join(emails, ';');
    emailMessage.RelatedToId = jobId; // Linking it to Job__c
    emailMessage.Subject = 'Password Sent Successfully';
    emailMessage.TextBody = 'Password was sent to: ' + String.join(emails, ', ');
    emailMessage.Status = '3'; // Draft status (Not sent)
    emailMessage.Incoming = false; // Outgoing email (even though it’s not sent)
    
    insert emailMessage;
}
    
     private static String decryptPassword(String encryptedPassword) {
         CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
        Blob key = EncodingUtil.base64Decode(setting.CRYPTO__c); 
        Blob encryptedBlob = EncodingUtil.base64Decode(encryptedPassword);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', key, encryptedBlob);
        return decryptedBlob.toString();
    }
    
    @AuraEnabled
    public static void sendExistingPasswordEmail(Id jobId, List<String> updatedEmails) {
        Job__c job = [SELECT Client_Report_Password__c,Sender_Email__c,Client_Report_Mail_Ids__c FROM Job__c WHERE Id = :jobId LIMIT 1];

        if (String.isEmpty(job.Client_Report_Password__c)) {
            throw new AuraHandledException('No password found for this Job record.');
        }

        // Decrypt Password before sending
        String decryptedPassword = decryptPassword(job.Client_Report_Password__c);
		OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address =:job.Sender_Email__c LIMIT 1];

        for (String email : updatedEmails) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{email.trim()});
            mail.setSubject('Your Secure Access Password');
            mail.setPlainTextBody('Your existing password is: ' + decryptedPassword);
            mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
       Set<String> emailSet = new Set<String>();
    
    if (String.isNotBlank(job.Client_Report_Mail_Ids__c)) {
        for (String email : job.Client_Report_Mail_Ids__c.split(',')) {
            emailSet.add(email.trim().toLowerCase());
        }
    }
    
    for (String email : updatedEmails) {
        emailSet.add(email.trim().toLowerCase()); // Convert new emails to lowercase before adding
    }

    // Update field with unique lowercase email list
    job.Client_Report_Mail_Ids__c = String.join(new List<String>(emailSet), ',');
    update job;
         createEmailMessage(job.Id, updatedEmails);
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean authenticateUser(String email, String password, Id jobId) {
        Job__c job = [SELECT Client_Report_Mail_Ids__c, Client_Report_Password__c FROM Job__c WHERE Id = :jobId LIMIT 1];

        // Check if the email exists in the stored emails
        Set<String> emailSet = new Set<String>();
        if (String.isNotBlank(job.Client_Report_Mail_Ids__c)) {
            for (String storedemail : job.Client_Report_Mail_Ids__c.split(',')) {
            emailSet.add(storedemail.trim().toLowerCase());
        }
        }

        // Decrypt password (If stored in an encrypted format)
        String storedPassword = decryptPassword(job.Client_Report_Password__c);

        return emailSet.contains(email.trim().toLowerCase()) && storedPassword == password;
    }
}