public without sharing class CourseCertificatesController {

    @AuraEnabled
    public static String checkUserPermissions() {
        String result = '';
        String userId = UserInfo.getUserId();
        String userProfileId = UserInfo.getProfileId();
        try{
            Profile userProfile = [SELECT Name FROM Profile WHERE Id =:userProfileId].get(0);
            List<PermissionSetAssignment> userPsList= [SELECT Id, PermissionSetGroupId, PermissionSetGroup.DeveloperName, AssigneeId, Assignee.Name 
                                                       FROM PermissionSetAssignment 
                                                       WHERE AssigneeId =: userId];        
            if(!userPsList.isEmpty()){
                List<String> permissionNames = new List<String>();
                for(PermissionSetAssignment psa : userPsList){
                    permissionNames.add(psa.PermissionSetGroup.DeveloperName);
                }
                
                if( userProfile.Name == 'System Administrator' || permissionNames.contains('GCSC_Training_User') || permissionNames.contains('GCSC_Operations_Group')){
                    result = 'ALL';
                } else if(/*userProfile.Name == 'System Administrator' ||*/ permissionNames.contains('GCSC_CSTS')){
                    result = 'PREVIEW ONLY';
                } else{
                    result = 'NONE';
                }
            } else {
                result = 'NONE';
            }
        } catch (Exception e){
            result = e.getMessage();
        }

        return result;
    }
    
    @AuraEnabled
    public static List<PdfDataWrapper> getPdfData( Id courseId){

        Courses__c course = new Courses__c();
        try{
			course = [SELECT Id, Name, Course_Partner_Logo__c, Partner_Logo_base64_Type__c, Partner_Logo_Content_Version_ID__c, Course_Name_on_Certificate__c, Delivery_Mode__c, Delivery_Language__c, Send_Certificates_in_English__c, CPD_CEU_Points__c, Course_Start_Date__c, Course_End_Date__c,
								(SELECT Id, Name, Course_Number__c, Pass_Status__c, Certificate_Sent__c, Booking_Status__c, Delegate_Contact__r.Email, Registration_No__c, Delegate_Contact__r.Name, Delegate_Contact__r.Registration_Number__c, Delegate_Contact__r.Registration_Number_legacy__c
								 FROM Course_Booking__r 
                                 WHERE Course_Number__c=:courseId 
                                 )
                             FROM Courses__c 
                             WHERE Id=:courseId].get(0);
        } catch (Exception e){
            course = null;
        }
        List<PdfDataWrapper> pdfDataList = new List<PdfDataWrapper>();
        List<Course_Booking__c> cbListAux = new List<Course_Booking__c>();
        List<Course_Booking__c> cbList = new List<Course_Booking__c>();

        if(course == null){
            PdfDataWrapper pdfData = new PdfDataWrapper();
            pdfData.resultMessage = 'NO COURSE';
            pdfDataList.add(pdfData);
            return pdfDataList;
        } else {
            
            cbListAux = course.Course_Booking__r;
            
            if(course.Delivery_Language__c == null || course.Delivery_Language__c == '' ){
                course.Delivery_Language__c = 'English';
            }
            
            if(!cbListAux.isEmpty()){
                for(Course_Booking__c cbaux : cbListAux){
                    if(course.Delivery_Mode__c != 'Face to Face' ){
						if(cbaux.Pass_Status__c == 'Pass' && cbaux.Booking_Status__c == 'Confirmed'){
                            cbList.add(cbaux);
                        } 
                    } else {
                        cbList.add(cbaux);
                    }
                }                
            } else {
                PdfDataWrapper pdfData = new PdfDataWrapper();
                pdfData.resultMessage = 'NO CB';
                pdfDataList.add(pdfData);
                return pdfDataList;
            }

        }
        
        string logo = '';
        string fileExtension = null;
        string deliveryLanguage = '';
        string textLanguage = '';

        if(cbList.size() > 0){

            if(course.Course_Partner_Logo__c == null || course.Course_Partner_Logo__c == '' ){
                System.debug('NO PARTNER LOGO');
                
                String shlLogo = getSHLLogo('Certificate_SHL_Logo');

                if(shlLogo != ''){
                    logo = shlLogo;
                    fileExtension = 'png'; // DO I need this? confirm
                } else {
                    logo = '';
                    fileExtension = '';
                }
            } else {
                System.debug('PARTNER LOGO');
                
                Blob partnerImageData = [Select VersionData 
                                         FROM ContentVersion 
                                         WHERE Id =: course.Partner_Logo_Content_Version_ID__c].get(0).VersionData;
				String base64Image = EncodingUtil.base64Encode(partnerImageData);
                logo = base64Image;

                fileExtension = '';
            }
            
            
            if(course.Send_Certificates_in_English__c == false){
                deliveryLanguage = course.Delivery_Language__c;
            } else {
                deliveryLanguage = 'English';
            }
            
            
            Map<String,String> mapTextPlaceholder_Value =  getMetadataByLanguage(deliveryLanguage);
                
            for(Course_Booking__c cb : cbList){
                
                Contact con = cb.Delegate_Contact__r;
                
				PdfDataWrapper pdfData = new PdfDataWrapper();
                
                if(cb.Certificate_Sent__c == NULL){
                    pdfData.sendDate = 'NULL';
                } else {
                    pdfData.sendDate = 'DATE';
                }
                
                if(fileExtension == ''){
                    pdfData.DataType = course.Partner_Logo_base64_Type__c;
                } else {
                    pdfData.DataType = '';
                }
                
                pdfData.Language = deliveryLanguage; // Changes done by Jai for Japanese language addition
                pdfData.logoURL = logo;
                pdfData.fileExtension = fileExtension;
                pdfData.ReplaceCertificateTitle_Label = mapTextPlaceholder_Value.get('ReplaceCertificateTitle_Label');
                pdfData.ReplaceCertifyThat_Label = mapTextPlaceholder_Value.get('ReplaceCertifyThat_Label');
                pdfData.ReplaceName = con.Name;
                pdfData.ReplaceSuccessfullyCompleted_Label = mapTextPlaceholder_Value.get('ReplaceSuccessfullyCompleted_Label');
                
                if(course.Course_Name_on_Certificate__c != null && course.Course_Name_on_Certificate__c != '' ){
                    pdfData.ReplaceCourseName = course.Course_Name_on_Certificate__c;
                } else {
                    pdfData.ReplaceCourseName = '';
                }
                           
                pdfData.ReplaceDate = (course.Course_End_Date__c).format();
                
                if(course.CPD_CEU_Points__c != null && course.CPD_CEU_Points__c != '' ){
                    pdfData.ReplaceCPDCEUPoints = 'CPD CEU Points: '+ course.CPD_CEU_Points__c;
                } else {
                    pdfData.ReplaceCPDCEUPoints = '';
                }
                
                pdfData.ReplaceAppropriateTraining_Label = mapTextPlaceholder_Value.get('ReplaceAppropriateTraining_Label');
                pdfData.ReplaceResgistrationNumber_Label = mapTextPlaceholder_Value.get('ReplaceResgistrationNumber_Label');
                //pdfData.ReplaceResgistrationNumber = con.Registration_Number__c;
                pdfData.ReplaceResgistrationNumber = con.Registration_Number_legacy__c != null ? con.Registration_Number_legacy__c : con.Registration_Number__c;
                pdfData.ReplaceTermsConditions_Label = mapTextPlaceholder_Value.get('ReplaceTermsConditions_Label');
                pdfData.ReplaceRightsReserved_Label = mapTextPlaceholder_Value.get('ReplaceRightsReserved_Label');
                pdfData.cbId = cb.Id;
                pdfData.delegateName = con.Name;
                pdfData.cbNumber = cb.Name;
                
                if(course.Delivery_Mode__c == 'Face to Face' ){
                    pdfData.DeliveryMode = 'FACE';
                } else {
                    pdfData.DeliveryMode = '';
                }
                
                pdfData.resultMessage = 'SUCCESS';
				
                pdfDataList.add(pdfData);    
            }

			return pdfDataList;
            
        } else{
           PdfDataWrapper pdfData = new PdfDataWrapper();
           pdfData.resultMessage = 'FAILURE';
           pdfDataList.add(pdfData);
           return pdfDataList; 
        }
    }
    
    @AuraEnabled
    public static String sendPDF (List<PdfDataGeneratedWrapper> pdfDataObj_List){         
        
            Set<Id> cbId_Set = new Set<Id>();
            String result = '';

            for(PdfDataGeneratedWrapper pdfobj : pdfDataObj_List){
                cbId_Set.add(pdfobj.cbId);
            }
            
            Map<ID, Course_Booking__c> cbMap = new Map<ID, Course_Booking__c>([SELECT Id, Course_Number__c, Certificate_Sent__c, Delegate_Contact__r.Id, Delegate_Contact__r.Email, Delegate_Contact__r.Name
                                     FROM Course_Booking__c
                                     WHERE Id IN: cbId_Set]);

            if(!cbMap.isEmpty()) {
                
                List<ContentVersion> cvList = new List<ContentVersion>();
                List<Messaging.SingleEmailMessage> emailToSendList = new List<Messaging.SingleEmailMessage>();
                String templateName = '';
                
                Courses__c course = [SELECT Id, Delivery_Language__c, Profit_Centre__c, Send_Certificates_in_English__c  
                                     FROM Courses__c 
                                     WHERE Id =: cbMap.values()[0].Course_Number__c].get(0);           
                
                //If course Delivery Language is not set it defaults the email body language to English
                if(course.Delivery_Language__c == null || course.Delivery_Language__c == '' ){
                    course.Delivery_Language__c = 'English';
                }
                
                
                if(course.Send_Certificates_in_English__c){
                    templateName = 'CertificateEmailBody_English';
                } else {
                    templateName = 'CertificateEmailBody_'+course.Delivery_Language__c;
                }
                 
                Id template_id = [SELECT id FROM EmailTemplate WHERE Name =:templateName].get(0).Id; 

                String senderEmailaAddress = (system.label.Certificate_SenderEmail_Address).toLowerCase().trim();//'noreplytrainingacademy@shl.com'

                Id senderEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address =:senderEmailaAddress].get(0).Id;

                
                //Iterate record returned from client side
                for(PdfDataGeneratedWrapper pdf_Obj : pdfDataObj_List){
                    
                    String passBlob = pdf_Obj.pdfBase64String;
                    Blob pdfBlob = EncodingUtil.base64Decode(passBlob);
                    
                    //check if Course profit center is China, if not add pdf file content version to save under CB Files to list
                    if(!((course.Profit_Centre__c).toUpperCase()).contains('CHINA')){
                        ContentVersion cv = newFile(pdfBlob, pdf_Obj.cbId, cbMap.get(pdf_Obj.cbId).Delegate_Contact__r.Name );
                        cvList.add(cv);
                    }
                    
                    //create email for each Delegate contact, with attached certificate file and ad to email list to send
                    Messaging.SingleEmailMessage email = newEmail(pdfBlob,cbMap.get(pdf_Obj.cbId).Delegate_Contact__r.Name,pdf_Obj.cbId,cbMap.get(pdf_Obj.cbId).Delegate_Contact__r.Id,cbMap.get(pdf_Obj.cbId).Delegate_Contact__r.Email,template_id,senderEmailId);
                    emailToSendList.add(email);
                }
                
             	try{  
            	
                    if(!cvList.isEmpty()){
                        insert cvList; //save file under each CB, if there is any in the list
                    }
                      
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailToSendList); //send emails to delegate contacts

                    for(Course_Booking__c cb : cbMap.values()){
                        cb.Certificate_Sent__c = system.today();
                    }
                    update cbMap.values();
    
                    result = 'SUCCESS';
                    
             	} catch (Exception e){
                    result = e.getMessage();
                 
            	}
        }
        else {
            result = 'ERROR';
        }
        
        return result;
    }
    
    @AuraEnabled
    public static String deletePartnerLogo(Id courseId){
        String result = '';
        try{
            Courses__c course = [SELECT Id, Partner_Logo_Content_Version_ID__c, Partner_Logo_base64_Type__c
                                 FROM Courses__c 
                                 WHERE Id=:courseId].get(0);
            course.Partner_Logo_Content_Version_ID__c = null;
            course.Partner_Logo_base64_Type__c = null;
            update course;
            result = 'SUCCESS';
        } catch (Exception e) {
            result = e.getMessage();
        }
        
        return result;
    }
    
    @AuraEnabled
    public static String savePartnerLogo (String partnerLogoData, String name, Id courseId, String fileType ){
        String result;
        try{

            ContentVersion cv1 = new ContentVersion();
            String passBlob = partnerLogoData;
            Blob imgBlob = EncodingUtil.base64Decode(passBlob);
            cv1.ContentLocation = 'S';
            cv1.VersionData = imgBlob;
            cv1.Title = name;
            cv1.FirstPublishLocationId = courseId;
            cv1.PathOnClient = name + '.' + fileType ;
            insert cv1;
            
            Courses__c course = [SELECT Id, Partner_Logo_Content_Version_ID__c, Partner_Logo_base64_Type__c
                                 FROM Courses__c 
                                 WHERE Id=:courseId].get(0);

            course.Partner_Logo_Content_Version_ID__c =cv1.Id;
            course.Partner_Logo_base64_Type__c = fileType;
            update course;
            result = 'SUCCESS';
        } catch (Exception e){
            result = e.getMessage();
        }
        return result;
    }
    

    private static Map<String,String> getMetadataByLanguage(String language){
        List<Course_Certificate_LanguageTranslation__mdt> metadataByLanguageList = [SELECT Text_Placeholder__c, Text_Value_Translated__c 
                                                                                    FROM Course_Certificate_LanguageTranslation__mdt 
                                                                                    WHERE Delivery_Language__c =: language];
    	Map<String,String> result = new Map<String,String>();
        if(!metadataByLanguageList.isEmpty()){
            for(Course_Certificate_LanguageTranslation__mdt mdt : metadataByLanguageList){
                result.put(mdt.Text_Placeholder__c, mdt.Text_Value_Translated__c );
            }
        }
        return result;
    }
    
    private static String getSHLLogo(String emailTemplateName){
    	EmailTemplate templateLogo =  [SELECT id, HtmlValue FROM EmailTemplate WHERE Name =: emailTemplateName Limit 1];
        String logoUrl = '';
        
        if(templateLogo.HtmlValue != '' && templateLogo.HtmlValue != null){
            logoUrl = fetchImageInfo(templateLogo.HtmlValue, 'src="', '"' );
        }
		return logoUrl;
    }
    
    private static Messaging.SingleEmailMessage newEmail (Blob pdfBlob, String pdfName, String cbId, String conId, String conEmail, Id template_id, Id senderEmailId) {
       List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
       Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(pdfName + ' Certificate.pdf');
                efa.setContentType('application/pdf');
    			efa.setInline(false);
                efa.setBody(pdfBlob);
       email_attachments.add(efa);

       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        		email.setUseSignature(false);
                email.setToAddresses(new List<String>{conEmail});//list of email addresses
                email.setTargetObjectId(conId);//Id of Lead, User or Contact if that is target object. not required. Required if using templateId
                email.setWhatId(cbId);//Id of object that should do field merge
                email.setTemplateId(template_id);
                email.setSaveAsActivity(true);
                email.setFileAttachments(email_attachments);
         		email.setOrgWideEmailAddressId(senderEmailId); 
        return email;
    }
    
    private static ContentVersion newFile (Blob pdfBlob, String cbId, String pdfName) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = pdfBlob;
        cv.Title = pdfName + ' Certificate';
        cv.PathOnClient = pdfName +'.pdf';
        cv.FirstPublishLocationId = cbId;
        cv.SharingPrivacy = 'P' ;
        cv.SharingOption = 'R';
        return cv;
    }
    
    private static string fetchImageInfo(String imageRichText, String start, String ends){
        Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(imageRichText);
        String img = '';
        while (imgMatcher.find()){                
            String imageTag = imgMatcher.group();
            img = imageTag.substringBetween(start, ends );
        }
        return img.unescapeHtml4();
    }
    

    
	public class PdfDataWrapper{
        @AuraEnabled
        public String fileExtension { get; set;}
        
        @AuraEnabled
        public String logoURL { get; set;}
        
        @AuraEnabled
        public String ReplaceCertificateTitle_Label { get; set;}
        
 		@AuraEnabled
        public String ReplaceCertifyThat_Label { get; set;}
        
        @AuraEnabled
        public String ReplaceName { get; set;}
        
        @AuraEnabled
       	public String ReplaceSuccessfullyCompleted_Label { get; set;}
        
        @AuraEnabled
        public String ReplaceCourseName { get; set;}
        
        @AuraEnabled
        public String ReplaceCourseNameDescription { get; set;}
        
        @AuraEnabled
        public String ReplaceDate { get; set;}
        
        @AuraEnabled
        public String ReplaceCPDCEUPoints { get; set;}
        
        @AuraEnabled 
        public String ReplaceAppropriateTraining_Label { get; set;}
        
        @AuraEnabled
        public String ReplaceResgistrationNumber_Label { get; set;}
        
        @AuraEnabled
        public String ReplaceResgistrationNumber { get; set;}
        
        @AuraEnabled
        public String  ReplaceTermsConditions_Label { get; set;}
        
        @AuraEnabled
        public String  ReplaceRightsReserved_Label { get; set;}
        
        @AuraEnabled
        public String Language { get; set;}
        
        @AuraEnabled
        public String  resultMessage { get; set;}
        
        @AuraEnabled
        public Id  cbId { get; set;}
        
        @AuraEnabled
        public String  cbNumber { get; set;}
        
        @AuraEnabled
        public String  delegateName { get; set;}
        
        @AuraEnabled
        public String  DeliveryMode { get; set;}
        
        @AuraEnabled
        public String  sendDate { get; set;}
        
        @AuraEnabled
        public String  DataType { get; set;}
    }

    public class PdfDataGeneratedWrapper {
        @AuraEnabled
        public String cbId { get; set;}
        
        @AuraEnabled
        public String pdfBase64String { get; set;}
        
    }
    

}