@isTest(SeeAllData=true)
private class Event_Tester
{
    static testMethod void testTriggers()
    {   
        Test.startTest();
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='System Administrator' limit 1];
        User usr = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        System.RunAs(usr){
            Event event = getNewEvent();
            event.StartDateTime = Datetime.Now().addHours(3);
            event.EndDateTime = event.StartDateTime.addHours(2);
            update event;
        }
        
        //added later
        // Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='System Administrator' limit 1];
        //User usr = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        System.RunAs(usr){
            Datetime variable=System.now();
            String Testname='Test Account'+variable;
            Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
            insert account;
            
            
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';
            
            insert contact;
            
            Contract cnt = new Contract(AccountId=account.Id,Agreement__c='Order',ContractTerm=12,Status='Draft',StartDate=date.today(),Invoicing_Contact__c=contact.Id,Contract_Type__c='Consulting',Subscription_Start_Date__c=system.today());
            insert cnt; 
            
            
            
            //cli.Start_date__c=system.today();
            //update cli;
            
            Test.stopTest();
            RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' limit 1];
            
            Pricebook2  p=[Select id,name from Pricebook2  where name='Master Price Book' limit 1 ];
            // pricebookentry PR1=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];
            Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
            opportunity.ownerid=UserInfo.getUserId();
            opportunity.AccountId=account.id;
            opportunity.Billing_Contact__c=contact.id;
            opportunity.Closedate=system.today();
            opportunity.Primary_Contact__c=contact.id;
            opportunity.CurrencyIsoCode='GBP';
            opportunity.Unconfirmed_Sun_Order_Number__c='1234';
            opportunity.NVM_Credit_Card_ID__c='1234';
            opportunity.Amount=1000;
            opportunity.Forecast_Category__c='Pipeline';
            opportunity.Business_Type__c = 'Cross-sell: subscription';
            opportunity.Business_Type__c='NBB - New Logo';
            opportunity.Variation_Opportunity__c='NO';
            opportunity.Original_Opportunity__c=null;
            opportunity.Annual_Contract_Value__c=1000.00;
            // opportunity.StageName='Making Contact';   
            opportunity.StageName='Prepare';   
            opportunity.GCSC__c='Phone';
            opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
            opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
            opportunity.RecordTypeID=RT.id;
            opportunity.Pricebook2Id=p.id;
            //opportunity.Business_Type__c='Renewal'   ;
            
            //opportunity.Variation_Opportunity__c = 'yes';
            //opportunity.Original_Opportunity__c=OriginalOpp.id;
            //opportunity.Original_Opportunity__r.Order_Number__c=contract2.id;
            opportunity.Client_Business_Function__c='IT';
            opportunity.Talent_Level__c='Professional / Individual Contributor';
            
            
            
            
            account=[Select id,name,Status__c,CurrencyISOCode,Billing_Address_Line_1__c,Billing_City__c,Billing_Country__c,Billing_State__c,Billing_ZIP_Postal_Code__c,BU__c from Account where id = :account.id];
            
            Contract contract2=new Contract(name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id,Subscription_Start_Date__c=system.today());
            insert contract2;
            //  Opportunity OriginalOpp= new Opportunity(RecordTypeID=RT.id,OwnerId=UserInfo.getUserId(),name='Test2 Opportunity',Billing_Contact__c=contact.id,NVM_Credit_Card_ID__c='1234',Unconfirmed_Sun_Order_Number__c='1234',CurrencyISOCode='AUD',Primary_Contact__c=contact.id, AccountID=account.id,StageName='making contact',closeDate=System.today());
            Opportunity OriginalOpp= new Opportunity(RecordTypeID=RT.id,OwnerId=UserInfo.getUserId(),name='Test2 Opportunity',Billing_Contact__c=contact.id,NVM_Credit_Card_ID__c='1234',Unconfirmed_Sun_Order_Number__c='1234',CurrencyISOCode='AUD',Primary_Contact__c=contact.id, AccountID=account.id,StageName='Prepare',closeDate=System.today(),Forecast_Category__c='Pipeline',Business_Type__c = 'Cross-sell: subscription');
            OriginalOpp.Order_Number__c=contract2.id;
            insert OriginalOpp;
            
            system.debug('**OwnerID**'+opportunity.ownerid);
            
            
            Contract contract=new Contract();
            
            opportunity.Order_Number__c=contract.id;
            //opp.StageName='Closing';
            opportunity.StageName='Drive Close';
            opportunity.Business_Type__c = 'Cross-sell: subscription';
            opportunity.Forecast_Category__c = 'Pipeline';
            opportunity.Original_Opportunity__c = OriginalOpp.Id;
            
            insert opportunity;
            
            pricebookentry PR=[select id,Pricebook2.name,Product2.Revenue_Category__c from 
                               Pricebookentry where IsActive=true and Pricebook2.name = 'Master Price Book' 
                               AND Product2.Revenue_Category__c != 'Subscription' AND product2.Family!= 'Product'
                               AND currencyIsoCode='GBP' limit 1]; //and name='DevelopmentCoach'
            
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity.id,Total_Equivalent_Units__c=12,
                                                           PricebookEntryId=PR.id,Basis_of_Fees__c='Units',
                                                           Platform__c='MFS',
                                                           TotalPrice=100,Quantity=1);
            
            insert LI;
            //LI.PricebookEntry.Pricebook2ID='xxxxxxx';
            /*
try{
update opp;
}
catch (exception ex){
} */
            
            //Event event = getNewEvent();
            Event event = new Event();
            event.StartDateTime = Datetime.Now().addHours(3);
            event.EndDateTime = event.StartDateTime.addHours(2);
            
            insert event;
            
            //added later
        }
        
    }
    
    static testMethod void testSendMail()
    {
        sendMail('This is my email message');
    }
    
    static Event getNewEvent()
    {
        
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' limit 1];
        Event event = new Event();
        event.OwnerId = userInfo.getUserId();
        event.StartDateTime = Datetime.Now().addHours(2);
        event.EndDateTime = event.StartDateTime.addHours(2);
        event.Send_email_to_assignee__c = true;
        Opportunity opp = new Opportunity(RecordTypeID=RT.id,Name='test opp',StageName='Prepare',CloseDate=Date.today(),Forecast_Category__c='Pipeline',Business_Type__c = 'Cross-sell: subscription');
        
        insert opp;
        event.whatId = opp.id;    
        insert event;
        return event;
        
        
    }    
    
    static void sendMail(string message)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'me@email1.com','you@email2.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('My Subject');
        mail.setUseSignature(false);
        mail.setHtmlBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
    
    static testMethod void testOpp()
    {
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        
        Contract contract2=new Contract(name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id,Subscription_Start_Date__c=system.today());
        insert contract2;
        
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        insert contact;
        
        Contract cnt = new Contract(AccountId=account.Id,Subscription_Start_Date__c=system.today(),Agreement__c='Order',ContractTerm=12,Status='Draft',StartDate=date.today(),Invoicing_Contact__c=contact.Id,Contract_Type__c='Consulting');
        insert cnt; 
        
        
        
        //cli.Start_date__c=system.today();
        //update cli;
        
        
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' limit 1];
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];
        system.debug('PriceBOOKTEST'+p.id);
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.AccountId=account.id;
        opportunity.Forecast_Category__c='Pipeline';
        opportunity.Business_Type__c = 'Cross-sell: subscription';
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        //oopportunity.StageName='Making Contact';   
        opportunity.StageName='Prepare';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Pricebook2Id=p.id;
        opportunity.Business_Type__c='Renewal'   ;
        
        //opportunity.Variation_Opportunity__c = 'yes';
        //opportunity.Original_Opportunity__c=OriginalOpp.id;
        //opportunity.Original_Opportunity__r.Order_Number__c=contract2.id;
        opportunity.Client_Business_Function__c='IT';
        opportunity.Talent_Level__c='Professional / Individual Contributor';
        
        
        
        
        
        //      Opportunity OriginalOpp= new Opportunity(RecordTypeID=RT.id,OwnerId=UserInfo.getUserId(),name='Test2 Opportunity',Billing_Contact__c=contact.id,NVM_Credit_Card_ID__c='1234',Unconfirmed_Sun_Order_Number__c='1234',CurrencyISOCode='AUD',Primary_Contact__c=contact.id, AccountID=account.id,StageName='making contact',closeDate=System.today());
        Opportunity OriginalOpp= new Opportunity(RecordTypeID=RT.id,OwnerId=UserInfo.getUserId(),name='Test2 Opportunity',Billing_Contact__c=contact.id,NVM_Credit_Card_ID__c='1234',Unconfirmed_Sun_Order_Number__c='1234',CurrencyISOCode='AUD',Primary_Contact__c=contact.id, AccountID=account.id,StageName='Prepare',closeDate=System.today(),Forecast_Category__c='Pipeline',Business_Type__c = 'Cross-sell: subscription');
        OriginalOpp.Order_Number__c=contract2.id;
        insert OriginalOpp;
        
        system.debug('**OwnerID**'+opportunity.ownerid);
        
        
        Contract contract=new Contract();
        
        opportunity.Order_Number__c=contract.id;
        
        opportunity.StageName='Drive Close';
        
        insert opportunity;
        
        pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];
        
        OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity.id,PricebookEntryId=PR.id,TotalPrice=100,Quantity=1);
        test.startTest();
        
        try{
            Event event1 = new Event();
            event1.StartDateTime = Datetime.Now().addHours(2);
            event1.EndDateTime = event1.StartDateTime.addHours(2);
            event1.Event_Category__c='First sales introduction' ;
            event1.Event_Type__c='Sales' ;
            event1.Status__c='Completed';
            event1.whatId = opportunity.id;
            event1.Status__c='Pending';
            event1.whoid=  contact.id; 
            insert event1;
            event1.StartDateTime = Datetime.Now().addHours(3);
            event1.EndDateTime = event1.StartDateTime.addHours(3);
            event1.Event_Category__c='First sales introduction' ;
            event1.Event_Type__c='Sales' ;
            event1.Status__c='Completed';
            event1.whatId = opportunity.id;
            event1.whoid=  contact.id; 
            update event1;     
            
            Event event = new Event();
            event.StartDateTime = Datetime.Now().addHours(3);
            event.EndDateTime = event.StartDateTime.addHours(2);
            event.whatId = opportunity.id;
            event.whoid=  contact.id;   
            event.Status__c='Pending';
            // opportunity.StageName='Drive Close';
            event.Event_Category__c='First sales introduction' ;
            event.Event_Type__c='Sales' ;
            event.Status__c='Completed';
            insert event;
            event.whatId = opportunity.id;
            event.Status__c='Pending';
            event.whoid=  contact.id; 
            event.EndDateTime = event.StartDateTime.addHours(2);
            event.StartDateTime = Datetime.Now().addHours(3);
            //update event;  
        }
        catch(Exception ex)
        {
            
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
            
        }
        
        test.stoptest();
    }
    
    /* static testMethod void testOpp1()
{     Datetime variable=System.now();
String Testname='Test Account'+variable;
Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
insert account;

Contract contract2=new Contract(name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
insert contract2;

Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
contact.Same_As_The_Account_Billing_Address__c=true;
contact.Mailing_Address_Line_1__c ='test';
contact.Mailing_City__c='test';
contact.Mailing_ZIP_Postal_Code__c ='110094';
contact.Mailing_Country__c='India';

insert contact;

Contract cnt = new Contract(AccountId=account.Id,Agreement__c='Order',ContractTerm=12,Status='Draft',StartDate=date.today(),Invoicing_Contact__c=contact.Id,Contract_Type__c='Consulting');
insert cnt; 



//cli.Start_date__c=system.today();
//update cli;


RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' limit 1];

Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];

Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
opportunity.ownerid=UserInfo.getUserId();
opportunity.Forecast_Category__c='Forecast';
//opportunity.Business_Type__c='NBB - New Logo';
opportunity.AccountId=account.id;
opportunity.Billing_Contact__c=contact.id;
opportunity.Closedate=system.today();
opportunity.Primary_Contact__c=contact.id;
opportunity.CurrencyIsoCode='AUD';
opportunity.Unconfirmed_Sun_Order_Number__c='1234';
opportunity.NVM_Credit_Card_ID__c='1234';
opportunity.Amount=1000;
opportunity.Variation_Opportunity__c='NO';
opportunity.Original_Opportunity__c=null;
opportunity.Annual_Contract_Value__c=1000.00;
//oopportunity.StageName='Making Contact';   
opportunity.StageName='Prepare';   
opportunity.GCSC__c='Phone';
opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
opportunity.RecordTypeID=RT.id;
opportunity.Pricebook2Id=p.id;
opportunity.Business_Type__c='Renewal'   ;
opportunity.CreatedDate=date.today();

//    opportunity.Variation_Opportunity__c = 'yes';
//    opportunity.Original_Opportunity__c=OriginalOpp.id;
//    opportunity.Original_Opportunity__r.Order_Number__c=contract2.id;
opportunity.Client_Business_Function__c='IT';
opportunity.Talent_Level__c='Professional / Individual Contributor';


//      Opportunity OriginalOpp= new Opportunity(RecordTypeID=RT.id,OwnerId=UserInfo.getUserId(),name='Test2 Opportunity',Billing_Contact__c=contact.id,NVM_Credit_Card_ID__c='1234',Unconfirmed_Sun_Order_Number__c='1234',CurrencyISOCode='AUD',Primary_Contact__c=contact.id, AccountID=account.id,StageName='making contact',closeDate=System.today());
Opportunity OriginalOpp= new Opportunity(RecordTypeID=RT.id,OwnerId=UserInfo.getUserId(),name='Test2 Opportunity',Billing_Contact__c=contact.id,NVM_Credit_Card_ID__c='1234',Unconfirmed_Sun_Order_Number__c='1234',CurrencyISOCode='AUD',Primary_Contact__c=contact.id, AccountID=account.id,StageName='Prepare',closeDate=System.today(),Forecast_Category__c='Forecast',Business_Type__c='NBB - New Logo');
OriginalOpp.Order_Number__c=contract2.id;
insert OriginalOpp;

system.debug('**OwnerID**'+opportunity.ownerid);


Contract contract=new Contract();

opportunity.Order_Number__c=contract.id;
//opp.StageName='Closing';
opportunity.StageName='Drive Close';

insert opportunity;

opportunity.Client_Business_Function__c='IT';
opportunity.Talent_Level__c='Professional / Individual Contributor';

RecordType RT1=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' AND RecordType.Name='GCSC Opportunity' limit 1];

Opportunity orgOpportunity=new Opportunity(name='Test Opportunity3', AccountID=account.id);
orgOpportunity.Forecast_Category__c='Forecast';
orgOpportunity.Business_Type__c='NBB - New Logo';
orgOpportunity.ownerid=UserInfo.getUserId();
orgOpportunity.AccountId=account.id;
orgOpportunity.Billing_Contact__c=contact.id;
orgOpportunity.Closedate=system.today();
orgOpportunity.Primary_Contact__c=contact.id;
orgOpportunity.CurrencyIsoCode='USD';
orgOpportunity.Unconfirmed_Sun_Order_Number__c='1234';
orgOpportunity.NVM_Credit_Card_ID__c='1234';
orgOpportunity.Amount=1000;
orgOpportunity.Likelihood__c='70%';
orgOpportunity.Variation_Opportunity__c='NO';
orgOpportunity.Annual_Contract_Value__c=1000.00;
orgOpportunity.TM_Phase__c='Pre-Hire';   
orgOpportunity.StageName='New';   
orgOpportunity.GCSC__c='Phone';
orgOpportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
orgOpportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
orgOpportunity.RecordTypeID=RT1.id;
orgOpportunity.Pricebook2Id=p.id;
//orgOpportunity.Business_Type__c='Renewal';
orgOpportunity.Order_Number__c=contract.id;
//orgOpportunity.Closed_Lost_Reason__c= 'Finance Drop';
insert orgOpportunity;

Opportunity opportunity1=new Opportunity(name='Test Opportunity', AccountID=account.id);
Opportunity1.Forecast_Category__c='Forecast';
//Opportunity1.Business_Type__c='Renewal';
opportunity1.ownerid=UserInfo.getUserId();
opportunity1.AccountId=account.id;
opportunity1.Billing_Contact__c=contact.id;
opportunity1.Closedate=system.today();
opportunity1.Primary_Contact__c=contact.id;
opportunity1.CurrencyIsoCode='AUD';
opportunity1.Unconfirmed_Sun_Order_Number__c='1234';
opportunity1.NVM_Credit_Card_ID__c='1234';
opportunity1.Amount=1000;
opportunity1.Variation_Opportunity__c='NO';
opportunity1.Original_Opportunity__c=orgOpportunity.id;
opportunity1.Annual_Contract_Value__c=1000.00;       
opportunity1.StageName='Prepare';   
opportunity1.GCSC__c='Phone';
opportunity1.OpportunityAmountMappedWithLead__c = 323.34;//**********
opportunity1.OpportunityTypeMappedWithLead__c = 'New Business';//**********
opportunity1.RecordTypeID=RT1.id;
opportunity1.Pricebook2Id=p.id;
opportunity1.Order_Number__c=contract.id;
opportunity1.Business_Type__c='Renewal';
opportunity1.CreatedDate=date.today();
insert opportunity1; 

RecordType RT2=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' limit 1];


Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id);
Opportunity2.Forecast_Category__c='Forecast';
//Opportunity2.Business_Type__c='NBB - New Logo';
opportunity2.ownerid=UserInfo.getUserId();
opportunity2.AccountId=account.id;
opportunity2.Billing_Contact__c=contact.id;
opportunity2.Closedate=system.today();
opportunity2.Primary_Contact__c=contact.id;
opportunity2.CurrencyIsoCode='AUD';
opportunity2.Unconfirmed_Sun_Order_Number__c='1234';
opportunity2.NVM_Credit_Card_ID__c='1234';
opportunity2.Amount=1000;
opportunity2.Variation_Opportunity__c='NO';
opportunity2.Original_Opportunity__c=orgOpportunity.id;
opportunity2.Annual_Contract_Value__c=1000.00;
//opportunity.StageName='Making Contact';   
opportunity2.StageName='Prepare';   
opportunity2.GCSC__c='Phone';
opportunity2.OpportunityAmountMappedWithLead__c = 323.34;//**********
opportunity2.OpportunityTypeMappedWithLead__c = 'New Business';//**********
opportunity2.RecordTypeID=RT2.id;
opportunity2.Pricebook2Id=p.id;
opportunity2.Order_Number__c=contract.id;
//opportunity2.Order_Number__c=null;
opportunity2.Business_Type__c='Renewal';
opportunity2.CreatedDate=date.today();

insert opportunity2;   

pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];

test.startTest();

List<Event> events= new List<Event>();
Event event1=[select id, StartDateTime,EndDateTime,Event_Category__c,Event_Type__c,Status__c,whatId,whoid from Event Limit 1];
event1.Event_Category__c='First sales introduction' ;
event1.Event_Type__c='Sales' ;
event1.Status__c='Completed';
event1.whatId = opportunity.id;
event1.whoid=  contact.id; 
event1.NBB_CrossSell_Events__c=false;
system.debug('Startdateoutput'+event1.StartDateTime);
//update event1;


Event event = new Event();
event.StartDateTime = Datetime.Now().addHours(1);
event.EndDateTime = event.StartDateTime.addHours(2);
event.whatId = opportunity.id;
event.whoid=  contact.id;   
//event.Target_Date__c=date.today();
event.Event_Category__c='First sales introduction' ;
event.Event_Type__c='Sales' ;
event.Status__c='Completed';
events.add(event);

Event event2 = new Event();
event2.StartDateTime = Datetime.Now().addHours(1);
event2.EndDateTime = event.StartDateTime.addHours(2);
event2.whatId = opportunity1.id;
event2.whoid=  contact.id;   
event2.Event_Category__c='Onboarding';
event2.Event_Type__c='Account Management' ;
event2.Status__c='Pending';
event2.Send_email_to_assignee__c=true;
event2.NBB_CrossSell_Events__c=false;
event2.OwnerId=UserInfo.getUserId();
events.add(event2);
ProjectObject__c project = [Select id from ProjectObject__c where RecordTypeId='012D0000000VAFcIAO' and Project_Status__c!='Closed/Delivered' limit 1];
Event event3 = new Event();
event3.StartDateTime = Datetime.Now().addHours(1);
event3.EndDateTime = event.StartDateTime.addHours(2);
event3.whatId = project.id;
event3.whoid=  contact.id;   
event3.Event_Category__c='Onboarding';
event3.Event_Type__c='Account Management' ;
event3.Status__c='Pending';
event3.NBB_CrossSell_Events__c=false;
events.add(event3);

Event event4 = new Event();
event4.StartDateTime = Datetime.Now().addHours(1);
event4.EndDateTime = event4.StartDateTime.addHours(2);
event4.whatId = opportunity2.id;
event4.whoid=  contact.id;   
event4.Event_Category__c='Onboarding';
event4.Event_Type__c='Account Management' ;
event4.Status__c='Pending';
event4.NBB_CrossSell_Events__c=false;
events.add(event4);

insert events;
event2.StartDateTime = Datetime.Now().addHours(3);
event2.EndDateTime = event2.StartDateTime.addHours(4);
event2.OwnerId='00520000000hIsYAAU';
event2.Send_email_to_assignee__c=true;
update event2;  

test.stoptest();
} */    
    
    static testmethod void TestEvent1(){
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        
        Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        
        Contract contract2=new Contract(name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id,Subscription_Start_Date__c=system.today());
        insert contract2;
        
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        insert contact;
        
        Contract cnt = new Contract(AccountId=account.Id,Agreement__c='Order',ContractTerm=12,Status='Draft',StartDate=date.today(),Invoicing_Contact__c=contact.Id,Contract_Type__c='Consulting',Subscription_Start_Date__c=system.today());
        insert cnt; 
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' limit 1];
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];
        
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.Forecast_Category__c='Pipeline';
        opportunity.Business_Type__c = 'Cross-sell: subscription';
        opportunity.AccountId=account.id;
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        //oopportunity.StageName='Making Contact';   
        opportunity.StageName='Prepare';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Pricebook2Id=p.id;
        opportunity.Business_Type__c='Renewal'   ;
        opportunity.CreatedDate=date.today();
        opportunity.Client_Business_Function__c='IT';
        opportunity.Talent_Level__c='Professional / Individual Contributor';
        Opportunity OriginalOpp= new Opportunity(RecordTypeID=RT.id,OwnerId=UserInfo.getUserId(),name='Test2 Opportunity',Billing_Contact__c=contact.id,NVM_Credit_Card_ID__c='1234',Unconfirmed_Sun_Order_Number__c='1234',CurrencyISOCode='AUD',Primary_Contact__c=contact.id, AccountID=account.id,StageName='Prepare',closeDate=System.today(),Forecast_Category__c='Pipeline',Business_Type__c = 'Cross-sell: subscription');
        OriginalOpp.Order_Number__c=contract2.id;
        insert OriginalOpp;
        Contract contract=new Contract();
        opportunity.Order_Number__c=contract.id;
        opportunity.StageName='Drive Close';
        
        insert opportunity;
        
        test.startTest();
        List<Event> events= new List<Event>();
        Event event1 = new Event();
        event1.StartDateTime = Datetime.Now().addHours(1);
        event1.EndDateTime = event1.StartDateTime.addHours(2);
        insert event1;
        //Event event1=[select id, StartDateTime,EndDateTime,Event_Category__c,Event_Type__c,Status__c,whatId,whoid from Event Limit 1];
        event1.Event_Category__c='First sales introduction' ;
        event1.Event_Type__c='Sales' ;
        event1.Status__c='Completed';
        event1.whatId = opportunity.id;
        event1.whoid=  contact.id; 
        event1.NBB_CrossSell_Events__c=false;
        system.debug('Startdateoutput'+event1.StartDateTime);
        update event1;
        test.stopTest();       
        
        
    }
    
    static testmethod void TestEvent2(){
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        
        Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        
        Contract contract2=new Contract(name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id,Subscription_Start_Date__c=system.today());
        insert contract2;
        
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        insert contact;
        
        test.startTest();   
        //ProjectObject__c project = [Select id from ProjectObject__c where RecordTypeId='012D0000000VAFcIAO' and Project_Status__c!='Closed/Delivered' limit 1];
        ProjectObject__c project = new ProjectObject__c();
            project.Project_Name__c = 'project_';
            project.Account__c = contact.AccountId;
            project.Contact__c = contact.Id;
            project.Billing_Contact__c = contact.Id;
           	//project.Project_Manager__c = UserInfo.getUserId();
          	project.RecordTypeId = '012D0000000VAFcIAO';
        
        insert project;
        Event event3 = new Event();
        event3.StartDateTime = Datetime.Now().addHours(1);
        event3.EndDateTime = event3.StartDateTime.addHours(2);
        event3.whatId = project.id;
        event3.whoid=  contact.id;   
        event3.Event_Category__c='Onboarding';
        event3.Event_Type__c='Account Management' ;
        event3.Status__c='Pending';
        event3.NBB_CrossSell_Events__c=false;
        insert event3;
        
        test.stopTest();
        
    }
    
    static testmethod void TestEvent3(){
        RecordType RT1=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' AND RecordType.Name='GCSC Opportunity' limit 1];
        Pricebook2  p=[Select id,name from Pricebook2  where name='Master Price Book' limit 1 ];
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        Contract contract2=new Contract(name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id,Subscription_Start_Date__c=system.today());
        insert contract2;
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        insert contact;
        Contract contract=new Contract();
        Opportunity orgOpportunity=new Opportunity(name='Test Opportunity3', AccountID=account.id);
        orgOpportunity.Forecast_Category__c='Pipeline';
        orgOpportunity.Business_Type__c = 'Cross-sell: subscription';
        orgOpportunity.ownerid=UserInfo.getUserId();
        orgOpportunity.AccountId=account.id;
        orgOpportunity.Billing_Contact__c=contact.id;
        orgOpportunity.Closedate=system.today();
        orgOpportunity.Primary_Contact__c=contact.id;
        orgOpportunity.CurrencyIsoCode='USD';
        orgOpportunity.Unconfirmed_Sun_Order_Number__c='1234';
        orgOpportunity.NVM_Credit_Card_ID__c='1234';
        orgOpportunity.Amount=1000;
        orgOpportunity.Likelihood__c='70%';
        orgOpportunity.Variation_Opportunity__c='NO';
        orgOpportunity.Annual_Contract_Value__c=1000.00;
        orgOpportunity.TM_Phase__c='Pre-Hire';   
        orgOpportunity.StageName='New';   
        orgOpportunity.GCSC__c='Phone';
        orgOpportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        orgOpportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        orgOpportunity.RecordTypeID=RT1.id;
        orgOpportunity.Pricebook2Id=p.id;
        //orgOpportunity.Business_Type__c='Renewal';
        orgOpportunity.Order_Number__c=contract.id;
        //orgOpportunity.Closed_Lost_Reason__c= 'Finance Drop';
        insert orgOpportunity;
        
        Opportunity opportunity1=new Opportunity(name='Test Opportunity', AccountID=account.id);
        Opportunity1.Forecast_Category__c='Pipeline';
        Opportunity1.Business_Type__c = 'Cross-sell: subscription';
        opportunity1.ownerid=UserInfo.getUserId();
        opportunity1.AccountId=account.id;
        opportunity1.Billing_Contact__c=contact.id;
        opportunity1.Closedate=system.today();
        opportunity1.Primary_Contact__c=contact.id;
        opportunity1.CurrencyIsoCode='AUD';
        opportunity1.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity1.NVM_Credit_Card_ID__c='1234';
        opportunity1.Amount=1000;
        opportunity1.Variation_Opportunity__c='NO';
        opportunity1.Original_Opportunity__c=orgOpportunity.id;
        opportunity1.Annual_Contract_Value__c=1000.00;       
        opportunity1.StageName='Prepare';   
        opportunity1.GCSC__c='Phone';
        opportunity1.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity1.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity1.RecordTypeID=RT1.id;
        opportunity1.Pricebook2Id=p.id;
        opportunity1.Order_Number__c=contract.id;
        opportunity1.Business_Type__c='Renewal';
        opportunity1.CreatedDate=date.today();
        insert opportunity1; 
        test.startTest();   
        Event event2 = new Event();
        event2.StartDateTime = Datetime.Now().addHours(1);
        event2.EndDateTime = event2.StartDateTime.addHours(2);
        event2.whatId = opportunity1.id;
        event2.whoid=  contact.id;   
        event2.Event_Category__c='Onboarding';
        event2.Event_Type__c='Account Management' ;
        event2.Status__c='Pending';
        event2.Send_email_to_assignee__c=true;
        event2.NBB_CrossSell_Events__c=false;
        event2.OwnerId=UserInfo.getUserId();
        insert event2;
        
        event2.StartDateTime = Datetime.Now().addHours(3);
        event2.EndDateTime = event2.StartDateTime.addHours(4);
        event2.OwnerId='00520000000hIsYAAU';
        event2.Send_email_to_assignee__c=true;
        update event2;  
        
        test.stopTest();
    }
    
    static testMethod void testEventProgress(){
        
        String Testname='Test Account';
        Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        
        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=account.Id);
        insert accPlan;
        
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress');
        insert stgoal;
        
        Event event = new Event();
        event.OwnerId = userInfo.getUserId();
        event.StartDateTime = Datetime.Now().addHours(2);
        event.EndDateTime = event.StartDateTime.addHours(2);
        event.whatId = stgoal.id;  
        event.Is_Completed__c = true;
        insert event;
        
        event.EndDateTime = Datetime.Now().addDays(2);
        update event;
        
        delete event;
    }
}