global class MilestoneTrigger_Manager{
        
        // Milestone Validation on deletion. Cannot be deleted if Financial period is closed or if a user is not a Project Manager or Cordinator
        public static void MilestoneValidationChecks(List<Milestone__c> MilestoneOldList){        
            Set<Id> milestonePeriodIdsSet = new Set<Id>();
            Set<Id> projectIdsSet = new Set<Id>();
            for(Integer i=0;i<MilestoneOldList.size();i++){
                milestonePeriodIdsSet.add(MilestoneOldList[i].Milestone_Period__c);
                projectIdsSet.add(MilestoneOldList[i].Project__c);
            }
            //Adding below code As per CRI-670 : Project manager can delete unsigned milestones. (Already there is one validation which restrict deletion of singed milestone so it means only project manager can delete milestones.)
            Map<Id,ProjectObject__c> projectMap = new Map<Id,ProjectObject__c>([Select id,project_manager__c,Project_Co_ordinator__c from ProjectObject__c where id in:projectIdsSet]);
            //As per CRI-670
            Map<Id,Milestone_Period__c> milestonePeriodMap = new Map<Id,Milestone_Period__c>([Select id,Financial_Period_Closed__c from Milestone_Period__c where id in :milestonePeriodIdsSet]);
            for(Integer i=0;i<MilestoneOldList.size();i++){
                if(milestonePeriodMap!=null && milestonePeriodMap.get(MilestoneOldList[i].Milestone_Period__c)!=null &&  milestonePeriodMap.get(MilestoneOldList[i].Milestone_Period__c).Financial_Period_Closed__c == true){               
                   MilestoneOldList[i].addError('Milestone can not be deleted because its related period is closed.');
                }
                if(projectMap!=null && projectMap.get(MilestoneOldList[i].Project__c)!=null && projectMap.get(MilestoneOldList[i].Project__c).project_manager__c != UserInfo.getUserId() && projectMap.get(MilestoneOldList[i].Project__c).Project_Co_ordinator__c != UserInfo.getUserId() && !MilestoneOldList[i].Superuser_BU__c){
                   MilestoneOldList[i].addError('Milestone can not be deleted because you are not the Project Manager, Super User Or the Project co-ordinator of the related project.');
                }              
            }
        }
        
       // To update Calues of fields: Track_changes_history__c,Track_change__c,Milestone_Sign_Off_Name__c,Milestone_Code_Lookup__c 
        public static void MilestoneInsertChecks(List<Milestone__c> MilestoneNewList){
            Set<String> serviceTypeSet = new Set<String>();
            Set<String> milestoneCodeSet = new Set<String>();
            List<User> userList = [Select id,Profile.Name ,Name from User where id = :UserInfo.getUserId()];
            for(Milestone__c mls :MilestoneNewList){
                if(mls.Track_change__c!=null){
                    mls.Track_changes_history__c=userList[0].Name+'('+System.now()+')'+'\n'+mls.Track_change__c; 
                    mls.Track_change__c= '';
                }
                else{
                    mls.Track_change__c= '';
                    mls.Track_changes_history__c = '';
                }
                if(mls.Service_Type2__c!=null && mls.Milestone_Code2__c!=null){
                    serviceTypeSet.add(mls.Service_Type2__c);
                    milestoneCodeSet.add(mls.Milestone_Code2__c);
                }
                if(mls.Is_Signed__c == true){
                    mls.Milestone_Sign_Off_Name__c = UserInfo.getUserId();
                }
            }
            Map<String,Id> milestoneCodeMap = new Map<String,Id>();
            for(Milestone_Code__c milestoneCode : [Select id,Service_Type__c,Milestone__c from Milestone_Code__c
                                                    where Service_Type__c in :serviceTypeSet and Milestone__c in :milestoneCodeSet])
            milestoneCodeMap.put(milestoneCode.Service_Type__c+milestoneCode.Milestone__c,milestoneCode.id);
            
            for(integer i=0;i<MilestoneNewList.size();i++){
                if(MilestoneNewList[i].Service_Type2__c!=null && MilestoneNewList[i].Milestone_Code2__c!=null){                
                    MilestoneNewList[i].Milestone_Code_Lookup__c = milestoneCodeMap.get(MilestoneNewList[i].Service_Type2__c+MilestoneNewList[i].Milestone_Code2__c);
                }
            }
            
        }
        public static void MilestoneInsertIsSignedCheck(List<Milestone__c> MilestoneNewList){
            Decimal TotalMilestoneValue = MilestoneNewList[0].Total_Milestone_Value__c;
            Boolean IsSignedChecked = false;
            For(Milestone__c milestone:MilestoneNewList){
                if(milestone.Amount__c!=null){
                    TotalMilestoneValue = TotalMilestoneValue+milestone.Amount__c;
                }
                if(milestone.Is_Signed__c==true){
                    IsSignedChecked = true;
                }
            }
            
            For(Milestone__c milestone:MilestoneNewList){
                System.debug('Today TotalMilestoneValue '+TotalMilestoneValue);
                System.debug('Today Total_OrderProduct_Value__c '+milestone.Total_OrderProduct_Value__c);
                boolean abc = TotalMilestoneValue != milestone.Total_OrderProduct_Value__c ;
                System.debug('TotalMilestoneValue != milestone.Total_OrderProduct_Value__c '+abc);
                System.debug('-------IsSignedChecked-------- '+IsSignedChecked);
                if(IsSignedChecked==true && TotalMilestoneValue != milestone.Total_OrderProduct_Value__c){
                   milestone.addError('You can only sign a milestone if the total milestones value = the orderproduct value');  
                }
            }
        }
        Static Integer RunCount = 1;
        public static void MilestoneUpdateIsSignedCheck(List<Milestone__c> MilestoneNewList,List<Milestone__c> MilestoneOldList){
            if(RunCount==1){
            Decimal TotalMilestoneValue = MilestoneNewList[0].Total_Milestone_Value__c;
            Boolean IsSignedChecked = false;
            Decimal TotalUnsignedAmountOld=0;
            Decimal TotalUnsignedAmountNew=0; 
            Decimal TotalSignedAmount=0;
            for(Integer i=0;i<MilestoneNewList.size();i++){
                if(MilestoneOldList[i].Amount__c!=null){
                    System.debug('Milestone Amount '+MilestoneOldList[i].Amount__c);  
                    TotalUnsignedAmountOld = TotalUnsignedAmountOld+MilestoneOldList[i].Amount__c;
                }
                if(MilestoneNewList[i].Amount__c!=null){
                    TotalUnsignedAmountNew = TotalUnsignedAmountNew+MilestoneNewList[i].Amount__c;
                }
                if(MilestoneNewList[i].Is_Signed__c==true && MilestoneOldList[i].Is_Signed__c==false){
                    IsSignedChecked = true;
                }
            }
            system.debug('--update---');
            TotalSignedAmount =  TotalMilestoneValue-TotalUnsignedAmountOld;
            For(Milestone__c milestone:MilestoneNewList){ 
            system.debug('--TotalSignedAmount---'+TotalSignedAmount);
            system.debug('--TotalUnsignedAmountNew---'+TotalUnsignedAmountNew);
            system.debug('--milestone.Total_OrderProduct_Value__c---'+milestone.Total_OrderProduct_Value__c);
                if(IsSignedChecked==true && (TotalUnsignedAmountNew+TotalSignedAmount) != milestone.Total_OrderProduct_Value__c){
                    milestone.addError('You can only sign a milestone if the total milestones value = the orderproduct value');  
                }
            }
        }
            RunCount++;
        }
    
    //Method to share project and milestone with read access to cross border milestone owners
    public static void extendOppAccessToCrossBorderMilestone(list<Milestone__c> milestonelist, Map<Id, Milestone__c> oldMap){
        list<ProjectObject__Share> projShareList = new list<ProjectObject__Share>();
		Map<id,string> oldProjectSharing = new Map<id,string>();
        List<ProjectObject__Share> projectSharingToDelete = new List<ProjectObject__Share>();
        List<Database.SaveResult> saveProjectShareResult = new List<Database.SaveResult>();
        list<Id> milestoneOwnerList = new list<Id>();
		List<string> crossborderBU = new List<string>();
		Set<string> groupname = new set<string>();
		
		Map<string,id> PSgroupmap1 = new Map<string,id>();
		Map<string,id> PSgroupmap = new Map<string,id>();
		
		List<PS_cross_border_milestone_sharing__mdt> InActiveEmailRecords = [Select Cross_Border_BU__c, Public_Group__c from PS_cross_border_milestone_sharing__mdt];
		for(PS_cross_border_milestone_sharing__mdt psmetagroup:InActiveEmailRecords)
		{
			groupname.add(psmetagroup.Public_Group__c);
		}
		List<Group> PSgroup = [Select id, name, developername from group where name IN: groupname];
		
		for(Group PSg:PSgroup)
		{
			PSgroupmap1.put(PSg.name,PSg.id);
		}
		
		for(PS_cross_border_milestone_sharing__mdt psmeta:InActiveEmailRecords)
		{
			PSgroupmap.put(psmeta.Cross_Border_BU__c, PSgroupmap1.get(psmeta.Public_Group__c));
		}
		
		
		if(milestonelist.size() > 0)
		{
		
			for(Milestone__c mil : milestonelist){
			List<string> crossborderlist = new List<string>();
			ProjectObject__Share projectShare = new ProjectObject__Share();
				if(mil.Cross_Border_BU__c != null && oldmap ==null && PSgroupmap!=null){
												
                        projectShare.AccessLevel = 'Read';
                        projectShare.ParentId = mil.Project__c;
                        projectShare.UserOrGroupId = PSgroupmap.get(mil.Cross_Border_BU__c);
                        projectShare.RowCause = Schema.ProjectObject__Share.RowCause.Share_with_crossborder_milestoneowner__c;
                        projShareList.add(projectShare);
					}
				
				if(oldMap != null && oldMap.size() > 0){
				
					if(oldMap.get(mil.id).Cross_Border_BU__c!=mil.Cross_Border_BU__c && mil.Cross_Border_BU__c!=null){
						system.debug('--->PSgroupmap.get(mil.Cross_Border_BU__c)<----'+PSgroupmap.get(mil.Cross_Border_BU__c));
						projectShare.ParentId = mil.Project__c;
						projectShare.UserOrGroupId = PSgroupmap.get(mil.Cross_Border_BU__c);
						projectShare.AccessLevel = 'Read';
						projectShare.RowCause = Schema.ProjectObject__Share.RowCause.Share_with_crossborder_milestoneowner__c;
						projShareList.add(projectShare);
						oldProjectSharing.put(mil.Project__c, oldMap.get(mil.id).Cross_Border_BU__c);
					
					}
					if(mil.Cross_Border_BU__c ==null && oldMap.get(mil.id).Cross_Border_BU__c!=mil.Cross_Border_BU__c){
                        oldProjectSharing.put(mil.Project__c, oldMap.get(mil.id).Cross_Border_BU__c);
                    }
				}
			}
							
		}
				
			
		
        if(oldProjectSharing.size() > 0){	
            projectSharingToDelete = [SELECT Id FROM ProjectObject__Share 
                                      WHERE ParentId In :oldProjectSharing.keyset()
                                      AND RowCause=:Schema.ProjectObject__Share.RowCause.Share_with_crossborder_milestoneowner__c];
            delete projectSharingToDelete;
        }
        
        if(projShareList.size()>0){
            saveProjectShareResult = Database.insert(projShareList,false);
        }
        
        if(saveProjectShareResult.size()>0){
            Integer i=0;
            for(Database.SaveResult sr : saveProjectShareResult){
                if(sr.isSuccess()){
                    System.debug('Success Id: '+ sr.getId());
                }else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Project fields that causes error: ' + err.getFields());
                    }
                }
                i++;
            }
        }
    }
        
    }