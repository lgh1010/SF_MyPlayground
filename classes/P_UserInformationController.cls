public with sharing class P_UserInformationController {
    @AuraEnabled
    public static Map<String, Object> getInit(){
        try {
            return new Map<String, Object> {
                'userInfo' => getUserInfo()
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static UserInfoWrapper getUserInfo(){
        UserInfoWrapper result = new UserInfoWrapper();

        try {
            User u = [
                SELECT FirstName, 
                       LastName, 
                       Username, 
                       Email, 
                       Contact.AccountId
                FROM User 
                WHERE Id = :System.UserInfo.getUserId()
            ];
            result = new UserInfoWrapper(u);
        } catch (Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
            result.errorMessage = ERROR_MSG;
        }

        return result;
    }

    class UserInfoWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String username;
        @AuraEnabled public String email;
        @AuraEnabled public String contactId;
        @AuraEnabled public String accountId;

        @AuraEnabled public String errorMessage;

        public UserInfoWrapper(){}
        public UserInfoWrapper(User u) {
            this.id = u.Id;
            this.firstName = u.FirstName;
            this.lastName = u.LastName;
            this.userName = u.Username;
            this.email = u.Email;
            
            String contactId = '';
            if(String.isNotBlank(u.ContactId)) {
                contactId = u.ContactId;
            } else {
                List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
                contactId = contactList.get(0)?.Id;
            }
            this.contactId = contactId;

            String accountId = '';
            if(String.isNotBlank(u.Contact?.AccountId)) {
                accountId = u.Contact.AccountId;
            } else {
                List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
                accountId = accountList.get(0)?.Id;
            }
            this.accountId = accountId;
        }
    }
}
