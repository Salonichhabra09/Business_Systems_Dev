@isTest(seealldata=true)
private class Kb_ContactUs_Tester {

        static testMethod void testContactUs() {
         
         
    
      
        PageReference pg = new PageReference('/KB_ContactUs');
        pg.getParameters().put('q', 'who');
        pg.getParameters().put('l','en_US' );
        pg.getParameters().put('cg', 'client');
        pg.getParameters().put('operating_system', 'Windows');
        pg.getParameters().put('java', '1.6.0_45');
        pg.getParameters().put('browser1', 'Chrome');
        pg.getParameters().put('browser2', '31.0.1650');
        pg.getParameters().put('flash', '11.9.900');
        pg.getParameters().put('AdditionalComments', 'XYZ');
        pg.getParameters().put('activexenabled', 'Yes');
        pg.getParameters().put('screenreswidth', '1000');
        pg.getParameters().put('screenresheight', '900');
        pg.getParameters().put('popup', 'Yes');
        pg.getParameters().put('error', 'abc');
        pg.getParameters().put('sessionid', '12345');
        pg.getParameters().put('lva', '123456');
        pg.getParameters().put('country', '91');
         pg.getParameters().put('operating_system', 'Windows');
        pg.getHeaders().put('User-Agent', 'Windows 95');
        Test.setCurrentPage(pg);
        //pg.getHeaders().put('operating_system', 'Windows');
        //Test.setCurrentPage(pg);
       /* 
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows CE');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows 98');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows 98; Win 9x 4.90');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 4.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.01');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.1');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.2');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.1');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.2');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.3');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getParameters().put('browser1', 'Microsoft Internet Explorer');
        pg.getHeaders().put('User-Agent', 'Trident/4.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Trident/5.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Trident/6.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Trident/7.0');
        Test.setCurrentPage(pg);*/
        
            
        PageReference pg1 = new PageReference('/KB_ContactUs');
        pg1.getParameters().put('q', 'who');
        pg1.getParameters().put('l','en_US' );
        pg1.getParameters().put('cg', 'candidate');
        pg1.getParameters().put('operating_system', 'Windows');
        pg1.getParameters().put('java', '1.6.0_45');
        pg1.getParameters().put('browser1', 'Chrome');
        pg1.getParameters().put('browser2', '31.0.1650');
        pg1.getParameters().put('flash', '11.9.900');
        pg1.getParameters().put('AdditionalComments', 'XYZ');
        pg1.getParameters().put('activexenabled', 'Yes');
        pg1.getParameters().put('screenreswidth', '1000');
        pg1.getParameters().put('screenresheight', '900');
        pg1.getParameters().put('popup', 'Yes');
        pg1.getParameters().put('error', 'abc');
        pg1.getParameters().put('sessionid', '12345');
        pg1.getParameters().put('lva', '123456');
        pg1.getParameters().put('country', '91');
        pg1.getParameters().put('operating_system', 'Windows');
        pg1.getHeaders().put('User-Agent', 'Windows 95');
        Test.setCurrentPage(pg);
        
        //ApexPages.currentPage().getParameters().put('recaptcha_challenge_field','fdsfsdafsadfas');
        //ApexPages.currentPage().getParameters().put('recaptcha_response_field','sdfdsfdsfasd');
        ApexPages.currentPage().getParameters().put('g-recaptcha-response','fdsfsdafsadfas');
        KB_ContactUs contactUsController = new KB_ContactUs();
        contactUsController.isTestTrue = true;
        //variables getter setter
        string urlString = contactUsController.urlString;
     
      Blob b1 = contactUsController.b1;
      
      string contentType1 = contactUsController.contentType1;
      
      string fileName1 = contactUsController.fileName1;
      
      Blob b2 = contactUsController.b2;
      
      string contentType2 = contactUsController.contentType2;
      
      string fileName2 = contactUsController.fileName2;
      
      Blob  b3 =contactUsController.b3;
      
      string contentType3 = contactUsController.contentType3;
      
      string fileName3 = contactUsController.fileName3;
      
      blob b4 =contactUsController.b4;
      
      string contentType4 = contactUsController.contentType4;
      
      string fileName4 =contactUsController.fileName4;
      
      blob b5 = contactUsController.b5;
      
      string contentType5 =contactUsController.contentType5;
      
      string fileName5 =contactUsController.fileName5;
       
       blob b6 =contactUsController.b6;
      
      string contentType6 =contactUsController.contentType6;
      
      string fileName6 =contactUsController.fileName6;
     
      blob b7 =contactUsController.b7;
      
      string contentType7 =contactUsController.contentType7;
      
      string fileName7 =contactUsController.fileName7;
      
      blob b8 = contactUsController.b8;
      
      string contentType8 =contactUsController.contentType8;
      
      string fileName8 =contactUsController.fileName8;
      
      blob b9 =contactUsController.b9;
      
      string contentType9 =contactUsController.contentType9;
    
      string fileName9 =contactUsController.fileName9;
      
      blob b10 =contactUsController.b10;
     
      string contentType10 =contactUsController.contentType10;
      
      string fileName10 =contactUsController.fileName10;
     
      string pagetyperec = contactUsController.pagetyperec;
      string selectedLanguage =contactUsController.selectedLanguage;

        
        
        //variables getter setter
        contactUsController.isTestTrue = true;
        contactUsController.saveContactUsForm2();
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('operating_system', 'Windows');
        Test.setCurrentPage(pg);
        
        contactUsController.saveContactUsForm2();
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows CE');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm2();
        contactUsController.saveContactUsForm();
        pg.getHeaders().put('User-Agent', 'Windows 98');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows 98; Win 9x 4.90');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 4.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.01');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.1');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 5.2');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.1');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.2');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Windows NT 6.3');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getParameters().put('browser1', 'Microsoft Internet Explorer');
        pg.getHeaders().put('User-Agent', 'Trident/4.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Trident/5.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Trident/6.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        pg.getHeaders().put('User-Agent', 'Trident/7.0');
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        contactUsController.cg = 'client';
        contactUsController.selectedCountry = '91';
        contactUsController.queryType = System.Label.Kb_Case_Client_Query_Type_PB;
        Test.startTest();
           
        KB_CaseCustomerSuccess__c cs = new KB_CaseCustomerSuccess__c(Assigned_To__c = contactUsController.fileName2,
                                                                           Help_Desk_Email__c='test@shl.com',
                                                                           ISO3__c='IND',ISO2__c='IN',
                                                                           Telephone_Code__c=91,Name = 'Test 12');
        insert cs;
        KB_CaseCountryCodeAndAssignmentEmails__c cs1= [select id,Name,Telephone_Code__c,Country_Display_Order__c,Help_Desk_Email__c,ISO3__c from KB_CaseCountryCodeAndAssignmentEmails__c where Name='India'];
        cs1.Assigned_To__c = contactUsController.fileName2;
        update cs1;
        contactUsController.countriesCodeMap1.put(String.valueOf(Integer.valueOf(cs1.Telephone_Code__c)),cs1);
        //contactUsController.countriyCodeCusomerSuccessMap.put(String.valueOf(Integer.valueOf(cs.Telephone_Code__c)),cs);
        Test.setCurrentPage(pg);
        contactUsController.saveContactUsForm();
        contactUsController.saveContactUsForm2();
        contactUsController.reloadCSE();
        contactUsController.cg = 'candidate';
        contactUsController.saveContactUsForm();
        contactUsController.cancelContactUsForm();      
        contactUsController.languages(String.valueOf(Integer.valueOf(cs1.Telephone_Code__c)));
        contactUsController.reloadCSE();
        contactUsController.queryType = System.Label.Kb_Case_Client_Query_Type_TQ;
        contactUsController.cg = 'client';
        contactUsController.cancelContactUsForm();
        contactUsController.reloadCSE(); 
        contactUsController.cg = 'xyz';
        contactUsController.reloadCSE(); 
        contactUsController.applyLanguage();
        contactUsController.selectedCountry = '91';
        contactUsController.applyLanguage();
        Test.stopTest();
    }
    
      static testMethod void testContactUs2() {
           
        PageReference pg = new PageReference('/KB_ContactUs');
        pg.getParameters().put('q', 'who');
        pg.getParameters().put('l','en_US' );
        pg.getParameters().put('cg', 'candidate');
        pg.getParameters().put('operating_system', 'Windows');
        pg.getParameters().put('java', '1.6.0_45');
        pg.getParameters().put('browser1', 'Chrome');
        pg.getParameters().put('browser2', '31.0.1650');
        pg.getParameters().put('flash', '11.9.900');
        pg.getParameters().put('AdditionalComments', 'XYZ');
        pg.getParameters().put('activexenabled', 'Yes');
        pg.getParameters().put('screenreswidth', '1000');
        pg.getParameters().put('screenresheight', '900');
        pg.getParameters().put('popup', 'Yes');
        pg.getParameters().put('error', 'abc');
        pg.getParameters().put('sessionid', '12345');
        pg.getParameters().put('lva', '123456');
        pg.getParameters().put('country', '91');
        pg.getParameters().put('operating_system', 'Windows');
        pg.getHeaders().put('User-Agent', 'Windows CE');
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('recaptcha_challenge_field','fdsfsdafsadfas');
        ApexPages.currentPage().getParameters().put('recaptcha_response_field','sdfdsfdsfasd');
        KB_ContactUs contactUsController = new KB_ContactUs();
    }
  

}