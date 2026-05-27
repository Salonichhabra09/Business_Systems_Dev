public without sharing class Kb_Controller {
  public Kb_Controller(ApexPages.StandardController stdController) {
 /* public Integer countValue{get;set;} 
  public String selArID{get;set;}
  public PageReference increaseCount(){
          System.debug('>>>>>>>>>>selArID>' + selArID);
          
          FAQ__kav MSBarticle = [select id,of_Clicks__c from FAQ__kav WHERE Id =: selArID];
          System.debug('>>>>>>>>OLD >>increaseCount>' + MSBarticle.of_Clicks__c);
          MSBarticle.of_Clicks__c = MSBarticle.of_Clicks__c + 1; 
          update MSBarticle ;
          
          System.debug('>>>>>>>New>>>increaseCount>' + MSBarticle.of_Clicks__c);
          return null;
  } */
  
   
  /* ***** SEARCH DEFAULTS ***** */
  /*   public static List<URL_Redirects__c> RedirectList{get;set;}

  private final static String SEARCH_PROMPT = System.Label.PKB2_Search_Prompt;
  private final static String CONTACT_US_PROMPT = System.Label.PKB2_Contact_Us_Prompt;
  private final static String CONTACT_US_BUTTON_PROMPT = System.Label.PKB2_Ask_Button;
  private final static String SEARCH_BUTTON_PROMPT = System.Label.PKB2_Search_Button;
  private final static Integer CASE_SUBJECT_LENGTH = 250;
  private static String DEFAULT_CATEGORY_GROUP = 'SHL_Support';
  public static String pg{get;set;}
  // Changes Start by Apoorva Gautam-----User Story--SSE-132 
  public static string str_cg{get;set;}
  // Changes Start by Apoorva Gautam-----User Story--SSE-132 
  // Changes Start by Apoorva Gautam-----User Story--SSE-135 
  public static Boolean bol_con{get; set;}
  public static Boolean bol_nm{get; set;}
        public String redirect{get;set;}

  // Changes Start by Apoorva Gautam-----User Story--SSE-135 
 
  // Changes Added(Start) by Apoorva Gautam-----CRI-00001647
  Public static String str_pt{get;set;}
  // Changes Added(End) by Apoorva Gautam-----CRI-00001647
  Public static String str_fq{get;set;}
  // Changes start by Apoorva Gautam-----CRI-00001639
  Public static Boolean Bol_kb{get;set;}
  // Changes End by Apoorva Gautam-----CRI-00001639
  public string  getUcountry(){ String s=[SELECT id,country__c from user where id=:UserInfo.getUserId()].country__c; return s;}
  // this needs to be public and not final so that it can be overridden during unit tests, since
  // kav records created in apex cannot be set to 'online', and can only stay at 'draft'
  public static String DEFAULT_PUBLISH_STATUS = 'online';
  public String showCatBarId{get;set;}
  // this also needs to be public to allow setting during unit tests
  public static String DEFAULT_SITE_NAME = Site.getName();
  public List<CatLevel1> catLevelList{get;set;}
  public List<CatLevel1> catAllLevelList{get;set;}
  //REMOVE THIS ONCE THE FOOTER IS FINALIZED
  public List<CatLevel1> catAllLevelList_Old{get;set;}
  public String searchPrompt { get { return (displayContactUs ? CONTACT_US_PROMPT : SEARCH_PROMPT); } } 
  public String buttonPrompt { get { return (displayContactUs ? CONTACT_US_BUTTON_PROMPT : SEARCH_BUTTON_PROMPT); } } 

  /* ***** URL PARAM CONSTANTS AND GETTERS ***** */
  /*public final static String QUERY_PARAM = 'q';
  public final static String LANGUAGE_PARAM = 'l';
  public final static String CATEGORY_PARAM = 'c';
  public final static String CATEGORY_GP_PARAM = 'cg';
  public final static String SESSION_PARAM = 's';
  public final static String FEEDBACK_PARAM = 'f';
  public final static String CONTACT_US_PARAM = 'cu';
  public final static String FEEDBACK_SOURCE_PARAM = 'fs';
  public final static String PAGE_NUM_PARAM = 'pn';
  public final static String LAST_VIEW_ARTICLE = 'lva';
  //public final static String DEFAULT_CATEGORY_GROUP='dc'
  
  public String queryParam            { get { return QUERY_PARAM; } }
  public String languageParam         { get { return LANGUAGE_PARAM; } }
  public String categoryParam         { get { return CATEGORY_PARAM; } }
  public String sessionParam          { get { return SESSION_PARAM; } }
  public String feedbackParam         { get { return FEEDBACK_PARAM; } }
  public String feedbackSourceParam   { get { return FEEDBACK_SOURCE_PARAM; } }
  public String contactUsParam        { get { return CONTACT_US_PARAM; } }
  public String pageNumParam          { get { return PAGE_NUM_PARAM; } }
  public String categoryGpParam       { get { return CATEGORY_GP_PARAM; } }
  public String categoryGP { get; set; }
  public String LVA { get; set; }
  //public Integer showCatBar{get;set;}
  public String selectedClientinfo{get;set;}//Variable is used to Control the Client Information Label on Page(on clicking Client Information Link)
  public String selectedSubCategory{get;set;}
  public String langFlag{get;set;}
  public String footerCatList{get;set;}
  public String footerCatList1{get;set;}
  //REMOVE THIS ONCE THE FOOTER IS FINALIZED footerCatList_Old
  public String footerCatList_Old{get;set;}
  public String menuBarCatList{get;set;}
    /* ***** KAV EXTENSION, used in VF pages when need to derive article type name from whole object name ***** */
  /*private final static String KAV_EXTENSION = '__kav';
  public String kavExtension          { get { return KAV_EXTENSION; } }
  
  // value for the contact us param
  private final static String CONTACT_US_VALUE = '1';
  public String contactUsValue        { get { return CONTACT_US_VALUE; } }

  // values for the feedback params, informs conditionals about which panel to display on the pkb_Feedback page
  private final static String FEEDBACK_SHOW_YESNO = 'yesno';
  private final static String FEEDBACK_SHOW_DIALOG = 'dialog';
  public String feedbackShowYesNo     { get { return FEEDBACK_SHOW_YESNO; } }
  public String feedbackShowDialog    { get { return FEEDBACK_SHOW_DIALOG; } }

  // values for the feedback source param; these *MUST* match the picklist values for the Feedback_Source__c field of the deflection object
  private final static String FEEDBACK_CONTACT_US = 'ContactUs';
  private final static String FEEDBACK_SEARCH = 'Search';
  private final static String FEEDBACK_RELATED = 'RelatedArticle';
  public String feedbackContactUs     { get { return FEEDBACK_CONTACT_US; } }
  public String feedbackSearch        { get { return FEEDBACK_SEARCH; } }
  public String feedbackRelated       { get { return FEEDBACK_RELATED; } }
  
  /* ***** STANDARD CONTROLLER AND RECORD PROPS AND COLLECTIONS ***** */
  /*public ApexPages.StandardController theSC { get; set; }
  public KnowledgeArticle theArticle { get; set; }
  public KnowledgeArticleVersion theAV { get; set; }
  public KnowledgeArticleData theKad { get; set; }
  public List<KnowledgeArticleData> rssKads { get; set; }
  public List<KnowledgeArticleData> featuredKads { get; set; }
  public List<KnowledgeArticleData> recommendedKads { get; set; }
  public String publishStatus { get { return DEFAULT_PUBLISH_STATUS; } }
  transient public FAQ__kav selectedArticle{get;set;}
  public List<FAQ__kav> managedServiceArticleList{get;set;}
  public Boolean showManageService{get;set;}
  public Boolean facebook { get {return Site.getTemplate().getUrl().endsWith('pkb_Template_fb');} }
  public Map<String,List<FAQ__DataCategorySelection>> catVsArticlesList {get;set;}
  public Map<String,List<FAQ__kav>> catVsArticlesList1 {get;set;}
  //public Boolean catDef1{get {return URL.getCurrentRequestUrl().toExternalForm().contains('Customers');}}
  public Kb_Controller() { }
  
  /* ***** CONTROLLER EXTENSION CONSTRUCTOR ***** */ 
  /*public Kb_Controller(ApexPages.StandardController sc) {
    //system.debug('****='+Site.getTemplate().getUrl());
    //system.debug('**getCurrentSiteUrl()**='+Site.getCurrentSiteUrl());
    //system.debug('**getCurrentRequestUrl()**='+URL.getCurrentRequestUrl());
    //system.debug('**getOriginalUrl()**='+Site.getOriginalUrl());
    // Note that when an article is being viewed via its "url name" url (and not via a url that has the article ID in it),
    // the standard controller record will only have the Id field populated, and not any other field. This is true even if
    // other article fields are placed on the VF page; they will still not be populated. 
    //
    // It is for this reason that to get basic information
    // about the article (such as title) when an article is being viewed, the KnowledgeArticleVersion object must be queried
    // using the Id of the article. To assist with this, there is a wrapper class in this controller called KnowledgeArticleData
    // that pulls together KAV data and combines it with the article type data from describe calls.
    
    Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    showContactUsForm = false;
    theArticle = (KnowledgeArticle)sc.getRecord();
    selectedClientinfo=null;
    // countValue = 10;
    // populate the props with ural param values as needed
    String q = ApexPages.currentPage().getParameters().get(QUERY_PARAM);
    if(q!=null)
    {
        q = q.replace('&quot;','"');
        q = q.replace('&amp;','&');
        q = q.replace('&#39;','\'');
        q = q.replace('&lt;','<');
        q = q.replace('&gt;','>');
    }
    String l = ApexPages.currentPage().getParameters().get(LANGUAGE_PARAM);
    String c = ApexPages.currentPage().getParameters().get(CATEGORY_PARAM);
    String cg = ApexPages.currentPage().getParameters().get(CATEGORY_GP_PARAM);
    String fs = ApexPages.currentPage().getParameters().get(FEEDBACK_SOURCE_PARAM);    
    LVA = ApexPages.currentPage().getParameters().get(LAST_VIEW_ARTICLE);
    
    // Changes Added(Start) by Apoorva Gautam-----CRI-00001647
    String s= ApexPages.currentPage().getParameters().get('pt');
    str_pt=s;
    // Changes Added(End) by Apoorva Gautam-----CRI-00001647
    str_fq= ApexPages.currentPage().getParameters().get('lg');
    // Changes start by Apoorva Gautam-----CRI-00001639
    String sUrl=Apexpages.currentPage().getUrl();
    if(sUrl.contains('Client_Information')){Bol_kb=true;}    
    if(sUrl.contains('Client_Information')&&(sUrl.contains('q='))){Bol_kb=false;}
    // Changes End by Apoorva Gautam-----CRI-00001639
    //String st=ApexPages.currentPage().getParameters().get('cg');
    // Changes Start by Apoorva Gautam-----User Story--SSE-132   
        if(cg=='candidate'){str_cg='candidate';}
        if(cg=='client') {str_cg='client';}
      // Changes Start by Apoorva Gautam-----User Story--SSE-132   
    // Changes Start by Apoorva Gautam-----User Story--SSE-135
    if(sUrl.contains('KB_ContactUs')){bol_con=true;}
    if(sUrl.contains('s=true')){bol_nm=true;}
    // Changes End by Apoorva Gautam ------ User-Story----SSE-135
    /*** Modified by Sagar Pareek *******/
    /*String dc = ApexPages.currentPage().getParameters().get('dc');
    if(dc=='' || dc==null){
        DEFAULT_CATEGORY_GROUP='SHL_Support';
    }
    else{ DEFAULT_CATEGORY_GROUP='Partner_Portal';cg='FAQ';}
    pg=ApexPages.currentPage().getParameters().get('p');
    /****** Modification ends by Sagar Pareek *****/
    /*System.debug('The language we are getting is'+l);
    System.debug(c);
    System.debug(cg);
    System.debug(fs);
    System.debug(LVA);
    if (!isBlank(l)) selectedLanguage = String.escapeSingleQuotes(l);
    if (!isBlank(c)) selectedCategory = String.escapeSingleQuotes(c);
    //if (!isBlank(cg)) categoryGP = String.escapeSingleQuotes(cg);
    categoryGP = string.valueOf(ApexPages.currentPage()).substringAfter('/apex/');
    if(categoryGP.indexOf('?') != -1){categoryGP = categoryGP.substringBefore('?').toLowerCase();
    }else{
        categoryGP = categoryGP.substringBefore(']').toLowerCase();
    }
    system.debug('**categoryGP**='+categoryGP);
    if(cg != null && cg !=''){
        categoryGP = cg.toLowerCase();
    }
    system.debug('**cg**='+cg);
    system.debug('**categoryGP**='+categoryGP);
    if (!isBlank(fs)) feedbackSource = fs; // need to validate this value is in the picklist when inserting
   
    if(pg=='' || pg==null){
         langFlag = selectedLanguage+'.jpg';
    }
    else{langFlag = selectedLanguage+'.png';}
    Cookie sessionCookie = ApexPages.currentPage().getCookies().get('PKB2SessionId');
    
    if (sessionCookie == null) {
        sessionId = randomUUID();
        sessionCookie = new Cookie('PKB2SessionId', sessionId, '/', -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{sessionCookie});
    } else {sessionId = sessionCookie.getValue();}
    enteredSearchQuery = searchPrompt;

    if (!isBlank(q) && q.length() > 1) {
        urlSearchQuery = q;
        enteredSearchQuery = q;
    }else{
        /*String errorMsg  = System.Label.PKB2_js_search_string_length;
        errorMsg = errorMsg.replace('NNN','3');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorMsg));*/
     //}
    // This section will show articles in case of selected category is managed services bureau or managed sercices project or bureau services
    /*showManageService = false;
    if(c != null && q== null){
        if(c.trim().equalsIgnoreCase('SHL_Support:Managed_Services_Bureau') || c.trim().equalsIgnoreCase('SHL_Support:Managed_Services_Project') || c.trim().equalsIgnoreCase('SHL_Support:Bureau_Services')){
            showManageService = true;
            Set<Id> MSBArticlesIds = new Set<Id>();
            for(FAQ__DataCategorySelection acs : [SELECT DataCategoryName,ParentId FROM FAQ__DataCategorySelection WHERE IsDeleted = false]){
                //system.debug('**Managed_Services_Bureau**='+acs);
                if(c.trim().contains(acs.DataCategoryName)){
                    MSBArticlesIds.add(acs.ParentId);
                }
            }
            system.debug('**Managed_Services_Bureau**='+MSBArticlesIds);
            managedServiceArticleList = new List<FAQ__kav>();
            if(l.equalsIgnoreCase('en_US')){
                //it will fetch only english/default language version only
                //Modification by Sagar Pareek starts here
                if(pg=='ch' || pg=='sl' || pg=='dd'){
                    if(pg=='ch'){
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online']){
                        managedServiceArticleList.add(MSBarticle);
                        }
                    }
                    if(pg=='sl'){
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online'  ]){
                        managedServiceArticleList.add(MSBarticle);
                        }
                    
                    }
                    if(pg=='dd'){
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online' ]){
                        managedServiceArticleList.add(MSBarticle);
                        }
                    }
                }
                else{
                    for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online']){
                        managedServiceArticleList.add(MSBarticle);
                    }
                }    
            }else{
                //fetch the translated version of the article
                Set<Id> translatedArticleIdset = new Set<Id>();
                if(pg=='ch' || pg=='sl' || pg=='dd'){}
                    if(pg=='ch'){
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online'  ]){
                        translatedArticleIdset.add(MSBarticle.KnowledgeArticleId);
                        }
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE KnowledgeArticleId IN: translatedArticleIdset AND Language=: l AND PublishStatus = 'Online' ]){
                        managedServiceArticleList.add(MSBarticle);
                        }
                    }
                    if(pg=='sl'){
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online' ]){
                        translatedArticleIdset.add(MSBarticle.KnowledgeArticleId);
                        }
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE KnowledgeArticleId IN: translatedArticleIdset AND Language=: l AND PublishStatus = 'Online' ]){
                        managedServiceArticleList.add(MSBarticle);
                        }
                    }
                    if(pg=='dd'){
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online' ]){
                        translatedArticleIdset.add(MSBarticle.KnowledgeArticleId);
                        }
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE KnowledgeArticleId IN: translatedArticleIdset AND Language=: l AND PublishStatus = 'Online' ]){
                        managedServiceArticleList.add(MSBarticle);
                        }
                    }
                else{
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE Id IN: MSBArticlesIds AND PublishStatus = 'Online']){
                        translatedArticleIdset.add(MSBarticle.KnowledgeArticleId);
                        }
                        for(FAQ__kav MSBarticle : [select id,ArticleNumber,title,KnowledgeArticleId from FAQ__kav WHERE KnowledgeArticleId IN: translatedArticleIdset AND Language=: l AND PublishStatus = 'Online']){
                        managedServiceArticleList.add(MSBarticle);
                        }
                }
            }
            system.debug('**managedServiceArticleList**='+managedServiceArticleList.size());
        }
    }
    selectedArticle = new FAQ__kav();
    try{
        if(theArticle.Id != null){
            selectedArticle = [SELECT Attachment4__ContentType__s,Attachment4__Body__s,Attachment4__Name__s,Attachment3__ContentType__s,Attachment3__Body__s,Attachment3__Name__s,Attachment2__ContentType__s,Attachment2__Body__s,Attachment2__Name__s,Attachment1__ContentType__s,Attachment1__Body__s,Attachment1__Name__s,Attachment__ContentType__s,Attachment__Body__s,Attachment__Name__s,Answer__c,ArticleNumber,ArticleType,Id,KnowledgeArticleId,Language,Plain_Text__c,PublishStatus,Question__c,Related_Articles__c,Summary,Title,UrlName,ValidationStatus FROM FAQ__kav WHERE Language =: l AND KnowledgeArticleId =: theArticle.Id AND PublishStatus = 'Online'];
        }
    }catch(Exception ex){
        //do nothing
    }
        
    if (!viewingArticle) { 
      buildFeaturedKads();
    }
    
    theKad = new KnowledgeArticleData();
    if (viewingArticle) {
      theKad = new KnowledgeArticleData(theArticle.Id, selectedLanguage);
      theAV = theKad.theAV;
        List<PKB_Article_Feedback_Deflection__c> afds = [
          select
            Id
          from PKB_Article_Feedback_Deflection__c
          where
            Session_ID__c = :sessionId and
            Article_Number__c = :theKad.articleNumber
        ];
        feedbackRecorded = !afds.isEmpty();
    }  

    if (searchExecuted) {
        buildRecommendedKads();
    }
    system.debug('\n\n[DEBUG-PKB CONTROLLER] cONSTRUCTOR\n=========\n'+c);
    if (displayContactUs) {
        theCud = new ContactUsData();
    }
    
    //Added by Apoorva-------For collapsible
    
     selectedSubCategory = '';
        catLevelList = new List<CatLevel1> ();
        catAllLevelList = new List<CatLevel1> ();
        populateCatList();
        populateAllCatList();
        catVsArticlesList = new Map<String,List<FAQ__DataCategorySelection>>();
        catVsArticlesList1 = new Map<String,List<FAQ__kav>>();
        List<FAQ__kav> pArticlesList = new List<FAQ__kav>();
        for(FAQ__kav MSBarticle : [select id,MasterVersionId, ArticleNumber,title,KnowledgeArticleId,Question__c,Answer__c from FAQ__kav  WHERE language =:l  AND PublishStatus = 'Online' order by title asc]){
            pArticlesList.add(MSBarticle); 
        }
        //String query = 'SELECT id,MasterVersionId,Question__c,Answer__c,KnowledgeArticleId,Title,ArticleNumber FROM FAQ__kav WHERE Language = \''+l +'\' AND PublishStatus = \'Online\' order by title asc';
        //List<FAQ__kav> pArticlesList  = Database.query(query);
        Set<Id> articleIdsSet = new Set<Id>();
        if(pArticlesList!=null && pArticlesList.size()>0){
            for(FAQ__kav parArticle : pArticlesList){               
                articleIdsSet.add(parArticle.MasterVersionId);
            }   
        }    
        System.debug('****articleIdsSet****'+articleIdsSet);    
        string query = 'SELECT DataCategoryGroupName,DataCategoryName,Id,Parent.id,Parent.KnowledgeArticleId,Parent.Title,Parent.ArticleNumber FROM FAQ__DataCategorySelection  WHERE Parent.id in :articleIdsSet AND Parent.PublishStatus = \'Online\'';
        List<FAQ__DataCategorySelection> partnerArticlesList  = Database.query(query);
        System.debug('****partnerArticlesList****'+partnerArticlesList);
        Map<String,List<String>> masterIdVsCatMap = new Map<String,List<String>>();
        if(partnerArticlesList!=null && partnerArticlesList.size()>0) {        
            for(FAQ__DataCategorySelection pArtDataCate:partnerArticlesList) {            
                if(masterIdVsCatMap.get(pArtDataCate.Parent.id)==null){
                    List<String> catList = new List<String>();
                    catList.add(pArtDataCate.DataCategoryName);
                    masterIdVsCatMap.put(pArtDataCate.Parent.id,catList);
                }
                else
                    masterIdVsCatMap.get(pArtDataCate.Parent.id).add(pArtDataCate.DataCategoryName);
            }
        }
        System.debug('****masterIdVsCatMap****'+masterIdVsCatMap);
        Map<String,List<String>> catAndItsChildCatMap = new Map<String,List<String>>();
        
        List<String> allCategoriesList = new List<String>();
        if(catVsArticlesList1.get('All')==null) {        
            catVsArticlesList1.put('All',new List<FAQ__kav>());
        }
        for(CatLevel1 cat1:catLevelList)
        {    
        
            system.debug('cat1----------'+cat1);
            allCategoriesList.add(cat1.apiName);
            system.debug('allCategoriesList----------'+allCategoriesList);
            if(catAndItsChildCatMap.get(cat1.apiName)==null)
            {
                catAndItsChildCatMap.put(cat1.apiName,new List<String>());
            }
            if(catVsArticlesList.get(cat1.apiName)==null)
            {
                catVsArticlesList.put(cat1.apiName,new List<FAQ__DataCategorySelection>());
            }
            if(catVsArticlesList1.get(cat1.apiName)==null)
            {
                catVsArticlesList1.put(cat1.apiName,new List<FAQ__kav>());
            }
            if(cat1.childCategory.size()>0)
            {
                for(CatLevel2 cat2: cat1.childCategory) {                                
                    if(catVsArticlesList.get(cat2.apiName)==null)
                    {
                        catVsArticlesList.put(cat2.apiName,new List<FAQ__DataCategorySelection>());
                    }
                    System.debug('*****cat2****'+cat2);
                    if(cat2.childCategory.size()>0)
                    {
                        for(CatLevel3 cat3: cat2.childCategory) {                                                
                            if(catVsArticlesList.get(cat3.apiName)==null)
                            {
                                catVsArticlesList.put(cat3.apiName,new List<FAQ__DataCategorySelection>());
                            }
                            System.debug('*****cat3****'+cat3);
                            if(cat3.childCategory.size()>0)
                            {
                                for(CatLevel4 cat4: cat3.childCategory) { 
                                    if(catVsArticlesList.get(cat4.apiName)==null)
                                    {
                                        catVsArticlesList.put(cat4.apiName,new List<FAQ__DataCategorySelection>());
                                    }
                                    System.debug('*****cat4****'+cat4);
                                }
                            }
                        }
                    }                  
                }
            }
            if(cat1.childCategory.size()>0)
            {
                for(CatLevel2 cat2: cat1.childCategory)
                {
                    allCategoriesList.add(cat2.apiName);
                    catAndItsChildCatMap.get(cat1.apiName).add(cat2.apiName);
                    if(catAndItsChildCatMap.get(cat2.apiName)==null)
                    {
                        catAndItsChildCatMap.put(cat2.apiName,new List<String>());
                    }
                    if(catVsArticlesList1.get(cat2.apiName)==null)
                    {
                        catVsArticlesList1.put(cat2.apiName,new List<FAQ__kav>());
                    }
                    System.debug('*****cat2****'+cat2);
                    if(cat2.childCategory.size()>0)
                    {
                        for(CatLevel3 cat3: cat2.childCategory)
                        {
                            allCategoriesList.add(cat3.apiName);
                            catAndItsChildCatMap.get(cat1.apiName).add(cat3.apiName);
                            catAndItsChildCatMap.get(cat2.apiName).add(cat3.apiName);
                            if(catAndItsChildCatMap.get(cat3.apiName)==null)
                            {
                                catAndItsChildCatMap.put(cat3.apiName,new List<String>());
                            }
                            if(catVsArticlesList1.get(cat3.apiName)==null)
                            {
                                catVsArticlesList1.put(cat3.apiName,new List<FAQ__kav>());
                            }
                            System.debug('*****cat3****'+cat3);
                            if(cat3.childCategory.size()>0)
                            {
                                for(CatLevel4 cat4: cat3.childCategory)
                                {allCategoriesList.add(cat4.apiName);catAndItsChildCatMap.get(cat1.apiName).add(cat4.apiName);catAndItsChildCatMap.get(cat2.apiName).add(cat4.apiName);catAndItsChildCatMap.get(cat3.apiName).add(cat4.apiName);if(catVsArticlesList1.get(cat4.apiName)==null){catVsArticlesList1.put(cat4.apiName,new List<FAQ__kav>());}
                                   
                                }
                            }
                        }
                    }
                }
            }
        }
        catAndItsChildCatMap.put('All',allCategoriesList);
        if(partnerArticlesList!= null && partnerArticlesList.size()>0)
        {
            for(FAQ__DataCategorySelection partArticle:partnerArticlesList)
            {
                if(catVsArticlesList.get('SHL_Support:'+partArticle.DataCategoryName)!=null)
                {
                    catVsArticlesList.get('SHL_Support:'+partArticle.DataCategoryName).add(partArticle);
                }
            }
        }
        if(pArticlesList!= null && pArticlesList.size()>0)
        {
            for(FAQ__kav art:pArticlesList)
            {              
                if(masterIdVsCatMap.get(art.MasterVersionId)!=null && masterIdVsCatMap.get(art.MasterVersionId).size()>0)
                {
                    for(String cat:masterIdVsCatMap.get(art.MasterVersionId))
                    {
                        System.debug('*****masterIdVsCatMap.get(art.MasterVersionId)****'+masterIdVsCatMap.get(art.MasterVersionId));
                        if(catVsArticlesList1.get('SHL_Support:'+cat)!=null)
                        {
                            System.debug('*****catAndItsChildCatMap.get(SHL_Support:+cat)****'+catAndItsChildCatMap.get('SHL_Support:'+cat));
                            if(catAndItsChildCatMap.get('SHL_Support:'+cat)!=null && catAndItsChildCatMap.get('SHL_Support:'+cat).size()>0)
                            {                             
                                for(String childCat:catAndItsChildCatMap.get('SHL_Support:'+cat))
                                {
                                    catVsArticlesList1.get(childCat).add(art);
                                }
                                catVsArticlesList1.get('SHL_Support:'+cat).add(art);
                            }
                            else
                                catVsArticlesList1.get('SHL_Support:'+cat).add(art);                        
                        }
                    }
                }
            }
            System.debug('*****catVsArticlesList1****'+catVsArticlesList1);
        }
        
        //Changes Added by Apoorva Gautam
    
    
    //showCatBar = 0;
    selectedSubCategory = '';
    //populate category level list
    catLevelList = new List<CatLevel1> ();
    catAllLevelList = new List<CatLevel1> ();
    catAllLevelList_Old = new List<CatLevel1> ();
    populateCatList();
    populateAllCatList();
    
    footerCatList = '<li class="footer-catLevel3"><div onClick="footerCAARedirect(\''+System.Label.Kb_Assessment_Advice_URL+'\')">'+System.Label.Kb_Assessment_Advice+'</div></li>';
    footerCatList += '<li class="footer-catLevel3"><div onClick="footerCAARedirect(\''+System.Label.Kb_Practice_Test_URL+'\')">'+System.Label.Kb_Practice_Test+'</div></li>';
    footerCatList += '<li class="footer-catLevel3"><div onClick="footerCAARedirect(\''+System.Label.Kb_Disabled_Talent_URL+'\')">'+System.Label.Kb_Disabled_Talent+'</div></li>';
    
    footerCatList1 = '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'SHL on Demand\')">'+System.Label.Kb_Footer_SHL_on_Demand+'</div></li>';
    footerCatList1 += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'Select2Perform\')">'+System.Label.Kb_Footer_Select2Perform+'</div></li>';
    //footerCatList1 += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'SHL Central\')">'+System.Label.Kb_Footer_SHL_Central+'</div></li>';
    //footerCatList1 += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'Client Training\')">'+System.Label.Kb_Footer_Client_Training+'</div></li>';
    //footerCatList1 += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'Billing and Delivery Help\')">'+System.Label.Kb_Footer_Billing_Delivery+'</div></li>';
    
    //REMOVE THIS ONCE THE FOOTER IS FINALIZED footerCatList_Old
    footerCatList_Old = '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'SHL on Demand\')">'+System.Label.Kb_Footer_SHL_on_Demand+'</div></li>';
    footerCatList_Old += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'Select2Perform\')">'+System.Label.Kb_Footer_Select2Perform+'</div></li>';
    footerCatList_Old += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'SHL Central\')">'+System.Label.Kb_Footer_SHL_Central+'</div></li>';
    footerCatList_Old += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'Client Training\')">'+System.Label.Kb_Footer_Client_Training+'</div></li>';
    footerCatList_Old += '<li class="footer-catLevel2"><div onClick="footerCAARedirect(\'Billing and Delivery Help\')">'+System.Label.Kb_Footer_Billing_Delivery+'</div></li>';
    /*
    menuBarCatList = '<div class="catlevel3" style="padding:2px 15px;float:left;" onClick="footerCAARedirect(\'Assessment Advice\')">'+System.Label.Kb_Assessment_Advice+'</div>';
    menuBarCatList += '<div class="catlevel3" style="padding:2px 15px;float:left;" onClick="footerCAARedirect(\'Practice Test\')">'+System.Label.Kb_Practice_Test+'</div>';
    menuBarCatList += '<div class="catlevel3" style="padding:2px 15px;float:left;" onClick="footerCAARedirect(\'Disabled Talent\')">'+System.Label.Kb_Disabled_Talent+'</div>';
    */
    /*menuBarCatList = '<li><a href="javascript:void();" onClick="footerCAARedirect(\''+System.Label.Kb_Assessment_Advice_URL+'\')">'+System.Label.Kb_Assessment_Advice+'</a></li>';
    menuBarCatList += '<li><a href="javascript:void();" onClick="footerCAARedirect(\''+System.Label.Kb_Practice_Test_URL+'\')">'+System.Label.Kb_Practice_Test+'</a></li>';
    menuBarCatList += '<li><a href="javascript:void();" onClick="footerCAARedirect(\''+System.Label.Kb_Disabled_Talent_URL+'\')">'+System.Label.Kb_Disabled_Talent+'</a></li>';
    
  }
  
   public String randomUUID(){
        String kHexChars = '0123456789abcdefABCDEF';
        String returnValue = '';
        Integer nextByte = 0;
        for(Integer i = 0; i < 16; i++){
            if(i==4 || i==6 || i==8 || i==10){
                returnValue += '-';
            }
            //generate a "byte"; i.e., number in range [-2^7,2^7-1]
            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if(i==6){
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            if(i==8){
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            
            returnValue += charAt(kHexChars,nextByte >> 4);
            returnValue += charAt(kHexChars,nextByte & 15);
        }
        return returnValue;
    }
    
    private String charAt(String str, Integer index) {
        if(str == null){
            return null;
        }
        if(str.length() <= 0){
            return str;    
        }
        if(index < 0 || index >= str.length()){
            return null;    
        }
        return str.substring(index, index+1);
    }
  
  /* ***** SOSL QUERY TO ENABLE SEARCH RSS ***** */
  // method is called from action parameter of RSS page and builds the KAD wrapper collection that will enable
  // the RSS feed for a single search query (via SOSL)
  /*public void prepareSearchRSS() {
    if (viewingArticle) return;

    String catQ = 'WITH DATA CATEGORY ';
    rssKads = new List<KnowledgeArticleData>();

    String escapedQ = String.escapeSingleQuotes(urlSearchQuery);

    // return if query is less than 2 chars long, page will render with an empty list
    if (isBlank(escapedQ) || urlSearchQuery.length() < 2) return;
    
    // build the WITH DATA CATEGORY clause if any categories were selected
    if (!isBlank(selectedCategory)) catQ += buildCategorySosl();

    system.debug('\n\n[DEBUG-PKB CONTROLLER] DATA CATEGORY \n=========\n'+catQ);

    // build the query string and execute the query
    String q = '';
    String pageSearch='';
    if(pg=='sl' || pg=='ch' || pg=='dd'){if(pg=='sl'){pageSearch='Login Page';}if(pg=='ch'){pageSearch='Main Portal Page';    }if(pg=='dd'){pageSearch='DD Page';}q += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(' +join(kavFields, ',')+ ' where PublishStatus = :publishStatus and Language = :selectedLanguage   order by LastPublishedDate desc limit 20) ';}
    else{
        
        q += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(' +join(kavFields, ',')+ ' where PublishStatus = :publishStatus and Language = :selectedLanguage order by LastPublishedDate desc limit 20) ';
    
    
    }
    
    if (!isBlank(selectedCategory)) q += catQ;

    List<List<SObject>> searchList = Search.query(q);
    List<KnowledgeArticleVersion> kavs = (List<KnowledgeArticleVersion>)searchList[0];

    // convert the KAV records into a list of the wrapper class records for easier handling  
    for (KnowledgeArticleVersion k : kavs) {
        rssKads.add(new KnowledgeArticleData(k));
    }
  }

  public String buildCategorySosl() {
    if (isBlank(selectedCategory)) return null;

    List<String> selectedCategorySOSL = new List<String>();
    List<String> selectedCategoryTokens = selectedCategory.split(',');
    List<String> temp;
      for (String s : selectedCategoryTokens) {
        temp = s.trim().split(':');
        temp[0] = temp[0] + '__c';
        temp[1] = temp[1] + '__c';
        selectedCategorySOSL.add(join(temp, ' ABOVE_OR_BELOW '));//AT
      }
    return (join(selectedCategorySOSL, ' AND '));           
  }

  public Boolean foundRecommended { get; set; }
  public void buildRecommendedKads() {
    if (viewingArticle && !displayContactUs) return;

    List<PKB_Featured__c> pkbfs;
    Set<String> anums = new Set<String>();
    String escapedQ = String.escapeSingleQuotes(urlSearchQuery);
    String orQuery;

    // split the escapedQ by spaces, trim by commas, periods, etc
    orQuery = buildOrQuery(escapedQ);
    
    // gather recommended article numbers based on keyword search from the PKB Featured object and put into set
    // recommended articles are records of the PKB_Feedback__c object that:
    // 1. have a keyword value
    // 2. have the Is_Keyword_Article__c box is checked
    // 3. the record Name field matches the name of the Site being viewed
    String q = '';
    String pageSearch='';
    if(pg=='sl' || pg=='ch' || pg=='dd'){if(pg=='sl'){pageSearch='Login Page';}if(pg=='ch'){pageSearch='Main Portal Page';}if(pg=='dd'){pageSearch='DD Page';}q += 'FIND \'' + orQuery + '\' IN ALL FIELDS RETURNING ';q += 'PKB_Featured__c(Keyword__c, Article_Number__c where Is_Keyword_Article__c = true'; if (isSite) q+= ' and PKB_Name__c = :siteName';q+= ' ORDER BY Order__c ASC NULLS last)';}
    
    else{
        q += 'FIND \'' + orQuery + '\' IN ALL FIELDS RETURNING ';
    q += 'PKB_Featured__c(Keyword__c, Article_Number__c where Is_Keyword_Article__c = true'; 
    if (isSite) q+= ' and PKB_Name__c = :siteName';
    q+= ' ORDER BY Order__c ASC NULLS last)';
    
    }
      
      system.debug('\n\n==['+siteName+']=== '+q);
      
      
    List<List<SObject>> searchList = Search.query(q);
    pkbfs = (List<PKB_Featured__c>)searchList[0];

    for (PKB_Featured__c p : pkbfs) {
      anums.add(p.Article_Number__c);
    }

    // return if no recommended articles were found
    if (anums.isEmpty()) return;

    // get the KADS from the list of article IDs and set foundRecommended based on that 
    recommendedKads = initFromListOfArticleNumbers(new List<String>(anums), selectedLanguage);
    foundRecommended = !recommendedKads.isEmpty();
  }
  
  public static String buildOrQuery(String keywords) {
    if (isBlank(keywords)) return null;

system.debug('\n\n[DEBUG-PKB CONTROLLER] buildOrQuery  \n=========\n'+keywords);

    String temp;
     //keywords = keywords.replaceAll('"' ,'\\"');
    List<String> tokens = String.escapeSingleQuotes(keywords).replaceAll('[!.,?<>;:{}@#$%^&*()]', '').split(' ');
    List<String> newTokens = new List<String>();

    for (String s : tokens) {
      temp = s.trim();
      if (!excludedSoslWords.contains(temp))
        newTokens.add(temp + '*');
    }
    tokens = newTokens;

    if (tokens.isEmpty()) { return null;
    } else if (tokens.size() == 1) {
        return tokens[0];
    } else {return join(tokens, ' OR ');
    }
  }

  /* ***** GENERAL DISPLAY AND PROCESSING CONDITIONALS ***** */
  /*public Boolean viewingArticle { get { return (!isBlank(theArticle.Id)); } }
  public Boolean searchExecuted { get { return (!isBlank(allSearchParams) && enteredSearchQuery != searchPrompt); } }
  public Boolean displaySearchResultsLink { get { return (!isBlank(allSearchParams)); } }
  public Boolean isSite { get { return !isBlank(Site.getName()); } }

  /* ***** HANDLE TO CURRENT INSTANCE OF CONTROLLER (to be passed to rendered VF components, avoids re-instantiation of controller) ***** */
  /*public Kb_Controller kbCon { get { return this; } }


  /* ***** SEARCH RELATED PROPS AND METHODS ***** */

  /*public String selectedCategory { get; set; }
  public String urlSearchQuery { get; set; }
  public String feedbackSource { get; set; }
  public String enteredSearchQuery { 
    set;
    get {
        if (enteredSearchQuery == null) enteredSearchQuery = searchPrompt;
        return enteredSearchQuery;
    }
  }

  // url-formatted (e.g. key1=value1&key2=value2) string containing the params related to a search  
  public String allSearchParams {
    get {
        String s;
        List<String> keyValues = new List<String>();
        if (!isBlank(urlSearchQuery))   keyValues.add(QUERY_PARAM+ '=' +EncodingUtil.urlEncode(urlSearchQuery, 'UTF-8'));
        if (!isBlank(selectedLanguage)) keyValues.add(LANGUAGE_PARAM+ '=' +EncodingUtil.urlEncode(selectedLanguage, 'UTF-8'));
        if (!isBlank(selectedCategory)) keyValues.add(CATEGORY_PARAM+ '=' +EncodingUtil.urlEncode(selectedCategory, 'UTF-8'));
        if (displayContactUs)           keyValues.add(CONTACT_US_PARAM+ '=' +CONTACT_US_VALUE);
        s = join(keyValues, '&');
      return s;
    }
  }

  public String pageTitle {
    get {
      String t = siteBaseTitle.replaceAll('_', ' ')+ ' - Home';
      if(selectedCategory != null)t = siteBaseTitle.replaceAll('_', ' ')+' - '+ selectedCategory.split(':')[1].replaceAll('_',' ');
      if (viewingArticle) t = siteBaseTitle.replaceAll('_', ' ')+ ' - ' +theKad.title;
      if(pg=='dd'||pg=='ch'||pg=='sl'){
          t=Label.PP_Tab+' - FAQ';
      }
      return t;
    }
  }

  // note that siteName will be null when accessing page internally
  public String siteBaseTitle { 
    get {
        String s = siteName;
        if (isBlank(s)) s = 'Knowledge Base';
      return s;
    }    
  }

  public String selectedLanguageURL {
    get {
      return '/' +(multiLanguage ? selectedLanguage+'/' : '');
    }   
  }

  public String selectedCategoryLabel { 
    get { 
        return selectedCategory.replace(',', ', ').replace(':', ': ').replace('_', ' ');
    } 
  }
   
  public String selectedLanguage { 
    set;
    get { 
      // initialize if blank ('' or null) to ensure that this will always return a valid value
        if (isBlank(selectedLanguage)) selectedLanguage = pkb_SettingsController.DEFAULT_LANGUAGE;
        //if (isBlank(selectedLanguage)) selectedLanguage = 'Select Language'; 
        return selectedLanguage;
    } 
  }

  public void buildFeaturedKads() {
    Set<String> anums = new Set<String>();
    List<PKB_Featured__c> pkbfs = [
      select
        Id
        ,Article_Number__c
        ,LastModifiedDate
      from PKB_Featured__c
      where
        Is_Keyword_Article__c = false and
        PKB_Name__c = :siteName and
        (Expiration__c >= :Date.today() or
         Expiration__c = null)
      order by
        Order__c desc NULLS last,
        LastModifiedDate desc
    ];      

    for (PKB_Featured__c p : pkbfs) {
        anums.add(p.Article_Number__c);
    }
system.debug('\n\n[DEBUG-PKB CONTROLLER] buildFeaturedKads \n===='+anums+'=====\n');
    featuredKads = initFromListOfArticleNumbers(new List<String>(anums), selectedLanguage);
    system.debug('\n\n[DEBUG-PKB CONTROLLER] featuredKads \n===='+featuredKads+'=====\n');
  }

  /* ***** NARROW SEARCH DISPLAY CONDITIONALS ***** */
  
  /*public Boolean displayCategory1 { get { return (!isBlank(categoryGroup1) && !isBlank(rootCategory1)); } }
  public Boolean displayCategory2 { get { return (!isBlank(categoryGroup2) && !isBlank(rootCategory2)); } }
  public Boolean displayCategory3 { get { return (!isBlank(categoryGroup3) && !isBlank(rootCategory3)); } }
  public Boolean displayNarrow    { get { return (displayCategory1 || displayCategory2 || displayCategory3); } }
  
  
  /* ***** FEEDBACK AND CASE DEFERRAL CONDITIONALS AND PROCESSING ***** */
  
  /*public Boolean displayFeedbackYesNo   { get { return ApexPages.currentPage().getParameters().get(FEEDBACK_PARAM) == FEEDBACK_SHOW_YESNO; } }
  public Boolean displayFeedbackDialog  { get { return ApexPages.currentPage().getParameters().get(FEEDBACK_PARAM) == FEEDBACK_SHOW_DIALOG; } }
  public String sessionId { get; set; }
  public String feedbackComments { get; set; }
  public String createCaseErrorMsg { get; set; }

    
  public Boolean caseCreateError {
    set;
    get {
        if (caseCreateError == null) caseCreateError = false;
        return caseCreateError;
    }
  }

  public Boolean caseCreated { 
    set; 
    get {
        if (caseCreated == null) caseCreated = false;
        return caseCreated;
    }
  }

  public Boolean feedbackRecorded {
    set;
    get {
      if (feedbackRecorded == null) feedbackRecorded = false;
      return feedbackRecorded;
    }
  }

  public void deferred() {
    createDeferral(true);
    feedbackRecorded = true;    
  }

  public void recordArticleFeedback() {
    if (!isBlank(feedbackComments)) { 
        createDeferral(false);
      feedbackRecorded = true;
    }
  }

  public void createDeferral(Boolean isDeferred) {
    // validate that the feedback source option is a valid option
    String fs = (feedbackSourceOptions.contains(feedbackSource) ? feedbackSource : null);

    PKB_Article_Feedback_Deflection__c afd = new PKB_Article_Feedback_Deflection__c(
      Article_ID__c = theKad.id,
      Article_Number__c = theKad.articleNumber,
      Article_Title__c = theKad.title,
      Feedback_Source__c = fs,
      Comments__c = feedbackComments,
      Session_ID__c = sessionId,
      Deflection__c = isDeferred,
      Keyword_Searched__c = urlSearchQuery
    );
    insert afd;
  }

  public Set<String> feedbackSourceOptions { 
    set;
    get {
      if (feedbackSourceOptions == null) feedbackSourceOptions = getActivePicklistOptions('PKB_Article_Feedback_Deflection__c', 'Feedback_Source__c').keySet();
      return feedbackSourceOptions;
    }
  }

  /* ***** CONTACT US CONDITIONALS AND PROCESSING ***** */ 
  /*public Boolean displayContactUs   { get { return (ApexPages.currentPage().getParameters().get(CONTACT_US_PARAM) == CONTACT_US_VALUE); } }
  public ContactUsData theCud       { get; set; }
  public Case theCase               { get; set; }

  public PageReference contactUsDeferral() {
    feedbackComments = urlSearchQuery;
    feedbackSource = 'ContactUs';
    deferred();
    PageReference p = new PageReference(currentSiteUrl);
    p.setRedirect(true);
    return p;
  }
/*
  public void createCase() {
  
    createCaseErrorMsg = null;
    caseCreateError = false;

    // check for blanks
    if ( (isBlank(theCud.firstName) || isBlank(theCud.lastName) || isBlank(theCud.email) || isBlank(theCud.reqType)) ) {
        createCaseErrorMsg = System.Label.PKB2_All_Fields_Required;
      caseCreateError = true;
      return;
    }

    // check for valid email
    if (!isEmail(theCud.email)) {
      createCaseErrorMsg = System.Label.PKB2_Email_Invalid;
      caseCreateError = true;
      return;    
    } 
     
    String d = '';
    d += '\n' +System.Label.PKB2_First_Name+      ': ' +theCud.firstName;
    d += '\n' +System.Label.PKB2_Last_Name+       ': ' +theCud.lastName;
    d += '\n' +System.Label.PKB2_Email+           ': ' +theCud.email; 
    d += '\n' +System.Label.PKB2_Request_Type+    ': ' +theCud.reqType + '\n';
    d += '\n' +System.Label.PKB2_Search_Button+   ':\n' +urlSearchQuery;

    theCud.query = urlSearchQuery;
    String subject = '<no search provided>';
    if (!isBlank(urlSearchQuery)) subject = ( urlSearchQuery.length() < CASE_SUBJECT_LENGTH ? urlSearchQuery : urlSearchQuery.substring(0, CASE_SUBJECT_LENGTH) );
  
    // populate the case data
    theCase = new Case();
    theCase.Subject = subject;
    theCase.Type = theCud.reqType;
    theCase.Origin = defaultCaseOrigin;
    if (caseOrigins.containsKey('Web')) theCase.Origin = 'Web';
    theCase.Description = d;
    // fields for the mobile app 
    theCase.Customer_emoticon_value__c = theCud.User_Experience;
    theCase.pkbgeolocalization__Latitude__s = theCud.location_Latitude;
    theCase.pkbgeolocalization__Longitude__s = theCud.location_Longitude;

  
    insertRecords();
  }

  public void insertRecords() {
    createCaseErrorMsg = null;
    caseCreateError = false;

    // attempt to create the account and contact if configured to do so
    System.Savepoint sp = Database.setSavepoint();
    if (createAcctCon) {      
      try {
        Account a;
        Contact c;
        List<Contact> cons = [select Id, Account.Id from Contact where Email = :theCud.email and Email != null limit 2];

        if (!cons.isEmpty()) { 
            a = cons[0].Account;
            c = cons[0];
        } else {

            a = new Account(Name = theCud.lastName + ', ' +theCud.firstName);
            insert a;
            
            c = new Contact(
              AccountId = a.Id
              ,FirstName = theCud.firstName
              ,LastName = theCud.lastName
              ,Email = theCud.email
            );
            insert c;
        }

        theCase.AccountId = a.Id;
        theCase.ContactId = c.Id;
        //relate Contact to article feedback
        relateContactToFeedback(sessionId, c.Id);
        
      } catch (System.DmlException de) {
        setErrorAndRollback(sp);
        notifyAdminAndChangeSettings(de, null);

      } catch (Exception e) {
        setErrorAndRollback(sp);
        notifyAdminAndChangeSettings(null, e);
      } 
    }

    // try to insert the case regardless if the account or contact succeeded or not
    try {
        insert theCase;           
        caseCreated = true;
    } catch (DmlException de) {
      setErrorAndRollback(sp);
      notifyAdmin(de, null, System.Label.PKB2_Case_Error_Admin_Notification);
    } catch (Exception e) {
      setErrorAndRollback(sp);
      notifyAdmin(null, e, System.Label.PKB2_Case_Error_Admin_Notification);        
    }
  }


    public void relateContactToFeedback(String sessionId, Id contactId){

    system.debug('\n\n===== sessionId :'+sessionId+'  contactId :'+contactId);
        //Update Article Feedback with Contact
        List <PKB_Article_Feedback_Deflection__c>  articleFeedbacks;
        articleFeedbacks= [ select Id  
                            from PKB_Article_Feedback_Deflection__c
                            where Session_ID__c = :sessionId and Contact__c = null];

        if (!articleFeedbacks.isEmpty()) {
            for(PKB_Article_Feedback_Deflection__c articleFeedback: articleFeedbacks) {
                articleFeedback.Contact__c = contactId;
            }
        update articleFeedbacks;
        }
    }

  public void setErrorAndRollback(System.Savepoint sp) {
        createCaseErrorMsg = System.Label.PKB2_Case_Submit_Error;
        caseCreateError = true;
        Database.rollback(sp);      
  }

  public void notifyAdminAndChangeSettings(System.DmlException de, Exception e) {
    notifyAdmin(de, e, System.Label.PKB2_Error_Admin_Notification_Email);
    
    // flip the site settings to not create contact/account in future
    kbSettings.Create_Contact_and_Account__c = false;
    update kbSettings;
  }

  public void notifyAdmin(System.DmlException de, Exception e, String introMessage) {
    String body;
    Messaging.SingleEmailMessage msg;

    String debug;
    
    if (de != null) {
      debug = debugDmlException(de);
    } else if (e != null) {
      debug = debugException(e);
    }

    // send email only if siteAdmin isn't null
    if (siteAdmin != null) {
      msg = new Messaging.SingleEmailMessage();
      msg.setSubject('Public Knowledge Base 2 - Package Exception Notification');
      msg.setToAddresses(new List<String>{siteAdmin.Email});

      body = introMessage;
      body += '\n\nAPEX TRANSACTION DEBUG INFORMATION:\n' +debug;
      body += '\n\nSUBMITTED CASE INFORMATION:';
      body += '\n\nSubject: ' +theCase.Subject;
      body += '\n\nCase Type: ' +theCase.Type;
      body += '\n\nCase Origin: ' +theCase.Origin;
      body += '\n\nDescription: ' +theCase.Description;
      body += '\n\n';
      msg.setPlainTextBody(body);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
    }
  }

  public static String debugDmlException(System.DmlException de) {
    String s = '';
      s += 'Cause: ' +de.getCause();
      s += '\nLineNumber: ' +de.getLineNumber();
      s += '\nMessage: ' +de.getMessage();
      s += '\nStackTraceString: ' +de.getStackTraceString();
      s += '\nTypeName: ' +de.getTypeName();
      s += '\nDmlFieldNames: ' +de.getDmlFieldNames(0);
      s += '\nDmlFields: ' +de.getDmlFields(0);
      s += '\nDmlIndex: ' +de.getDmlIndex(0);
      s += '\nDmlMessage: ' +de.getDmlMessage(0);
      s += '\nDmlStatusCode: ' +de.getDmlStatusCode(0);
      s += '\nDmlType: ' + de.getDmlType(0);
      s += '\nNumDml: ' +de.getNumDml();
    return s;
  }
*/
  /*public static String debugException(Exception e) {
    String s = '';
    s += 'Cause: ' +e.getCause();
    s += '\nLineNumber: ' +e.getLineNumber();
    s += '\nMessage: ' +e.getMessage();
    s += '\nStackTraceString: ' +e.getStackTraceString();
    s += '\nTypeName: ' +e.getTypeName();
    return s;
  }

  public String defaultCaseOrigin { 
    set;
    get {
        if (defaultCaseOrigin == null) defaultCaseOrigin = getPicklistDefault('Case', 'Origin');
        return defaultCaseOrigin;
    }
  }
  
  public Map<String,String> caseOrigins {
    set;
    get {
        if (caseOrigins == null) caseOrigins = getActivePicklistOptions('Case', 'Origin');
      return caseOrigins;
    }
  }
/*
  public List<SelectOption> caseTypeOptions {
    set;
    get {
        if (caseTypeOptions == null) {
            List<SelectOption> opts = new List<SelectOption>();
        Map<String,String> optionsMap = getActivePicklistOptions('Case', 'Type');
            for (String s : optionsMap.keySet()) {
          opts.add(new SelectOption(s, optionsMap.get(s)));                 
            }
        caseTypeOptions = new List<SelectOption>();
        caseTypeOptions.add(new SelectOption('', '--' +System.Label.PKB2_None+ '--'));
        caseTypeOptions.addAll(sortOptionList(opts));
        }
        return caseTypeOptions;
    }
  }
*/
  /* ***** SITE-SPECIFIC VALUES THAT CAN BE OVERRIDDEN IF NOT VIEWING IN A SITE ***** */

  /*public String currentSiteUrl { 
    set;
    get {
      if (currentSiteUrl == null) {
        currentSiteUrl = Site.getCurrentSiteUrl(); 
        if (!isSite) {
            if (Site.getTemplate().getUrl().endsWith('pkb_Template_fb'))
               currentSiteUrl = Page.pkb_Home_fb.getUrl();
            else
               currentSiteUrl = Page.Kb_Home.getUrl();
        }
      }
      return currentSiteUrl;
    }
  }

  public String siteName { get { return DEFAULT_SITE_NAME; } }
 
  /* ***** CUSTOM SETTINGS (note that defaults are retrieved from the pkb_SettingsController) ***** */

  /*private PKB__c kbSettings { get { return PKB__c.getValues(siteName); }  }
  public Boolean showArticleSummary { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_DISPLAY_SUMMARY : kbSettings.Display_Article_Summary__c); } }
  public Integer popularArticles    { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_POPULAR_SIZE : Integer.valueOf(kbSettings.Popular_Articles_Size__c)); } } 
  public Integer relatedArticles    { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_RELATED_SIZE : Integer.valueOf(kbSettings.Related_Articles_Size__c)); } }
  public Integer articlesPerPage    { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_RESULTS_SIZE : Integer.valueOf(kbSettings.Results_Page_Size__c)); } }
  public Boolean multiLanguage      { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_MULTI_LANGUAGE : kbSettings.Multi_Language_Enabled__c); } }
  public Boolean createAcctCon      { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_CREATE_ACCOUNT_CONTACT : kbSettings.Create_Contact_and_Account__c); } }
  public String availableLanguages  { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_LANGUAGE : kbSettings.Selected_Languages__c); } } 
  public String categoryGroup1      { get { return (kbSettings == null ? null : kbSettings.Category_Group_1__c); } } 
  public String categoryGroup2      { get { return (kbSettings == null ? null : kbSettings.Category_Group_2__c); } } 
  public String categoryGroup3      { get { return (kbSettings == null ? null : kbSettings.Category_Group_3__c); } } 
  public String categoryLabel1      { get { return (kbSettings == null ? null : System.Label.PKB2_Category_Group_Label_1); } }
  public String categoryLabel2      { get { return (kbSettings == null ? null : System.Label.PKB2_Category_Group_Label_2); } }
  public String categoryLabel3      { get { return (kbSettings == null ? null : System.Label.PKB2_Category_Group_Label_3); } }
  public String rootCategory1       { get { return (kbSettings == null ? null : kbSettings.Root_Category_1__c); } }
  public String rootCategory2       { get { return (kbSettings == null ? null : kbSettings.Root_Category_2__c); } }
  public String rootCategory3       { get { return (kbSettings == null ? null : kbSettings.Root_Category_3__c); } }
  public String fbAppId             { get { return (kbSettings == null ? null : kbSettings.FBAppId__c); } }

  /* ***** SEARCH RESULTS PAGINATION NAVIGATION ***** */

  /*public Integer currPage { 
    set;
    get {
        if (currPage == null) { 
            currPage = 1;
            String p = ApexPages.currentPage().getParameters().get(PAGE_NUM_PARAM);
        if (!isBlank(p)) currPage = Integer.valueOf(p);
        }
      return currPage;
    }
  }
  public void nextPage() {
    currPage++;
  }
  public void prevPage() {
    currPage--;     
  }

  /* ***** RETRIEVE LANGUAGE LABELS AND VALUES AND CONSTRUCT SELECT OPTIONS ***** */

  /*public Set<String> availableLanguagesSet { 
    set;
    get {
      if (availableLanguagesSet == null) {
        availableLanguagesSet = new Set<String>();
        List<String> langs = ( isBlank(availableLanguages) ? new List<String>{pkb_SettingsController.DEFAULT_LANGUAGE} : availableLanguages.split(';') );
        for (String s : langs)
          availableLanguagesSet.add(s);
      }
      return availableLanguagesSet;
    }
  }

  public List<SelectOption> languageOptions { 
    set;
    get { 
      if (languageOptions == null) {
        languageOptions = new List<SelectOption>();
        for (SelectOption so : allLanguageOptions) {
            if (availableLanguagesSet.contains(so.getValue())) {
                languageOptions.add(so);
            }
        }       
        languageOptions = sortOptionList(languageOptions);
      }
      if(pg=='ch' ||pg=='dd' ||pg=='sl'){
          List<SelectOption> finalList= new List<SelectOption>();
        //finalList.add(new SelectOption('Select Language', 'Select Language'));
        //Start code for showing language option as choosen on Language field on User record
        string UserPreferredLanguage=[select language__c from User where id=:UserInfo.getUserId()].language__c;
        if(UserPreferredLanguage!=null){
        for(SelectOption so : languageOptions)
            {
            if(UserPreferredLanguage.contains(so.getLabel()))
                    {
                        finalList.add(so);
                    }
            }
            }
            else 
            finalList.addAll(languageOptions);
        //End code for showing language option as choosen on Language field on User record      
        // 
         return finalList; 
      
      }
      else{
         List<SelectOption> finalList= new List<SelectOption>();
         //finalList.add(new SelectOption('Select Language', 'Select Language'));
         finalList.addAll(languageOptions);
         return finalList;
      }
  
    } 
  }
 
  public static List<SelectOption> allLanguageOptions { 
    set;
    get {
      if (allLanguageOptions == null) {
        /*
        Map<String,String> optionsMap = getActivePicklistOptions('User', 'LanguageLocaleKey');
        allLanguageOptions = new List<SelectOption>();
        for (String s : optionsMap.keySet()) {
          allLanguageOptions.add(new SelectOption(s, optionsMap.get(s)));
        }
        */
        /*if(pg=='' ||pg==null){
            allLanguageOptions = new List<SelectOption>();
            allLanguageOptions.add(new SelectOption('zh_CN','中文（简体）'));
            allLanguageOptions.add(new SelectOption('en_US','English'));
            allLanguageOptions.add(new SelectOption('da','Dansk'));
            allLanguageOptions.add(new SelectOption('nl_NL','Nederlands'));
            allLanguageOptions.add(new SelectOption('fi','Suomi'));
            allLanguageOptions.add(new SelectOption('fr','Français'));
            allLanguageOptions.add(new SelectOption('de','Deutsch'));
            allLanguageOptions.add(new SelectOption('it','Italiano'));
            allLanguageOptions.add(new SelectOption('no','Norsk'));
            allLanguageOptions.add(new SelectOption('sv','Svenska'));
            allLanguageOptions = sortOptionList(allLanguageOptions);
       }else{
           
        
       
       
       
       
           allLanguageOptions = new List<SelectOption>();
        
        allLanguageOptions.add(new SelectOption('cs','Česky'));
        allLanguageOptions.add(new SelectOption('da','Dansk'));
        allLanguageOptions.add(new SelectOption('de','Deutsch'));
        allLanguageOptions.add(new SelectOption('en_US','English (US)'));
        allLanguageOptions.add(new SelectOption('en_AU','English (AUS)'));
        allLanguageOptions.add(new SelectOption('en_GB','English'));
        allLanguageOptions.add(new SelectOption('es','Español'));
        allLanguageOptions.add(new SelectOption('es_MX','Español ( México )'));
        allLanguageOptions.add(new SelectOption('fr','Français'));
        allLanguageOptions.add(new SelectOption('fr_CA','Français ( Canada )'));
        allLanguageOptions.add(new SelectOption('in','Indonesian'));
        allLanguageOptions.add(new SelectOption('it','Italiano'));
        allLanguageOptions.add(new SelectOption('hu','Magyar'));
        allLanguageOptions.add(new SelectOption('nl_NL','Nederlands'));
        allLanguageOptions.add(new SelectOption('no','Norsk'));
        allLanguageOptions.add(new SelectOption('pl','Polski'));
        allLanguageOptions.add(new SelectOption('pt_PT','Português (PT)'));
        allLanguageOptions.add(new SelectOption('pt_BR','Português (BR)'));
        allLanguageOptions.add(new SelectOption('ro','Română'));
        allLanguageOptions.add(new SelectOption('fi','Suomi'));
        allLanguageOptions.add(new SelectOption('sv','Svenska'));
        allLanguageOptions.add(new SelectOption('tr','Türkçe'));
        allLanguageOptions.add(new SelectOption('ru','русский'));
        allLanguageOptions.add(new SelectOption('el','Ελληνική'));
        allLanguageOptions.add(new SelectOption('zh_CN','中文（简体）'));
        allLanguageOptions.add(new SelectOption('zh_TW','中國（繁體）'));
        allLanguageOptions.add(new SelectOption('ja','日本語'));
        //below line commented by Anjali for SSE-4563 as Arabic language is no longer in use.
        //allLanguageOptions.add(new SelectOption('ar','العربية'));
        allLanguageOptions = sortOptionList(allLanguageOptions);
       
       
       }
      }
      return allLanguageOptions;
    }
  }


  /* ***** DYNAMIC RETRIEVAL OF ARTICLE TYPES VIA DESCRIBES AND OBJECT ID PREFIXES ***** */
  
 /* public static Set<String> kavNames { 
    set;
    get {
        if (kavNames == null) {
            kavNames = new Set<String>();
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        for (String s : gd.keySet()) {
          if (s.contains(KAV_EXTENSION)) {
            kavNames.add(s);
          }
        }
        }
      return kavNames;
    }
  }

  public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap {
    get {
        if (kavObjPrefixMap == null) {
            kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            sor = gd.get(s).getDescribe();
            kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
        }
        }
      return kavObjPrefixMap;
    }
  }

  public static Schema.DescribeSObjectResult getKAVDescribeById(String i) {
    if (isBlank(i) || i.length() < 15) return null;
    return kavObjPrefixMap.get(i.substring(0,3).toLowerCase());
  }


  /* ***** CONTACT US FORM WRAPPER CLASS ***** */
  /*public class ContactUsData {
    public String firstName { get; set; }
    public String lastName  { get; set; }
    public String email     { get; set; }
    public String reqType   { get; set; }
    public String query     { get; set; }
    /** fields added to covert new fields on Mobile app**/
    /*public Decimal  location_Latitude   { get; set; }
    public Decimal  location_Longitude { get; set; }
    public String User_Experience       { get; set; }
    
    
    public ContactUsData() { }
  }


  /* ***** KNOWLEDGE ARTICLE DATA (KAD) WRAPPER CLASS ***** */

  /* 
    This wrapper class mimics the quasi article/article version object that is given to the loop executed by the 
    VF tag knowledge:articleList. It implements all of the fields of that object plus articleNumber, and also exposes a handle to the
    underlying KAV object that was used to populate most of the fields
    
    A single instance can be instantiated by passing the constructor a single ID of a KnowledgeArticle record (this constructor uses a soql query to retrieve the article) 
    or an already-queried KAV record. 
    
    Multiple instances can be instantiated from a list of KnowledgeArticle or KAV IDs by using the KAD static initializers (initFromListOfArticleNumbers, etc).    
  */
  /*public class KnowledgeArticleData { 
    public String id                     { get; set; } // note this is the ID of the KnowledgeArticle record, not the ID of the KAV record
    public String title                  { get; set; }
    public String summary                { get; set; }
    public String urlName                { get; set; }
    public String articleTypeName        { get; set; }
    public String articleTypeLabel       { get; set; }      
    public DateTime lastModifiedDate     { get; set; }
    public DateTime firstPublishedDate   { get; set; }
    public DateTime lastPublishedDate    { get; set; }
    public String articleNumber          { get; set; }
    public KnowledgeArticleVersion theAV { get; set; }  

    // ctor for empty KAD
    public KnowledgeArticleData() { }
        
    // ctor that takes an already constructed-KAV record
    public KnowledgeArticleData(KnowledgeArticleVersion kav) {
      init(kav);
    }

    // ctore that takes the ID of a KnowledgeArticle record and queries the KAV record from it
    public KnowledgeArticleData(Id i, String lang) {
      String q = '';
      String pub = Kb_Controller.DEFAULT_PUBLISH_STATUS;
      q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
      q += ' where PublishStatus = :pub and Language = :lang and KnowledgeArticleId = :i limit 1';
      KnowledgeArticleVersion kav = (KnowledgeArticleVersion)Database.query(q);
      init(kav);
    }

    public void init(KnowledgeArticleVersion kav) {
        this.theAV = kav;
    
      id = this.theAV.KnowledgeArticleId;
      title = this.theAV.Title;
      summary = this.theAV.Summary;
      urlName = this.theAV.UrlName;
      articleTypeName = getKAVDescribeById(id).getLocalName();
      articleTypeLabel = getKAVDescribeById(id).getLabel();
      lastModifiedDate = this.theAV.LastModifiedDate;
      firstPublishedDate = this.theAV.FirstPublishedDate;
      lastPublishedDate = this.theAV.LastPublishedDate;     
      articleNumber = this.theAV.ArticleNumber;
    }
  }

  public static Set<String> excludedSoslWords {
    get { 
        if (excludedSoslWords == null) {
            excludedSoslWords = new Set<String>();
            /*{'and','or','the','a'};*/
   /*     }
        return excludedSoslWords;
    }
    private set;
  }

  // these fields must be queried when instantiating a KAD wrapper object, so this set is
  // used in the sosl and soql queries to ensure that all queries get the right fields
  public static Set<String> kavFields { 
    get {
        if (kavFields == null) {
            kavFields = new Set<String>{
          'Id'
          ,'Title'
          ,'Summary'
          ,'UrlName'
          ,'ArticleNumber'
          ,'LastModifiedDate'
          ,'FirstPublishedDate'     
          ,'LastPublishedDate'
          ,'Language'
          ,'PublishStatus'
          ,'KnowledgeArticleId'
            };
        }
      return kavFields;
    }
    private set;
  }


  /* ***** KNOWLEDGE ARTICLE DATA CLASS STATIC INITIALIZERS/FACTORIES ***** */
  
  /*public static List<KnowledgeArticleData> initFromListOfArticleNumbers(List<String> anums, String lang) {
    List<KnowledgeArticleData> kads = new List<KnowledgeArticleData>();
    
    if (anums == null || anums.isEmpty()) return kads;

    String q = '';
    q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
    q += ' where PublishStatus = \'' +Kb_Controller.DEFAULT_PUBLISH_STATUS+ '\' and Language = \'' +lang+ '\' and ArticleNumber in :anums order by LastPublishedDate desc';

    system.debug('\n\n[DEBUG-PKB CONTROLLER] initFromListOfArticleNumbers query\n===='+q+'=====\n');
    List<KnowledgeArticleVersion> kavs = (List<KnowledgeArticleVersion>)Database.query(q);

    for (KnowledgeArticleVersion kav : kavs) {
      kads.add(new KnowledgeArticleData(kav));
    }


    system.debug('\n\n[DEBUG-PKB CONTROLLER] initFromListOfArticleNumbers \n===='+kads+'=====\n');    
    return kads;
  }  
  
  // instantiates and returns a list of the KAD wrapper class objects from a list of KnowledgeArticle IDs and the specified language.
  public static List<KnowledgeArticleData> initFromListOfArticleIds(List<String> aids, String lang) {
    List<KnowledgeArticleData> kads = new List<KnowledgeArticleData>();
    
    if (aids == null || aids.isEmpty()) return kads;

    String q = '';
    q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
    q += ' where PublishStatus = \'' +Kb_Controller.DEFAULT_PUBLISH_STATUS+ '\' and Language = \'' +lang+ '\' and KnowledgeArticleId in :aids order by LastPublishedDate desc';

    List<KnowledgeArticleVersion> kavs = (List<KnowledgeArticleVersion>)Database.query(q);
    return initFromListOfKAVs(kavs);
  }

  // instantiates and returns a list of the KAD wrapper class objects from a list of KAV IDs and the specified language.
  public static List<KnowledgeArticleData> initFromListOfKAVIds(List<String> kids, String lang) {
    List<KnowledgeArticleData> kads = new List<KnowledgeArticleData>();

    if (kids == null || kids.isEmpty()) return kads;
  
    String q = '';
    q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
    q += ' where PublishStatus = \'' +Kb_Controller.DEFAULT_PUBLISH_STATUS+ '\' and Language = \'' +lang+ '\' and Id in :kids order by LastPublishedDate desc';

    List<KnowledgeArticleVersion> kavs = (List<KnowledgeArticleVersion>)Database.query(q);
    return initFromListOfKAVs(kavs);
  }
  
  // instantiates a list of KADs from already-queried KAVs
  public static List<KnowledgeArticleData> initFromListOfKAVs(List<KnowledgeArticleVersion> kavs) {
    List<KnowledgeArticleData> kads = new List<KnowledgeArticleData>();

    if (kavs == null || kavs.isEmpty()) return kads;
    
    for (KnowledgeArticleVersion kav : kavs) {
      kads.add(new KnowledgeArticleData(kav));
    }
    return kads;
  }

  /* ***** GENERAL UTIL METHODS ***** */

  // returns true if string is null or empty
  /*public static Boolean isBlank(String s) {
    return ( s == null || s == '');
  }

  // joins elements in the passed list of strings by the passed string c
  // c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
  public static String join(List<String> strings, String c) {
    if (strings == null || strings.isEmpty()) return null;
    
    String sep = (isBlank(c) ? ',' : c);
    Integer i, size;
    String s = strings[0];
 
    size = strings.size();
    for (i = 1; i < size; i++) {
      s += (sep + strings[i]);      
    }
    return s;    
  }

  // version of join method that takes a set of strings
  public static String join(Set<String> strings, String c) {
    return join(new List<String>(strings), c);
  }
  
  
  public static String getPicklistDefault(String so, String field) {
    String defVal = null;
    for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
        if (ple.isDefaultValue()) { 
            defVal = ple.getValue();
            break;
        }
    }
    return defVal;
  }
  
  public static Map<String,String> getActivePicklistOptions(String so, String field) {
    Map<String,String> options = new Map<String,String>();

    for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
      options.put(ple.getValue(), ple.getLabel());          
    }
    return options;    
  }

  public static List<Schema.PicklistEntry> getActivePicklistEntries(String so, String field) {
    Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();   
    List<Schema.PicklistEntry> ples = new List<Schema.PicklistEntry>();    
    
    // return empty list if object name was not found in the schema
    if (!gd.containsKey(so)) return ples;

    Schema.DescribeSObjectResult sor = gd.get(so).getDescribe();
    Map<String,Schema.SObjectField> sofs = sor.fields.getMap();
    
    // return empty list if field name was not found in the object's field list
    if (!sofs.containsKey(field)) return ples;

    Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();

    // return empty list if the field type is not picklist
    if (dfr.getType() != Schema.DisplayType.Picklist) return ples;

    for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
      if (ple.isActive()) {
        ples.add(ple);        
      }
    }
    return ples;        
  }
  /*
  public static Boolean isEmail(String s) {
    if (isBlank(s)) return false;

    String p = '\\w+([-+.\']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*';
    Pattern pat = Pattern.compile(p);
    Matcher mat = pat.matcher(s);
    return mat.matches();
  }
*/
 /* public User siteAdmin { 
    set;
    get {
        if (siteAdmin == null) siteAdmin = getSiteAdmin();
        return siteAdmin;
    }
  }

  public static User getSiteAdmin() {
    List<Site> sites = [
      select
        Id
        ,Name
        ,Admin.Id
        ,Admin.FirstName
        ,Admin.LastName
        ,Admin.Name
        ,Admin.Email
      from Site
      where 
        Name = :DEFAULT_SITE_NAME
    ];
        
    // send the admin back if it's a site, send null back if not a site
    User u = (!sites.isEmpty() && sites[0].Admin != null ? sites[0].Admin : null);
    return u;
  }

  /* 
    Retrieved from http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html on 22 July 2011
    Author: Jason Hartfield
  
    This is a simple quicksort algorithm to sort a SelectOption list (dropdown) 
    by label alphabetically.
  */
   /* public static List<SelectOption> sortOptionList(List<SelectOption> listToSort) {
        if (listToSort == null || listToSort.size() <= 1)
            return listToSort;
            
        List<SelectOption> less = new List<SelectOption>();
        List<SelectOption> greater = new List<SelectOption>();
        integer pivot = listToSort.size() / 2;
          
        // save the pivot and remove it from the list
        SelectOption pivotValue = listToSort[pivot];
        listToSort.remove(pivot);
        
        for (SelectOption x : listToSort) {
        if (x.getLabel() <= pivotValue.getLabel()) {
          less.add(x);
        } else if (x.getLabel() > pivotValue.getLabel()) {
            greater.add(x);
        }
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(sortOptionList(less));
        returnList.add(pivotValue);
        returnList.addAll(sortOptionList(greater));
        return returnList; 
    } 
    //populate cate level list used in menu bar and categroy detail pages
   private void populateCatList(){
       
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');        
        List<DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objType);        
        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');       
        pair1.setDataCategoryGroupName(DEFAULT_CATEGORY_GROUP);
        DataCategoryGroupSobjectTypePair[] pairs = new DataCategoryGroupSobjectTypePair[] {pair1};        
        DescribeDataCategoryGroupStructureResult[] results =
        Schema.describeDataCategoryGroupStructures(pairs,false);
        for(DataCategory cc : results[0].getTopCategories()[0].getChildCategories()){           
            if(categoryGP != null){
                if(cc.getName()=='Client_Help'){
                    prepareCatList(cc);
                }else if(cc.getName()=='Candidate_Help'){
                    prepareCatList(cc);
                }
            }
        }
    }
    //helper method to populate category list
    private void prepareCatList(DataCategory cc){
        String c = ApexPages.currentPage().getParameters().get(CATEGORY_PARAM);
        //get ctegory name from query string
        if(c != null && c.trim() != ''){
            c = c.split(':')[1];
        }else{
            c = '';
        }
        system.debug('**c**='+c);
        selectedClientinfo=c;
        system.debug('**selectedClientinfo**='+selectedClientinfo);
        system.debug('*cc**='+cc.getChildCategories());
        CatLevel1 cl1; 
        //for(DataCategory cc1 : cc.getChildCategories()){
            //system.debug('*cc1**='+cc1.getLabel());
            List<CatLevel2> catLevel2List = new List<CatLevel2>();
            for(DataCategory cc2 : cc.getChildCategories()){
                //Remove this condition in June when SHL Online will be visible
                //if(cc2.getName() != 'SHL_Online'){    
                    
                    system.debug('*cc2**='+cc2.getLabel());
                    List<CatLevel3> catLevel3List = new List<CatLevel3>();
                    Boolean catDisplay3=false;
                    if(c==cc2.getName()){
                        showCatBarId = cc2.getName();
                        catDisplay3=true;
                    }
                    for(DataCategory cc3 : cc2.getChildCategories()){
                        if(c != null){
                            if(c==cc3.getName()){
                                catDisplay3=true;
                                showCatBarId = cc2.getName();
                            }  
                            if(c==cc3.getName()){
                                selectedSubCategory = cc3.getLabel();
                            }  
                        }
                        system.debug('*cc3**='+cc3.getLabel());
                        List<CatLevel4> catLevel4List = new List<CatLevel4>();
                        Boolean catDisplay4=false;
                        for(DataCategory cc4 : cc3.getChildCategories()){
                            system.debug('*cc4**='+cc4.getLabel());
                            if(c != null){
                                if(c==cc4.getName() || c==cc4.getName()){
                                    catDisplay3=true;
                                    selectedSubCategory = cc4.getLabel();
                                    catDisplay4 = true;
                                }
                                /*if(c.contains(cc4.getName())){
                                    selectedSubCategory = cc4.getLabel();
                                } */
                            //}
                            //if(!showCatBar){
                              //  showCatBar = showCat(c,cc4.getName());
                            //}
                    /*        catLevel4List.add(new CatLevel4(cc4.getName(),cc4.getLabel()));
                        }
                        if(selectedLanguage=='de' && cc3.getName()=='Accessibility'){
                            catLevel3List.add(new CatLevel3(cc3.getName(),cc3.getLabel().replace(' ','<br/>'),catLevel4List,catDisplay4));
                        }else{
                            catLevel3List.add(new CatLevel3(cc3.getName(),cc3.getLabel(),catLevel4List,catDisplay4));   
                        }
                         
                        //if(!showCatBar){
                          //  showCatBar = showCat(c,cc3.getName());
                        //}
                    }
                    catLevel2List.add(new CatLevel2(cc2.getName(),cc2.getLabel(),catLevel3List,catDisplay3));
                //}
            }
            catLevelList.add(new CatLevel1(cc.getName(),cc.getLabel(),catLevel2List));
            system.debug('**catLevelList.size()**='+catLevelList.size());
            system.debug('**catLevelList**='+catLevelList);
        //}
    }
    //set which category level will be visible
   /* private Boolean showCat(String c,String cat){
        Boolean showC = false;
        if(c != null){
            if(c.contains(cat)){
                showC = true;
            }                   
        }
        return showC;
    }*/
    //wrapper class to handle category level
    /*public class CatLevel1{
        public string apiName{get;set;}
        public string catLabel{get;set;}
        public List<CatLevel2> childCategory{get;set;}
        public catLevel1(string n, string l, List<CatLevel2> cat2){
            apiname = DEFAULT_CATEGORY_GROUP+':'+n;
            catLabel = l;
            childCategory = cat2;
        }
    }
    public class CatLevel2{
        public string apiName{get;set;}
        public string catLabel{get;set;}
        public List<CatLevel3> childCategory{get;set;}
        public Boolean showCatBar{get;set;}
        public catLevel2(string n, string l, List<CatLevel3> cat3,Boolean showCat){
            apiname = DEFAULT_CATEGORY_GROUP+':'+n;
            catLabel = l;
            childCategory = cat3;
            showCatBar = showCat;
        }
    }
    public class CatLevel3{
        public string apiName{get;set;}
        public string catLabel{get;set;}
        public List<CatLevel4> childCategory{get;set;}
        public Boolean showCatBar{get;set;}
        public catLevel3(string n, string l, List<CatLevel4> cat4,Boolean showCat){
            apiname = DEFAULT_CATEGORY_GROUP+':'+n;
            catLabel = l;
            childCategory = cat4;
            showCatBar = showCat;
        }
    }
    public class CatLevel4{
        public string apiName{get;set;}
        public string catLabel{get;set;}
        public catLevel4(string n, string l){
            apiname = DEFAULT_CATEGORY_GROUP+':'+n;
            catLabel = l;
            
        }
    }
    
    //populate cate level list used in footer component
    public void  populateAllCatList(){
        //catLevelList = new List<CatLevel1> ();
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');
        
        List<DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        
        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');
        //specify which category group you want to make visible
        /*if(categoryGP != null){
            if(categoryGP.equalsIgnoreCase('cn')){
                pair1.setDataCategoryGroupName(describeCategoryResult[0].getName());
            }else{
                pair1.setDataCategoryGroupName(describeCategoryResult[1].getName());
            }
        }else{
            pair1.setDataCategoryGroupName(describeCategoryResult[1].getName());
        }*/
     /*   pair1.setDataCategoryGroupName(DEFAULT_CATEGORY_GROUP);
        DataCategoryGroupSobjectTypePair[] pairs = new DataCategoryGroupSobjectTypePair[] {pair1};
        
        DescribeDataCategoryGroupStructureResult[] results =
                    Schema.describeDataCategoryGroupStructures(pairs,false);
        System.debug('***='+results[0].getLabel());
        for(DataCategory cc : results[0].getTopCategories()[0].getChildCategories()){
            System.debug('**cc.getName()**='+cc.getName());
            System.debug('**categoryGP**='+categoryGP);
            
            prepareAllCatList(cc);
            //REMOVE THIS ONCE THE FOOTER IS FINALIZED prepareAllCatListOld
            //prepareAllCatListOld(cc);
        }
    }
    //helper method to populate category list
    private void prepareAllCatList(DataCategory cc){
        //system.debug('*cc**='+cc.getLabel());
        CatLevel1 cl1;
        Integer i = 0;
        //for(DataCategory cc1 : cc.getChildCategories()){
            //system.debug('*cc1**='+cc1.getLabel());
            List<CatLevel2> catLevel2List = new List<CatLevel2>();
            List<CatLevel2> catLevel2ListCS = new List<CatLevel2>();
            for(DataCategory cc2 : cc.getChildCategories()){
                //if(cc2.getName() != 'SHL_Online'){    
                    system.debug('*cc2**='+cc2.getLabel()+'***'+i);
                    List<CatLevel3> catLevel3List = new List<CatLevel3>();
                    for(DataCategory cc3 : cc2.getChildCategories()){
                        
                        system.debug('*cc3**='+cc3.getLabel());
                        List<CatLevel4> catLevel4List = new List<CatLevel4>();
                        for(DataCategory cc4 : cc3.getChildCategories()){
                            //system.debug('*cc4**='+cc4.getLabel());
                            catLevel4List.add(new CatLevel4(cc4.getName(),cc4.getLabel()));
                            
                        }
                        catLevel3List.add(new CatLevel3(cc3.getName(),cc3.getLabel(),catLevel4List,false)); 
                        
                    }
                    //All the sub category under "Client Help" category is divided into two parts for footer
                    if(cc.getName()=='Client_Help' && i>1){
                        catLevel2ListCS.add(new CatLevel2(cc2.getName(),cc2.getLabel(),catLevel3List,false));
                    }else{
                        catLevel2List.add(new CatLevel2(cc2.getName(),cc2.getLabel(),catLevel3List,false));
                    }
                    i++;
                //}
            }
            //client help category is divided into two parts as "Client System Help" and "Cleint Services" to show in footer
            if(cc.getName()=='Client_Help'){
                catAllLevelList.add(new CatLevel1(cc.getName(),System.Label.Kb_P2_Client_System_Help,catLevel2List));
                catAllLevelList.add(new CatLevel1(cc.getName(),System.Label.Kb_P2_Client_Services,catLevel2ListCS));
            }else{
                //Online Cusotmer Service should not be visible in footer
                if(cc.getName() !='Online_Customer_Service'){
                    if(cc.getName() =='For_Internal_Guidance'){
                        //add for internal guidance category as sub category of candidate help only for footer
                        catAllLevelList[2].childCategory.add(new CatLevel2(cc.getName(),cc.getLabel(),null,false));
                    }else{
                        catAllLevelList.add(new CatLevel1(cc.getName(),cc.getLabel(),catLevel2List));
                    }
                }
            }
        //}
        
    }
    //REMOVE THIS METHOD ONCE THE FOOTER IS FINALIZED
   /* private void prepareAllCatListOld(DataCategory cc){
        if(cc.getName() != 'Client_Help'){
            //system.debug('*cc**='+cc.getLabel());
            CatLevel1 cl1; 
            //system.debug('*cc1**='+cc1.getLabel());
            List<CatLevel2> catLevel2List = new List<CatLevel2>();
            for(DataCategory cc2 : cc.getChildCategories()){
                //system.debug('*cc2**='+cc2.getLabel());
                List<CatLevel3> catLevel3List = new List<CatLevel3>();
                for(DataCategory cc3 : cc2.getChildCategories()){
                    
                    //system.debug('*cc3**='+cc3.getLabel());
                    List<CatLevel4> catLevel4List = new List<CatLevel4>();
                    for(DataCategory cc4 : cc3.getChildCategories()){
                        //system.debug('*cc4**='+cc4.getLabel());
                        catLevel4List.add(new CatLevel4(cc4.getName(),cc4.getLabel()));
                        
                    }
                    catLevel3List.add(new CatLevel3(cc3.getName(),cc3.getLabel(),catLevel4List,false)); 
                    
                }
                catLevel2List.add(new CatLevel2(cc2.getName(),cc2.getLabel(),catLevel3List,false));
            }
            catAllLevelList_Old.add(new CatLevel1(cc.getName(),cc.getLabel(),catLevel2List));
        }
    }*/
    //Property and method to switch search and contact us form on contactus page.
  /*  public Boolean showContactUsForm {get;set;}
    public PageReference showContactUsForm()
    {
        showContactUsForm = true;
        return null;
    }


 @RemoteAction
     public static List<topic> searchMovie(String searchTerm , string lan, string pagename , string cg) {
        System.debug('page name is : '+pagename);
        //public string datcategoryselected ;
        
         
     set<id> ids= new set<id>();
    system.debug(lan + 'is langaue that is selected');
    if (pagename=='Client' || cg=='client')
   { list<knowledgearticleversion> kb_client = [SELECT Id , ArticleType  FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = :lan  and ArticleType ='FAQ__kav' WITH DATA CATEGORY SHL_Support__c  BELOW Client_Help__c ];

for (knowledgearticleversion k : kb_client )
{ids.add(k.id);
}
}
else
  {  list<knowledgearticleversion> kb_candiddate = [SELECT Id , ArticleType  FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = :lan  and ArticleType ='FAQ__kav' WITH DATA CATEGORY SHL_Support__c  BELOW Candidate_Help__c ];
 for (knowledgearticleversion k : kb_candiddate )
{ids.add(k.id);
}
    }





         List<Topic> topics = Database.query('SELECT Id,Name FROM Topic where Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' and  id in ( SELECT TopicId FROM TopicAssignment WHERE  EntityId in :ids) ' ); 
        //list<KnowledgeArticleVersion> orderelistofarticles = new list<KnowledgeArticleVersion>();
      
        return topics;
    }
      @RemoteAction
      public static List<URL_Redirects__c> getRedirect(){              
            RedirectList = [Select Redirect_From__c,Redirect_To__c from URL_Redirects__c];
            System.debug('Redirect Size : '+RedirectList.size());
            System.debug('Redirect To: '+RedirectList[0].Redirect_To__c);
            return RedirectList;
       }*/
  }
}