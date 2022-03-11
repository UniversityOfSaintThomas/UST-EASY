trigger INT_OpportunityTrigger on Opportunity (after delete, after insert, after undelete,after update, before delete, before insert, before update) {

hed.TDTM_Global_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Opportunity);
}