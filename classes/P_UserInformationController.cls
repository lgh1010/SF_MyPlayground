public with sharing class P_UserInformationController {
    @AuraEnabled
    public static Map<String, Object> getInit(){
        try {
            Map<String, String> userInfo = getUserInfo();

            return new Map<String, Object> {
                'userInfo' => userInfo,
                'account'  => getAccountInfo(userInfo.get('AccountId'))
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getUserInfo(){
        Map<String, String> result = new Map<String, String>();

        try {
            User u = [SELECT FirstName, LastName, Username, Email, Contact.AccountId FROM User WHERE Id = :System.UserInfo.getUserId()];

            result.putAll(new Map<String, String>{
                'FirstName' => u.FirstName,
                'LastName'  => u.LastName,
                'Username'  => u.Username,
                'Email'     => u.Email,
                'AccountId' => u.Contact?.AccountId
            });
        } catch (Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
            result.put('ERROR_MSG', ERROR_MSG);
        }

        return result;
    }

    public static Map<String, String> getAccountInfo(String accountId) {
        Map<String, String> result = new Map<String, String>();

        try {
            Account a = [SELECT Name FROM Account WHERE Id = :accountId];

            result.putAll(new Map<String, String> {
                'Name' => a.Name
            });
        } catch (Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
            result.put('ERROR_MSG', ERROR_MSG);
        }

        return result;
    }

}
