public class DefermentApprovalTrigger_helper {
    
    
    static public void chainingApprovals(list<Deferment_Approval__c>newDefermentApproval, list<Deferment_Approval__c>oldDefermentApproval, Map<id, Deferment_Approval__c>oldMapDefermentApproval){
        
        List<Approval.ProcessSubmitRequest> submit_requests = new List<Approval.ProcessSubmitRequest>();
        List<Deferment_Approval__c> thirdApprovedDeferment= new List<Deferment_Approval__c>();
        Set<id> trdAppDeferment = new Set<Id>(); 
        Set<id> secAppDeferment = new Set<Id>();
        Set<id> AppDeferment = new Set<Id>();      
 
        for(Deferment_Approval__c defermentApproval :newDefermentApproval){
            
            if(oldMapDefermentApproval.get(defermentApproval.Id).first_approval__c != defermentApproval.first_approval__c && defermentApproval.first_approval__c == True){
  
                AppDeferment.add(defermentApproval.Id);
                
            }else if(oldMapDefermentApproval.get(defermentApproval.Id).second_approval__c != defermentApproval.second_approval__c && defermentApproval.second_approval__c == True){

                secAppDeferment.add(defermentApproval.Id);
                
            }else if(oldMapDefermentApproval.get(defermentApproval.Id).third_approval__c != defermentApproval.third_approval__c && defermentApproval.third_approval__c == True){
            
               thirdApprovedDeferment.add(defermentApproval);
               trdAppDeferment.add(defermentApproval.Id);
                
            }
        }
        
        if(!AppDeferment.isEmpty()){
     
            
            DefermentApprovalTrigger_helper.Approvals(AppDeferment, 'Deferment Initial approval1','X1st_Approval');

        }else if(!secAppDeferment.isEmpty()){
       
            
              DefermentApprovalTrigger_helper.Approvals(secAppDeferment, '1st Approval','X2nd_Approval');
            
        }else if(!thirdApprovedDeferment.isEmpty()){
              Map<Id, Id>Deferment = new Map<Id, Id>(); 
            
            for(Deferment_Approval__c defmt: [SELECT Id, Deferment__r.Id FROM Deferment_Approval__c WHERE Id IN:trdAppDeferment]){
                
                Deferment.put(defmt.Id, defmt.Deferment__r.Id );
                
            }
            
            DefermentApprovalTrigger_helper.finalchainingApprovals(trdAppDeferment, Deferment, thirdApprovedDeferment, '1st Approval', 'Executive_Approval');

        }
        
       
        
    }
    static private void Approvals(Set<Id>AppDeferment, String rejection, String Approvals){
        
        List<Approval.ProcessSubmitRequest> submit_requests = new List<Approval.ProcessSubmitRequest>();
        
        for( ProcessInstance rejected_approval :[SELECT Id, LastActorId,TargetObjectId 
                                                         FROM ProcessInstance
                                                         WHERE Status = 'Rejected' 
                                                         AND ProcessDefinition.Name =:rejection
                                                         AND TargetObjectId IN:AppDeferment])
        {
           
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('The Approver was rejected it has been esculated to you');
            if(Approvals == 'Executive_Approval'){
            req.setObjectId(rejected_approval.TargetObjectId);  
            }else{   
            req.setObjectId(rejected_approval.TargetObjectId);                
            }
            req.setSubmitterId(rejected_approval.LastActorId);
            req.setProcessDefinitionNameOrId(Approvals);

            submit_requests.add(req);

            
        }
        

        try {
         
            if (submit_requests.size() > 0) Approval.process(submit_requests, true);
            
        } catch (Exception e) {
            System.debug('Exception updating second approval:' + e.getMessage());
        }       
    }
    
      static private void finalchainingApprovals(Set<Id>AppDeferment, Map<Id,Id>Deferment, list <Deferment_Approval__c>ApprovedDeferment, String rejection, String Approvals){
        
        List<Approval.ProcessSubmitRequest> submit_requests = new List<Approval.ProcessSubmitRequest>();
    
        for( ProcessInstance rejected_approval :[SELECT Id, LastActorId,TargetObjectId 
                                                         FROM ProcessInstance
                                                         WHERE Status = 'Rejected' 
                                                         AND ProcessDefinition.Name =:rejection
                                                         AND TargetObjectId IN:AppDeferment])
        {
      
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('The Approver was rejected it has been esculated to you');
            req.setObjectId(Deferment.get(rejected_approval.TargetObjectId));
            req.setSubmitterId(rejected_approval.LastActorId);
            req.setProcessDefinitionNameOrId(Approvals);

            
            submit_requests.add(req);

            
        }
        

        try {
         
            if (submit_requests.size() > 0) Approval.process(submit_requests, true);
            
        } catch (Exception e) {
            System.debug('Exception updating second approval:' + e.getMessage());
        }       
    }
}