/* @Author      Mtha Gumede
* @Company:     Absa
* @Description: Helper class for Derferment trigger
* @Date:        10/2018
* @TestClasses:
* History
* <Date>      <Authors Name>    <Brief Description of Change>*/
public class DefermentTrigger_Helper {
    
    static public void CreateDefermentApprovals(list<Deferment__c> newDeferment) {
        
        list<Deferment_Approval__c>Defermentaproval = new list<Deferment_Approval__c>(); 
        list<RecordType>RecordTypes = new list<RecordType>();
        
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Deferment_Approval__c']){
            RecordTypes.add(rt);
        }
        
        
        for(Deferment__c deferment :newDeferment){
            for(RecordType rt :RecordTypes){
                
                Deferment_Approval__c defermentApproval = new Deferment_Approval__c();
                defermentApproval.Deferment__c = deferment.id;
                defermentApproval.RecordTypeId = rt.id;
                defermentApproval.Credit__c = deferment.Credit_Approver__c;                 
                defermentApproval.legal__c = deferment.Legal_Approver__c;
                defermentApproval.Product_Partner__c =deferment.Product_Approver__c;
                
                Defermentaproval.add(defermentApproval);
            }   
        }
        if (!Defermentaproval.isEmpty()){
            
            try{
                
                insert Defermentaproval;
                
            }
            catch (Exception e) {
                //Insert to a log object 
                system.debug('Defermentaproval not inserted');
                
            }
            
        }
    }
}