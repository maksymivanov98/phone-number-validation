trigger ContactTrigger on Contact (before insert, after insert, before update, before delete, after delete) {
    
    ContactTriggerHandler handler = new ContactTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        handler.beforeInsert(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        handler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    
    if(Trigger.isBefore && Trigger.IsDelete){
        handler.beforeDelete(Trigger.oldMap);
    }
    
    
}