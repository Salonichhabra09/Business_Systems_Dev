public without sharing class FieldCreationController
{
    public static String fieldLabel;
    public static String fieldType;
    public static Integer fieldLength;
    public static String fieldFullName;
    public static Integer fieldPrecision;
    public static Integer fieldScale;
    public static String fieldApiName;
    public static List<MetadataService.CustomValue> customValues = new List<MetadataService.CustomValue>();
    public static list<MetadataService.Metadata> mtdt = new list<MetadataService.Metadata>();
    public static list<MetadataService.Metadata> profileList = new list<MetadataService.Metadata>();
    public String jsonData;
    
    public FieldCreationController(String json){
        this.jsonData = json;
    }
    
    public static void fieldDataList(String jsonData, String accessToken){
        Integer len = 255;
        Integer prec = 18;
        Integer scale = 2;
        System.debug('access_token '+accessToken);
        List<String> fieldLabels = new List<String>();
        //if(jsonData != ''){
        list<DataWrapper> convertedData = (list<DataWrapper>)JSON.deserialize(jsonData,list<DataWrapper>.Class); 
        MetadataService.MetadataPort service = createService(accessToken);
            for(DataWrapper wrapper : convertedData){
                list<String> picklistValues = new list<String>();
                String fieldTypeVar;
                System.debug('wrapper.fieldtype '+wrapper.fieldtype);
                if(wrapper.fieldtype == 'text'){
                    prec = null;
                    scale= null;
                    fieldTypeVar = 'Text';
                    System.debug('Hi I am here');
                }else if(wrapper.fieldtype == 'Number'){
                    len = null;
                    fieldTypeVar = 'Number';
                    prec = 18;
                    scale = 2;
                }
                else if(wrapper.fieldtype == 'dropdown' || wrapper.fieldtype == 'radiogroup' || wrapper.fieldtype =='checkboxgroup' ){
                    prec = null;
                    scale= null;
                    len = null;
                    fieldTypeVar = 'Picklist';
                    picklistValues = wrapper.Values.split(',');
                }
                else if(wrapper.fieldtype == 'checkbox'){
                    fieldTypeVar = 'Checkbox';
                }
                else if(wrapper.fieldtype == 'email'){
                    fieldTypeVar = 'Email';
                    prec = null;
                    scale= null;
                    len=null;
                }
                else if(wrapper.fieldtype == 'date'){
                    fieldTypeVar = 'Date';
                    prec = null;
                    scale= null;
                    len=null;
                }
                else if(wrapper.fieldtype == 'textarea'){
                    fieldTypeVar = 'TextArea';
                    prec = null;
                    scale= null;
                    len=32000;
                }
                else if(wrapper.fieldtype == 'time'){
                    fieldTypeVar = 'Time';
                    prec = null;
                    scale= null;
                    len=null;
                }
                fieldLabels.add(wrapper.fieldLabel);
                fieldData(wrapper.fieldLabel, fieldTypeVar, len, prec, scale, true, picklistValues, accessToken); 
                //updateFieldLevelSecurity(accessToken);
            }
        
        List<MetadataService.SaveResult> finalresultList = new List<MetadataService.SaveResult>();
        if(!Test.isRunningTest()){
        List<MetadataService.SaveResult> results = service.createMetadata(mtdt);
        handleSaveResults(results);
        }
        /*List<MetadataService.SaveResult> results1 = service.updateMetadata(profileList);
		finalresultList.addAll(results1);
        handleSaveResults(results);*/
            updateProfilesAsyncMS(accessToken,String.join(fieldLabels, ','));
            updateProfilesAsyncAdmin(accessToken,String.join(fieldLabels, ','));
            updateProfilesAsyncCustomer(accessToken,String.join(fieldLabels, ','));
        	updateFieldLevelSecurityAsyncPendulaPermissionSet(accessToken,String.join(fieldLabels, ','));
       // }
        //}   
    }
    
    public static String generateAPIName(String fLabel){
        // Step 1: Replace hyphens and dots with underscore
        String apiName = fLabel.replaceAll('[-.]', '_');
        
        // Step 2: Remove all other special characters except underscore and space
        apiName = apiName.replaceAll('[^a-zA-Z0-9_ ]', '');
        
        // Step 3: Replace spaces with underscore
        apiName = apiName.replaceAll('\\s+', '_');
        
        // Step 4: Remove consecutive underscores (optional cleanup)
        apiName = apiName.replaceAll('_+', '_');
        
        // Step 5: Trim leading/trailing underscores
        apiName = apiName.replaceAll('^_+|_+$', '');
        
        // Step 6: Ensure the name starts with a letter
        if (!Pattern.matches('^[a-zA-Z].*', apiName)) {
            apiName = 'F' + apiName;
        }
        
        // Step 7: Truncate to 40 characters max
        if (apiName.length() > 40) {
            apiName = apiName.substring(0, 40);
        }
        return apiName;
    }
    
    @future(callout=true)
    public static void updateProfilesAsyncMS(String accessToken,String fieldLabelsStr) {
       List<String> fieldLabels = fieldLabelsStr.split(','); // Convert back to list
       updateFieldLevelSecurityMS(accessToken, fieldLabels);
        
    }
     @future(callout=true)
    public static void updateProfilesAsyncAdmin(String accessToken,String fieldLabelsStr) {
       List<String> fieldLabels = fieldLabelsStr.split(','); // Convert back to list
       updateFieldLevelSecurityAdmin(accessToken, fieldLabels);
        
    }
     @future(callout=true)
    public static void updateProfilesAsyncCustomer(String accessToken,String fieldLabelsStr) {
       List<String> fieldLabels = fieldLabelsStr.split(','); // Convert back to list
       updateFieldLevelSecurityCustomer(accessToken, fieldLabels);
        
    }
     @future(callout=true)
    public static void updateFieldLevelSecurityAsyncPendulaPermissionSet(String accessToken,String fieldLabelsStr) {
       List<String> fieldLabels = fieldLabelsStr.split(','); // Convert back to list
        if (!Test.isRunningTest()) {
       updateFieldLevelSecurityPendulaPermissionSet(accessToken, fieldLabels);
        }
    }
    
    public class DataWrapper{
        public String fieldLabel;
        public String fieldtype;
        public String Values;
        public list<String> picklistValues;
    }
    
    @AuraEnabled
    public static void fieldData(String fLabel, String fType, Integer fLength, Integer fPrecision, 
                                 Integer fScale, Boolean isFLS, list<String> picklistValues, String accessToken){
                                     MetadataService.CustomField cf = new MetadataService.CustomField();
                                     //String tempVar = fLabel.replaceAll(' ', '_');
                                     
                                     /* START */
                                     // Step 1: Replace hyphens and dots with underscore
                                     String apiName = fLabel.replaceAll('[-.]', '_');
                                     
                                     // Step 2: Remove all other special characters except underscore and space
                                     apiName = apiName.replaceAll('[^a-zA-Z0-9_ ]', '');
                                     
                                     // Step 3: Replace spaces with underscore
                                     apiName = apiName.replaceAll('\\s+', '_');
                                     
                                     // Step 4: Remove consecutive underscores (optional cleanup)
                                     apiName = apiName.replaceAll('_+', '_');
                                     
                                     // Step 5: Trim leading/trailing underscores
                                     apiName = apiName.replaceAll('^_+|_+$', '');
                                     
                                     // Step 6: Ensure the name starts with a letter
                                     if (!Pattern.matches('^[a-zA-Z].*', apiName)) {
                                         apiName = 'F_' + apiName;
                                     }
                                     
                                     // Step 7: Truncate to 40 characters max
                                     if (apiName.length() > 40) {
                                         apiName = apiName.substring(0, 40);
                                     }
                                     
                                     // Step 8: Append Salesforce custom field suffix
                                     fieldApiName = apiName + '__c'; 
                                     /* END */
                                     
                                     //fieldApiName = tempVar + '__c'; 
                                     fieldFullName = 'Bureau_Candidate__c.' + apiName + '__c';
                                     fieldLabel = fLabel;
                                     fieldType = fType;
                                     if(fieldType != 'Checkbox'){
                                         System.debug('Hi I am here 133');
                                         fieldLength = fLength;
                                         fieldPrecision = fPrecision;
                                         fieldScale = fScale;
                                         System.debug('Hi I am here 137');
                                     }
                                     if(fieldType == 'Picklist'){
                                         for(String str : picklistValues){
                                             addValuesInPicklist(str);
                                         }
                                         createPicklistField(accessToken);
                                     }
                                     else{
                                         createField(accessToken);
                                     }
                                     
                                 }
    
    public static void createField(String accessToken)
    {
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = fieldFullName; //'Job__c.TestField__c';
        customField.label = fieldLabel; //'Test Field';
        customField.type_x = fieldType; //'Text';
        customField.length = fieldLength; //42;
        customField.precision = fieldPrecision;
        customField.scale = fieldScale;
        if(fieldType=='Checkbox'){
            customField.defaultValue = 'false';
        }
        mtdt.add(customField);
        
    }
    
    public static void addValuesInPicklist(String picklistVal){
        MetadataService.CustomValue cv1 = new MetadataService.CustomValue();
        cv1.label = picklistVal;//'One';
        cv1.fullName = picklistVal;//'One';
        cv1.isActive = true;
        cv1.default_x = false;
        customValues.add(cv1);
    }
    
    public static void createPicklistField(String accessToken){
        System.debug('customValues '+ customValues);
        MetadataService.MetadataPort service = createService(accessToken);
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = fieldFullName; //'Job__c.TestField__c';
        customField.label = fieldLabel; //'Test Field';
        customField.type_x = fieldType; //'Picklist';
        
        // Define the Value Set and Value Set Definitions
        MetadataService.ValueSet vs = new MetadataService.ValueSet();
        MetadataService.ValueSetValuesDefinition vd = new MetadataService.ValueSetValuesDefinition();
        
        // Define the picklist values
          
        vd.value = customValues;
        vd.sorted = true;
        vs.valueSetDefinition = vd;
        
        // Use valueSet instead of Picklist
        customField.valueSet  = vs;
		
        /*List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);*/
        mtdt.add(customField);
    }
    
    public static void updateFieldLevelSecurityMS(String accessToken,List<String> fieldLabels)
    {
        for (String fieldLabel : fieldLabels) {
            
        String tempVar = fieldLabel.replaceAll(' ', '_');
        String fieldFullName = 'Bureau_Candidate__c.' + generateAPIName(fieldLabel) + '__c';
        MetadataService.Profile msl = new MetadataService.Profile();
        msl.fullName = 'Managed Service Lightning';
        msl.custom = true;
        MetadataService.ProfileFieldLevelSecurity fieldSecMsl = new MetadataService.ProfileFieldLevelSecurity();
        fieldSecMsl.field = fieldFullName;//'Bureau_Candidate__c.cvb__c';
        fieldSecMsl.editable = true;
        msl.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSecMsl} ;   
        profileList.add(msl);
         if(!Test.isRunningTest()){    
        MetadataService.MetadataPort service = createService(accessToken);
        List<MetadataService.SaveResult> results = service.updateMetadata(profileList);
        handleSaveResults(results);
         }
        profileList = new list<MetadataService.Metadata>();
        }
        
    }
    public static void updateFieldLevelSecurityAdmin(String accessToken,List<String> fieldLabels)
    {
        for (String fieldLabel : fieldLabels) {
            
        String tempVar = fieldLabel.replaceAll(' ', '_');
        String fieldFullName = 'Bureau_Candidate__c.' + generateAPIName(fieldLabel) + '__c';
        MetadataService.Profile admin = new MetadataService.Profile();
        admin.fullName = 'Admin';
        admin.custom = false;
        MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec.field = fieldFullName;//'Bureau_Candidate__c.cvb__c';
        fieldSec.editable = true;
        admin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec} ;
        profileList.add(admin);
         if(!Test.isRunningTest()){
        MetadataService.MetadataPort service = createService(accessToken);
        List<MetadataService.SaveResult> results = service.updateMetadata(profileList);
        handleSaveResults(results);
         }
        profileList = new list<MetadataService.Metadata>();
        }
        
    }
    public static void updateFieldLevelSecurityCustomer(String accessToken,List<String> fieldLabels)
    {
        for (String fieldLabel : fieldLabels) {
            
        String tempVar = fieldLabel.replaceAll(' ', '_');
        String fieldFullName = 'Bureau_Candidate__c.' + generateAPIName(fieldLabel) + '__c';
        MetadataService.Profile crp = new MetadataService.Profile();
        crp.fullName = 'Customer Request Profile';
        crp.custom = true;
        MetadataService.ProfileFieldLevelSecurity fieldSecCrp = new MetadataService.ProfileFieldLevelSecurity();
        fieldSecCrp.field = fieldFullName;//'Bureau_Candidate__c.cvb__c';
        fieldSecCrp.editable = true;
        crp.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSecCrp} ;   
        profileList.add(crp);
             if(!Test.isRunningTest()){
        MetadataService.MetadataPort service = createService(accessToken);
        List<MetadataService.SaveResult> results = service.updateMetadata(profileList);
        handleSaveResults(results);
             }
        profileList = new list<MetadataService.Metadata>();
        }
        
    }
    
   /* public static void updateFieldLevelSecurityPendulaPermissionSet(String accessToken, List<String> fieldLabels) {
    for (String fieldLabel : fieldLabels) {
        String tempVar = fieldLabel.replaceAll(' ', '_');
        String fieldFullName = 'Bureau_Candidate__c.' + tempVar + '__c';

        MetadataService.PermissionSet ps = new MetadataService.PermissionSet();
        ps.fullName = 'Pendula_API_Only'; // Update with your actual Permission Set API name

        MetadataService.PermissionSetFieldPermissions fieldPerm = new MetadataService.PermissionSetFieldPermissions();
        fieldPerm.field = fieldFullName;
        fieldPerm.editable = false;
        fieldPerm.readable = true;

        ps.fieldPermissions = new List<MetadataService.PermissionSetFieldPermissions> { fieldPerm };

        if (!Test.isRunningTest()) {
            MetadataService.MetadataPort service = createService(accessToken);
            List<MetadataService.SaveResult> results = service.updateMetadata(
                new List<MetadataService.Metadata> { ps }
            );
            handleSaveResults(results);
        }
    }
}*/
    
    public static void updateFieldLevelSecurityPendulaPermissionSet(String accessToken, List<String> fieldLabels) {
    // Step 1: Create MetadataService instance
    MetadataService.MetadataPort service = createService(accessToken);
    // Step 2: Read the existing permission set
    MetadataService.IReadResult iResult = service.readMetadata('PermissionSet', new String[] { 'Pendula_API_Only' });
    MetadataService.ReadPermissionSetResult readResult = (MetadataService.ReadPermissionSetResult) iResult;

    if (readResult != null && readResult.records != null && readResult.records.size() > 0) {
        MetadataService.PermissionSet ps = (MetadataService.PermissionSet) readResult.records[0];

        if (ps.fieldPermissions == null) {
            ps.fieldPermissions = new List<MetadataService.PermissionSetFieldPermissions>();
        }

        // Convert existing field permissions to a map for easy lookup
        Map<String, MetadataService.PermissionSetFieldPermissions> existingFLS = new Map<String, MetadataService.PermissionSetFieldPermissions>();
        for (MetadataService.PermissionSetFieldPermissions fp : ps.fieldPermissions) {
            existingFLS.put(fp.field, fp);
        }

        // Step 3: Loop through the provided field API names and update or add FLS
         for (String fieldLabel : fieldLabels) {
        String tempVar = fieldLabel.replaceAll(' ', '_');
        String fieldFullName = 'Bureau_Candidate__c.' + generateAPIName(fieldLabel) + '__c';

            if (existingFLS.containsKey(fieldFullName)) {
                // Update existing field permission to read-only
                existingFLS.get(fieldFullName).readable = true;
                existingFLS.get(fieldFullName).editable = true;
            } else {
                // Add new field permission
                MetadataService.PermissionSetFieldPermissions newPerm = new MetadataService.PermissionSetFieldPermissions();
                newPerm.field = fieldFullName;
                newPerm.readable = true;
                newPerm.editable = true;
                ps.fieldPermissions.add(newPerm);
            }
        }

        // Step 4: Update the permission set via Metadata API
        if (!Test.isRunningTest()) {
            List<MetadataService.SaveResult> results = service.updateMetadata(
                new List<MetadataService.Metadata> { ps }
            );
            handleSaveResults(results);
        }
    } else {
        System.debug('Permission Set "Pendula_API_Only" not found.');
    }
}


    
    /*public static void addFieldToLayout(String accessToken)
    {
        MetadataService.MetadataPort service = createService(accessToken);

        // Read the Layout
        MetadataService.Layout layout = (MetadataService.Layout) service.readMetadata('Layout', new String[] { 'Bureau_Candidate__c-Bureau Candidate Layout' }).getRecords()[0];

        // Add Layout section, layout, item and field
        if(layout.layoutSections == null)
            layout.layoutSections = new List<MetadataService.LayoutSection>();
        
        MetadataService.LayoutSection newLayoutSection = new MetadataService.LayoutSection();
        newLayoutSection.style = 'OneColumn';
        newLayoutSection.label = 'User Added Fields';
        MetadataService.LayoutColumn newLayoutColumn = new MetadataService.LayoutColumn();
        MetadataService.LayoutItem newLayoutItem = new MetadataService.LayoutItem();
        newLayoutItem.field = fieldApiName; //'TestField__c';
        newLayoutColumn.layoutItems = new List<MetadataService.LayoutItem> { newLayoutItem };
        newLayoutSection.layoutColumns = new List<MetadataService.LayoutColumn> { newLayoutColumn };
        layout.layoutSections.add(newLayoutSection);

        // Update the Layout
        handleSaveResults(
            service.updateMetadata(
                new MetadataService.Metadata[] { layout }));
    }*/
    
    public class FieldCreationControllerException extends Exception { }
    
    public static MetadataService.MetadataPort createService(String accessToken)
    {
        Http http = new Http();
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.timeout_x = 120000;
        service.SessionHeader = new MetadataService.SessionHeader_element();
        System.debug(UserInfo.getSessionId());
        service.SessionHeader.sessionId = accessToken;//UserInfo.getSessionId();
        return service;
    }
    
    /**
* Example helper method to interpret a SaveResult, throws an exception if errors are found
**/
    public static void handleSaveResults(list<MetadataService.SaveResult> saveResults)
    {
        for(MetadataService.SaveResult saveResult : saveResults){
            // Nothing to see?
        if(saveResult==null || saveResult.success){
            System.debug('Field created successfully');
        }
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new FieldCreationControllerException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new FieldCreationControllerException('Request failed with no specified error.');
        }
        
    }
    
}