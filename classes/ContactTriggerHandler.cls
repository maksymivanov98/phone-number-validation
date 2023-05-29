public class ContactTriggerHandler {
    
    public void beforeInsert(List <Contact> newContactList){
        validationBeforeInsert(newContactList);
    }
    
    public void beforeUpdate(Map <id, Contact> oldContactMap, Map <id, Contact> newContactMap){
        validationBeforeUpdate(oldContactMap, newContactMap);
    }
    
    public void beforeDelete(Map <id, Contact> oldContactMap){
        deleteContactNumberFromAccount(oldContactMap.values());
    }
    
    private void validationBeforeInsert(List <Contact> contactList){
        checkPhoneNumber(contactList);
        try{
            addPhoneToAccountBeforeInsert(contactList);
        }catch(Exception ex){
            throw new ContactTriggerHandlerException('An error occurred while adding/remove a contact number to an account: ' + ex.getLineNumber() + ex.getMessage());
        }
    }
    
    private void validationBeforeUpdate(Map <id, Contact> oldContactMap, Map <id, Contact> newContactMap){
        checkPhoneNumber(newContactMap.values());
        try{
            addPhoneToAccountBeforeUpdate(oldContactMap, newContactMap);
        }catch(Exception ex){
            throw new ContactTriggerHandlerException('An error occurred while adding/remove a contact number to an account: ' + ex.getLineNumber() + ex.getMessage());
        }
    }
    
    private void checkPhoneNumber(List <Contact> contactList){
        for(Contact contact : contactList){
            if(!String.isBlank(contact.Phone)){
                contact.Phone = checkOnRegionCode(contact);
                contact.Phone = removeOtherSymbols(contact.phone);
                if(!checkNumberSymbols(contact.Phone)){
                    contact.Phone.addError('The phone number has the wrong length');
                }
            }
        }
    }
    
    private Boolean checkNumberSymbols(String phoneNumber){
        Integer phoneNumberLength = phoneNumber.length();
        return phoneNumberLength >= 10 && phoneNumberLength <= 15;
    }
    
    private String removeOtherSymbols(String phone){
        phone = phone.replaceAll('[a-zA-Z\\s-]', '');
        return phone;
    }
    
    private String checkOnRegionCode(Contact contact) {
        if (contact.Phone.startsWith('+')) {
            return contact.Phone;
        }
        Region_Code__c region = Region_Code__c.getInstance(contact.OtherCountry);
        if (region != null && region.Code__c != null) {
            return region.Code__c + contact.Phone;
        }
        return contact.Phone;
    }
    
    private Map<Id, Account> getAccountMap(Set<Id> idAccountSet) {
        return new Map<Id, Account>([SELECT Id, Contact_Numbers__c FROM Account WHERE Id IN :idAccountSet]);
    }
    
    private String removePhoneFromAccount(String contactNumbers, String phone) {
        List<String> lines = contactNumbers.split('\n');
        List<String> updatedcontactNumbers = new List<String>();
        for (String line : lines) {
            if (!line.contains(phone)) {
                updatedcontactNumbers.add(line);
            }
        }
        return String.join(updatedcontactNumbers, '\n');
    }
    
    private void addPhoneToAccountBeforeInsert(List <Contact> contactList){
        Set<Id>accountIdSet = new Set<Id>();
        for(Contact contact : contactList){
            if(!String.isBlank(contact.AccountId)){
                accountIdSet.add(contact.AccountId);
            }
        }
        if(!accountIdSet.isEmpty()){
            Map<id, Account> accountMap = getAccountMap(accountIdSet);
            for(Contact contact : contactList){
                if(!String.isBlank(contact.AccountId) && !String.isBlank(contact.Phone)){
                    String firstName = contact.FirstName == null ? '' : contact.FirstName;
                    String lastName = contact.LastName == null ? '' : contact.LastName;
                    accountMap.get(contact.AccountId).Contact_Numbers__c = accountMap.get(contact.AccountId).Contact_Numbers__c == null ? '' : accountMap.get(contact.AccountId).Contact_Numbers__c;
                    accountMap.get(contact.AccountId).Contact_Numbers__c += '\n' + firstName + ' ' + lastName + ': ' + contact.Phone;
                }
            }
            update accountMap.values();
        }
    }
    
    private void addPhoneToAccountBeforeUpdate(Map <id, Contact> oldContactMap, Map <id, Contact> newContactMap){
        Set<Id>accountIdSet = new Set<Id>();
        for(Contact contact : oldContactMap.values()){
            if(!String.isBlank(contact.AccountId) && !String.isBlank(contact.Phone)){
                accountIdSet.add(contact.AccountId);
            }
        }
        for(Contact contact : newContactMap.values()){
            if(!String.isBlank(contact.AccountId)){
                accountIdSet.add(contact.AccountId);
            }
        }
        if(accountIdSet.size() > 0){
            Map<id, Account> accountMap = getAccountMap(accountIdSet);
            for(Contact contact : oldContactMap.values()){
                Account account;
                if(!String.isBlank(contact.AccountId)){
                    account = accountMap.get(contact.AccountId);
                }else{
                    account = accountMap.get(newContactMap.get(contact.id).accountId);
                }
                if(contact.Phone != newContactMap.get(contact.id).Phone || contact.accountId != newContactMap.get(contact.id).accountId){
                    if(!String.isBlank(contact.accountId) && account.Contact_Numbers__c.contains(contact.Phone) && newContactMap.get(contact.id).Phone != null && newContactMap.get(contact.id).accountId != null){
                        // update
                        if(contact.Phone.startsWith('+') && newContactMap.get(contact.id).Phone.startsWith('+')){
                            account.Contact_Numbers__c = account.Contact_Numbers__c.replaceAll('\\'+contact.Phone, '\\'+newContactMap.get(contact.id).Phone);
                        }else if(!contact.Phone.startsWith('+') && newContactMap.get(contact.id).Phone.startsWith('+')){
                            account.Contact_Numbers__c = account.Contact_Numbers__c.replaceAll(contact.Phone, '\\'+newContactMap.get(contact.id).Phone);
                        }else if(contact.Phone.startsWith('+') && !newContactMap.get(contact.id).Phone.startsWith('+')){
                            account.Contact_Numbers__c = account.Contact_Numbers__c.replaceAll('\\' + contact.Phone, newContactMap.get(contact.id).Phone);
                        }else if(!contact.Phone.startsWith('+') && !newContactMap.get(contact.id).Phone.startsWith('+')){
                            account.Contact_Numbers__c = account.Contact_Numbers__c.replaceAll(contact.Phone, newContactMap.get(contact.id).Phone);
                        }
                    }else if(!String.isBlank(contact.accountId) && account.Contact_Numbers__c.contains(contact.Phone) && (newContactMap.get(contact.id).Phone == null || newContactMap.get(contact.id).accountId == null)){
                        //delete
                        account.Contact_Numbers__c = removePhoneFromAccount(account.Contact_Numbers__c, contact.Phone);
                    }else if(!String.isBlank(newContactMap.get(contact.id).accountId)){
                        //add
                        String firstName = contact.FirstName == null ? '' : contact.FirstName;
                        String lastName = contact.LastName == null ? '' : contact.LastName;
                        accountMap.get(newContactMap.get(contact.id).accountId).Contact_Numbers__c += '\n' + firstName + ' ' + lastName + ': ' + contact.Phone;
                    }
                }
            }
            update accountMap.values();
        }
    }
    
    private void deleteContactNumberFromAccount(List<Contact> contactList) {
        Set<Id> accountIdSet = new Set<Id>();
        for (Contact contact : contactList) {
            accountIdSet.add(contact.AccountId);
        }
        if(!accountIdSet.isEmpty()){
            Map<Id, Account> accountMap = getAccountMap(accountIdSet);
            List<Account> accountsToUpdate = new List<Account>();
            for (Contact contact : contactList) {
                Account account = accountMap.get(contact.AccountId);
                if (account != null && !String.isBlank(account.Contact_Numbers__c)) {
                    String certainPhone = contact.Phone;
                    String updatedTextFieldValue = removePhoneFromAccount(account.Contact_Numbers__c, certainPhone);
                    account.Contact_Numbers__c = updatedTextFieldValue;
                    accountsToUpdate.add(account);
                }
            }
            update accountsToUpdate;
        }
    }
    
    public class ContactTriggerHandlerException extends Exception {
        
    }
    
}