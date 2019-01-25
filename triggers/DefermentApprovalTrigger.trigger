trigger DefermentApprovalTrigger on Deferment_Approval__c (before insert, before update, after insert, after update, after delete) {
    
    if(Trigger.isAfter && Trigger.isUpdate ){

        DefermentApprovalTrigger_helper.chainingApprovals(Trigger.new,Trigger.old, Trigger.oldMap);
        
    }

}