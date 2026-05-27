@isTest(seeAllData = true)
Private Class CreateVariationTester{
    public static Account account;
    public static List<Contact> contacts;


    static testMethod void CreateVariationTest(){
    
    
            Test.startTest();
            Contract contract = new Contract();       
 
			Territory__c ter = new Territory__c();
        	ter.Name = 'Test';
        	insert ter;
        
            Account account=new Account(Industry='Agriculture',name='Test Account',Business_Relationship__c = 'New Logo (Never Traded)',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1',Territory__c=ter.Id);
            insert account;
            Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
            contacts = new List<Contact>();
            contacts.add(contact);
           
            insert contacts;
            contract.AccountId = account.Id;  
            contract.Legal_Order_Name__c = 'test'; 
            contract.CurrencyIsoCode = account.CurrencyIsoCode;
            contract.S2P_Reference_Required__c = 'New';
            contract.Status = 'Draft';        //Modified by Prabhat
            //contract.Status = 'Complete';       //Modified by Prabhat 
            contract.CustomerSignedDate = Date.Today();
            contract.StartDate = Date.Today();
            contract.ContractTerm = 6;   
            contract.Activated_Date__c=datetime.now();
            contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
            contract.Submission_Offset__c = 10;
            contract.Agreement__c = 'Order';
           contract.Subscription_Start_Date__c = system.today();
            insert contract;
            contract.Status  = 'Complete';
     
            //update contract;
            System.debug('ContractId*' + contract.id);
            
            Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR'  // SSE-10872
          opportunity2.ownerid=UserInfo.getUserId();
          opportunity2.StageName='Verbal';
          opportunity2.Billing_Contact__c=contact.id;
         opportunity2.Closedate=system.today();
        opportunity2.Primary_Contact__c=contact.id;
        opportunity2.CurrencyIsoCode='GBP';
        opportunity2.NVM_Credit_Card_ID__c='1234';
        opportunity2.Amount=1000;
//opportunity2.Pricebook2Id =standardPB.id;
        opportunity2.Variation_Opportunity__c='NO';
        opportunity2.OppUpdatedByOrderOn__c=Date.today();
        opportunity2.Original_Opportunity__c=null;
        opportunity2.Annual_Contract_Value__c=1000.00;
        opportunity2.Business_Type__c='Expansion';
        
        opportunity2.GCSC__c='Phone';        
        opportunity2.RecordTypeID=System.label.GCSCRecordType;
        opportunity2.Forecast_Category__c='Pipeline';         
        //insert opportunity2;

            System.debug('ContractId2*' + opportunity.Order_number__c);
          //  System.debug('ContractId3*' + opportunity.Order_number__r.Status);
            System.debug('Status*' + opportunity.Order_Status__c);           
            opportunity2.Order_number__c = contract.id;
            opportunity2.SkipValidationLeadConversion__c = true;
            opportunity2.StageName='Closed/Won';
        opportunity2.Order_activated_and_greater_than_zero__c = 'true';
            //update opportunity2;
            
           
            contract.Opportunity__c = opportunity2.id;
            //update contract;
            
          Order Ord=new order();
        Ord.AccountId= account.id;
        Ord.ContractId= contract.id;
        Ord.EffectiveDate=date.today();
        Ord.Status='Draft';
 Ord.OpportunityId = opportunity2.Id;
        //insert Ord;
  try{
            Ord.Status ='Activated';
            //update Ord;
            }
        Catch(Exception e){
        }   
            
            /*apexPages.standardcontroller std= new ApexPages.StandardController(opportunity2);
            
            PageReference pageref= Page.IgniteRecTypeSel_vfpage;
            Test.setCurrentPage(pageref);
            pageref.getParameters().put('id',opportunity2.id);
            
            system.debug('opportunityid'+opportunity.id);
        
            createVariation CV=new CreateVariation(std);
            PageReference ObjPgRef = CV.RecSelPage();
            List<SelectOption> ObjPgRef1 = CV.getItems();
            PageReference ObjPgRef2 = CV.Cancel();
            String St = CV.getRecordtype();
            
            cv.CloseDate = String.Valueof(System.today());
            cv.OppName = 'Test Opportunity';*/
            
            Test.stopTest();
    }
    
}