public without sharing class MarkInactiveAddressAndTaxController {

    @AuraEnabled(cacheable=true)
    public static String getAddressAndTaxType(Id recordId){
        try {
            List<India_GST__c> addressAndTaxRecord = [SELECT Id,Type__c,RecordType.Name FROM India_GST__c WHERE Id=:recordId];
            String message = addressAndTaxRecord[0].Type__c!=null?'Are you sure you want to deactivate the '+addressAndTaxRecord[0].Type__c + ' record? ': 'Are you sure you want to deactivate the Address and tax record?';
            if(!addressAndTaxRecord.isEmpty()){
                if(addressAndTaxRecord[0].RecordType.Name == 'Tax'){
                    message += 'The same will not be available for further process and selection in Infor10.';
                }
            }

            return message;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String markInactive(Id recordId){
        try {
            India_GST__c addressAndTaxRecord = new India_GST__c();
            addressAndTaxRecord.Id = recordId;
            addressAndTaxRecord.Is_Active__c = false;

            update addressAndTaxRecord;

            return 'Success';

        } catch (DMLException e) {
            return e.getDMLMessage(0);
        }
    }
}