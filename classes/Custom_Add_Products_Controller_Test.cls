@istest
public class Custom_Add_Products_Controller_Test {
    @istest(seealldata=true)
    public static void Custom_Add_Products_Controller_Test_Method(){
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];

        Account acc=new Account(name='Test Account',ownerid=user.id,Status__c='Approved',Industry='Legal',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con=new Contact(lastname='Test Contact', ownerid=user.id,Accountid=acc.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;
        
        Opportunity opp=new Opportunity(name='Test Opportunity', AccountID=acc.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');
        //opp.ownerid=UserInfo.getUserId();
        opp.ownerid = user.id;
        opp.StageName='Draft';
        opp.Billing_Contact__c=con.id;
        opp.Closedate=system.today();
        opp.Primary_Contact__c=con.id;
        opp.pricebook2id='01s2000000000vQAAQ';
        opp.CurrencyIsoCode='AUD';
        opp.NVM_Credit_Card_ID__c='1234';
        opp.Amount=1000;
        opp.Variation_Opportunity__c='NO';
        opp.OppUpdatedByOrderOn__c=Date.today();
        opp.Original_Opportunity__c=null;
        opp.Annual_Contract_Value__c=1000.00;
        opp.Business_Type__c='New customer: subscription';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Commit';
        opp.Multi_YearDeal__c='3';
        System.runAs(user){
            insert opp;
        }
        
        list<Product2> prodlist = new list <Product2>();
        Product2 Prod = new Product2(Name = 'test product 1',Status__c='Revenue Ready',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
        prodlist.add(prod);
        Product2 Prod2 = new Product2(Name = 'test product 2',Status__c='Revenue Ready',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
        prodlist.add(prod2);
        Product2 Prod3 = new Product2(Name = 'test product 3',Status__c='Revenue Ready',IsActive=true,Revenue_Category__c='Training');
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
        OpportunityLineItem LI1=new OpportunityLineItem(Solution_Cap__c = 1,Number_of_Services__c=10,
                                                        RenewableNew__c = 'Ongoing',OpportunityId=opp.id,PricebookEntryId=pbe1.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI1);
        OpportunityLineItem LI2=new OpportunityLineItem(Solution_Cap__c = 1,Number_of_Services__c=10,RenewableNew__c = 'Ongoing',OpportunityId=opp.id,PricebookEntryId=pbe2.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI2);
        OpportunityLineItem LI3=new OpportunityLineItem(Solution_Cap__c = 1,Number_of_Services__c=10,RenewableNew__c = 'Ongoing',OpportunityId=opp.id,PricebookEntryId=pbe3.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI3);
        System.runAs(user){
            insert OLIlist;
            
            PageReference pageRef = Page.Clone_Custom_Add_Products_Page;
            pageRef.getParameters().put('id', opp.id);
            Test.setCurrentPage(pageRef);
            Clone_Custom_Add_Products_Controller controller = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            controller.saveProducts();
            pageRef.getParameters().put('id', opp.id);
            pageRef.getParameters().put('rowIndex','4');
            Test.setCurrentPage(pageRef);
            Clone_Custom_Add_Products_Controller controller2 = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            //controller2.addProduct();
            //controller2.deleteRow();
            controller2.Cancelled();
            opp = [SELECT Id,StageName,Multi_YearDeal__c,Business_Type__c,Opportunity_Deal_Year__c,Original_Opportunity__c FROM Opportunity where id = :opp.id];
            opp.StageName = 'Verbal';
            //Clone_Custom_Add_Products_Controller controller3 = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            //update opp;
        }
    }
    @istest(seealldata=true)
    public static void Custom_Add_Products_Controller_Test_Method_Closed_Opp(){
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];

        Account acc=new Account(name='Test Account',ownerid=user.id,Status__c='Approved',Industry='Legal',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con=new Contact(lastname='Test Contact', ownerid=user.id,Accountid=acc.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;
        
        Opportunity opp=new Opportunity(name='Test Opportunity', 
                                        AccountID=acc.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');
        //opp.ownerid=UserInfo.getUserId();
        opp.ownerid = user.id;
        opp.StageName='Draft';
        opp.Billing_Contact__c=con.id;
        opp.Closedate=system.today();
        opp.Primary_Contact__c=con.id;
        opp.pricebook2id='01s2000000000vQAAQ';
        opp.CurrencyIsoCode='AUD';
        opp.Opportunity_Deal_Year__c = 1;
        opp.NVM_Credit_Card_ID__c='1234';
        opp.Amount=1000;
        opp.Variation_Opportunity__c='NO';
        opp.OppUpdatedByOrderOn__c=Date.today();
        opp.Original_Opportunity__c=null;
        opp.Annual_Contract_Value__c=1000.00;
        opp.Business_Type__c='Renewal';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Commit';
        opp.Multi_YearDeal__c='3';
        insert opp;
        opp.StageName = 'Closed/Won';
        update opp;
        
      
            
            PageReference pageRef = Page.Clone_Custom_Add_Products_Page;
            pageRef.getParameters().put('id', opp.id);
            Test.setCurrentPage(pageRef);
            Clone_Custom_Add_Products_Controller controller = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            controller.saveProducts();
            pageRef.getParameters().put('id', opp.id);
            pageRef.getParameters().put('rowIndex','4');
            Test.setCurrentPage(pageRef);
            Clone_Custom_Add_Products_Controller controller2 = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            //controller2.addProduct();
            //controller2.deleteRow();
            controller2.Cancelled();
            opp = [SELECT Id,StageName,Multi_YearDeal__c,Business_Type__c,Opportunity_Deal_Year__c,Original_Opportunity__c FROM Opportunity where id = :opp.id];
            opp.StageName = 'Verbal';
            //Clone_Custom_Add_Products_Controller controller3 = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            //update opp;
        }
    @istest(seealldata=true)
    public static void Custom_Add_Products_Controller_Test_Method_Renewal_Opp(){
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];

        Account acc=new Account(name='Test Account',ownerid=user.id,Status__c='Approved',Industry='Legal',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con=new Contact(lastname='Test Contact', ownerid=user.id,Accountid=acc.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;
        
        Opportunity opp=new Opportunity(name='Test Opportunity', 
                                        AccountID=acc.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');
        //opp.ownerid=UserInfo.getUserId();
        opp.ownerid = user.id;
        opp.StageName='New';
        opp.Billing_Contact__c=con.id;
        opp.Closedate=system.today();
        opp.Primary_Contact__c=con.id;
        opp.pricebook2id='01s2000000000vQAAQ';
        opp.CurrencyIsoCode='AUD';
        opp.Opportunity_Deal_Year__c = 1;
        opp.NVM_Credit_Card_ID__c='1234';
        opp.Amount=1000;
        opp.Variation_Opportunity__c='NO';
        opp.OppUpdatedByOrderOn__c=Date.today();
        opp.Original_Opportunity__c=null;
        opp.Annual_Contract_Value__c=1000.00;
        opp.Business_Type__c='Renewal';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Commit';
        opp.Multi_YearDeal__c='3';
        opp.Opportunity_Deal_Year__c=2;
        insert opp;
        opp.StageName = 'Closed/Won';
        update opp;
        
      
            
            PageReference pageRef = Page.Clone_Custom_Add_Products_Page;
            pageRef.getParameters().put('id', opp.id);
            Test.setCurrentPage(pageRef);
            Clone_Custom_Add_Products_Controller controller = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            controller.saveProducts();
            pageRef.getParameters().put('id', opp.id);
            pageRef.getParameters().put('rowIndex','4');
            Test.setCurrentPage(pageRef);
            Clone_Custom_Add_Products_Controller controller2 = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            //controller2.addProduct();
            //controller2.deleteRow();
            controller2.Cancelled();
            opp = [SELECT Id,StageName,Multi_YearDeal__c,Business_Type__c,Opportunity_Deal_Year__c,Original_Opportunity__c FROM 
                   Opportunity where id = :opp.id];
            opp.StageName = 'Verbal';
            //Clone_Custom_Add_Products_Controller controller3 = new Clone_Custom_Add_Products_Controller(new ApexPages.StandardController(opp));
            //update opp;
        }

    
}