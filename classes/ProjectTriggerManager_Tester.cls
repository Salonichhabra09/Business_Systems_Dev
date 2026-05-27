@isTest(seeAllData = true)
Private class ProjectTriggerManager_Tester {
    static testMethod void insertProjects()
    {
        //List<Contact> contact = new List<contact>();
        Account ActId=new Account(Industry='Agriculture',name='Test Account',Business_Relationship__c = 'New Logo (Never Traded)',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert ActId;
        //Account ActId =[Select id from Account where Business_Relationship__c='New Logo (Never Traded)' limit 1];
        Contact contact = new Contact();
        contact.LastName = 'test'+System.now().date();
        //contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'India';
        contact.Mailing_City__c = 'India';
        contact.Mailing_ZIP_Postal_Code__c ='122018';
        contact.Mailing_Country__c = 'India';
        contact.accountId = ActId.id;
        insert contact;
        //contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1]; 
        //Contact contact = [SELECT Id,AccountId from Contact where AccountId!=null LIMIT 1]; 
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];
        User usrRecCord = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Co_ordinator__c = true limit 1];
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='Expansion';
        opp.Forecast_Category__c='Pipeline';
        opp.Stagename='Qualifying';
        opp.accountID = contact.accountId;
        insert opp;
        
        
        
        Contract contract = new Contract();
        Account account = [SELECT Id,CurrencyIsoCode from Account where id=:contact.AccountId];
        contract.AccountId = account.Id;   
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;  
        contract.Legal_Order_Name__c='test';
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
        contract.Opportunity__c=opp.id;
        update contract;
        
        opportunity oppty=[select id,Order_Number__c from opportunity where id=:opp.id ];
        oppty.Order_Number__c=contract.Id;//prabhat
        Update oppty;//prabhat
        
        //Create a new Contract Line     
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract.Id;
        contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
        contractLine.IM_Lookup_Code__c = 'Consulting';
        contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
        contractLine.PO_number__c = '12312323423';
        //contractLine.Price__c = 5000;
        contractLine.Order_Method__c='T&E';
        contractLine.Invoicing_Schedule__c = 'Special Invoicing Instructions';
        //contractLine.Proposition__c = 'Graduate Hiring';
        //contractLine.Package__c = 'Graduate Essential';
        //insert contractLine;
        
        Contract_Line__c contractLine2 = new Contract_Line__c();
        contractLine2.Contract__c = contract.Id;
        contractLine2.CurrencyIsoCode = contract.CurrencyIsoCode;
        contractLine2.IM_Lookup_Code__c = 'Consulting';
        contractLine2.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
        contractLine2.PO_number__c = '987177675';
        //contractLine.Price__c = 5000;
        contractLine2.Order_Method__c='T&E';
        contractLine2.Invoicing_Schedule__c = 'Special Invoicing Instructions';
        //contractLine2.Package__c = 'Graduate Essential';
        //contractLine2.Proposition__c = 'Graduate Hiring';
        //insert contractLine2;
        
        list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
        list<ProjectObject__c> listproject = new list<ProjectObject__c> ();
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        test.starttest();
        for(Integer i=0;i<1;i++){
            ProjectObject__c project = new ProjectObject__c();
            project.Project_Name__c = 'project_' + i;
            project.RecordTypeId=selectedRecordTypeId;
            project.Account__c = contact.AccountId;
            project.Contact__c = contact.Id;
            project.Billing_Contact__c = contact.Id;
            project.Opportunity__c = opp.id;
            project.Project_Manager__c =usrRec.id;
            project.LBU__c = '';
            project.CurrencyIsoCode = account.CurrencyIsoCode;
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
            project.Project_Manager__c=usrRec.Id;
            project.Project_Description__c = 'Test';
             project.Comment__c='Test comments';
            project.Reason_for_Delivery_Target_Variance__c = 'Test Variance';
            project.Reason_CPS__c = 'Test Reason';
            //project.Project_Co_ordinator__c=usrRecCord.Id;
            
            listproject.add(project);
        }
        User usrRec2 = [Select id,Company_BU__c from User where name like 'Globus Development' limit 1];
            system.runAs(usrRec2){
        insert listproject;
        }
        system.debug('This is OrderLine of Project'+listproject[0].Order_Line_Number__c);
        for(ProjectObject__c proj:listproject)
        {
            proj.Order_Header_Number__c = contract.id;
            proj.Order_Line_Number__c =null;
            //proj.Delivered__c=System.today()+1;
            proj.LBU__c = 'CH1';
            proj.Project_Description__c='Update Test';
            proj.Comment__c='Test 1';
            proj.Reason_for_Delivery_Target_Variance__c = 'Test 2';
            proj.Reason_CPS__c = 'Test 3';
            //proj.Additional_Scoped_Days__c=3;
            //proj.Project_Status__c='Closed/Delivered';
        }
        ProjectTriggerManager.RunDescriptioncount=1;
        ProjectTriggerManager.RunCountForVariance=1;
        ProjectTriggerManager.RunCountForComment=1;
        ProjectTriggerManager.RunCountForReason=1;
        update listproject;
        
    /*    try{
            update listproject;
        }
        Catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Delivered and closed project Date can only be edited by member of "CPS Project closed/delivered edit rights" group') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } */
        User usrRecCps = [Select id, Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];
        Workpacket__c Wkpkt= new Workpacket__c();
        ProjectObject__c ProjId= [Select id,Project_Status__c from ProjectObject__c where id=:listproject[0].id];    
        Wkpkt.CPS_Project_Number__c=ProjId.Id;
        Wkpkt.Solution_Type__c='BOS';
        Wkpkt.Product_PS__c='Product Support';
        Wkpkt.Description__c='test';
        Wkpkt.Status__c='Planning';
        Wkpkt.Agreed_Delivery__c=System.today();
        Wkpkt.CPS_Project_Manager__c='Prabhat Arora';
        Insert Wkpkt;
        
        ProjId.Project_Status__c='Closed/Delivered';
        ProjId.Audit_Document__c='abc';
        ProjId.Additional_Scoped_Days__c=3;
        ProjId.Project_Manager__c= usrRecCps.Id;
        ProjId.Project_Co_ordinator__c=usrRecCps.Id;
        //ProjId.Order_Line_Number__c=contractLine.Id;

        //update ProjId;
        try{
            update ProjId;
            system.debug('This is UpdatedOrderLine of Project'+ProjId.Order_Line_Number__c);
        }
        Catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot move a CPS project to closed if any related work packets are NOT Closed/Delivered or Closed/Cancelled') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        delete ProjId;
        test.stoptest();
        
        
    }
    
    static testMethod void UpdateOLIonProjects()
    {
    Account ActId=new Account(Industry='Agriculture',name='Test Account',Business_Relationship__c = 'New Logo (Never Traded)',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
    insert ActId;
    //Account ActId =[Select id from Account where Business_Relationship__c=:'New Logo (Never Traded)' limit 1];
       // Contact contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1]; 
        //Contact contact = [SELECT Id,AccountId from Contact where AccountId!=null LIMIT 1]; 
        Contact contact = new Contact();
        contact.LastName = 'test'+System.now().date();
        //contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'India';
        contact.Mailing_City__c = 'India';
        contact.Mailing_ZIP_Postal_Code__c ='122018';
        contact.Mailing_Country__c = 'India';
        contact.accountId = ActId.id;
        insert contact;
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];
        User usrRecCord = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Co_ordinator__c = true limit 1];
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='Expansion';
        opp.Forecast_Category__c='Pipeline';
        opp.Stagename='Qualifying';
        opp.accountID = contact.accountId;
        //test.starttest();
        insert opp;
        
        
        
        Contract contract = new Contract();
        Account account = [SELECT Id,CurrencyIsoCode from Account where id=:contact.AccountId];
        contract.AccountId = account.Id;   
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;  
        contract.Legal_Order_Name__c='test';
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
        contract.Opportunity__c=opp.id;
        update contract;
        
        opportunity oppty=[select id,Order_Number__c from opportunity where id=:opp.id ];
        oppty.Order_Number__c=contract.Id;//prabhat
        Update oppty;//prabhat
        
        //Create a new Contract Line     
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract.Id;
        contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
        contractLine.IM_Lookup_Code__c = 'Consulting';
        contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
        contractLine.PO_number__c = '12312323423';
        //contractLine.Price__c = 5000;
        contractLine.Order_Method__c='T&E';
        //contractLine.Proposition__c = 'Graduate Hiring';
        //contractLine.Package__c = 'Graduate Essential';
        contractLine.Invoicing_Schedule__c = 'Special Invoicing Instructions';
        //insert contractLine;
        
        Contract_Line__c contractLine2 = new Contract_Line__c();
        contractLine2.Contract__c = contract.Id;
        contractLine2.CurrencyIsoCode = contract.CurrencyIsoCode;
        contractLine2.IM_Lookup_Code__c = 'Consulting';
        contractLine2.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
        contractLine2.PO_number__c = '987177675';
        //contractLine.Price__c = 5000;
        contractLine2.Order_Method__c='T&E';
        contractLine2.Invoicing_Schedule__c = 'Special Invoicing Instructions';
        //contractLine2.Package__c = 'Graduate Essential';
        //contractLine2.Proposition__c = 'Graduate Hiring';
        //insert contractLine2;
        
        list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
        list<ProjectObject__c> listproject2 = new list<ProjectObject__c> ();
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        //Test.StartTest();
        for(Integer i=0;i<1;i++){
            ProjectObject__c project2 = new ProjectObject__c();
            project2.Project_Name__c = 'project_' + i;
            project2.RecordTypeId=selectedRecordTypeId;
            project2.Account__c = contact.AccountId;
            project2.Contact__c = contact.Id;
            project2.Billing_Contact__c = contact.Id;
            project2.Opportunity__c = opp.id;
            project2.Project_Manager__c =usrRec.id;
            project2.LBU__c = 'CH1';
            project2.CurrencyIsoCode = account.CurrencyIsoCode;
            project2.Functional_Area__c = 'Consulting & Training';
            project2.Order_Header_Number__c = contract.id;
            project2.Total_Actual_Time__c=1;
            project2.Scoped_Hours_Effort__c=1;
            project2.Additional_Scoped_Days__c = 1;
            project2.Current_Scoped_Days_Effort__c = 1;
            project2.additional_scoped_comments__c = 'test Comments';
            project2.Chargeable__c = 'test';
            project2.Reason__c = 'test';
            project2.CPS_Project_Manager__c='Prabhat Arora';
            project2.Delivered__c=System.today();
            project2.Project_Manager__c=usrRec.Id;
            //project2.Order_Line_Number__c=contractLine.id;
            //project.Project_Co_ordinator__c=usrRecCord.Id;
            
            listproject2.add(project2);
        }
        insert listproject2;
        Test.StartTest();
        Project_Deliverables__c objPD = new Project_Deliverables__c();
        objPD.PS_Offering__c = 'Outsourced Assessment';
        objPD.Project__c=listproject2[0].id;
        objPD.Number__c=10;
        objPD.Deal_Type__c='Assessment for Selection';
        objPD.Complexity__c= 'Tailored';
        objPD.Additional_Comments__c= 'Test Comments';
        listPD.add(objPD);
        //ProjectObject__c Pj=[select id, Order_Line_Number__c from ProjectObject__c where Order_Line_Number__c=null limit 1];
        insert listPD;
        //listproject2[0].Order_Line_Number__c=contractLine2.id;
         listproject2[0].LBU__c='CA1';
        Update listproject2;
        //listproject2[0].Order_Line_Number__c=contractLine.id;
         listproject2[0].Functional_Area__c = 'Commercial Operations';
        listproject2[0].LBU__c = '';
        
        Update listproject2;
         //listproject2[0].Order_Line_Number__c=Pj.Order_Line_Number__c;
         listproject2[0].LBU__c = 'UK1';
         listproject2[0].Project_Description__c='Update Test';
            listproject2[0].Comment__c='Test 1';
            listproject2[0].Reason_for_Delivery_Target_Variance__c = 'Test 2';
            listproject2[0].Reason_CPS__c = 'Test 3';
         ProjectTriggerManager.RunDescriptioncount=1;
        ProjectTriggerManager.RunCountForVariance=1;
        ProjectTriggerManager.RunCountForComment=1;
        ProjectTriggerManager.RunCountForReason=1;
        Update listproject2;
         /*listproject2[0].LBU__c = 'AD1';
        Update listproject2;
        listproject2[0].LBU__c = 'AU1';
        Update listproject2;
        listproject2[0].LBU__c = 'DE1';
        Update listproject2;*/
        Test.StopTest();
        
    
    }
    
    static testMethod void updateProjects()
    {
        //List<Contact> contact = new List<contact>();
        Account ActId=new Account(Industry='Agriculture',name='Test Account',Business_Relationship__c = 'New Logo (Never Traded)',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert ActId;
        //Account ActId =[Select id from Account where Business_Relationship__c='New Logo (Never Traded)' limit 1];
        Contact contact = new Contact();
        contact.LastName = 'test'+System.now().date();
        //contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'India';
        contact.Mailing_City__c = 'India';
        contact.Mailing_ZIP_Postal_Code__c ='122018';
        contact.Mailing_Country__c = 'India';
        contact.accountId = ActId.id;
        insert contact;
        //contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1]; 
        //Contact contact = [SELECT Id,AccountId from Contact where AccountId!=null LIMIT 1]; 
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];
        User usrRecCord = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Co_ordinator__c = true limit 1];
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='Expansion';
        opp.Forecast_Category__c='Pipeline';
        opp.Stagename='Qualifying';
        opp.accountID = contact.accountId;
        insert opp;
        
        
        
        Contract contract = new Contract();
        Account account = [SELECT Id,CurrencyIsoCode from Account where id=:contact.AccountId];
        contract.AccountId = account.Id;   
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;  
        contract.Legal_Order_Name__c='test';
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
        contract.Opportunity__c=opp.id;
        update contract;
        
        opportunity oppty=[select id,Order_Number__c from opportunity where id=:opp.id ];
        oppty.Order_Number__c=contract.Id;//prabhat
        Update oppty;//prabhat
        
        list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
        list<ProjectObject__c> listproject = new list<ProjectObject__c> ();
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        
        for(Integer i=0;i<1;i++){
            ProjectObject__c project = new ProjectObject__c();
            project.Project_Name__c = 'project_' + i;
            project.RecordTypeId=selectedRecordTypeId;
            project.Account__c = contact.AccountId;
            project.Contact__c = contact.Id;
            project.Billing_Contact__c = contact.Id;
            project.Opportunity__c = opp.id;
            project.Project_Manager__c =usrRec.id;
            project.LBU__c = '';
            project.CurrencyIsoCode = account.CurrencyIsoCode;
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
            project.Project_Manager__c=usrRec.Id;
            project.Project_Description__c = 'Test';
            project.Comment__c='Test comments';
            project.Reason_for_Delivery_Target_Variance__c = 'Test Variance';
            project.Reason_CPS__c = 'Test Reason';
            //project.Project_Co_ordinator__c=usrRecCord.Id;
            
            listproject.add(project);
        }
        User usrRec2 = [Select id,Company_BU__c from User where name like 'Globus Development' limit 1];
        system.runAs(usrRec2){
            insert listproject;
        }
        ProjectTriggerManager.RunDescriptioncount=1;
        ProjectTriggerManager.RunCountForVariance=1;
        ProjectTriggerManager.RunCountForComment=1;
        ProjectTriggerManager.RunCountForReason=1;
        
        User usrRecCps = [Select id, Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true and id != :usrRec.Id limit 1];
        
        ProjectObject__c ProjId= [Select id,Project_Status__c from ProjectObject__c where id=:listproject[0].id];    
        
        ProjId.Project_Status__c='Closed/Delivered';
        ProjId.Audit_Document__c='abc';
        ProjId.Additional_Scoped_Days__c=3;
        ProjId.Project_Manager__c= usrRecCps.Id;
        ProjId.Project_Co_ordinator__c=usrRecCps.Id;
        
        test.starttest();
        update ProjId;
        test.stoptest();
    }
    
    
}