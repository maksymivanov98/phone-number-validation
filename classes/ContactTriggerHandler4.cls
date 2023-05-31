public without sharing class ContactTriggerHandler4 extends TriggerHandler4 {
    
    public static Boolean skip = false;
    
    private ContactTriggerHandlerHelper4 helper = new ContactTriggerHandlerHelper4();
    
    protected override void beforeInsert() {
        if (skip) return;
        helper.validationBeforeInsert(Trigger.New);
    }

	protected override void beforeUpdate(){
        if (skip) return;
        helper.validationBeforeUpdate(Trigger.old, Trigger.new);
	}
    
    protected override void beforeDelete() {
        if (skip) return;
        
    }
    
}