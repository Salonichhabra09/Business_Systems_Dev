@isTest(SeeAllData=true)
public class UpdateOrderFullyActivatedTester {
        Static  TestMethod void UpdateOrderFullyActivated(){
            
                    Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert account;
              
                   
                    Contact Cont=CreateTestData.getContact(account.id);
                    Contract c = new Contract();
       c.name = 'test';
       c.status = 'Draft';
       c.Subscription_Start_Date__c = Date.Today();
       c.AccountId = account.id;
       c.Payment_terms__c = '30 days';
       insert c;
            c.Status= 'Cancelled';
            update c;
  Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
   Opportunity opp=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');
        opp.ownerid=UserInfo.getUserId();
        opp.StageName='Draft';
        opp.Billing_Contact__c=cont.id;
        opp.Closedate=system.today();
        opp.Primary_Contact__c=cont.id;
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
        opp.Forecast_Category__c='Forecast';
        opp.Multi_YearDeal__c='3';
        opp.ContractId = c.id;
        insert opp;

              
            
    Order Ord=new order();
            Ord.AccountId=account.id;
           Ord.ContractId=c.id;
            Ord.Name ='Test';
            Ord.EffectiveDate=date.today();
           
            Ord.Status='Draft';
            
            //Ord.Booking_Date__c=date.today();
            Ord.Booked_Elsewhere__c = true;
          
        	 Ord.Pricebook2Id =pbook.Id;
      insert Ord;
//Ord.Status = 'Activated';
             
//update ord;
           /* try{
                insert(Ord);
            }
            catch(Exception e) {
                update(Ord);
            }*/
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
        OpportunityLineItem LI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',Solution_Cap__c =12,OpportunityId=opp.id,PricebookEntryId=pbe1.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI1);
        OpportunityLineItem LI2=new OpportunityLineItem(RenewableNew__c = 'Ongoing',Solution_Cap__c =12,OpportunityId=opp.id,PricebookEntryId=pbe2.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI2);
        OpportunityLineItem LI3=new OpportunityLineItem(RenewableNew__c = 'Ongoing',Solution_Cap__c =12,OpportunityId=opp.id,PricebookEntryId=pbe3.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI3);
        insert OLIlist;
          
        List<OrderItem> OrderItemList = new list<OrderItem>();
        Set<id> orderitemid = new Set<id>();
        for(OpportunityLineItem oli : OLIlist ){
            OrderItem oi = new OrderItem();
            oi.OrderId = Ord.id;
            oi.Quantity = oli.Quantity;
            oi.UnitPrice = oli.List_Price__c;
            oi.PricebookEntryId = oli.PricebookEntryId;
            OrderItemList.add(oi);
        }
               
        insert OrderItemList;
              Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = cont.id;
        invoiceHeader.Account__c = cont.AccountId;
        invoiceHeader.Contract__c = c.id;
        invoiceHeader.CurrencyIsoCode = c.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = account.BU__c;
        invoiceHeader.Order__c=Ord.id;
        invoiceHeader.Invoice_Status__c='Draft';
        insert invoiceHeader;
       /*Ord.Oats_Status__c = 'Completed';
           Ord.Status = 'Activated';
            update Ord;*/
        
            try{
            UpdateOrderFullyActivated.updateOrder(Ord.Id);
            }
            catch(Exception e){
                system.debug(e);
            }

        }
}