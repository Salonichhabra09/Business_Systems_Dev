public class dependentPicklist_UpdateCtrl {
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    /*
    @AuraEnabled
    Public static List<String> getCountryfromKB_CSet(){
        List<string> CountryLst=new List<string>();
        List<KB_CaseCountryCodeAndAssignmentEmails__c> CsLst=[select Name,Channel__c, ISO3__c, Language__c from KB_CaseCountryCodeAndAssignmentEmails__c where Channel__c='Chat'];
        for(KB_CaseCountryCodeAndAssignmentEmails__c kb:CsLst){
            CountryLst.add(kb.Name);
        }
        return CountryLst;
        
    }*/
    @AuraEnabled
    Public static String getCntryAbrvtn_CSet(String SelctdCountry){
        string CntLst;
        List<KB_CaseCountryCodeAndAssignmentEmails__c> CsLst=[select Name,Channel__c, ISO3__c, Language__c from KB_CaseCountryCodeAndAssignmentEmails__c where Channel__c='Chat'And Name=:SelctdCountry];
        for(KB_CaseCountryCodeAndAssignmentEmails__c kb:CsLst){
            CntLst=kb.ISO3__c;
        }
        return CntLst;
        
    }
    // Added by Pankhuri
    @AuraEnabled
    Public static String getButtonId(String SelctdCountry, String Lang, String Skill){ 
        System.debug('Lang ' + Lang);
        System.debug('Skill ' + Skill);
        System.debug('SelctdCountry' + SelctdCountry);
      /*  if(Skill == 'Product, billing or ordering query'){
           Skill = 'CS';
        } 
        else if(Skill == 'Technology related questions or issue')
          Skill = 'TS'; 
        */  
          if(Skill == Label.Kb_Case_Client_Query_Type_PB){
           Skill = 'CS';
           System.debug('Skill_CS ' + Skill);
        } 
        else if(Skill == Label.Kb_Case_Client_Query_Type_TQ){
          Skill = 'TS';
          System.debug('Skill_TS ' + Skill);
          }
          System.debug('Final_Skill ' + Skill);
          
        if(SelctdCountry != null && Lang != null && Skill != null){      
            ChatCountryLanguageMapping__mdt CLM = new ChatCountryLanguageMapping__mdt();
            CLM = [SELECT Chat_Button_Id__c,Country__c,Language__c,Skill__c 
                   FROM ChatCountryLanguageMapping__mdt WHERE Language__c =: Lang AND Skill__c =: Skill AND Country__c =:SelctdCountry  limit 1];  
                   
                   return CLM.Chat_Button_Id__c;
        }            
        else{
            ChatCountryLanguageMapping__mdt CLM = new ChatCountryLanguageMapping__mdt();
            CLM = [SELECT Chat_Button_Id__c,Country__c,Language__c,Skill__c 
                   FROM ChatCountryLanguageMapping__mdt WHERE DeveloperName=:'Default_No_Agents_Queue' limit 1];  
                   
                   return CLM.Chat_Button_Id__c;
                   //return null;
        }
    }
}