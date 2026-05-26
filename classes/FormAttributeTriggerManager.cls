public class FormAttributeTriggerManager {
    
    public static list<MetadataService.Metadata> mtdt = new list<MetadataService.Metadata>();
    
    public static void beforeInsertUpdate(list<Form_Attribute__c> formAttributesList, Map<Id, Form_Attribute__c> formMap){
        Set<String> uniqueLabel = new Set<String>();
        Set<Form_Attribute__c> recordsToInsert = new Set<Form_Attribute__c>();
        Map<String, Boolean> existingFormAttributeRecordsMap = new Map<String, Boolean>();
        for (Form_Attribute__c fa : formAttributesList) {
            System.debug('Inside For loop ');
            if(fa.Category__c == 'Candidate Import Template'
              && fa.Label__c != null
              && fa.Object__c == 'Bureau_Candidate__c'){
                  System.debug('Inside If statement ');
                  if(formMap != null && fa.Label__c != formMap.get(fa.Id).Label__c){
                      uniqueLabel.add(fa.Label__c.toLowerCase());
                	  recordsToInsert.add(fa);
                  }
                  if(formMap == null){
                      System.debug('Inside second If statement ');
                      SYstem.debug('Label '+fa.Label__c);
                     uniqueLabel.add(fa.Label__c.toLowerCase());
                	  recordsToInsert.add(fa); 
                  }
            }
        }
                
        if (!recordsToInsert.isEmpty()) {
            System.debug('uniqueLabel '+uniqueLabel);
            /*List<Form_Attribute__c> existingAttrubutes = [SELECT Id, Label__c, Object__c, Category__c FROM Form_Attribute__c 
                                      WHERE Label__c IN :uniqueLabel 
                                      AND Category__c = 'Candidate Import Template'
                                      AND Object__c = 'Bureau_Candidate__c'];*/
            List<Form_Attribute__c> existingAttrubutes = [SELECT Id, Label__c, Object__c, Category__c FROM Form_Attribute__c 
                                      WHERE Category__c = 'Candidate Import Template'
                                      AND Object__c = 'Bureau_Candidate__c'];
            
            System.debug('existingAttrubutes '+existingAttrubutes);
            for (Form_Attribute__c fa : existingAttrubutes) {
                existingFormAttributeRecordsMap.put(fa.Label__c, true);
            }
			System.debug('existingFormAttributeRecordsMap '+existingFormAttributeRecordsMap);
			            
            for (Form_Attribute__c fa : recordsToInsert) {
                system.debug('fa '+fa.Label__c);
                if (existingFormAttributeRecordsMap.containsKey(fa.Label__c)) {
                    fa.addError('A record with the same label already exists.');
                }
            }
        }
        
    }
}