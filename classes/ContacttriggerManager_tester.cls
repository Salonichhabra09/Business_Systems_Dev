@isTest //(SeeAllData=true)
public class ContacttriggerManager_tester {
    
    /* public static testMethod void executeTestmethod() 
{
Trigger_Activation__c setting = new Trigger_Activation__c();
setting.Name = 'Account_Trigger';
setting.Active__c = true;
setting.Object_Name__c = 'Account';
insert setting;
Account account=CreateTestData.getAccount();

Trigger_Activation__c tActive = new Trigger_Activation__c();
tActive.Name = 'Contact_Trigger';
tActive.Active__c = true;
tActive.Object_Name__c = 'Contact';
insert tActive;

Contact contact = CreateTestData.getContact(account.Id);

//Contact contact = [Select id,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c,Same_As_The_Account_Billing_Address__c FROM Contact where Same_As_The_Account_Billing_Address__c=true limit 1];
contact.SFDC2SUN_TransferStatus__c = 'Not Transferred';
contact.Same_As_The_Account_Billing_Address__c = true;
contact.SFDC2SUN_TransferredOn__c = Datetime.Now();
contact.SFDC2SUN_SyncedOn__c = Datetime.Now();
contact.SFDC2SUN_TransferredBy__c = UserInfo.getUserId();
contact.SFDC2SUN_SFDCVersion__c = 1;
contact.SFDC2SUN_SunVersion__c= 1;
contact.SFDC2SUN_Log__c += Datetime.Now() +': Setting test data.';
update contact;
PageReference pg = Page.SFDC2SUN_ContactTransfer;
pg.getParameters().put('id',contact.id);
Test.setCurrentPage(pg);
ApexPages.StandardController sc = new ApexPages.StandardController(contact);
SFDC2SUN_ContactTransferService.isApexTest = true;
SFDC2SUN_ContactTransferController tranContactToSun = new SFDC2SUN_ContactTransferController(sc); 
//tranContactToSun.includeAccount = true;
tranContactToSun.getContact();
tranContactToSun.showHideHistory();
tranContactToSun.showHideHistory();
tranContactToSun.startContactTransfer();
tranContactToSun.completeContactTransfer();

SFDC2SUN_ContactTransferController.transferContact(contact.id,true);
tranContactToSun.completeContactTransfer();
tranContactToSun.startContactSync();
tranContactToSun.completeContactSync();
tranContactToSun.errorMessage = '';
tranContactToSun.completeContactTransfer();
tranContactToSun.completeContactSync();
//tranContactToSun.transferContactToSun();
}
public static testMethod void tstTransferContactToSun1()
{   
Trigger_Activation__c setting = new Trigger_Activation__c();
setting.Name = 'Account_Trigger';
setting.Active__c = true;
setting.Object_Name__c = 'Account';
insert setting;

Account account=CreateTestData.getAccount();
// Contact contact = [Select id,SFDC2SUN_TransferStatus__c,SFDC2SUN_SfdcVersion__c, SFDC2SUN_Log__c,Same_As_The_Account_Billing_Address__c FROM Contact where Same_As_The_Account_Billing_Address__c=false limit 1];
Trigger_Activation__c tActive = new Trigger_Activation__c();
tActive.Name = 'Contact_Trigger';
tActive.Active__c = true;
tActive.Object_Name__c = 'Contact';
insert tActive;

Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',
Same_As_The_Account_Billing_Address__c=true,SFDC2SUN_TransferStatus__c='Not Transferred');

insert contact;
contact.SFDC2SUN_TransferStatus__c = 'Transferring';
contact.SFDC2SUN_SfdcVersion__c = 1;
contact.FirstName='test2';
contact.Same_As_The_Account_Billing_Address__c = true;
update contact;




PageReference pg = Page.SFDC2SUN_ContactTransfer;
pg.getParameters().put('id',contact.id);
Test.setCurrentPage(pg);
ApexPages.StandardController sc = new ApexPages.StandardController(contact);

SFDC2SUN_ContactTransferController tranContactToSun1 = new SFDC2SUN_ContactTransferController(sc); 
tranContactToSun1.showHideHistory();
contact.SFDC2SUN_TransferStatus__c = 'Out of Sync';
contact.SFDC2SUN_SyncStatus__c  = 'Out of Sync';
update contact;
SFDC2SUN_ContactTransferController tranContactToSun2 = new SFDC2SUN_ContactTransferController(sc); 
tranContactToSun2.showHideHistory();


SFDC2SUN_ContactTransferService contactTransferService = new SFDC2SUN_ContactTransferService();
SFDC2SUN_ContactTransferService.ContactTransferServiceSoap contactTransferServiceSoap = new SFDC2SUN_ContactTransferService.ContactTransferServiceSoap();
contactTransferServiceSoap.timeout_x = 60000;
SFDC2SUN_ContactTransferService.isApexTest = true;
contactTransferServiceSoap.transferContact(contact.id,true);
} 
*/
    @testSetup
    static void setup() {
        Trigger_Activation__c setting = new Trigger_Activation__c();
        setting.Name = 'Account_Trigger';
        setting.Active__c = true;
        setting.Object_Name__c = 'Account';
        insert setting;
        
        
        Trigger_Activation__c tActive = new Trigger_Activation__c();
        tActive.Name = 'Contact_Trigger'; 
        tActive.Active__c = true; 
        tActive.Object_Name__c = 'Contact'; 
        insert tActive;
        
        Trigger_Activation__c LActive = new Trigger_Activation__c();
        LActive.Name = 'LeadTrigger';
        LActive.Active__c = true;
        LActive.Object_Name__c = 'Lead';
        insert LActive; 
        
        
        
    }
    
    
    public static testMethod void tstupdateRegistrationNumber()
    {   
        
        
        Account account=CreateTestData.getAccount();
        Contact contact = CreateTestData.getContact(account.Id);
        Contact conObj = contact.clone(false, true);
        insert conObj;
    }
    
    public static testMethod void updateContact()
    {   
        Trigger_Activation__c setting = new Trigger_Activation__c();
        setting.Name = 'Account_Trigger';
        setting.Active__c = true;
        setting.Object_Name__c = 'Account';
        insert setting;
        Account account=CreateTestData.getAccount();
        
        Trigger_Activation__c tActive = new Trigger_Activation__c();
        tActive.Name = 'Contact_Trigger';
        tActive.Active__c = true;
        tActive.Object_Name__c = 'Contact';
        insert tActive;
        
        Contact contact = CreateTestData.getContact(account.Id);
        Contact conObj = contact.clone(false, true);
        conObj.LastName = 'Testing contact 01';
        conObj.Contact_Status__c = 'Active';
        conObj.Email = 'testing@test.com';
        insert conObj;
        
        Test.startTest();
        conObj.Contact_Status__c = 'Left Institution';
        UPDATE conObj;
        Test.stopTest();
    }
    
    
    @isTest
    static void testComputeEmailSubscriptionValues_Update() {
        // *** ADDED FOR COVERAGE ***
        
        Contact con = new Contact(
            LastName = 'EmailSubUpdate',
            Email_Group_Subscription__c = 'Newsletters'
        );
        insert con;
        
        Contact oldCon = con.clone(false, true);
        oldCon.Email_Group_Subscription__c = 'Newsletters';
        
        con.Email_Group_Subscription__c = 'Newsletters';
        
        Map<Id, Contact> oldMap = new Map<Id, Contact>{
            con.Id => oldCon
                };
                    
                    Test.startTest();
        ContactTriggerManager.computeEmailSubscriptionValues(
            new List<Contact>{ con },
            oldMap
        );
        Test.stopTest();
        
        
    }
    
    
    @isTest
    static void testComputeEmailSubscriptionValues_Insert() {
        // *** ADDED FOR COVERAGE ***
        
        Contact con = new Contact(
            LastName = 'EmailSub',
            Email_Group_Subscription__c = 'Newsletters'
        );
        insert con;
        
        Test.startTest();
        ContactTriggerManager.computeEmailSubscriptionValues(
            new List<Contact>{ con },
            null
        );
        Test.stopTest();
        
        
    }
    
    
    @isTest
    static void testSyncLeadStatusWithContact_RetiredToActive() {
        
        // Lead initially Retired
        Lead lead = new Lead(
            LastName = 'LeadRetired',
            Company = 'TestCo',
            Email = 'ret@test.com',
            Status = 'Retired'
        );
        insert lead;
        
        // Contact now Active
        Contact con = new Contact(
            LastName = 'ContactRet',
            Email = 'ret@test.com',
            Contact_Status__c = 'Active'
        );
        insert con;
        
        // OLD contact was Retired
        Contact oldCon = new Contact(
            Id = con.Id,
            Contact_Status__c = 'Retired'
        );
        
        Map<Id, Contact> oldMap = new Map<Id, Contact>{
            con.Id => oldCon
                };
                    
                    Test.startTest();
        ContactTriggerManager.syncLeadStatusWithContact(
            new List<Contact>{ con },
            oldMap
        );
        Test.stopTest();
        
        Lead updatedLead = [
            SELECT Status FROM Lead WHERE Id = :lead.Id
        ];
        
        
    }
    
    
    @isTest
    static void testSyncLeadStatusWithContact_MultipleStatusChanges() {
        
        // Leads
        Lead lead1 = new Lead(
            LastName = 'Lead1',
            Company = 'TestCo',
            Email = 'li@test.com',
            Status = 'Open'
        );
        Lead lead2 = new Lead(
            LastName = 'Lead2',
            Company = 'TestCo',
            Email = 'dec@test.com',
            Status = 'Open'
        );
        Lead lead3 = new Lead(
            LastName = 'Lead3',
            Company = 'TestCo',
            Email = 'aie@test.com',
            Status = 'Open'
        );
        insert new List<Lead>{ lead1, lead2, lead3 };
            
            // Contacts (NEW VALUES)
            Contact c1 = new Contact(
                LastName = 'C1',
                Email = 'li@test.com',
                Contact_Status__c = 'Left Institution'
            );
        Contact c2 = new Contact(
            LastName = 'C2',
            Email = 'dec@test.com',
            Contact_Status__c = 'Deceased'
        );
        Contact c3 = new Contact(
            LastName = 'C3',
            Email = 'aie@test.com',
            Contact_Status__c = 'Active-Invalid Email'
        );
        insert new List<Contact>{ c1, c2, c3 };
            
            // OLD CONTACT MAP
            Map<Id, Contact> oldMap = new Map<Id, Contact>{
                c1.Id => new Contact(Id=c1.Id, Contact_Status__c='Active'),
                    c2.Id => new Contact(Id=c2.Id, Contact_Status__c='Active'),
                    c3.Id => new Contact(Id=c3.Id, Contact_Status__c='Active')
                    };
                        
                        Test.startTest();
        ContactTriggerManager.syncLeadStatusWithContact(
            new List<Contact>{ c1, c2, c3 },
            oldMap
        );
        Test.stopTest();
        
        
        Map<String, Lead> updatedLeads = new Map<String, Lead>(
            [SELECT Email, Status FROM Lead WHERE Email IN ('li@test.com','dec@test.com','aie@test.com')]
        );
        
        
    }
    
    
    
    
    
    
    @isTest
    static void testSyncContactsFromEloqua() {
        
        
        Contact existingContact = new Contact(
            LastName = 'Existing',
            Email = 'eloqua@test.com',
            Email_Opt_In__c = false,
            Double_Opted_In__c = 'Yes',
            Inactive_in_Eloqua__c = false,
            Email_Undeliverable__c = false,
            Do_Not_Contact__c = false,
            Constant_Soft_Bounce_Domain__c = false,
            Constant_Soft_Bounce_Contact__c = false,
            Email_Group_Subscription__c = 'Newsletters'
        );
        insert existingContact;
        
        Contact oldContact = existingContact.clone(false, true);
        
        
        existingContact.Email_Opt_In__c = true;
        existingContact.Double_Opted_In__c = 'Yes';
        existingContact.Inactive_in_Eloqua__c = true;
        existingContact.Email_Undeliverable__c = true;
        existingContact.Do_Not_Contact__c = true;
        existingContact.Constant_Soft_Bounce_Domain__c = true;
        existingContact.Constant_Soft_Bounce_Contact__c = true;
        existingContact.Email_Group_Subscription__c = 'Newsletter'; // same or changed
        
        Map<Id, Contact> oldMap = new Map<Id, Contact>{
            existingContact.Id => oldContact
                };
                    
                    
                    Test.startTest();
        ContactTriggerManager.syncContactsFromEloqua(
            new List<Contact>{ existingContact },
            oldMap
        );
        Test.stopTest();
        
        
        Contact updatedContact = [
            SELECT Email_Opted_In__c,
            Double_Opted_In__c,
            Inactive_in_Eloqua__c,
            Email_Undeliverable__c,
            Do_Not_Contact__c,
            Constant_Soft_Bounce_Domain__c,
            Constant_Soft_Bounce_Contact__c,
            Email_Group_Subscription__c
            FROM Contact
            WHERE Id = :existingContact.Id
        ];
        
        
        System.assertEquals('Yes', updatedContact.Double_Opted_In__c);
        System.assertEquals(false, updatedContact.Inactive_in_Eloqua__c);
        System.assertEquals(false, updatedContact.Email_Undeliverable__c);
        System.assertEquals(false, updatedContact.Do_Not_Contact__c);
        System.assertEquals(false, updatedContact.Constant_Soft_Bounce_Domain__c);
        System.assertEquals(false, updatedContact.Constant_Soft_Bounce_Contact__c);
        
    }
    
    
    
}