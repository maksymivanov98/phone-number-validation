trigger ContactTrigger4 on Contact (before insert, before update, after insert, after update, before delete, after delete) {
    new ContactTriggerHandler4().run();
}