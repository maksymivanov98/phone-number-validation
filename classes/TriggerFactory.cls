public with sharing class TriggerFactory {
    public static void createHandler(Schema.sObjectType soType) {
        ITrigger handler = getHandler(soType);
        
        if(handler == null) {
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }
        
        execute(handler);
    }
    private static void execute(ITrigger handler) {
        if(Trigger.isBefore) {
            handler.bulkBefore();
        }
        else {
            handler.bulkAfter();
        }
    }
    
    private static ITrigger getHandler(Schema.sObjectType soType) {
        if(soType == Contact.sObjectType) {
            return new ContactTriggerHandler2();
        }
        
        return null;
    }
}