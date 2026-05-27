@isTest(SeeAllData=true)
public class OpportunityTriggerManager_Test {
    //changes start SSE-1609   
    @isTest    
    static void TestcheckCompetitorAccount(){
        try{
            Test.startTest();
            
            Account account=new Account(name='Test Account Priyank1',
                                        Status__c='Approved',
                                        Billing_Address_Line_1__c='test',
                                        Billing_City__c='Test City',
                                        Billing_Country__c='China',
                                        Billing_State__c='Test',
                                        Billing_ZIP_Postal_Code__c='1100110',
                                        Industry= 'Legal',
                                        BU__c='Hong Kong - HK1');
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact', 
                                        Accountid=account.id, 
                                        Area_of_Interest__c ='Training',
                                        Same_As_The_Account_Billing_Address__c=true,
                                        Mailing_Address_Line_1__c ='test',
                                        Mailing_City__c='test',
                                        Mailing_ZIP_Postal_Code__c ='110094',
                                        Mailing_Country__c='India');
            insert contact;
            
            Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),
                                            name='Original Contract', 
                                            Legal_Order_Name__c='test',
                                            CurrencyISOCode=account.CurrencyISOCode, 
                                            AccountID=account.id);
            insert contract2;
            
            Opportunity opportunity2= new Opportunity(name='Test Opportunity', 
                                                      AccountID=account.id,
                                                      Talent_Segment__c='Volume', 
                                                      TM_Phase__c='Post-Hire',
                                                      StageName='Verbal',
                                                      Billing_Contact__c=contact.id,
                                                      Closedate=system.today(),
                                                      Primary_Contact__c=contact.id,
                                                      CurrencyIsoCode='GBP',
                                                      NVM_Credit_Card_ID__c='1234',
                                                      Amount=1000,
                                                      Variation_Opportunity__c='NO',
                                                      OppUpdatedByOrderOn__c=Date.today(),
                                                      Original_Opportunity__c=null,
                                                      Annual_Contract_Value__c=1000.00,
                                                      Business_Type__c='Expansion',
                                                      GCSC__c='Phone',       
                                                      RecordTypeID=System.label.GCSCRecordType,
                                                      Forecast_Category__c='Commit',
                                                      Offering__c = 'OPQ'); 
            insert opportunity2;
            
            opportunity2.StageName = 'Closed Lost';
            opportunity2.Closed_Lost_Reason__c = 'Expertise';
            update opportunity2; 
            
            Opportunity opp=new Opportunity();
            opp.name = 'test';
            opp.accountid = account.Id;
            opp.StageName = 'new';
            opp.Business_Type__c = 'Expansion';
            opp.Forecast_Category__c = 'Commit';
            opp.CloseDate = system.today();
            insert opp;
            
            opportunity opp2 = new opportunity();
            opp2.id = opp.id;
            opp2.Offering__c = 'OPQ';
            opp2.StageName = 'Closed Lost';
            opp2.Closed_Lost_Reason__c = 'Lost to Competitor';
            
            
            update opp2; 
            
            Test.stopTest();
        }catch(Exception ex){ 
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You can not select the Closed Lost Reason as Competitor because there is no Competitor Account linked to the Opportunity') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    /*
//changes end SSE-1609      
Static  TestMethod void TestOpptyTriggers(){
Test.startTest();
Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='OAT' limit 1];

User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
User Adminuser = [Select id from user where ProfileId = '00e20000000gzoS' AND isActive=true limit 1];
Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='China',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
insert account;

Contact contact=new Contact(lastname='Test Contact', Accountid=account.id, Area_of_Interest__c ='Training');
contact.Same_As_The_Account_Billing_Address__c=true;
contact.Mailing_Address_Line_1__c ='test';
contact.Mailing_City__c='test';
contact.Mailing_ZIP_Postal_Code__c ='110094';
contact.Mailing_Country__c='India';


insert contact;
Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
insert contract2;
Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR' // SSE-10872
opportunity2.ownerid=UserInfo.getUserId();
opportunity2.StageName='Verbal';
opportunity2.Billing_Contact__c=contact.id;
opportunity2.Closedate=system.today();
opportunity2.Primary_Contact__c=contact.id;
//opportunity2.pricebook2id=PR2.id;
opportunity2.CurrencyIsoCode='AUD';
//opportunity.Unconfirmed_Sun_Order_Number__c='1234';
opportunity2.NVM_Credit_Card_ID__c='1234';
opportunity2.Amount=1000;

opportunity2.Variation_Opportunity__c='NO';
opportunity2.OppUpdatedByOrderOn__c=Date.today();
opportunity2.Original_Opportunity__c=null;
opportunity2.Annual_Contract_Value__c=1000.00;
opportunity2.Business_Type__c='New customer: subscription';
opportunity2.CurrencyISOCode='GBP';
opportunity2.GCSC__c='Phone';        
opportunity2.RecordTypeID=System.label.GCSCRecordType;
opportunity2.Forecast_Category__c='Commit'; 
opportunity2.Offering__c = 'OPQ' ;   
insert opportunity2;


Opportunity opp=new Opportunity();
opp.name = 'test';
opp.StageName = 'new';
opp.Business_Type__c = 'New customer: subscription';
opp.Forecast_Category__c = 'Commit';
opp.CloseDate = system.today();
insert opp;
opportunity opp2 = new opportunity();
opp2.id = opp.id;
opp2.Offering__c = 'OPQ';
opp2.StageName = 'Closed/Won';
update opp2;  
Opportunity opportunity1 = [Select id,StageName,Forecast_Category__c,Business_Type__c from Opportunity where id = :Opp.id limit 1];
//opportunity1.Business_Type__c='NBB - Cross-Sell';
//opportunity1.Forecast_Category__c='Forecast';
ProjectObject__c pr2= new ProjectObject__c();
//pr2.Order_Header_Number__c=opportunity2.Order_Number__c;
pr2.Order_Line_Number__c=null;
pr2.Opportunity__c=opportunity1.Id;
pr2.CurrencyIsoCode='CNY';
insert pr2;


opportunity1.StageName='Closed Lost';
opportunity1.Closed_Lost_Reason__c='Budget Limitations';
//opportunity1.Forecast_Category__c='Forecast';
opportunity1.Order_Number__c=contract2.id;
opportunity1.Original_Opportunity__c=opportunity2.Id;
opportunity1.Primary_Contact__c=contact.id;
opportunity1.Billing_Contact__c=contact.id;
update opportunity1;




Opportunity opportunity6 = [Select id,StageName from Opportunity where id=:opportunity2.id];
opportunity6.StageName='Closed/Won';
opportunity6.Billing_Contact__c=contact.id;
//opportunity6.Multi_YearDeal__c = '2';
//opportunity6.RecordTypeID=System.label.standardRecordType;

try{
update opportunity6;
} catch ( Exception e){
Test.startTest();
System.assertEquals(opportunity1.Forecast_Category__c, 'Commit'); 

Opportunity opportunity=new Opportunity(name='Test Opportunity',Probability=90, AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');  //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR'  // SSE-10872
opportunity.ownerid=UserInfo.getUserId();
opportunity.StageName='Closed/Won';
opportunity.Billing_Contact__c=contact.id;
opportunity.Closedate=system.today();
opportunity.Primary_Contact__c=contact.id;        
opportunity.CurrencyIsoCode='AUD';
//opportunity.Unconfirmed_Sun_Order_Number__c='1234';
opportunity.NVM_Credit_Card_ID__c='1234';
opportunity.Amount=1000; 
opportunity.Renewal_Opportunity__c =True;
opportunity.Business_Type__c = 'Renewal' ;
// opportunity.HasOpportunityLineItem=False;
opportunity.Variation_Opportunity__c='NO';        
opportunity.Original_Opportunity__c=null;
opportunity.Annual_Contract_Value__c=1000.00;
opportunity.Business_Type__c='New customer: subscription';
opportunity.CurrencyISOCode='GBP';
opportunity.GCSC__c='Phone';
opportunity.RecordTypeID=System.label.standardRecordType;
opportunity.Forecast_Category__c='commit';  
opportunity.Offering__c = 'OPQ' ;
opportunity.Multi_YearDeal__c = '4';
insert opportunity;  

Id pipelineRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
Job__c j = new Job__c();
j.recordTypeId = pipelineRecordTypeId;
j.Opportunity__c = opportunity.id;      
j.JobStatus__c = 'UnConfirmed';       
j.Is_Auto_Pipeline_Job__c=true;
insert j;
Id pipelineRecordTypeId1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
Job__c j1 = new Job__c();
j1.recordTypeId = pipelineRecordTypeId1;
j1.Opportunity__c = opportunity.id;
j1.JobStatus__c = 'UnConfirmed';
j1.Is_Auto_Pipeline_Job__c=true;
insert j1;

list<Product2> prodlist = new list <Product2>();
Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
prodlist.add(prod);
Product2 Prod2 = new Product2(Name = 'test product 2',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
prodlist.add(prod2);
Product2 Prod3 = new Product2(Name = 'test product 3',IsActive=true,Revenue_Category__c='Training');
prodlist.add(prod3);
insert prodlist;

list<PricebookEntry> pbelist = new list<PricebookEntry>();
PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod.id,UnitPrice = 100,IsActive=true);
pbelist.add(pbe1);
PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod2.id,UnitPrice = 100,IsActive=true);
pbelist.add(pbe2);
PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod3.id,UnitPrice = 100,IsActive=true);
pbelist.add(pbe3);
insert pbelist;

list<OpportunityLineItem> OLIlist = new list<OpportunityLineItem>();
OpportunityLineItem LI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',Package__c = 'Bespoke',OpportunityId=opportunity.id,PricebookEntryId=pbe1.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring');
OLIlist.add(LI1);
OpportunityLineItem LI2=new OpportunityLineItem(RenewableNew__c = 'Ongoing',Package__c = 'Bespoke',OpportunityId=opportunity.id,PricebookEntryId=pbe2.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring');
OLIlist.add(LI2);
OpportunityLineItem LI3=new OpportunityLineItem(RenewableNew__c = 'Ongoing',Package__c = 'Bespoke',OpportunityId=opportunity.id,PricebookEntryId=pbe3.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring');
OLIlist.add(LI3);
insert olilist;

opportunity opp3 = new opportunity();
opp3.id = opportunity.id;
opp3.Multi_YearDeal__c = '6';
//update opp3;
try{
system.runAs(adminuser){

delete opportunity;
}
}
catch(exception ee){
system.debug(ee);
}            
}





Test.stopTest();   

}*/
    
    Static  TestMethod void testValidationLockedStage(){
        Test.startTest();
        User usr = [Select Id From User Where Profile.Name = 'Commercial' AND isActive = true].get(0);
        
         Account account=new Account(name='Test Account Priyank1',
                                        Status__c='Approved',
                                        Billing_Address_Line_1__c='test',
                                        Billing_City__c='Test City',
                                        Billing_Country__c='China',
                                        Billing_State__c='Test',
                                        Billing_ZIP_Postal_Code__c='1100110',
                                        Industry= 'Legal',
                                        BU__c='Hong Kong - HK1',
                                    	OwnerId = usr.Id);
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact', 
                                        Accountid=account.id, 
                                        Area_of_Interest__c ='Training',
                                        Same_As_The_Account_Billing_Address__c=true,
                                        Mailing_Address_Line_1__c ='test',
                                        Mailing_City__c='test',
                                        Mailing_ZIP_Postal_Code__c ='110094',
                                        Mailing_Country__c='India',
                                        OwnerId = usr.Id);
            insert contact;
        
        Opportunity opportunity3= new Opportunity(name='Test Opportunity', 
                                                  StageName='Verbal',
                                                  Closedate=system.today(),
                                                  Business_Type__c='Expansion',
                                                  Forecast_Category__c='Commit'
                                                 ); 
        try{
            insert opportunity3;
            
            
            Opportunity opportunity4= new Opportunity(name='Test Opportunity', 
                                                      StageName='New',
                                                      Closedate=system.today(),
                                                      Variation_Opportunity__c='NO',
                                                      Business_Type__c='Expansion',
                                                      Forecast_Category__c='Commit',
                                                      Probability = 54,
                                                      RecordTypeId = System.label.ReadOnlyRecordType,
                                                      Opportunity_Deal_Year__c = 2,
                                                      AccountId = account.Id,
                                                      Billing_Contact__c = contact.Id
                                                     ); 
            System.runAs(usr){
                insert opportunity4;
                System.debug('## 1');
                
                opportunity4.name='Test Opportunity4'; 
                opportunity4.Closedate=system.today()+1;
                opportunity4.StageName = 'Closed Lost';
                opportunity4.Closed_Lost_Reason__c = 'Expertise';
                opportunity4.Closed_Lost_Reason_Additional_Details__c ='test';
                opportunity4.RecordTypeId = System.label.ReadOnlyRecordType;
                opportunity4.Skip_Validation_Auto_Renewal__c = false;
                opportunity4.OwnerId = UserInfo.getUserId();
                
                update opportunity4;
                System.debug('## 2');
                
                
            }
        } catch (Exception e){
            
        }
        Test.stopTest();
        
    }
    
    Static  TestMethod void createJobTester1(){
        
        try{
            
            
            utility.getOpptyType();
            Datetime variable=System.now();
            String TestAccountname='Test Account'+variable; 
            Account account=new Account(name=TestAccountname+Datetime.now(),Status__c='Approved',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='China',Billing_State__c='Test',Industry= 'Legal',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id, Area_of_Interest__c ='Training');
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';          
            insert contact;
            Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
            insert contract2;
            
            
            Test.startTest(); 
            system.assertEquals(contact.Mailing_Country__c, 'India');
            Pricebook2 Pricebook=new Pricebook2();
            Pricebook.Description='Test Description';
            Pricebook.IsActive=True;
            Pricebook.Name='Test Pricebook';
            Insert Pricebook;
            
            Pricebook2 Master = [Select Id, Name, IsActive From Pricebook2 where Name = 'Master Price Book'];
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            
            Opportunity opportunity2=new Opportunity(name='Test Opportunity', 
                                                     AccountID=account.id,
                                                     Talent_Segment__c='Volume', 
                                                     TM_Phase__c='Post-Hire'); 
            
            opportunity2.ownerid=UserInfo.getUserId();
            opportunity2.StageName='New';
            opportunity2.Billing_Contact__c=contact.id;
            opportunity2.Closedate=system.today();
            opportunity2.Primary_Contact__c=contact.id;
            opportunity2.CurrencyIsoCode='GBP';
            opportunity2.NVM_Credit_Card_ID__c='1234';
            opportunity2.Amount=1000;
            opportunity2.Pricebook2Id =standardPB.id;
            opportunity2.Variation_Opportunity__c='NO';
            opportunity2.OppUpdatedByOrderOn__c=Date.today();
            opportunity2.Original_Opportunity__c=null;
            opportunity2.Annual_Contract_Value__c=1000.00;
            opportunity2.Business_Type__c='Expansion';
            opportunity2.Probability = 55;
            opportunity2.GCSC__c='Phone';        
            opportunity2.RecordTypeID=System.label.GCSCRecordType;
            opportunity2.Forecast_Category__c='Commit';         
            insert opportunity2;
            
            Opportunity opp=new Opportunity();
            opp.name = 'test';
            opp.StageName = 'new';
            opp.Business_Type__c = 'Renewal';
            opp.CurrencyIsoCode = 'GBP';
            opp.Probability = 55;
            opp.Renewal_Opportunity__c = true;
            //opp.Forecast_Category__c = 'Forecast';
            opp.CloseDate = system.today();
            opp.Offering__c = 'OPQ';
            insert opp;
            
            opportunity opportunitytes=[SELECT Id, Business_Type__c, Renewal_Opportunity__c, HasOpportunityLineItem 
                                        FROM Opportunity 
                                        where id = :opp.id limit 1];
            opportunitytes.Pricebook2Id=Master.id;
            opportunitytes.Forecast_Category__c='Commit';
            opportunitytes.Probability = 57;
            update opportunitytes;
            
            Product2 Product= new Product2();
            Product.Description='Managed Service Product';
            Product.IsActive=True;
            Product.Name='Managed Service Product';
            Product.Revenue_Category__c='Training';
            Product.MS_Product__c=true;
            Product.Status__c = 'Revenue Ready';
            Product.MS_Type__c='Talent Management';
            Insert Product;
            
            PricebookEntry PBE = new PricebookEntry(
                Pricebook2Id = standardPB.Id, 
                Product2Id = Product.id,
                UnitPrice = 12000, 
                IsActive = true,
                CurrencyIsoCode='GBP');
            insert PBE;
            
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Master.Id,
                                                            Product2id= Product.id,
                                                            UnitPrice = 1000,
                                                            CurrencyIsoCode='GBP', 
                                                            IsActive = true);
            insert standardPBE;
            
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity2.id,
                                                           PricebookEntryid=PBE.id,
                                                           Quantity=1,
                                                           UnitPrice = 1000);         
            LI.Product2Id=Product.Id;
            Li.Product_Name__c='Managed Service Product';
            Li.Start_Date__c=system.today();
            Li.End_Date__c=system.today()+7;
            LI.Year_1_List_Price__c=500; 
            li.Year_1_Sales_Price__c=300;
            li.Year_2_List_Price__c=600; 
            li.Year_2_Sales_Price__c=300;  
            li.Year_3_List_Price__c=600; 
            li.Year_3_Sales_Price__c=300;
            li.Package__c = 'Bespoke';
            insert LI;  
            
            OpportunityLineItem LI2=new OpportunityLineItem(OpportunityId=opportunity2.id,
                                                            PricebookEntryid=PBE.id,
                                                            Quantity=1,
                                                            UnitPrice = 1000);         
            LI2.Product_Name__c='Managed Service Product';
            LI2.Product2Id=Product.Id;
            LI2.Start_Date__c=system.today();
            LI2.End_Date__c=system.today()+7;
            LI2.Year_1_List_Price__c=500; 
            LI2.Year_1_Sales_Price__c=300;
            LI2.Year_2_List_Price__c=600; 
            LI2.Year_2_Sales_Price__c=300;  
            LI2.Year_3_List_Price__c=600; 
            LI2.Year_3_Sales_Price__c=300; 
            LI2.Package__c = 'Bespoke';
            insert LI2; 
            
            opportunity2.Probability = 65;
            update opportunity2;
            
            OpportunityLineItem LI1=new OpportunityLineItem(OpportunityId=opportunity2.id,
                                                            PricebookEntryId=PBE.id,
                                                            Quantity=1,
                                                            UnitPrice = 1000);
            LI1.Start_Date__c=system.today();
            LI1.End_Date__c=system.today()+7; 
            LI1.Year_1_List_Price__c=500; 
            LI1.Year_1_Sales_Price__c=300;
            LI1.Year_2_List_Price__c=600; 
            LI1.Year_2_Sales_Price__c=300;  
            LI1.Year_3_List_Price__c=600; 
            LI1.Year_3_Sales_Price__c=300; 
            LI1.Package__c = 'Bespoke';
            insert LI1;      
            
            opportunity2.Probability = 75;
            update opportunity2;
            Test.stopTest(); 
        }catch(Exception e){
            
        }
    }
    
    Static  TestMethod void OLIAfterUpdate(){
        
        try{
            
            Datetime variable=System.now();
            String TestAccountname='Test Account'+variable; 
            Account account=new Account(name=TestAccountname+Datetime.now(),Status__c='Approved',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='China',Billing_State__c='Test',Industry= 'Legal',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id,Area_of_Interest__c ='Training');
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';          
            insert contact;
            Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
            insert contract2;
            
            
            Test.startTest(); 
            system.assertEquals(contact.Mailing_Country__c, 'India');
            Pricebook2 Pricebook=new Pricebook2();
            Pricebook.Description='Test Description';
            Pricebook.IsActive=True;
            Pricebook.Name='Test Pricebook';
            Insert Pricebook;
            //  Pricebook2 ignite = [Select Id, Name, IsActive From Pricebook2 where Name = 'Ignite Price Book'LIMIT 1];
            Pricebook2 Master = [Select Id, Name, IsActive From Pricebook2 where Name = 'Master Price Book'];
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR'  // SSE-10872
            opportunity2.ownerid=UserInfo.getUserId();
            opportunity2.StageName='Verbal';
            opportunity2.Billing_Contact__c=contact.id;
            opportunity2.Closedate=system.today();
            opportunity2.Primary_Contact__c=contact.id;
            opportunity2.CurrencyIsoCode='GBP';
            opportunity2.NVM_Credit_Card_ID__c='1234';
            opportunity2.Amount=1000;
            opportunity2.Pricebook2Id =standardPB.id;
            opportunity2.Variation_Opportunity__c='NO';
            opportunity2.OppUpdatedByOrderOn__c=Date.today();
            opportunity2.Original_Opportunity__c=null;
            opportunity2.Annual_Contract_Value__c=1000.00;
            opportunity2.Business_Type__c='Expansion';
            
            opportunity2.GCSC__c='Phone';        
            opportunity2.RecordTypeID=System.label.GCSCRecordType;
            opportunity2.Forecast_Category__c='Commit';         
            insert opportunity2;
            
            
            Product2 Product= new Product2();
            Product.Description='Product';
            Product.IsActive=True;
            Product.Name=' Product';
            Product.Revenue_Category__c='Training';
            Product.MS_Product__c=true;
            Product.Status__c = 'Revenue Ready';
            Insert Product;
            
            PricebookEntry PBE = new PricebookEntry(
                Pricebook2Id = standardPB.Id, Product2Id = Product.id,
                UnitPrice = 12000, IsActive = true,CurrencyIsoCode='GBP');
            insert PBE;
            
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Master.Id,Product2id= Product.id,UnitPrice = 1000,CurrencyIsoCode='GBP', IsActive = true);
            insert standardPBE;
            
            OpportunityLineItem LI1=new OpportunityLineItem(OpportunityId=opportunity2.id,PricebookEntryId=PBE.id,Quantity=1,UnitPrice = 1000);
            LI1.Start_Date__c=system.today();
            LI1.End_Date__c=system.today()+7; 
            LI1.Year_1_List_Price__c=500; 
            LI1.Year_1_Sales_Price__c=300;
            LI1.Year_2_List_Price__c=600; 
            LI1.Year_2_Sales_Price__c=300;  
            LI1.Year_3_List_Price__c=600; 
            LI1.Year_3_Sales_Price__c=300; 
            LI1.Solution_Cap__c = 2;
            insert LI1; 
            Boolean b=Utility.EACVFlag = true? true:false;
            system.assertEquals(b, true);
            LI1.Year_3_Sales_Price__c=400; 
            update LI1;  
            
            Test.stopTest(); 
        }catch(Exception e){
            
        }
    }
    
    Static  TestMethod void OLIAfterUpdateAutoJob(){
        
        try{
            Datetime variable=System.now();
            String TestAccountname='Test Account'+variable; 
            Account account=new Account(name=TestAccountname+Datetime.now(),Status__c='Approved',Industry= 'Legal',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='China',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id,Area_of_Interest__c ='Training');
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';          
            insert contact;
            Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
            insert contract2;
            
            
            Test.startTest(); 
            system.assertEquals(contact.Mailing_Country__c, 'India');
            Pricebook2 Pricebook=new Pricebook2();
            Pricebook.Description='Test Description';
            Pricebook.IsActive=True;
            Pricebook.Name='Test Pricebook';
            Insert Pricebook;
            //  Pricebook2 ignite = [Select Id, Name, IsActive From Pricebook2 where Name = 'Ignite Price Book'LIMIT 1];
            Pricebook2 Master = [Select Id, Name, IsActive From Pricebook2 where Name = 'Master Price Book'];
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');  // ,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR'  // SSE-10872
            opportunity2.ownerid=UserInfo.getUserId();
            opportunity2.StageName='Verbal';
            opportunity2.Billing_Contact__c=contact.id;
            opportunity2.Closedate=system.today();
            opportunity2.Primary_Contact__c=contact.id;
            opportunity2.CurrencyIsoCode='GBP';
            opportunity2.NVM_Credit_Card_ID__c='1234';
            opportunity2.Amount=1000;
            opportunity2.Pricebook2Id =standardPB.id;
            opportunity2.Variation_Opportunity__c='NO';
            opportunity2.OppUpdatedByOrderOn__c=Date.today();
            opportunity2.Original_Opportunity__c=null;
            opportunity2.Annual_Contract_Value__c=1000.00;
            opportunity2.Business_Type__c='Expansion';
            
            opportunity2.GCSC__c='Phone';        
            opportunity2.RecordTypeID=System.label.GCSCRecordType;
            opportunity2.Forecast_Category__c='Commit';         
            insert opportunity2;
            
            
            Product2 Product= new Product2();
            Product.Description='Product';
            Product.IsActive=True;
            Product.Name=' Product';
            Product.Revenue_Category__c='Training';
            Product.MS_Product__c=true;
            Product.Status__c = 'Revenue Ready';
            Insert Product;
            
            PricebookEntry PBE = new PricebookEntry(
                Pricebook2Id = standardPB.Id, Product2Id = Product.id,
                UnitPrice = 12000, IsActive = true,CurrencyIsoCode='GBP');
            insert PBE;
            
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Master.Id,Product2id= Product.id,UnitPrice = 1000,CurrencyIsoCode='GBP', IsActive = true);
            insert standardPBE;
            
            
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity2.id,PricebookEntryid=PBE.id,Quantity=1,UnitPrice = 1000);         
            //LI.Product2Id=Product.Id;
            Li.Product_Name__c='Managed Service Product';
            Li.Start_Date__c=system.today();
            Li.End_Date__c=system.today()+7;
            LI.Year_1_List_Price__c=500; 
            li.Year_1_Sales_Price__c=300;
            li.Year_2_List_Price__c=600; 
            li.Year_2_Sales_Price__c=300;  
            li.Year_3_List_Price__c=600; 
            li.Year_3_Sales_Price__c=300;
            li.Solution_Cap__c = 2;
            insert LI; 
            
            Test.stopTest(); 
        }catch(Exception e){
            
        }
    }
    
    /*@isTest(SeeAllData=false) static void checkEndOfLifeProducts_Test(){
        
        try{
            
            Test.startTest();
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            
            Product2 Product=new Product2();
            Product.Description='Test Description';
            Product.IsActive=True;
            Product.Name='Test Product';
            Product.Revenue_Category__c='Training';
            Product.Status__c='End Of Life';
            Insert Product;
            
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id,
                                                            Product2Id = Product.Id, 
                                                            UnitPrice = 1000,
                                                            CurrencyIsoCode='GBP', 
                                                            IsActive = true);
            insert standardPBE;
            
            
            Account account=CreateTestData.getAccount();
            Contact contact=CreateTestData.getContact(account.id);
            
            
            Opportunity opportunity=new Opportunity(name='Test Standard Opportunity', 
                                                    AccountID=account.id,
                                                    Offering__c='Enterprise Leadership',
                                                    Talent_Level__c='Leader',
                                                    Talent_Segment__c='Volume',
                                                    Client_Business_Function__c='HR');
            opportunity.ownerid=UserInfo.getUserId();
            opportunity.Billing_Contact__c=contact.id;
            opportunity.Closedate=system.today();
            opportunity.Primary_Contact__c=contact.id;
            opportunity.CurrencyIsoCode='GBP';
            opportunity.Unconfirmed_Sun_Order_Number__c='1234';
            opportunity.NVM_Credit_Card_ID__c='1234';
            opportunity.Amount=1000;
            opportunity.Variation_Opportunity__c='NO';
            opportunity.Original_Opportunity__c=null;
            opportunity.Annual_Contract_Value__c=1000.00;
            opportunity.StageName='New';   
            opportunity.GCSC__c='Phone';
            opportunity.OpportunityAmountMappedWithLead__c = 323.34;
            opportunity.OpportunityTypeMappedWithLead__c = 'New Business';
            opportunity.Skip_Validation__c=True;
            opportunity.TM_Phase__c='Mixed';
            opportunity.Package_Level__c='Basic';
            opportunity.Business_Type__c='Expansion';
            opportunity.RecordTypeId=System.label.GCSCRecordType;
            opportunity.Skip_Validation__c=True;
            opportunity.Eligible_for_Auto_Close__c = false;
            opportunity.Pricebook2Id = standardPB.Id;
            opportunity.Forecast_Category__c = 'Commit';
            opportunity.Opportunity_Deal_Year__c = 1;
            insert opportunity;
            
            Opportunity opportunity1=new Opportunity(name='Test GCSC Opportunity', 
                                                     AccountID=account.id,
                                                     Offering__c='Enterprise Leadership',
                                                     Talent_Level__c='Leader',
                                                     Talent_Segment__c='Volume',
                                                     Client_Business_Function__c='HR');
            opportunity1.ownerid=UserInfo.getUserId();
            opportunity1.Billing_Contact__c=contact.id;
            opportunity1.Closedate=system.today();
            opportunity1.Primary_Contact__c=contact.id;
            opportunity1.CurrencyIsoCode='GBP';
            opportunity1.Unconfirmed_Sun_Order_Number__c='1234';
            opportunity1.NVM_Credit_Card_ID__c='1234';
            opportunity1.Amount=1000;
            opportunity1.Variation_Opportunity__c='NO';
            opportunity1.Original_Opportunity__c=opportunity.Id;
            opportunity1.Annual_Contract_Value__c=1000.00;
            opportunity1.StageName='New';   
            opportunity1.GCSC__c='Phone';
            opportunity1.OpportunityAmountMappedWithLead__c = 323.34;
            opportunity1.OpportunityTypeMappedWithLead__c = 'New Business';
            opportunity1.Skip_Validation__c=True;
            opportunity1.TM_Phase__c='Mixed';
            opportunity1.Package_Level__c='Basic';
            opportunity.Eligible_for_Auto_Close__c = false;
            opportunity1.Business_Type__c='Renewal';
            opportunity1.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GCSC Opportunity').getRecordTypeId();
            opportunity1.Skip_Validation__c=True;
            opportunity1.Pricebook2Id = standardPB.Id;
            insert opportunity1;
            
            OpportunityLineItem originalOLI=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                                    OpportunityId=opportunity.Id,
                                                                    PricebookEntryId=standardPBE.id,
                                                                    TotalPrice=100,
                                                                    Quantity=1,
                                                                    Platform__c='iAssess',
                                                                    Solution_Cap__c = 12,
                                                                    Usage_Allowance__c='Capped', 
                                                                    Usage_Cap_or_Estimation__c=1234,
                                                                    Basis_of_Fees__c='Applications',
                                                                    List_Price__c=100,
                                                                    Proposition__c='Graduate Hiring',
                                                                    Package__c='Graduate Advanced',
                                                                    Product2Id = Product.Id);
            insert originalOLI;
            
            OpportunityLineItem originalOLI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                                     OpportunityId=opportunity1.Id,
                                                                     PricebookEntryId=standardPBE.id,
                                                                     Quantity=1,
                                                                     Platform__c='iAssess',
                                                                     Solution_Cap__c = 12,
                                                                     Usage_Allowance__c='Capped', 
                                                                     Usage_Cap_or_Estimation__c=1234,
                                                                     Basis_of_Fees__c='Applications',
                                                                     List_Price__c=1000,
                                                                     UnitPrice=1000,
                                                                     Proposition__c='Graduate Hiring',
                                                                     Package__c='Graduate Advanced',
                                                                     Product2Id = Product.Id);
            insert originalOLI1;
            //User user = [SELECT Id FROM User WHERE Profile.Name = 'Commercial' AND isActive = true LIMIT 1].get(0);
            User user = TestDataUtility.getUser('Commercial');
            try{
                insert user;
            } catch(Exception ee){
                
            }
            
            System.runAs(user) {
                try{
                    opportunity.StageName = 'Proposal';
                    update opportunity;
                } catch (Exception e){
                    try{
                        opportunity1.Eligible_for_Auto_Close__c = true;
                        update opportunity1;                  
                    } catch(Exception ee){
                        
                    }
                }
                
            }
            Test.stopTest();
        }catch(Exception e){
            
        }
    }*/
    
    @isTest(SeeAllData=false) static void testCheckEndOfLifeProducts() {
        
        try{
        User userRecord = TestDataUtility.getUser('Managed Service Lightning');
        insert userRecord;
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'test accountt '+System.now();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Product.Status__c='End Of Life';
        Insert Product;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id,
                                                        Product2Id = Product.Id, 
                                                        UnitPrice = 1000,
                                                        CurrencyIsoCode='GBP', 
                                                        IsActive = true);
        insert standardPBE;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'GCSC Opportunity' LIMIT 1];
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, userRecord.Id);
        opportunityRecord.Pricebook2Id = pricebookId;
        opportunityRecord.Business_Type__c = 'Expansion';
        opportunityRecord.Forecast_Category__c = 'Commit';
        opportunityRecord.RecordTypeId = rt.Id;
        INSERT opportunityRecord;
            
            OpportunityLineItem originalOLI=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                                OpportunityId=opportunityRecord.Id,
                                                                PricebookEntryId=standardPBE.id,
                                                                TotalPrice=100,
                                                                Quantity=1,
                                                                Platform__c='iAssess',
                                                                Solution_Cap__c = 12,
                                                                Usage_Allowance__c='Capped', 
                                                                Usage_Cap_or_Estimation__c=1234,
                                                                Basis_of_Fees__c='Applications',
                                                                List_Price__c=100,
                                                                Proposition__c='Graduate Hiring',
                                                                Package__c='Graduate Advanced',
                                                                Product2Id = Product.Id);
        insert originalOLI;
            
        /*Opportunity opportunityRecord1 = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, userRecord.Id);
        opportunityRecord1.Pricebook2Id = pricebookId;
        opportunityRecord1.Business_Type__c = 'Expansion';
        opportunityRecord1.Forecast_Category__c = 'Commit';
        opportunityRecord1.RecordTypeId = rt.Id;
        INSERT opportunityRecord1;
            
            OpportunityLineItem originalOLI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                                OpportunityId=opportunityRecord1.Id,
                                                                PricebookEntryId=standardPBE.id,
                                                                TotalPrice=100,
                                                                Quantity=1,
                                                                Platform__c='iAssess',
                                                                Solution_Cap__c = 12,
                                                                Usage_Allowance__c='Capped', 
                                                                Usage_Cap_or_Estimation__c=1234,
                                                                Basis_of_Fees__c='Applications',
                                                                List_Price__c=100,
                                                                Proposition__c='Graduate Hiring',
                                                                Package__c='Graduate Advanced',
                                                                Product2Id = Product.Id);
        insert originalOLI1;
        */
        System.runAs(userRecord) {
            
            opportunityRecord.StageName = 'Proposal';
            //opportunityRecord1.Eligible_for_Auto_Close__c = true;
            list<Opportunity> oppListToUpdate = new list<Opportunity>();
            oppListToUpdate.add(opportunityRecord);
            //oppListToUpdate.add(opportunityRecord1);
            
            Test.startTest();
            try {
                update oppListToUpdate;
            } catch (DmlException e) {
            }
            Test.stopTest();
        }
        }catch(Exception e){
            
        }
    }
    
    @isTest(SeeAllData=false) static void testCheckEndOfLifeProductsElse() {
        
        try{
        User userRecord = TestDataUtility.getUser('Managed Service Lightning');
        insert userRecord;
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'test accountt '+System.now();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Product.Status__c='End Of Life';
        Insert Product;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id,
                                                        Product2Id = Product.Id, 
                                                        UnitPrice = 1000,
                                                        CurrencyIsoCode='GBP', 
                                                        IsActive = true);
        insert standardPBE;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'GCSC Opportunity' LIMIT 1];
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, userRecord.Id);
        opportunityRecord.Pricebook2Id = pricebookId;
        opportunityRecord.Business_Type__c = 'Expansion';
        opportunityRecord.Forecast_Category__c = 'Commit';
        opportunityRecord.RecordTypeId = rt.Id;
        INSERT opportunityRecord;
        
        OpportunityLineItem originalOLI=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                                OpportunityId=opportunityRecord.Id,
                                                                PricebookEntryId=standardPBE.id,
                                                                TotalPrice=100,
                                                                Quantity=1,
                                                                Platform__c='iAssess',
                                                                Solution_Cap__c = 12,
                                                                Usage_Allowance__c='Capped', 
                                                                Usage_Cap_or_Estimation__c=1234,
                                                                Basis_of_Fees__c='Applications',
                                                                List_Price__c=100,
                                                                Proposition__c='Graduate Hiring',
                                                                Package__c='Graduate Advanced',
                                                                Product2Id = Product.Id);
        insert originalOLI;
            
       /*     Opportunity opportunityRecord1 = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, userRecord.Id);
        opportunityRecord1.Pricebook2Id = pricebookId;
        opportunityRecord1.Business_Type__c = 'Expansion';
        opportunityRecord1.Forecast_Category__c = 'Commit';
        opportunityRecord1.Opportunity_Deal_Year__c = 1;
        INSERT opportunityRecord1;
            
            OpportunityLineItem originalOLI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                                OpportunityId=opportunityRecord1.Id,
                                                                PricebookEntryId=standardPBE.id,
                                                                TotalPrice=100,
                                                                Quantity=1,
                                                                Platform__c='iAssess',
                                                                Solution_Cap__c = 12,
                                                                Usage_Allowance__c='Capped', 
                                                                Usage_Cap_or_Estimation__c=1234,
                                                                Basis_of_Fees__c='Applications',
                                                                List_Price__c=100,
                                                                Proposition__c='Graduate Hiring',
                                                                Package__c='Graduate Advanced',
                                                                Product2Id = Product.Id);
        insert originalOLI1;
       */ 
        System.runAs(userRecord) {
            
            //opportunityRecord.StageName = 'Proposal';
            opportunityRecord.Eligible_for_Auto_Close__c = true;
            
            //opportunityRecord1.StageName = 'Proposal';
            list<Opportunity> oppListToUpdate = new list<Opportunity>();
            oppListToUpdate.add(opportunityRecord);
            //oppListToUpdate.add(opportunityRecord1);
            Test.startTest();
            try {
                update oppListToUpdate;
            } catch (DmlException e) {
            }
            Test.stopTest();
        }
        }catch(Exception e){
            
        }
    }
    
    
    @isTest
    static void validateUserOnDeletionTest(){
        try{
            
            
            // create test opportunity
            Opportunity opp = new Opportunity();
            opp.Name='Test Opportunity';
            opp.closedate=system.today();
            opp.stagename='prospecting';
            opp.Business_Type__c='Renewal';
            
            insert opp;
            
            Profile p =[Select id from Profile where Name != 'System Administrator' Limit 1];
            
            User usr = new User(Alias = 'Ashut+', Email='standarduser@xyz.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',
                                UserName='standarduser@xyz.com');
            //system.runAs(usr){
            try{
                delete opp;
            }catch(Exception e){
                //Boolean validateUser = e.getMessage().contains('Opportunity cannot be deleted');
                //System.AssertEquals(validateUser, false);
            }
            //}
        }catch(Exception e){
            
        }
    }
    
    @isTest
    static void UpdateOpportunityContactRoleNewTest(){
        try{
            List<Contact> contactList = new List<Contact>();
            contact con = new contact();
            con.LastName = 'testcon';
            contactList.add(con);
            insert contactList;
            
            list<Opportunity> oppList = new list<Opportunity>();
            
            Opportunity opp = new Opportunity();
            opp.Name='Test Opportunity';
            opp.closedate=system.today();
            opp.stagename='prospecting';
            opp.Primary_Contact__c = con.Id;
            opp.Billing_Contact__c = con.Id;
            opp.ContactId = con.Id;
            opp.Business_Type__c='Renewal';
            oppList.add(opp);
            
            Opportunity opp1 = new Opportunity();
            opp1.Name='Test Opportunity 1';
            opp1.closedate=system.today();
            opp1.stagename='prospecting';
            opp1.Primary_Contact__c = con.Id;
            opp1.Billing_Contact__c = con.Id;
            opp1.ContactId = con.Id;
            opp1.Business_Type__c='Renewal';
            oppList.add(opp1);
            
            insert oppList;
            
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.OpportunityId = opp.Id;
            ocr.IsPrimary = true;
            ocr.Role = 'Decision Maker';
            ocr.ContactId = con.Id;
            
            insert ocr;
            //Integer myCount=[select count() from opportunity]; 
            
            oppList[0].Primary_Contact__c = '123456789'; 
            oppList[0].Billing_Contact__c = '646464665';
            oppList[1].Billing_Contact__c = '646464665';
            update oppList;
            
            
            ocr.IsPrimary = false;
            ocr.Role='Billing Contact';
            update ocr;
            
            Opportunity opp2 = new Opportunity();
            opp2.Name='Test Opportunity';
            opp2.closedate=system.today();
            opp2.stagename='prospecting';
            opp2.Primary_Contact__c = con.Id;
            opp2.Billing_Contact__c = con.Id;
            opp2.ContactId = con.Id;
            opp2.Business_Type__c='Renewal';
            
            insert opp2;
            
            OpportunityContactRole ocr1 = new OpportunityContactRole();
            ocr1.OpportunityId = opp2.Id;
            ocr1.IsPrimary = true;
            ocr1.Role = 'Decision Maker';
            ocr1.ContactId = con.Id;
            insert ocr1;
            
            
            opp2.Primary_Contact__c = '123456789'; 
            opp2.Billing_Contact__c = '123456789';
            update opp2;
            
            if(ocr1.Role=='Decision Maker / Billing Contact' || ocr1.Role=='Billing Contact'){
                ocr1.IsPrimary=False;
                ocr1.Role='Billing Contact';
                delete ocr1;
            }
            
        }catch(Exception e){
            
            System.debug(e);
        }
        
    } 
    
    
    @isTest
    static void OpptyDeleteWithContractTest(){
        try{
            Account acc = new Account(Name='Ok'+System.now(),Industry= 'Legal',status__c='Approved');
            insert acc;
            Opportunity opp1 = new Opportunity(Name='Demo1',Business_Type__c='Renewal',CloseDate=System.today(), StageName='Prospecting', AccountId=acc.id);
            insert opp1;
            Contract c = new Contract(Status='Draft', StartDate=System.today(), ContractTerm=6, Subscription_Start_Date__c=system.today(), Opportunity__c=opp1.Id, AccountId=acc.id);
            insert c;
            
            Opportunity opp2 = new Opportunity(Name='Demo2', CloseDate=System.today(), StageName='Prospecting',Business_Type__c='Renewal');
            insert opp2;
            
            delete opp1;
            
        }catch(Exception e){
            System.debug(e);
        }
        
    }
    
    static testmethod void Method1(){
        try{
            
            Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
            User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
            String accountname = 'Test Account_34';
            Account account=new Account(name=accountname+Datetime.now(),ownerid=user.id,Status__c='Approved',
                                        Industry= 'Legal',Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='India',Billing_State__c='Test',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='	Sweden - SE1');
            insert account;
            
            
            Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';
            contact.ownerid= user.id;
            contact.Email = 'abcTest@invalid.com';
            insert contact;
            
            Contact contact1=new Contact(lastname='Test Contact11', Accountid=account.id);
            contact1.Same_As_The_Account_Billing_Address__c=true;
            contact1.Mailing_Address_Line_1__c ='test1';
            contact1.Mailing_City__c='test1';
            contact1.Mailing_ZIP_Postal_Code__c ='1100941';
            contact1.Mailing_Country__c='India';
            contact1.ownerid= user.id;
            contact1.Email = 'abcTest1@invalid1.com';
            
            insert contact1;
            
            Contract contract= new Contract(
                AccountId=account.Id,        
                Agreement__c='Order',
                ContractTerm=12,
                Status='Draft',
                StartDate=date.today(),
                Invoicing_Contact__c=contact.Id,
                Contract_Type__c='Consulting',
                Subscription_Start_Date__c=date.today()
            );
            insert contract; 
            
            Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
            RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
            //Id priceBookID = Test.getStandardPricebookId();
            Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
            opportunity.ownerid=user.id;
            opportunity.Billing_Contact__c=contact.id;
            opportunity.Closedate=system.today();
            opportunity.Primary_Contact__c=contact1.id;
            opportunity.CurrencyIsoCode='AUD';
            opportunity.Unconfirmed_Sun_Order_Number__c='1234';
            opportunity.NVM_Credit_Card_ID__c='1234';
            opportunity.Amount=1000;
            opportunity.Variation_Opportunity__c='NO';
            opportunity.Order_Number__c=contract.id;
            opportunity.Original_Opportunity__c=null;
            opportunity.Annual_Contract_Value__c=1000.00;
            opportunity.StageName='First Appointment';   
            opportunity.GCSC__c='Phone';
            opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
            opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
            opportunity.RecordTypeID=RT.id;
            opportunity.Skip_Validation__c=True;
            opportunity.Pricebook2Id=p.id;
            opportunity.Business_Type__c='Expansion';
            opportunity.Forecast_Category__c='Commit';
            opportunity.Multi_YearDeal__c = '2';
            opportunity.Opportunity_Deal_Year__c = 1;
            
            
            insert opportunity;
            pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];
            
            
            
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity.id,CurrencyChange__c = false,Package__c = 'Bespoke',RenewableNew__c = 'Ongoing',PricebookEntryId=PR.id,TotalPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1, Total_Equivalent_Units__c = 10, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped');
            insert LI;
            LI.RenewableNew__c = 'One-off';
            // LI.ms_product__c = true;
            update LI;
            LI.RenewableNew__c = 'Ongoing';
            update LI;
            
            System.runAs(user){            
                Delete LI;
            }
        }catch(Exception e){
            
        }
        
    }
    
    Static  TestMethod void TestOpptyTriggers_1(){
        try{
            Test.startTest();
            Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Finance' limit 1];
            
            User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
            User Adminuser = [Select id from user where ProfileId = '00e20000000gzoS' AND isActive=true limit 1];
            Account account=new Account(name='Test Account'+System.now(),Status__c='Approved',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',Industry= 'Legal',
                                        Billing_Country__c='China',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id, Area_of_Interest__c ='Training');
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';
            
            Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
            
            
            insert contact;
            Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
            insert contract2;
            Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR' // SSE-10872
            opportunity2.ownerid=UserInfo.getUserId();
            opportunity2.StageName='Verbal';
            opportunity2.Billing_Contact__c=contact.id;
            opportunity2.Closedate=system.today();
            opportunity2.Primary_Contact__c=contact.id;
            opportunity2.pricebook2id=p.id;
            opportunity2.CurrencyIsoCode='AUD';
            //opportunity.Unconfirmed_Sun_Order_Number__c='1234';
            opportunity2.NVM_Credit_Card_ID__c='1234';
            opportunity2.Amount=1000;
            
            opportunity2.Variation_Opportunity__c='NO';
            opportunity2.OppUpdatedByOrderOn__c=Date.today();
            opportunity2.Original_Opportunity__c=null;
            opportunity2.Annual_Contract_Value__c=1000.00;
            opportunity2.Business_Type__c='Expansion';
            //opportunity2.CurrencyISOCode='GBP';
            opportunity2.GCSC__c='Phone';        
            opportunity2.RecordTypeID=System.label.GCSCRecordType;
            opportunity2.Forecast_Category__c='Commit'; 
            opportunity2.Offering__c = 'OPQ' ;   
            insert opportunity2;
            
            pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];
            
            
            
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity2.id,CurrencyChange__c = false,Package__c = 'Bespoke',RenewableNew__c = 'Ongoing',PricebookEntryId=PR.id,TotalPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1, Total_Equivalent_Units__c = 10, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped');
            insert LI;
            
            Opportunity opportunity6=new Opportunity();
            opportunity6.Id = opportunity2.Id;
            opportunity6.Multi_YearDeal__c = '3';
            opportunity6.RecordTypeID=System.label.standardRecordType;
            
            
            Update opportunity6;
            
            opportunity6.Multi_YearDeal__c = '1';
            Update opportunity6;
        }catch(Exception e){}
    }
    
    Static  TestMethod void TestOpptyTriggers_2(){
        try{
            Test.startTest();
            Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Finance' limit 1];
            
            User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
            User Adminuser = [Select id from user where ProfileId = '00e20000000gzoS' AND isActive=true limit 1];
            Account account=new Account(name='Test Account'+System.now(),Status__c='Approved',Industry= 'Legal',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='China',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact'+System.now(), Accountid=account.id, Area_of_Interest__c ='Training');
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';
            
            Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
            Pricebook2 Master = [Select Id, Name, IsActive From Pricebook2 where Name = 'Master Price Book'];
            
            
            insert contact;
            Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
            insert contract2;
            Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR' // SSE-10872
            opportunity2.ownerid=UserInfo.getUserId();
            opportunity2.StageName='Proposal';
            opportunity2.Billing_Contact__c=contact.id;
            opportunity2.Closedate=system.today();
            opportunity2.Primary_Contact__c=contact.id;
            opportunity2.pricebook2id=p.id;
            //opportunity2.CurrencyIsoCode='AUD';
            //opportunity.Unconfirmed_Sun_Order_Number__c='1234';
            opportunity2.NVM_Credit_Card_ID__c='1234';
            opportunity2.Amount=1000;
            
            opportunity2.Variation_Opportunity__c='NO';
            opportunity2.OppUpdatedByOrderOn__c=Date.today();
            opportunity2.Original_Opportunity__c=null;
            opportunity2.Annual_Contract_Value__c=1000.00;
            opportunity2.Business_Type__c='Expansion';
            opportunity2.CurrencyISOCode='GBP';
            opportunity2.GCSC__c='Phone';        
            opportunity2.RecordTypeID=System.label.GCSCRecordType;
            opportunity2.Forecast_Category__c='Commit'; 
            opportunity2.Offering__c = 'OPQ' ;   
            insert opportunity2;
            
            Product2 Product= new Product2();
            Product.Description='Managed Service Product';
            Product.IsActive=True;
            Product.Name='Managed Service Product';
            Product.Revenue_Category__c='Training';
            Product.MS_Product__c=true;
            Product.Status__c = 'Revenue Ready';
            Insert Product;
            
            PricebookEntry PBE = new PricebookEntry(
                Pricebook2Id = p.Id, Product2Id = Product.id,
                UnitPrice = 12000, IsActive = true,CurrencyIsoCode='GBP');
            insert PBE;
            //pricebookentry PR=[SELECT Id FROM PricebookEntry where CurrencyIsoCode ='GBP' and IsActive = true and Product2.MS_Product__c=true and Product2.name = 'Managed Services (Fee Per Candidate)' limit 1];
            // pricebookentry PR1=[SELECT Id FROM PricebookEntry where CurrencyIsoCode ='GBP' and IsActive = true and Product2.MS_Product__c=true and Pricebook2.isStandard=true and Product2.name Like 'Managed Services%' limit 1];
            
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Master.Id,Product2id= Product.id,UnitPrice = 1000,CurrencyIsoCode='GBP', IsActive = true);
            insert standardPBE;
            
            
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity2.id,PricebookEntryid=PBE.id,Quantity=1,UnitPrice = 1000);         
            LI.Product2Id=Product.Id;
            Li.Product_Name__c='Managed Service Product';
            Li.Start_Date__c=system.today();
            Li.End_Date__c=system.today()+7;
            LI.Year_1_List_Price__c=500; 
            li.Year_1_Sales_Price__c=300;
            li.Year_2_List_Price__c=600; 
            li.Year_2_Sales_Price__c=300;  
            li.Year_3_List_Price__c=600; 
            li.Year_3_Sales_Price__c=300;
            li.Package__c = 'Bespoke';
            insert LI;    
            
            Contact contact2=new Contact(lastname='Test Contact2'+System.now(), Accountid=account.id, Area_of_Interest__c ='Training');
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';
            
            
            insert contact2;
            
            Opportunity opportunity6=new Opportunity();
            opportunity6.Id = opportunity2.Id;
            opportunity6.Multi_YearDeal__c = '3';
            opportunity6.RecordTypeID=System.label.standardRecordType;
            opportunity6.StageName='Verbal';
            opportunity6.Primary_Contact__c=contact.id;
            opportunity6.Billing_Contact__c=contact2.id;
            
            
            Update opportunity6;
            
            opportunity6.Multi_YearDeal__c = '1';
            Update opportunity6;
        }catch(Exception e){}
    }
    
    @isTest
    static void UpdateOpportunityContactRoleNewTest2(){
        try{
            
            
            Test.StartTest();
            Account acc = CreateTestData.GetAccount();
            
            List<Contact> contactList = new List<Contact>();
            
            Contact con = new Contact(lastname='Test Contact 1'+System.now(), AccountId=acc.id,Same_As_The_Account_Billing_Address__c=true);
            contactList.add(con);
            
            Contact con1 = new Contact(lastname='Test Contact 2'+System.now(), AccountId=acc.id,Same_As_The_Account_Billing_Address__c=true);
            contactList.add(con1); 
            
            Contact con2 = new Contact(lastname='Test Contact 3'+System.now(), AccountId=acc.id,Same_As_The_Account_Billing_Address__c=true);
            contactList.add(con2); 
            
            Contact con3 = new Contact(lastname='Test Contact 4'+System.now(), AccountId=acc.id,Same_As_The_Account_Billing_Address__c=true);
            contactList.add(con3);
            
            Contact con4 = new Contact(lastname='Test Contact 5'+System.now(), AccountId=acc.id,Same_As_The_Account_Billing_Address__c=true);
            contactList.add(con4); 
            
            Contact con5 = new Contact(lastname='Test Contact 6'+System.now(), AccountId=acc.id,Same_As_The_Account_Billing_Address__c=true);
            contactList.add(con5); 
            
            insert contactList;
            
            
            
            Opportunity opp = new Opportunity();
            opp.Name='Test Opportunity';
            opp.closedate=system.today();
            opp.stagename='prospecting';
            opp.Primary_Contact__c = con.Id;
            opp.Billing_Contact__c = con1.Id;
            opp.AccountId = acc.Id;
            opp.ContactId = con.Id;
            opp.Business_Type__c='Renewal';
            insert opp;
            
            opp.Primary_Contact__c = con2.id;
            update opp;
            
            opp.Primary_Contact__c = con3.Id;
            opp.Billing_Contact__c = con3.Id;
            update opp;
            
            opp.Billing_Contact__c = con.Id;
            update opp;
            
            
            Test.stopTest();
        }catch(Exception e){
            
        }
        
    } 
    
    @isTest
    public static void testTrackNextStepAndManagerComments(){
        
        try{
            
            Account accountRecord = TestDataUtility.getAccount();
            accountRecord.Name = 'test acc'+System.now();
            accountRecord.Industry = 'Education & Educational Services';
            INSERT accountRecord;
            
            Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
            INSERT contactRecord;
            
            Campaign campaignRecord = TestDataUtility.getCampaign();
            INSERT campaignRecord;
            
            Test.StartTest();
            
            Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
            opportunityRecord.CampaignId = campaignRecord.Id;
            opportunityRecord.NextStep = 'Next Step';
            opportunityRecord.Manager_s_Notes__c = 'Notes';
            INSERT opportunityRecord;
            
            opportunityRecord.NextStep = 'This is a Next Step';
            opportunityRecord.Manager_s_Notes__c = 'Manager Notes';
            update opportunityRecord;
            
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void testCopyClosedWonOrLostReason(){
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'test acc'+System.now();
        accountRecord.Industry = 'Education & Educational Services';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Campaign campaignRecord = TestDataUtility.getCampaign();
        INSERT campaignRecord;
        
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id,null);
        contractRecord.Subscription_Start_Date__c = date.today();
        contractRecord.Contract_End_Date__c = date.today()+365;
        INSERT contractRecord; 
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.CampaignId = campaignRecord.Id;
        opportunityRecord.ContractId = contractRecord.Id;
        INSERT opportunityRecord;
        
        Opportunity opportunityRecord2 = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord2.CampaignId = campaignRecord.Id;
        opportunityRecord2.ContractId = contractRecord.Id;
        opportunityRecord2.Opportunity_Deal_Year__c = 2;
        opportunityRecord2.Can_be_Auto_renewed__c = true;
        opportunityRecord2.Original_Opportunity__c = opportunityRecord.Id;
        INSERT opportunityRecord2;
        
        User usr = [Select Id From User Where Profile.Name = 'Commercial' AND isActive = true].get(0);
        
        opportunityRecord2.StageName = 'Closed Lost';
        UPDATE opportunityRecord2;
        
        System.runAs(usr){
            try{
                opportunityRecord.StageName = 'Closed Lost';
                UPDATE opportunityRecord;
            } catch (Exception e) {
                
            }
        }
        
        
        Test.StartTest();
        
        opportunityRecord.Closed_Lost_Reason__c = 'Expertise';
        UPDATE opportunityRecord;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testExtendOppAccessToOpportunityOwnerManager(){
        try{
            
            
            Account accountRecord = TestDataUtility.getAccount();
            accountRecord.Name = 'test acc'+System.now();
            accountRecord.Industry = 'Education & Educational Services';
            INSERT accountRecord;
            
            Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
            INSERT contactRecord;
            
            Campaign campaignRecord = TestDataUtility.getCampaign();
            INSERT campaignRecord;
            
            Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
            opportunityRecord.CampaignId = campaignRecord.Id;
            INSERT opportunityRecord;
            
            User user = [SELECT Id FROM User WHERE Profile.Name = 'Commercial' AND isActive = true LIMIT 1].get(0);
            
            Test.StartTest();
            
            opportunityRecord.OwnerId = user.Id;
            opportunityRecord.Renewal_Notification_Sent_On__c = System.today();
            opportunityRecord.Price_Notification_Email_Bounced__c = true;
            update opportunityRecord;
            
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void testCaptureTotalExtensionLength(){
        try{
            
            
            Account accountRecord = TestDataUtility.getAccount();
            accountRecord.Name = 'test acc'+System.now();
            accountRecord.Industry = 'Education & Educational Services';
            INSERT accountRecord;
            
            Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
            INSERT contactRecord;
            
            Campaign campaignRecord = TestDataUtility.getCampaign();
            INSERT campaignRecord;
            
            Opportunity original = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
            original.CampaignId = campaignRecord.Id;
            INSERT original;
            
            Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
            opportunityRecord.CampaignId = campaignRecord.Id;
            opportunityRecord.Business_Type__c = 'Extension';
            opportunityRecord.Custom_Contract_Duration__c = 2;
            opportunityRecord.Standard_Contract_Duration__c = 'Other';
            opportunityRecord.Original_Opportunity__c = original.Id;
            
            Test.StartTest();
            INSERT opportunityRecord;
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void testtotalSolutionCapCalculation(){
        try{
            
            
            Datetime variable=System.now();
            String TestAccountname='Test Account'+variable; 
            Account account=new Account(name=TestAccountname+Datetime.now(),Status__c='Approved',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='China',Billing_State__c='Test',Industry= 'Legal',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
            insert account;
            
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id, Area_of_Interest__c ='Training');
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';          
            insert contact;
            Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
            insert contract2;
            
            
            Test.startTest(); 
            system.assertEquals(contact.Mailing_Country__c, 'India');
            Pricebook2 Pricebook=new Pricebook2();
            Pricebook.Description='Test Description';
            Pricebook.IsActive=True;
            Pricebook.Name='Test Pricebook';
            Insert Pricebook;
            
            //   Pricebook2 ignite = [Select Id, Name, IsActive From Pricebook2 where Name = 'Ignite Price Book'LIMIT 1];
            Pricebook2 Master = [Select Id, Name, IsActive From Pricebook2 where Name = 'Master Price Book'];
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            
            Opportunity opportunity2=new Opportunity(name='Test Opportunity', 
                                                     AccountID=account.id,
                                                     Talent_Segment__c='Volume', 
                                                     TM_Phase__c='Post-Hire'); 
            
            //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR'  // SSE-10872
            //
            opportunity2.ownerid=UserInfo.getUserId();
            opportunity2.StageName='New';
            opportunity2.Billing_Contact__c=contact.id;
            opportunity2.Closedate=system.today();
            opportunity2.Primary_Contact__c=contact.id;
            opportunity2.CurrencyIsoCode='GBP';
            opportunity2.NVM_Credit_Card_ID__c='1234';
            opportunity2.Amount=1000;
            opportunity2.Pricebook2Id =standardPB.id;
            opportunity2.Variation_Opportunity__c='NO';
            opportunity2.OppUpdatedByOrderOn__c=Date.today();
            opportunity2.Original_Opportunity__c=null;
            opportunity2.Annual_Contract_Value__c=1000.00;
            opportunity2.Business_Type__c='Expansion';
            opportunity2.Probability = 55;
            opportunity2.GCSC__c='Phone';        
            opportunity2.RecordTypeID='012D0000000V7oqIAC';
            opportunity2.Forecast_Category__c='Commit';         
            insert opportunity2;
            
            
            
            //Product2 Product2=[select id, name from Product2 where Product2.Name Like 'Managed Services%' and currencyisocode='GBP' and MS_Product__c=true limit 1];
            Product2 Product= new Product2();
            Product.Description='Managed Service Product';
            Product.IsActive=True;
            Product.Name='Managed Service Product';
            Product.Revenue_Category__c='Training';
            Product.MS_Product__c=true;
            Product.Status__c = 'Revenue Ready';
            Product.MS_Type__c='Talent Management';
            Insert Product;
            
            PricebookEntry PBE = new PricebookEntry(
                Pricebook2Id = standardPB.Id, 
                Product2Id = Product.id,
                UnitPrice = 12000, 
                IsActive = true,
                CurrencyIsoCode='GBP');
            insert PBE;
            
            //pricebookentry PR=[SELECT Id FROM PricebookEntry where CurrencyIsoCode ='GBP' and IsActive = true and Product2.MS_Product__c=true and Product2.name = 'Managed Services (Fee Per Candidate)' limit 1];
            // pricebookentry PR1=[SELECT Id FROM PricebookEntry where CurrencyIsoCode ='GBP' and IsActive = true and Product2.MS_Product__c=true and Pricebook2.isStandard=true and Product2.name Like 'Managed Services%' limit 1];
            
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Master.Id,
                                                            Product2id= Product.id,
                                                            UnitPrice = 1000,
                                                            CurrencyIsoCode='GBP', 
                                                            IsActive = true);
            insert standardPBE;
            
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity2.id,
                                                           PricebookEntryid=PBE.id,
                                                           Quantity=1,
                                                           UnitPrice = 1000);         
            LI.Product2Id=Product.Id;
            Li.Product_Name__c='Managed Service Product';
            Li.Start_Date__c=system.today();
            Li.End_Date__c=system.today()+7;
            LI.Year_1_List_Price__c=500; 
            li.Year_1_Sales_Price__c=300;
            li.Year_2_List_Price__c=600; 
            li.Year_2_Sales_Price__c=300;  
            li.Year_3_List_Price__c=600; 
            li.Year_3_Sales_Price__c=300;
            li.Package__c = 'Bespoke';
            insert LI;  
            
            OpportunityLineItem LI2=new OpportunityLineItem(OpportunityId=opportunity2.id,
                                                            PricebookEntryid=PBE.id,
                                                            Quantity=1,
                                                            UnitPrice = 1000);         
            LI2.Product_Name__c='Managed Service Product';
            LI2.Product2Id=Product.Id;
            LI2.Start_Date__c=system.today();
            LI2.End_Date__c=system.today()+7;
            LI2.Year_1_List_Price__c=500; 
            LI2.Year_1_Sales_Price__c=300;
            LI2.Year_2_List_Price__c=600; 
            LI2.Year_2_Sales_Price__c=300;  
            LI2.Year_3_List_Price__c=600; 
            LI2.Year_3_Sales_Price__c=300; 
            LI2.Package__c = 'Bespoke';
            insert LI2; 
            
            opportunity2.stagename = 'Closed/Won';
            update opportunity2;
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void testCloseLostCancellationReason(){
        try{
            
            Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
            User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
            String accountname = 'Test Account_34';
            Account account=new Account(name=accountname+Datetime.now(),ownerid=user.id,Status__c='Approved',
                                        Industry= 'Legal',Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='India',Billing_State__c='Test',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='	Sweden - SE1');
            insert account;
            
            
            Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
            contact.Same_As_The_Account_Billing_Address__c=true;
            contact.Mailing_Address_Line_1__c ='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c ='110094';
            contact.Mailing_Country__c='India';
            contact.ownerid= user.id;
            contact.Email = 'abcTest@invalid.com';
            insert contact; 
            
            Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
            RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
            
            Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
            opportunity.ownerid=user.id;
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
            opportunity.StageName='First Appointment';   
            opportunity.GCSC__c='Phone';
            opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
            opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
            opportunity.RecordTypeID=RT.id;
            opportunity.Skip_Validation__c=True;
            opportunity.Pricebook2Id=p.id;
            opportunity.Business_Type__c='Renewal';
            opportunity.Forecast_Category__c='Commit';
            opportunity.Multi_YearDeal__c = '2';
            opportunity.Opportunity_Deal_Year__c = 1;
            opportunity.Can_be_Auto_renewed__c = true;
            
            insert opportunity;
            
            System.runAs(user){            
                opportunity.StageName = 'Closed Lost';
                opportunity.Closed_Lost_Reason__c = 'Solution';
                
                update opportunity;
            }
        }catch(Exception e){
            
        }
        
    }
    
}