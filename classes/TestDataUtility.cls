public class TestDataUtility {
  public static User getUser(String userType){
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name =: userType limit 1];
      	String userName = Math.random() + 'standarduser' + UserInfo.getOrganizationId() + '@test.com';
        //User usr = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pf.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName=userName);

        return usr;
    }
    
    public static Account getAccount(){
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='India - IN1',Industry='Legal');
        return account;
    }
    
    public static Contact getContact(Id AccountId){
        Contact contact=new Contact(lastname='Test Contact'+date.today(),AccountId=AccountId);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test'; 
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        contact.Email = 'Testing@shl.com';
        return contact;
    }   
    
    public static Contract getContract(Id Accountid,Id OpportunityId){        
        Contract contract = new Contract(Agreement__c='Order',Subscription_Start_Date__c=date.today(),Accountid=Accountid,ContractTerm=12,Status='Draft',StartDate=date.today(),Contract_Type__c='Consulting',Opportunity__c=Opportunityid);   
        return contract;
    }
    
    public static Opportunity getOpportunity(Id AccountId, Id BillingContactId){
        Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),AccountId=AccountId,Billing_Contact__c=BillingContactId,Primary_Contact__c=BillingContactId,name='Test Opportunity',NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName='New',closeDate=System.today(),Order_number__c=NULL,Forecast_Category__c='Commit',Business_Type__c='Expansion');
        return opportunity;
    }

    public static Opportunity getOpportunity(Id AccountId, Id BillingContactId, Id ownerId){
        Opportunity opportunity= new Opportunity(OwnerId=ownerId,AccountId=AccountId,Billing_Contact__c=BillingContactId,Primary_Contact__c=BillingContactId,name='Test Opportunity',NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName='New',closeDate=System.today(),Order_number__c=NULL,Forecast_Category__c='Commit',Business_Type__c='Expansion');
        return opportunity;
    }
    
    public static Product2 getProduct2(){
        Product2 Product2=New Product2();Product2.Description='Test Description'; Product2.IsActive=True; Product2.Name='Test Product';
        return Product2;
    }

    public static list<Product2> getProduct2List(Integer count){
        list<Product2> product2List = new list<Product2>();
        for(Integer i=0; i<count ;i++){
            Product2 Product2=New Product2();
            Product2.Description='Test Description'; 
            Product2.IsActive=True; 
            Product2.Name='Test Product';
            product2List.add(Product2);
        }
        return product2List;
    }
    
    public static PricebookEntry  getPricebookEntry(ID Product2Id,String PBECurrency, Id priceBookId){
        //Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        PricebookEntry PBE = new PricebookEntry();PBE.CurrencyIsoCode=PBECurrency; PBE.IsActive=True;PBE.Pricebook2Id=priceBookId; PBE.Product2Id=Product2Id;PBE.UnitPrice=1;
        return PBE;    
    }
    
    public static Order getOrder(ID Contractid,ID AccountID){
        Order order= New Order(AccountID=AccountID,ContractID=Contractid,CurrencyIsoCode='GBP',Status='Draft',EffectiveDate=Date.Today(),Pricebook2Id = '01s2000000000vQAAQ');
        return order;
    }
    
    public static Trigger_Activation__c getTriggerActivation(String objectName, String objectSettingName){
        Trigger_Activation__c triggerActivation = new Trigger_Activation__c(Active__c = true, Object_Name__c = objectName, Name = objectSettingName);
        return triggerActivation;
    }
    
    public static AutomaticJobCreation__c getAutomaticJobCreation(String name, String msLOB){
        AutomaticJobCreation__c job = new AutomaticJobCreation__c(Name = name, MS_Line_of_Business__c = msLOB);
        return job;
    }
    
    public static Field_Value_Setting__c getFieldValueSetting(String values, String objectSettingName){
        Field_Value_Setting__c triggerActivation = new Field_Value_Setting__c(Value__c = values, Name = objectSettingName);
        return triggerActivation;
    }
    
    public static OrderItem getOrderItem(String orderId, String pricebookRecordId){
        OrderItem orderItem = new OrderItem(OrderId = orderId, PricebookEntryId = pricebookRecordId);
        return orderItem;
    }
    
    public static Campaign getCampaign(){
        Campaign campaign = new Campaign(Alliance_Campaign__c = true, Name = 'Opportunity not linked to Campaign');
        return campaign;
    }

    public Static India_GST__c getIndiaGST(Id AccountId){
            
        India_GST__c IndiaGst=new India_GST__c(name='07TESTOTESTB123',Account__c=AccountId);IndiaGst.Address_Line_1__c='Ground Floor, Corporate One';IndiaGst.City__c ='New Delhi'; IndiaGst.Country__c='India';IndiaGst.State_County__c ='Delhi';IndiaGst.State_Code__c ='07';IndiaGst.ZIP_Postal_Code__c='110076';IndiaGst.Taxpayer_Type__c='EXPWOP';
        return IndiaGst;
    }
    
    public static Courses__c getCourse(Contact contactRecord){
        Courses__c course  = new Courses__c(Course_Director__c = contactRecord.Id, Duration__c='12', Maximum_Delegates__c=12, 
                                        Course_Description__c='description', Course_Name__c='test', Course_Category__c = 'Internal');
        return course;   
    }
    
    public static Course_Booking__c getCourseBooking(Courses__c course, Opportunity opportunityRecord, Contact contactRecord){
        Course_Booking__c courseBooking = new Course_Booking__c(Course_Number__c = course.Id, OAT_Email__c = 'test_oat@test.com',
                                                      Opportunity__c = opportunityRecord.Id, Delegate_Contact__c = contactRecord.Id,
                                                      Booking_Status__c = 'Confirmed');
        return courseBooking;
    }

    public static Job__c getManualJob(Id opportunityId, Id userId){
        Job__c job = new Job__c(Opportunity__c = opportunityId, Project_Manager__c = userId);
        return job;
    }
    
    public static Bureau_Candidate__c getCandidate(Id jobId, String statusValue, String emailValue){
        Bureau_Candidate__c candidate = new Bureau_Candidate__c(Category__c='Self',
                                                                First_Name__c='malin ',
                                                                Last_Name__c='Gusatsson',
                                                                Email__c=emailValue,
                                                                Gender__c='Female',
                                                                Phone_Number__c='9876543211',
                                                                Country__c='United Kingdom',
                                                                Language__c='',
                                                                Status2__c=statusValue,
                                                                Reports_Status__c='Unsent',
                                                                Username__c='',
                                                                Product_Assessment__c='SHL 360',
                                                                System_s__c='SHL 360',
                                                                Email_as_Username__c=false,
                                                                Bureau_Job__c=jobId,
                                                                Candidate_Unique_Id__c=jobId+'malin Gusatsson'+emailValue);
        return candidate;
    }
    
    public static list<Bureau_Candidate__c> getCandidateList(){
        return new list<Bureau_Candidate__c>();
    } 

    @future
    public static void insertQueue() {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'MS_Task__c');
        insert q1;
    }
    
    @future
    public static void insertProjectManagerUser(String MS_LOB) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User futureUser = new User(firstname = 'Future', lastname = 'User',
            alias = 'future', defaultgroupnotificationfrequency = 'N',
            digestfrequency = 'N', email = uniqueName + '@test' + orgId + '.org',
            emailencodingkey = 'UTF-8', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey = 'America/Los_Angeles',
            Username = uniqueName + '@test' + orgId + '.org',
            userpermissionsmarketinguser = false,
            userpermissionsofflineuser = false,
            MS_LOB__c = MS_LOB);
        insert futureUser;
    }
    
    public static Work_Request__c getGeneratedWRF(String accountId,String jobId){
        String formDetails = '[{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Name","index":1,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Email","index":2,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Launch Date","index":3,"showHelpTextArea":true,"showEditFields":false,"helpText":"Please allow at least 2 full working days","isRequired":true,"showTextFieldArea":false},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Deadline Date","index":4,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Dates","index":5,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Reminder Dates","index":6,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Name(s)","index":7,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Email address(es)","index":8,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Name(s)","index":9,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Email address(es)","index":10,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"dropdown","isnormal":false,"istextarea":false,"isrichtexarea":false,"ispicklist":true,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Assessment Package","index":12,"showTextFieldArea":false,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true},{"fieldtype":"Textarea","isnormal":false,"istextarea":true,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Additional Instructions (If any)","index":11,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false}]';
        String candidateDetails = '[{"Label__c":"Category","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Category__c","fieldLabel":"Category","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":1,"isReporting":true},{"Label__c":"First Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"First_Name__c","fieldLabel":"First Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":2,"isReporting":true},{"Label__c":"Last Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Last_Name__c","fieldLabel":"Last Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":3,"isReporting":true},{"Label__c":"Email","Data_Type__c":"email","Values__c":"undefined","API_Name__c":"Email__c","fieldLabel":"Email","fieldtype":"email","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":4,"isReporting":true}]';
        String systemSelected = 'TalentCentral+';
        String textUnderLogo = 'Testing';
        String wrfClientName = 'Test Class';
        String Solution = 'Graduate Essential';
        String candidateInstruction = 'Testing';
        Work_Request__c req = new Work_Request__c();
            if(formDetails !='' && formDetails != null){
                req.Field_Configuration__c = formDetails; 
                req.System_Used__c = systemSelected;
                req.Account__c = accountId;
                //req.RecordTypeId = System.label.Work_Request_Generated_RecordType_ID;
                req.RecordTypeId = Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Generated').getRecordTypeId();
                req.Work_Request_Type__c = 'MS Generated';
                req.Link_Generated_Date__c = Date.Today();
                req.Job_Id_System_Used__c = jobId;
                req.Text_Under_Logo__c =textUnderLogo;
                req.WRF_Client_Name__c = wrfClientName;
                req.Candidate_Template_Instructions__c = candidateInstruction;
            if(candidateDetails !='' && candidateDetails != null)
                req.Candidate_Field_Configuration__c = candidateDetails;
            }
            insert req;
        return req;
            
    }
    
    public static Work_Request__c getSubmittedWRF(String recordId,String FileId){
            String formDetails = '[{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Name","index":1,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Email","index":2,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Launch Date","index":3,"showHelpTextArea":true,"showEditFields":false,"helpText":"Please allow at least 2 full working days","isRequired":true,"showTextFieldArea":false},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Deadline Date","index":4,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Dates","index":5,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Reminder Dates","index":6,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Name(s)","index":7,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Email address(es)","index":8,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Name(s)","index":9,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Email address(es)","index":10,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"dropdown","isnormal":false,"istextarea":false,"isrichtexarea":false,"ispicklist":true,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Assessment Package","index":12,"showTextFieldArea":false,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true},{"fieldtype":"Textarea","isnormal":false,"istextarea":true,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Additional Instructions (If any)","index":11,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false}]';
            //String candidateDetails = '[{"Label__c":"Category","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Category__c","fieldLabel":"Category","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":1,"isReporting":true},{"Label__c":"First Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"First_Name__c","fieldLabel":"First Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":2,"isReporting":true},{"Label__c":"Last Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Last_Name__c","fieldLabel":"Last Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":3,"isReporting":true},{"Label__c":"Email","Data_Type__c":"email","Values__c":"undefined","API_Name__c":"Email__c","fieldLabel":"Email","fieldtype":"email","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":4,"isReporting":true}]';
        	Integer candidateRequestedCount = 10;
            String RequestorName = 'Testing firstname';
            String RequestorEmail = 'Testing@test.com';   
        	Integer participantRequestedCount = 10;
        	String candidateRequestType = 'Manual';
            Work_Request__c generatedRequest = [select id,Account__c,System_Used__c,Job_Id_System_Used__c,WRF_Link__c,WRF_Client_Name__c,No_of_WR_submitted__c,No_of_Candidate_Requested__c,No_of_Participant_Requested__c,Candidate_Requested_Backend_Use__c from Work_Request__c where id=:recordId limit 1];
            Work_Request__c submittedRequest = new Work_Request__c();
            Job__c relatedJob = [select id,System_Used__c,Project_Manager__c,Sender_Email__c,Billing_Cycle_End_Date__c,opportunity__c,Project_Manager__r.email,Account__r.Is_Repeatable_Business__c,Client_Domain__c,Billing_Frequency__c,recordtypeid,Is_GCSC_Opp__c from job__c where id=:generatedRequest.Job_Id_System_Used__c limit 1];
            submittedRequest.Status__c = 'Open';
            submittedRequest.Field_Configuration__c = formDetails;
        	System.debug('Id in Test Class '+generatedRequest.Id);
        	System.debug('Id in Test Class '+recordId);
            submittedRequest.Work_Request_Generated__c = generatedRequest.Id;
            submittedRequest.RecordtypeId = Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Submitted').getRecordTypeId();
            if(RequestorEmail.contains('shl.com')){
                submittedRequest.Work_Request_Type__c = 'Internal Submission';
            }
            else{
                submittedRequest.Work_Request_Type__c = 'Client Submitted';
            }
            submittedRequest.Link_Generated_Date__c = Date.Today();
            submittedRequest.System_Used__c = generatedRequest.System_Used__c;
            submittedRequest.Account__c = generatedRequest.Account__c;
            submittedRequest.WRF_Link__c = generatedRequest.WRF_Link__c;
            submittedRequest.Job__c = generatedRequest.Job_Id_System_Used__c;
            submittedRequest.Requestor_Name__c = RequestorName;
            submittedRequest.Requestor_Email__c = RequestorEmail;
            submittedRequest.Candidate_Field_Configuration__c = FileId;
            submittedRequest.No_of_Candidate_Requested__c = candidateRequestedCount;
            submittedRequest.No_of_Participant_Requested__c	 = participantRequestedCount;
            submittedRequest.Candidate_Requested_Backend_Use__c = candidateRequestedCount;
            submittedRequest.WRF_Client_Name__c = generatedRequest.WRF_Client_Name__c;
            submittedRequest.Candidate_Request_Type_Backend_Use__c = candidateRequestType;
            insert submittedRequest;
            return submittedRequest;
        
    }
    
    public static Work_Request__c getSubmittedWRFWithNoFile(String recordId){
            String formDetails = '[{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Name","index":1,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Email","index":2,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Launch Date","index":3,"showHelpTextArea":true,"showEditFields":false,"helpText":"Please allow at least 2 full working days","isRequired":true,"showTextFieldArea":false},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Deadline Date","index":4,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Dates","index":5,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Reminder Dates","index":6,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Name(s)","index":7,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Email address(es)","index":8,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Name(s)","index":9,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Email address(es)","index":10,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"dropdown","isnormal":false,"istextarea":false,"isrichtexarea":false,"ispicklist":true,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Assessment Package","index":12,"showTextFieldArea":false,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true},{"fieldtype":"Textarea","isnormal":false,"istextarea":true,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Additional Instructions (If any)","index":11,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false}]';
        	Integer candidateRequestedCount = 10;
            String RequestorName = 'Testing firstname';
            String RequestorEmail = 'Testing@test.com';   
        	Integer participantRequestedCount = 10;
        	String candidateRequestType = 'Manual';
            Work_Request__c generatedRequest = [select id,Account__c,System_Used__c,Job_Id_System_Used__c,WRF_Link__c,WRF_Client_Name__c,No_of_WR_submitted__c,No_of_Candidate_Requested__c,No_of_Participant_Requested__c,Candidate_Requested_Backend_Use__c from Work_Request__c where id=:recordId limit 1];
            Work_Request__c submittedRequest = new Work_Request__c();
            Job__c relatedJob = [select id,System_Used__c,Project_Manager__c,Sender_Email__c,Billing_Cycle_End_Date__c,opportunity__c,Project_Manager__r.email,Account__r.Is_Repeatable_Business__c,Client_Domain__c,Billing_Frequency__c,recordtypeid,Is_GCSC_Opp__c from job__c where id=:generatedRequest.Job_Id_System_Used__c limit 1];
            submittedRequest.Status__c = 'Open';
            submittedRequest.Field_Configuration__c = formDetails;
            submittedRequest.Work_Request_Generated__c = generatedRequest.Id;
            submittedRequest.RecordtypeId = Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Submitted').getRecordTypeId();
            if(RequestorEmail.contains('shl.com')){
                submittedRequest.Work_Request_Type__c = 'Internal Submission';
            }
            else{
                submittedRequest.Work_Request_Type__c = 'Client Submitted';
            }
            submittedRequest.Link_Generated_Date__c = Date.Today();
            submittedRequest.System_Used__c = generatedRequest.System_Used__c;
            submittedRequest.Account__c = generatedRequest.Account__c;
            submittedRequest.WRF_Link__c = generatedRequest.WRF_Link__c;
            submittedRequest.Job__c = generatedRequest.Job_Id_System_Used__c;
            submittedRequest.Requestor_Name__c = RequestorName;
            submittedRequest.Requestor_Email__c = RequestorEmail;
            //submittedRequest.Candidate_Field_Configuration__c = FileId;
            submittedRequest.No_of_Candidate_Requested__c = candidateRequestedCount;
            submittedRequest.No_of_Participant_Requested__c	 = participantRequestedCount;
            submittedRequest.Candidate_Requested_Backend_Use__c = candidateRequestedCount;
            submittedRequest.WRF_Client_Name__c = generatedRequest.WRF_Client_Name__c;
            submittedRequest.Candidate_Request_Type_Backend_Use__c = candidateRequestType;
            insert submittedRequest;
            return submittedRequest;
        
    }
    
    public static list<Bureau_Rating__c> createRatings(List<Bureau_Candidate__c> candidateDataToInsert, Work_Request__c wrfRequest){
        try{
            list<Bureau_Rating__c> ratingInsertionList = new list<Bureau_Rating__c>();
            for (Bureau_Candidate__c item : candidateDataToInsert) {
                Bureau_Rating__c newRating = new Bureau_Rating__c();
                newRating.Rater_Type__c = 'Self';
                newRating.Participant__c = item.Id;
                newRating.Respondent__c = item.Id;
                newRating.TC_Status__c ='Not Started';
                newRating.TC_Report_Sent__c ='Not Sent';
                newRating.Reminder_1__c = 'Eligible';
                newRating.Work_Request__c = wrfRequest.Id;
                ratingInsertionList.add(newRating);
            }
            
            if(!ratingInsertionList.isEmpty()){
                try {
                    INSERT ratingInsertionList;
                }catch(DmlException dmlEx){
                    System.debug('Error inserting ratings: ' + dmlEx.getMessage());
                    throw new DmlException(dmlEx.getMessage());
                }
            }
            return ratingInsertionList;
        } catch (Exception ex) {
            System.debug('Unexpected error: ' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    public static Territory__c getTerritory(Id idAD, Id idBDM){
        Datetime variable=System.now();
        String Testname='Test Territory '+variable;
        Territory__c territory =new Territory__c(Name = Testname,Account_Director__c = idAD,Is_Active__c = true,Business_Development_Manager__c = idBDM, Region__c= 'India', Super_Region__c = 'India');
        return territory;
    }

    
}