global class MSAContractENBA {  
    @InvocableMethod(label='MSA Contract Check' 
                     description='Recommends action based on MSA Contract availability')
    global static List<List<Recommendation>> getMSAContract(List<String> inputData){
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        List<Contract> contract = [SELECT Id,ContractNumber FROM Contract WHERE AccountId = :inputData[0] AND Status='Active' AND RecordType.Name='MSA Contract'];
         List<Recommendation> recs = new List<Recommendation>(); 
         Recommendation rec = new Recommendation();
            if (contract.size()==0){
                        rec.Name = 'New MSA';
                        rec.Description = 'No active MSA contract exists for the account. Click on Launch CLM and select MSA from list of Options.';
                        rec.ActionReference = 'Launch_Clm_For_Account';
                        rec.AcceptanceLabel = 'Launch CLM';
                		rec.ImageId = '03S4G00000005Co';
                		recs.add(rec);
                }
        else{
            rec.Name = 'New MSA';
                        rec.Description = 'Active MSA Contract exists. Click on Launch CLM to create Amendment or a new MSA Contract from list of options.';
                        rec.ActionReference = 'Launch_Clm_For_Account';
                        rec.AcceptanceLabel = 'Launch CLM';
            			rec.ImageId = '03S4G00000005Co';
                		recs.add(rec);
        }
        outputs.add(recs);
        return outputs; 
    }
}