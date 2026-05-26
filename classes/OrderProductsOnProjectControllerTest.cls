@isTest
public class OrderProductsOnProjectControllerTest {
@istest(seealldata=true)
    public static void OrderProductsOnProjectControllerTestMethod(){
        test.startTest();
        Account acc=new Account(currencyisocode = 'AUD',name='Order Product',Industry='Legal',
                                Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con=new Contact(lastname='Order Product', Accountid=acc.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;
        
        Contract contract = new Contract();
        contract.AccountId = acc.Id;   
        contract.CurrencyIsoCode = acc.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;  
        contract.Legal_Order_Name__c='test';
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
        string contractnumber = [select ContractNumber from contract where id = :contract.id].ContractNumber;
        
        Opportunity opp=new Opportunity(name='Test Opportunity', AccountID=acc.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');
        opp.ownerid=UserInfo.getUserId();
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
        opp.Business_Type__c='Expansion';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Commit';
        opp.Multi_YearDeal__c='3';
        opp.ContractId = contract.id;
        insert opp;
        
        list<Product2> prodlist = new list <Product2>();
        Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Status__c='Revenue Ready',
                                     Revenue_Category__c='Professional Services',Renewable__c = 'Yes');
        prodlist.add(prod);
        Product2 Prod2 = new Product2(Name = 'test product 2',Status__c='Revenue Ready',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
        prodlist.add(prod2);
        Product2 Prod3 = new Product2(Name = 'test product 3',Status__c='Revenue Ready',IsActive=true,Revenue_Category__c='Training');
        prodlist.add(prod3);
        
        insert prodlist;
        
        list<PricebookEntry> pbelist = new list<PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod.id,UnitPrice = 100,currencyisocode = acc.CurrencyIsoCode ,IsActive=true);
        pbelist.add(pbe1);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod2.id,UnitPrice = 100,IsActive=true);
        pbelist.add(pbe2);
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod3.id,UnitPrice = 100,IsActive=true);
        pbelist.add(pbe3);
        insert pbelist;
        
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];
        //list<id> userid = [select id,UserOrGroupId from groupmember where group.DeveloperName = 'Central_PS_CS' limit 1].UserOrGroupId;
        User cpsuser = [select id from user where name = 'Globus Development'];
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        
        ProjectObject__c project = new ProjectObject__c();
            project.Project_Name__c = 'project_1';
            project.RecordTypeId=Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
            project.Account__c = acc.id;
            project.Contact__c = con.Id;
            project.Billing_Contact__c = con.Id;
            project.Opportunity__c = opp.id;
            project.Project_Manager__c =  usrRec.id;
            project.LBU__c = lbuList[1].trim();
            project.CurrencyIsoCode = acc.CurrencyIsoCode;
            project.Functional_Area__c = 'Consulting & Training';
            project.Order_Header_Number__c = contract.id;
            project.Total_Actual_Time__c=1;
            project.Scoped_Hours_Effort__c=1;
            project.Additional_Scoped_Days__c = 1;
            project.Current_Scoped_Days_Effort__c = null;
            project.additional_scoped_comments__c = 'test Comments';
            project.Chargeable__c = 'test';
            project.Reason__c = 'test';
            project.CPS_Project_Manager__c='Prabhat Arora';
            project.Delivered__c=System.today();
            //project.Project_Manager__c=userinfo.getUserId();
        system.runAs(cpsuser){
            insert project;
        }
        Order ord = new Order();
        Id orderrt = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standard Order').getRecordTypeId();

        ord.Accountid = acc.id;
        ord.ContractId = contract.id;
        ord.name = 'test';
       // ord.RecordTypeId = '0127E0000032wq7';
        ord.Status = 'Draft';
        ord.RecordTypeId = orderrt;
        ord.EffectiveDate = system.today();
        ord.CurrencyIsoCode = contract.CurrencyIsoCode;
        ord.Pricebook2Id = '01s2000000000vQAAQ';
        insert ord;
        
        
        
        orderitem op = new orderitem();
        op.quantity = 1;
        op.UnitPrice = 1000;
        op.orderid = ord.id;
        op.PricebookEntryId = pbe1.id;
        op.Project__c = project.id;
        //op.CurrencyIsoCode = ord.CurrencyIsoCode;
        insert op;
        
        
        PageReference pageRef = Page.OrderProductsOnProject;
            pageRef.getParameters().put('Project', project.id);
            pageRef.getParameters().put('Contract', contractnumber);
            Test.setCurrentPage(pageRef);
            OrderProductsOnProjectController controller = new OrderProductsOnProjectController();
        system.runAs(cpsuser){
            controller.AddProducts();
        }
            //controller.UpdateProjectRollUpFields();
        test.stopTest();            
    }
}