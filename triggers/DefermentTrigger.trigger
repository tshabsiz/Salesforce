trigger DefermentTrigger on Deferment__c (before insert, before update, after insert, after update, after delete) {
    
    if (Trigger.isAfter && Trigger.isInsert) { 
        
        DefermentTrigger_Helper.CreateDefermentApprovals(Trigger.new);
    }
}