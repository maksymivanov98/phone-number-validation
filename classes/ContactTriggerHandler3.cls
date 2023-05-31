public without sharing class ContactTriggerHandler3 implements TriggerHandler3 {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public ContactTriggerHelper3 helper;
    public ContactTriggerHandler3(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new ContactTriggerHelper3();
    }
    public void beforeInsert(List<Contact> newContacts) {
        helper.validationBeforeInsert(newContacts);
    }
    public void beforeUpdate(List<Contact> oldContacts, List<Contact> newContacts, Map<ID, SObject> oldContactMap, Map<ID, SObject> newContactMap) {
        helper.validationBeforeUpdate(oldContacts, newContacts);
    }
    public void beforeDelete(List<Contact> oldContacts, Map<ID, SObject> oldContactMap) {
        helper.deleteContactNumberFromAccount(oldContacts);
    }
    public void afterInsert(List<Contact> newContacts, Map<ID, SObject> newContactMap) {

    }
    public void afterUpdate(List<Contact> oldContacts, List<Contact> newContacts, Map<ID, SObject> oldContactMap, Map<ID, SObject> newContactMap) {

    }
    public void afterDelete(List<Contact> oldContacts, Map<ID, SObject> oldContactMap) {

    }
    public void afterUndelete(List<Contact> newContacts, Map<ID, SObject> newContactMap) {

    }
}